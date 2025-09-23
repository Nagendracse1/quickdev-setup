#!/bin/bash

# A setup script to automate development environment setup on macOS.
# This script uses interactive menus and includes failure handling with a retry option.

# --- Color Definitions (for better UI) ---
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_CYAN='\033[0;36m'
C_BLUE='\033[0;34m'
C_PURPLE='\033[0;35m'
C_WHITE='\033[1;37m'
C_GRAY='\033[0;90m'
C_BOLD='\033[1m'
C_DIM='\033[2m'

# Bright colors
C_BRIGHT_GREEN='\033[1;32m'
C_BRIGHT_BLUE='\033[1;34m'
C_BRIGHT_CYAN='\033[1;36m'
C_BRIGHT_YELLOW='\033[1;33m'
C_BRIGHT_RED='\033[1;31m'
C_BRIGHT_PURPLE='\033[1;35m'

# Background colors
C_BG_GREEN='\033[42m'
C_BG_RED='\033[41m'
C_BG_YELLOW='\033[43m'

C_NONE='\033[0m' # No Color

# --- Helper Functions ---
function clear_screen() {
    clear
    echo -e "${C_BOLD}${C_BRIGHT_CYAN}╔══════════════════════════════════════════════════════════╗${C_NONE}"
    echo -e "${C_BOLD}${C_BRIGHT_CYAN}║${C_NONE}     ${C_BRIGHT_WHITE}🚀 QuickDev Setup - Developer Environment 🚀${C_NONE}     ${C_BOLD}${C_BRIGHT_CYAN}║${C_NONE}"
    echo -e "${C_BOLD}${C_BRIGHT_CYAN}╚══════════════════════════════════════════════════════════╝${C_NONE}\n"
}

function check_existing_installation() {
    local tool=$1
    local check_command=$2
    
    if eval "$check_command" &> /dev/null; then
        echo "${C_GREEN}[already installed]${C_NONE}"
        return 0
    fi
    return 1
}

function prompt_for_version() {
    local lang_name=$1
    local default_version=$2
    echo -e "${C_YELLOW}Available versions for $lang_name:${C_NONE}"
    case $lang_name in
        "Node.js") echo "Popular versions: 18, 20, 21 (LTS recommended)" ;;
        "Ruby") echo "Popular versions: 3.1.4, 3.2.2, 3.3.0" ;;
        "Go") echo "Popular versions: 1.20, 1.21, 1.22" ;;
        "Java") echo "Popular versions: 11, 17, 21 (LTS recommended)" ;;
        "PHP") echo "Popular versions: 7.4, 8.1, 8.2, 8.3 (latest recommended)" ;;
    esac
    read -p "Enter the desired version for $lang_name (default: $default_version): " version
    echo "${version:-$default_version}"
}

function ask_yes_no() {
    local prompt="$1"
    local default="${2:-}"
    local response

    if [[ "$default" == "y" ]]; then
        prompt="$prompt [Y/n]: "
    elif [[ "$default" == "n" ]]; then
        prompt="$prompt [y/N]: "
    else
        prompt="$prompt [y/n]: "
    fi

    while true; do
        read -p "$prompt" response
        response=${response:-$default}
        case "$response" in
            [yY][eE][sS]|[yY]) return 0 ;;
            [nN][oO]|[nN]) return 1 ;;
            *) echo -e "${C_RED}Invalid input. Please enter 'y' or 'n'.${C_NONE}" ;;
        esac
    done
}

function add_zsh_plugin() {
    local plugin_name="$1"
    local zshrc_file="$HOME/.zshrc"
    
    if [ -f "$zshrc_file" ]; then
        # Check if plugin is already in plugins list
        if ! grep -q "plugins=.*$plugin_name" "$zshrc_file"; then
            # Check if plugins line exists
            if grep -q "^plugins=" "$zshrc_file"; then
                # Add plugin to existing plugins line
                sed -i.bak "s/plugins=(\(.*\))/plugins=(\1 $plugin_name)/" "$zshrc_file"
                echo -e "${C_GREEN}Added $plugin_name to zsh plugins${C_NONE}"
            else
                # Add plugins line with the plugin
                echo "plugins=($plugin_name)" >> "$zshrc_file"
                echo -e "${C_GREEN}Added plugins line with $plugin_name to ~/.zshrc${C_NONE}"
            fi
        else
            echo -e "${C_GREEN}$plugin_name already in zsh plugins${C_NONE}"
        fi
        
        # Add manual source lines for immediate availability (fallback)
        case "$plugin_name" in
            "zsh-autosuggestions")
                if ! grep -q "zsh-autosuggestions.zsh" "$zshrc_file"; then
                    echo "" >> "$zshrc_file"
                    echo "# zsh-autosuggestions plugin sourcing" >> "$zshrc_file"
                    echo "if [ -f \"\${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh\" ]; then" >> "$zshrc_file"
                    echo "    source \"\${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh\"" >> "$zshrc_file"
                    echo "fi" >> "$zshrc_file"
                fi
                ;;
            "zsh-syntax-highlighting")
                if ! grep -q "zsh-syntax-highlighting.zsh" "$zshrc_file"; then
                    echo "" >> "$zshrc_file"
                    echo "# zsh-syntax-highlighting plugin sourcing" >> "$zshrc_file"
                    echo "if [ -f \"\${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh\" ]; then" >> "$zshrc_file"
                    echo "    source \"\${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh\"" >> "$zshrc_file"
                    echo "fi" >> "$zshrc_file"
                fi
                ;;
        esac
    else
        echo -e "${C_YELLOW}~/.zshrc not found, please add '$plugin_name' to plugins manually${C_NONE}"
    fi
}



function add_to_path_if_missing() {
    local path_to_add="$1"
    local zshrc_file="$HOME/.zshrc"
    
    # Check if the PATH is already in .zshrc
    if [ -f "$zshrc_file" ] && grep -Fq "$path_to_add" "$zshrc_file"; then
        echo -e "${C_GREEN}PATH already configured${C_NONE}"
        return 0
    fi
    
    # Add PATH to .zshrc
    echo "export PATH=\"$path_to_add:\$PATH\"" >> "$zshrc_file"
    echo -e "${C_GREEN}Added to PATH in ~/.zshrc${C_NONE}"
}

function test_github_ssh() {
    echo -e "${C_CYAN}🔍 Testing GitHub SSH connections for all accounts...${C_NONE}"
    echo -e "${C_BRIGHT_YELLOW}═══════════════════════════════════════════════════${C_NONE}"
    
    # First, add all SSH keys to the agent
    echo -e "\n${C_BLUE}🔐 Adding SSH keys to agent...${C_NONE}"
    eval "$(ssh-agent -s)" >/dev/null 2>&1
    
    # Find and add all SSH keys
    local keys_added=0
    for key_file in ~/.ssh/id_ed25519 ~/.ssh/id_ed25519_* ~/.ssh/id_rsa ~/.ssh/id_rsa_*; do
        if [ -f "$key_file" ] && [[ "$key_file" != *.pub ]]; then
            if ssh-add "$key_file" >/dev/null 2>&1; then
                echo -e "${C_GREEN}✓ Added: $(basename "$key_file")${C_NONE}"
                keys_added=$((keys_added + 1))
            fi
        fi
    done
    
    if [ $keys_added -eq 0 ]; then
        echo -e "${C_YELLOW}⚠ No SSH keys found to add${C_NONE}"
    else
        echo -e "${C_GREEN}✓ Added ${keys_added} SSH key(s) to agent${C_NONE}"
    fi
    
    local all_passed=true
    local account_count=0
    
    # Test default GitHub connection
    echo -e "\n${C_BRIGHT_CYAN}Testing Default Account:${C_NONE}"
    echo -e "${C_GRAY}Command: ssh -T git@github.com${C_NONE}"
    local default_result=$(ssh -T git@github.com 2>&1)
    if echo "$default_result" | grep -q "successfully authenticated"; then
        local github_user=$(echo "$default_result" | grep "Hi" | cut -d' ' -f2 | tr -d '!')
        echo -e "${C_BG_GREEN}${C_WHITE} ✓ SUCCESS ${C_NONE} ${C_BRIGHT_GREEN}Authenticated as: ${github_user}${C_NONE}"
        
        # Show associated email from git config
        local git_email=$(git config --global user.email 2>/dev/null)
        local git_name=$(git config --global user.name 2>/dev/null)
        if [[ -n "$git_email" ]]; then
            echo -e "   ${C_GRAY}Git Config: ${git_name} <${git_email}>${C_NONE}"
        fi
        
        # Show SSH key fingerprint
        if [ -f ~/.ssh/id_ed25519.pub ]; then
            local key_fingerprint=$(ssh-keygen -lf ~/.ssh/id_ed25519.pub 2>/dev/null | cut -d' ' -f2)
            echo -e "   ${C_GRAY}SSH Key: ed25519 ${key_fingerprint:0:16}...${C_NONE}"
        elif [ -f ~/.ssh/id_rsa.pub ]; then
            local key_fingerprint=$(ssh-keygen -lf ~/.ssh/id_rsa.pub 2>/dev/null | cut -d' ' -f2)
            echo -e "   ${C_GRAY}SSH Key: rsa ${key_fingerprint:0:16}...${C_NONE}"
        fi
    else
        echo -e "${C_BG_RED}${C_WHITE} ✗ FAILED ${C_NONE} ${C_BRIGHT_RED}Authentication failed${C_NONE}"
        echo -e "   ${C_GRAY}Error: $(echo "$default_result" | head -1)${C_NONE}"
        all_passed=false
    fi
    account_count=$((account_count + 1))
    
    # Check SSH config for additional accounts
    if [ -f ~/.ssh/config ]; then
        local additional_hosts=$(grep -E "^Host\s+github-" ~/.ssh/config | awk '{print $2}')
        
        for host in $additional_hosts; do
            if [[ -n "$host" ]]; then
                account_count=$((account_count + 1))
                local account_name=$(echo "$host" | sed 's/github-//')
                
                echo -e "\n${C_BRIGHT_CYAN}Testing ${account_name^} Account:${C_NONE}"
                echo -e "${C_GRAY}Command: ssh -T git@${host}${C_NONE}"
                
                local host_result=$(ssh -T "git@${host}" 2>&1)
                if echo "$host_result" | grep -q "successfully authenticated"; then
                    local github_user=$(echo "$host_result" | grep "Hi" | cut -d' ' -f2 | tr -d '!')
                    echo -e "${C_BG_GREEN}${C_WHITE} ✓ SUCCESS ${C_NONE} ${C_BRIGHT_GREEN}Authenticated as: ${github_user}${C_NONE}"
                    
                    # Show associated git config for this account
                    if [ -f ~/.gitconfig-${account_name} ]; then
                        local account_email=$(grep "email" ~/.gitconfig-${account_name} | cut -d'=' -f2 | xargs)
                        local account_user=$(grep "name" ~/.gitconfig-${account_name} | cut -d'=' -f2 | xargs)
                        echo -e "   ${C_GRAY}Git Config: ${account_user} <${account_email}>${C_NONE}"
                        echo -e "   ${C_GRAY}Directory: ~/${account_name}/${C_NONE}"
                    fi
                    
                    # Show SSH key fingerprint for this account
                    if [ -f ~/.ssh/id_ed25519_${account_name}.pub ]; then
                        local key_fingerprint=$(ssh-keygen -lf ~/.ssh/id_ed25519_${account_name}.pub 2>/dev/null | cut -d' ' -f2)
                        echo -e "   ${C_GRAY}SSH Key: ed25519 ${key_fingerprint:0:16}...${C_NONE}"
                    fi
                else
                    echo -e "${C_BG_RED}${C_WHITE} ✗ FAILED ${C_NONE} ${C_BRIGHT_RED}Authentication failed${C_NONE}"
                    echo -e "   ${C_GRAY}Error: $(echo "$host_result" | head -1)${C_NONE}"
                    all_passed=false
                fi
            fi
        done
    fi
    
    # Summary
    echo -e "\n${C_BRIGHT_YELLOW}═══════════════════════════════════════════════════${C_NONE}"
    if [ "$all_passed" = true ]; then
        echo -e "${C_BG_GREEN}${C_WHITE} 🎉 ALL ACCOUNTS WORKING ${C_NONE} ${C_BRIGHT_GREEN}Found ${account_count} working Git account(s)${C_NONE}"
    else
        echo -e "${C_BG_RED}${C_WHITE} ⚠️  SOME ACCOUNTS FAILED ${C_NONE} ${C_BRIGHT_RED}Check the failed accounts above${C_NONE}"
    fi
    
    # Show SSH agent status
    echo -e "\n${C_BRIGHT_CYAN}SSH Agent Status:${C_NONE}"
    if ssh-add -l >/dev/null 2>&1; then
        local loaded_keys=$(ssh-add -l | wc -l | xargs)
        echo -e "${C_GREEN}✓ SSH agent running with ${loaded_keys} key(s) loaded${C_NONE}"
        ssh-add -l | while read line; do
            echo -e "   ${C_GRAY}${line}${C_NONE}"
        done
    else
        echo -e "${C_YELLOW}⚠ SSH agent not running or no keys loaded${C_NONE}"
        echo -e "${C_GRAY}Run: ssh-add ~/.ssh/id_ed25519 (or your key file)${C_NONE}"
    fi
    
    # Show manual test commands
    echo -e "\n${C_BRIGHT_CYAN}Manual Test Commands:${C_NONE}"
    echo -e "${C_WHITE}Default account: ${C_GRAY}ssh -T git@github.com${C_NONE}"
    
    if [ -f ~/.ssh/config ]; then
        local additional_hosts=$(grep -E "^Host\s+github-" ~/.ssh/config | awk '{print $2}')
        for host in $additional_hosts; do
            if [[ -n "$host" ]]; then
                local account_name=$(echo "$host" | sed 's/github-//')
                echo -e "${C_WHITE}${account_name^} account: ${C_GRAY}ssh -T git@${host}${C_NONE}"
            fi
        done
    fi
    
    # Show SSH key management commands
    echo -e "\n${C_BRIGHT_CYAN}SSH Key Management Commands:${C_NONE}"
    echo -e "${C_WHITE}Add all keys to agent: ${C_GRAY}ssh-add ~/.ssh/id_ed25519 ~/.ssh/id_ed25519_*${C_NONE}"
    echo -e "${C_WHITE}List loaded keys: ${C_GRAY}ssh-add -l${C_NONE}"
    echo -e "${C_WHITE}Remove all keys: ${C_GRAY}ssh-add -D${C_NONE}"
    
    if [ "$all_passed" = false ]; then
        echo -e "\n${C_YELLOW}💡 Troubleshooting tips:${C_NONE}"
        echo -e "${C_WHITE}1. Add SSH keys to GitHub: ${C_CYAN}https://github.com/settings/keys${C_NONE}"
        echo -e "${C_WHITE}2. Check SSH agent: ${C_GRAY}ssh-add -l${C_NONE}"
        echo -e "${C_WHITE}3. Add keys to agent: ${C_GRAY}ssh-add ~/.ssh/id_ed25519_*${C_NONE}"
        echo -e "${C_WHITE}4. Test manually with commands above${C_NONE}"
        return 1
    fi
    
    return 0
}

function run_with_retry() {
    local task_name="$1"
    shift
    local command_to_run=("$@")

    while true; do
        echo -e "\n${C_CYAN}▶ Running: ${task_name}...${C_NONE}"
        
        if output=$("${command_to_run[@]}" 2>&1); then
            echo "$output"
            echo -e "${C_GREEN}✔ Success:${C_NONE} ${task_name} completed."
            return 0
        else
            local exit_code=$?
            echo "$output"
            echo -e "${C_RED}✖ Error:${C_NONE} ${task_name} failed with exit code $exit_code."
            if ask_yes_no "Do you want to retry this step?" "y"; then
                echo "Retrying..."
            else
                echo -e "${C_YELLOW}Skipping failed step.${C_NONE}"
                return 1
            fi
        fi
    done
}

function check_and_install_brew() {
    echo -e "\n--- ${C_CYAN}Homebrew Setup${C_NONE} ---"
    if ! command -v brew &> /dev/null; then
        echo "Homebrew not found. Installing..."
        run_with_retry "Installing Homebrew" /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add to shell profile
        if [[ -f ~/.zshrc ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
        fi
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        echo -e "${C_GREEN}Homebrew is already installed.${C_NONE}"
        run_with_retry "Updating Homebrew" brew update
    fi
}

# --- Installation Functions for Individual Languages ---
function install_node() {
    if check_existing_installation "nvm" "command -v nvm"; then
        echo "nvm already installed"
        return 0
    fi
    
    if ! run_with_retry "Installing nvm (Node Version Manager)" bash -c "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash"; then
        return 1
    fi
    
    # Source nvm
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    local NODE_VERSION=$(prompt_for_version "Node.js" "20")
    run_with_retry "Installing Node.js $NODE_VERSION" nvm install $NODE_VERSION
    nvm alias default $NODE_VERSION
    
    # Install Yarn package manager
    if command -v npm &> /dev/null; then
        echo -e "${C_YELLOW}Installing Yarn package manager...${C_NONE}"
        if run_with_retry "Installing Yarn globally" npm install -g yarn; then
            echo -e "${C_GREEN}✅ Yarn installed successfully!${C_NONE}"
            # Verify yarn installation
            if command -v yarn &> /dev/null; then
                local yarn_version=$(yarn --version 2>/dev/null)
                echo -e "${C_CYAN}Yarn version: $yarn_version${C_NONE}"
            fi
        else
            echo -e "${C_YELLOW}⚠️ Yarn installation failed, but Node.js is ready${C_NONE}"
        fi
    else
        echo -e "${C_YELLOW}⚠️ npm not available, skipping Yarn installation${C_NONE}"
    fi
}

function install_ruby() {
    if check_existing_installation "rbenv" "command -v rbenv"; then
        echo "rbenv already installed"
    else
        if ! run_with_retry "Installing rbenv and ruby-build" brew install rbenv ruby-build; then
            return 1
        fi
        echo "if which rbenv > /dev/null; then eval \"\$(rbenv init -)\"; fi" >> ~/.zshrc
    fi
    
    eval "$(rbenv init -)"
    local RUBY_VERSION=$(prompt_for_version "Ruby" "3.2.2")
    run_with_retry "Installing Ruby $RUBY_VERSION" rbenv install $RUBY_VERSION
    rbenv global $RUBY_VERSION
}

function install_go() {
    echo -e "${C_YELLOW}Available versions for Go:${C_NONE}"
    echo "Popular versions: 1.20, 1.21, 1.22"
    echo "Note: For latest Go, just use 'go' (without version)"
    read -p "Enter the desired version for Go (default: latest): " GO_VERSION
    
    # Use default version handling
    if [[ -z "$GO_VERSION" || "$GO_VERSION" == "latest" ]]; then
        GO_PACKAGE="go"
        GO_VERSION="latest"
    else
        GO_PACKAGE="go@$GO_VERSION"
    fi
    
    # Check if Go is already installed
    if command -v go &> /dev/null; then
        echo -e "${C_GREEN}Go is already installed.${C_NONE}"
        go version
        return 0
    fi
    
    # Check if specific version is installed via brew
    if [[ "$GO_VERSION" != "latest" ]] && brew list "go@$GO_VERSION" &> /dev/null 2>&1; then
        echo -e "${C_GREEN}Go $GO_VERSION is already installed via brew.${C_NONE}"
        # Add Go to PATH if not already there
        if ! command -v go &> /dev/null; then
            add_to_path_if_missing "/opt/homebrew/opt/go@$GO_VERSION/bin"
            echo -e "${C_YELLOW}Go PATH added to ~/.zshrc. Please restart your terminal.${C_NONE}"
        fi
        return 0
    fi
    
    if run_with_retry "Installing Go $GO_VERSION" brew install "$GO_PACKAGE"; then
        # Add Go to PATH if it's a versioned install
        if [[ "$GO_VERSION" != "latest" ]]; then
            add_to_path_if_missing "/opt/homebrew/opt/go@$GO_VERSION/bin"
        fi
        echo -e "${C_GREEN}Go $GO_VERSION installed successfully!${C_NONE}"
        echo -e "${C_YELLOW}Please restart your terminal or run: source ~/.zshrc${C_NONE}"
    fi
}

function install_java() {
    local JAVA_VERSION=$(prompt_for_version "Java" "17")
    # Check if specific Java version is already installed
    if brew list "openjdk@$JAVA_VERSION" &> /dev/null; then
        echo -e "${C_GREEN}OpenJDK $JAVA_VERSION is already installed.${C_NONE}"
        # Add Java to PATH if not already there
        if ! command -v java &> /dev/null || ! java -version 2>&1 | grep -q "openjdk"; then
            add_to_path_if_missing "/opt/homebrew/opt/openjdk@$JAVA_VERSION/bin"
            if ! grep -q "JAVA_HOME.*openjdk@$JAVA_VERSION" ~/.zshrc 2>/dev/null; then
                echo "export JAVA_HOME=\"/opt/homebrew/opt/openjdk@$JAVA_VERSION/libexec/openjdk.jdk/Contents/Home\"" >> ~/.zshrc
            fi
            echo -e "${C_YELLOW}Java PATH and JAVA_HOME added to ~/.zshrc. Please restart your terminal.${C_NONE}"
        fi
        return 0
    fi
    
    if run_with_retry "Installing OpenJDK $JAVA_VERSION" brew install "openjdk@$JAVA_VERSION"; then
        if run_with_retry "Linking OpenJDK $JAVA_VERSION" sudo ln -sfn "/opt/homebrew/opt/openjdk@$JAVA_VERSION/libexec/openjdk.jdk" /Library/Java/JavaVirtualMachines/openjdk.jdk; then
            # Add Java to PATH
            add_to_path_if_missing "/opt/homebrew/opt/openjdk@$JAVA_VERSION/bin"
            if ! grep -q "JAVA_HOME.*openjdk@$JAVA_VERSION" ~/.zshrc 2>/dev/null; then
                echo "export JAVA_HOME=\"/opt/homebrew/opt/openjdk@$JAVA_VERSION/libexec/openjdk.jdk/Contents/Home\"" >> ~/.zshrc
            fi
            echo -e "${C_YELLOW}Java PATH and JAVA_HOME added to ~/.zshrc. Please restart your terminal.${C_NONE}"
        fi
    fi
}

function install_php() {
    local PHP_VERSION=$(prompt_for_version "PHP" "8.3")
    
    # Check if specific PHP version is already installed
    if brew list "php@$PHP_VERSION" &> /dev/null 2>&1; then
        echo -e "${C_GREEN}PHP $PHP_VERSION is already installed.${C_NONE}"
        # Add PHP to PATH if not already there
        if ! command -v php &> /dev/null || ! php --version 2>&1 | grep -q "PHP $PHP_VERSION"; then
            add_to_path_if_missing "/opt/homebrew/opt/php@$PHP_VERSION/bin"
            add_to_path_if_missing "/opt/homebrew/opt/php@$PHP_VERSION/sbin"
            echo -e "${C_YELLOW}PHP PATH added to ~/.zshrc. Please restart your terminal.${C_NONE}"
        fi
        return 0
    elif command -v php &> /dev/null; then
        local current_version=$(php --version 2>/dev/null | head -n1 | cut -d' ' -f2 | cut -d'.' -f1,2)
        echo -e "${C_GREEN}PHP $current_version is already installed (system default).${C_NONE}"
        return 0
    fi
    
    if run_with_retry "Installing PHP $PHP_VERSION" brew install "php@$PHP_VERSION"; then
        # Add PHP to PATH
        add_to_path_if_missing "/opt/homebrew/opt/php@$PHP_VERSION/bin"
        add_to_path_if_missing "/opt/homebrew/opt/php@$PHP_VERSION/sbin"
        
        echo -e "${C_GREEN}PHP $PHP_VERSION installed successfully!${C_NONE}"
        echo -e "${C_YELLOW}PHP PATH added to ~/.zshrc. Please restart your terminal.${C_NONE}"
        echo -e "${C_CYAN}You can now use: php, composer, pear, pecl${C_NONE}"
    fi
}

# --- Main Setup Functions with Menus ---
function setup_language_runtimes() {
    clear_screen
    echo -e "${C_BRIGHT_CYAN}┌─────────────────────────────────────────┐${C_NONE}"
    echo -e "${C_BRIGHT_CYAN}│${C_NONE} 💻 ${C_BRIGHT_WHITE}Setup Language Runtimes${C_NONE}           ${C_BRIGHT_CYAN}│${C_NONE}"
    echo -e "${C_BRIGHT_CYAN}└─────────────────────────────────────────┘${C_NONE}"
    # Use individual variables instead of associative array for better compatibility
    local installed_node=""
    local installed_ruby=""
    local installed_go=""
    local installed_java=""
    
    while true; do
        # Check current status dynamically
        local node_status=""
        local ruby_status=""
        local go_status=""
        local java_status=""
        local php_status=""
        
        if command -v node &> /dev/null; then
            local node_version=$(node --version 2>/dev/null)
            node_status="${C_BG_GREEN}${C_WHITE} ✓ ${C_NONE}${C_BRIGHT_GREEN} ${node_version}${C_NONE}"
        elif command -v nvm &> /dev/null; then
            node_status="${C_BRIGHT_YELLOW}[${C_WHITE}nvm ready${C_BRIGHT_YELLOW}]${C_NONE}"
        else
            node_status="${C_GRAY}[${C_WHITE}not installed${C_GRAY}]${C_NONE}"
        fi
        
        if command -v ruby &> /dev/null; then
            local ruby_version=$(ruby --version 2>/dev/null | cut -d' ' -f2)
            ruby_status="${C_BG_GREEN}${C_WHITE} ✓ ${C_NONE}${C_BRIGHT_GREEN} v${ruby_version}${C_NONE}"
        elif command -v rbenv &> /dev/null; then
            ruby_status="${C_BRIGHT_YELLOW}[${C_WHITE}rbenv ready${C_BRIGHT_YELLOW}]${C_NONE}"
        else
            ruby_status="${C_GRAY}[${C_WHITE}not installed${C_GRAY}]${C_NONE}"
        fi
        
        if command -v go &> /dev/null; then
            local go_version=$(go version 2>/dev/null | cut -d' ' -f3)
            go_status="${C_BG_GREEN}${C_WHITE} ✓ ${C_NONE}${C_BRIGHT_GREEN} ${go_version}${C_NONE}"
        else
            go_status="${C_GRAY}[${C_WHITE}not installed${C_GRAY}]${C_NONE}"
        fi
        
        if command -v java &> /dev/null; then
            local java_version=$(java -version 2>&1 | head -n1 | cut -d'"' -f2)
            java_status="${C_BG_GREEN}${C_WHITE} ✓ ${C_NONE}${C_BRIGHT_GREEN} v${java_version}${C_NONE}"
        else
            java_status="${C_GRAY}[${C_WHITE}not installed${C_GRAY}]${C_NONE}"
        fi
        
        if command -v php &> /dev/null; then
            local php_version=$(php --version 2>/dev/null | head -n1 | cut -d' ' -f2)
            php_status="${C_BG_GREEN}${C_WHITE} ✓ ${C_NONE}${C_BRIGHT_GREEN} v${php_version}${C_NONE}"
        else
            php_status="${C_GRAY}[${C_WHITE}not installed${C_GRAY}]${C_NONE}"
        fi
        
        echo -e "\n${C_BRIGHT_YELLOW}🔧 Select a language to install:${C_NONE}"
        echo -e "${C_BRIGHT_BLUE}1.${C_NONE} 🟢 Node.js (via nvm) ${node_status}"
        echo -e "${C_BRIGHT_BLUE}2.${C_NONE} 💎 Ruby (via rbenv)  ${ruby_status}"
        echo -e "${C_BRIGHT_BLUE}3.${C_NONE} 🐹 Go               ${go_status}"
        echo -e "${C_BRIGHT_BLUE}4.${C_NONE} ☕ Java (OpenJDK)   ${java_status}"
        echo -e "${C_BRIGHT_BLUE}5.${C_NONE} 🐘 PHP              ${php_status}"
        echo -e "${C_BRIGHT_BLUE}6.${C_NONE} ✅ ${C_BRIGHT_GREEN}Done with languages${C_NONE}"
        
        read -p "Enter your choice [1-6]: " choice
        
        case $choice in
            1) if install_node; then installed_node="${C_GREEN}[installed]${C_NONE}"; fi ;;
            2) if install_ruby; then installed_ruby="${C_GREEN}[installed]${C_NONE}"; fi ;;
            3) if install_go; then installed_go="${C_GREEN}[installed]${C_NONE}"; fi ;;
            4) if install_java; then installed_java="${C_GREEN}[installed]${C_NONE}"; fi ;;
            5) if install_php; then installed_php="${C_GREEN}[installed]${C_NONE}"; fi ;;
            6) echo -e "${C_BRIGHT_GREEN}✅ Moving to main menu...${C_NONE}"; sleep 1; break ;;
            *) echo -e "${C_RED}❌ Invalid option. Please try again.${C_NONE}"; sleep 1 ;;
        esac
    done
}

function install_cli_tools() {
    clear_screen
    echo -e "${C_BRIGHT_PURPLE}┌─────────────────────────────────────────┐${C_NONE}"
    echo -e "${C_BRIGHT_PURPLE}│${C_NONE} 🛠️  ${C_BRIGHT_WHITE}Install CLI Tools${C_NONE}                   ${C_BRIGHT_PURPLE}│${C_NONE}"
    echo -e "${C_BRIGHT_PURPLE}└─────────────────────────────────────────┘${C_NONE}"
    
    # CLI Tools Section - using individual variables for better compatibility
    local cli_tools=(git kubectl colima docker docker-compose gh terraform aws-cli mongosh mongodb-database-tools redis)
    local cli_status=""
    
    while true; do
        echo -e "\n${C_BRIGHT_YELLOW}🛠️  Select a CLI tool to install:${C_NONE}"
        for i in "${!cli_tools[@]}"; do 
            local tool=${cli_tools[$i]}
            local status=""
            case $tool in
                "git")
                    if command -v git &> /dev/null; then
                        local git_version=$(git --version 2>/dev/null | cut -d' ' -f3)
                        status="${C_BG_GREEN}${C_WHITE} 🌿 ${C_NONE} ${C_BRIGHT_PURPLE}v${git_version}${C_NONE}"
                    else
                        status="${C_GRAY} 🌿 ${C_WHITE}not installed${C_NONE}"
                    fi
                    ;;
                "kubectl")
                    if command -v kubectl &> /dev/null; then
                        local kubectl_version=$(kubectl version --client 2>/dev/null | grep "Client Version:" | cut -d' ' -f3)
                        if [[ -n "$kubectl_version" ]]; then
                            status="${C_BG_GREEN}${C_WHITE} ⚓ ${C_NONE} ${C_BRIGHT_BLUE}${kubectl_version}${C_NONE}"
                        else
                            status="${C_BG_GREEN}${C_WHITE} ⚓ ${C_NONE} ${C_BRIGHT_GREEN}installed${C_NONE}"
                        fi
                    else
                        status="${C_GRAY} ⚓ ${C_WHITE}not installed${C_NONE}"
                    fi
                    ;;
                "docker")
                    if command -v docker &> /dev/null; then
                        local docker_version=$(docker --version 2>/dev/null | cut -d' ' -f3 | tr -d ',')
                        status="${C_BG_GREEN}${C_WHITE} 🐋 ${C_NONE} ${C_BRIGHT_CYAN}v${docker_version}${C_NONE}"
                    else
                        status="${C_GRAY} 🐋 ${C_WHITE}not installed${C_NONE}"
                    fi
                    ;;
                "docker-compose")
                    if command -v docker-compose &> /dev/null; then
                        local compose_version=$(docker-compose --version 2>/dev/null | cut -d' ' -f4 | tr -d ',')
                        if [[ -n "$compose_version" ]]; then
                            status="${C_BG_GREEN}${C_WHITE} 🐙 ${C_NONE} ${C_BRIGHT_BLUE}v${compose_version}${C_NONE}"
                        else
                            status="${C_BG_GREEN}${C_WHITE} 🐙 ${C_NONE} ${C_BRIGHT_GREEN}installed${C_NONE}"
                        fi
                    else
                        status="${C_GRAY} 🐙 ${C_WHITE}not installed${C_NONE}"
                    fi
                    ;;
                "colima")
                    if command -v colima &> /dev/null; then
                        if colima status &> /dev/null; then
                            status="${C_BG_GREEN}${C_WHITE} 🖥️  ${C_NONE} ${C_BRIGHT_GREEN}running${C_NONE}"
                        else
                            status="${C_BRIGHT_YELLOW} 🖥️  ${C_WHITE}stopped${C_NONE}"
                        fi
                    else
                        status="${C_GRAY} 🖥️  ${C_WHITE}not installed${C_NONE}"
                    fi
                    ;;
                "gh")
                    if command -v gh &> /dev/null; then
                        local gh_version=$(gh --version 2>/dev/null | head -n1 | cut -d' ' -f3)
                        if [[ -n "$gh_version" ]]; then
                            status="${C_BG_GREEN}${C_WHITE} 🐙 ${C_NONE} ${C_PURPLE}v${gh_version}${C_NONE}"
                        else
                            status="${C_BG_GREEN}${C_WHITE} 🐙 ${C_NONE} ${C_BRIGHT_GREEN}installed${C_NONE}"
                        fi
                    else
                        status="${C_GRAY} 🐙 ${C_WHITE}not installed${C_NONE}"
                    fi
                    ;;
                "terraform")
                    if command -v terraform &> /dev/null; then
                        local tf_version=$(terraform --version 2>/dev/null | head -n1 | cut -d' ' -f2 | tr -d 'v')
                        if [[ -n "$tf_version" ]]; then
                            status="${C_BG_GREEN}${C_WHITE} 🏗️  ${C_NONE} ${C_BRIGHT_PURPLE}v${tf_version}${C_NONE}"
                        else
                            status="${C_BG_GREEN}${C_WHITE} 🏗️  ${C_NONE} ${C_BRIGHT_GREEN}installed${C_NONE}"
                        fi
                    else
                        status="${C_GRAY} 🏗️  ${C_WHITE}not installed${C_NONE}"
                    fi
                    ;;
                "aws-cli")
                    if command -v aws &> /dev/null; then
                        local aws_version=$(aws --version 2>/dev/null | cut -d' ' -f1 | cut -d'/' -f2)
                        if [[ -n "$aws_version" ]]; then
                            status="${C_BG_GREEN}${C_WHITE} ☁️  ${C_NONE} ${C_YELLOW}v${aws_version}${C_NONE}"
                        else
                            status="${C_BG_GREEN}${C_WHITE} ☁️  ${C_NONE} ${C_BRIGHT_GREEN}installed${C_NONE}"
                        fi
                    else
                        status="${C_GRAY} ☁️  ${C_WHITE}not installed${C_NONE}"
                    fi
                    ;;
                "mongosh")
                    if command -v mongosh &> /dev/null; then
                        local mongosh_version=$(mongosh --version 2>/dev/null | head -n1 | cut -d' ' -f1)
                        if [[ -n "$mongosh_version" ]]; then
                            status="${C_BG_GREEN}${C_WHITE} 🍃 ${C_NONE} ${C_BRIGHT_GREEN}v${mongosh_version}${C_NONE}"
                        else
                            status="${C_BG_GREEN}${C_WHITE} 🍃 ${C_NONE} ${C_BRIGHT_GREEN}installed${C_NONE}"
                        fi
                    else
                        status="${C_GRAY} 🍃 ${C_WHITE}not installed${C_NONE}"
                    fi
                    ;;
                "mongodb-database-tools")
                    if command -v mongodump &> /dev/null; then
                        local tools_version=$(mongodump --version 2>/dev/null | head -n1 | grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+' | head -n1)
                        if [[ -n "$tools_version" ]]; then
                            status="${C_BG_GREEN}${C_WHITE} 🛠️ ${C_NONE} ${C_BRIGHT_CYAN}${tools_version}${C_NONE}"
                        else
                            status="${C_BG_GREEN}${C_WHITE} 🛠️ ${C_NONE} ${C_BRIGHT_GREEN}installed${C_NONE}"
                        fi
                    else
                        status="${C_GRAY} 🛠️ ${C_WHITE}not installed${C_NONE}"
                    fi
                    ;;
                "redis")
                    if command -v redis-cli &> /dev/null; then
                        local redis_version=$(redis-cli --version 2>/dev/null | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | head -n1)
                        if [[ -n "$redis_version" ]]; then
                            status="${C_BG_GREEN}${C_WHITE} 🔴 ${C_NONE} ${C_BRIGHT_RED}v${redis_version}${C_NONE}"
                        else
                            status="${C_BG_GREEN}${C_WHITE} 🔴 ${C_NONE} ${C_BRIGHT_GREEN}installed${C_NONE}"
                        fi
                    else
                        status="${C_GRAY} 🔴 ${C_WHITE}not installed${C_NONE}"
                    fi
                    ;;
                *)
                    if brew list "$tool" &> /dev/null 2>&1; then
                        status="${C_BG_GREEN}${C_WHITE} ✅ ${C_NONE} ${C_BRIGHT_GREEN}installed${C_NONE}"
                    else
                        status="${C_GRAY} ❌ ${C_WHITE}not installed${C_NONE}"
                    fi
                    ;;
            esac
            echo -e "${C_BRIGHT_BLUE}$((i+1)).${C_NONE} $tool $status"
        done
        echo -e "${C_BRIGHT_BLUE}$(( ${#cli_tools[@]} + 1 )).${C_NONE} ✅ ${C_BRIGHT_GREEN}Done with CLI tools${C_NONE}"
        read -p "Enter your choice: " choice
        
        if [[ "$choice" -gt 0 && "$choice" -le "${#cli_tools[@]}" ]]; then
            local tool=${cli_tools[$((choice-1))]}
            
            # Special handling for MongoDB database tools
            if [[ "$tool" == "mongodb-database-tools" ]]; then
                if command -v mongodump &> /dev/null; then
                    echo -e "${C_GREEN}MongoDB database tools are already installed.${C_NONE}"
                else
                    # First tap the MongoDB repository, then install
                    if run_with_retry "Adding MongoDB tap" brew tap mongodb/brew && \
                       run_with_retry "Installing MongoDB database tools" brew install mongodb/brew/mongodb-database-tools; then
                        echo -e "${C_GREEN}MongoDB database tools installed successfully!${C_NONE}"
                        echo -e "${C_CYAN}Available MongoDB tools:${C_NONE}"
                        echo "  • mongodump - Export MongoDB data"
                        echo "  • mongorestore - Import MongoDB data"
                        echo "  • mongoexport - Export data to JSON/CSV"
                        echo "  • mongoimport - Import data from JSON/CSV"
                        echo "  • mongostat - MongoDB statistics"
                        echo "  • mongotop - MongoDB top command"
                    fi
                fi
            # Special handling for Redis CLI
            elif [[ "$tool" == "redis" ]]; then
                if command -v redis-cli &> /dev/null; then
                    local redis_version=$(redis-cli --version 2>/dev/null | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | head -n1)
                    echo -e "${C_GREEN}Redis CLI is already installed (v${redis_version}).${C_NONE}"
                else
                    if run_with_retry "Installing Redis CLI and server" brew install redis; then
                        echo -e "${C_GREEN}✅ Redis installed successfully!${C_NONE}"
                        local redis_version=$(redis-cli --version 2>/dev/null | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | head -n1)
                        echo -e "${C_CYAN}Redis version: ${redis_version}${C_NONE}"
                        echo -e "${C_YELLOW}🔴 Redis CLI commands available:${C_NONE}"
                        echo -e "${C_CYAN}Usage examples:${C_NONE}"
                        echo "  redis-cli                    # Connect to local Redis"
                        echo "  redis-cli -h host -p port    # Connect to remote Redis"
                        echo "  redis-cli ping               # Test connection"
                        echo "  redis-cli info               # Server information"
                        echo "  redis-cli monitor            # Monitor commands"
                        echo ""
                        echo -e "${C_YELLOW}📋 Redis server controls:${C_NONE}"
                        echo "  brew services start redis   # Start Redis server"
                        echo "  brew services stop redis    # Stop Redis server"
                        echo "  brew services restart redis # Restart Redis server"
                    fi
                fi
            elif brew list "$tool" &> /dev/null 2>&1; then
                echo -e "${C_GREEN}$tool is already installed.${C_NONE}"
            elif run_with_retry "Installing $tool" brew install "$tool"; then
                echo -e "${C_GREEN}$tool installed successfully!${C_NONE}"
            fi
        elif [ "$choice" -eq "$((${#cli_tools[@]} + 1))" ]; then
            echo -e "${C_BRIGHT_GREEN}✅ CLI tools setup complete!${C_NONE}"; sleep 1; break
        else
            echo -e "${C_RED}❌ Invalid option.${C_NONE}"; sleep 1
        fi
    done
}

function install_gui_apps() {
    clear_screen
    echo -e "${C_BRIGHT_PURPLE}┌─────────────────────────────────────────┐${C_NONE}"
    echo -e "${C_BRIGHT_PURPLE}│${C_NONE} 📱 ${C_BRIGHT_WHITE}Install GUI Applications${C_NONE}             ${C_BRIGHT_PURPLE}│${C_NONE}"
    echo -e "${C_BRIGHT_PURPLE}└─────────────────────────────────────────┘${C_NONE}"
    
    local gui_apps=(visual-studio-code notion postman mongodb-compass google-chrome warp slack discord figma)
    
    while true; do
        echo -e "\n${C_BRIGHT_YELLOW}📱 Select a GUI application to install:${C_NONE}"
        for i in "${!gui_apps[@]}"; do 
            local app=${gui_apps[$i]}
            local status=""
            local icon=""
            
            local icon=""
            local app_path=""
            
            case $app in
                "visual-studio-code") 
                    icon="💻"
                    app_path="/Applications/Visual Studio Code.app"
                    ;;
                "notion") 
                    icon="📝"
                    app_path="/Applications/Notion.app"
                    ;;
                "postman") 
                    icon="📮"
                    app_path="/Applications/Postman.app"
                    ;;
                "mongodb-compass") 
                    icon="🍃"
                    app_path="/Applications/MongoDB Compass.app"
                    ;;
                "google-chrome") 
                    icon="🌐"
                    app_path="/Applications/Google Chrome.app"
                    ;;
                "warp") 
                    icon="🚀"
                    app_path="/Applications/Warp.app"
                    ;;
                "slack") 
                    icon="💬"
                    app_path="/Applications/Slack.app"
                    ;;
                "discord") 
                    icon="🎮"
                    app_path="/Applications/Discord.app"
                    ;;
                "figma") 
                    icon="🎨"
                    app_path="/Applications/Figma.app"
                    ;;
                *) 
                    icon="📱"
                    app_path="/Applications/${app}.app"
                    ;;
            esac
            
            # Check if app is installed (either via brew or manually)
            if [[ -d "$app_path" ]]; then
                # Try to get version from brew first
                if brew list --cask "$app" &> /dev/null 2>&1; then
                    local app_version=$(brew list --cask --versions "$app" 2>/dev/null | cut -d' ' -f2)
                    if [[ -n "$app_version" ]]; then
                        status="${C_BG_GREEN}${C_WHITE} ${icon} ${C_NONE} ${C_BRIGHT_GREEN}v${app_version}${C_NONE}"
                    else
                        status="${C_BG_GREEN}${C_WHITE} ${icon} ${C_NONE} ${C_BRIGHT_GREEN}installed${C_NONE}"
                    fi
                else
                    # App exists but not managed by brew
                    status="${C_BG_GREEN}${C_WHITE} ${icon} ${C_NONE} ${C_BRIGHT_GREEN}installed${C_NONE}"
                fi
            else
                status="${C_GRAY} ${icon} ${C_WHITE}not installed${C_NONE}"
            fi
            echo -e "${C_BRIGHT_BLUE}$((i+1)).${C_NONE} $app $status"
        done
        echo -e "${C_BRIGHT_BLUE}$(( ${#gui_apps[@]} + 1 )).${C_NONE} ✅ ${C_BRIGHT_GREEN}Done with GUI applications${C_NONE}"
        read -p "Enter your choice: " choice

        if [[ "$choice" -gt 0 && "$choice" -le "${#gui_apps[@]}" ]]; then
            local app=${gui_apps[$((choice-1))]}
            # Get the app path for this specific app
            local app_path=""
            case $app in
                "visual-studio-code") app_path="/Applications/Visual Studio Code.app" ;;
                "notion") app_path="/Applications/Notion.app" ;;
                "postman") app_path="/Applications/Postman.app" ;;
                "mongodb-compass") app_path="/Applications/MongoDB Compass.app" ;;
                "google-chrome") app_path="/Applications/Google Chrome.app" ;;
                "warp") app_path="/Applications/Warp.app" ;;
                "slack") app_path="/Applications/Slack.app" ;;
                "discord") app_path="/Applications/Discord.app" ;;
                "figma") app_path="/Applications/Figma.app" ;;
                *) app_path="/Applications/${app}.app" ;;
            esac
            
            if [[ -d "$app_path" ]]; then
                echo -e "${C_GREEN}$app is already installed.${C_NONE}"
            elif run_with_retry "Installing $app" brew install --cask "$app"; then
                echo -e "${C_GREEN}$app installed successfully!${C_NONE}"
            fi
        elif [ "$choice" -eq "$((${#gui_apps[@]} + 1))" ]; then
            echo -e "${C_BRIGHT_GREEN}✅ Applications setup complete!${C_NONE}"; sleep 1; break
        else
            echo -e "${C_RED}❌ Invalid option.${C_NONE}"; sleep 1
        fi
    done
}

function setup_shell_and_ai_tools() {
    clear_screen
    echo -e "${C_BRIGHT_CYAN}┌─────────────────────────────────────────┐${C_NONE}"
    echo -e "${C_BRIGHT_CYAN}│${C_NONE} 🐚 ${C_BRIGHT_WHITE}Setup Shell and AI Tools${C_NONE}           ${C_BRIGHT_CYAN}│${C_NONE}"
    echo -e "${C_BRIGHT_CYAN}└─────────────────────────────────────────┘${C_NONE}"
    local shell_tools=("oh-my-zsh" "zsh-autosuggestions" "zsh-syntax-highlighting" "powerlevel10k" "claude-code" "yarn")
    
    while true; do
        echo -e "\n${C_BRIGHT_YELLOW}🐚 Select a shell/AI tool to install:${C_NONE}"
        for i in "${!shell_tools[@]}"; do 
            local tool=${shell_tools[$i]}
            local status=""
            case $tool in
                "oh-my-zsh")
                    if [ -d "$HOME/.oh-my-zsh" ]; then
                        local omz_version=$(cat ~/.oh-my-zsh/tools/version.sh 2>/dev/null | grep "OMZ_VERSION" | cut -d'"' -f2)
                        if [[ -n "$omz_version" ]]; then
                            status="${C_BRIGHT_CYAN}[${C_WHITE}v${omz_version}${C_BRIGHT_CYAN}]${C_NONE}"
                        else
                            status="${C_BRIGHT_CYAN}[${C_WHITE}✓ installed${C_BRIGHT_CYAN}]${C_NONE}"
                        fi
                    else
                        status="${C_GRAY}[${C_WHITE}not installed${C_GRAY}]${C_NONE}"
                    fi
                    ;;
                "zsh-autosuggestions")
                    if [ -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
                        if grep -q "zsh-autosuggestions" ~/.zshrc 2>/dev/null; then
                            status="${C_BG_GREEN}${C_WHITE} ⚡ ${C_NONE}${C_BRIGHT_GREEN} active${C_NONE}"
                        else
                            status="${C_BRIGHT_YELLOW}[${C_WHITE}needs activation${C_BRIGHT_YELLOW}]${C_NONE}"
                        fi
                    else
                        status="${C_GRAY}[${C_WHITE}not installed${C_GRAY}]${C_NONE}"
                    fi
                    ;;
                "zsh-syntax-highlighting")
                    if [ -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
                        if grep -q "zsh-syntax-highlighting" ~/.zshrc 2>/dev/null; then
                            status="${C_BG_GREEN}${C_WHITE} 🎨 ${C_NONE}${C_BRIGHT_GREEN} active${C_NONE}"
                        else
                            status="${C_BRIGHT_YELLOW}[${C_WHITE}needs activation${C_BRIGHT_YELLOW}]${C_NONE}"
                        fi
                    else
                        status="${C_GRAY}[${C_WHITE}not installed${C_GRAY}]${C_NONE}"
                    fi
                    ;;
                "powerlevel10k")
                    if [ -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
                        if grep -q "powerlevel10k" ~/.zshrc 2>/dev/null; then
                            status="${C_BG_GREEN}${C_WHITE} ⭐ ${C_NONE}${C_BRIGHT_GREEN} active theme${C_NONE}"
                        else
                            status="${C_BRIGHT_YELLOW}[${C_WHITE}needs activation${C_BRIGHT_YELLOW}]${C_NONE}"
                        fi
                    else
                        status="${C_GRAY}[${C_WHITE}not installed${C_GRAY}]${C_NONE}"
                    fi
                    ;;
                "claude-code")
                    if command -v claude-code &> /dev/null; then
                        local claude_version=$(claude-code --version 2>/dev/null | head -n1)
                        if [[ -n "$claude_version" ]]; then
                            status="${C_BG_GREEN}${C_WHITE} 🤖 ${C_NONE}${C_BRIGHT_PURPLE} ${claude_version}${C_NONE}"
                        else
                            status="${C_BG_GREEN}${C_WHITE} 🤖 ${C_NONE}${C_BRIGHT_PURPLE} installed${C_NONE}"
                        fi
                    else
                        status="${C_GRAY}[${C_WHITE}not installed${C_GRAY}]${C_NONE}"
                    fi
                    ;;
                "yarn")
                    if command -v yarn &> /dev/null; then
                        local yarn_version=$(yarn --version 2>/dev/null)
                        if [[ -n "$yarn_version" ]]; then
                            status="${C_BG_GREEN}${C_WHITE} 📦 ${C_NONE}${C_BRIGHT_BLUE} v${yarn_version}${C_NONE}"
                        else
                            status="${C_BG_GREEN}${C_WHITE} 📦 ${C_NONE}${C_BRIGHT_BLUE} installed${C_NONE}"
                        fi
                    else
                        status="${C_GRAY}[${C_WHITE}not installed${C_GRAY}]${C_NONE}"
                    fi
                    ;;
            esac
            echo -e "${C_BRIGHT_BLUE}$((i+1)).${C_NONE} $tool $status"
        done
        echo -e "${C_BRIGHT_BLUE}$(( ${#shell_tools[@]} + 1 )).${C_NONE} ✅ ${C_BRIGHT_GREEN}Done with shell/AI tools${C_NONE}"
        read -p "Enter your choice: " choice
        
        if [[ "$choice" -gt 0 && "$choice" -le "${#shell_tools[@]}" ]]; then
            local tool=${shell_tools[$((choice-1))]}
            case $tool in
                "oh-my-zsh")
                    if [ -d "$HOME/.oh-my-zsh" ]; then
                        echo -e "${C_GREEN}Oh My Zsh already installed${C_NONE}"
                    elif run_with_retry "Installing Oh My Zsh" sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended"; then
                        echo -e "${C_GREEN}Oh My Zsh installed successfully!${C_NONE}"
                    fi
                    ;;
                "zsh-autosuggestions")
                    local plugin_dir="${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
                    if [ -d "$plugin_dir" ]; then
                        echo -e "${C_GREEN}zsh-autosuggestions already installed${C_NONE}"
                        # Check if it's activated, if not, offer to activate
                        if ! grep -q "zsh-autosuggestions" ~/.zshrc 2>/dev/null; then
                            echo -e "${C_YELLOW}Plugin is installed but not activated in ~/.zshrc${C_NONE}"
                            add_zsh_plugin "zsh-autosuggestions"
                            echo -e "${C_CYAN}✅ Plugin activated! Restart your terminal or run 'source ~/.zshrc'${C_NONE}"
                        fi
                    else
                        # Remove if exists but corrupted
                        if [ -e "$plugin_dir" ]; then
                            echo -e "${C_YELLOW}Removing corrupted installation...${C_NONE}"
                            rm -rf "$plugin_dir"
                        fi
                        if run_with_retry "Installing zsh-autosuggestions plugin" git clone https://github.com/zsh-users/zsh-autosuggestions "$plugin_dir"; then
                            echo -e "${C_GREEN}zsh-autosuggestions installed successfully!${C_NONE}"
                            add_zsh_plugin "zsh-autosuggestions"
                            echo -e "${C_CYAN}✅ Plugin activated! Restart your terminal or run 'source ~/.zshrc'${C_NONE}"
                        fi
                    fi
                    ;;
                "zsh-syntax-highlighting")
                    local plugin_dir="${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
                    if [ -d "$plugin_dir" ]; then
                        echo -e "${C_GREEN}zsh-syntax-highlighting already installed${C_NONE}"
                        # Check if it's activated, if not, offer to activate
                        if ! grep -q "zsh-syntax-highlighting" ~/.zshrc 2>/dev/null; then
                            echo -e "${C_YELLOW}Plugin is installed but not activated in ~/.zshrc${C_NONE}"
                            add_zsh_plugin "zsh-syntax-highlighting"
                            echo -e "${C_CYAN}✅ Plugin activated! Restart your terminal or run 'source ~/.zshrc'${C_NONE}"
                        fi
                    else
                        # Remove if exists but corrupted
                        if [ -e "$plugin_dir" ]; then
                            echo -e "${C_YELLOW}Removing corrupted installation...${C_NONE}"
                            rm -rf "$plugin_dir"
                        fi
                        if run_with_retry "Installing zsh-syntax-highlighting plugin" git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$plugin_dir"; then
                            echo -e "${C_GREEN}zsh-syntax-highlighting installed successfully!${C_NONE}"
                            add_zsh_plugin "zsh-syntax-highlighting"
                            echo -e "${C_CYAN}✅ Plugin activated! Restart your terminal or run 'source ~/.zshrc'${C_NONE}"
                        fi
                    fi
                    ;;
                "powerlevel10k")
                    # Check if Oh My Zsh is installed first
                    if [ ! -d "$HOME/.oh-my-zsh" ]; then
                        echo -e "${C_RED}❌ Oh My Zsh is required for Powerlevel10k${C_NONE}"
                        echo -e "${C_YELLOW}Please install Oh My Zsh first (option 1 in this menu)${C_NONE}"
                        return 1
                    fi
                    
                    local theme_dir="${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k"
                    if [ -d "$theme_dir" ]; then
                        echo -e "${C_GREEN}Powerlevel10k already installed${C_NONE}"
                        
                        # Check if it's activated and offer to activate if not
                        if ! grep -q "powerlevel10k" ~/.zshrc 2>/dev/null; then
                            echo -e "${C_YELLOW}Powerlevel10k is installed but not activated.${C_NONE}"
                            if ask_yes_no "Would you like to activate Powerlevel10k as your zsh theme?" "y"; then
                                # Backup current .zshrc
                                cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null
                                
                                # Verify the theme directory exists before activation
                                if [ -d "$theme_dir" ]; then
                                    # Update or add ZSH_THEME line
                                    if grep -q "^ZSH_THEME=" ~/.zshrc 2>/dev/null; then
                                        sed -i.bak 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
                                    else
                                        echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> ~/.zshrc
                                    fi
                                    
                                    echo -e "${C_GREEN}✅ Powerlevel10k activated! Restart your terminal or run 'source ~/.zshrc'${C_NONE}"
                                    echo -e "${C_CYAN}💡 The configuration wizard will run on next terminal start${C_NONE}"
                                else
                                    echo -e "${C_RED}❌ Theme directory not found. Please reinstall Powerlevel10k.${C_NONE}"
                                fi
                            fi
                        else
                            echo -e "${C_GREEN}✅ Powerlevel10k is active!${C_NONE}"
                        fi
                    else
                        # Ensure the custom/themes directory exists
                        mkdir -p "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes"
                        
                        if run_with_retry "Installing Powerlevel10k theme" git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$theme_dir"; then
                        echo -e "${C_GREEN}Powerlevel10k installed successfully!${C_NONE}"
                        
                        # Auto-activate after installation
                        if ask_yes_no "Would you like to activate Powerlevel10k as your zsh theme now?" "y"; then
                            # Backup current .zshrc
                            cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null
                            
                            # Update or add ZSH_THEME line
                            if grep -q "^ZSH_THEME=" ~/.zshrc 2>/dev/null; then
                                sed -i.bak 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
                            else
                                echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> ~/.zshrc
                            fi
                            
                            echo -e "${C_GREEN}✅ Powerlevel10k activated! Restart your terminal or run 'source ~/.zshrc'${C_NONE}"
                            echo -e "${C_CYAN}💡 The configuration wizard will run on next terminal start${C_NONE}"
                        else
                            echo -e "${C_YELLOW}Note: Set ZSH_THEME=\"powerlevel10k/powerlevel10k\" in ~/.zshrc to activate${C_NONE}"
                        fi
                    else
                        echo -e "${C_RED}❌ Failed to install Powerlevel10k${C_NONE}"
                    fi
                    fi
                    ;;
                "claude-code")
                    if command -v claude-code &> /dev/null; then
                        echo -e "${C_GREEN}Claude Code already installed${C_NONE}"
                    else
                        if command -v npm &> /dev/null; then
                            if run_with_retry "Installing Claude Code CLI" npm install -g @anthropic-ai/claude-code; then
                                echo -e "${C_GREEN}Claude Code installed successfully!${C_NONE}"
                                echo -e "${C_YELLOW}🤖 You can now use 'claude-code' command for AI-powered coding assistance${C_NONE}"
                                echo -e "${C_CYAN}Usage examples:${C_NONE}"
                                echo "  claude-code --help"
                                echo "  claude-code 'Explain this function'"
                                echo "  claude-code 'Write a Python function to sort a list'"
                            fi
                        else
                            echo -e "${C_RED}npm not found. Please install Node.js first in the Language Runtimes section.${C_NONE}"
                        fi
                    fi
                    ;;
                "yarn")
                    if command -v yarn &> /dev/null; then
                        local yarn_version=$(yarn --version 2>/dev/null)
                        echo -e "${C_GREEN}Yarn already installed (v${yarn_version})${C_NONE}"
                    else
                        if command -v npm &> /dev/null; then
                            if run_with_retry "Installing Yarn package manager" npm install -g yarn; then
                                echo -e "${C_GREEN}✅ Yarn installed successfully!${C_NONE}"
                                local yarn_version=$(yarn --version 2>/dev/null)
                                echo -e "${C_CYAN}Yarn version: ${yarn_version}${C_NONE}"
                                echo -e "${C_YELLOW}📦 You can now use 'yarn' commands for package management${C_NONE}"
                                echo -e "${C_CYAN}Usage examples:${C_NONE}"
                                echo "  yarn install          # Install dependencies"
                                echo "  yarn add <package>     # Add a package"
                                echo "  yarn build            # Build project"
                                echo "  yarn start            # Start development server"
                            else
                                echo -e "${C_RED}❌ Failed to install Yarn${C_NONE}"
                            fi
                        else
                            echo -e "${C_RED}npm not found. Please install Node.js first in the Language Runtimes section.${C_NONE}"
                            echo -e "${C_YELLOW}💡 Node.js installation includes npm, which is required for Yarn${C_NONE}"
                        fi
                    fi
                    ;;
            esac
        elif [ "$choice" -eq "$((${#shell_tools[@]} + 1))" ]; then
            break
        else
            echo -e "${C_RED}Invalid option.${C_NONE}"
        fi
        read -n 1 -s -r -p "Press any key to continue..."
    done
}

function setup_docker_and_databases() {
    clear_screen
    echo -e "${C_BRIGHT_BLUE}┌─────────────────────────────────────────┐${C_NONE}"
    echo -e "${C_BRIGHT_BLUE}│${C_NONE} 🐳 ${C_BRIGHT_WHITE}Setup Docker and Databases${C_NONE}        ${C_BRIGHT_BLUE}│${C_NONE}"
    echo -e "${C_BRIGHT_BLUE}└─────────────────────────────────────────┘${C_NONE}"
    local services=("colima-start" "mongodb-container" "redis-container" "postgres-container" "kafka-container" "gcloud-emulators-container")
    
    while true; do
        echo -e "\n${C_BRIGHT_YELLOW}🐳 Select a service to setup:${C_NONE}"
        for i in "${!services[@]}"; do 
            local service=${services[$i]}
            local status=""
            case $service in
                "colima-start")
                    if colima status &> /dev/null; then
                        status="${C_GREEN}[running]${C_NONE}"
                    fi
                    ;;
                "mongodb-container")
                    if docker ps --format "table {{.Names}}" | grep -q "my-mongo" 2>/dev/null; then
                        status="${C_GREEN}[running]${C_NONE}"
                    fi
                    ;;
                "redis-container")
                    if docker ps --format "table {{.Names}}" | grep -q "my-redis" 2>/dev/null; then
                        status="${C_GREEN}[running]${C_NONE}"
                    fi
                    ;;
                "postgres-container")
                    if docker ps --format "table {{.Names}}" | grep -q "my-postgres" 2>/dev/null; then
                        status="${C_GREEN}[running]${C_NONE}"
                    fi
                    ;;
                "kafka-container")
                    if docker ps --format "table {{.Names}}" | grep -q "kafka" 2>/dev/null; then
                        status="${C_GREEN}[running]${C_NONE}"
                    fi
                    ;;
                "gcloud-emulators-container")
                    if docker ps --format "table {{.Names}}" | grep -q "pubsub-emulator" 2>/dev/null; then
                        status="${C_GREEN}[running]${C_NONE}"
                    fi
                    ;;
            esac
            echo -e "${C_BRIGHT_BLUE}$((i+1)).${C_NONE} $service $status"
        done
        echo -e "${C_BRIGHT_BLUE}$(( ${#services[@]} + 1 )).${C_NONE} ✅ ${C_BRIGHT_GREEN}Done with Docker/Database setup${C_NONE}"
        read -p "Enter your choice: " choice
        
        if [[ "$choice" -gt 0 && "$choice" -le "${#services[@]}" ]]; then
            local service=${services[$((choice-1))]}
            case $service in
                "colima-start")
                    if ! command -v colima &> /dev/null; then
                        echo -e "${C_RED}Colima not installed. Please install it first.${C_NONE}"
                    elif colima status &> /dev/null; then
                        echo -e "${C_GREEN}Colima is already running${C_NONE}"
                    elif run_with_retry "Starting Colima" colima start --cpu 4 --memory 8 --disk 60; then
                        echo -e "${C_GREEN}Colima started successfully!${C_NONE}"
                    fi
                    ;;
                "mongodb-container")
                    if docker ps --format "table {{.Names}}" | grep -q "my-mongo" 2>/dev/null; then
                        echo -e "${C_GREEN}MongoDB container already running${C_NONE}"
                    elif run_with_retry "Running MongoDB container" docker run --name my-mongo -d -p 27017:27017 mongo; then
                        echo -e "${C_GREEN}MongoDB container started successfully!${C_NONE}"
                    fi
                    ;;
                "redis-container")
                    if docker ps --format "table {{.Names}}" | grep -q "my-redis" 2>/dev/null; then
                        echo -e "${C_GREEN}Redis container already running${C_NONE}"
                    elif run_with_retry "Running Redis container" docker run --name my-redis -d -p 6379:6379 redis; then
                        echo -e "${C_GREEN}Redis container started successfully!${C_NONE}"
                    fi
                    ;;
                "postgres-container")
                    if docker ps --format "table {{.Names}}" | grep -q "my-postgres" 2>/dev/null; then
                        echo -e "${C_GREEN}PostgreSQL container already running${C_NONE}"
                    else
                        read -p "Enter PostgreSQL password (default: postgres): " pg_password
                        pg_password=${pg_password:-postgres}
                        if run_with_retry "Running PostgreSQL container" docker run --name my-postgres -e POSTGRES_PASSWORD="$pg_password" -d -p 5432:5432 postgres; then
                            echo -e "${C_GREEN}PostgreSQL container started successfully!${C_NONE}"
                        fi
                    fi
                    ;;
                "kafka-container")
                    if docker ps --format "table {{.Names}}" | grep -q "kafka" 2>/dev/null; then
                        echo -e "${C_GREEN}Kafka container already running${C_NONE}"
                    else
                        echo -e "${C_CYAN}Starting Kafka with KRaft mode (no Zookeeper needed)...${C_NONE}"
                        
                        # Create Kafka volumes if they don't exist
                        docker volume create kafka_data 2>/dev/null || true
                        docker volume create kafka_logs 2>/dev/null || true
                        
                        # Start Kafka container with full configuration
                        if run_with_retry "Running Kafka container" docker run --name kafka -d \
                            --hostname kafka \
                            -p 9092:9092 \
                            -p 9101:9101 \
                            -v kafka_data:/var/lib/kafka/data \
                            -v kafka_logs:/kafka \
                            -e KAFKA_NODE_ID=1 \
                            -e KAFKA_LISTENER_SECURITY_PROTOCOL_MAP='CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT' \
                            -e KAFKA_ADVERTISED_LISTENERS='PLAINTEXT://kafka:29092,PLAINTEXT_HOST://localhost:9092' \
                            -e KAFKA_METRICS_REPORTERS=io.confluent.metrics.reporter.ConfluentMetricsReporter \
                            -e KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1 \
                            -e KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS=0 \
                            -e KAFKA_CONFLUENT_METRICS_REPORTER_BOOTSTRAP_SERVERS=kafka:29092 \
                            -e KAFKA_CONFLUENT_METRICS_REPORTER_TOPIC_REPLICAS=1 \
                            -e KAFKA_CONFLUENT_METRICS_ENABLE='true' \
                            -e KAFKA_CONFLUENT_SUPPORT_CUSTOMER_ID=anonymous \
                            -e KAFKA_AUTO_CREATE_TOPICS_ENABLE='false' \
                            -e KAFKA_PROCESS_ROLES='broker,controller' \
                            -e KAFKA_CONTROLLER_QUORUM_VOTERS='1@kafka:29093' \
                            -e KAFKA_LISTENERS='PLAINTEXT://kafka:29092,CONTROLLER://kafka:29093,PLAINTEXT_HOST://0.0.0.0:9092' \
                            -e KAFKA_INTER_BROKER_LISTENER_NAME='PLAINTEXT' \
                            -e KAFKA_CONTROLLER_LISTENER_NAMES='CONTROLLER' \
                            -e KAFKA_LOG_DIRS='/var/lib/kafka/data' \
                            -e CLUSTER_ID='MkU3OEVBNTcwNTJENDM2Qk' \
                            --restart unless-stopped \
                            confluentinc/cp-kafka:7.5.0; then
                            
                            echo -e "${C_GREEN}Kafka container started successfully!${C_NONE}"
                            echo -e "${C_YELLOW}Kafka is available on localhost:9092${C_NONE}"
                            echo -e "${C_YELLOW}Metrics available on port 9101${C_NONE}"
                            
                            # Ask if user wants to install Kafka UI
                            if ask_yes_no "Would you like to install Kafka UI for management?" "y"; then
                                echo -e "${C_CYAN}Starting Kafka UI...${C_NONE}"
                                sleep 5  # Wait for Kafka to be ready
                                if run_with_retry "Running Kafka UI container" docker run --name kafka-ui -d \
                                    --link kafka:kafka \
                                    -p 8086:8080 \
                                    -e KAFKA_CLUSTERS_0_NAME=local \
                                    -e KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS=kafka:29092 \
                                    -e KAFKA_CLUSTERS_0_METRICS_PORT=9101 \
                                    -e DYNAMIC_CONFIG_ENABLED='true' \
                                    --restart unless-stopped \
                                    provectuslabs/kafka-ui:latest; then
                                    
                                    echo -e "${C_GREEN}Kafka UI started successfully!${C_NONE}"
                                    echo -e "${C_YELLOW}Kafka UI available at: http://localhost:8086${C_NONE}"
                                fi
                            fi
                        fi
                    fi
                    ;;
                "gcloud-emulators-container")
                    if docker ps --format "table {{.Names}}" | grep -q "pubsub-emulator" 2>/dev/null; then
                        echo -e "${C_GREEN}Google Cloud Pub/Sub emulator already running${C_NONE}"
                    else
                        echo -e "${C_CYAN}Starting Google Cloud Pub/Sub emulator...${C_NONE}"
                        
                        # Create Pub/Sub volume if it doesn't exist
                        docker volume create pubsub_data 2>/dev/null || true
                        
                        if run_with_retry "Running Google Cloud Pub/Sub emulator" docker run --name pubsub-emulator -d \
                            -p 8085:8085 \
                            -v pubsub_data:/opt/data \
                            -e PUBSUB_PROJECT_ID=brevo \
                            --restart on-failure \
                            gcr.io/google.com/cloudsdktool/google-cloud-cli:emulators \
                            gcloud beta emulators pubsub start --host-port=0.0.0.0:8085 --data-dir=/opt/data; then
                            
                            echo -e "${C_GREEN}Google Cloud Pub/Sub emulator started successfully!${C_NONE}"
                            echo -e "${C_YELLOW}Pub/Sub emulator available on localhost:8085${C_NONE}"
                            echo -e "${C_YELLOW}Project ID: brevo${C_NONE}"
                        fi
                    fi
                    ;;
            esac
        elif [ "$choice" -eq "$((${#services[@]} + 1))" ]; then
            break
        else
            echo -e "${C_RED}Invalid option.${C_NONE}"
        fi
        read -n 1 -s -r -p "Press any key to continue..."
    done
}

# Function to set up another Git account
function setup_another_git_account() {
    echo -e "${C_CYAN}🔑 Add Another Git Account${C_NONE}"
    echo -e "${C_YELLOW}This will help you add a work or personal account alongside your existing Git setup${C_NONE}"
    echo ""
    
    # Ask what type of account to add
    echo -e "${C_BRIGHT_YELLOW}What type of account do you want to add?${C_NONE}"
    echo -e "${C_BRIGHT_CYAN}1)${C_NONE} Work account"
    echo -e "${C_BRIGHT_CYAN}2)${C_NONE} Personal account"
    echo -e "${C_BRIGHT_CYAN}3)${C_NONE} Custom account"
    read -p "Enter your choice [1-3]: " account_type
    
    case $account_type in
        1)
            account_name="work"
            echo -e "${C_CYAN}Setting up work account...${C_NONE}"
            ;;
        2)
            account_name="personal"
            echo -e "${C_CYAN}Setting up personal account...${C_NONE}"
            ;;
        3)
            read -p "Enter account name (e.g., client, project): " account_name
            echo -e "${C_CYAN}Setting up $account_name account...${C_NONE}"
            ;;
        *)
            echo -e "${C_RED}Invalid choice. Exiting.${C_NONE}"
            return
            ;;
    esac
    
    # Get account information
    read -p "Enter your name for this account: " git_name
    read -p "Enter your email for this account: " git_email
    
    echo ""
    echo -e "${C_CYAN}📧 Account to add:${C_NONE}"
    echo -e "  ${C_GREEN}$git_name${C_NONE} <${C_CYAN}$git_email${C_NONE}> (${account_name})"
    echo ""
    
    read -p "Continue? (y/n): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo -e "${C_YELLOW}Setup cancelled${C_NONE}"
        return
    fi
    
    # Generate SSH key for the new account
    echo -e "${C_BLUE}🔑 Generating SSH key...${C_NONE}"
    
    ssh_key_file="~/.ssh/id_ed25519_${account_name}"
    if [ ! -f ~/.ssh/id_ed25519_${account_name} ]; then
        echo -e "${C_YELLOW}Generating ${account_name} SSH key...${C_NONE}"
        ssh-keygen -t ed25519 -C "$git_email" -f ~/.ssh/id_ed25519_${account_name} -N ""
        echo -e "${C_GREEN}✅ ${account_name} SSH key created${C_NONE}"
    else
        echo -e "${C_YELLOW}${account_name} SSH key already exists${C_NONE}"
    fi
    
    # Update SSH config
    echo -e "${C_BLUE}⚙️ Configuring SSH...${C_NONE}"
    
    # Backup existing SSH config if it exists
    if [ -f ~/.ssh/config ]; then
        cp ~/.ssh/config ~/.ssh/config.backup.$(date +%Y%m%d_%H%M%S)
        echo -e "${C_YELLOW}Backed up existing SSH config${C_NONE}"
    fi
    
    # Add new account to SSH config
    echo "" >> ~/.ssh/config
    echo "# ${account_name} GitHub account" >> ~/.ssh/config
    echo "Host github-${account_name}" >> ~/.ssh/config
    echo "    HostName github.com" >> ~/.ssh/config  
    echo "    User git" >> ~/.ssh/config
    echo "    IdentityFile ~/.ssh/id_ed25519_${account_name}" >> ~/.ssh/config
    echo "    IdentitiesOnly yes" >> ~/.ssh/config
    
    # Set proper permissions
    chmod 600 ~/.ssh/config
    
    # Add SSH key to agent
    echo -e "${C_BLUE}🔐 Adding key to SSH agent...${C_NONE}"
    eval "$(ssh-agent -s)" > /dev/null
    ssh-add ~/.ssh/id_ed25519_${account_name}
    
    # Create Git config file for the new account
    echo -e "${C_BLUE}📝 Creating Git configuration for ${account_name}...${C_NONE}"
    
    cat > ~/.gitconfig-${account_name} << EOF
[user]
    name = $git_name
    email = $git_email
[core]
    editor = code --wait
[push]
    default = current
[pull]
    rebase = false
EOF

    # Create directory structure
    echo -e "${C_BLUE}📁 Creating directory structure...${C_NONE}"
    mkdir -p ~/${account_name}
    
    # Update main Git config to add the new conditional include
    echo -e "${C_BLUE}📝 Updating main Git configuration...${C_NONE}"
    
    # Check if we already have conditional includes in gitconfig
    if grep -q "includeIf" ~/.gitconfig 2>/dev/null; then
        # Add the new conditional include to existing config
        echo "" >> ~/.gitconfig
        echo "# ${account_name} account" >> ~/.gitconfig
        echo "[includeIf \"gitdir:~/${account_name}/\"]" >> ~/.gitconfig
        echo "    path = ~/.gitconfig-${account_name}" >> ~/.gitconfig
    else
        # Create a basic gitconfig with the new account
        current_user=$(git config --global user.name 2>/dev/null || echo "")
        current_email=$(git config --global user.email 2>/dev/null || echo "")
        
        cat > ~/.gitconfig << EOF
# Default configuration
[user]
    name = ${current_user:-$git_name}
    email = ${current_email:-$git_email}

# Conditional includes based on directory
[includeIf "gitdir:~/${account_name}/"]
    path = ~/.gitconfig-${account_name}

# Global settings
[core]
    editor = code --wait
[init]
    defaultBranch = main
[push]
    default = current
[pull]
    rebase = false
[credential]
    helper = osxkeychain
EOF
    fi

    echo ""
    echo -e "${C_GREEN}🎉 ${account_name} Git account setup completed!${C_NONE}"
    echo ""
    echo -e "${C_YELLOW}📋 Next steps:${C_NONE}"
    echo -e "${C_WHITE}1. Add SSH key to your ${account_name} GitHub account:${C_NONE}"
    echo ""
    echo -e "${C_CYAN}   ${account_name} account public key:${C_NONE}"
    echo -e "${C_GRAY}   $(cat ~/.ssh/id_ed25519_${account_name}.pub)${C_NONE}"
    echo ""
    echo -e "${C_WHITE}2. Add key at: ${C_CYAN}https://github.com/settings/ssh/new${C_NONE}"
    echo ""
    echo -e "${C_WHITE}3. Clone repositories using the new account:${C_NONE}"
    echo -e "${C_GREEN}   ${C_WHITE}git clone git@github-${account_name}:username/repo.git ~/${account_name}/repo${C_NONE}"
    echo ""
    echo -e "${C_WHITE}4. Test connection:${C_NONE}"
    echo -e "${C_GREEN}   ${C_WHITE}ssh -T git@github-${account_name}${C_NONE}"
    echo ""
    echo -e "${C_YELLOW}💡 Repositories in ~/${account_name}/ will use the ${account_name} account${C_NONE}"
    echo -e "${C_YELLOW}💡 Use 'github-${account_name}' as the host when cloning repositories${C_NONE}"
}

function configure_git() {
    clear_screen
    echo -e "${C_BRIGHT_YELLOW}┌─────────────────────────────────────────┐${C_NONE}"
    echo -e "${C_BRIGHT_YELLOW}│${C_NONE} 🔑 ${C_BRIGHT_WHITE}Configure Git${C_NONE}                    ${C_BRIGHT_YELLOW}│${C_NONE}"
    echo -e "${C_BRIGHT_YELLOW}└─────────────────────────────────────────┘${C_NONE}"
    local configs=("user-config" "credential-helper" "ssh-key" "test-github-ssh" "add-another-account")
    
    while true; do
        echo -e "\n${C_BRIGHT_YELLOW}🔑 Select a Git configuration:${C_NONE}"
        for i in "${!configs[@]}"; do 
            local config=${configs[$i]}
            local status=""
            case $config in
                "user-config")
                    local git_user=$(git config --global user.name 2>/dev/null)
                    local git_email=$(git config --global user.email 2>/dev/null)
                    if [[ -n "$git_user" && -n "$git_email" ]]; then
                        status="${C_BRIGHT_GREEN}[${C_WHITE}$git_user${C_BRIGHT_GREEN} <${C_CYAN}$git_email${C_BRIGHT_GREEN}>]${C_NONE}"
                    else
                        status="${C_BRIGHT_YELLOW}[${C_WHITE}not configured${C_BRIGHT_YELLOW}]${C_NONE}"
                    fi
                    ;;
                "credential-helper")
                    local helper=$(git config --global credential.helper 2>/dev/null)
                    if [[ -n "$helper" ]]; then
                        status="${C_BRIGHT_GREEN}[${C_PURPLE}$helper${C_BRIGHT_GREEN}]${C_NONE}"
                    else
                        status="${C_BRIGHT_YELLOW}[${C_WHITE}not configured${C_BRIGHT_YELLOW}]${C_NONE}"
                    fi
                    ;;
                "ssh-key")
                    if [ -f ~/.ssh/id_ed25519 ]; then
                        local key_fingerprint=$(ssh-keygen -lf ~/.ssh/id_ed25519.pub 2>/dev/null | cut -d' ' -f2)
                        status="${C_BRIGHT_GREEN}[${C_BRIGHT_CYAN}ed25519${C_BRIGHT_GREEN}: ${C_GRAY}${key_fingerprint:0:16}...${C_BRIGHT_GREEN}]${C_NONE}"
                    elif [ -f ~/.ssh/id_rsa ]; then
                        local key_fingerprint=$(ssh-keygen -lf ~/.ssh/id_rsa.pub 2>/dev/null | cut -d' ' -f2)
                        status="${C_BRIGHT_GREEN}[${C_BRIGHT_CYAN}rsa${C_BRIGHT_GREEN}: ${C_GRAY}${key_fingerprint:0:16}...${C_BRIGHT_GREEN}]${C_NONE}"
                    else
                        status="${C_BRIGHT_YELLOW}[${C_WHITE}no key found${C_BRIGHT_YELLOW}]${C_NONE}"
                    fi
                    ;;
                "test-github-ssh")
                    # Test and collect all configured accounts
                    local account_names=""
                    local working_accounts=0
                    local total_accounts=0
                    local all_working=true
                    
                    # Test default account
                    total_accounts=$((total_accounts + 1))
                    if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
                        local default_user=$(ssh -T git@github.com 2>&1 | grep "Hi" | cut -d' ' -f2 | tr -d '!')
                        working_accounts=$((working_accounts + 1))
                        account_names="${account_names}${C_BRIGHT_GREEN}• ${default_user}${C_NONE} "
                    else
                        all_working=false
                        account_names="${account_names}${C_BRIGHT_RED}• failed${C_NONE} "
                    fi
                    
                    # Check additional accounts in SSH config
                    if [ -f ~/.ssh/config ]; then
                        local additional_hosts=$(grep -E "^Host\s+github-" ~/.ssh/config | awk '{print $2}')
                        for host in $additional_hosts; do
                            if [[ -n "$host" ]]; then
                                total_accounts=$((total_accounts + 1))
                                local host_result=$(ssh -T "git@${host}" 2>&1)
                                if echo "$host_result" | grep -q "successfully authenticated"; then
                                    local host_user=$(echo "$host_result" | grep "Hi" | cut -d' ' -f2 | tr -d '!')
                                    working_accounts=$((working_accounts + 1))
                                    account_names="${account_names}${C_BRIGHT_GREEN}• ${host_user}${C_NONE} "
                                else
                                    all_working=false
                                    local account_name=$(echo "$host" | sed 's/github-//')
                                    account_names="${account_names}${C_BRIGHT_RED}• ${account_name} (failed)${C_NONE} "
                                fi
                            fi
                        done
                    fi
                    
                    # Set status with account names
                    if [ "$all_working" = true ]; then
                        status="${C_BG_GREEN}${C_WHITE} ✓ ${C_NONE} ${account_names}"
                    elif [ $working_accounts -gt 0 ]; then
                        status="${C_BG_YELLOW}${C_BLACK} ⚠ ${C_NONE} ${account_names}"
                    else
                        status="${C_BG_RED}${C_WHITE} ✗ ${C_NONE} ${account_names}"
                    fi
                    ;;
                "add-another-account")
                    if [ -f ~/.ssh/config ] && grep -q "github-work" ~/.ssh/config; then
                        status="${C_BG_GREEN}${C_WHITE} ✓ ${C_NONE}${C_BRIGHT_GREEN} configured${C_NONE}"
                    else
                        status="${C_BRIGHT_YELLOW}[${C_WHITE}setup additional account${C_BRIGHT_YELLOW}]${C_NONE}"
                    fi
                    ;;
            esac
            echo -e "${C_BRIGHT_BLUE}$((i+1)).${C_NONE} $config $status"
        done
        echo -e "${C_BRIGHT_BLUE}$(( ${#configs[@]} + 1 )).${C_NONE} ✅ ${C_BRIGHT_GREEN}Done with Git configuration${C_NONE}"
        read -p "Enter your choice: " choice
        
        if [[ "$choice" -gt 0 && "$choice" -le "${#configs[@]}" ]]; then
            local config=${configs[$((choice-1))]}
            case $config in
                "user-config")
                    read -p "Enter your Git username: " git_user
                    read -p "Enter your Git email: " git_email
                    git config --global user.name "$git_user"
                    git config --global user.email "$git_email"
                    echo -e "${C_GREEN}Git user configuration completed.${C_NONE}"
                    ;;
                "credential-helper")
                    git config --global credential.helper osxkeychain
                    echo -e "${C_GREEN}Git credential helper configured.${C_NONE}"
                    ;;
                "ssh-key")
                    if [ -f ~/.ssh/id_rsa ] || [ -f ~/.ssh/id_ed25519 ]; then
                        echo -e "${C_GREEN}SSH key already exists${C_NONE}"
                        echo -e "${C_YELLOW}Your SSH public key:${C_NONE}"
                        if [ -f ~/.ssh/id_ed25519.pub ]; then
                            cat ~/.ssh/id_ed25519.pub
                        elif [ -f ~/.ssh/id_rsa.pub ]; then
                            cat ~/.ssh/id_rsa.pub
                        fi
                        echo -e "\n${C_CYAN}To add this key to GitHub:${C_NONE}"
                        echo "1. Copy the key above"
                        echo "2. Go to: https://github.com/settings/ssh/new"
                        echo "3. Paste the key and give it a title"
                        echo "4. Click 'Add SSH key'"
                        echo -e "\n${C_CYAN}To test the connection:${C_NONE}"
                        echo "ssh -T git@github.com"
                    else
                        read -p "Enter your email for SSH key: " ssh_email
                        if run_with_retry "Generating SSH key" ssh-keygen -t ed25519 -C "$ssh_email" -f ~/.ssh/id_ed25519 -N ""; then
                            echo -e "${C_GREEN}SSH key generated successfully!${C_NONE}"
                            echo -e "\n${C_YELLOW}Your SSH public key:${C_NONE}"
                            cat ~/.ssh/id_ed25519.pub
                            echo -e "\n${C_CYAN}IMPORTANT: Add this key to GitHub:${C_NONE}"
                            echo "1. Copy the key above"
                            echo "2. Go to: https://github.com/settings/ssh/new"
                            echo "3. Paste the key and give it a title (e.g., 'MacBook')"
                            echo "4. Click 'Add SSH key'"
                            echo -e "\n${C_CYAN}To test the connection after adding:${C_NONE}"
                            echo "ssh -T git@github.com"
                            
                            # Start SSH agent and add key
                            eval "$(ssh-agent -s)"
                            ssh-add ~/.ssh/id_ed25519
                            echo -e "\n${C_GREEN}SSH key added to SSH agent${C_NONE}"
                        fi
                    fi
                    ;;
                "test-github-ssh")
                    test_github_ssh
                    ;;
                "add-another-account")
                    setup_another_git_account
                    ;;
            esac
        elif [ "$choice" -eq "$((${#configs[@]} + 1))" ]; then
            break
        else
            echo -e "${C_RED}Invalid option.${C_NONE}"
        fi
        read -n 1 -s -r -p "Press any key to continue..."
    done
}

# --- Main Menu Function ---
function main_menu() {
    while true; do
        clear_screen
        echo -e "${C_BRIGHT_YELLOW}📋 Select a setup category:${C_NONE}"
        echo -e "${C_BRIGHT_BLUE}1.${C_NONE} 🍺 ${C_CYAN}Homebrew Setup${C_NONE}"
        echo -e "${C_BRIGHT_BLUE}2.${C_NONE} 💻 ${C_GREEN}Language Runtimes${C_NONE} ${C_GRAY}(Node.js, Ruby, Go, Java, PHP)${C_NONE}"
        echo -e "${C_BRIGHT_BLUE}3.${C_NONE} 🛠️  ${C_PURPLE}CLI Tools${C_NONE} ${C_GRAY}(git, docker, kubectl, etc.)${C_NONE}"
        echo -e "${C_BRIGHT_BLUE}4.${C_NONE} 📱 ${C_BRIGHT_PURPLE}GUI Applications${C_NONE} ${C_GRAY}(VS Code, Chrome, etc.)${C_NONE}"
        echo -e "${C_BRIGHT_BLUE}5.${C_NONE} 🐚 ${C_BRIGHT_CYAN}Shell and AI Tools${C_NONE}"
        echo -e "${C_BRIGHT_BLUE}6.${C_NONE} 🐳 ${C_BLUE}Docker and Databases${C_NONE}"
        echo -e "${C_BRIGHT_BLUE}7.${C_NONE} 🔑 ${C_YELLOW}Git Configuration${C_NONE}"
        echo -e "${C_BRIGHT_BLUE}8.${C_NONE} 🚀 ${C_BRIGHT_GREEN}Run All Categories${C_NONE}"
        echo -e "${C_BRIGHT_BLUE}9.${C_NONE} 👋 ${C_RED}Exit${C_NONE}"
        
        read -p "Enter your choice [1-9]: " choice
        
        case $choice in
            1) check_and_install_brew ;;
            2) setup_language_runtimes ;;
            3) install_cli_tools ;;
            4) install_gui_apps ;;
            5) setup_shell_and_ai_tools ;;
            6) setup_docker_and_databases ;;
            7) configure_git ;;
            8) 
                check_and_install_brew
                setup_language_runtimes
                install_cli_tools
                install_gui_apps
                setup_shell_and_ai_tools
                setup_docker_and_databases
                configure_git
                ;;
            9) echo -e "${C_GREEN}Goodbye!${C_NONE}"; exit 0 ;;
            *) echo -e "${C_RED}Invalid option. Please try again.${C_NONE}" ;;
        esac
        
        if [[ $choice != 9 ]]; then
            echo -e "\n${C_BG_GREEN}${C_WHITE} ✅ Category completed! ${C_NONE}"
            sleep 1.5  # Brief pause to show completion
        fi
    done
}

# --- CLI Argument Handling ---
function show_help() {
    echo -e "${C_CYAN}🚀 QuickDev Setup - Developer Environment Setup Tool${C_NONE}"
    echo "=============================================="
    echo ""
    echo -e "${C_YELLOW}Usage:${C_NONE}"
    echo "  $(basename $0) [options]"
    echo ""
    echo -e "${C_YELLOW}Options:${C_NONE}"
    echo "  -h, --help              Show this help message"
    echo "  -v, --version           Show version information"
    echo "  --auto                  Run all categories automatically (no prompts)"
    echo "  --brew                  Install/update Homebrew only"
    echo "  --languages             Setup language runtimes only"
    echo "  --cli-tools             Install CLI tools only"
    echo "  --gui-apps              Install GUI applications only"
    echo "  --shell-tools           Setup shell and AI tools only"
    echo "  --docker                Setup Docker and databases only"
    echo "  --git                   Configure Git only"
    echo ""
    echo -e "${C_YELLOW}Examples:${C_NONE}"
    echo "  $(basename $0)                    # Interactive menu"
    echo "  $(basename $0) --auto            # Install everything automatically"
    echo "  $(basename $0) --languages       # Setup languages only"
    echo "  $(basename $0) --brew --git      # Install Homebrew and configure Git"
    echo ""
    echo -e "${C_CYAN}For more information, visit: https://github.com/Nagendracse1/quickdev-setup${C_NONE}"
}

function show_version() {
    echo -e "${C_CYAN}QuickDev Setup${C_NONE}"
    echo "Version: 1.0.0"
    echo "Author: Nagendra Kumar"
    echo "License: MIT"
    echo "Repository: https://github.com/Nagendracse1/quickdev-setup"
}

# Parse command line arguments
AUTO_MODE=false
RUN_COMPONENTS=()

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--version)
            show_version
            exit 0
            ;;
        --auto)
            AUTO_MODE=true
            shift
            ;;
        --brew)
            RUN_COMPONENTS+=(brew)
            shift
            ;;
        --languages)
            RUN_COMPONENTS+=(languages)
            shift
            ;;
        --cli-tools)
            RUN_COMPONENTS+=(cli-tools)
            shift
            ;;
        --gui-apps)
            RUN_COMPONENTS+=(gui-apps)
            shift
            ;;
        --shell-tools)
            RUN_COMPONENTS+=(shell-tools)
            shift
            ;;
        --docker)
            RUN_COMPONENTS+=(docker)
            shift
            ;;
        --git)
            RUN_COMPONENTS+=(git)
            shift
            ;;
        *)
            echo -e "${C_RED}❌ Unknown option: $1${C_NONE}"
            echo "Use '--help' for usage information"
            exit 1
            ;;
    esac
done

# --- Main Script Execution ---
echo -e "${C_CYAN}Welcome to QuickDev Setup!${C_NONE}"
echo "This script will help you set up your development environment step by step."
echo ""

# Handle specific component requests
if [ ${#RUN_COMPONENTS[@]} -gt 0 ]; then
    for component in "${RUN_COMPONENTS[@]}"; do
        case $component in
            brew) check_and_install_brew ;;
            languages) setup_language_runtimes ;;
            cli-tools) install_cli_tools ;;
            gui-apps) install_gui_apps ;;
            shell-tools) setup_shell_and_ai_tools ;;
            docker) setup_docker_and_databases ;;
            git) configure_git ;;
        esac
    done
elif [ "$AUTO_MODE" = true ]; then
    echo -e "${C_YELLOW}🤖 Running in automatic mode - installing everything...${C_NONE}"
    check_and_install_brew
    setup_language_runtimes
    install_cli_tools
    install_gui_apps
    setup_shell_and_ai_tools
    setup_docker_and_databases
    configure_git
elif ask_yes_no "Do you want to use the interactive menu?" "y"; then
    main_menu
else
    echo -e "${C_YELLOW}🤖 Running all categories automatically...${C_NONE}"
    check_and_install_brew
    setup_language_runtimes
    install_cli_tools
    install_gui_apps
    setup_shell_and_ai_tools
    setup_docker_and_databases
    configure_git
fi

echo -e "\n✅ ${C_GREEN}Setup is complete! Please restart your terminal for all changes to take effect.${C_NONE}"