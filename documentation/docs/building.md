---
sidebar_position: 4
---

# Building Docker images from generated Dockerfiles

To generate the images from the Dockerfiles the following commands can be used:

```shell
$ ./applejack.py build --xl-version <version> --use-cache
```

This command will only succeed if you've already downloaded the binaries for both components (XL Deploy and XL Release) of the XebiaLabs DevOps Platform. If you do not have these readily available, you can use the following command:

```shell
$ ./applejack.py build --xl-version <version> --download-username <username> --download-password <password>
```

This command will use the provided username and password to login to the XebiaLabs distribution site and download your copy of the XebiaLabs DevOps Platform to embed in the built image.

By default the images are generated with 3 different target operating systems:
- RedHat Enterprise Linux
- Centos 7
- Debian Slim
- Amazon Linux

If you only want to build a Docker image for a specific target operating system, use the following command:

```shell
$ ./applejack.py build --xl-version <version> --target-os rhel --target-os centos --target-os debian-slim
```
Note: For rhel images you will need to build it in RedHat OS with valid RHEL subscription.

If you want to push Docker image while building you need to use `--push` and `--registry` with dockerhub organisation you need to push to which is by default xebialabs, see following command:

```shell
$ ./applejack.py build --xl-version <version> --target-os centos --push --registry xebialabs
```

### Building an image for an alpha version of XL Deploy or XL Release
Alpha versions are not released to Distribution site hence you will need to get those versions from nexus by specifying `--download-source`, see the following command:
```shell
$ ./applejack.py build --xl-version <version> --download-username <LDAP username> --download-source nexus
```

If you also want to push it to the xebialabsunsupported organisation, use the following commandline:

```shell
$ ./applejack.py build --xl-version <version> --download-username <LDAP username> --download-source nexus --push --registry xebialabsunsupported
```

### Development versions
You can create 'official' Docker versions from your SNAPSHOT server zips. (Tip: use `--target-os=centos` or `--target-os=debian-slim`.) Install your SNAPSHOTs into your local `.m2` folder (or explicitly specify one as below) and issue the following command:
```shell
$ ./applejack.py build --xl-version <version> --download-source=localm2 # looks inside ~/.m2/repository

$ ./applejack.py build --xl-version <version> --download-source=localm2 --m2location=/tmp/foo/m2/repo
```
This relies on `./applejack/conf/products/*.yml` each having a key `repositories.localm2` (sibling to `repositories.nexus` and `repositories.dist`) with a value specifying a relative path inside the repository (e.g. 'com/xebialabs/deployit/xl-deploy-base/{version}/{product}-base-{version}-server.zip')

For building an image for one specific product only, you can also just point to the specific zipfile to use:
```shell
$ ./applejack.py build --xl-version <version> --product=xl-deploy --download-source=zip --zipfile=/tmp/foo/xld-9.0.0-SNAPSHOT.zip
```
### Database driver support

Both XL Release and XL Deploy supports db2, mysql, mssql, postgresql, oracle database for production setups more information can be found on official documentation :

- XL-Release : https://docs.xebialabs.com/release/how-to/configure-the-xl-release-sql-repository-in-a-database.html

- XL-Deploy : https://docs.xebialabs.com/deploy/how-to/configure-the-xl-deploy-sql-repository.html

To connect with these databases both the products needs jdbc driver in the classpath, example:  inside `/opt/xebialabs/xl-release-server/lib` (for xl release).

By default with these official images we provide jdbc drivers for mysql, mssql and postgresql.

if you have a requirement to connect to the db2, oracle then you will need to provide jdbc drivers by creating your custom docker image on top of official image and copying jdbc drivers in the `lib` directory.

Example : Adding db2 jdbc driver in classpath of xl-release container

```shell
FROM xebialabs/xl-release:8.5
ADD db2jcc4-10.1.jar /opt/xebialabs/xl-release-server/lib
```
