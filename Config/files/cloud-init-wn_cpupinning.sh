#!/bin/bash
if [ ${cpu_pinning} == true ]; then
    curl --fail -H "Authorization: Bearer Oracle" -L0 http://169.254.169.254/opc/v2/instance/metadata/oke_init_script | base64 --decode >/var/run/oke-init.sh
    bash /var/run/oke-init.sh --kubelet-extra-args "--cpu-manager-policy=static --cpu-manager-reconcile-period=5s --reserved-cpus=0-${cpu} --feature-gates='CPUManager=true'"
else
    curl --fail -H "Authorization: Bearer Oracle" -L0 http://169.254.169.254/opc/v2/instance/metadata/oke_init_script | base64 --decode >/var/run/oke-init.sh
    bash /var/run/oke-init.sh
fi
if [ ${hp} == true ]; then 
    sudo sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ hugepagesz=1G default_hugepagesz=1G hugepages=${hp_size}"/' /etc/default/grub
    sudo grub2-mkconfig -o /boot/grub2/grub.cfg
fi
wget https://docs.oracle.com/iaas/Content/Resources/Assets/secondary_vnic_all_configure.sh
chmod 777 secondary_vnic_all_configure.sh
sudo ./secondary_vnic_all_configure.sh -c
sudo cp /secondary_vnic_all_configure.sh /usr/local/sbin
sudo bash -c 'cat <<EOF > /etc/systemd/system/secondary_vnic.service
[Unit]
Description=Setting the secondary vnic
After=default.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/local/sbin/secondary_vnic_all_configure.sh -c

[Install]
WantedBy=multi-user.target
EOF'
sudo systemctl enable secondary_vnic.service
#sudo reboot
#oci compute instance update --launch-options {\"network-type\":\"VFIO\"} --force