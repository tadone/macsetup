#!/usr/local/bin/zsh
sudo -v

# Install Prezto (ZSH configuration framework)
execute 'git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"' "Prezto Installed"

setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
  ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done
print_result

# Install rest of Homebrew packages
