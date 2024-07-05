from jinja2 import Environment, FileSystemLoader
from pathlib import Path
from git import Repo
from datetime import datetime
from . import image_version, dockerfile_path, target_path, all_products, load_product_config, target_systems, all_product_configs


class Renderer(object):
    def __init__(self, commandline_args):
        """Initialize the XebiaLabs Dockerfile template rendering engine."""
        self.commit = commandline_args['commit']
        self.registry = commandline_args['registry']
        self.version = commandline_args['xl_version']
        self.skip_vulnerable_libs = commandline_args['skip_vulnerable_libs']
        self.image_version = image_version(commandline_args['xl_version'], commandline_args['suffix'])

    def __render_jinja_template(self, templates_path, template_file, target_file, context):
        env = Environment(
            loader=FileSystemLoader(str(templates_path))
        )
        template = env.get_template(str(template_file).replace('\\', '/'))
        with open(target_file, 'w') as f:
            f.write(template.render(context))

    def render(self, target_os, product_conf):
        self.__generate_dockerfile(target_os, product_conf)
        for dir in product_conf['resources']['dirs']:
            self.__copy_render_resources(dir, product_conf, target_os)

    def __generate_dockerfile(self, target_os, product_conf):
        target_path = self.__get_target_path(target_os, product_conf['name'])
        context = self.__build_render_context(product_conf, target_os, is_slim=False)
        slim_context = self.__build_render_context(product_conf, target_os, is_slim=True)
        self.__render_jinja_template(Path('templates') / 'dockerfiles', product_conf['dockerfiles']['os'][target_os], target_path / 'Dockerfile', context)
        self.__render_jinja_template(Path('templates') / 'dockerfiles', product_conf['dockerfiles']['os'][target_os], target_path / 'Dockerfile.slim', slim_context)
        print("Dockerfile template for '%s' rendered" % target_os)

    def __build_render_context(self, product_conf, target_os, is_slim):
        context = dict(product_conf['context'])
        context['image_version'] = self.image_version
        context['xl_version'] = self.version
        context['registry'] = self.registry
        if self.skip_vulnerable_libs:
            context['skip_vulnerable_libs'] = self.skip_vulnerable_libs
        context['target_os'] = target_os
        context['today'] = datetime.now().strftime('%Y-%m-%d')
        context['is_slim'] = is_slim
        return context

    def __copy_render_resources(self, source_dir, product_conf, target_os):
        template_path = Path('templates') / 'resources'
        source_path = template_path / source_dir
        dest_path = target_path(product_conf['name'], self.version) / 'resources'
        if not dest_path.is_dir():
            dest_path.mkdir()
        for p in sorted(source_path.rglob('*')):
            relative = p.relative_to(source_path)
            if p.is_dir() and p.name == 'includes':
                # Skip over the j2 includes directory
                continue
            elif p.is_dir() and not (dest_path / relative).is_dir():
                (dest_path / relative).mkdir(parents=True)
            elif p.is_file() and '.j2' in p.suffixes:
                # Render J2 template
                render_dest = dest_path / relative.parent / relative.stem
                context = self.__build_render_context(product_conf, target_os, is_slim=False)
                self.__render_jinja_template(template_path, Path(source_dir) / relative, render_dest, context)

                if relative.parent.name == 'bin':
                    render_slim_dest = dest_path / relative.parent / (relative.stem + '.slim')
                    slim_context = self.__build_render_context(product_conf, target_os, is_slim=True)
                    self.__render_jinja_template(template_path, Path(source_dir) / relative, render_slim_dest, slim_context)
            elif p.is_file():
                p.copy(dest_path / relative)

    def __get_target_path(self, target_os, product_name):
        target_path = dockerfile_path(self.version, target_os, product_name)
        if not target_path.exists():
            target_path.mkdir(parents=True)
        return target_path

    def commit_rendered(self):
        self.__git_commit_dockerfiles()

    def __git_commit_dockerfiles(self):
        repo = Repo.init('.')
        # Check whether the index of the repository is empty so we can do a clean commit.
        if repo.index.diff('HEAD'):
            raise Exception("Git working index not empty!")

        origin = repo.remotes.origin

        # Only add the changed (or added) Dockerfiles to the index
        diff = [diff.a_path for diff in repo.index.diff(None)] + repo.untracked_files
        changed = False
        print(diff)
        for product_conf in all_product_configs():
            for target_os in target_systems(product_conf):
                dockerfile_paths = [
                    str(self.__get_target_path(target_os, product_conf['name']) / "Dockerfile"),
                    str(self.__get_target_path(target_os, product_conf['name']) / "Dockerfile.slim")
                ]
                for df in dockerfile_paths:
                    print("Checking diff for %s" % df)
                    if df in diff:
                        print("Adding modified %s" % df)
                        changed = True
                        repo.index.add([df])

        # If nothing changed, no commit/tag operation is needed.
        if not changed:
            print("No change detected, not committing")
            return
        repo.index.commit("Update Dockerfiles to version %s" % self.version)
        print("Committed updated Dockerfiles to %s" % repo.head.ref)

        origin.push()
        print("Dockerfiles have been committed and pushed to %s on %s" % (repo.head.ref, origin))
