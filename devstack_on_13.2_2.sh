## Setup

## This is the main install script which should be run after the first script which ensures all prerequisties are installed.

## Unlike the first script, this script should be run in a normal User(non-root) console

mkdir ~/devstack
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









