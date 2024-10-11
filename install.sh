#!/bin/bash -e

if [ -z "$1" ]; then
	echo "Usage: install.sh program"
	echo "Ex: install.sh nvim"
fi

if [ "$1" = "nvim" ]; then
	if ! [ -f $HOME/.config/nvim ]; then
	  echo "Installing nvim config..."
    if [ -d $HOME/.config/nvim ]; then
      echo "Removing old nvim config."
      rm -r $HOME/.config/nvim
    fi
	  cp -R ./nvim $HOME/.config/nvim
    echo "Running Packer to install nvim packages..."
    nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
	fi
fi


if [ "$1" = "zsh" ]; then
  echo "Copying zshrc file to $HOOME/.zshrc"
  cp zsh/zshrc $HOME/.zshrc
fi
