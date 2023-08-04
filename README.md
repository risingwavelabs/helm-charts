# helm-charts

[![Release Charts](https://github.com/risingwavelabs/helm-charts/actions/workflows/release.yml/badge.svg)](https://github.com/risingwavelabs/helm-charts/actions/workflows/release.yml)

## Usage

[Helm](https://helm.sh/) must be installed to use the charts. Please refer to Helm's [documentation](https://helm.sh/docs/intro/install/) to get started.

Once Helm is set up properly, add the repository as follows:

```bash
helm repo add risingwavelabs https://risingwavelabs.github.io/helm-charts/
```

You can then run `helm search repo risingwavelabs` to see the charts.

## Examples

Please refer to the [examples](examples) directory for examples on how to customize the values.

For example, deploy a RisingWave with authentication, database, and state store configurations:

```bash
helm install \
  -f examples/auth/root-user.values.yaml \
  -f examples/database/databases.values.yaml \
  -f examples/state-store/s3.values.yaml \
  risingwave risingwavelabs/risingwave
```

## Plugin

Install the [risingwave](/plugins/risingwave) plugin to operate the releases.

```bash
helm plugin install ./plugins/risingwave
```

Pause the release:

```bash
helm risingwave pause <release-name> [chart]
```

Resume the release:

```bash
helm risingwave resume <release-name> [chart]
```

Upgrade the release:

```bash
helm risingwave upgrade <release-name> [chart] --version=<version>
```

Rollback the upgrade:

```bash
helm risingwave rollback <release-name> [chart]
```

## License

Apache License 2.0. See [LICENSE](LICENSE) for more details.
