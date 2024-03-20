1. **Create a Namespace for RisingWave** It's recommended to create a dedicated namespace for RisingWave resources.

   ```shell
   kubectl create namespace risingwave
   ```

2. **Configure the RisingWave** Create a `values.yaml` file configure the RisingWave according to your requirements. Example:

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