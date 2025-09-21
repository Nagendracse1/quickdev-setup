#!/bin/bash

# DevEnv Setup Tool Installer
# This script installs the macOS developer environment setup tool globally

set -e

TOOL_NAME="quickdev-setup"
SCRIPT_PATH="$(pwd)/setup.sh"
SCRIPT_URL="https://raw.githubusercontent.com/Nagendracse1/quickdev-setup/main/setup.sh"

# Determine best installation directory
if [[ -d "/opt/homebrew/bin" && ":$PATH:" == *":/opt/homebrew/bin:"* ]]; then
    INSTALL_DIR="/opt/homebrew/bin"
elif [[ -d "/usr/local/bin" ]]; then
    INSTALL_DIR="/usr/local/bin"
else
    INSTALL_DIR="/usr/local/bin"  # Will create if needed
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NONE='\033[0m'

echo -e "${BLUE}🚀 QuickDev Setup${NONE}"
echo "================================"

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}❌ This tool is designed for macOS only${NONE}"
    exit 1
fi

# Function to install from local file
install_local() {
    if [ ! -f "$SCRIPT_PATH" ]; then
        echo -e "${RED}❌ setup.sh not found in current directory${NONE}"
        exit 1
    fi
    
    echo -e "${YELLOW}📦 Installing from local file...${NONE}"
    
    # Create install directory if it doesn't exist
    if [ ! -d "$INSTALL_DIR" ]; then
        echo -e "${YELLOW}📁 Creating $INSTALL_DIR directory...${NONE}"
        sudo mkdir -p "$INSTALL_DIR"
    fi
    
    # Create executable copy
    sudo cp "$SCRIPT_PATH" "$INSTALL_DIR/$TOOL_NAME"
    sudo chmod +x "$INSTALL_DIR/$TOOL_NAME"
    
    echo -e "${GREEN}✅ $TOOL_NAME installed successfully!${NONE}"
}

# Function to install from GitHub (when available)
install_remote() {
    echo -e "${YELLOW}📡 Downloading from GitHub...${NONE}"
    
    # Create install directory if it doesn't exist
    if [ ! -d "$INSTALL_DIR" ]; then
        echo -e "${YELLOW}📁 Creating $INSTALL_DIR directory...${NONE}"
        sudo mkdir -p "$INSTALL_DIR"
    fi
    
    if command -v curl &> /dev/null; then
        sudo curl -fsSL "$SCRIPT_URL" -o "$INSTALL_DIR/$TOOL_NAME"
    elif command -v wget &> /dev/null; then
        sudo wget -q "$SCRIPT_URL" -O "$INSTALL_DIR/$TOOL_NAME"
    else
        echo -e "${RED}❌ Neither curl nor wget found. Please install one of them.${NONE}"
        exit 1
    fi
    
    sudo chmod +x "$INSTALL_DIR/$TOOL_NAME"
    echo -e "${GREEN}✅ $TOOL_NAME installed successfully!${NONE}"
}

# Function to uninstall
uninstall() {
    local found=false
    
    # Check multiple possible installation locations
    local install_paths=("/opt/homebrew/bin/$TOOL_NAME" "/usr/local/bin/$TOOL_NAME")
    
    for path in "${install_paths[@]}"; do
        if [ -f "$path" ]; then
            echo -e "${YELLOW}📍 Found $TOOL_NAME at: $path${NONE}"
            if sudo rm "$path"; then
                echo -e "${GREEN}✅ Removed $path${NONE}"
                found=true
            else
                echo -e "${RED}❌ Failed to remove $path${NONE}"
            fi
        fi
    done
    
    if [ "$found" = true ]; then
        echo -e "${GREEN}🎉 $TOOL_NAME uninstalled successfully!${NONE}"
        echo ""
        echo -e "${BLUE}Optional cleanup:${NONE}"
        echo "  # Remove configuration files (if any)"
        echo "  rm -rf ~/.quickdev-config.json"
        echo "  rm -rf ~/.quickdev-plugins/"
        echo ""
        echo -e "${YELLOW}💡 Note: Installed packages and tools remain on your system${NONE}"
    else
        echo -e "${YELLOW}⚠️ $TOOL_NAME not found in standard locations${NONE}"
        echo -e "${BLUE}You can manually check these locations:${NONE}"
        for path in "${install_paths[@]}"; do
            echo "  $path"
        done
    fi
}

# Main installation logic
case "${1:-install}" in
    "install")
        if [ -f "$SCRIPT_PATH" ]; then
            install_local
        else
            echo -e "${YELLOW}⚠️ Local setup.sh not found, trying remote installation...${NONE}"
            install_remote
        fi
        
        echo ""
        echo -e "${GREEN}🎉 Installation complete!${NONE}"
        echo -e "${BLUE}Usage:${NONE}"
        echo "  $TOOL_NAME                    # Run the setup tool"
        echo "  $TOOL_NAME --help            # Show help"
        echo ""
        echo -e "${YELLOW}💡 You can now run '$TOOL_NAME' from anywhere!${NONE}"
        ;;
        
    "uninstall")
        uninstall
        ;;
        
    "--help"|"-h")
        echo -e "${BLUE}QuickDev Setup Installer${NONE}"
        echo ""
        echo "Usage:"
        echo "  $0 [install]     # Install QuickDev Setup globally (default)"
        echo "  $0 uninstall     # Remove QuickDev Setup from system"
        echo "  $0 --help        # Show this help message"
        echo ""
        echo "Examples:"
        echo "  $0                              # Install QuickDev Setup"
        echo "  $0 install                      # Install QuickDev Setup"  
        echo "  $0 uninstall                    # Uninstall QuickDev Setup"
        echo ""
        echo "Remote installation:"
        echo "  # Install"
        echo "  curl -fsSL https://raw.githubusercontent.com/Nagendracse1/quickdev-setup/main/install.sh | bash"
        echo "  # Uninstall"  
        echo "  curl -fsSL https://raw.githubusercontent.com/Nagendracse1/quickdev-setup/main/install.sh | bash -s uninstall"
        ;;
        
    *)
        echo -e "${RED}❌ Unknown option: $1${NONE}"
        echo "Use '--help' for usage information"
        exit 1
        ;;
esac