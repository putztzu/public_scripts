## Setup

## Run this script in a root console (su), location not important
## This script installs prerequisites.
## When this script completes, change to a normal User (not root) and run the second script.

## Description of VM used for testing
## But this script can be run on bare metal or any other install
## BASE
## openSUSE 13.2, fully updated
## 200GB virtual disk
## 4GB RAM for install
## Virtualbox 5.0, using KVM interface (and misc other minor configs)
## If running in a VM, configure nested virtualization (VBox, or KVM)
## Windows 10 host

## Configure machine hostname in YAST > Network Settings > DNS/Hostname tab
## If you configure Wicked/Static addresses, be sure to configure DNS bound to the proper network interface
## Highly recommend reboot to lock in changes although may not be necessary

## Add openSUSE cloud repo. Although Devstack will not install OpenStack from main OpenStack repos, a few packages will still be needed. You will find below 13.2, 13.1, TW, LEAP and SLES repositories are provided. If you are not installing 13.2, then comment the following install command and uncomment the appropriate.

# openSUSE 13.2
# zypper ar -f http://download.opensuse.org/repositories/Cloud:/OpenStack:/Master/openSUSE_13.2/ Cloud:OpenStack:Master && zypper --gpg-auto-import-keys ref

# openSUSE 13.1
# zypper ar -f http://download.opensuse.org/repositories/Cloud:/OpenStack:/Master/openSUSE_13.1/ Cloud:OpenStack:Master && zypper --gpg-auto-import-keys ref

# Tumbleweed
# zypper ar -f http://download.opensuse.org/repositories/Cloud:/OpenStack:/Master/Tumbleweed/ Cloud:OpenStack:Master && zypper --gpg-auto-import-keys ref

# SLES and LEAP (until LEAP might have its own repo)
zypper ar -f http://download.opensuse.org/repositories/Cloud:/OpenStack:/Master/SLE_12/ Cloud:OpenStack:Master && zypper --gpg-auto-import-keys ref

## Install prerequisites
zypper -n in git patterns-openSUSE-lamp_server rabbitmq-server bridge-utils ebtables dstat gcc make kernel-devel

## Start and enable services
systemctl start rabbitmq-server.service
systemctl enable rabbitmq-server.service
systemctl start mysql.service
systemctl enable mysql.service
systemctl start apache2.service
systemctl enable apache2.service

## After this script has completed, change to a normal User, eg run "su $USER"
## Then run the second script
