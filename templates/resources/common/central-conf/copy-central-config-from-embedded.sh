#!/bin/bash
echo "copying centralConfiguration from embedded centralConfiguration folder"
cp -R /mnt/centralConfiguration-source-dir/centralConfiguration /mnt/centralConfiguration-target-dir
mkdir -p /mnt/centralConfiguration-target-dir/conf
cp -R /mnt/centralConfiguration-source-dir/conf/repository-keystore.jceks /mnt/centralConfiguration-target-dir/conf
rm -f /mnt/centralConfiguration-target/conf/deployit.conf
touch /mnt/centralConfiguration-target/conf/deployit.conf
# shellcheck disable=SC2129
echo http.port=8888 >> /mnt/centralConfiguration-target-dir/conf/deployit.conf
sed -n '/xl.spring.cloud.encrypt.key/p' /mnt/centralConfiguration-source-dir/conf/deployit.conf >> /mnt/centralConfiguration-target-dir/conf/deployit.conf
sed -n '/repository.keystore.password\=/p' /mnt/centralConfiguration-source-dir/conf/deployit.conf >> /mnt/centralConfiguration-target-dir/conf/deployit.conf
echo "Done."
