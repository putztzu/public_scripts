# Based on steps at https://www.codeweavers.com/support/wiki/linux/faq/OpenSUSE
# Although the original steps are for LEAP, IMO can be tried on any supported version of openSUSE

# IMPORTANT! - The last line that creates the symbolic link for libgnutils has been updated to current package as of day this script was created but is sure to change, so will likely need to be modified each time this script is run and you may not know the exact library name until after it has been installed. Post in the openSUSE Technical Forums if you don't understand how to resolve this.

zypper install libcapi20-3-32bit fontconfig-32bit libgphoto2-6-32bit libgsm1-32bit liblcms2-2-32bit libopenal1-32bit libOSMesa9-32bit sane-backends-32bit libXcomposite1-32bit libXinerama1-32bit libxslt1-32bit libXxf86vm1-32bit && \
zypper install http://crossover.codeweavers.com/redirect/crossover.rpm && \
zypper install libgnutls30-32bit && \
zypper install http://download.opensuse.org/repositories/home:/giordanoboschetti/openSUSE_Tumbleweed/i586/libmpg123-0-1.22.1-4.7.i586.rpm && \
ln -s /usr/lib/libgnutls.so.30.6.3 /usr/lib/libgnutls.so && \
Finished Installing
