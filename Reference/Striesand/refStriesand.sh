#!/bin/bash
echo "###-- Setting Frontend as Non-Interactive"
export DEBIAN_FRONTEND=noninteractive

echo "OS Update Procedure"
sudo apt-get update --assume-yes

# Skipping the Linux Agent Upate due to BUG - https://github.com/Azure/WALinuxAgent/issues/1459
echo "Block the Linux Azure Agent Update"
apt-mark hold walinuxagent

echo "OS Upgrade Procedure"
sudo apt-get upgrade --assume-yes

echo "###-- Installing Toolchain"
sudo apt-get install --assume-yes git python-pip python-cffi libffi-dev libssl-dev libcurl4-openssl-dev
pip install --upgrade pip

echo "###-- Generate a new SSH Key Pair"
whoami
ssh-keygen -f $HOME/.ssh/id_rsa -t rsa -N ''

echo "###-- Downloading Installer Repository"
git clone https://github.com/StreisandEffect/streisand.git

# Assume the Azure Public IP is valid
sed -i '/for the VPN/d' ./streisand/playbooks/roles/common/tasks/detect-public-ip.yml
sed -i '/to skip and use/d' ./streisand/playbooks/roles/common/tasks/detect-public-ip.yml
sed -i '/if you do not know/d' ./streisand/playbooks/roles/common/tasks/detect-public-ip.yml
sed -i '/Ask user to update to public IP/d' ./streisand/playbooks/roles/common/tasks/detect-public-ip.yml
sed -i '/pause/d' ./streisand/playbooks/roles/common/tasks/detect-public-ip.yml
sed -i '/{{ prompt_external_ip/d' ./streisand/playbooks/roles/common/tasks/detect-public-ip.yml
sed -i '/publish_external/d' ./streisand/playbooks/roles/common/tasks/detect-public-ip.yml


### Virtual Environment Work
echo "###-- Changing to striesand repo"
cd streisand
echo "###-- Prepare the Python Virtual Environment"
./util/venv-dependencies.sh ./venv
echo "###-- Active the Virtual Environment"
source "./venv/bin/activate"

# Create configuration for striesand installation
echo "###-- Create our Installation Configuration"
echo '                                                               ' >  global_vars/noninteractive/my-vpn-server.yml
echo '# Custom Server Configuration                                  ' >> global_vars/noninteractive/my-vpn-server.yml
echo '#                                                              ' >> global_vars/noninteractive/my-vpn-server.yml
echo '                                                               ' >> global_vars/noninteractive/my-vpn-server.yml
echo 'streisand_noninteractive: true                                 ' >> global_vars/noninteractive/my-vpn-server.yml
echo 'confirmation: true                                             ' >> global_vars/noninteractive/my-vpn-server.yml
echo '                                                               ' >> global_vars/noninteractive/my-vpn-server.yml
echo '# Change this to the location of a key on the local system.    ' >> global_vars/noninteractive/my-vpn-server.yml
echo 'streisand_ssh_private_key: "~/.ssh/id_rsa"                     ' >> global_vars/noninteractive/my-vpn-server.yml
echo '                                                               ' >> global_vars/noninteractive/my-vpn-server.yml
echo 'vpn_clients: 5                                                 ' >> global_vars/noninteractive/my-vpn-server.yml
echo '                                                               ' >> global_vars/noninteractive/my-vpn-server.yml
echo 'streisand_openconnect_enabled: no                              ' >> global_vars/noninteractive/my-vpn-server.yml
echo 'streisand_openvpn_enabled: no                                  ' >> global_vars/noninteractive/my-vpn-server.yml
echo 'streisand_shadowsocks_enabled: yes                             ' >> global_vars/noninteractive/my-vpn-server.yml
echo 'streisand_ssh_forward_enabled: yes                             ' >> global_vars/noninteractive/my-vpn-server.yml
echo '# By default sshuttle is disabled, it creates a `sshuttle` user' >> global_vars/noninteractive/my-vpn-server.yml
echo '# that has full shell privileges on the Streisand host         ' >> global_vars/noninteractive/my-vpn-server.yml
echo 'streisand_sshuttle_enabled: no                                 ' >> global_vars/noninteractive/my-vpn-server.yml
echo 'streisand_stunnel_enabled: no                                  ' >> global_vars/noninteractive/my-vpn-server.yml
echo 'streisand_tinyproxy_enabled: yes                               ' >> global_vars/noninteractive/my-vpn-server.yml
echo 'streisand_tor_enabled: no                                      ' >> global_vars/noninteractive/my-vpn-server.yml
echo 'streisand_wireguard_enabled: yes                               ' >> global_vars/noninteractive/my-vpn-server.yml
echo '                                                               ' >> global_vars/noninteractive/my-vpn-server.yml
echo '# Definitions needed for Lets Encrypt HTTPS certificate setup. ' >> global_vars/noninteractive/my-vpn-server.yml
echo '#                                                              ' >> global_vars/noninteractive/my-vpn-server.yml
echo '# If these are both left as empty strings, Lets Encrypt will   ' >> global_vars/noninteractive/my-vpn-server.yml
echo '# not be set up and a self-signed certificate will be used     ' >> global_vars/noninteractive/my-vpn-server.yml
echo '#                                                              ' >> global_vars/noninteractive/my-vpn-server.yml
echo '# The domain to use for Lets Encrypt certificate.              ' >> global_vars/noninteractive/my-vpn-server.yml
echo 'streisand_domain_var: ""                                       ' >> global_vars/noninteractive/my-vpn-server.yml
echo '# The admin email address for Lets Encrypt certificate reg     ' >> global_vars/noninteractive/my-vpn-server.yml
echo 'streisand_admin_email_var: ""                                  ' >> global_vars/noninteractive/my-vpn-server.yml
echo '                                                               ' >> global_vars/noninteractive/my-vpn-server.yml

echo "###-- Start the Installation"
deploy/streisand-local.sh --site-config global_vars/noninteractive/my-vpn-server.yml

echo "###-- Done!"