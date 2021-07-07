#!/bin/bash
# Add required software
apt update
apt install -y at vim mlocate net-tools zip curl wget libsasl2-modules aria2 sudo

# Backup pvemanagerlib.js
FILE=/usr/share/pve-manager/js/pvemanagerlib.js
cp $FILE $FILE.$(date +%d_%m_%Y_%Hhr_%Mm_%Ss).original

# Change Logo, Favicon, Bios Image
mkdir -p /usr/share/custom/backup
cp ./proxmox_logo.png /usr/share/custom
cp ./bootsplash.jpg /usr/share/custom
cp ./favicon-32x32.png /usr/share/custom/favicon.ico
cp ./favicon-32x32.png /usr/share/custom/logo-128.png
cp /usr/share/pve-manager/images/{favicon.ico,logo-128.png,proxmox_logo.png} /usr/share/custom/backup/
cp /usr/share/qemu-server/bootsplash.jpg /usr/share/custom/backup/
cp -f /usr/share/custom/{logo-128.png,favicon.ico,proxmox_logo.png} /usr/share/pve-manager/images/
cp -f /usr/share/custom/bootsplash.jpg /usr/share/qemu-server/

# Remove Subscription
sed -i.original -z "s/res === null || res === undefined || \!res || res\n\t\t\t.data.status.toLowerCase() \!== 'active'/false/g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js && systemctl restart pveproxy.service

# Remove Documentation
mv /usr/share/pve-docs/ /usr/share/noshow/

# Remove Title
sed -i.original "s/\[% nodename %\] - Proxmox Virtual Environment/Virtual Environment/g" /usr/share/pve-manager/index.html.tpl

# Remove Branding
sed -i.original "s/Proxmox VE Login/Server Login/g;s/Proxmox VE authentication server/Other Login (Not Implemented)/g" $FILE
sed -i.original "s/Proxmox Backup Server/Our Backup Server/g" $FILE

# Remove Help Button
(echo "/tbar.push(me.helpButton)"; echo "d"; echo "d"; echo "wq") | ex -s $FILE

# Remove Subscription Banner
(echo "/gettext('Subscriptions')"; echo "-1,+17d"; echo "wq") | ex -s $FILE

# Remove Support tab
(echo "/title: gettext('Support')"; echo "-2,+3d"; echo "i"; echo ");"; echo "."; echo "wq") | ex -s $FILE

# Remove Certificates
(echo "/gettext('Certificates')"; echo "-2,+5d"; echo "wq") | ex -s $FILE

# Remove Updates & Reposistories
(echo "/gettext('Updates')"; echo "-3,+24d"; echo "wq") | ex -s $FILE

# Remove VM Subscription
(echo "/gettext('Subscription')"; echo "-1,+5d"; echo "wq") | ex -s $FILE

# Remove Syslog
(echo "/title: 'Syslog'"; echo "-2,+6d"; echo "wq") | ex -s $FILE

# Remove Proxmox Related Labels
sed -i.original.1 "s/pve-docs/docs/g;s/Proxmox VE/Virtual/g" $FILE

# Change Grub Text
sed -i.original "s/Proxmox Virtual Environment/Virtual Server/g" /etc/default/grub

# Passthrough
sed -i.original "s/quiet/quiet intel_iommu=on/g" /etc/default/grub
cat <<EOF > /etc/modules
vfio
vfio_iommu_type1
vfio_pci
vfio_virqfd
EOF

# Change Login Message
sed -i.original "s/Proxmox/Virtual Server/g;/8006/d;/config/d" /usr/bin/pvebanner

# Apply Final Changes
update-grub

# Remove Subscription Tab
(echo "/fa-support"; echo "-2,+4d"; echo "wq") | ex -s $FILE
