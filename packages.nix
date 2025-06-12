{ pkgs, unstablePkgs, customPkgs, custom-st, mdcodecat, environment ? "desktop", ... }:
with pkgs;
let
  # Core packages needed everywhere
  core = [
    hello
    mdcodecat
    htop
    fortune
    nixfmt-classic
    zsh
    fzf
    bat
    fd
    eza
    ripgrep
    tree
    shellcheck
    xclip
    tmux
    jq
  ];

  # Development tools
  development = [
    cargo
    rustc
    awscli2
    oauth2c
    code-cursor
    claude-code
  ];

  # Desktop environment packages
  desktop = [
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
    zathura
    customPkgs.dmenu
    dwm
    st
    slock
    i3lock
    xscreensaver
    lightlocker
    xlockmore
    physlock
    (ffmpeg.override { withXcb = true; })
    slop
    ghostty
    peek
    devour
    pamixer
  ];

  # Fonts
  fonts = [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    proggyfonts
    ubuntu_font_family
    jetbrains-mono
  ] ++ builtins.filter lib.attrsets.isDerivation
  (builtins.attrValues pkgs.nerd-fonts);

  # System utilities (might not be needed on all systems)
  system = [
    cowsay
    perl
    glibcLocales
    locale
    ncurses
  ];

  # Environment-specific package sets
  environments = {
    minimal = core;
    server = core ++ development;
    desktop = core ++ development ++ desktop ++ fonts ++ system;
    headless = core ++ development ++ system;
  };
in
  environments.${environment} or environments.desktop
