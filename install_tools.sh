#!/bin/bash

set -e

echo "=================================="
echo "Updating system"
echo "=================================="

sudo apt update
sudo apt upgrade -y

echo "=================================="
echo "Installing base packages"
echo "=================================="

sudo apt install -y \
    curl \
    wget \
    openssh-server \
    gnupg

echo "=================================="
echo "Installing Docker"
echo "=================================="

curl -fsSL https://get.docker.com | sh

sudo systemctl enable docker
sudo systemctl start docker

sudo usermod -aG docker "$USER"

echo "=================================="
echo "Installing kubectl"
echo "=================================="

curl -LO "https://dl.k8s.io/release/$(curl -L -s \
https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

chmod +x kubectl
sudo mv kubectl /usr/local/bin/

echo "=================================="
echo "Installing k3d"
echo "=================================="

curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

echo "=================================="
echo "Installing ArgoCD CLI"
echo "=================================="

curl -sSL -o argocd \
https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64

chmod +x argocd
sudo mv argocd /usr/local/bin/

echo "=================================="
echo "Versions"
echo "=================================="

docker --version
kubectl version --client
k3d version
argocd version --client

echo
echo "Installation complete."
