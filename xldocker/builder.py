from . import ALL_TARGET_SYSTEMS
import json
import docker
import re
import sys
from pathlib import Path
from . import image_version, all_tags, target_path


class XLDockerImageBuilder(object):
    def __init__(self, commandline_args, product):
        """Initialize the Docker Image builder."""
        self.target_systems = commandline_args.target_os or ALL_TARGET_SYSTEMS
        self.registry = commandline_args.registry
        self.repository = product
        self.image_version = image_version(commandline_args.xl_version, commandline_args.suffix)
        self.use_cache = commandline_args.use_cache
        self.product = product

    @staticmethod
    def convert_build_logs(generator):
        for line in generator:
            multilines = [l for l in line.split(b'\n') if l.strip()]
            for l in multilines:
                j = json.loads(l)
                if "stream" in j:
                    yield j['stream']
                elif "error" in j:
                    raise Exception(j["error"])

    def build_docker_image(self, target_os):
        client = docker.from_env()
        generator = client.api.build(
            nocache=not self.use_cache,
            pull=not self.use_cache,
            path=str(target_path(self.product, self.image_version)),
            dockerfile=str(Path(target_os) / "Dockerfile"),
            rm=True,
        )
        for line in self.convert_build_logs(generator):
            match = re.search(
                r'(^Successfully built |sha256:)([0-9a-f]+)$',
                line
            )
            if match:
                image_id = match.group(2)
            sys.stdout.write(line)

        print("Built image %s for %s" % (image_id, target_os))
        image = client.images.get(image_id)
        repo = "%s/%s" % (self.registry, self.repository)
        for tag, force in all_tags(target_os, self.image_version):
            print("Tag image with %s:%s" % (repo, tag))
            image.tag(repo, tag)
        image.reload()
        print("Image %s has been tagged with %s" % (image_id, ', '.join(image.tags)))
        return image_id

    @staticmethod
    def convert_push_logs(generator):
        for line in generator:
            multilines = [l for l in line.split(b'\n') if l.strip()]
            for l in multilines:
                j = json.loads(l)
                if 'status' in j and 'progress' not in j:
                    if 'id' in j:
                        yield "%s %s" % (j['status'], j['id'])
                    else:
                        yield j['status']
                if 'error' in j:
                    raise Exception(j['error'])

    def push_image(self, image_id, target_os):
        print("Pushing image with id %s to %s" % (image_id, self.registry))
        client = docker.from_env()
        image = client.images.get(image_id)
        print("image = %s" % image)
        for tag, force in all_tags(target_os, self.image_version):
            repo = "%s/%s" % (self.registry, self.repository)
            for line in self.convert_push_logs(client.images.push(repo, tag=tag, stream=True)):
                print(line)
            print("Image %s with tag %s has been pushed to %s" % (image_id, tag, repo))
