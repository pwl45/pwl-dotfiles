#!/bin/sh
cd $(dirname $0)
sudo cp configuration.nix /etc/nixos/configuration.nix
echo 'Starting nixos rebuild'
sudo nixos-rebuild switch
echo 'Starting Home Manager Switch'
pwd
home-manager switch --flake .
