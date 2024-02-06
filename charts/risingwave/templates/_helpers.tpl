{{/*
Copyright RisingWave Labs
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Expand the name of the chart.
*/}}
{{- define "risingwave.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "risingwave.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "risingwave.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "risingwave.selectorLabels" -}}
app.kubernetes.io/name: {{ include "risingwave.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "risingwave.labels" -}}
helm.sh/chart: {{ include "risingwave.chart" . }}
{{ include "risingwave.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Values.commonLabels }}
{{ toYaml .Values.commonLabels }}
{{- end }}
{{- end }}

{{/*
Common annotations
*/}}
{{- define "risingwave.annotations" -}}
{{- if .Values.commonAnnotations }}
{{ toYaml .Values.commonAnnotations }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "risingwave.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "risingwave.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the etcd credentials Secret to use
*/}}
{{- define "risingwave.etcdCredentialsSecretName" -}}
{{- printf "%s-etcd" (include "risingwave.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create the name of the S3 credentials Secret to use
*/}}
{{- define "risingwave.s3CredentialsSecretName" -}}
{{- if .Values.stateStore.s3.authentication.existingSecretName }}
{{- .Values.stateStore.s3.authentication.existingSecretName }}
{{- else }}
{{- printf "%s-s3" (include "risingwave.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Create the name of the MinIO credentials Secret to use
*/}}
{{- define "risingwave.minioCredentialsSecretName" -}}
{{- if .Values.stateStore.minio.authentication.existingSecretName }}
{{- .Values.stateStore.minio.authentication.existingSecretName }}
{{- else }}
{{- printf "%s-minio" (include "risingwave.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Create the name of the GCS credentials Secret to use
*/}}
{{- define "risingwave.gcsCredentialsSecretName" -}}
{{- if .Values.stateStore.gcs.authentication.existingSecretName }}
{{- .Values.stateStore.gcs.authentication.existingSecretName }}
{{- else }}
{{- printf "%s-gcs" (include "risingwave.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Create the name of the OSS credentials Secret to use
*/}}
{{- define "risingwave.ossCredentialsSecretName" -}}
{{- if .Values.stateStore.oss.authentication.existingSecretName }}
{{- .Values.stateStore.oss.authentication.existingSecretName }}
{{- else }}
{{- printf "%s-oss" (include "risingwave.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Create the name of the Huawei Cloud OBS credentials Secret to use
*/}}
{{- define "risingwave.obsCredentialsSecretName" -}}
{{- if .Values.stateStore.obs.authentication.existingSecretName }}
{{- .Values.stateStore.obs.authentication.existingSecretName }}
{{- else }}
{{- printf "%s-obs" (include "risingwave.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Create the name of the AzureBlob credentials Secret to use
*/}}
{{- define "risingwave.azblobCredentialsSecretName" -}}
{{- if .Values.stateStore.azblob.authentication.existingSecretName }}
{{- .Values.stateStore.azblob.authentication.existingSecretName }}
{{- else }}
{{- printf "%s-azblob" (include "risingwave.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Create the name of credential Secret to use. Return empty string if the Secret isn't created.
*/}}
{{- define "risingwave.credentialsSecretName" -}}
{{- if and .Values.stateStore.s3.enabled (not .Values.stateStore.s3.authentication.useServiceAccount)  }}
{{- include "risingwave.s3CredentialsSecretName" . }}
{{- else if and (not .Values.tags.minio) .Values.stateStore.minio.enabled }}
{{- include "risingwave.minioCredentialsSecretName" .}}
{{- else if and .Values.stateStore.oss.enabled (not .Values.stateStore.oss.authentication.useServiceAccount) }}
{{- include "risingwave.ossCredentialsSecretName" . }}
{{- else if and .Values.stateStore.azblob.enabled (not .Values.stateStore.azblob.authentication.useServiceAccount) }}
{{- include "risingwave.azblobCredentialsSecretName" . }}
{{- else if and .Values.stateStore.gcs.enabled (not .Values.stateStore.gcs.authentication.useServiceAccount) }}
{{- include "risingwave.gcsCredentialsSecretName" . }}
{{- else if and .Values.stateStore.obs.enabled (not .Values.stateStore.obs.authentication.useServiceAccount)}}
{{- include "risingwave.obsCredentialsSecretName" . }}
{{- else }}
{{- print "" }}
{{- end }}
{{- end }}

{{/*
Create the hummock connection string to use.
*/}}
{{- define "risingwave.hummockConnectionString" -}}
{{- if .Values.stateStore.s3.enabled }}
{{- printf "hummock+s3://%s" .Values.stateStore.s3.bucket }}
{{- else if .Values.stateStore.minio.enabled }}

{{- if .Values.tags.minio }}
{{- $minioEndpoint := (printf "%s:%d" (include "common.names.fullname" .Subcharts.minio) (.Values.minio.service.ports.api | int)) }}
{{- $minioBucket := (splitList "," .Values.minio.defaultBuckets | first )}}
{{- printf "hummock+minio://$(MINIO_USERNAME):$(MINIO_PASSWORD)@%s/%s" $minioEndpoint $minioBucket }}
{{- else }}
{{- printf "hummock+minio://$(MINIO_USERNAME):$(MINIO_PASSWORD)@%s/%s" .Values.stateStore.minio.endpoint .Values.stateStore.minio.bucket }}
{{- end }}

{{- else if .Values.stateStore.oss.enabled }}
{{- printf "hummock+oss://%s" .Values.stateStore.oss.bucket }}
{{- else if .Values.stateStore.azblob.enabled }}
{{- printf "hummock+azblob://%s@%s" .Values.stateStore.azblob.container .Values.stateStore.azblob.root }}
{{- else if .Values.stateStore.gcs.enabled }}
{{- printf "hummock+gcs://%s@%s" .Values.stateStore.gcs.bucket .Values.stateStore.gcs.root }}
{{- else if .Values.stateStore.hdfs.enabled }}
{{- printf "hummock+hdfs://%s@%s" .Values.stateStore.hdfs.nameNode  .Values.stateStore.hdfs.root }}
{{- else if .Values.stateStore.obs.enabled }}
{{- printf "hummock+obs://%s" .Values.stateStore.obs.bucket }}
{{- else }}
{{- print "" }}
{{- end }}
{{- end }}

{{/*
Create the hummock data directory.
*/}}
{{- define "risingwave.stateStoreDataDirectory" -}}
{{- default "hummock" .Values.stateStore.dataDirectory }}
{{- end }}

{{/*
Create the etcd endpoints
*/}}
{{- define "risingwave.metaStoreEtcdEndpoints" -}}
{{- if .Values.tags.etcd }}
{{- printf "%s.%s.svc:%d" (include "common.names.fullname" .Subcharts.etcd) .Release.Namespace (.Values.etcd.service.ports.client | int) }}
{{- else }}
{{- join "," .Values.metaStore.etcd.endpoints }}
{{- end }}
{{- end }}

{{- define "risingwave.metaStoreAuthRequired" -}}
{{- if .Values.tags.etcd }}
{{- and (not .Values.etcd.auth.rbac.allowNoneAuthentication) .Values.etcd.auth.rbac.create }}
{{- else }}
{{- .Values.metaStore.etcd.authentication.enabled }}
{{- end }}
{{- end }}

{{/*
Create the name of the AzureBlob credentials Secret to use
*/}}
{{- define "risingwave.configurationConfigMapName" -}}
{{- printf "%s-configuration" (include "risingwave.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create the name of the meta Service and StatefulSet to use
*/}}
{{- define "risingwave.metaComponentName" -}}
{{- printf "%s-meta" (include "risingwave.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "risingwave.metaHeadlessServiceName" -}}
{{- printf "%s-meta-headless" (include "risingwave.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create the name of the frontend Service and Deployment to use
*/}}
{{- define "risingwave.frontendComponentName" -}}
{{- printf "%s-frontend" (include "risingwave.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create the name of the compute Service and StatefulSet to use
*/}}
{{- define "risingwave.computeComponentName" -}}
{{- if .Values.compactMode.enabled }}
{{- printf "%s-frontend-compute" (include "risingwave.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-compute" (include "risingwave.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{- define "risingwave.computeHeadlessServiceName" -}}
{{- if .Values.compactMode.enabled }}
{{- printf "%s-frontend-compute-headless" (include "risingwave.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-compute-headless" (include "risingwave.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Create the name of the compactor Service and Deployment to use
*/}}
{{- define "risingwave.compactorComponentName" -}}
{{- printf "%s-compactor" (include "risingwave.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create the image name to use.
*/}}
{{- define "risingwave.image" -}}
{{- $registryName := .Values.image.registry -}}
{{- $repositoryName := .Values.image.repository -}}
{{- $separator := ":" -}}
{{- $termination := .Values.image.tag | toString -}}
{{- if .Values.image.digest }}
    {{- $separator = "@" -}}
    {{- $termination = .Values.image.digest | toString -}}
{{- end -}}
{{- if $registryName }}
    {{- printf "%s/%s%s%s" $registryName $repositoryName $separator $termination -}}
{{- else -}}
    {{- printf "%s%s%s"  $repositoryName $separator $termination -}}
{{- end -}}
{{- end }}

{{/*
Create the OSS endpoint to use.
*/}}
{{- define "risingwave.oss.endpoint" }}
{{- if .Values.stateStore.oss.useInternalEndpoint }}
{{- printf "https://oss-$(OSS_REGION)-internal.aliyuncs.com" }}
{{- else }}
{{- printf "https://oss-$(OSS_REGION).aliyuncs.com" }}
{{- end }}
{{- end }}

{{/*
Create the OBS endpoint to use.
*/}}
{{- define "risingwave.obs.endpoint" }}
{{- printf "https://obs.$(OBS_REGION).myhuaweicloud.com" }}
{{- end }}