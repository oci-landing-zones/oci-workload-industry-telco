#!/bin/bash
curl --fail -H "Authorization: Bearer Oracle" -L0 http://169.254.169.254/opc/v2/instance/metadata/oke_init_script | base64 --decode >/var/run/oke-init.sh
bash /var/run/oke-init.sh
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