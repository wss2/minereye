#!/bin/bash


# sudo lvresize -l +100%FREE /dev/ubuntu-vg/ubuntu-lv
# sudo resize2fs /dev/ubuntu-vg/ubuntu-lv


# Update and Install Dependencies
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common gnupg lsb-release

# Install jq
sudo apt-get install -y jq

# Install pip3 and Python packages
sudo apt-get install -y python3-pip
pip3 install PyYAML ruamel.yaml argparse

# Install helm
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm

# Install helm diff plugin
sudo helm plugin install https://github.com/databus23/helm-diff

# Install helmfile
curl -SsL https://github.com/helmfile/helmfile/releases/download/v0.161.0/helmfile_0.161.0_linux_amd64.tar.gz -o helmfile.tar.gz
tar -zxf helmfile.tar.gz -C /tmp/
rm helmfile.tar.gz
chmod 700 /tmp/helmfile
sudo mv /tmp/helmfile /usr/local/bin/helmfile

# Install k3s
curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC="server --disable=traefik" sh -


echo "Installation complete."
