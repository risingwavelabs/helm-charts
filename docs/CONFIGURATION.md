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

### Cluster Mode v.s. Standalone Mode

### Customize Pods of Different Components

### Customize Meta Store

### Customize State Store

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