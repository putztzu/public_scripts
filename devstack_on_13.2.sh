## Setup

## Run this script in a root console (su), location not important
EE Extra Reminder! - Edit the commands below that set your passwords!

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

## Add openSUSE cloud repo. Although Devstack will not install OpenStack from main OpenStack repos, a few packages will still be needed
zypper ar -f http://download.opensuse.org/repositories/Cloud:/OpenStack:/Master/openSUSE_13.2/ Cloud:OpenStack:Master && zypper --gpg-auto-import-keys ref

## Install prerequisites
zypper -n in git patterns-openSUSE-lamp_server rabbitmq-server bridge-utils ebtables dstat gcc make kernel-devel tree mlocate

## Clone latest Devstack to your choice location. If unedited, the location is in your User /home
su $USER
git clone https://github.com/openstack-dev/devstack.git ~/devstack
cd ~/devstack


## Prepare your Devstack Answer file. Replace each "password" with your own passwords
cat >> localrc << EOF
ADMIN_PASSWORD=password
MYSQL_PASSWORD=password
RABBIT_PASSWORD=password
SERVICE_PASSWORD=password
SERVICE_TOKEN=tokentoken
FLAT_INTERFACE=br100
LOGFILE=\$DEST/logs/stack.sh.log
EOF

## Workaround for openSUSE "hostname" bug
## https://bugzilla.opensuse.org/show_bug.cgi?ie=952517
sed -i 's/hostname -f/hostname/g' lib/tls

## Install Devstack
FORCE=yes ./stack.sh









