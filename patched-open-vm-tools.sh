zypper in git make gcc kernel-devel wget && \
git clone https://github.com/rasa/vmware-tools-patches.git && \
cd vmware-tools-patches && \
./download-tools.sh && \
./untar-and-patch.sh && \
./compile.sh

