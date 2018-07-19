class XLDevOpsPlatformDownloader(object):

    def __init__(self, commandline_args, product):
        self.product = product
        self.download_source = commandline_args.download_source
        pass

    def filename_template(self):
        return "%s-%%s-server.zip" % self.product

    def download_product(self, product, product_version, download_source, download_username, download_password, use_cache):
        # Determine filename and download URL
        product_filename = self.filename_template() % (product_version)
        download_url = None
        if download_source == 'dist':
            download_url = DIST_DOWNLOAD_URL_TEMPLATE % (product_version) + product_filename
        elif download_source == 'nexus':
            nexus_repository = "alphas" if "alpha" in product_version else "releases"
            download_url = NEXUS_DOWNLOAD_URL_TEMPLATE % (nexus_repository, product_version) + product_filename
        else:
            raise ValueError("--download-source should be 'dist' or 'nexus'")
        target_filename = path.join('resources', product_filename)
        if use_cache and path.exists(target_filename):
            print("Product ZIP %s has already been download" % (product_filename))
            return

        # Set up basic auth for urllib
        if not download_username:
            raise ValueError('--download-username is required if --download is set')
        if not download_password:
            raise ValueError('--download-password is required if --download is set')
        passman = urllib.request.HTTPPasswordMgrWithDefaultRealm()
        passman.add_password(None, download_url, download_username, download_password)
        authhandler = urllib.request.HTTPBasicAuthHandler(passman)
        opener = urllib.request.build_opener(authhandler)
        urllib.request.install_opener(opener)

        print("Downloading product ZIP from %s" % (download_url))
        response = urllib.request.urlopen(download_url)
        data = response.read()
        with open(target_filename, 'wb') as f:
            f.write(data)
