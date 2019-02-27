#!/usr/bin/env python3
from applejack.downloader import XLDevOpsPlatformDownloader
from applejack.renderer import Renderer
from applejack.builder import ImageBuilder
from applejack import all_products, all_product_configs, load_product_config, target_systems
import click


class ProductConfigType(click.Choice):
    name = 'product_config'

    def __init__(self, choices):
        click.Choice.__init__(self, choices)

    def convert(self, value, param, ctx):
        if value:
            product = super(ProductConfigType, self).convert(value, param, ctx)
            return load_product_config(product)
        else:
            return None


_shared_opts = [
    click.option('--product', multiple=True, help="The product to build the files / images for.", type=ProductConfigType(all_products())),
    click.option('--xl-version', help="Product version, e.g. 8.1.0", required=True),
    click.option('--registry', help="Docker registry to use, either to pull from when used with render or to push to when used with build", default='xebialabs'),
    click.option('--suffix', help="The (optional) suffix attached to the Docker and Git commit tags. Only used when a new version of the Docker images is released for the same product version"),
]


def shared_opts(func):
    for option in reversed(_shared_opts):
        func = option(func)
    return func


@click.group(help="Render and build the Dockerfile templates")
def applejack():
    print("🦄 Whee! Let's go!")
    pass


@applejack.command(help="Render the templates")
@shared_opts
@click.option('--commit', '-c', is_flag=True, help="Commit and tag the generated Dockerfiles.")
def render(**kwargs):
    renderer = Renderer(kwargs)
    for product in (kwargs['product'] or all_product_configs()):
        for target_os in target_systems(product):
            print("Generating %s Dockerfile for %s" % (product['name'], target_os))
            renderer.render(target_os, product)
    if kwargs['commit']:
        print("Commiting generated Dockerfiles")
        renderer.commit_rendered()


@applejack.command(help="Build the Docker images from the generated templates")
@shared_opts
@click.option('--push', '-p', is_flag=True, help="Push the Docker images to the hub.")
@click.option('--download-source', help="Download source: dist (default) or nexus.", default='dist', type=click.Choice(["dist", "nexus"]))
@click.option('--download-username', help="Username to use to download product ZIP.")
@click.option('--download-password', help="Password to use to download product ZIP.")
@click.option('--target-os', multiple=True, help="The target container OS to build and/or push.")
@click.option('--use-cache', is_flag=True, help="Don't download product ZIP if already downloaded, don't pull the base image and use the Docker build cache")
def build(**kwargs):
    for product_conf in (kwargs['product'] or all_product_configs()):
        downloader = XLDevOpsPlatformDownloader(kwargs, product_conf)
        if not kwargs['use_cache'] or 'repositories' in product_conf.keys() or not downloader.is_cached():
            print("Going to download product ZIP for %s version %s" %
                  (product_conf['name'], kwargs['xl_version']))
            downloader.download_product()
        builder = ImageBuilder(kwargs, product_conf)
        for target_os in (kwargs['target_os'] or target_systems(product_conf)):
            print("Building Docker image for %s %s" % (product_conf['name'], target_os))
            image_id = builder.build_docker_image(target_os)
            if kwargs['push']:
                builder.push_image(image_id, target_os)


if __name__ == '__main__':
    applejack()
    print("🦄 🌈 Friendship is Magic... Like Docker 🦄")
