#!/usr/bin/env bash

# Get the path of the current script.
# https://stackoverflow.com/questions/59895/getting-the-source-directory-of-a-bash-script-from-within
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

function should_show_help() {
  if [[ $# -eq 0 ]]; then
    return 0
  fi

  while [[ $# -gt 0 ]]; do
    case $1 in
    -h|--help)
      return 0
      ;;
    *) ;;

    esac
    shift
  done

  return 1
}

function help() {
  cat <<EOF
Usage: helm risingwave <command> <release_name> [chart] [flags]
  Commands:
    pause       Pause a RisingWave release
    resume      Resume a RisingWave release if paused
    upgrade     Upgrade a RisingWave release
      --version <string>  The version of the release to upgrade to
    rollback    Rollback a RisingWave release to the previous revision

  Optional:
    chart       The chart name of the release

  Flags:
    -h, --help  Show help for this command
EOF
}

function export_release_info() {
  output=$($HELM_BIN -n "$HELM_NAMESPACE" list -f "$1" --output json | jq -r '.[] | "\(.chart) \(.revision) \(.app_version) \(.status)"') || return $?
  IFS=' ' read -r chart revision app_version status <<<"$output"

  if [[ -z "$chart" ]]; then
    echo "Release $1 not found." 1>&2
    exit 1
  fi

  export HELM_RELEASE=$1
  export HELM_RELEASE_CHART=$chart
  export HELM_RELEASE_REVISION=$revision
  export HELM_RELEASE_APP_VERSION=$app_version
  export HELM_RELEASE_STATUS=$status
}

function export_last_action() {
  output=$(kubectl -n "$HELM_NAMESPACE" get secret "sh.helm.release.v1.$HELM_RELEASE.v$HELM_RELEASE_REVISION" \
    -o jsonpath='{.metadata.annotations.risingwave\.plugins\.helm\.sh/last-action} {.metadata.annotations.risingwave\.plugins\.helm\.sh/last-revision} {.items[0].metadata.resourceVersion}') || return $?
  IFS=' ' read -r last_action last_revision resource_version <<<"$output"
  export HELM_RELEASE_LAST_ACTION=$last_action
  export HELM_RELEASE_PREV_REVISION=$last_revision
  export HELM_RELEASE_SECRET_RESOURCE_VERSION=$resource_version
}

function record_current_action() {
  kubectl -n "$HELM_NAMESPACE" annotate secret "sh.helm.release.v1.$HELM_RELEASE.v$((HELM_RELEASE_REVISION + 1))" \
    "risingwave.plugins.helm.sh/last-action=$1" \
    "risingwave.plugins.helm.sh/last-revision=$HELM_RELEASE_REVISION" \
    --resource-version="$HELM_RELEASE_SECRET_RESOURCE_VERSION" \
    --overwrite || return $?
}

function pause() {
  # If last action is pause, do nothing.
  if [[ "$HELM_RELEASE_LAST_ACTION" == pause ]]; then
    echo "Release $HELM_RELEASE is already paused." 1>&2
    exit 1
  fi

  $HELM_BIN upgrade "$HELM_RELEASE" "$HELM_CHART" \
    --namespace "$HELM_NAMESPACE" \
    --reuse-values \
    --values "$SCRIPT_DIR/pause.values.yaml" \
    --atomic

  record_current_action pause
}

function resume() {
  # If last action isn't pause, do nothing.
  if [[ "$HELM_RELEASE_LAST_ACTION" != pause ]]; then
    echo "Release $HELM_RELEASE is not paused." 1>&2
    exit 1
  fi

  # Rollback to last revision.
  $HELM_BIN rollback "$HELM_RELEASE" "$HELM_RELEASE_PREV_REVISION" \
    --namespace "$HELM_NAMESPACE" \
    --wait
}

function upgrade() {
  # If last action is pause, do nothing.
  if [[ "$HELM_RELEASE_LAST_ACTION" == pause ]]; then
    echo "Release $HELM_RELEASE is paused." 1>&2
    exit 1
  fi

  # Get version from opts.
  while [[ $# -gt 0 ]]; do
    case $1 in
    --version)
      shift
      export HELM_RELEASE_APP_VERSION=$1
      ;;
    *) ;;

    esac
    shift
  done

  # If version is not set, do nothing.
  if [[ -z "$HELM_RELEASE_APP_VERSION" ]]; then
    echo "Release $HELM_RELEASE version is not set." 1>&2
    help 1>&2
    exit 1
  fi

  $HELM_BIN upgrade "$HELM_RELEASE" "$HELM_CHART" \
    --namespace "$HELM_NAMESPACE" \
    --reuse-values \
    --set image.tag="$HELM_RELEASE_APP_VERSION" \
    --atomic

  record_current_action upgrade
}

function rollback() {
  # If last action is pause, do nothing.
  if [[ "$HELM_RELEASE_LAST_ACTION" == pause ]]; then
    echo "Release $HELM_RELEASE is paused." 1>&2
    exit 1
  fi

  # If last action isn't upgrade, do nothing.
  if [[ "$HELM_RELEASE_LAST_ACTION" != upgrade ]]; then
    echo "Release $HELM_RELEASE has no upgrade history." 1>&2
    exit 1
  fi

  # Rollback to last revision.
  $HELM_BIN rollback "$HELM_RELEASE" "$HELM_RELEASE_PREV_REVISION" \
    --namespace "$HELM_NAMESPACE" \
    --wait
}

if should_show_help "$@"; then
  help
  exit 0
fi

# Check arguments, at least 1.
if [ $# -lt 2 ]; then
  help 1>&2
  exit 1
fi

subcommand=$1
release_name=$2

export_release_info "$release_name"

if [ $# -gt 2 ]; then
  chart=$3
  export HELM_CHART=$chart
else
  export HELM_CHART=risingwavelabs/risingwave
fi

# Check chart is risingwave-*
if [[ "$HELM_RELEASE_CHART" != risingwave-* ]]; then
  echo "Chart $HELM_RELEASE_CHART is not a risingwave chart." 1>&2
  exit 1
fi

# Check release is deployed
if [[ "$HELM_RELEASE_STATUS" != deployed ]]; then
  echo "Release $HELM_RELEASE is not deployed." 1>&2
  exit 1
fi

export_last_action

case $subcommand in
pause)
  pause
  ;;
resume)
  resume
  ;;
upgrade)
  # Pass the rest of the arguments to upgrade.
  upgrade "${@:2}"
  ;;
rollback)
  rollback
  ;;
*)
  help 1>&2
  exit 1
  ;;
esac
