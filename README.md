<p align="center">
  <picture>
    <source srcset="https://raw.githubusercontent.com/risingwavelabs/risingwave/main/.github/RisingWave-logo-dark.svg" width="500px" media="(prefers-color-scheme: dark)">
    <img src="https://raw.githubusercontent.com/risingwavelabs/risingwave/main/.github/RisingWave-logo-light.svg" width="500px">
  </picture>
</p>


Helm Charts for RisingWave
---

[![Test Charts](https://github.com/risingwavelabs/helm-charts/actions/workflows/test.yml/badge.svg)](https://github.com/risingwavelabs/helm-charts/actions/workflows/test.yml)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Slack](https://badgen.net/badge/Slack/Join%20RisingWave/0abd59?icon=slack)](https://risingwave.com/slack)
[![X](https://img.shields.io/twitter/follow/risingwavelabs)](https://twitter.com/risingwavelabs)

## Charts

- [risingwave](charts/risingwave/README.md) - Helm chart for deploying
  a [RisingWave Cluster](https://github.com/risingwavelabs/risingwave)
- [risingwave-operator](jcharts/risingwave-operator/README.md) - Helm chart for deploying
  a [RisingWave Operator](https://github.com/risingwavelabs/risingwave-operator)

## Prerequisites

- Kubernetes cluster (version >= 1.24)
- [Helm](https://helm.sh/docs/intro/install/) (version >= 3.10)

## Installation

### Add Helm Repository

Add the Helm Repository

 ```shell
 helm repo add risingwavelabs https://risingwavelabs.github.io/helm-charts/ --force-update
 ```

Update the local Helm chart repository cache

 ```shell
 helm repo update
 ```

### Install RisingWave

> [!NOTE]
>
> The following command installs a standalone RisingWave with local persistency. It will create a PersistentVolumeClaim
> with StatefulSet and the data will be persisted in the provisioned PersistentVolume. Therefore, it requires the
> Kubernetes cluster to
> allow [dynamic volume provisioning](https://kubernetes.io/docs/concepts/storage/dynamic-provisioning/).
> Please download and revise the values file if it doesn't suit you well.

```shell
helm install risingwave risingwavelabs/risingwave \
  -f https://raw.githubusercontent.com/risingwavelabs/helm-charts/main/examples/dev/dev.values.yaml \
  # --set wait=true         # Uncomment to wait before RisingWave's ready
```

> [!TIP]
>
> The following command will help create a RisingWave similar to above except **without persistency guarantee**. If
> the [dynamic volume provisioning](https://kubernetes.io/docs/concepts/storage/dynamic-provisioning/) isn't setup in
> your Kubernetes cluster, you could take a quick try with RisingWave with this.
> 
> ```shell
> helm install risingwave risingwavelabs/risingwave \
>   --set metaStore.sqlite.enabled=true \
>   --set stateStore.localFs.enabled=true \
>   --set standalone.enabled=true \
>   # --set wait=true         # Uncomment to wait before RisingWave's ready 
> ```

### Install RisingWave Operator

Prerequisites:

- [Install cert-manager](https://cert-manager.io/docs/installation/helm/)

> [!NOTE]
>
> CustomResourceDefinitions are included in the RisingWave Operator Helm chart and will be installed by default.

Create a dedicated namespace for RisingWave Operator.

```shell
kubectl create namespace risingwave-operator-system
```

Install the RisingWave Operator Helm chart.

```shell
helm install risingwave-operator risingwavelabs/risingwave-operator \
  --namespace risingwave-operator-system --create-namespace
```

## Documentation

- [RisingWave Documentation](https://docs.risingwave.com/)
- [RisingWave Operator Documentation](https://github.com/risingwavelabs/risingwave-operator/blob/main/README.md)
- [Helm Charts Documentation](docs/README.md)

## Contributing

Contributions are welcome! Please see our [Contributing Guide](CONTRIBUTING.md) for more information.

## License

This project is licensed under the [Apache 2.0 License](LICENSE).
