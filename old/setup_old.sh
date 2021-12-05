#!/bin/bash

# Dotfiels and defaults script for OSX
# by Tad Swider
set -eu

GREEN="\u001b[32m"
YELLOW="\u001b[33m"
MAGENTA="\u001b[35m"
RESET="\u001b[0m" 

intro()  {
  version="$(sw_vers -productVersion)"
  echo -e "${MAGENTA}MacOS $version Setup Script\n${RESET}"
}

default_dirs() {
  # Check for iCloud Directory
  if [[ -d $HOME'/Library/Mobile Documents/com~apple~CloudDocs' ]]; then
    base_dir=$HOME'/Library/Mobile Documents/com~apple~CloudDocs'
    # Set default dirs/files
    export dotfiles_dir="$base_dir/Dotfiles"
    export macsetup_dir="$base_dir/Code/macsetup"
    # export helper_file="$base_dir/Code/macsetup/helper.sh"
  
  else
    echo -e "${YELLOW}This script is meant for OSX with iCloud. Aborting...${RESET}"
    exit 1
  fi
}

# macsetup_check() {
#   # Check for MacSetup Directoriy
#   if [[ -d $macsetup_dir ]]; then
#     printf "%b" "$(tput setaf 5) • Using helper script from iCloud directory\n$(tput sgr0)"
#     # Source helper.sh
#     source "$helper_file" || { printf "%b" "$(tput setaf 1)\n[✖] Could not source helper file. Aborting..."; exit 1; }
#   else
#     printf "%b" "$(tput setaf 5)\n • Downloading helper file$(tput sgr0)"
#     mkd "$macsetup_dir"
#     # Download macsetup files from git
#     curl --progress-bar "https://raw.githubusercontent.com/tadone/macsetup/master/helper.sh" -o "$macsetup_dir/helper.sh"
#     curl --progress-bar "https://raw.githubusercontent.com/tadone/macsetup/master/defaults.sh" -o "$macsetup_dir/defaults.sh"
#     curl --progress-bar "https://raw.githubusercontent.com/tadone/macsetup/master/apps.sh" -o "$macsetup_dir/apps.sh"
#     # Source helper.sh
#     source "$helper_file" || { printf "%b" "$(tput setaf 1)\n[✖] Could not source helper file. Aborting..."; exit 1; }
#   fi
# }

prevent_sleep() {
  # Prevent System Sleep
  /usr/bin/caffeinate -dimu -w $$ &
}

sudoers_add() {
  /usr/bin/sudo -v || exit 1
  USER_SUDOER="${USER} ALL=(ALL) NOPASSWD: ALL"

  echo -e "${GREEN}Adding $USER to /etc/sudoers for the duration of the script\n${RESET}"
  echo "${USER_SUDOER}" | /usr/bin/sudo -E -- /usr/bin/tee -a /etc/sudoers >/dev/null
}

sudoers_remove() {
  echo -e "${GREEN}Removing $USER from /etc/sudoers\n${RESET}"
  /usr/bin/sudo -E -- /usr/bin/sed -i '' "/^${USER_SUDOER}/d" /etc/sudoers
}

xcode() {
  # Install XCode Command Line Tools
  echo -e "${GREEN}Installing XCODE\n${RESET}"
  
  if ! xcode-select --print-path &> /dev/null; then
    xcode-select --install &> /dev/null || { print_error "Could not install XCode. Aborting..."; exit 1; }
    
    until xcode-select --print-path &> /dev/null; do
      echo "Waiting for XCode to install..."
      sleep 5
    done    
  
  else
    echo -e "${GREEN}Xcode Command Line Tools Installed\n${RESET}"
  fi
}

macos_defaults() {
  # MacOS Defaults
  if [[ -e "$macsetup_dir/defaults.sh" ]]; then
    print_in_purple "\n • Setting OSX Defaults\n"
    bash "$macsetup_dir/defaults.sh"
  else
    print_error "The defaults.sh file not found. Aborting..."
    exit 1
  fi
}

homebrew() {
  if ! hash "brew"; then
    # Install Homebrew & Update Homebrew
    echo -e "${GREEN}Installing Homebrew\n${RESET}"
    homebrew_dir="/usr/local"
    if [ ! -d "$homebrew_dir" ]; then mkdir /usr/local; fi
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      # Install brew apps
      if [ -f Brewfile ]; then
      echo -e "${GREEN}Installing Homebrew Apps${RESET}"
      brew bundle
      fi
  else
    echo -e "${GREEN}Upgrading Homebrew Apps\n${RESET}"
    brew upgrade
  fi
}


zsh_shell() {
  # Change to ZSH
  local brew_path=$(brew --prefix)
  local zsh_path="$brew_path/bin/zsh"

  echo -e "${GREEN}Adding ZSH to /etc/shells\n${RESET}"
  if ! grep "$zsh_path" < /etc/shells &> /dev/null; then
    printf '%s\n' "$zsh_path" | sudo tee -a /etc/shells
  else
    echo -e "${GREEN}ZSH already exists in /etc/shells\n${RESET}"
  fi
  echo -e "${MAGENTA}Changing ${USER}'s default shell to ZSH\n${RESET}"
  sudo chsh -s $zsh_path ${USER}
}

prezto() {
  # Install Prezto (ZSH configuration framework)
  echo -e "${GREEN}Seting up Presto ZSH framework\n${RESET}"
  if [[ ! -d "$HOME/.zprezto" ]]; then
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
    # Create links to zsh config files
    local ZFILES=(zlogin zlogout zpreztorc zprofile zshenv zshrc)
    for file in "${ZFILES[@]}";do
      ln -s "$HOME/.zprezto/runcoms/${file}" "${HOME}/.${file}"
    done
  else
    echo -e "${GREEN}Prezto already installed. Pulling latest changes from repository\n${RESET}"
    git -C "$HOME/.zprezto" pull --quiet
    git -C "$HOME/.zprezto" submodule update --init --recursive --quiet
  fi
  # Docker completion for Prezto ZSH
  curl -fLo ~/.zprezto/modules/completion/external/src/_docker \
    https://raw.github.com/felixr/docker-zsh-completion/master/_docker
}

# clone_dotfiles() {
#   print_in_purple "\n • Cloning dotfiles\n"
#   git_clone "https://github.com/tadone/dotfiles" "$dotfiles_dir" "Dotfiles cloned to $dotfiles_dir"
# }

link_dotfiles() {
  # Create Links from dotfiles
  echo -e "${GREEN}Linking dotfiles\n${RESET}"

  ln -sf "$dotfiles_dir/vimrc-mac" "$HOME/.vimrc"
  ln -sf "$dotfiles_dir/zpreztorc" "$HOME/.zpreztorc"
  ln -sf "$dotfiles_dir/pure.zsh" "$HOME/.zprezto/modules/prompt/external/pure/pure.zsh"
  ln -sf "$dotfiles_dir/zshrc" "$HOME/.zshrc"
  if [ ! -d "$HOME/.ssh" ]; then mkd "$HOME/.ssh";fi
  ln -sf "$dotfiles_dir/ssh_config" "$HOME/.ssh/config"
  ln -sf "$dotfiles_dir/gitconfig" "$HOME/.gitconfig"
}

vscode_setup() {
  print_in_purple "\n • Setting up VS Code\n"
  if hash code; then
    for line in $(cat "${dotfiles_dir}"/vscode_extensions.txt | grep -v '^#'); do 
      execute "code --install-extension $line" "Extension: $line"
    done
    echo ""
    execute 'ln -sf "$dotfiles_dir/vscode_settings.json" "$HOME/Library/Application Support/Code/User/settings.json"' "Linked VS Codes settings.json"
  else
    print_in_green "Visual Studio Code not installed. Skipping..."
  fi    
}

### MAIN ###
# Trap Ctrl-C
trap 'trap "" INT; print_error "Aborting..."; exit 1' INT

# Ask for the administrator password upfront.
intro
sudoers_add
prevent_sleep
default_dirs
macsetup_check
xcode
macos_defaults
homebrew
zsh_shell
prezto
# [ ! -d "$dotfiles_dir" ] && clone_dotfiles
link_dotfiles
#vscode_setup
sudoers_remove

# Done
print_in_green "\n • Finished!!!\n"