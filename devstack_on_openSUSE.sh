## Setup

## Run this script with root permissions from any location.
## Recommend run this file with sudo particularly if you intend to invoke 2 scripts with a single command, following examples so that your non-root account is specified
## examples
# sudo devstack_on_openSUSE.sh && devstack_on_openSUSE.2.sh
# sudo devstack_on_openSUSE.sh && devstack_on_openSUSE.2_docker.sh


## This script installs prerequisites.
## When this script completes, change to a normal User (not root) and run the second script if you didn't automatically invoke using one of the above examples.

## Description of VM used for testing
## But this script can be run on bare metal or any other install
## BASE
## Extensively tested on 13.2 and LEAP
## 200GB virtual disk, minimal
## 4GB RAM for install
## Virtualbox 5.0, using KVM interface (and misc other minor configs)
## VMware Workstation 11
## If running in a VM, configure nested virtualization (VBox, or KVM)
## Windows 10 host

## Configure machine hostname in YAST > Network Settings > DNS/Hostname tab
## If you configure Wicked/Static addresses, be sure to configure DNS bound to the proper network interface
## Highly recommend reboot to lock in changes although may not be necessary

## Add openSUSE cloud repo. Although Devstack will not install OpenStack from main OpenStack repos, a few packages will still be needed. You will find below 13.2, 13.1, TW, LEAP and SLES repositories are provided. If you are not installing 13.2, then comment the following install command and uncomment the appropriate.

# openSUSE 13.2
zypper ar -f http://download.opensuse.org/repositories/Cloud:/OpenStack:/Master/openSUSE_13.2/ Cloud:OpenStack:Master && zypper --gpg-auto-import-keys ref

# openSUSE 13.1
# zypper ar -f http://download.opensuse.org/repositories/Cloud:/OpenStack:/Master/openSUSE_13.1/ Cloud:OpenStack:Master && zypper --gpg-auto-import-keys ref

# Tumbleweed
# zypper ar -f http://download.opensuse.org/repositories/Cloud:/OpenStack:/Master/Tumbleweed/ Cloud:OpenStack:Master && zypper --gpg-auto-import-keys ref

# SLES and LEAP (until LEAP might have its own repo)
# zypper ar -f http://download.opensuse.org/repositories/Cloud:/OpenStack:/Master/SLE_12/ Cloud:OpenStack:Master && zypper --gpg-auto-import-keys ref

## Install prerequisites
zypper -n in git patterns-openSUSE-lamp_server rabbitmq-server bridge-utils ebtables dstat gcc make kernel-devel

## Start and enable services
sudo systemctl start rabbitmq-server.service
sudo systemctl enable rabbitmq-server.service
sudo systemctl start mysql.service
sudo systemctl enable mysql.service

## After this script has completed, change to a normal User, eg run "su $USER"
## Then run the second script
