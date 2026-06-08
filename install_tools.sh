#!/usr/bin/env bash

set -Eeuo pipefail

# ------------------------------------------------------------------------------
# Colors
# ------------------------------------------------------------------------------
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

LINE="${GREEN}================================================================================${NC}"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# ------------------------------------------------------------------------------
# Helpers
# ------------------------------------------------------------------------------
section() {
    echo -e "\n${LINE}"
    echo -e "${YELLOW}$1${NC}"
}

success() {
    echo -e "✅ ${YELLOW}$1${NC}"
}

info() {
    echo -e "📦 ${YELLOW}$1${NC}"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

append_if_missing() {
    local line="$1"
    local file="$2"

    touch "$file"
    grep -qxF "$line" "$file" || echo "$line" >> "$file"
}

trap 'echo -e "${RED}❌ Error on line $LINENO${NC}"' ERR

# ------------------------------------------------------------------------------
# OS Check
# ------------------------------------------------------------------------------
if ! grep -qiE "ubuntu|debian" /etc/os-release; then
    echo "Unsupported distribution"
    exit 1
fi

# ------------------------------------------------------------------------------
# Update system
# ------------------------------------------------------------------------------
section "Update system"

sudo apt update
sudo apt upgrade -y

# ------------------------------------------------------------------------------
# Base packages
# ------------------------------------------------------------------------------
section "Install base packages"

PACKAGES=(
    curl
    wget
    git
    vim
    openssh-server
    gnupg
    zsh
    software-properties-common
    apt-transport-https
    ca-certificates
)

sudo apt install -y "${PACKAGES[@]}"

success "Base packages ready"

# ------------------------------------------------------------------------------
# Vagrant
# ------------------------------------------------------------------------------
section "Install Vagrant"

if ! command_exists vagrant; then
    wget -qO- https://apt.releases.hashicorp.com/gpg \
        | sudo gpg --dearmor \
        -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(. /etc/os-release && echo "${VERSION_CODENAME}") main" \
        | sudo tee /etc/apt/sources.list.d/hashicorp.list >/dev/null

    sudo apt update
    sudo apt install -y vagrant
fi

success "Vagrant ready"

# ------------------------------------------------------------------------------
# VirtualBox
# ------------------------------------------------------------------------------
section "Install VirtualBox"

if ! command_exists virtualbox; then

    sudo rm -f /usr/share/keyrings/virtualbox.gpg

    wget -qO- https://www.virtualbox.org/download/oracle_vbox_2016.asc \
        | gpg --dearmor \
        | sudo tee /usr/share/keyrings/virtualbox.gpg >/dev/null

    DISTRO_CODENAME=$(lsb_release -cs)

    echo \
        "deb [arch=amd64 signed-by=/usr/share/keyrings/virtualbox.gpg] https://download.virtualbox.org/virtualbox/debian ${DISTRO_CODENAME} contrib" \
        | sudo tee /etc/apt/sources.list.d/virtualbox.list >/dev/null

    sudo apt update
    sudo apt install -y virtualbox-7.1
fi

success "VirtualBox ready"

# ------------------------------------------------------------------------------
# Docker
# ------------------------------------------------------------------------------
section "Install Docker"

if ! command_exists docker; then
    curl -fsSL https://get.docker.com | sh
    sudo usermod -aG docker "$USER"
fi

success "Docker ready"

# ------------------------------------------------------------------------------
# k3d
# ------------------------------------------------------------------------------
section "Install k3d"

if ! command_exists k3d; then
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
fi

success "k3d ready"

# ------------------------------------------------------------------------------
# kubectl
# ------------------------------------------------------------------------------
section "Install kubectl"

if ! command_exists kubectl; then
    VERSION=$(curl -Ls https://dl.k8s.io/release/stable.txt)

    curl -LO \
        "https://dl.k8s.io/release/${VERSION}/bin/linux/amd64/kubectl"

    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
fi

success "kubectl ready"

# ------------------------------------------------------------------------------
# ArgoCD CLI
# ------------------------------------------------------------------------------
section "Install ArgoCD CLI"

if ! command_exists argocd; then
    ARGOCD_VERSION=$(curl -s https://api.github.com/repos/argoproj/argo-cd/releases/latest \
        | grep tag_name \
        | cut -d '"' -f4)

    curl -sSL \
        -o argocd-linux-amd64 \
        "https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-linux-amd64"

    chmod +x argocd-linux-amd64
    sudo mv argocd-linux-amd64 /usr/local/bin/argocd
fi

success "ArgoCD ready"

# ------------------------------------------------------------------------------
# Helm
# ------------------------------------------------------------------------------
section "Install Helm"

if ! command_exists helm; then
    curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

success "Helm ready"

# ------------------------------------------------------------------------------
# Oh My Zsh
# ------------------------------------------------------------------------------
section "Install Oh My Zsh"

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no CHSH=no \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

success "Oh My Zsh ready"

# ------------------------------------------------------------------------------
# Zsh Plugins
# ------------------------------------------------------------------------------
section "Install Zsh plugins"

declare -A PLUGINS=(
    [zsh-autosuggestions]="https://github.com/zsh-users/zsh-autosuggestions"
    [zsh-syntax-highlighting]="https://github.com/zsh-users/zsh-syntax-highlighting.git"
)

for plugin in "${!PLUGINS[@]}"; do
    if [ ! -d "${ZSH_CUSTOM}/plugins/${plugin}" ]; then
        git clone "${PLUGINS[$plugin]}" \
            "${ZSH_CUSTOM}/plugins/${plugin}"
    fi
done

success "Plugins ready"

# ------------------------------------------------------------------------------
# Configure .zshrc
# ------------------------------------------------------------------------------
section "Configure .zshrc"

if grep -q '^plugins=(' ~/.zshrc; then
    sed -i \
        's/^plugins=(.*)$/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' \
        ~/.zshrc
fi

ALIASES=(
    'alias cl="clear"'
    'alias ls="ls --color=auto"'
    'alias rmf="rm -rf"'
    'alias k="kubectl"'
)

for alias_cmd in "${ALIASES[@]}"; do
    append_if_missing "$alias_cmd" ~/.zshrc
done

success ".zshrc configured"

# ------------------------------------------------------------------------------
# Set Zsh as default shell
# ------------------------------------------------------------------------------
section "Set Zsh as default shell"

ZSH_PATH=$(command -v zsh)

if [ "$SHELL" != "$ZSH_PATH" ]; then
    chsh -s "$ZSH_PATH"
fi

success "Zsh is the default shell"

# ------------------------------------------------------------------------------
# Vim configuration
# ------------------------------------------------------------------------------
section "Configure Vim"

if [ ! -f "$HOME/.vimrc" ]; then
cat <<'EOF' > "$HOME/.vimrc"
set encoding=utf-8
set nocompatible
syntax on
set autoindent
set number
set mouse=a
set shiftwidth=4
set tabstop=4
set scrolloff=3
set incsearch
set ignorecase
set ruler
set backspace=2
colorscheme desert
EOF
fi

success "Vim configured"

# ------------------------------------------------------------------------------
# Disable KVM (nested VM environments)
# ------------------------------------------------------------------------------
section "Disable KVM (optional)"

if sudo modprobe -r kvm_intel 2>/dev/null || \
   sudo modprobe -r kvm_amd 2>/dev/null; then

    sudo modprobe -r kvm_amd || true
    sudo modprobe -r kvm_intel || true
    sudo modprobe -r kvm || true
    success "KVM disabled"
else
    echo -e "${YELLOW}KVM not loaded or cannot be disabled${NC}"
fi

# ------------------------------------------------------------------------------
# Done
# ------------------------------------------------------------------------------
echo -e "\n🎉 ${GREEN}Setup completed successfully!${NC}"

