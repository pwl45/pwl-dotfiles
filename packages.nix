{ pkgs, unstablePkgs, customPkgs, custom-st, mdcodecat, ... }:
with pkgs;
[
  hello
  mdcodecat
  htop
  fortune
  nixfmt-classic
  cowsay
  perl
  glibcLocales
  locale
  zsh
  fzf
  bat
  fd
  eza
  sxhkd
  redshift
  dwmblocks
  firefox
  scrot
  mpv
  sxiv
  pavucontrol
  pulsemixer
  brightnessctl
  cargo
  rustc
  zathura
  xclip
  # dmenu
  customPkgs.dmenu
  dwmblocks
  dwm
  ripgrep
  tree
  shellcheck
  st
  slock
  i3lock
  xscreensaver
  lightlocker
  xlockmore
  physlock
  ncurses

  # fonts
  noto-fonts
  noto-fonts-cjk-sans
  noto-fonts-emoji
  liberation_ttf
  fira-code
  fira-code-symbols
  mplus-outline-fonts.githubRelease
  # dina-font
  proggyfonts
  ubuntu_font_family
  jetbrains-mono
  xclip
  (ffmpeg.override { withXcb = true; })
  slop
  ghostty
  peek
  devour
  pamixer
  tmux
  pamixer
  # powerline-fonts
  # alacritty
  awscli2
  oauth2c
  jq
] ++ builtins.filter lib.attrsets.isDerivation
(builtins.attrValues pkgs.nerd-fonts)
