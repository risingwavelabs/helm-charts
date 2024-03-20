![RisingWave](https://raw.githubusercontent.com/risingwavelabs/risingwave/main/.github/RisingWave-logo-light.svg)

Helm Charts for RisingWave
---

[![Test Charts](https://github.com/risingwavelabs/helm-charts/actions/workflows/test.yml/badge.svg)](https://github.com/risingwavelabs/helm-charts/actions/workflows/test.yml)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Slack](https://badgen.net/badge/Slack/Join%20RisingWave/0abd59?icon=slack)](https://risingwave.com/slack)
[![X](https://img.shields.io/twitter/follow/risingwavelabs)](https://twitter.com/risingwavelabs)

## Charts

- [risingwave](charts/risingwave/README.md) - Helm chart for deploying a RisingWave Cluster
- [risingwave-operator](charts/risingwave-operator/README.md) - Helm chart for deploying the RisingWave Operator

## Prerequisites

- Kubernetes cluster (version >= 1.24)
- [Helm](https://helm.sh/docs/intro/install/) (version >= 3.7.0)

## Installation

### Add Helm Repository

1. Add the Helm Repository

    ```shell
    helm repo add risingwavelabs https://risingwavelabs.github.io/helm-charts/ --force-update
    ```

2. Update the local Helm chart repository cache

    ```shell
    helm repo update
    ```

### Install RisingWave

>[!NOTE]
> 
> The following command installs a standalone RisingWave with local persistency. It will create a PersistentVolumeClaim 
> with StatefulSet and the data will be persisted in the provisioned PersistentVolume. Therefore, it requires the 
> Kubernetes cluster to allow dynamic provisioning of PVs. Please download the revise the values file if it doesn't suit
> you well.

```shell
helm install risingwave risingwavelabs/risingwave \
  # --set wait=true       # Uncomment to wait before RisingWave's ready
  -f https://raw.githubusercontent.com/risingwavelabs/helm-charts/main/examples/dev/dev.values.yaml
```

### Install RisingWave Operator

Prerequisites:
- [Install cert-manager](https://cert-manager.io/docs/installation/helm/)

1. Create a dedicated namespace for RisingWave Operator.

   ```shell
   kubectl create namespace risingwave-operator-system
   ```
   
2. Install the RisingWave Operator Helm Chart.

   ```shell
   helm install risingwave-operator risingwavelabs/risingwave-operator \
     --namespace risingwave-operator-system --create-namespace
   ```

## Documentation

- [RisingWave Documentation](https://github.com/risingwavelabs/risingwave)
- [RisingWave Operator Documentation](https://github.com/risingwavelabs/risingwave-operator)
- [Helm Charts Documentation](docs/README.md)

## Contributing

Contributions are welcome! Please see our Contributing Guide for more information.

## License

This project is licensed under the [Apache 2.0 License]((LICENSE).