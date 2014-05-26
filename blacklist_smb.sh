cat >> /etc/modprobe.d/50-blacklist.conf <<EOF
# Blacklist smb device in virtual machines
blacklist i2c_piix4
EOF
