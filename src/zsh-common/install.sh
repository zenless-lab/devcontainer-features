#!/bin/bash

set -e

# Read the options
set_default=${SET_DEFAULT:-false}
install_powerlevel10k=${INSTALL_POWERLEVEL10K:-false}
install=${INSTALL:-""}
skip=${SKIP:-""}
accept_suggest_key=${ACCEPT_SUGGEST_KEY:"^ "}

remote_user_home=$(eval echo ~$_REMOTE_USER)

# Convert comma-separated strings to arrays
IFS=',' read -r -a install_array <<< "$install"
IFS=',' read -r -a skip_array <<< "$skip"

# Define all possible plugins
declare -A plugins
plugins=(
    ["fzf"]="https://github.com/junegunn/fzf"
    # ["fzf-tab"]="https://github.com/Aloxaf/fzf-tab"
    ["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions"
    ["zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting"
    ["zsh-completions"]="https://github.com/zsh-users/zsh-completions"
    ["sudo"]=""
    ["z"]=""
    ["safe-paste"]=""
    ["web-search"]=""
)

# Install zsh and plugins
echo "Installing zsh and plugins..."
./multi_install.sh zsh git curl sudo

# Install oh-my-zsh, if not already installed
if [ ! -d $remote_user_home/.oh-my-zsh ]; then
    echo "Installing oh-my-zsh..."
    sudo -u $_REMOTE_USER sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Function to install a plugin
install_plugin() {
    local plugin=$1
    local url=${plugins[$plugin]}
    if [ -n "$url" ]; then
        if [ "$plugin" == "fzf" ]; then
            sudo -u $_REMOTE_USER git clone --depth 1 https://github.com/junegunn/fzf.git $remote_user_home/.fzf
            sudo -u $_REMOTE_USER $remote_user_home/.fzf/install --all
        else
            sudo -u $_REMOTE_USER git clone $url ${ZSH_CUSTOM:-$remote_user_home/.oh-my-zsh/custom}/plugins/$plugin
        fi
    fi
}

# Determine which plugins to install
if [ ${#install_array[@]} -gt 0 ]; then
    plugins_to_install=("${install_array[@]}")
else
    plugins_to_install=("${!plugins[@]}")
fi

# Remove skipped plugins
for skip_plugin in "${skip_array[@]}"; do
    plugins_to_install=("${plugins_to_install[@]/$skip_plugin}")
done

echo "Plugins to install: ${plugins_to_install[@]} for $_REMOTE_USER in $remote_user_home"

# Install and configure plugins
echo "Configuring zsh plugins..."
for plugin in "${plugins_to_install[@]}"; do
    echo "Installing $plugin..."
    if ! sudo -u $_REMOTE_USER grep -q "plugins=.*$plugin" $remote_user_home/.zshrc; then
        install_plugin $plugin
        sudo -u $_REMOTE_USER sed -i "s/plugins=(\(.*\))/plugins=(\1 $plugin)/" $remote_user_home/.zshrc
    else
        echo "$plugin already installed."
    fi
    echo "$plugin installed."
done

# Install and configure Powerlevel10k if the option is enabled
if $install_powerlevel10k; then
    echo "Installing Powerlevel10k prompt..."
    sudo -u $_REMOTE_USER git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$remote_user_home/.oh-my-zsh/custom}/themes/powerlevel10k
    sudo -u $_REMOTE_USER sed -i 's/ZSH_THEME=".*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' $remote_user_home/.zshrc
    echo "Powerlevel10k installed."
fi


# Set zsh as the default shell if set_default is true
if $set_default; then
    echo "Setting zsh as the default shell..."
    
    # if no which command available
    if ! command -v which &> /dev/null; then
        echo "which command not found, installing..."
        ./multi_install.sh which
    fi

    chsh -s $(which zsh) $_REMOTE_USER
    echo "Zsh set as the default shell."
fi

# Bind autosuggestions key, when autosuggestions are installed
echo "Configuring autosuggestions..."
echo 'ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#808080"' >> $remote_user_home/.zshrc
echo "Setting autosuggestions highlight style to fg=#808080"

if [ -n "$accept_suggest_key" ]; then
    echo "Binding autosuggestions key..."
    if ! sudo -u $_REMOTE_USER grep -q "bindkey \"$accept_suggest_key\" autosuggest-accept" $remote_user_home/.zshrc; then
        sudo -u $_REMOTE_USER echo "bindkey \"$accept_suggest_key\" autosuggest-accept" >> $remote_user_home/.zshrc
    fi
    echo "Autosuggestions key bound."
fi

echo "Zsh and plugins installation complete for $_REMOTE_USER."