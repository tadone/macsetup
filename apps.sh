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

print_success "All done"
# Install rest of Homebrew packages
