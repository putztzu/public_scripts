
## Clone latest Devstack to your choice location. These are only the install files which you can remove later if you wish. Devstack will actually be installed into /opt.  If unedited, the location is in your User /home
su $USER
mkdir ~/devstack
git clone https://github.com/openstack-dev/devstack.git ~/devstack
cd ~/devstack


## Prepare your Devstack Answer file. Replace each "password" with your own passwords
cat >> localrc << EOF
VIRT_DRIVER=novadocker.virt.docker.DockerDriver

# Introduce glance to docker images
$GLANCE_API_CONFG
[DEFAULT]
container_formats=ami,ari,aki,bare,ovf,ova,docker

# Configure nova to use the nova-docker driver--Neutron is the default as of kilo
$NOVA_CONF
[DEFAULT]
compute_driver=novadocker.virt.docker.DockerDriver

ADMIN_PASSWORD=qwerty
MYSQL_PASSWORD=qwerty
RABBIT_PASSWORD=qwerty
SERVICE_PASSWORD=qwerty
SERVICE_TOKEN=tokentoken
FLAT_INTERFACE=br100
LOGFILE=\$DEST/logs/stack.sh.log
EOF

## Workaround for openSUSE "hostname" bug
## https://bugzilla.opensuse.org/show_bug.cgi?ie=952517
sed -i 's/hostname -f/hostname/g' lib/tls

## Install Devstack
FORCE=yes ./stack.sh









