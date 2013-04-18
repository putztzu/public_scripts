# This script is intended to re-size the default openSUSE 12.3 GRUB2 menu so that the full kernel descriptions are visible
# Unresolved is the minor issue that the 12.3 logo is visible in the expanded menu space. Suspect is because it is part of the background image.
# This script is contributed to the Community with no restrictions on use or distribution except that the terms cescribed here must always be included
# This script is provided with no warranty and is used at the User's own risk.
# version 1.0 Apr 2013
# Created by TSU

# Preamble
# Designed to work with openSUSE 12.3, but with little modification should work for any GRUB2 and possibly GRUB bootloaders and other distros (path to theme.txt)

# Instructions
# Download this script
# open a root console and browse to the location of this script
# make executable eg (chmod +x)
# Execute the script

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
# Decrease the size of the fonts slightly (14 > 12)
# Similar changes to the progress bar
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
  top = 25%
  height = 50%	

  item_font = "DejaVu Sans Bold 12"
  item_color = "#fff"
  item_height = 32
  item_icon_space = 8
  item_spacing = 2

  selected_item_font = "DejaVu Sans Bold 12"
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
  top = 85%
  height = 20
  width = 80%

  font = "DejaVu Sans Regular 10"

  text_color = "#000"
  fg_color = "#98ce57"

  bg_color = "#fff"
  border_color = "#fff"

  # instead of the above colors, use pixmaps
  # bar_style = "progress_bar_*.png"
  # highlight_style = "progress_highlight_*.png"

  text = "@TIMEOUT_NOTIFICATION_LONG@"
}
EOF

# Re-make grub.cfg
grub2-mkconfig -o /boot/grub2/grub.cfg
!






