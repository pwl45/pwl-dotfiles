#!/usr/bin/env bash
sudo tailscale up --force-reauth --login-server "https://auth.paullapey.com" --authkey $(sudo cat /etc/tailscale/authkey.paul)
