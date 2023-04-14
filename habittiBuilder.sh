#Download debian live image if not already downloaded
if [ -e debian.iso ]; then
  echo "debian.iso exists, skipping download."
else
  wget https://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/debian-live-11.6.0-amd64-gnome.iso -O debian.iso
fi
#Check if abitti filesystem exists
if [ -e filesystem.squashfs ]; then
  echo "filesystem.squashfs exists, proceeding."
else
  echo "filesystem.squashfs does not exist. Please extract it from the Abitti image provided by YTL."
  exit 1
fi
#Unsquashfs abitti
sudo unsquashfs ./filesystem.squashfs
sudo rm ./filesystem.squashfs
#Extract debian iso
sudo xorriso -osirrox on -indev debian.iso -extract / debian
#Required for system to boot correctly (idk wtf this does)
sudo cp -r ./5.10.0-21-amd64 ./squashfs-root/lib/modules/
sudo cp -r ./5.10.0-20-amd64 ./squashfs-root/lib/modules/
#Allow dhcp
sudo sed -i 's/also require swap-server;//' ./squashfs-root/etc/dhcp/dhclient.conf
#Remove firewall
sudo find ./squashfs-root/etc/digabi/firewall.d -type f -exec sed -i 's/DROP/ACCEPT/g' {} +
sudo sed -i 's/DROP/ACCEPT/g' ./squashfs-root/lib/live/config/0001-iptables-set-drop-policy
sudo sed -i 's/^/#/' ./squashfs-root/usr/local/sbin/digabi-firewall-check
sudo sed -i '/REJECT/d' ./squashfs-root/etc/digabi/firewall.d/9000-log-and-reject.v4.conf
#Change release name to distinguish from unmodified Abitti
sudo sed -i 's/ABITTI/HABITTI/' ./squashfs-root/etc/digabios-release
#Add root user with the name "habitti"
echo "\nhabitti::0:0:root:/root:/bin/bash" | sudo tee -a ./squashfs-root/etc/passwd
#Add user digabi to sudoers (default abitti user)
echo "\ndigabi	ALL=(ALL:ALL) ALL" | sudo tee -a ./squashfs-root/etc/passwd
#Allow user digabi to use terminal
sudo sed -i 's/false/bash/' ./squashfs-root/lib/live/config/0031-lock-user-account
sudo chmod o+rx ./squashfs-root/usr/bin/terminator
#Disable mount backup check
sudo sed -i 's/^/#/' ./squashfs-root/usr/local/sbin/mount-backup
#Create modified squashfs filesystem
sudo mksquashfs ./squashfs-root ./filesystem.squashfs
#Move squashfs filesystem to debian folder
sudo mv ./filesystem.squashfs ./debian/live
#Modify grub config
sudo sed -i '13,30d' ./debian/boot/grub/grub.cfg
sudo sed -i 's/menuentry "Debian GNU\/Linux Live (kernel 5.10.0-20-amd64)" {/menuentry "hAbitti" --unrestricted {/' ./debian/boot/grub/grub.cfg
sudo sed -i 's/linux  \/live\/vmlinuz-5.10.0-20-amd64 boot=live components splash quiet "${loopback}"/linux  \/live\/vmlinuz-5.10.0-20-amd64 digabi=grub boot=live components nosplash debug config net.ifnames=0 union=overlay modules_load=i2c_hid,i2c-hid-acpi live-media-timeout=5 live-media-path=\/live panic=0 digabidata modprobe.blacklist=b44,b43,b43legacy,ssb,brcmsmac,bcma "${loopback}"/' ./debian/boot/grub/grub.cfg
#Modify isolinux menu.cfg
sudo sed -i 's/SAY "Booting Debian GNU\/Linux Live (kernel 5.10.0-20-amd64)..."/SAY "Booting hAbitti"/' ./debian/isolinux/menu.cfg
sudo sed -i 's/APPEND initrd=\/live\/initrd.img-5.10.0-20-amd64 boot=live components splash quiet/APPEND initrd=\/live\/initrd.img-5.10.0-20-amd64 boot=live components nosplash debug/' ./debian/isolinux/menu.cfg
sudo sed -i 's/Debian GNU\/Linux Live (kernel 5.10.0-20-amd64)/hAbitti/' ./debian/isolinux/menu.cfg
sudo sed -i 's/MENU title Main Menu/MENU title hAbitti/' ./debian/isolinux/menu.cfg
sudo sed -i '8,410d' ./debian/isolinux/menu.cfg
#Modify isolinux stdmenu.cfg
sudo sed -i 's/menu background splash.png/menu background ""/' ./debian/isolinux/stdmenu.cfg
#Build iso
sudo xorriso -outdev ./abitti-mod.iso -volid "d-live 11.6.0 st amd64" -padding 0 -compliance no_emul_toc -map ./debian / -chmod 0755 / -- -boot_image isolinux dir=/isolinux -boot_image any next -boot_image any efi_path=boot/grub/efi.img -boot_image isolinux partition_entry=gpt_basdat
echo -e "\e[32;1mdone\e[0m"