#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Directories and paths
BIN_DIR="/usr/local/bin"
TMP_DIR="$(mktemp -d)"

cleanup() {
    echo -e "${YELLOW}[!] Cleaning up temporary files...${NC}"
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

print_banner() {
    clear
    echo -e "${GREEN}"
    echo "======================================"
    echo "    Bug Bounty Tools Auto Installer   "
    echo "======================================"
    echo -e "${NC}"
}

run_command() {
    echo -e "${YELLOW}[*] $1${NC}"
    shift
    if ! "$@"; then
        echo -e "${RED}[ERROR] Failed: $1${NC}"
        exit 1
    fi
}

install_essential_packages() {
    run_command "Updating system packages..." sudo apt update && sudo apt upgrade -y
    run_command "Installing essential packages..." sudo apt install -y git curl wget python3 python3-pip snapd zip unzip golang-go
    run_command "Installing snaps (go and chromium)..." sudo snap install go --classic
    run_command "" sudo snap install chromium
}

download_and_install_binary() {
    local url=$1
    local archive_name=$2
    local extracted_binary=$3
    local dest_name=${4:-$extracted_binary}

    cd "$TMP_DIR"
    run_command "Downloading $archive_name..." wget -q --show-progress "$url" -O "$archive_name"

    case "$archive_name" in
        *.zip) run_command "Extracting $archive_name..." unzip -q "$archive_name" ;;
        *.tar.gz|*.tgz) run_command "Extracting $archive_name..." tar -xzf "$archive_name" ;;
        *) echo "Unknown archive format for $archive_name"; exit 1 ;;
    esac

    run_command "Installing $dest_name to $BIN_DIR..." sudo mv "$extracted_binary" "$BIN_DIR/$dest_name"
    run_command "Setting executable permission for $dest_name..." sudo chmod +x "$BIN_DIR/$dest_name"

    rm -f "$archive_name"
}

install_from_go() {
    local pkg=$1
    local bin_name=$2

    run_command "Installing $bin_name via go install..." go install "$pkg@latest"
    run_command "Copying $bin_name to $BIN_DIR..." sudo cp "$HOME/go/bin/$bin_name" "$BIN_DIR/$bin_name"
}

print_banner
install_essential_packages

echo ""
echo -e "${YELLOW}Choose installation method for all tools:${NC}"
echo "1) Install all tools via binaries (download & move)"
echo "2) Install all tools via go install / apt / pip"
read -rp "Enter choice (1 or 2): " method_choice

if [[ "$method_choice" == "1" ]]; then
    echo -e "${GREEN}Installing all tools using binaries...${NC}"

    cd "$TMP_DIR"

    # Katana
    download_and_install_binary "https://github.com/projectdiscovery/katana/releases/download/v1.1.3/katana_1.1.3_linux_amd64.zip" "katana_1.1.3_linux_amd64.zip" "katana"

    # Gau (getallurls) - corrected to linux amd64 archive (was darwin)
    download_and_install_binary "https://github.com/lc/gau/releases/download/v2.2.4/gau_2.2.4_linux_amd64.tar.gz" "gau_2.2.4_linux_amd64.tar.gz" "gau"

    # waybackurls
    download_and_install_binary "https://github.com/tomnomnom/waybackurls/releases/download/v0.1.0/waybackurls-linux-amd64-0.1.0.tgz" "waybackurls-linux-amd64-0.1.0.tgz" "waybackurls"

    # deduplicate (compile from source)
    run_command "Cloning deduplicate repo..." git clone --depth 1 https://github.com/nytr0gen/deduplicate.git "$TMP_DIR/deduplicate"
    cd deduplicate
    run_command "Building deduplicate binary..." go build -o deduplicate main.go
    sudo mv deduplicate "$BIN_DIR/"
    sudo chmod +x "$BIN_DIR/deduplicate"
    cd "$TMP_DIR"
    rm -rf deduplicate

    # gowitness
    run_command "Downloading gowitness..." wget -q --show-progress https://github.com/sensepost/gowitness/releases/download/3.0.5/gowitness-3.0.5-linux-amd64
    sudo mv gowitness-3.0.5-linux-amd64 "$BIN_DIR/gowitness"
    sudo chmod +x "$BIN_DIR/gowitness"

    # dalfox via snap
    run_command "Installing dalfox via snap..." sudo snap install dalfox

    # ffuf
    download_and_install_binary "https://github.com/ffuf/ffuf/releases/download/v2.1.0/ffuf_2.1.0_linux_amd64.tar.gz" "ffuf_2.1.0_linux_amd64.tar.gz" "ffuf"

    # httpx
    download_and_install_binary "https://github.com/projectdiscovery/httpx/releases/download/v1.7.0/httpx_1.7.0_linux_amd64.zip" "httpx_1.7.0_linux_amd64.zip" "httpx"

    # kiterunner
    run_command "Downloading kiterunner..." wget -q --show-progress https://github.com/assetnote/kiterunner/releases/download/v1.0.2/kiterunner_1.0.2_linux_amd64.tar.gz
    tar -xzf kiterunner_1.0.2_linux_amd64.tar.gz
    sudo mv kr "$BIN_DIR/kr"
    sudo chmod +x "$BIN_DIR/kr"
    rm -f kiterunner_1.0.2_linux_amd64.tar.gz

    # Nikto (clone repo)
    run_command "Cloning Nikto repository..." git clone --depth 1 https://github.com/sullo/nikto.git "$TMP_DIR/nikto"

    # sqlmap (clone repo)
    run_command "Cloning sqlmap repository..." git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git "$TMP_DIR/sqlmap"

elif [[ "$method_choice" == "2" ]]; then
    echo -e "${GREEN}Installing all tools via go install / apt / pip...${NC}"

    # Ensure GOPATH/bin is in PATH
    export PATH="$HOME/go/bin:$PATH"

    install_from_go "github.com/projectdiscovery/katana/cmd/katana" "katana"
    install_from_go "github.com/lc/gau/v2/cmd/gau" "gau"
    install_from_go "github.com/tomnomnom/waybackurls" "waybackurls"
    install_from_go "github.com/nytr0gen/deduplicate" "deduplicate"
    install_from_go "github.com/sensepost/gowitness" "gowitness"
    install_from_go "github.com/hahwul/dalfox/v2" "dalfox"
    install_from_go "github.com/ffuf/ffuf/v2" "ffuf"
    install_from_go "github.com/projectdiscovery/httpx/cmd/httpx" "httpx"

    # kiterunner binary (no go install available)
    cd "$TMP_DIR"
    run_command "Downloading kiterunner..." wget -q --show-progress https://github.com/assetnote/kiterunner/releases/download/v1.0.2/kiterunner_1.0.2_linux_amd64.tar.gz
    tar -xzf kiterunner_1.0.2_linux_amd64.tar.gz
    sudo mv kr "$BIN_DIR/kr"
    sudo chmod +x "$BIN_DIR/kr"
    rm -f kiterunner_1.0.2_linux_amd64.tar.gz

    # Nikto (clone repo)
    run_command "Cloning Nikto repository..." git clone --depth 1 https://github.com/sullo/nikto.git "$TMP_DIR/nikto"

    # sqlmap (clone repo)
    run_command "Cloning sqlmap repository..." git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git "$TMP_DIR/sqlmap"

else
    echo -e "${RED}[ERROR] Invalid choice! Exiting.${NC}"
    exit 1
fi

# Additional tools installation via apt & snap
run_command "Installing arjun via apt..." sudo apt install -y arjun
run_command "Installing cewl via apt..." sudo apt install -y cewl
run_command "Installing feroxbuster via snap..." sudo snap install feroxbuster

# lostools installation via pip
cd "$TMP_DIR"
run_command "Cloning lostools repository..." git clone --depth 1 https://github.com/coffinxp/lostools.git
cd lostools
run_command "Installing lostools python dependencies..." pip3 install --user -r requirements.txt

echo -e "${GREEN}"
echo "======================================"
echo "   Installation Complete! Enjoy!      "
echo "======================================"
echo -e "${NC}"
