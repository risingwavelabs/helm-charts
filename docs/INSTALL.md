Installation Guide
---

## Installing RisingWave

1. **Create a Namespace for RisingWave** It's recommended to create a dedicated namespace for RisingWave resources.

   ```shell
   kubectl create namespace risingwave
   ```

2. **Configure the RisingWave** Create a `values.yaml` file configure the RisingWave according to your requirements.
   Example:

    ```yaml
    # Configure meta store.
    metaStore:
      sqlite:
        enabled: true
    
    # Configure state store.
    stateStore:
      localFs:
        enabled: true
   
    # Enable standalone mode.
    standalone:
      enabled: true
    ```

   For more details in configurations, please refer to the [configuration guide](CONFIGURATION.md).

3. **Install the RisingWave Helm Chart** Install the RisingWave using the provided configuration.

   ```shell
   helm install \
     risingwave risingwavelabs/risingwave \
     --namespace risingwave \
     --create-namespace \
     # --set wait=true \                   # Uncomment to wait before RisingWave's ready                             
     -f values.yaml
   ```

4. **Verify the Installation** After the installation is complete, you can verify the RisingWave cluster resources:

   ```shell
   kubectl get all -n risingwave
   ```

   You should see the RisingWave pods, services, and other resources in the output.

## Uninstalling RisingWave

1. **Uninstall the RisingWave Helm Chart Release** Uninstall the RisingWave release with Helm.

   ```shell
   # The first `risingwave` is the namespace, and the second is the release name. The command template looks like
   #   helm uninstall --namespace <namespace> <release-name>
   helm uninstall --namespace risingwave risingwave
   ```

2. **Remove all PersistentVolumeClaims (optional)** Remove the PVCs to remove the bindings between pods and PVs. This
   will reclaim the PVs if the reclaim policy is `Delete`. Do this when you would like to do a clean re-installation, or
   omit the step if you would like to keep the data.

   ```shell
   # The first `risingwave` is the namespace, and the second is the release name. The command template looks like
   #   kubectl --namespace <namespace> delete pvc -l app.kubernetes.io/instance=<release-name>
   kubectl --namespace risingwave delete pvc -l app.kubernetes.io/instance=risingwave
   ```

3. **Delete the Namespace (optional)** Delete the namespace to release all resources.

   ```shell
   # `risingwave` is the namespace. The command template looks like
   #   kubectl delete namespace <namespace>
   kubectl delete namespace risingwave
   ```

## Installing RisingWave Operator

Prerequisites:

- [Install cert-manager](https://cert-manager.io/docs/installation/helm/). The RisingWave Operator installation relies
  on cert-manager to issue certificates for admission webhooks.

>[!CAUTION]
>
> Note that RisingWave Operator is a cluster level installation. The behaviour is undefined when there are more than one
> operator installed in the same Kubernetes cluster.

1. **Create a Namespace for RisingWave Operator** It is recommended to install the RisingWave Operator in a separate
   namespace, e.g., `risingwave-operator-system`.

   ```shell
   kubectl create namespace risingwave-operator-system
   ```

2. **Install the RisingWave Operator Helm Chart** Install the RisingWave Operator with default configuration.

   ```shell
   helm install risingwave-operator risingwavelabs/risingwave-operator \
     --namespace risingwave-operator-system --create-namespace
   ```

   The default values should already be good enough in most cases. However, customization is possible by providing a
   configuration. Please refer to the [configuration guide](CONFIGURATION.md) for more details.

3. **Verify the Installation** After the installation is complete, you can verify the RisingWave Operator resources:

   ```shell
   kubectl -n risingwave-operator get all
   ```

   You should see the RisingWave Operator pod, service, and other resources in the output.

4. **Create a RisingWave resource** Follow
   the [operator's guides](https://github.com/risingwavelabs/risingwave-operator/blob/main/README.md) to create a
   RisingWave resource.

## Uninstalling RisingWave Operator

>[!WARNING]
>
> Note that all RisingWave resources as well as the running RisingWave pods will be removed automatically when
deleting the RisingWave CRDs.

1. **Uninstall the Helm Release** Uninstall the Risingwave Operator release with Helm.

   ```shell
   # The command template looks like
   #   helm --namespace <namespace> uninstall <release-name>
   helm --namespace risingwave-operator-system uninstall risingwave-operator  
   ```

2. **Uninstall the RisingWave CRDs** Delete the RisingWave CRDs because helm won't uninstall them by design.

   ```shell
   kubectl delete crd risingwavescaleviews.risingwave.risingwavelabs.com
   kubectl delete crd risingwaves.risingwave.risingwavelabs.com
   ```

3. **Delete the Namespace** Delete the namespace to release all resources.

   ```shell
   kubectl delete namespace risingwave-operator-system
   ```

Once the steps are completed, RisingWave Operator will be fully removed from your Kubernetes cluster.