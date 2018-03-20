#!/usr/bin/env bash

echo "Downloading binary archive"
curl -o hab-0.20-x86_64-linux.tar.gz -L https://api.bintray.com/content/habitat/stable/linux/x86_64/hab-%24latest-x86_64-linux.tar.gz?bt_package=hab-x86_64-linux

echo "Extracting..."
tar -xzf hab-0.20-x86_64-linux.tar.gz

echo "Putting it on the path"
sudo mv hab-**/hab /usr/local/bin

echo "Making executable"
sudo chmod a+x /usr/local/bin/hab


echo 'database_host = ""' >> sparc_user.toml
echo 'database_username = ""' >> sparc_user.toml
echo 'database_password = ""' >> sparc_user.toml

echo "**************************************"
echo "You are all set."
echo "I've created a sparc_user.toml file incase you need to customize some of the runtime parameters"
echo "To run SPARC do:"
echo 'sudo env "PATH=$PATH" hab start chrisortman/sparc-request'
echo ""
echo "By default we try to connect to "
echo "MYSQL on 33.33.33.1 as root/root"
echo "But you can change it in sparc_user.toml and do this:"
echo 'sudo env HAB_SPARC_REQUEST="$(cat sparc_user.toml)" "PATH=\$PATH" hab start chrisortman/sparc-request'
