#!/bin/bash

if [[ -d $HOME'/Library/Mobile Documents/com~apple~CloudDocs' ]]; then
  icloud_dir=$HOME'/Library/Mobile Documents/com~apple~CloudDocs'
else
  printf "%b" "$(tput setaf 3)\n   [?] iCloud directory not found$(tput sgr0)" 
fi

if [[ -d $icloud_dir/Dotfiles ]]; then
  export helper_file="$icloud_dir/Code/macsetup/helper.sh" && source "$helper_file"
  export macsetup_dir="$icloud_dir/Code/macsetup"
  export dotfiles_dir="$icloud_dir/Dotfiles/"
else
  printf "%b" "$(tput setaf 5)\n • Downloading helper file$(tput sgr0)"
  helper_url="https://raw.githubusercontent.com/tadone/macsetup/master/helper.sh"
  curl --progress-bar $helper_url -o /tmp/helper.sh && source "/tmp/helper.sh" || { print_error "Could not download helper file. Aborting..."; exit 1; }
fi

prevent_sleep() {
  # Prevent System Sleep
  /usr/bin/caffeinate -dimu -w $$ &
}

sudoers_add() {
  /usr/bin/sudo -E -v || exit 1
  USER_SUDOER="${USER} ALL=(ALL) NOPASSWD: ALL"

  print_in_purple "Adding $USER to /etc/sudoers for the duration of the script"
  echo "${USER_SUDOER}" | /usr/bin/sudo -E -- /usr/bin/tee -a /etc/sudoers >/dev/null
}

sudoers_remove() {
  print_in_purple "Removing $USER from /etc/sudoers"
  /usr/bin/sudo -E -- /usr/bin/sed -i '' "/^${USER_SUDOER}/d" /etc/sudoers
}

xcode() {
  # Install XCode Command Line Tools
  print_in_purple "\n • Installing XCODE\n\n"
  
  if ! xcode-select --print-path &> /dev/null; then
    xcode-select --install &> /dev/null || { print_error "Could not install XCode. Aborting..."; exit 1; }
  else
    print_success "Xcode Command Line Tools Installed"
  fi

  until xcode-select --print-path; do
    echo "Waiting for XCode to install..."
    sleep 5
  done
}

macos_defaults() {
  # MacOS Defaults
  if [[ -e "$macsetup_dir/macos.sh" ]]; then
    "$macsetup_dir/macos.sh"
  else
    print_error "The macos.sh file not found. Aborting..."
    exit 1
  fi
}

homebrew() {
  # Install Homebrew & Update Homebrew
  print_in_purple "\n • Installing Homebrew\n\n"

  if ! cmd_exists "brew"; then
    printf "\n" | ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" &> /dev/null
          #  └─ simulate the ENTER keypress
  else
    print_in_purple "\n • Updating Homebrew\n\n"
    execute "brew update" "Homebrew Updated" && \
    execute "brew upgrade" "Homebrew Upgraded"
  fi
}

homebrew_apps() {
  # Install Apps with Homebrew
  if [[ -e "$macsetup_dir/apps.sh" ]]; then
    "$macsetup_dir/apps.sh"
  else
    print_error "The apps.sh file not found. Aborting..."
    exit 1    
  fi
}


zsh_shell() {
  # Change to ZSH
  local brew_path=$(brew --prefix)
  local zsh_path="$brew_path/bin/zsh"

  if ! grep "$zsh_path" < /etc/shells &> /dev/null; then
    print_in_purple "\n • Adding ZSH to /etc/shells\n\n"
    printf '%s\n' "$zsh_path" | sudo tee -a /etc/shells
  else
    print_success "$zsh_path already exists in /etc/shells"
  fi
  print_in_purple "\n • Changing ${USER}'s default shell to ZSH\n\n"
  sudo chsh -s "$zsh_path" "${USER}" &> /dev/null # Change default shell to ZSH
}

prezto() {
  # Install Prezto (ZSH configuration framework)
  print_in_purple "\n • Seting up Presto ZSH framework\n\n"
  if [[ ! -d "$HOME/.zprezto" ]]; then
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
    # Create links to zsh config files
    ZFILES=(zlogin zlogout zpreztorc zprofile zshenv zshrc)
    for file in "${ZFILES[@]}";do
      execute "ln -s $HOME/.zprezto/runcoms/${file} ${HOME}/.${file}" "Link ${file}"
    done
  else
    print_in_green "\n • Prezto already installed. Pulling latest changes from repository\n\n"
    git -C "$HOME/.zprezto" pull && git -C "$HOME/.zprezto" submodule update --init --recursive &> /dev/null/
    print_result $? "Presto update"
  fi  
}

link_dotfiles() {
  # Create Links from dotfiles
  print_in_purple "\n • Linking dotfiles\n\n"

  execute 'ln -sf "$dotfiles_dir/vimrc-mac" "$HOME/.vimrc"' "Linked vimrc-mac"
  execute 'ln -sf "$dotfiles_dir/zpreztorc" "$HOME/.zshrc"' "Linked zpreztorc"
  execute 'ln -sf "$dotfiles_dir/pure.zsh" "$HOME/.zprezto/modules/prompt/external/pure/pure.zsh"' "Linked pure.zsh"
  execute 'ln -sf "$dotfiles_dir/zshrc" "$HOME/.zshrc"' "Linked zshrc"
  execute 'ln -sf "$dotfiles_dir/ssh_config" "$HOME/.ssh/config"' "Linked zshrc"
}

# Clone dotfiles & macsetup
print_in_purple "\n • Cloning Git dotfiles & macsetup\n\n"
git_clone "https://github.com/tadone/dotfiles" "$dotfiles_dir" "Dotfiles cloned to $dotfiles_dir"
git_clone "https://github.com/tadone/macsetup" "$macsetup_dir" "Macsetup cloned to $macsetup_dir"


# Docker completion for Prezto ZSH
execute 'curl -fLo ~/.zprezto/modules/completion/external/src/_docker \
  https://raw.github.com/felixr/docker-zsh-completion/master/_docker'

### MAIN ###

# Ask for the administrator password upfront.
prevent_sleep
sudoers_add
xcode
macos_defaults
homebrew
homebrew_apps
zsh_shell
prezto
link_dotfiles
sudoers_remove

# Done
print_in_green "\n • Finished!!!\n\n"