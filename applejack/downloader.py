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
        self.download_username = commandline_args['download_username']
        self.download_password = commandline_args['download_password']
        self.product_version = commandline_args['xl_version']
        self.m2location = commandline_args['m2location']
        self.zipfile = commandline_args['zipfile']

    def _is_arch_specific(self):
        """Check if this product has architecture-specific downloads."""
        return '{arch}' in self.product_conf['resources']['target_name']

    def is_cached(self, architectures=None):
        """Check if product downloads are cached for all requested architectures."""
        architectures = architectures or ['amd64']
        if self._is_arch_specific():
            return all(self.__target_path(arch=arch).exists() for arch in architectures)
        else:
            return self.__target_path().exists()

    def __download_url(self, arch=None):
        url_template = self.product_conf['repositories'][self.download_source]
        nexus_repository = "alphas" if "alpha" in self.product_version else "releases"
        format_args = dict(repo=nexus_repository, version=self.product_version, product=self.product_conf['name'])
        if arch:
            format_args['arch'] = arch
        return url_template.format(**format_args)

    def __target_path(self, arch=None):
        return target_path(self.product_conf['name'], self.product_version) / 'resources' / self.__product_filename(arch=arch)

    def __product_filename(self, arch=None):
        format_args = dict(version=self.product_version, product=self.product_conf['name'])
        if arch:
            format_args['arch'] = arch
        return self.product_conf['resources']['target_name'].format(**format_args)

    def download_product(self, architectures=None):
        """Download product artifacts for the specified architectures.
        
        For arch-specific products (e.g., xl-client), downloads a binary for each architecture.
        For arch-neutral products (e.g., xl-deploy), downloads once regardless of architectures.
        
        Args:
            architectures: List of architectures to download for (e.g., ['amd64', 'arm64']).
                          Defaults to ['amd64'].
        """
        architectures = architectures or ['amd64']

        if self.download_source == 'zip':
            if not self.zipfile: raise Exception('--zipfile=xyz must be specified for --download-source=zip')
            target = self.__target_path()
            if not target.parent.is_dir():
                target.parent.mkdir(parents=True)
            copyfile(self.zipfile, target)
        elif self.download_source == 'localm2':
            m2 = Path(self.m2location) if self.m2location else Path.home() / '.m2' / 'repository'
            m2path = str(self.product_conf['repositories']['localm2']).format(version=self.product_version, product=self.product_conf['name'])
            print('Copying server zip from %s' % str(m2 / m2path))
            target = self.__target_path()
            if not target.parent.is_dir():
                target.parent.mkdir(parents=True)
            copyfile(m2 / m2path, target)
        elif 'repositories' in self.product_conf.keys():
            if self._is_arch_specific():
                # Download for each requested architecture
                for arch in architectures:
                    self.__download_single(arch=arch)
            else:
                # Architecture-neutral download (e.g., Java server ZIPs)
                self.__download_single(arch=None)
        else:
            print("Skipping Download because Repositories is not defined")

    def __download_single(self, arch=None):
        """Download a single product artifact, optionally for a specific architecture."""
        url = self.__download_url(arch=arch)
        target_filename = self.__target_path(arch=arch)
        if not target_filename.parent.is_dir():
            print("Creating resources directory '{}'.".format(target_filename.parent))
            target_filename.parent.mkdir(parents=True)
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

        arch_label = " (%s)" % arch if arch else ""
        print("Downloading product ZIP%s from %s" % (arch_label, url))
        response = urllib.request.urlopen(url)
        data = response.read()
        with open(target_filename, 'wb') as f:
            f.write(data)

        print("Product ZIP downloaded to %s" % target_filename)

