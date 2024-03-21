Frequently Asked Questions
---

## Helm Chart for RisingWave

### What to do when `helm install` fail?

First of all, please make sure the Helm version is larger than 3.7. It is because the chart
leverages [an undocumented feature](https://github.com/helm/helm/pull/9957) of helm. Upgrade the helm and try again.

If the problem is solved, please open a new [issue](https://github.com/risingwavelabs/helm-charts/issues/new/choose) and
provide detailed information about the problem, including steps to reproduce, expected behavior, and any relevant logs
or error messages.

### Why did the hooks failed?

Sometimes, after several rounds of re-installation, you might find the hook for creating database or setting the
username/password failed. For example, when you inspect the logs of the hook, you may find the following ones:

```plain
kubectl -n risingwave-poc logs pod/risingwave-hook-create-databases-8xvj4
Password for user root: 
psal: error: connection to server at "risingwave.risingwave-poc.svc"(172.20.23.179), port 4567 failed: ERROR:PasswordError: Invalid password
```

This is probably caused by re-installation on dirty meta store and state store backends. Please make sure you have
cleaned them properly and then retry.

### How to restart the RisingWave?

> [!WARNING]
>
> Restart a RisingWave without persistent stores will cause data loss and DOS.
> The best way to recover in this case is to rebuild everything.

If the meta store and state store backends that RisingWave is using are all persistent (remote backend or local
persistent), simply delete the RisingWave pods and let them restart to get a full restart of the cluster. Note
that `SQLite` meta store and `Local File System` are not persistent unless the data paths are in a persistent volume.
Please refer to [the installation guide](CONFIGURATION.md) for more details.
