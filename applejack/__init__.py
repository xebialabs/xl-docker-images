"""xldocker package."""
from pathlib import Path


DEFAULT_OS = "debian-slim"
ALL_TARGET_SYSTEMS = ['debian-slim', 'centos', 'rhel']

PRODUCTS = {
    "xl-deploy": {
        "nexus": 'https://nexus.xebialabs.com/nexus/service/local/repositories/{repo}/content/com/xebialabs/deployit/xl-deploy/{version}/{product}-{version}-server-trial-edition.zip',
        "dist": 'https://dist.xebialabs.com/customer/xl-deploy/product/{version}/{product}-{version}-server.zip',
        "jinja_context": {
            "product": "xl-deploy",
            "product_name": "XL Deploy",
            "product_description": "Enterprise-scale Application Release Automation for any environment",
            "product_conf": "deployit",
            "port": 4516,
            "volumes": [
                "${APP_HOME}/conf",
                "${APP_HOME}/hotfix/lib",
                "${APP_HOME}/hotfix/plugins",
                "${APP_HOME}/ext",
                "${APP_HOME}/plugins",
                "${APP_HOME}/repository"
            ],
            "wrapper_conf": "xld-wrapper-linux.conf"
        }
    },
    "xl-release": {
        "nexus": 'https://nexus.xebialabs.com/nexus/service/local/repositories/{repo}/content/com/xebialabs/xlrelease/xl-release/{version}/{product}-{version}-server-trial-edition.zip',
        "dist": 'https://dist.xebialabs.com/customer/xl-release/product/{version}/{product}-{version}-server.zip',
        "jinja_context": {
            "product": "xl-release",
            "product_name": "XL Release",
            "product_description": "Automate, orchestrate and get visibility into your release pipelines — at enterprise scale",
            "product_conf": "xl-release",
            "port": 5516,
            "volumes": [
                "${APP_HOME}/archive",
                "${APP_HOME}/conf",
                "${APP_HOME}/hotfix",
                "${APP_HOME}/ext",
                "${APP_HOME}/plugins",
                "${APP_HOME}/repository"
            ],
            "wrapper_conf": "xlr-wrapper-linux.conf"
        }
    }
}


def _copy(self, target):
    import shutil
    assert self.is_file()
    shutil.copy(str(self), str(target))  # str() only there for Python < (3, 6)


Path.copy = _copy


def target_path(product, version):
    """Construct the target output path for all the generated artifacts."""
    return Path(product) / major_minor(version)


def dockerfile_path(version, target_os, product):
    """Construct the path to where the Dockerfile template resides for a specific product, version and target_os."""
    return target_path(product, version) / target_os


def image_version(version, suffix):
    """Return the image version from the version and suffix passed in."""
    return version if not suffix else "%s-%s" % (version, suffix)


def major_minor(image_version):
    """Split a version into its 2 root components (major, minor)."""
    return '.'.join(image_version.split('.')[0:2])


def all_tags(target_os, image_version):
    """Create a generator that yields all the version tags for a specific target_os and image_version."""
    major_version = major_minor(image_version)
    if target_os:
        yield ("%s-%s" % (image_version, target_os), False)
        yield ("%s-%s" % (major_version, target_os), True)
    if DEFAULT_OS == target_os or not target_os:
        yield (image_version, False)
        yield (major_version, True)
