"""xldocker package."""
from pathlib import Path


DEFAULT_OS = "debian-slim"
ALL_TARGET_SYSTEMS = ['debian-slim', 'centos', 'rhel']

PRODUCTS = {
    "xl-deploy": {
        "nexus": 'https://nexus.xebialabs.com/nexus/service/local/repositories/{repo}/content/com/xebialabs/deployit/xl-deploy/{version}/',
        "dist": 'https://dist.xebialabs.com/customer/xl-deploy/product/{version}/'
    },
    "xl-release": {
        "nexus": 'https://nexus.xebialabs.com/nexus/service/local/repositories/{repo}/content/com/xebialabs/xlrelease/xl-release/{version}/',
        "dist": 'https://dist.xebialabs.com/customer/xl-release/product/{version}/'
    }
}


def dockerfile_path(version, target_os, product):
    """Construct the path to where the Dockerfile template resides for a specific product, version and target_os."""
    return Path(major_minor(version)) / target_os / product


def image_version(version, suffix):
    """Return the image version from the version and suffix passed in."""
    return version if not suffix else "%s-%s" % (version, suffix)


def major_minor(image_version):
    """Split a version into its 2 root components (major, minor)."""
    return image_version.rsplit('.', 1)[0]


def all_tags(target_os, image_version):
    """Create a generator that yields all the version tags for a specific target_os and image_version."""
    major_version = major_minor(image_version)
    if target_os:
        yield ("%s-%s" % (image_version, target_os), False)
        yield ("%s-%s" % (major_version, target_os), True)
    if DEFAULT_OS == target_os or not target_os:
        yield (image_version, False)
        yield (major_version, True)
