#!/bin/bash

# Dotfiels and defaults script for OSX
# by Tad Swider
set -eu

intro()  {
  version="$(sw_vers -productVersion)"
  printf "%b" "$(tput setaf 5)\n[MacOS $version Setup Script]\n"
}

icloud_check() {
  # Check for iCloud Directory
  if [[ -d $HOME'/Library/Mobile Documents/com~apple~CloudDocs' ]]; then
    base_dir=$HOME'/Library/Mobile Documents/com~apple~CloudDocs'
    
    # Set default dirs/files
    dotfiles_dir="$base_dir/Dotfiles/"
    macsetup_dir="$base_dir/Code/macsetup"
    helper_file="$base_dir/Code/macsetup/helper.sh"
  else
    printf "%b" "$(tput setaf 1)\n[✖] This script is meant for OSX with iCloud. Aborting...$(tput sgr0)"
    exit 1
  fi
}

macsetup_check() {
  # Check for MacSetup Directoriy
  if [[ -d $macsetup_dir ]]; then
    printf "%b" "$(tput setaf 5) • Using helper script from iCloud directory\n$(tput sgr0)"
    # Source helper.sh
    source "$helper_file" || { printf "%b" "$(tput setaf 1)\n[✖] Could not source helper file. Aborting..."; exit 1; }
  else
    printf "%b" "$(tput setaf 5)\n • Downloading helper file$(tput sgr0)"
    mkd "$macsetup_dir"
    # Download macsetup files from git
    curl --progress-bar "https://raw.githubusercontent.com/tadone/macsetup/master/helper.sh" -o "$macsetup_dir/helper.sh"
    curl --progress-bar "https://raw.githubusercontent.com/tadone/macsetup/master/defaults.sh" -o "$macsetup_dir/defaults.sh"
    curl --progress-bar "https://raw.githubusercontent.com/tadone/macsetup/master/apps.sh" -o "$macsetup_dir/apps.sh"
    # Source helper.sh
    source "$helper_file" || { printf "%b" "$(tput setaf 1)\n[✖] Could not source helper file. Aborting..."; exit 1; }
  fi
}

prevent_sleep() {
  # Prevent System Sleep
  /usr/bin/caffeinate -dimu -w $$ &
}

sudoers_add() {
  /usr/bin/sudo -E -v || exit 1
  USER_SUDOER="${USER} ALL=(ALL) NOPASSWD: ALL"

  printf "%b" "$(tput setaf 5)\n • Adding $USER to /etc/sudoers for the duration of the script\n"
  echo "${USER_SUDOER}" | /usr/bin/sudo -E -- /usr/bin/tee -a /etc/sudoers >/dev/null
}

sudoers_remove() {
  print_in_purple "\n • Removing $USER from /etc/sudoers\n"
  /usr/bin/sudo -E -- /usr/bin/sed -i '' "/^${USER_SUDOER}/d" /etc/sudoers
}

xcode() {
  # Install XCode Command Line Tools
  print_in_purple "\n • Installing XCODE\n"
  
  if ! xcode-select --print-path &> /dev/null; then
    xcode-select --install &> /dev/null || { print_error "Could not install XCode. Aborting..."; exit 1; }
    
    until xcode-select --print-path &> /dev/null; do
      echo "Waiting for XCode to install..."
      sleep 5
    done    
  
  else
    print_success "Xcode Command Line Tools Installed"
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
  if ! cmd_exists "brew"; then
      # Install Homebrew & Update Homebrew
    print_in_purple "\n • Installing Homebrew\n"
    printf "\n" | ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" &> /dev/null
          #  └─ simulate the ENTER keypress
  else
    print_in_purple "\n • Updating Homebrew\n"
    # execute "brew update" "Homebrew Updated"
  fi
}

homebrew_apps() {
  # Install Apps with Homebrew
  print_in_purple "\n • Installing Apps with Homebrew & Mas"
  if [[ -e "$macsetup_dir/apps.sh" ]]; then
    bash "$macsetup_dir/apps.sh"
  else
    print_error "The apps.sh file not found. Aborting..."
    exit 1    
  fi
}


zsh_shell() {
  # Change to ZSH
  local brew_path=$(brew --prefix)
  local zsh_path="$brew_path/bin/zsh"

  print_in_purple "\n • Adding ZSH to /etc/shells\n"
  if ! grep "$zsh_path" < /etc/shells &> /dev/null; then
    printf '%s\n' "$zsh_path" | sudo tee -a /etc/shells
  else
    print_success "ZSH already exists in /etc/shells"
  fi
  print_in_purple "\n • Changing ${USER}'s default shell to ZSH\n"
  execute "sudo chsh -s $zsh_path ${USER} &> /dev/null" "Default shell changed to ZSH" # Change default shell to ZSH
}

prezto() {
  # Install Prezto (ZSH configuration framework)
  print_in_purple "\n • Seting up Presto ZSH framework\n"
  if [[ ! -d "$HOME/.zprezto" ]]; then
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
    # Create links to zsh config files
    local ZFILES=(zlogin zlogout zpreztorc zprofile zshenv zshrc)
    for file in "${ZFILES[@]}";do
      execute "ln -s $HOME/.zprezto/runcoms/${file} ${HOME}/.${file}" "Link ${file}"
    done
  else
    print_in_green "\n • Prezto already installed. Pulling latest changes from repository\n"
    execute 'git -C "$HOME/.zprezto" pull --quiet' "Git pull"
    execute 'git -C "$HOME/.zprezto" submodule update --init --recursive --quiet' "Git submodule update"
    # print_result $? "Presto update"
  fi
  # Docker completion for Prezto ZSH  
  execute 'curl -fLo ~/.zprezto/modules/completion/external/src/_docker \
    https://raw.github.com/felixr/docker-zsh-completion/master/_docker' "Pull docker completions"
}

clone_dotfiles() {
  print_in_purple "\n • Cloning dotfiles\n"
  git_clone "https://github.com/tadone/dotfiles" "$dotfiles_dir" "Dotfiles cloned to $dotfiles_dir"
}

link_dotfiles() {
  # Create Links from dotfiles
  print_in_purple "\n • Linking dotfiles\n"

  execute 'ln -sf "$dotfiles_dir/vimrc-mac" "$HOME/.vimrc"' "Linked vimrc-mac"
  execute 'ln -sf "$dotfiles_dir/zpreztorc" "$HOME/.zshrc"' "Linked zpreztorc"
  execute 'ln -sf "$dotfiles_dir/pure.zsh" "$HOME/.zprezto/modules/prompt/external/pure/pure.zsh"' "Linked pure.zsh"
  execute 'ln -sf "$dotfiles_dir/zshrc" "$HOME/.zshrc"' "Linked zshrc"
  execute 'ln -sf "$dotfiles_dir/ssh_config" "$HOME/.ssh/config"' "Linked zshrc"
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
icloud_check
macsetup_check
xcode
macos_defaults
homebrew
homebrew_apps
zsh_shell
prezto
[ ! -d "$dotfiles_dir" ] && clone_dotfiles
link_dotfiles
vscode_setup
sudoers_remove

# Done
print_in_green "\n • Finished!!!\n"