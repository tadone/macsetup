#!/usr/local/bin/zsh
source /tmp/helper.sh

# Install Prezto (ZSH configuration framework)
if [[ ! -d "$HOME/.zprezto" ]]; then
  git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
  setopt EXTENDED_GLOB
    for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
      ln -sf "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}" &> /dev/null
    done
else
  print_in_purple "\n • Prezto already exists. Updating with Git Pull\n\n"
  git -C "$HOME/.zprezto" pull && git -C "$HOME/.zprezto" submodule update --init --recursive
  print_result $?
fi

# Install rest of Homebrew packages (Non-GUI)
print_in_purple "\n   Installing Homebrew Apps\n\n"

brew_install "GNU Tools" "coreutils"
brew_install "Find Utils" "findutils"
brew_install "ssh-copy-id" "ssh-copy-id"
brew_install "ShellCheck" "shellcheck"
brew_install "Vim" "vim --with-override-system-vi"
brew_install "Youtube DL" "youtube-dl"
brew_install "Htop" "htop-osx"
brew_install "Wget" "wget"
brew_install "SpeedTest CLI" "speedtest-cli"
brew_install "NCurses Disk Usage" "ncdu"
brew_install "PV Progress Indicator" "pv"
brew_install "Rdiff Backup Util" "rdiff-backup"
brew_install "Dark Mode" "dark-mode"
brew_install "Ansible" "ansible"
brew_install "Hub" "hub"
brew_install "Archey" "archey"
brew_install "Tree" "tree"
brew_install "Nmap" "nmap"
brew_install "reattach-to-user-namespace" "reattach-to-user-namespace"

# Install Mac App Store (mas) command line tool
brew_install "Mas" "mas"

# GUI Tools
brew_install "iTerm2" "iterm2-beta" "caskroom/versions" "cask"
brew_install "Chrome" "google-chrome" "caskroom/cask" "cask"
brew_install "Atom" "atom" "caskroom/cask" "cask"
brew_install "Etcher" "etcher" "caskroom/cask" "cask"
brew_install "TinyMediaManager" "tinymediamanager" "caskroom/cask" "cask"
brew_install "Disk Inventory X" "disk-inventory-x" "caskroom/cask" "cask"
brew_install "Spectacle" "spectacle" "caskroom/cask" "cask"
brew_install "Qbittorrent" "qbittorrent" "caskroom/cask" "cask"
brew_install "Unarchiver" "the-unarchiver" "caskroom/cask" "cask"
#brew_install "1Password" "1password" "caskroom/cask" "cask"
brew_install "Dropbox" "dropbox" "caskroom/cask" "cask"
brew_install "MPV Player" "mpv" "caskroom/cask" "cask"
brew_install "iiNA" "iina" "caskroom/cask" "cask"
#brew_install "CheatSheet" "cheatsheet" "caskroom/cask" "cask"
#brew_install "Skype" "skype" "caskroom/cask" "cask"
brew_install "AppCleaner Free" "appcleaner" "caskroom/cask" "cask"
brew_install "Flux" "flux" "caskroom/cask" "cask"
brew_install "Sourcetree" "sourcetree"
#brew_install "Libre Office" "libreoffice" "caskroom/cask" "cask"
# Fonts
brew_install "Font: Inconsolata-DZ" "font-inconsolata-dz" "caskroom/fonts"
brew_install "Font: Inconsolata-G" "font-inconsolata-g-for-powerline" "caskroom/fonts"
brew_install "Font: Source Code Pro" "font-source-code-pro" "caskroom/fonts"
brew_install "Font: Fira Mono" "font-fira-mono" "caskroom/fonts"
brew_install "Font: Roboto" "font-roboto" "caskroom/fonts"
brew_install "Font: Hack" "font-hack" "caskroom/fonts"
# Quick Look Plugins
brew_install "Quick Look: ZIP" "betterzipql" "caskroom/cask" "cask"
brew_install "Quick Look: Image Size" "qlimagesize" "caskroom/cask" "cask"


# Install Mac App Store Apps via mas
# https://libraries.io/homebrew/mas
mas_install "Reeder 3" "880001334"
mas_install "1password" "443987910"
mas_install "Cathode" "499233976"
mas_install "Magnet" "441258766"
mas_install "Skitch" "425955336"
