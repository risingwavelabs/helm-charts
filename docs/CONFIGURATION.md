Configuration Guide
---

## Prerequisites

> [!TIP]
>
> Recommend reading the following materials before proceeding to at least understand how value files in Helm chart and
> installation work.
>
> - https://helm.sh/docs/chart_template_guide/values_files/
> - https://helm.sh/docs/helm/helm_install/

1. Basic understanding of Kubernetes and Helm

## How to Learn Available Value Options

> [!NOTE]
>
> Helm repository must be added before showing values.

For RisingWave chart,

```shell
helm show values risingwavelabs/risingwave
```

For RisingWave Operator chart,

```shell
helm show values risingwavelabs/risingwave-operator
```

## Configuration for RisingWave

### Examples in Facets

We have provided [a bunch of example values](/examples) in several perspectives. Check them to get started quickly!

### Distributed Mode v.s. Standalone Mode

RisingWave is a distributed system
by [design](https://github.com/risingwavelabs/risingwave/blob/main/docs/architecture-design.md). It is consisted of four
main components:

- Meta, the central metadata service
- Frontend, the SQL parsing and processing service
- Compute, the stream processing and query processing service
- Compactor, the storage compaction service

In order to better utilize resources and support an easier deployment, RisingWave also supports a standalone mode that
combines all the four components in one process. Helm chart for RisingWave supports it natively.

By default, helm chart for RisingWave installs a distributed mode RisingWave. However, if one favors standalone mode for
development/test, the following can help turn it on:

```yaml
standalone:
  enabled: true
```

For the two modes, the recommending resources are:

- Standalone mode, >= 2c8Gi
- Distributed mode,
    - Meta, >= 1c2Gi
    - Frontend, >= 1c2Gi
    - Compute, >= 4c16Gi
    - Compactor, >= 2c4g

### Customize Pods of Different Components

Most of the pod related values are under these sections:

| Section            | Component  | Description                                    |
|:-------------------|:-----------|:-----------------------------------------------|
| standalone         | Standalone | Customizing the StatefulSet for standalone pod |
| metaComponent      | Meta       | Customizing the StatefulSet for meta pods      | 
| computeComponent   | Compute    | Customizing the StatefulSet for compute pods   | 
| frontendComponent  | Frontend   | Customizing the Deployment for frontend pods   | 
| compactorComponent | Compactor  | Customizing the Deployment for compactor pods  |

Almost all possible fields on the raw workloads are exposed.

### Customize Meta Store

> [!CAUTION]
>
> Data in meta store must be persistent. Otherwise, the RisingWave will be broken on a restart. For example, it could
> refuse to start when there's a mismatch between meta store and state store.

> [!WARNING]
>
> Meta store backend is supposed to changeless in almost all cases. Please don't change it while upgrading!

Customize the `metaStore` section to configure the meta store backends. Currently, the following backends are supported:

| Name       | Section              | Location |
|:-----------|:---------------------|:---------|
| etcd       | metaStore.etcd       | remote   |
| SQLite     | metaStore.sqlite     | local    |
| PostgreSQL | metaStore.postgresql | remote   |
| MySQL      | metaStore.mysql      | remote   |

In the backends, `SQLite` is the only one that stores

### Customize State Store

> [!CAUTION]
>
> Data in state store must be persistent. Otherwise, the RisingWave will be broken on a restart. For example, it could
> refuse to start when there's a mismatch between meta store and state store.

> [!WARNING]
>
> State store backend is supposed to changeless in almost all cases. Please don't change it while upgrading!

Customize the `stateStore` section to configure the state store backends. Currently, the following backends are
supported:

| Name                       | Section            | Location |
|:---------------------------|:-------------------|:---------|
| AWS S3 (+compatible)       | stateStore.s3      | remote   |
| Google Cloud Storage (GCS) | stateStore.gcs     | remote   |
| Aliyun OSS                 | stateStore.oss     | remote   |
| Huawei Cloud OBS           | stateStore.obs     | remote   |
| HDFS                       | stateStore.hdfs    | remote   |
| MinIO                      | stateStore.minio   | remote   |
| Local File System          | stateStore.localFs | local    |

For the details of a backend, please check the values of the corresponding section.

### Bundled etcd/MinIO as Stores

Helm chart for RisingWave also provides an option to deploy the etcd and MinIO along with the RisingWave to provide meta
and state store backends. It is useful to try out the helm chart quickly. The feature is achieved with `bitnami/etcd`
and `bitnami/minio` sub-charts. If you are interested in these charts, please refer
to [bitnami/charts](https://github.com/bitnami) for details.

Set the `tags.bundle` option to `true` to experience the feature.

```shell
helm install -f tags.bundle=true risingwave risingwavelabs/risingwave
```

It's also possible to control the enablement of etcd and MinIO sub-charts separately with `tags.etcd` and `tags.minio`.
But note that `tags.bundle` must be `false` when you want such control.

> [!TIP]
>
> etcd is recommended as the default meta store backend. Simply using the following values to deploy it with RisingWave
> so that you can focus on setting the state store.
> 
> ```yaml
> tags:
>   etcd: true
> ```

### IAM Role for ServiceAccount (EKS) and Others

To authorize access to object storages or blob storages, RisingWave requires a set of credentials. For
example, `AccessKey` and `SecretAccessKey` are supposed to be provided when using AWS S3 as the state store.

However, there are techniques
call [IRSA (IAM Role for ServiceAccount)](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html)
that can help do the authentication automatically, which of course have lots of benefits in terms of security and
auditability.

Take AWS EKS/S3 as an example, the following values will help associate the service account used by RisingWave pods with
an IAM. Therefore, the RisingWave pods are granted with the privileges the IAM has.

```yaml
serviceAccount:
  create: true
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::111122223333:role/my-role

stateStore:
  s3:
    enabled: true
    authentication:
      # Set useServiceAccount to true to allow empty accessKey/secretAccessKey.
      useServiceAccount: true
```

Other cloud vendors provide the similar solutions:

- For Google Cloud GKE, there
  is [workload identity federation](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity)
- For Azure, there
  is [Microsoft Entra Workload ID with AKS](https://learn.microsoft.com/en-us/azure/aks/workload-identity-overview?tabs=dotnet)

The configurations are similar for GCS and Azure Blob. Almost all the state backends except `MinIO`, `Local FS`
and `HDFS` has the option `authentication.useServiceAccount` to allow empty credentials in values.

### Enable Monitoring (PodMonitor)

Prerequisites:

- [prometheus-operator](https://github.com/prometheus-operator/prometheus-operator) is installed, or at least the CRDs
  are installed.

Apply the following values override to enable the metrics collection,

```yaml
monitor:
  podMonitor:
    enabled: true
```

It's also possible to customize the scrape task details, like the scrape interval and timeout. Check
the `monitor.podMonitor` section in the values for details.

## Configuration for RisingWave Operator

### Customize Manager Pod

Customizing the pod by setting the values under `manager` section, for example,

```yaml
manager:
  nodeSelector:
    kubernetes.io/zone: us-east-1

  affinity: { }

  tolerations: [ ]

  resources:
    limits:
      cpu: 1
      memory: 512Mi
```

Most of the pod settings are exposed under this section. Please check the chart values for details.

### Enable kube-rbac-proxy for Metrics

By default, the kube-rbac-proxy isn't enabled. If you would like to enable it to secure the metrics, you could override
the following values.

```yaml
proxy:
  enabled: true
  image: quay.io/brancz/kube-rbac-proxy:v0.14.2
  imagePullPolicy: IfNotPresent
```

It's also possible to customize the image used.

### Enable Monitoring (PodMonitor)

Prerequisites:

- [prometheus-operator](https://github.com/prometheus-operator/prometheus-operator) is installed, or at least the CRDs
  are installed.

Apply the following values override to enable the metrics collection,

```yaml
monitor:
  podMonitor:
    enabled: true
```

It's also possible to customize the scrape task details, like the scrape interval and timeout. Check
the `monitor.podMonitor` section in the chart values for details.