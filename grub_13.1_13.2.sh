# This script fixes the grub menu when upgrading 13.1 > 13.2
# Original code created by User tpe


# Backing up original
cp /boot/grub2/grub.cfg /boot/grub2/original_grub_cfg
# Parse grub info file. Replace 13.1 with 13.2
sed -i 's/13.1/13.2/g' /etc/default/grub
# Re-compile grub2
grub2-mkconfig > /boot/grub2/grub.cfg
# Done
echo Done.
