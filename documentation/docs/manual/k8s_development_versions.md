---
sidebar_position: 8
---

# Using development version images with minikube

After building development version images, described <a href="../building#development-versions" >here</a>, for example for xl-deploy:
```shell
$ ./applejack.py render --xl-version 10.4.0-SNAPSHOT --product xl-deploy --product deploy-task-engine
$ ./applejack.py build --xl-version 10.4.0-SNAPSHOT --product xl-deploy --product deploy-task-engine --download-source=localm2 --target-os centos
```

Start minikube with following options:
```shell
$ minikube start -p k120 --kubernetes-version=v1.20.0 --driver=virtualbox"
```

Load images to minikube VM:
```shell
$ minikube image load xebialabs/xl-deploy:10.4.0-SNAPSHOT -p k120
$ minikube image load xebialabs/deploy-task-engine:10.4.0-SNAPSHOT -p k120
```

In case of using [helm chart](https://github.com/digital-ai/deploy-helm-chart) do changes in `values.yaml` 
```yaml
...
## XL-Deploy image version
## Ref: https://hub.docker.com/r/xebialabs/xl-deploy/tags
ImageTag: "10.4.0-SNAPSHOT"

ServerImageRepository: "xebialabs/xl-deploy"
WorkerImageRepository: "xebialabs/deploy-task-engine"

## Specify a imagePullPolicy
## Defaults to 'Always' if image tag is 'latest',set to 'IfNotPresent'
ImagePullPolicy: "Never"
...
```

Install/delete in helm repo dir:
```shell
$ helm install xld .
$ helm delete xld
```
