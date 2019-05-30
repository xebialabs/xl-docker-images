"""xldocker package."""
from pathlib import Path
import yaml


def _copy(self, target):
    import shutil
    assert self.is_file()
    shutil.copy(str(self), str(target))  # str() only there for Python < (3, 6)


Path.copy = _copy


def load_product_config(product):
    p = Path("applejack/conf/products") / ("%s.yml" % product)
    if not p.exists():
        raise Exception("Could not find configuration for product %s in %s" % (product, p))
    return yaml.load(p.read_text())


def all_products():
    """Return all products for which a configuration exists."""
    return [x.stem for x in Path("applejack/conf/products").iterdir() if x.is_file()]


def all_product_configs():
    for p in all_products():
        yield load_product_config(p)


def target_systems(product_conf):
    """Return all configured target systems"""
    return product_conf['dockerfiles']['os'].keys()


def target_path(product, version):
    """Construct the target output path for all the generated artifacts."""
    return Path(product) / major_minor(version)


def dockerfile_path(version, target_os, product):
    """Construct the path to where the Dockerfile template resides for a specific product, version and target_os."""
    return target_path(product, version) / target_os


def image_version(version, suffix):
    """Return the image version from the version and suffix passed in."""
    return version if not suffix else "%s-%s" % (version, suffix)

def registry(registry):
    """Return registry from the --registry passed in."""
    return registry


def major_minor(image_version):
    """Split a version into its 2 root components (major, minor)."""
    return '.'.join(image_version.split('.')[0:2])


def all_tags(target_os, image_version, default_os=None):
    """Create a generator that yields all the version tags for a specific target_os and image_version."""
    major_version = major_minor(image_version)
    if target_os:
        yield ("%s-%s" % (image_version, target_os), False)
        yield ("%s-%s" % (major_version, target_os), True)
    if default_os == target_os or not target_os:
        yield (image_version, False)
        yield (major_version, True)