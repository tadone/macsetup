#!/bin/bash
MYDIR=$(dirname "$0")
source "$MYDIR/helper.sh" || exit 1
# source helper.sh

# Trap Ctrl-C
trap 'trap "" INT; print_error "Aborting..."; exit 1' INT

# Install rest of Homebrew packages (Non-GUI)
print_in_purple "\n   Installing Essentials\n"
brew_install "Git" "git"
brew_install "ZSH" "zsh"
brew_install "ZSH Completions" "zsh-completions"

print_in_purple "\n   Installing Homebrew Apps\n"
brew_install "GNU Tools" "coreutils"
# brew_install "Python 3" "python3"
brew_install "Golang" "golang"
brew_install "Find Utils" "findutils"
brew_install "ssh-copy-id" "ssh-copy-id"
brew_install "curl" "curl"
#brew_install "HTTPie" "httpie"
#brew_install "AWS Shell" "aws-shell"
brew_install "ShellCheck" "shellcheck"
brew_install "Vim" "vim"
brew_install "FZF" "fzf"
brew_install "Z" "z"
#brew_install "KAK" "kakoune"
brew_install "Krew" "krew"
#brew_install "Youtube DL" "youtube-dl"
# brew_install "Htop" "htop-osx"
brew_install "Wget" "wget"
# brew_install "SpeedTest CLI" "speedtest-cli"
# brew_install "NCurses Disk Usage" "ncdu"
# brew_install "PV Progress Indicator" "pv"
# brew_install "Rdiff Backup Util" "rdiff-backup"
# brew_install "Dark Mode" "dark-mode"
# brew_install "Ansible" "ansible"
# brew_install "Hub" "hub"
# brew_install "Archey" "archey"
# brew_install "Tree" "tree"
brew_install "tldr" "tldr"
# brew_install "Nmap" "nmap"
# brew_install "reattach-to-user-namespace" "reattach-to-user-namespace"
# brew_install "GPG" "gpg"
# brew_install "Bat - Cat Replacement" "bat"
brew_install "Noti - Notification" "noti"
# brew_install "Diff so fancy" "diff-so-fancy"
brew_install "FD - Find Replacement" "fd"
brew_install "JQ - JSON Query Tool" "jq"
# brew_install "MyCLI - SQL Tool" "jq"
brew_install "Rename" "rename"

print_in_purple "\n   Installing Cloud Providers\n"
# brew_install "Google SDK" "google-cloud-sdk"
# brew_install "MiniKube" "minikube"
# brew_install "AWS Cli" "awscli"
# brew_install "Azure CLI" "azure-cli"
brew_install "Kubernetes CLI" "kubernetes-cli"
brew_install "kubectx" "kubectx"
brew_install "Kustomize" "kustomize"
brew_install "Kubetail" "kubetail"
# brew_install "Stern" "stern"
# brew_install "Kubespy" "kubespy"

print_in_purple "\n   Installing Applications\n"
# GUI Tools
brew_install "iTerm2" "iterm2"
#brew_install "Hyper" "Hyper"
brew_install "Chrome" "google-chrome"
brew_install "Firefox" "firefox"
brew_install "YakYak" "yakyak"
brew_install "Mark Text" "mark-text"
brew_install "VS Code" "visual-studio-code"
# brew_install "Google Chat" "google-chat"
# brew_install "Atom" "atom"
# brew_install "Slack" "slack"
# brew_install "Etcher" "balenaetcher"
brew_install "Spotify" "spotify"
brew_install "Docker" "docker"
# brew_install "Notion" "notion"
brew_install "Media Elch" "mediaelch"
brew_install "iiNA" "iina"
# brew_install "TinyMediaManager" "tinymediamanager"
brew_install "Disk Inventory X" "disk-inventory-x"
#brew_install "Spectacle" "spectacle"
#brew_install "Qbittorrent" "qbittorrent"
#brew_install "Unarchiver" "the-unarchiver"
#brew_install "1Password" "1password"
#brew_install "Dropbox" "dropbox"
#brew_install "MPV Player" "mpv"
#brew_install "MacDown" "macdown"
#brew_install "CheatSheet" "cheatsheet"
#brew_install "Skype" "skype"
#brew_install "AppCleaner Free" "appcleaner"
#brew_install "Flux" "flux"
#brew_install "Sourcetree" "sourcetree"
#brew_install "Libre Office" "libreoffice"
# Fonts
#brew_tap "Homebrew/cask-fonts"
brew_install "homebrew/cask-fonts/font-roboto-mono-for-powerline" "Font: Roboto Mono for Powerline"
brew_install "homebrew/cask-fonts/font-fira-mono"
brew_install "homebrew/cask-fonts/font-hack"
brew_install "homebrew/cask-fonts/font-source-code-pro"

# OLD 
# brew_install "Font: Inconsolata-DZ" "font-inconsolata-dz" "caskroom/fonts" "cask"
# brew_install "Font: Inconsolata-G" "font-inconsolata-g-for-powerline" "caskroom/fonts" "cask"
#brew_install "Font: Source Code Pro" "font-source-code-pro" "caskroom/fonts"
#brew_install "Font: Fira Mono" "font-fira-mono" "caskroom/fonts" "cask"
# brew_install "Font: Roboto" "font-roboto-mono-for-powerline" "caskroom/fonts" "cask"
# brew_install "Font: Hack" "font-hack" "caskroom/fonts" "cask"
# Quick Look Plugins
# brew_install "Quick Look: ZIP" "betterzipql"

print_in_purple "\n   Installing Apps with <mas>\n"
# Install Mac App Store (mas) command line tool
brew_install "Mas" "mas"
print_in_purple "\n   Sign in via App Store before continuing\n"
# Install Mac App Store Apps via mas
# https://libraries.io/homebrew/mas
#mas signin tadone@gmail.com

#mas_install "Magnet" "441258766"
#mas_install "SnippetsLab" "1006087419"
#mas_install "Enpass" "732710998"
#mas_install "MenuBar Stats" "714196447"
#mas_install "Unsplash Wallpapers" "1284863847"
#mas_install "Reeder 3" "880001334"
#mas_install "Affinity Photo" "824183456"
# mas_install "Aperture" "408981426"
#mas_install "1password" "443987910"
#mas_install "Cathode" "499233976"
#mas_install "Skitch" "425955336"