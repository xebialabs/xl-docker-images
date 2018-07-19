DEFAULT_OS = "debian-slim"
ALL_TARGET_SYSTEMS = ['debian-slim', 'centos', 'rhel']

PRODUCTS = {
    "xl-deploy": {
        "nexusUrl": 'https://nexus.xebialabs.com/nexus/service/local/repositories/%s/content/com/xebialabs/deployit/xl-deploy/%s/',
        "distUrl": 'https://dist.xebialabs.com/customer/xl-deploy/product/%s/'
    },
    "xl-release": {
        "nexusUrl": 'https://nexus.xebialabs.com/nexus/service/local/repositories/%s/content/com/xebialabs/xl-release/%s/',
        "distUrl": 'https://dist.xebialabs.com/customer/xl-release/product/%s/'
    }
}


def image_version(version, suffix):
    """Return the image version from the version and suffix passed in"""
    return version if not suffix else "%s-%s" % (version, suffix)


def all_tags(target_os, image_version):
    major_minor = image_version.rsplit('.', 1)[0]
    if target_os:
        yield ("%s-%s" % (image_version, target_os), False)
        yield ("%s-%s" % (major_minor, target_os), True)
    if DEFAULT_OS == target_os or not target_os:
        yield (image_version, False)
        yield (major_minor, True)
