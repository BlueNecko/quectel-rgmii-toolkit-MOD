#!/bin/sh
# Modified by BlueNecko to set up a proper entware environment for custom Quectel RG520F series LGA modems 
TYPE='generic'
#|---------|-----------------|
#| TARGET  | Quectel Modem   |
#| ARCH    | armv7sf-k3.2    | 
#| LOADER  | ld-linux.so.3   | 
#| GLIBC   | 2.27            | 
#|---------|-----------------|
unset LD_LIBRARY_PATH
unset LD_PRELOAD
ARCH=armv7sf-k3.2
LOADER=ld-linux.so.3
GLIBC=2.27
PRE_OPKG_PATH=$(which opkg)


if [ -n "$PRE_OPKG_PATH" ]; then
    # Automatically rename the existing opkg binary
    mv "$PRE_OPKG_PATH" "${PRE_OPKG_PATH}_old"
    echo -e "\033[32mFactory/Already existing opkg has been renamed to opkg_old.\033[0m"
else
    echo "Info: no existing opkg binary detected, proceeding with installation"
fi


echo -e '\033[32mInfo: Proceeding with main installation ...\033[0m'
# no need to create many folders. entware-opt package creates most
for folder in bin etc lib/opkg tmp var/lock
do
  if [ -d "/usrdata/opt/$folder" ]; then
    echo -e '\033[31mWarning: Folder /usrdata/opt/$folder exists!\033[0m'
    echo -e '\033[31mWarning: If something goes wrong please clean /usrdata/opt folder and try again.\033[0m'
  else
    mkdir -p /usrdata/opt/$folder
  fi
done

echo -e '\033[32mInfo: Opkg package manager deployment...\033[0m'
URL=http://bin.entware.net/${ARCH}/installer
wget $URL/opkg -O /usrdata/opt/bin/opkg
chmod 755 /usrdata/opt/bin/opkg
wget $URL/opkg.conf -O /usrdata/opt/etc/opkg.conf

echo -e '\033[32mInfo: Basic packages installation...\033[0m'
/usrdata/opt/bin/opkg update
/usrdata/opt/bin/opkg install entware-opt

# Fix for multiuser environment
chmod 777 /usrdata/opt/tmp

# Create and enable rc.unslung service
echo -e '\033[32mInfo: Create your own rc.unslung init (Entware init.d service)...\033[0m'

systemctl daemon-reload
echo -e '\033[32mInfo: Congratulations!\033[0m'
echo -e '\033[32mInfo: If there are no errors above then Entware was successfully initialized.\033[0m'
echo -e '\033[32mInfo: Add /usrdata/opt/bin & /usrdata/opt/sbin to $PATH variable\033[0m'
ln -sf /usrdata/opt/bin/opkg /bin
