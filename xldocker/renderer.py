from jinja2 import Environment, FileSystemLoader
from os import path
from git import Repo
from . import image_version, ALL_TARGET_SYSTEMS, major_minor, PRODUCTS, dockerfile_path


class XLDockerRenderer(object):
    def __init__(self, commandline_args):
        self.context = vars(commandline_args)
        self.commit = commandline_args.commit
        self.version = commandline_args.xl_version
        self.image_version = image_version(commandline_args.xl_version, commandline_args.suffix)
        self.context['image_version'] = self.image_version

    def generate_dockerfile(self, target_os, product):
        env = Environment(
            loader=FileSystemLoader('templates')
        )
        docker_file_template = env.get_template(path.join(target_os, 'Dockerfile.j2'))
        target_path = self.__get_target_path(target_os, product)
        with open(target_path / 'Dockerfile', 'w') as f:
            f.write(docker_file_template.render(self.context))
        print("Dockerfile template for '%s' rendered" % target_os)

    def __get_target_path(self, target_os, product):
        target_path = dockerfile_path(self.version, target_os, product)
        if not target_path.exists():
            target_path.mkdir(parents=True)
        return target_path

    def git_commit_dockerfiles(self):
        repo = Repo.init('.')
        # Check whether the index of the repository is empty so we can do a clean commit.
        if repo.index.diff('HEAD'):
            raise Exception("Git working index not empty!")

        origin = repo.remotes.origin

        # Only add the changed (or added) Dockerfiles to the index
        diff = [diff.a_path for diff in repo.index.diff(None)] + repo.untracked_files
        changed = False
        print(diff)
        for target_os in ALL_TARGET_SYSTEMS:
            for product in PRODUCTS.keys():
                df = str(self.__get_target_path(target_os, product) / "Dockerfile")
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

        # Attempt tagging and rewind if failed.
        # No longer doing this due to new directory structure
        # try:
        #     for tag, force in all_tags(None, self.image_version):
        #         repo.create_tag(tag, force=force)
        # except Exception as e:
        #     print("Resetting commit because tagging failed.")
        #     repo.head.reset('HEAD~1', index=True, working_tree=False)
        #     raise e
        origin.push()
        print("Dockerfiles have been committed and pushed to %s on %s" % (repo.head.ref, origin))
