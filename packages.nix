{ pkgs, unstablePkgs, customPkgs, mdcodecat, ... }:
with pkgs;
[
  # hello
  texliveFull
  htop
  fortune
  nixfmt-classic
  cowsay
  unstablePkgs.emacs
  unstablePkgs.code-cursor
  # emacs
  perl
  glibcLocales
  locale
  zsh
  fzf
  bat
  fd
  ripgrep
  eza
  sxhkd
  redshift
  songrec
  dwmblocks
  customPkgs.dmenu
  firefox
  scrot
  cheese
  mpv
  sxiv
  pavucontrol
  pulsemixer
  brightnessctl
  cargo
  rustc
  zathura
  # nerdfonts
  qbittorrent
  xcape
  devour
  sshfs
  wmname
  colordiff
  powertop
  qemu
  shellcheck
  google-chrome
  zoom-us
  # texlive.combined.scheme-full
  python3
  qmk
  hugo
  tree
  ffmpeg
  libheif
  nix-prefetch-git
  audio-recorder
  vlc
  yazi
  kdePackages.dolphin
  bind
  pdftk
  p7zip
  ntfs3g
  jq
  arandr
  scowl
  nmap
  inetutils
  netcat
  cmake
  mdcodecat
  ruby
  wine
  winetricks
  openbox
  xorg.xev
  gamescope
  lutris
  go
  fortune
  # terraform
  openfortivpn
  alacritty
  bazel
  networkmanagerapplet
  iftop
  nethogs
  vnstat
  tcpdump
  nload
  iptraf-ng # Additional useful network monitor
  bmon # Another bandwidth monitor
  ethtool # For network interface info

  mcomix
  mupdf
  yt-dlp
  libreoffice
  poppler-utils
  xorg.xhost
  tmux
  pamixer
  telegram-desktop
  ghostty
  jdk
  # rpi-imager
  claude-code
  ansifilter
  imagemagick
  awscli2
  oauth2c
  libheif
  upower
  pinta
  sqlite
] ++ builtins.filter lib.attrsets.isDerivation
(builtins.attrValues pkgs.nerd-fonts)
