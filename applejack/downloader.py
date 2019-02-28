from . import target_path
from getpass import getpass
import urllib


class XLDevOpsPlatformDownloader(object):

    def __init__(self, commandline_args, product_conf):
        """Initialize the XebiaLabs DevOps Platform download client."""
        self.product_conf = product_conf
        self.download_source = commandline_args['download_source']
        self.use_cache = commandline_args['use_cache']
        self.download_source = commandline_args['download_source']
        self.download_username = commandline_args['download_username']
        self.download_password = commandline_args['download_password']
        self.product_version = commandline_args['xl_version']
        pass

    def is_cached(self):
        return self.__target_path(self.__download_url()).exists()

    def __download_url(self):
        urlTemplate = self.product_conf['repositories'][self.download_source]
        nexus_repository = "alphas" if "alpha" in self.product_version else "releases"
        return urlTemplate.format(repo=nexus_repository, version=self.product_version, product=self.product_conf['name'])

    def __target_path(self, download_url):
        return target_path(self.product_conf['name'], self.product_version) / 'resources' / self.__product_filename(download_url)

    def __product_filename(self, download_url):
        return self.product_conf['resources']['target_name'].format(version=self.product_version, product=self.product_conf['name'])

    def download_product(self):
        if 'repositories' in self.product_conf.keys():
            # Determine filename and download URL
            url = self.__download_url()
            target_filename = self.__target_path(url)
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

