#!/data/data/com.termux/files/usr/bin/bash

# Color variables
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

echo -e "${GREEN}=== Installing required tools... ===${RESET}"
pkg update -y && pkg upgrade -y

pkg install -y nmap nikto whatweb whois dnsutils git curl wget python php openssh clang make cmake rust

# Install WhatWeb if not present
if ! command -v whatweb &> /dev/null; then
    echo -e "${RED}[!] WhatWeb not found, manual installation...${RESET}"
    git clone https://github.com/urbanadventurer/WhatWeb.git
    cd WhatWeb && chmod +x whatweb && cp whatweb $PREFIX/bin/ && cd ..
fi

clear
echo -e "${GREEN}=== DomRecon Scanner for Termux ===${RESET}"
read -p "Enter the domain to scan: " domain

# Check if domain was entered
if [[ -z "$domain" ]]; then
    echo -e "${RED}[!] No domain entered. Exiting...${RESET}"
    exit 1
fi

echo -e "${YELLOW}[*] Starting scan for: $domain${RESET}"
echo

# WHOIS information
echo -e "${GREEN}[+] WHOIS Info:${RESET}"
whois $domain | head -n 20
echo

# DNS Information
echo -e "${GREEN}[+] DNS Info:${RESET}"
dig $domain any +noall +answer
echo

# Nmap Port Scan
echo -e "${GREEN}[+] Port Scan (Nmap):${RESET}"
nmap -T4 -F $domain
echo

# WhatWeb Fingerprinting
echo -e "${GREEN}[+] Fingerprinting (WhatWeb):${RESET}"
whatweb $domain
echo

# Nikto Vulnerability Scan
echo -e "${GREEN}[+] Vulnerability Scan (Nikto):${RESET}"
nikto -h http://$domain
echo

# Option for ReconFTW installation
echo
read -p "Do you want to install and run ReconFTW for a full scan? [y/n]: " use_recon
if [[ "$use_recon" == "y" || "$use_recon" == "Y" ]]; then
    echo -e "${YELLOW}[*] Cloning and installing ReconFTW...${RESET}"
    git clone https://github.com/six2dez/reconftw ~/reconftw
    cd ~/reconftw
    chmod +x reconftw.sh
    ./reconftw.sh -i
    ./reconftw.sh -d $domain -r
    cd -
else
    echo -e "${YELLOW}[*] Skipping ReconFTW section.${RESET}"
fi

echo
echo -e "${GREEN}=== Scan completed for $domain ===${RESET}"
