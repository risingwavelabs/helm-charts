# helm-charts

[![Release Charts](https://github.com/risingwavelabs/helm-charts/actions/workflows/release.yml/badge.svg)](https://github.com/risingwavelabs/helm-charts/actions/workflows/release.yml)

## Usage

[Helm](https://helm.sh/) must be installed to use the charts. Please refer to Helm's [documentation](https://helm.sh/docs/intro/install/) to get started.

Once Helm is set up properly, add the repository as follows:

```bash
helm repo add risingwavelabs https://risingwavelabs.github.io/helm-charts/
```

You can then run `helm search repo risingwavelabs` to see the charts.

## Deploy

To deploy the RisingWave chart with the release name `risingwave`:

```bash
helm install --set wait=true risingwave risingwavelabs/risingwave
```

Example output:

```plain
NAME: risingwave
LAST DEPLOYED: Mon Aug  7 14:41:08 2023
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
Welcome to fast and modern stream processing with RisingWave!

Check the running status with the following command:

    kubectl get pods -l app.kubernetes.io/instance=risingwave

Try accessing the SQL console with the following command:

    kubectl port-forward svc/risingwave 4567:svc

Keep the above command running and open a new terminal window to run the following command:

    psql -h localhost -p 4567 -d dev -U root

For more advanced applications, refer to our documentation at: https://www.risingwave.dev
```

## Uninstallation

To uninstall the `risingwave` release, simply run the following command:

```shell
helm uninstall risingwave
```

> WARNING: reinstalling a release with the same name without the data fully purged might result in undefined behaviours.
> It can be the same as restarting when and only when all the data (e.g., PVC + S3) is untouched.  

Note that helm won't delete the PVCs used by `etcd` or `minio` nor the data on S3 or other object storages. 
You may be required to delete them manually. The following commands can help with the deletion of the PVCs:

```shell
# replace risingwave with the real release name when it has a different value
kubectl delete -l app.kubernetes.io/instance=risingwave
```

Additionally, the PVs won't be reclaimed depending on the options on the storage class. 
Please refer to the [documentation](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#reclaiming) and delete them yourselves.

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

To show all the possible configurations:

```bash
helm show values risingwavelabs/risingwave
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

## FAQ

### 1. Hook for creating databases failed.

Example:

```plain
kubectl -n risingwave-poc logs pod/risingwave-hook-create-databases-8xvj4
Password for user root: 
psal: error: connection to server at "risingwave.risingwave-poc.svc"(172.20.23.179), port 4567 failed: ERROR:PasswordError: Invalid password
```

A probable cause could be reinstalling the chart without purging the data. Please refer to the [Uninstallation](#uninstallation) section 
to fully uninstall the release before retrying.

### 2. Got `Error: template: risingwave/templates/meta-sts.yaml:179:74: executing “risingwave/templates/meta-sts.yaml” at <.Subcharts.minio>: nil pointer evaluating interface {}.minio`, what should I do?

The helm chart uses [an undocumented feature](https://github.com/helm/helm/pull/9957) of helm. 
If you encountered the error above, please update the helm to 3.7+ and try again. 

## License

Apache License 2.0. See [LICENSE](LICENSE) for more details.
