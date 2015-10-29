## Setup

## Description of VM used for testing
## BASE
## openSUSE 13.2, fully updated
## 200GB virtual disk
## 4GB RAM for install
## Virtualbox 5.0, using KVM interface (and misc other minor configs)
## Windows 10 host

## Configure machine hostname in YAST > Network Settings > DNS/Hostname tab

## Add openSUSE cloud repo. Although Devstack will not install OpenStack from main OpenStack repos, a few packages will still be needed
zypper ar -f http://download.opensuse.org/repositories/Cloud:/OpenStack:/Master/openSUSE_13.2/ Cloud:OpenStack:Master && zypper --gpg-auto-import-keys ref

## Install prerequisites
zypper -n in git patterns-openSUSE-lamp_server rabbitmq-server bridge-utils ebtables dstat gcc make kernel-devel tree mlocate

## Clone latest Devstack to your choice location. If unedited, the location is in your User /home
su $USER
cd ~/
git clone https://github.com/openstack-dev/devstack.git

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









