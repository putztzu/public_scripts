## This script installs docker integrated with devstack
sudo -n zypper in docker
sudo systemctl start docker
sudo systemctl enable docker

## Prepare Nova-Docker
## Official Guide python packages unnecessary because openSUSE installs by default
sudo mkdir -p /opt/stack
sudo git clone https://git.openstack.org/openstack/nova-docker /opt/stack/nova-docker
cd /opt/stack/nova-docker
# Check out a different version if not using master, ie
# sudo git checkout stable/kilo && sudo git pull --ff-only origin stable/kilo
sudo pip install . #The linecache2 error appears to be benign



## Clone latest Devstack to your choice location. These are only the install files which you can remove later if you wish. Devstack will actually be installed into /opt.  If unedited, the location is in your User /home
# su $USER
mkdir ~/devstack
git clone https://github.com/openstack-dev/devstack.git ~/devstack
cd ~/devstack


## Prepare your Devstack Answer file. Do not alter without good reason
cat >> local.conf << EOF
VIRT_DRIVER=novadocker.virt.docker.DockerDriver

# Introduce glance to docker images
\$GLANCE_API_CONF
[DEFAULT]
container_formats=ami,ari,aki,bare,ovf,ova,docker

# Configure nova to use the nova-docker driver--Neutron is the default as of kilo
\$NOVA_CONF
[DEFAULT]
compute_driver=novadocker.virt.docker.DockerDriver
EOF

# Configure the Answer file for stack.sh
# IMPORTANT! - change "password" in following to your password
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

