import subprocess
import sys
from pathlib import Path
from . import image_version, all_tags, target_path, target_systems


class ImageBuilder(object):
    def __init__(self, commandline_args, product_conf):
        """Initialize the Docker Image builder."""
        self.target_systems = commandline_args['target_os'] or target_systems(product_conf)
        self.registry = commandline_args['registry']
        self.repository = product_conf['context']['product']
        self.image_version = image_version(commandline_args['xl_version'], commandline_args['suffix'])
        self.use_cache = commandline_args['use_cache']
        self.product_conf = product_conf
        self.push = commandline_args['push']
        self.validate()

    def validate(self):
        if self.push and ('alpha' in self.image_version or 'beta' in self.image_version) and self.registry == 'xebialabs':
            raise Exception("Cannot push a non-release(candidate) to the official repository, please specify 'xebialabsunsupported'")
        pass

    def build_docker_image(self, target_os, is_slim, platforms=None):
        """Build a Docker image using docker buildx for multi-platform support.
        
        Args:
            target_os: Target operating system (e.g., 'ubuntu', 'redhat', 'alpine')
            is_slim: Whether to build the slim variant
            platforms: List of target platforms (e.g., ['linux/amd64', 'linux/arm64'])
        
        Returns:
            None (buildx doesn't return an image ID when building multi-platform)
        """
        platforms = platforms or ['linux/amd64']

        build_path = str(target_path(self.product_conf['name'], self.image_version))

        if is_slim:
            docker_file = str(Path(build_path) / target_os / "Dockerfile.slim").replace('\\', '/')
        else:
            docker_file = str(Path(build_path) / target_os / "Dockerfile").replace('\\', '/')
        repo = "%s/%s" % (self.registry, self.repository)

        # Build tag arguments
        tag_args = []
        for tag, _ in all_tags(target_os, self.image_version, self.product_conf['dockerfiles']['default']):
            if is_slim:
                tag += "-slim"
            tag_args.extend(['-t', '%s:%s' % (repo, tag)])

        platform_str = ','.join(platforms)
        is_multi_platform = len(platforms) > 1

        cmd = [
            'docker', 'buildx', 'build',
            '--platform', platform_str,
            '-f', docker_file,
            *tag_args,
        ]

        # For single-platform builds, explicitly pass TARGETARCH as a build-arg
        # to ensure it's set correctly even if buildx doesn't auto-inject it
        if not is_multi_platform:
            arch = platforms[0].split('/')[-1]
            cmd.extend(['--build-arg', 'TARGETARCH=%s' % arch])

        if self.push:
            # Multi-platform images must be pushed directly (can't load to local daemon)
            cmd.append('--push')
        elif not is_multi_platform:
            # Single platform can be loaded into local Docker daemon
            cmd.append('--load')
        else:
            # Multi-platform without push: build only (useful for CI validation)
            print("WARNING: Multi-platform build without --push. Images will not be loaded into local daemon.")

        if not self.use_cache:
            cmd.append('--no-cache')
            cmd.append('--pull')

        cmd.append(build_path)

        print("Running: %s" % ' '.join(cmd))
        result = subprocess.run(cmd, check=False)

        if result.returncode != 0:
            raise Exception("Docker buildx build failed with exit code %d for %s %s" % (
                result.returncode, target_os, '(slim)' if is_slim else ''))

        slim_label = " (slim)" if is_slim else ""
        print("Built image for %s%s [platforms: %s]" % (target_os, slim_label, platform_str))
        print("Tagged with: %s" % ', '.join(t for t in tag_args if not t.startswith('-')))

        return None
