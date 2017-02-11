#!/bin/bash -x

helper_url="https://raw.githubusercontent.com/tadone/dotfiles-tad/master/helper.sh"
dotfiles_dir="$HOME/Projects/dotfiles"
the_user=$(whoami)

# Helper Functions
printf "\n • Get file containing helper functions\n\n"
if [[ -e "/tmp/helper.sh" ]]; then
  . "/tmp/helper.sh" || exit
  print_in_purple "\n • Helper file loaded\n\n"
else
  curl --progress-bar $helper_url -o /tmp/helper.sh && . "/tmp/helper.sh" || \
  exit
fi

# Ask for the administrator password upfront.
ask_for_sudo
#sudo -v <$ echo "$PASSWORD"

# Install XCode Command Line Tools
if ! xcode-select --print-path &> /dev/null; then
  xcode-select --install &> /dev/null || exit
else
  print_success "Xcode Command Line Tools Installed"
fi

until [[ "xcode-select --print-path" ]]; do
  sleep 5
done

# Install Homebrew & Update Homebrew
if ! cmd_exists "brew"; then
  printf "\n" | ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" &> /dev/null
        #  └─ simulate the ENTER keypress
else
  print_in_purple "\n • Updating Homebrew\n\n"
  execute "brew update" "Homebrew Updated" && \
  execute "brew upgrade" "Homebrew Upgraded"
fi

# Install essentials with Homebrew
brew_install () {
    brew install $1
}

execute "brew_install git" "Git Installed"
execute "brew_install zsh" "ZSH Installed"

# Change to ZSH
brew_path=$(brew --prefix)
zsh_path="$brew_path/bin/zsh"

if ! grep "$zsh_path" < /etc/shells &> /dev/null; then
  printf '%s\n' "$zsh_path" | sudo tee -a /etc/shells
else
  print_success "$zsh_path already exists in /etc/shells"
fi

print_in_purple "\n • Changing to ZSH\n\n"
chsh -s "$zsh_path" <& echo "$PASSWORD" #&> /dev/null # Change default shell to ZSH

# Clone and link dotfiles

if cmd_exists "git"; then
  if [[ ! -d "$dotfiles_dir" ]]; then
    mkdir "$dotfiles_dir" && \
    execute "git clone https://github.com/tadone/dotfiles-tad $dotfiles_dir" "Cloned dotfiles to $dotfiles_dir"
  else
    print_warning "$dotfiles_dir directory already exists"
    print_warning "Please run Git Pull to update files."
  fi
fi

# Install Apps with Homebrew
if [[ -x "$PWD/apps.sh" ]]; then
  . "$PWD/apps.sh" || exit
else
  print_error "Can't access apps.sh"
fi


print_in_green "\n • Finished!!!\n\n"
