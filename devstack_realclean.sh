# realclean.sh
#!/bin/bash
echo "really clean everyhing devstack related"
echo "Assumes nothing else installed in this system. Kill if you need to review what this script does"
echo "This script starts clean Devstack locations before cleaning generic locations"

cd ~/devstack/

echo "devstack clean"
# clean.sh

echo "clean /opt/stack"
sudo rm -rf /opt/stack*

echo "clean /usr/local/bin"
sudo rm -f /usr/local/bin/*

## openSUSE has python installed by default
# echo "clean /usr/local/lib/python2.7"
# sudo rm -rf /usr/local/lib/python2.7/dist-packages/*

## No comparable zypper command
# echo "remove automatically installed packages"
# sudo apt-get autoremove
