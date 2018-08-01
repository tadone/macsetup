#!/bin/bash

export helper_url="https://raw.githubusercontent.com/tadone/macsetup/master/helper.sh"
export dotfiles_dir="$HOME/Projects/dotfiles"
export macsetup_dir="$HOME/Projects/macsetup"
export the_user=$(whoami)

# Helper Functions
PURPLE=$(tput setaf 5)
NORMALL=$(tput sgr0)
printf "%b" "$PURPLE\n • Get file containing helper functions\n\n$NORMALL"
curl --progress-bar $helper_url -o /tmp/helper.sh && . "/tmp/helper.sh" || exit

# Ask for the administrator password upfront.
ask_for_sudo
#sudo -v <$ echo "$PASSWORD"

# Install XCode Command Line Tools
print_in_purple "\n • Installing XCODE\n\n"
if ! xcode-select --print-path &> /dev/null; then
  xcode-select --install &> /dev/null || exit
else
  print_success "Xcode Command Line Tools Installed"
fi

until [[ "xcode-select --print-path" ]]; do
  sleep 5
done

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

# Install essentials with Homebrew

brew_install "Git" "git"
brew_install "ZSH" "zsh"
brew_install "ZSH Completions" "zsh-completions"

# Change to ZSH
print_in_purple "\n • Changing to ZSH\n\n"

brew_path=$(brew --prefix)
zsh_path="$brew_path/bin/zsh"

if ! grep "$zsh_path" < /etc/shells &> /dev/null; then
  printf '%s\n' "$zsh_path" | sudo tee -a /etc/shells
else
  print_success "$zsh_path already exists in /etc/shells"
fi

sudo chsh -s "$zsh_path" "$the_user" &> /dev/null # Change default shell to ZSH

# Install Prezto (ZSH configuration framework)
print_in_purple "\n • Seting up Presto ZSH framework"
if [[ ! -d "$HOME/.zprezto" ]]; then
  git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
  # Create links to zsh config files
  ln -s ~/.zprezto/runcoms/zlogin ~/.zlogin
  ln -s ~/.zprezto/runcoms/zlogout ~/.zlogout
  ln -s ~/.zprezto/runcoms/zpreztorc ~/.zpreztorc
  ln -s ~/.zprezto/runcoms/zprofile ~/.zprofile
  ln -s ~/.zprezto/runcoms/zshenv ~/.zshenv
  ln -s ~/.zprezto/runcoms/zshrc ~/.zshrc
else
  print_in_green "\n • Prezto already installed. Pulling latest changes from repository\n\n"
  git -C "$HOME/.zprezto" pull && git -C "$HOME/.zprezto" submodule update --init --recursive &> /dev/null/
  print_result $? "Presto update"
fi

# Clone dotfiles & macsetup
print_in_purple "\n • Cloning Git dotfiles & macsetup\n\n"
git_clone "https://github.com/tadone/dotfiles" "$dotfiles_dir" "Dotfiles cloned to $dotfiles_dir"
git_clone "https://github.com/tadone/macsetup" "$macsetup_dir" "Macsetup cloned to $macsetup_dir"

# Install Apps with Homebrew
if [[ -e "$macsetup_dir/apps.sh" ]]; then
  "$zsh_path" "$macsetup_dir/apps.sh" || exit
else
  print_error "Can't access apps.sh"
  exit
fi

# MacOS Defaults
if [[ -e "$macsetup_dir/macos.sh" ]]; then
  "$zsh_path" "$macsetup_dir/macos.sh" || exit
else
  print_error "Can't access macos.sh"
  exit
fi
# Install Atom packages with apm
apm install --packages-file "$dotfiles_dir/work-package-list.txt"
# Create Links from dotfiles
print_in_purple "\n • Linking from dotfiles\n\n"
execute 'ln -sf "$dotfiles_dir/vimrc-mac" "$HOME/.vimrc"' "Linked vimrc-mac"
execute 'ln -sf "$dotfiles_dir/zshrc" "$HOME/.zshrc"' "Linked zshrc"
# Docker completion for Prezto ZSH
execute 'curl -fLo ~/.zprezto/modules/completion/external/src/_docker \
  https://raw.github.com/felixr/docker-zsh-completion/master/_docker'

print_in_green "\n • Finished!!!\n\n"
