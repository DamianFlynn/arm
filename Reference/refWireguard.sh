sudo apt-get update
sudo apt-get upgrade
sudo apt-get install git python-pip python-cffi libffi-dev libssl-dev libcurl4-openssl-dev
pip install
ssh-keygen
git clone https://github.com/StreisandEffect/streisand.git && cd streisand
./util/venv-dependencies.sh ./venv
source ./venv/bin/activate
'
---
# Custom Server Configuration
#

streisand_noninteractive: true
confirmation: true

# Change this to the location of a key on the local system.
streisand_ssh_private_key: "~/.ssh/id_rsa"

vpn_clients: 5

streisand_openconnect_enabled: no
streisand_openvpn_enabled: no
streisand_shadowsocks_enabled: yes
streisand_ssh_forward_enabled: yes
# By default sshuttle is disabled because it creates a `sshuttle` user that has
# full shell privileges on the Streisand host
streisand_sshuttle_enabled: no
streisand_stunnel_enabled: no
streisand_tinyproxy_enabled: yes
streisand_tor_enabled: no
streisand_wireguard_enabled: yes

# Definitions needed for Let's Encrypt HTTPS (or TLS) certificate setup.
#
# If these are both left as empty strings, Let's Encrypt will not be set up and
# a self-signed certificate will be used instead.
#
# The domain to use for Let's Encrypt certificate.
streisand_domain_var: ""
# The admin email address for Let's Encrypt certificate registration.
streisand_admin_email_var: ""
'

deploy/streisand-local.sh --site-config global_vars/noninteractive/my-vpn-server.yml