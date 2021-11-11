---
sidebar_position: 3
---

# Generating the Dockerfiles for a new version of the DevOps Platform

In order to generate a new set of Dockerfiles for all components of the XebiaLabs DevOps Platform and commit them to version control, you can execute the following command:

To execute the commands in scope of the same Pip environment, you can prepend the command with `pipenv run python`

```shell
$ ./applejack.py render --xl-version <version> --commit
```

If you want to generate the Dockerfiles for a specific components of the XebiaLabs DevOps Platform, you can execute the following command:

```shell
$ ./applejack.py render --xl-version <version> --product xl-deploy --product xl-release
```

If you want to specify different base image organisation than default one "xebialabs" in which generated docker images will pull from you can use `--registry`,

```shell
$ ./applejack.py render --xl-version <version> --product xl-deploy --registry xebialabsunsupported
```

If you want to generate an updated set of Dockerfiles for an already released version of the XebiaLabs DevOps Platform, the following command will generate a version tag of `<version>-<suffix>`:

```shell
$ ./applejack.py render --xl-version <version> --suffix <number>
```
