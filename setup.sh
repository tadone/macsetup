#!/bin/bash

# Dotfiels and defaults script for OSX
# by Tad Swider
set -eu

GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
MAGENTA=$(tput setaf 5)
RESET=$(tput sgr0)

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
DOTFILES="$HOME/Code/dotfiles"
MACSETUP="$HOME/Code/macsetup"

intro()  {
  version="$(sw_vers -productVersion)"
  echo -e "\n${MAGENTA}MacOS $version Setup Script${RESET}"
}

macsetup_files() {
  echo -e "${GREEN}Downloading setup files to /tmp\n${RESET}"
  curl --progress-bar "https://raw.githubusercontent.com/tadone/macsetup/master/osx_settings.sh" -o "/tmp/osx_settings.sh"
  curl --progress-bar "https://raw.githubusercontent.com/tadone/macsetup/master/Brewfile" -o "/tmp/Brewfile"
}

# macsetup_check() {
#   # Check for MacSetup Directoriy
#   if [[ -d $SCRIPT_DIR ]]; then
#     printf "%b" "$(tput setaf 5) • Using helper script from iCloud directory\n$(tput sgr0)"
#     # Source helper.sh
#     source "$helper_file" || { printf "%b" "$(tput setaf 1)\n[✖] Could not source helper file. Aborting..."; exit 1; }
#   else
#     printf "%b" "$(tput setaf 5)\n • Downloading helper file$(tput sgr0)"
#     mkd "$SCRIPT_DIR"
#     # Download macsetup files from git
#     curl --progress-bar "https://raw.githubusercontent.com/tadone/macsetup/master/helper.sh" -o "$SCRIPT_DIR/helper.sh"
#     curl --progress-bar "https://raw.githubusercontent.com/tadone/macsetup/master/defaults.sh" -o "$SCRIPT_DIR/defaults.sh"
#     curl --progress-bar "https://raw.githubusercontent.com/tadone/macsetup/master/apps.sh" -o "$SCRIPT_DIR/apps.sh"
#     # Source helper.sh
#     source "$helper_file" || { printf "%b" "$(tput setaf 1)\n[✖] Could not source helper file. Aborting..."; exit 1; }
#   fi
# }

prevent_sleep() {
  # Prevent System Sleep
  /usr/bin/caffeinate -dimu -w $$ &
}

sudoers_add() {
  echo -e "${GREEN}Adding $USER to /etc/sudoers for the duration of the script\n${RESET}"
  # Ensure sudo
  /usr/bin/sudo -v || exit 1

  USER_SUDOER="${USER} ALL=(ALL) NOPASSWD: ALL"
  echo "${USER_SUDOER}" | /usr/bin/sudo -E -- /usr/bin/tee -a /etc/sudoers >/dev/null
}

# sudoers_remove() {
#   echo -e "${GREEN}Removing $USER from /etc/sudoers\n${RESET}"
#   /usr/bin/sudo -E -- /usr/bin/sed -i '' "/^${USER_SUDOER}/d" /etc/sudoers
# }

xcode() {
  # Install XCode Command Line Tools
  echo -e "${GREEN}Installing XCODE${RESET}"

  if ! xcode-select --print-path &> /dev/null; then
    xcode-select --install &> /dev/null || { echo -e "${YELLOW}Could not install XCode. Aborting...${RESET}"; exit 1; }

    until xcode-select --print-path &> /dev/null; do
      echo "Waiting for XCode to install..."
      sleep 5
    done

  else
    echo -e "${GREEN} - Xcode Command Line Tools Installed${RESET}"
  fi
}

osx_settings() {
  # MacOS Defaults
  if [[ -e "$SCRIPT_DIR/osx_settings.sh" ]]; then
    echo -e "${GREEN}Setting OSX Defaults${RESET}"
    bash "$SCRIPT_DIR/osx_settings.sh"
  else
    echo -e "${YELLOW}The osx_settings.sh file not found. Aborting..."
    exit 1
  fi
}

homebrew() {
  if ! hash "brew"; then

    # Install Homebrew
    echo -e "${GREEN}Installing Homebrew${RESET}"
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Set path
    eval "$(/opt/homebrew/bin/brew shellenv)"

  else
    echo -e "${GREEN}Upgrading Homebrew Apps${RESET}"
    brew upgrade
  fi
}

homebrew_apps() {
  # Install brew apps
  if hash "brew"; then

    if [ -f "/tmp/Brewfile" ]; then
      echo -e "${GREEN}Installing Homebrew Apps${RESET}"
      brew bundle --file "/tmp/Brewfile"
    else
      echo -e "${YELLOW}Brewfile not found. Exiting...${RESET}"
      exit 1
    fi

  else
    echo -e "${YELLOW}Homebrew not installed. Exiting...${RESET}"
    exit 1
  fi
}

mas_app_store_apps() {
  if hash mas; then
    # mas install "441258766" # Magnet
    mas install "1006087419" # SnippetsLab
    mas install "714196447" # MenuBar Stats
    # mas install "824183456" # Affinity Photo
    # mas install "443987910" # 1password
    # mas install "425955336" # Skitch
  fi
}

zsh_shell() {
  # Change to ZSH
  local brew_path=$(brew --prefix)
  local zsh_path="$brew_path/bin/zsh"

  echo -e "${GREEN}Adding ZSH to /etc/shells${RESET}"
  if ! grep "$zsh_path" < /etc/shells &> /dev/null; then
    printf '%s\n' "$zsh_path" | sudo tee -a /etc/shells
  else
    echo -e "${GREEN}ZSH already exists in /etc/shells${RESET}"
  fi
  echo -e "${YELLOW}Changing ${USER}'s default shell to ZSH${RESET}"
  sudo chsh -s $zsh_path ${USER}
}

prezto() {
  # Install Prezto (ZSH configuration framework)
  echo -e "${GREEN}Seting up Presto ZSH framework${RESET}"
  if [[ ! -d "$HOME/.zprezto" ]]; then
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
    # Create links to zsh config files
    local ZFILES=(zlogin zlogout zpreztorc zprofile zshenv zshrc)
    for file in "${ZFILES[@]}";do
      ln -s "$HOME/.zprezto/runcoms/${file}" "${HOME}/.${file}"
    done
  else
    echo -e "${GREEN} - Prezto already installed. Pulling latest changes from repository${RESET}"
    git -C "$HOME/.zprezto" pull --quiet
    git -C "$HOME/.zprezto" submodule update --init --recursive --quiet
  fi
  # Docker completion for Prezto ZSH
  echo -e "${GREEN} - Downloading docker zsh completions${RESET}"
  curl -fsSLo ~/.zprezto/modules/completion/external/src/_docker \
    https://raw.github.com/felixr/docker-zsh-completion/master/_docker

  # FZF Git
  if [[ ! -f "$HOME/.fzf-git.sh" ]]; then
    curl --progress-bar "https://raw.githubusercontent.com/junegunn/fzf-git.sh/main/fzf-git.sh" -o "$HOME/.fzf-git.sh"
  fi
}

clone_macsetup() {
  # print_in_purple "\n • Cloning macsetup\n"
  echo -e "${GREEN}Cloning macsetup${RESET}"
  if [[ ! -d "$MACSETUP" ]]; then
    git clone "https://github.com/tadone/macsetup" "$MACSETUP"
  fi
}

clone_dotfiles() {
  # print_in_purple "\n • Cloning dotfiles\n"
  echo -e "${GREEN}Cloning dotfiles${RESET}"
  if [[ ! -d "$DOTFILES" ]]; then
    git clone "https://github.com/tadone/dotfiles" "$DOTFILES"
  fi
}

link_dotfiles() {
  # Create Links from dotfiles
  echo -e "${GREEN}Linking dotfiles${RESET}"
  ln -sf "$DOTFILES/zpreztorc" "$HOME/.zpreztorc"
  ln -sf "$DOTFILES/zshrc" "$HOME/.zshrc"
  ln -sf "$DOTFILES/p10k.zsh" "$HOME/.p10k.zsh"
  ln -sf "$DOTFILES/gitconfig" "$HOME/.gitconfig"
  ln -sf "$DOTFILES/gitignore" "$HOME/.gitignore"

  # Create SSH Directory
  echo -e "${GREEN}Creating SSH Dir${RESET}"
  if [ ! -d "$HOME/.ssh" ]; then mkdir -p "$HOME/.ssh"; fi
}

# vscode_setup() {
#   print_in_purple "\n • Setting up VS Code\n"
#   if hash code; then
#     for line in $(cat "${dotfiles_dir}"/vscode_extensions.txt | grep -v '^#'); do
#       execute "code --install-extension $line" "Extension: $line"
#     done
#     echo ""
#     execute 'ln -sf "$DOTFILES/vscode_settings.json" "$HOME/Library/Application Support/Code/User/settings.json"' "Linked VS Codes settings.json"
#   else
#     print_in_green "Visual Studio Code not installed. Skipping..."
#   fi
# }

### MAIN ###
# Trap Ctrl-C
trap 'trap "" INT; echo -e "${YELLOW}Aborting...${RESET}"; exit 1' INT

# Ask for the administrator password upfront.
intro
sudoers_add
prevent_sleep
macsetup_files
# default_dirs
# macsetup_check
xcode
osx_settings
homebrew
homebrew_apps
# mas_app_store_apps
# zsh_shell
prezto
clone_macsetup
clone_dotfiles
link_dotfiles
#vscode_setup
# sudoers_remove

# Done
echo -e "${GREEN}Finished!!!\n${RESET}"