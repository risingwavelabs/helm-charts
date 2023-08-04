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
{{ printf "%s-etcd" (include "risingwave.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create the name of the S3 credentials Secret to use
*/}}
{{- define "risingwave.s3CredentialsSecretName" -}}
{{ printf "%s-s3" (include "risingwave.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create the name of the MinIO credentials Secret to use
*/}}
{{- define "risingwave.minioCredentialsSecretName" -}}
{{ printf "%s-minio" (include "risingwave.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create the name of the GCS credentials Secret to use
*/}}
{{- define "risingwave.gcsCredentialsSecretName" -}}
{{ printf "%s-gcs" (include "risingwave.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create the name of the OSS credentials Secret to use
*/}}
{{- define "risingwave.ossCredentialsSecretName" -}}
{{ printf "%s-oss" (include "risingwave.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create the name of the AzureBlob credentials Secret to use
*/}}
{{- define "risingwave.azblobCredentialsSecretName" -}}
{{ printf "%s-azblob" (include "risingwave.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "risingwave.credentialsSecretRequired" -}}
{{- if and .Values.stateStore.s3.enabled (empty .Values.stateStore.s3.authentication.useServiceAccount) }}
true
{{- else if and (not .Values.tags.minio) .Values.stateStore.minio.enabled }}
true
{{- else if and .Values.stateStore.oss.enabled (empty .Values.stateStore.oss.authentication.useServiceAccount) }}
true
{{- else if and .Values.stateStore.gcs.enabled (empty .Values.stateStore.gcs.authentication.useServiceAccount) }}
true
{{- else if and .Values.stateStore.azblob.enabled (empty .Values.stateStore.azblob.authentication.useServiceAccount) }}
true
{{- else }}
false
{{- end }}
{{- end }}

{{/*
Create the name of credential Secret to use
*/}}
{{- define "risingwave.credentialsSecretName" -}}
{{- if .Values.stateStore.s3.enabled }}
{{- include "risingwave.s3CredentialsSecretName" . }}
{{- else if and (not .Values.tags.minio) .Values.stateStore.minio.enabled }}
{{- include "risingwave.minioCredentialsSecretName" .}}
{{- else if .Values.stateStore.oss.enabled }}
{{- include "risingwave.ossCredentialsSecretName" . }}
{{- else if .Values.stateStore.azblob.enabled }}
{{- include "risingwave.azblobCredentialsSecretName" . }}
{{- else if .Values.stateStore.gcs.enabled }}
{{- include "risingwave.gcsCredentialsSecretName" . }}
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
{{- else }}
{{- print "" }}
{{- end }}
{{- end }}

{{/*
Create the hummock data directory.
*/}}
{{- define "risingwave.stateStoreDataDirectory" -}}
{{- default .Values.stateStore.dataDirectory "hummock" }}
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
{{ printf "%s-configuration" (include "risingwave.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create the name of the meta Service and StatefulSet to use
*/}}
{{- define "risingwave.metaComponentName" -}}
{{ printf "%s-meta" (include "risingwave.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "risingwave.metaHeadlessServiceName" -}}
{{ printf "%s-meta-headless" (include "risingwave.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create the name of the frontend Service and Deployment to use
*/}}
{{- define "risingwave.frontendComponentName" -}}
{{ printf "%s-frontend" (include "risingwave.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create the name of the compute Service and StatefulSet to use
*/}}
{{- define "risingwave.computeComponentName" -}}
{{ printf "%s-compute" (include "risingwave.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "risingwave.computeHeadlessServiceName" -}}
{{ printf "%s-compute-headless" (include "risingwave.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create the name of the compactor Service and Deployment to use
*/}}
{{- define "risingwave.compactorComponentName" -}}
{{ printf "%s-compactor" (include "risingwave.fullname" .) | trunc 63 | trimSuffix "-" }}
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
