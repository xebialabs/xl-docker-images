from jinja2 import Environment, FileSystemLoader
from os import path
from git import Repo
from . import image_version, ALL_TARGET_SYSTEMS, all_tags


class XLDockerRenderer(object):
    def __init__(self, commandline_args):
        self.context = vars(commandline_args)
        self.commit = commandline_args.commit
        self.version = commandline_args.xl_version
        self.image_version = image_version(commandline_args.xl_version, commandline_args.suffix)
        self.context['image_version'] = self.image_version

    def generate_dockerfile(self, target_os):
        env = Environment(
            loader=FileSystemLoader('templates')
        )
        docker_file_template = env.get_template(path.join(target_os, 'Dockerfile.j2'))
        with open(path.join(target_os, 'Dockerfile'), 'w') as f:
            f.write(docker_file_template.render(self.context))
        print("Dockerfile template for '%s' rendered" % target_os)

    def git_commit_dockerfiles(self):
        repo = Repo.init('.')
        # Check whether the index of the repository is empty so we can do a clean commit.
        if repo.index.diff('HEAD'):
            raise Exception("Git working index not empty!")

        origin = repo.remotes.origin

        # Only add the changed Dockerfiles to the index
        diff = [diff.a_path for diff in repo.index.diff(None)]
        changed = False
        for target_os in ALL_TARGET_SYSTEMS:
            df = path.join(target_os, 'Dockerfile')
            if df in diff:
                changed = True
                repo.index.add([df])

        # If nothing changed, no commit/tag operation is needed.
        if not changed:
            print("No change detected, not committing")
            return
        repo.index.commit("Update Dockerfiles to version %s" % self.version)
        print("Committed updated Dockerfiles to %s" % repo.head.ref)

        # Attempt tagging and rewind if failed.
        try:
            for tag, force in all_tags(None, self.image_version):
                repo.create_tag(tag, force=force)
        except Exception as e:
            print("Resetting commit because tagging failed.")
            repo.head.reset('HEAD~1', index=True, working_tree=False)
            raise e
        origin.push()
        print("Dockerfiles have been committed and pushed to %s on %s" % (repo.head.ref, origin))
