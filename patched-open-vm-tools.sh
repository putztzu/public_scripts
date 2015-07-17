# enable the following line for openSUSE and comment out apt-get and yum commands
# zypper in git make gcc kernel-devel wget && \
#
# enable the following line for Debian, Ubuntu, Mint, other similar and comment out out zypper and yum commands
# apt-get install git make gcc wget unzip wget zip linux-headers-$(uname -r) build-essential dkms patch perl psmisc &&  \
# 
#enable the following line for Fedora, CentOS or RHEL and comment out the zypper and apt-get commands
# yum gcc glibc-headers kernel-devel kernel-headers make perl git wget && \
#
git clone https://github.com/rasa/vmware-tools-patches.git && \
cd vmware-tools-patches && \
./download-tools.sh && \
./untar-and-patch.sh && \
./compile.sh && \
echo "This software is provided free of warranty and to be used only at the User's own risk."

