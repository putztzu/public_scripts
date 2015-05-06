# This script is intended to re-size the default openSUSE GRUB2 menu so that full kernel descriptions are visible
# This script is contributed to the Community with no restrictions on use or distribution except that the terms described here must always be included
# This script is provided with no warranty and is used at the User's own risk.
# version 1.4 May Apr 2015
# Additional modifications, primarily modified background images for each distro version contributed on an ongoing basis
# Created by TSU

# Preamble
# Designed to work with openSUSE 12.3 but known to work in the distro version number in the background image, but with little modification should work for any GRUB2 and possibly GRUB bootloaders and other distros (path to theme.txt)

# Instructions
# Download this script.
# Unlike previous versions of this script, no background is included because the background no longer contains the distro version.
# open a root console and browse to the location of this script
# make executable eg (chmod +x) if necessary (should be done for you already)
# Execute the script
# The script automatically makes a backup of the previous configuration
# The new values in this script have been tested to work on practically any display but can be customized
# I recommend keeping this script in a known location (which can be run from anywhere on the system). Any Plymouth updates may undo your custom configuration, simply running this script again will re-install your modifications.

# Although the background is not changed starting with 13.2, if the User wishes to install his/her own background the following command is retained but disabled
# Simply copy your background to the same folder as this script and rename it "background_modified.png" and uncomment the following command
# Copy modified background image to where it can be used
# cp background_modified.png /boot/grub2/themes/openSUSE/


# Following lines make backup of theme.txt. Alternative could have been to point /etc/default/grub to a new file
# If you need to recover and undo the changes made by this script,
# 1. boot to emergency mode, 
# 2. open a root console, 
# 3. delete or rename the existing theme.txt 
# 4. copy theme.txt.original to theme.txt 
# 5. re-run the last line (grub2-mkconfig -o /boot/grub2/grub.cfg).

cd /boot/grub2/themes/openSUSE/
mv theme.txt theme.txt.original

# The following creates a new theme.txt with the following changes
# Re-size the menu options to 90% of the screen width
# Re-position and re-size the progress bar
# See above for instructions to restore the original configuration which has been saved as theme.txt.original

cat > theme.txt <<EOF

# openSUSE grub2 theme

desktop-image: "background.png"

title-text: ""

terminal-box: "terminal_box_*.png"
terminal-font: "Gnu Unifont Mono Regular 16"

+ boot_menu {
  left = 5%
  width = 90%
  top = 30%
  height = 50%	

  item_font = "DejaVu Sans Bold 14"
  item_color = "#fff"
  item_height = 32
  item_icon_space = 8
  item_spacing = 2

  selected_item_font = "DejaVu Sans Bold 14"
  selected_item_color= "#000"
  selected_item_pixmap_style = "select_*.png"

  icon_height = 32
  icon_width = 32

  scrollbar = true
  scrollbar_width = 20
  scrollbar_thumb = "slider_*.png"
}

+ progress_bar {
  id = "__timeout__"

  left = 10%
  width = 85%
  top = 80%
  height = 10

  font = "DejaVu Sans Regular 12"

  text_color = "#fff"
  fg_color = "#0d6967"

  bg_color = "#000"
  border_color = "#fff"

  # instead of the above colors, use pixmaps
  # bar_style = "progress_bar_*.png"
  # highlight_style = "progress_highlight_*.png"

  text = "@TIMEOUT_NOTIFICATION_LONG@"
}
EOF

# Re-make grub.cfg
grub2-mkconfig -o /boot/grub2/grub.cfg



