#!/bin/bash -e

if [ -z "$1" ]; then
	echo "Usage: install.sh program"
	echo "Ex: install.sh nvim"
fi

if [ "$1" = "nvim" ]; then
	if ! [ -f $HOME/.config/nvim ]; then
	  echo "Installing nvim config..."
	  cp -R ./nvim $HOME/.config/nvim
    echo "Running Packer to install nvim packages..."
    nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
	fi
fi
