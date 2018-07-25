from . import PRODUCTS
from pathlib import Path
import urllib


class XLDevOpsPlatformDownloader(object):

    def __init__(self, commandline_args, product):
        """Initialize the XebiaLabs DevOps Platform download client."""
        self.product = product
        self.download_source = commandline_args.download_source
        self.use_cache = commandline_args.use_cache
        self.download_source = commandline_args.download_source
        self.download_username = commandline_args.download_username
        self.download_password = commandline_args.download_password
        self.product_version = commandline_args.xl_version
        pass

    def target_path(self):
        return Path('resources') / self.product_filename()
        pass

    def product_filename(self):
        return "{product}-{version}-server.zip".format(product=self.product, version=self.product_version)

    def download_product(self):
        # Determine filename and download URL
        product_filename = self.product_filename()
        download_url = None
        urlTemplate = PRODUCTS[self.product][self.download_source]
        nexus_repository = "alphas" if "alpha" in self.product_version else "releases"
        download_url = urlTemplate.format(repo=nexus_repository, version=self.product_version) + product_filename
        target_filename = self.target_path()
        # Set up basic auth for urllib
        if not self.download_username:
            raise ValueError('--download-username is needed')
        if not self.download_password:
            raise ValueError('--download-password is needed')
        passman = urllib.request.HTTPPasswordMgrWithDefaultRealm()
        passman.add_password(None, download_url, self.download_username, self.download_password)
        authhandler = urllib.request.HTTPBasicAuthHandler(passman)
        opener = urllib.request.build_opener(authhandler)
        urllib.request.install_opener(opener)

        print("Downloading product ZIP from %s" % (download_url))
        response = urllib.request.urlopen(download_url)
        data = response.read()
        with open(target_filename, 'wb') as f:
            f.write(data)

        print("Product ZIP downloaded to %s" % target_filename)
