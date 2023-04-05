---
sidebar_position: 9
---

# Xl-client

If you want to run an instance of XL Release, Remote Runner, or XL Deploy in K8s using the xl-client docker image, follow these steps.

:::important
We need to volume mount the kube config file in order to access cluster in the docker container.

**Note:**
* Default kube config path /opt/xebialabs/.kube/config in the docker container.
:::

##  Install xl-release in the k8s cluster.

* You can run the official xl-client docker images from XebiaLabs using the `docker run` command as follows: 
```shell
   docker run -it
   --name xlclient
   -v ~/.kube/config:/opt/xebialabs/.kube/config
   -e KUBECONFIG=/opt/xebialabs/.kube/config
   -v /home/ishwarya/Downloads/config:/opt/xebialabs/xl-client/config
   xebialabsunsupported/xl-client:23.1.0-329.113 kube install

```

* In our example, we are mounting config from local volumes, for reading the xl-release.lic file from file Path.


* This will start the xl-client in docker. We can use the kube command to install/clean the xl-release from the k8s cluster.

* You can stream the logs from the container using `docker logs -f <container id>`.

### 1. Installing xl-release using xl-client kube install
```shell
[ishwarya@worker01 xl-docker-images]* S-90011 $ docker run -it -v ~/.kube/config:/opt/xebialabs/.kube/config -e KUBECONFIG=/opt/xebialabs/.kube/config --name xlclient  -v /home/ishwarya/Downloads/config:/opt/xebialabs/xl-client/config xebialabsunsupported/xl-client:23.1.0-329.113 kube install
[INFO  tini (1)] Spawned child process '/opt/xebialabs/xl-client/xl' with pid '7'
? Following kubectl context will be used during execution: `default/api-apollo-operator-raqx-p1-openshiftapps-com:6443/cluster-admin`? Yes
? Select the Kubernetes setup where the Digital.ai Devops Platform will be installed, updated or cleaned: Openshift [Openshift]
? Do you want to use an custom Kubernetes namespace (current default is 'digitalai'): Yes
? Enter the name of the Kubernetes namespace where the Digital.ai DevOps Platform will be installed, updated or cleaned: digitalai
? Product server you want to perform install for: dai-release [Digital.ai Release]
? Select type of image registry: default
? Enter the repository name (eg: <repositoryName> from <repositoryName>/<imageName>:<tagName>): xebialabsunsupported
? Enter the image name (eg: <imageName> from <repositoryName>/<imageName>:<tagName>): xl-release
? Enter the image tag (eg: <tagName> from <repositoryName>/<imageName>:<tagName>): 23.1.0-328.113
? Enter the release server replica count: 1
? Enter PVC size for Release (Gi): 1
? Select between supported Access Modes: ReadWriteMany
? Provide DNS name for accessing UI of the server: router-default.apps.apollo-operator.raqx.p1.openshiftapps.com
? Provide administrator password: admin
? Type of the OIDC configuration: no-oidc [No OIDC Configuration]
? Enter the operator image to use (eg: <repositoryName>/<imageName>:<tagName>): xebialabsunsupported/release-operator:23.1.0-328.113-openshift
? Select source of the license: file [Path to the license file (the file can be in clean text or base64 encoded)]
? Provide license file for the server: /opt/xebialabs/xl-client/config/xl-release.lic
? Select source of the repository keystore: generate
? Provide keystore passphrase: A4IQWnmhllmFrRfP
? Provide storage class for the server: aws-efs
? Do you want to install a new PostgreSQL on the cluster: Yes
? Provide Storage Class to be defined for PostgreSQL: aws-efs
? Provide PVC size for PostgreSQL (Gi): 1
? Do you want to install a new RabbitMQ on the cluster: Yes
? Replica count to be defined for RabbitMQ: 1
? Storage Class to be defined for RabbitMQ: aws-efs
? Provide PVC size for RabbitMQ (Gi): 1
         -------------------------------- ----------------------------------------------------
        | LABEL                          | VALUE                                              |
         -------------------------------- ----------------------------------------------------
        | AccessModeRelease              | ReadWriteMany                                      |
	| AdminPassword                  | admin                                              |
	| CleanBefore                    | false                                              |
	| CreateNamespace                | true                                               |
	| EnablePostgresql               | true                                               |
	| EnableRabbitmq                 | true                                               |
	| ExternalOidcConf               | external: false                                    |
	| GenerationDateTime             | 20230405-032401                                    |
	| ImageNameRelease               | xl-release                                         |
	| ImageRegistryType              | default                                            |
	| ImageTag                       | 23.1.0-328.113                                     |
	| IngressHost                    | router-default.apps.apollo-operator.raqx.p1.open.. |
	| IngressType                    | nginx                                              |
	| IsCustomImageRegistry          | false                                              |
	| K8sSetup                       | Openshift                                          |
	| KeystorePassphrase             | A4IQWnmhllmFrRfP                                   |
	| License                        | LS0tIExpY2Vuc2UgLS0tCkxpY2Vuc2UgdmVyc2lvbjogNApQ.. |
	| LicenseFile                    | /opt/xebialabs/xl-client/config/xl-release.lic     |
	| LicenseSource                  | file                                               |
	| Namespace                      | digitalai                                          |
	| OidcConfigType                 | no-oidc                                            |
	| OidcConfigTypeInstall          | no-oidc                                            |
	| OperatorImageReleaseOpenshift  | xebialabsunsupported/release-operator:23.1.0-328.. |
	| OsType                         | linux                                              |
	| PostgresqlPvcSize              | 1                                                  |
	| PostgresqlStorageClass         | aws-efs                                            |
	| ProcessType                    | install                                            |
	| PvcSizeRelease                 | 1                                                  |
	| RabbitmqPvcSize                | 1                                                  |
	| RabbitmqReplicaCount           | 1                                                  |
	| RabbitmqStorageClass           | aws-efs                                            |
	| RepositoryKeystoreSource       | generate                                           |
	| RepositoryName                 | xebialabsunsupported                               |
	| ServerType                     | dai-release                                        |
	| ShortServerName                | xlr                                                |
	| StorageClass                   | aws-efs                                            |
	| UseCustomNamespace             | true                                               |
	| XlrReplicaCount                | 1                                                  |
	 -------------------------------- ----------------------------------------------------
? Do you want to proceed to the deployment with these values? Yes
For current process files will be generated in the: digitalai/dai-release/digitalai/20230405-032401/kubernetes
Generated answers file successfully: digitalai/generated_answers_dai-release_digitalai_install-20230405-032401.yaml 
Starting install processing.
Created keystore digitalai/dai-release/digitalai/20230405-032401/kubernetes/repository-keystore.jceks
Skip creating namespace digitalai, already exists
Update CR with namespace... - Using custom resource name dai-ocp-xlr-digitalai
Generated files successfully for Openshift installation.
Applying resources to the cluster!
? Do you want to replace the resource clusterrole/digitalai-xlr-operator-proxy-role with specification from file
digitalai/dai-release/digitalai/20230405-032401/kubernetes/template/cluster-role-digital-proxy-role.yaml: Yes
Applied resource clusterrole/digitalai-xlr-operator-proxy-role from the file digitalai/dai-release/digitalai/20230405-032401/kubernetes/template/cluster-role-digital-proxy-role.yaml
? Do you want to replace the resource clusterrole/digitalai-xlr-operator-manager-role with specification from file
digitalai/dai-release/digitalai/20230405-032401/kubernetes/template/cluster-role-manager-role.yaml: Yes
Applied resource clusterrole/digitalai-xlr-operator-manager-role from the file digitalai/dai-release/digitalai/20230405-032401/kubernetes/template/cluster-role-manager-role.yaml
? Do you want to replace the resource clusterrole/digitalai-xlr-operator-metrics-reader with specification from file
digitalai/dai-release/digitalai/20230405-032401/kubernetes/template/cluster-role-metrics-reader.yaml: Yes
Applied resource clusterrole/digitalai-xlr-operator-metrics-reader from the file digitalai/dai-release/digitalai/20230405-032401/kubernetes/template/cluster-role-metrics-reader.yaml
Applied resource service/xlr-operator-controller-manager-metrics-service from the file digitalai/dai-release/digitalai/20230405-032401/kubernetes/template/controller-manager-metrics-service.yaml
Applied resource customresourcedefinition/digitalaireleaseocps.xlrocp.digital.ai from the file digitalai/dai-release/digitalai/20230405-032401/kubernetes/template/custom-resource-definition.yaml
Applied resource deployment/xlr-operator-controller-manager from the file digitalai/dai-release/digitalai/20230405-032401/kubernetes/template/deployment.yaml
Applied resource role/xlr-operator-leader-election-role from the file digitalai/dai-release/digitalai/20230405-032401/kubernetes/template/leader-election-role.yaml
Applied resource rolebinding/xlr-operator-leader-election-rolebinding from the file digitalai/dai-release/digitalai/20230405-032401/kubernetes/template/leader-election-rolebinding.yaml
? Do you want to replace the resource clusterrolebinding/digitalai-xlr-operator-manager-rolebinding with specification from file
digitalai/dai-release/digitalai/20230405-032401/kubernetes/template/manager-rolebinding.yaml: Yes
Applied resource clusterrolebinding/digitalai-xlr-operator-manager-rolebinding from the file digitalai/dai-release/digitalai/20230405-032401/kubernetes/template/manager-rolebinding.yaml
? Do you want to replace the resource clusterrolebinding/digitalai-xlr-operator-proxy-rolebinding with specification from file
digitalai/dai-release/digitalai/20230405-032401/kubernetes/template/proxy-rolebinding.yaml: Yes
Applied resource clusterrolebinding/digitalai-xlr-operator-proxy-rolebinding from the file digitalai/dai-release/digitalai/20230405-032401/kubernetes/template/proxy-rolebinding.yaml
Applied resource digitalaireleaseocp/dai-ocp-xlr-digitalai from the file digitalai/dai-release/digitalai/20230405-032401/kubernetes/dai-release_cr.yaml
Install finished successfully!
[INFO  tini (1)] Main child exited normally (with status '0')

```
### 2. Cleaning xl-release using xl-client kube clean
```shell

[ishwarya@worker01 xl-docker-images]* S-90011 $ docker run -it -v ~/.kube/config:/opt/xebialabs/.kube/config -e KUBECONFIG=/opt/xebialabs/.kube/config --name xlclient -v /home/ishwarya/git/deploy/xlr-remote-runner:/opt/xebialabs/remoteRunner -v /home/ishwarya/Downloads/config:/opt/xebialabs/xl-client/config xebialabsunsupported/xl-client:23.1.0-329.113 kube clean
[INFO  tini (1)] Spawned child process '/opt/xebialabs/xl-client/xl' with pid '6'
? Following kubectl context will be used during execution: `default/api-apollo-operator-raqx-p1-openshiftapps-com:6443/cluster-admin`? Yes
? Select the Kubernetes setup where the Digital.ai Devops Platform will be installed, updated or cleaned: Openshift [Openshift]
? Do you want to use an custom Kubernetes namespace (current default is 'digitalai'): Yes
? Enter the name of the Kubernetes namespace where the Digital.ai DevOps Platform will be installed, updated or cleaned: digitalai
? Product server you want to perform clean for: dai-release [Digital.ai Release]
? Enter the name of custom resource definition you want to reuse or replace: digitalaireleaseocps.xlrocp.digital.ai
? Should CRD be reused, if No we will delete the CRD digitalaireleaseocps.xlrocp.digital.ai, and all related CRs will be deleted with it: Yes
? Enter the name of custom resource: dai-ocp-xlr-digitalai
? Should we preserve persisted volume claims? If not all volume data will be lost: No
         -------------------------------- ----------------------------------------------------
        | LABEL                          | VALUE                                              |
         -------------------------------- ----------------------------------------------------
        | CleanBefore                    | false                                              |
        | CrName                         | dai-ocp-xlr-digitalai                              |
        | CrdName                        | digitalaireleaseocps.xlrocp.digital.ai             |
        | CreateNamespace                | true                                               |
        | ExternalOidcConf               | external: false                                    |
	| GenerationDateTime             | 20230405-042734                                    |
	| IngressType                    | nginx                                              |
	| IsCrdReused                    | true                                               |
	| IsCustomImageRegistry          | false                                              |
	| K8sSetup                       | Openshift                                          |
	| Namespace                      | digitalai                                          |
	| OidcConfigType                 | existing                                           |
	| OsType                         | linux                                              |
	| PreservePvc                    | false                                              |
	| ProcessType                    | clean                                              |
	| ServerType                     | dai-release                                        |
	| ShortServerName                | xlr                                                |
	| UseCustomNamespace             | true                                               |
	 -------------------------------- ----------------------------------------------------
? Do you want to proceed to the deployment with these values? Yes
For current process files will be generated in the: digitalai/dai-release/digitalai/20230405-042734/kubernetes
Generated answers file successfully: digitalai/generated_answers_dai-release_digitalai_clean-20230405-042734.yaml 
Cleaning the resources on the cluster!
CR dai-ocp-xlr-digitalai is available, deleting
? Do you want to delete the resource digitalaireleaseocps.xlrocp.digital.ai/dai-ocp-xlr-digitalai: Yes
Deleted digitalaireleaseocps.xlrocp.digital.ai/dai-ocp-xlr-digitalai from namespace digitalai
Deleting statefulsets
Deleting deployments
? Do you want to delete the resource deployment/xlr-operator-controller-manager: Yes
Deleted deployment/xlr-operator-controller-manager from namespace digitalai
Deleting jobs
Deleting services
? Do you want to delete the resource svc/xlr-operator-controller-manager-metrics-service: Yes
Deleted svc/xlr-operator-controller-manager-metrics-service from namespace digitalai
Deleting secrets
Deleting roles
? Do you want to delete the resource role/xlr-operator-leader-election-role: Yes
Deleted role/xlr-operator-leader-election-role from namespace digitalai
? Do you want to delete the resource rolebinding/xlr-operator-leader-election-rolebinding: Yes
Deleted rolebinding/xlr-operator-leader-election-rolebinding from namespace digitalai
Deleting PVCs
? Do you want to delete the resource pvc/dai-ocp-xlr-digitalai-digitalai-release-ocp: Yes
Deleted pvc/dai-ocp-xlr-digitalai-digitalai-release-ocp from namespace digitalai
? Do you want to delete the resource pvc/data-dai-ocp-xlr-digitalai-postgresql-0: Yes
Deleted pvc/data-dai-ocp-xlr-digitalai-postgresql-0 from namespace digitalai
? Do you want to delete the resource pvc/data-dai-ocp-xlr-digitalai-rabbitmq-0: Yes
Deleted pvc/data-dai-ocp-xlr-digitalai-rabbitmq-0 from namespace digitalai
Clean finished successfully!
[INFO  tini (1)] Main child exited normally (with status '0')

```

## Install remote runner in k8s cluster.

```shell
   docker run -it
   --name xlclient
   -v ~/.kube/config:/opt/xebialabs/.kube/config
   -e KUBECONFIG=/opt/xebialabs/.kube/config 
   -v /home/ishwarya/git/deploy/xlr-remote-runner:/opt/xebialabs/remoteRunner
   xebialabsunsupported/xl-client:23.1.0-329.113 kube install

```
* In our example, we are mounting remote runner package from local path.
* This will start the xl-client in docker install/clean remote runner from the k8s cluster.
* You can stream the logs from the container using `docker logs -f <container id>`.


### 1. Installing remote-runner using xl-client kube install
```shell
[ishwarya@worker01 xl-docker-images]* S-90011 $ docker run -it -v ~/.kube/config:/opt/xebialabs/.kube/config -e KUBECONFIG=/opt/xebialabs/.kube/config --name xlclient -v /home/ishwarya/git/deploy/xlr-remote-runner:/opt/xebialabs/remoteRunner xebialabsunsupported/xl-client:23.1.0-329.113 kube install
[INFO  tini (1)] Spawned child process '/opt/xebialabs/xl-client/xl' with pid '7'
? Following kubectl context will be used during execution: `default/api-apollo-operator-raqx-p1-openshiftapps-com:6443/cluster-admin`? Yes
? Select the Kubernetes setup where the Digital.ai Devops Platform will be installed, updated or cleaned: Openshift [Openshift]
? Do you want to use an custom Kubernetes namespace (current default is 'digitalai'): Yes
? Enter the name of the Kubernetes namespace where the Digital.ai DevOps Platform will be installed, updated or cleaned: digitalai
? Product server you want to perform install for: dai-release-runner [Remote Runner for Digital.ai Release]
? Select type of image registry: default
? Enter the repository name (eg: <repositoryName> from <repositoryName>/<imageName>:<tagName>): xebialabs
? Enter the remote runner image name (eg: <imageName> from <repositoryName>/<imageName>:<tagName>): xlr-remote-runner
? Enter the image tag (eg: <tagName> from <repositoryName>/<imageName>:<tagName>): 0.1.32
? Enter the Remote Runner Helm Chart path (URL or local path): /opt/xebialabs/remoteRunner/helm/remote-runner
? Enter the Release URL that will be used by remote runner: http://router-default.apps.apollo-operator.raqx.p1.openshiftapps.com/
? Enter the Release Token that will be used by remote runner: rpa_0a03368a8c8ca112417182b5d24b552bd5dc26a9
? Provide storage class for the remote runner: aws-efs
         -------------------------------- ----------------------------------------------------
        | LABEL                          | VALUE                                              |
         -------------------------------- ----------------------------------------------------
        | CleanBefore                    | false                                              |
        | CreateNamespace                | true                                               |
	| ExternalOidcConf               | external: false                                    |
	| GenerationDateTime             | 20230405-042108                                    |
	| ImageNameRemoteRunner          | xlr-remote-runner                                  |
	| ImageRegistryType              | default                                            |
	| ImageTagRemoteRunner           | 0.1.32                                             |
	| IngressType                    | nginx                                              |
	| IsCustomImageRegistry          | false                                              |
	| K8sSetup                       | Openshift                                          |
	| Namespace                      | digitalai                                          |
	| OidcConfigType                 | no-oidc                                            |
	| OsType                         | linux                                              |
	| ProcessType                    | install                                            |
	| RemoteRunnerHelmChartUrl       | /opt/xebialabs/remoteRunner/helm/remote-runner     |
	| RemoteRunnerReleaseUrl         | http://router-default.apps.apollo-operator.raqx... |
	| RemoteRunnerStorageClass       | aws-efs                                            |
	| RemoteRunnerToken              | rpa_0a03368a8c8ca112417182b5d24b552bd5dc26a9       |
	| RepositoryName                 | xebialabs                                          |
	| ServerType                     | dai-release-runner                                 |
	| ShortServerName                | other                                              |
	| UseCustomNamespace             | true                                               |
	 -------------------------------- ----------------------------------------------------
? Do you want to proceed to the deployment with these values? Yes
For current process files will be generated in the: digitalai/dai-remote-runner/digitalai/20230405-042108/kubernetes
Generated answers file successfully: digitalai/generated_answers_dai-release-runner_digitalai_install-20230405-042108.yaml 
Starting install processing.
Installing helm chart remote-runner from /opt/xebialabs/xl-client/digitalai/dai-remote-runner/digitalai/20230405-042108/kubernetes/helm-chart
Installed helm chart remote-runner to namespace digitalai
[INFO  tini (1)] Main child exited normally (with status '0')

```
### 2. Cleaning remote-runner using xl-client kube clean
```shell

[ishwarya@worker01 xl-docker-images]* S-90011 $ docker run -it -v ~/.kube/config:/opt/xebialabs/.kube/config -e KUBECONFIG=/opt/xebialabs/.kube/config --name xlclient -v /home/ishwarya/git/deploy/xlr-remote-runner:/opt/xebialabs/remoteRunner -v /home/ishwarya/Downloads/config:/opt/xebialabs/xl-client/config xebialabsunsupported/xl-client:23.1.0-329.113 kube clean
[INFO  tini (1)] Spawned child process '/opt/xebialabs/xl-client/xl' with pid '7'
? Following kubectl context will be used during execution: `default/api-apollo-operator-raqx-p1-openshiftapps-com:6443/cluster-admin`? Yes
? Select the Kubernetes setup where the Digital.ai Devops Platform will be installed, updated or cleaned: Openshift [Openshift]
? Do you want to use an custom Kubernetes namespace (current default is 'digitalai'): Yes
? Enter the name of the Kubernetes namespace where the Digital.ai DevOps Platform will be installed, updated or cleaned: digitalai
? Product server you want to perform clean for: dai-release-runner [Remote Runner for Digital.ai Release]
	 -------------------------------- ----------------------------------------------------
        | LABEL                          | VALUE                                              |
         -------------------------------- ----------------------------------------------------
        | CleanBefore                    | false                                              |
	| CreateNamespace                | true                                               |
	| ExternalOidcConf               | external: false                                    |
	| GenerationDateTime             | 20230405-043542                                    |
	| IngressType                    | nginx                                              |
	| IsCustomImageRegistry          | false                                              |
	| K8sSetup                       | Openshift                                          |
	| Namespace                      | digitalai                                          |
	| OidcConfigType                 | existing                                           |
	| OsType                         | linux                                              |
	| ProcessType                    | clean                                              |
	| ServerType                     | dai-release-runner                                 |
	| ShortServerName                | other                                              |
	| UseCustomNamespace             | true                                               |
	 -------------------------------- ----------------------------------------------------
? Do you want to proceed to the deployment with these values? Yes
For current process files will be generated in the: digitalai/dai-remote-runner/digitalai/20230405-043542/kubernetes
Generated answers file successfully: digitalai/generated_answers_dai-release-runner_digitalai_clean-20230405-043542.yaml 
Uninstalling helm chart remote-runner from digitalai
Uninstalled helm chart remote-runner from namespace digitalai
Clean finished successfully!
[INFO  tini (1)] Main child exited normally (with status '0')

```
## Docker compose
### 1. Installing xl-release using xl-client kube install using docker-compose file.

```yaml
version: "2"
services:
  xl-client:
    image: xebialabsunsupported/xl-client:23.1.0-329.113
    container_name: xl-client
    volumes:
      - /home/ishwarya/Downloads/config:/opt/xebialabs/xl-client/config
      - ~/.kube/config:/opt/xebialabs/.kube/config
    command: ["kube", "install"]  
```

* Save the above content to a file named `docker-compose-xlclient.yaml` in a folder and run `docker-compose -f docker-compose-xlclient.yaml run xl-client` from the same folder.

```shell

[ishwarya@worker01 Downloads] $ docker-compose -f xlclient.yaml run xl-client
Creating downloads_xl-client_run ... done
? Following kubectl context will be used during execution: `xl-cli-cluster`? Yes
? Select the Kubernetes setup where the Digital.ai Devops Platform will be installed, updated or cleaned: AzureAKS [Azure AKS]
? Do you want to use an custom Kubernetes namespace (current default is 'digitalai'): Yes
? Enter the name of the Kubernetes namespace where the Digital.ai DevOps Platform will be installed, updated or cleaned: digitalai
? Product server you want to perform install for: dai-release [Digital.ai Release]
? Select type of image registry: default
? Enter the repository name (eg: <repositoryName> from <repositoryName>/<imageName>:<tagName>): xebialabsunsupported
? Enter the image name (eg: <imageName> from <repositoryName>/<imageName>:<tagName>): xl-release
? Enter the image tag (eg: <tagName> from <repositoryName>/<imageName>:<tagName>): 23.1.0-328.113
? Enter the release server replica count: 1
? Enter PVC size for Release (Gi): 1
? Select between supported Access Modes: ReadWriteMany
? Select between supported ingress types: nginx
? Do you want to enable an TLS/SSL configuration (if yes, requires existing TLS secret in the namespace): No
? Provide DNS name for accessing UI of the server: xlr-operator.germanywestcentral.cloudapp.azure.com
? Provide administrator password: admin
? Type of the OIDC configuration: no-oidc [No OIDC Configuration]
? Enter the operator image to use (eg: <repositoryName>/<imageName>:<tagName>): xebialabsunsupported/release-operator:23.1.0-328.113
? Select source of the license: file
? Provide license file for the server: /opt/xebialabs/xl-client/config/xl-release.lic
? Select source of the repository keystore: generate
? Provide keystore passphrase: YkA8VRZLJsJYr8D9
? Provide storage class for the server: xld-operator-azurefile
? Do you want to install a new PostgreSQL on the cluster: Yes
? Provide Storage Class to be defined for PostgreSQL: xlr-operator-azuredisk
? Provide PVC size for PostgreSQL (Gi): 1
? Do you want to install a new RabbitMQ on the cluster: Yes
? Replica count to be defined for RabbitMQ: 1
? Storage Class to be defined for RabbitMQ: xld-operator-azurefile
? Provide PVC size for RabbitMQ (Gi): 1
         -------------------------------- ----------------------------------------------------
        | LABEL                          | VALUE                                              |
         -------------------------------- ----------------------------------------------------
        | AccessModeRelease              | ReadWriteMany                                      |
        | AdminPassword                  | admin                                              |
        | CleanBefore                    | false                                              |
        | CreateNamespace                | true                                               |
        | EnableIngressTls               | false                                              |
        | EnablePostgresql               | true                                               |
        | EnableRabbitmq                 | true                                               |
	| ExternalOidcConf               | external: false                                    |
	| GenerationDateTime             | 20230405-075832                                    |
	| ImageNameRelease               | xl-release                                         |
	| ImageRegistryType              | default                                            |
	| ImageTag                       | 23.1.0-328.113                                     |
	| IngressHost                    | xlr-operator.germanywestcentral.cloudapp.azure.com |
	| IngressType                    | nginx                                              |
	| IsCustomImageRegistry          | false                                              |
	| K8sSetup                       | AzureAKS                                           |
	| KeystorePassphrase             | YkA8VRZLJsJYr8D9                                   |
	| License                        | LS0tIExpY2Vuc2UgLS0tCkxpY2Vuc2UgdmVyc2lvbjogNApQ.. |
	| LicenseFile                    | /opt/xebialabs/xl-client/config/xl-release.lic     |
	| LicenseSource                  | file                                               |
	| Namespace                      | digitalai                                          |
	| OidcConfigType                 | no-oidc                                            |
	| OidcConfigTypeInstall          | no-oidc                                            |
	| OperatorImageReleaseGeneric    | xebialabsunsupported/release-operator:23.1.0-328.. |
	| OsType                         | linux                                              |
	| PostgresqlPvcSize              | 1                                                  |
	| PostgresqlStorageClass         | xlr-operator-azuredisk                             |
	| ProcessType                    | install                                            |
	| PvcSizeRelease                 | 1                                                  |
	| RabbitmqPvcSize                | 1                                                  |
	| RabbitmqReplicaCount           | 1                                                  |
	| RabbitmqStorageClass           | xld-operator-azurefile                             |
	| RepositoryKeystoreSource       | generate                                           |
	| RepositoryName                 | xebialabsunsupported                               |
	| ServerType                     | dai-release                                        |
	| ShortServerName                | xlr                                                |
	| StorageClass                   | xld-operator-azurefile                             |
	| UseCustomNamespace             | true                                               |
	| XlrReplicaCount                | 1                                                  |
	 -------------------------------- ----------------------------------------------------
? Do you want to proceed to the deployment with these values? Yes
For current process files will be generated in the: digitalai/dai-release/digitalai/20230405-075832/kubernetes
Generated answers file successfully: digitalai/generated_answers_dai-release_digitalai_install-20230405-075832.yaml 
Starting install processing.
Created keystore digitalai/dai-release/digitalai/20230405-075832/kubernetes/repository-keystore.jceks
Skip creating namespace digitalai, already exists
Update CR with namespace... / Using custom resource name dai-xlr-digitalai
Generated files successfully for AzureAKS installation.
Applying resources to the cluster!
? Do you want to replace the resource clusterrole/digitalai-xlr-operator-proxy-role with specification from file
digitalai/dai-release/digitalai/20230405-075832/kubernetes/template/cluster-role-digital-proxy-role.yaml: Yes
Applied resource clusterrole/digitalai-xlr-operator-proxy-role from the file digitalai/dai-release/digitalai/20230405-075832/kubernetes/template/cluster-role-digital-proxy-role.yaml
? Do you want to replace the resource clusterrole/digitalai-xlr-operator-manager-role with specification from file
digitalai/dai-release/digitalai/20230405-075832/kubernetes/template/cluster-role-manager-role.yaml: Yes
Applied resource clusterrole/digitalai-xlr-operator-manager-role from the file digitalai/dai-release/digitalai/20230405-075832/kubernetes/template/cluster-role-manager-role.yaml
? Do you want to replace the resource clusterrole/digitalai-xlr-operator-metrics-reader with specification from file
digitalai/dai-release/digitalai/20230405-075832/kubernetes/template/cluster-role-metrics-reader.yaml: Yes
Applied resource clusterrole/digitalai-xlr-operator-metrics-reader from the file digitalai/dai-release/digitalai/20230405-075832/kubernetes/template/cluster-role-metrics-reader.yaml
Applied resource service/xlr-operator-controller-manager-metrics-service from the file digitalai/dai-release/digitalai/20230405-075832/kubernetes/template/controller-manager-metrics-service.yaml
Applied resource customresourcedefinition/digitalaireleases.xlr.digital.ai from the file digitalai/dai-release/digitalai/20230405-075832/kubernetes/template/custom-resource-definition.yaml
Applied resource deployment/xlr-operator-controller-manager from the file digitalai/dai-release/digitalai/20230405-075832/kubernetes/template/deployment.yaml
Applied resource role/xlr-operator-leader-election-role from the file digitalai/dai-release/digitalai/20230405-075832/kubernetes/template/leader-election-role.yaml
Applied resource rolebinding/xlr-operator-leader-election-rolebinding from the file digitalai/dai-release/digitalai/20230405-075832/kubernetes/template/leader-election-rolebinding.yaml
? Do you want to replace the resource clusterrolebinding/digitalai-xlr-operator-manager-rolebinding with specification from file
digitalai/dai-release/digitalai/20230405-075832/kubernetes/template/manager-rolebinding.yaml: Yes
Applied resource clusterrolebinding/digitalai-xlr-operator-manager-rolebinding from the file digitalai/dai-release/digitalai/20230405-075832/kubernetes/template/manager-rolebinding.yaml
? Do you want to replace the resource clusterrolebinding/digitalai-xlr-operator-proxy-rolebinding with specification from file
digitalai/dai-release/digitalai/20230405-075832/kubernetes/template/proxy-rolebinding.yaml: Yes
Applied resource clusterrolebinding/digitalai-xlr-operator-proxy-rolebinding from the file digitalai/dai-release/digitalai/20230405-075832/kubernetes/template/proxy-rolebinding.yaml
Applied resource digitalairelease/dai-xlr-digitalai from the file digitalai/dai-release/digitalai/20230405-075832/kubernetes/dai-release_cr.yaml
Install finished successfully!

```
### 2. Cleaning xl-release using xl-client kube install using docker-compose file.

```shell

version: "2"
services:
  xl-client:
    image: xebialabsunsupported/xl-client:23.1.0-329.113
    container_name: xl-client
   # stdin_open: true
   # tty: true
    volumes:
      - /home/ishwarya/Downloads/config:/opt/xebialabs/xl-client/config
      - ~/.kube/config:/opt/xebialabs/.kube/config      
    environment:
      - KUBECONFIG=/opt/xebialabs/.kube/config
    command: ["kube", "clean"]  
```

* Save the above content to a file named `docker-compose-xlclient.yaml` in a folder and run `docker-compose -f docker-compose-xlclient.yaml run xl-client` from the same folder.
```shell

[ishwarya@worker01 Downloads] $ docker-compose -f xlclient.yaml run xl-client
Creating downloads_xl-client_run ... done
? Following kubectl context will be used during execution: `xl-cli-cluster`? Yes
? Select the Kubernetes setup where the Digital.ai Devops Platform will be installed, updated or cleaned: AzureAKS [Azure AKS]
? Do you want to use an custom Kubernetes namespace (current default is 'digitalai'): Yes
? Enter the name of the Kubernetes namespace where the Digital.ai DevOps Platform will be installed, updated or cleaned: digitalai
? Product server you want to perform clean for: dai-release [Digital.ai Release]
? Enter the name of custom resource definition you want to reuse or replace: digitalaireleases.xlr.digital.ai
? Should CRD be reused, if No we will delete the CRD digitalaireleases.xlr.digital.ai, and all related CRs will be deleted with it: Yes
? Enter the name of custom resource: dai-xlr-digitalai
? Should we preserve persisted volume claims? If not all volume data will be lost: No
         -------------------------------- ----------------------------------------------------
        | LABEL                          | VALUE                                              |
         -------------------------------- ----------------------------------------------------
	| CleanBefore                    | false                                              |
	| CrName                         | dai-xlr-digitalai                                  |
	| CrdName                        | digitalaireleases.xlr.digital.ai                   |
	| CreateNamespace                | true                                               |
	| ExternalOidcConf               | external: false                                    |
	| GenerationDateTime             | 20230405-081824                                    |
	| IngressType                    | nginx                                              |
	| IsCrdReused                    | true                                               |
	| IsCustomImageRegistry          | false                                              |
	| K8sSetup                       | AzureAKS                                           |
	| Namespace                      | digitalai                                          |
	| OidcConfigType                 | existing                                           |
	| OsType                         | linux                                              |
	| PreservePvc                    | false                                              |
	| ProcessType                    | clean                                              |
	| ServerType                     | dai-release                                        |
	| ShortServerName                | xlr                                                |
	| UseCustomNamespace             | true                                               |
	 -------------------------------- ----------------------------------------------------
? Do you want to proceed to the deployment with these values? Yes
For current process files will be generated in the: digitalai/dai-release/digitalai/20230405-081824/kubernetes
Generated answers file successfully: digitalai/generated_answers_dai-release_digitalai_clean-20230405-081824.yaml 
Cleaning the resources on the cluster!
CR dai-xlr-digitalai is available, deleting
? Do you want to delete the resource digitalaireleases.xlr.digital.ai/dai-xlr-digitalai: Yes
Deleted digitalaireleases.xlr.digital.ai/dai-xlr-digitalai from namespace digitalai
Deleting statefulsets
Deleting deployments
? Do you want to delete the resource deployment/xlr-operator-controller-manager: Yes
Deleted deployment/xlr-operator-controller-manager from namespace digitalai
Deleting jobs
Deleting services
? Do you want to delete the resource svc/xlr-operator-controller-manager-metrics-service: Yes
Deleted svc/xlr-operator-controller-manager-metrics-service from namespace digitalai
Deleting secrets
? Do you want to delete the resource secret/sh.helm.release.v1.dai-xlr-digitalai.v1: Yes
Deleted secret/sh.helm.release.v1.dai-xlr-digitalai.v1 from namespace digitalai
? Do you want to delete the resource ingressclass/nginx-dai-xlr-digitalai: Yes
Deleted ingressclass/nginx-dai-xlr-digitalai from namespace digitalai
Deleting roles
? Do you want to delete the resource role/xlr-operator-leader-election-role: Yes
Deleted role/xlr-operator-leader-election-role from namespace digitalai
? Do you want to delete the resource rolebinding/xlr-operator-leader-election-rolebinding: Yes
Deleted rolebinding/xlr-operator-leader-election-rolebinding from namespace digitalai
Deleting PVCs
? Do you want to delete the resource pvc/dai-xlr-digitalai-digitalai-release: Yes
Deleted pvc/dai-xlr-digitalai-digitalai-release from namespace digitalai
? Do you want to delete the resource pvc/data-dai-xlr-digitalai-postgresql-0: Yes
Deleted pvc/data-dai-xlr-digitalai-postgresql-0 from namespace digitalai
? Do you want to delete the resource pvc/data-dai-xlr-digitalai-rabbitmq-0: Yes
Deleted pvc/data-dai-xlr-digitalai-rabbitmq-0 from namespace digitalai
Clean finished successfully!

```
