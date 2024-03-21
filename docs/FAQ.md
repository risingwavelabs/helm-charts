Frequently Asked Questions
---

## 1. Hook for creating databases failed.

Example:

```plain
kubectl -n risingwave-poc logs pod/risingwave-hook-create-databases-8xvj4
Password for user root: 
psal: error: connection to server at "risingwave.risingwave-poc.svc"(172.20.23.179), port 4567 failed: ERROR:PasswordError: Invalid password
```

A probable cause could be reinstalling the chart without purging the data. Please refer to the [Uninstallation](#uninstallation) section
to fully uninstall the release before retrying.

## 2. Got `Error: template: risingwave/templates/meta-sts.yaml:179:74: executing “risingwave/templates/meta-sts.yaml” at <.Subcharts.minio>: nil pointer evaluating interface {}.minio`, what should I do?

The helm chart uses [an undocumented feature](https://github.com/helm/helm/pull/9957) of helm.
If you encountered the error above, please update the helm to 3.7+ and try again.
Refer to [this stackoverflow question](https://stackoverflow.com/questions/47791971/how-can-you-call-a-helm-helper-template-from-a-subchart-with-the-correct-conte) for the reason.  
