#!/usr/bin/env python3
import argparse
from xldocker.downloader import XLDevOpsPlatformDownloader
from xldocker.renderer import XLDockerRenderer
from xldocker.builder import XLDockerImageBuilder
from xldocker import ALL_TARGET_SYSTEMS, PRODUCTS


def add_common_arguments(parser):
    parser.add_argument('--product', help="The product to build the files / images for.", action="append", choices=PRODUCTS.keys())
    parser.add_argument('--xl-version', help="Product version, e.g. 8.1.0", required=True)
    parser.add_argument('--suffix', help="The (optional) suffix attached to the Docker and Git commit tags. Only used when a new version of the Docker images is released for the same product version")


parser = argparse.ArgumentParser(description="Render and build the Dockerfile templates")
subparsers = parser.add_subparsers(dest="action")
render_parser = subparsers.add_parser("render", help="Render the templates")
add_common_arguments(render_parser)
render_parser.add_argument('-c', '--commit', action='store_true', help="Commit and tag the generated Dockerfiles.")
build_parser = subparsers.add_parser("build", help="Build the Docker images from the generated templates")
add_common_arguments(build_parser)
build_parser.add_argument('-p', '--push', action='store_true', help="Push the Docker images to the hub.")
build_parser.add_argument('--download-source', help="Download source: dist (default) or nexus.", default='dist', choices=["dist", "nexus"])
build_parser.add_argument('--download-username', help="Username to use to download product ZIP.")
build_parser.add_argument('--download-password', help="Password to use to download product ZIP.")
build_parser.add_argument('--target-os', action='append', help="The target container OS to build and/or push.", choices=ALL_TARGET_SYSTEMS)
build_parser.add_argument('--registry', help="Registry to push the Docker image to.", default='xebialabs')
build_parser.add_argument('--use-cache', action='store_true', help="Don't download product ZIP if already downloaded, don't pull the base image and use the Docker build cache")
args = parser.parse_args()

if args.action == 'render':
    renderer = XLDockerRenderer(args)
    for target_os in ALL_TARGET_SYSTEMS:
        for product in (args.product or PRODUCTS.keys()):
            print("Generating %s Dockerfile for %s" % (product, target_os))
            renderer.generate_dockerfile(target_os, product)
    if args.commit:
        print("Commiting generated Dockerfiles")
        renderer.git_commit_dockerfiles()
elif args.action == 'build':
    for product in (args.product or PRODUCTS.keys()):
        downloader = XLDevOpsPlatformDownloader(args, product)
        if not args.use_cache or not downloader.target_path().exists():
            print("Going to download product ZIP for %s version %s" % (product, args.xl_version))
            downloader.download_product()

        builder = XLDockerImageBuilder(args, product)
        for target_os in (args.target_os or ALL_TARGET_SYSTEMS):
            print("Building Docker image for %s %s" % (product, target_os))
            image_id = builder.build_docker_image(target_os)
            if args.push:
                builder.push_image(image_id)
