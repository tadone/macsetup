#!/usr/local/bin/zsh
source /tmp/helper.sh

# Install Prezto (ZSH configuration framework)
print_in_purple "\n • Seting up Presto ZSH framework"
if [[ ! -d "$HOME/.zprezto" ]]; then
  git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
  setopt EXTENDED_GLOB
    for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
      ln -sf "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}" &> /dev/null
    done
else
  print_in_green "\n • Prezto already installed. Pulling latest changes from repository\n\n"
  git -C "$HOME/.zprezto" pull && git -C "$HOME/.zprezto" submodule update --init --recursive &> /dev/null/
  print_result $? "Presto update"
fi

# Install rest of Homebrew packages (Non-GUI)
print_in_purple "\n • Installing Homebrew Apps\n\n"

brew_install "GNU Tools" "coreutils"
brew_install "Python 3" "python3"
brew_install "Find Utils" "findutils"
brew_install "ssh-copy-id" "ssh-copy-id"
brew_install "curl" "curl"
brew_install "HTTPie" "httpie"
#brew_install "AWS Shell" "aws-shell"
brew_install "ShellCheck" "shellcheck"
brew_install "Vim" "vim --with-override-system-vi --with-lua"
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
brew_install "tldr" "tldr"
brew_install "Nmap" "nmap"
brew_install "reattach-to-user-namespace" "reattach-to-user-namespace"

# Install Mac App Store (mas) command line tool
brew_install "Mas" "mas"

# GUI Tools
brew_install "iTerm2" "iterm2" "caskroom/versions" "cask"
brew_install "Chrome" "google-chrome" "caskroom/cask" "cask"
brew_install "Atom" "atom" "caskroom/cask" "cask"
brew_install "Slack" "slack" "caskroom/cask" "cask"
brew_install "Etcher" "etcher" "caskroom/cask" "cask"
brew_install "Spotify" "spotify" "caskroom/versions" "cask"
brew_install "Docker" "docker" "caskroom/versions" "cask"
#brew_install "TinyMediaManager" "tinymediamanager" "caskroom/cask" "cask"
brew_install "Disk Inventory X" "disk-inventory-x" "caskroom/cask" "cask"
brew_install "Spectacle" "spectacle" "caskroom/cask" "cask"
#brew_install "Qbittorrent" "qbittorrent" "caskroom/cask" "cask"
brew_install "Unarchiver" "the-unarchiver" "caskroom/cask" "cask"
#brew_install "1Password" "1password" "caskroom/cask" "cask"
#brew_install "Dropbox" "dropbox" "caskroom/cask" "cask"
brew_install "MPV Player" "mpv" "caskroom/cask" "cask"
brew_install "iiNA" "iina" "caskroom/cask" "cask"
#brew_install "MacDown" "macdown" "caskroom/cask" "cask"
#brew_install "CheatSheet" "cheatsheet" "caskroom/cask" "cask"
#brew_install "Skype" "skype" "caskroom/cask" "cask"
brew_install "AppCleaner Free" "appcleaner" "caskroom/cask" "cask"
#brew_install "Flux" "flux" "caskroom/cask" "cask"
#brew_install "Sourcetree" "sourcetree" "caskroom/cask" "cask"
#brew_install "Libre Office" "libreoffice" "caskroom/cask" "cask"
# Fonts
brew_install "Font: Inconsolata-DZ" "font-inconsolata-dz" "caskroom/fonts" "cask"
brew_install "Font: Inconsolata-G" "font-inconsolata-g-for-powerline" "caskroom/fonts" "cask"
#brew_install "Font: Source Code Pro" "font-source-code-pro" "caskroom/fonts"
brew_install "Font: Fira Mono" "font-fira-mono" "caskroom/fonts" "cask"
brew_install "Font: Roboto" "font-roboto-mono-for-powerline" "caskroom/fonts" "cask"
brew_install "Font: Hack" "font-hack" "caskroom/fonts" "cask"
# Quick Look Plugins
brew_install "Quick Look: ZIP" "betterzipql" "caskroom/cask" "cask"
brew_install "Quick Look: Image Size" "qlimagesize" "caskroom/cask" "cask"


# Install Mac App Store Apps via mas
# https://libraries.io/homebrew/mas
print_in_purple "\n • Installing Apps with <mas>\n\n"
mas_install "Magnet" "441258766"
mas_install "Enpass" "732710998"
mas_install "MenuBar Stats" "714196447"
mas_install "Unsplash Wallpapers" "1284863847"
mas_install "Reeder 3" "880001334"
#mas_install "Affinity Photo" "824183456"
#mas_install "Aperture" "408981426"
#mas_install "1password" "443987910"
#mas_install "Cathode" "499233976"
mas_install "Skitch" "425955336"
