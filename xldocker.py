#!/usr/bin/env python3
import argparse
import docker
import json
import re
import sys
import urllib
from xldocker.downloader import XLDevOpsPlatformDownloader
from xldocker.renderer import XLDockerRenderer
from xldocker.builder import XLDockerImageBuilder
from xldocker import ALL_TARGET_SYSTEMS

products = {
    "xl-deploy": {
        "nexusUrl": 'https://nexus.xebialabs.com/nexus/service/local/repositories/%s/content/com/xebialabs/deployit/xl-deploy/%s/',
        "distUrl": 'https://dist.xebialabs.com/customer/xl-deploy/product/%s/'
    },
    "xl-release": {
        "nexusUrl": 'https://nexus.xebialabs.com/nexus/service/local/repositories/%s/content/com/xebialabs/xl-release/%s/',
        "distUrl": 'https://dist.xebialabs.com/customer/xl-release/product/%s/'
    }
}


def add_common_arguments(parser):
    parser.add_argument('--product', help="The product to build the files / images for.", action="append", choices=["xl-deploy", "xl-release"])
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
        print("Generating Dockerfile for %s" % (target_os))
        renderer.generate_dockerfile(target_os)
    if args.commit:
        print("Commiting generated Dockerfiles")
        renderer.git_commit_dockerfiles()
elif args.action == 'build':
    builder = XLDockerImageBuilder(args)
    downloader = XLDevOpsPlatformDownloader(args)
    if not args.use_cache or not downloader.check_already_downloaded():
        print("Download the shizzle")
        download_product(XL_PRODUCT, args.xl_version, args.download_source, args.download_username, args.download_password, args.use_cache)
    for target_os in target_systems:
        print("Building Docker image for %s" % (target_os))
        builder.build_docker_image(target_os)
        if args.push:
            print("TODO PUSH!")
