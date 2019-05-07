from . import target_path
from pathlib import Path
from getpass import getpass
from shutil import copyfile
import urllib


class XLDevOpsPlatformDownloader(object):

    def __init__(self, commandline_args, product_conf):
        """Initialize the XebiaLabs DevOps Platform download client."""
        self.product_conf = product_conf
        self.download_source = commandline_args['download_source']
        self.use_cache = commandline_args['use_cache']
        self.download_username = commandline_args['download_username']
        self.download_password = commandline_args['download_password']
        self.product_version = commandline_args['xl_version']
        self.m2location = commandline_args['m2location']
        self.zipfile = commandline_args['zipfile']

    def is_cached(self):
        return self.__target_path().exists()

    def __download_url(self):
        url_template = self.product_conf['repositories'][self.download_source]
        nexus_repository = "alphas" if "alpha" in self.product_version else "releases"
        return url_template.format(repo=nexus_repository, version=self.product_version, product=self.product_conf['name'])

    def __target_path(self):
        return target_path(self.product_conf['name'], self.product_version) / 'resources' / self.__product_filename()

    def __product_filename(self):
        return self.product_conf['resources']['target_name'].format(version=self.product_version, product=self.product_conf['name'])

    def download_product(self):
        if self.download_source == 'zip':
            if not self.zipfile: raise Exception('--zipfile=xyz must be specified for --download-source=zip')
            copyfile(self.zipfile, self.__target_path())
        elif self.download_source == 'localm2':
            m2 = Path(self.m2location) if self.m2location else Path.home() / '.m2' / 'repository'
            m2path = str(self.product_conf['repositories']['localm2']).format(version=self.product_version, product=self.product_conf['name'])
            print('Copying server zip from %s' % str(m2 / m2path))
            copyfile(m2 / m2path, self.__target_path())
        elif 'repositories' in self.product_conf.keys():
            # Determine filename and download URL
            url = self.__download_url()
            target_filename = self.__target_path()
            if not target_filename.parent.is_dir():
                print("Creating resources directory '{}'.".format(target_filename.parent))
                target_filename.parent.mkdir()
            # Set up basic auth for urllib
            if not self.download_username:
                raise ValueError('--download-username is needed')
            if not self.download_password:
                self.download_password = getpass()
                if not self.download_password:
                    raise ValueError("Either specify --download-password on the commandline or input the password at the prompt")
            passman = urllib.request.HTTPPasswordMgrWithDefaultRealm()
            passman.add_password(None, url, self.download_username, self.download_password)
            authhandler = urllib.request.HTTPBasicAuthHandler(passman)
            opener = urllib.request.build_opener(authhandler)
            urllib.request.install_opener(opener)

            print("Downloading product ZIP from %s" % (url))
            response = urllib.request.urlopen(url)
            data = response.read()
            with open(target_filename, 'wb') as f:
                f.write(data)

            print("Product ZIP downloaded to %s" % target_filename)
        else:
            print("Skipping Download because Repositories is not defined")

