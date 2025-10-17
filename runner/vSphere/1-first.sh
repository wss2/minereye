#!/bin/bash
set -euo pipefail

# ==========================================================
# Bootstrap ambiente K3s + Helm + Helmfile (versione aggiornata)
# Testato su Ubuntu/Debian 22.04+
# ==========================================================

# Espandi volume root se necessario (solo ext4)
# sudo lvresize -l +100%FREE /dev/ubuntu-vg/ubuntu-lv && sudo resize2fs /dev/ubuntu-vg/ubuntu-lv

echo "[1/8] Aggiornamento pacchetti..."
sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release jq software-properties-common

echo "[2/8] Installazione Python e librerie YAML..."
if ! command -v python3 &>/dev/null; then
    sudo apt-get install -y python3 python3-pip
fi
python3 -m pip install --upgrade pip
python3 -m pip install -q PyYAML ruamel.yaml argparse

echo "[3/8] Installazione Helm..."
if ! command -v helm &>/dev/null; then
    curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
else
    echo "Helm già installato: $(helm version --short)"
fi

echo "[4/8] Installazione plugin Helm Diff..."
if ! helm plugin list | grep -q "diff"; then
    helm plugin install https://github.com/databus23/helm-diff
else
    echo "Plugin helm-diff già presente"
fi

echo "[5/8] Installazione Helmfile..."
if ! command -v helmfile &>/dev/null; then
    VERSION=$(curl -s https://api.github.com/repos/helmfile/helmfile/releases/latest | jq -r .tag_name)
    curl -sSL "https://github.com/helmfile/helmfile/releases/download/${VERSION}/helmfile_${VERSION#v}_linux_amd64.tar.gz" -o /tmp/helmfile.tar.gz
    tar -zxf /tmp/helmfile.tar.gz -C /tmp/
    sudo mv /tmp/helmfile /usr/local/bin/helmfile
    sudo chmod +x /usr/local/bin/helmfile
    rm /tmp/helmfile.tar.gz
else
    echo "Helmfile già installato: $(helmfile --version)"
fi

echo "[6/8] Installazione o aggiornamento K3s..."
if ! systemctl is-active --quiet k3s; then
    curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC="server --disable=traefik" sh -
else
    echo "K3s già in esecuzione"
fi

echo "[7/8] Verifica versioni installate..."
helm version
helmfile --version
k3s --version | head -n1

echo "[8/8] Pulizia pacchetti inutili..."
sudo apt-get autoremove -y
sudo apt-get clean

echo "Installazione completata con successo."
