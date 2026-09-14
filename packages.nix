{
  pkgs,
  unstablePkgs,
  customPkgs,
  mdcodecat,
  ntok,
  environment ? "desktop",
  ...
}:
with pkgs;
let
  inherit (lib) optionals;
  inherit (stdenv.hostPlatform) isLinux isDarwin;

  # Each group starts with shared packages, followed by OS-specific additions.
  # Core packages needed everywhere
  core = [
    hello
    mdcodecat
    ntok
    htop
    fortune
    nixfmt
    zsh
    fzf
    bat
    fd
    eza
    ripgrep
    tree
    shellcheck
    tmux
    jq
    zoxide
    python3
    dnsutils
    bc
  ]
  ++ optionals isLinux [
    xclip
    xsel
    util-linux
  ];

  # Development tools
  development = [
    cargo
    git-filter-repo
    rustc
    awscli2
    google-cloud-sdk
    oauth2c
    claude-code
    grok-build
    unstablePkgs.codex
    bazel-buildtools
    zig
    gh
    acli
    mermaid-cli
    opencode
    pi-coding-agent
    nodejs
    texliveFull
    tcpdump
    speedtest-cli
    mtr
    aria2
    emacs
    # hermes
  ]
  ++ optionals isLinux [
    upower
    dmidecode
    iw
    ethtool
  ];

  # Desktop environment packages
  desktop = [
    qrcode
    telegram-desktop
    pinta
    firefox
    qbittorrent
    browsh
    mpv
    imagemagick
    # code-cursor
    yt-dlp
    (import ./packages/llm.nix { inherit pkgs; })
  ]
  ++ optionals isLinux [
    discord
    google-chrome
    zoom-us
    sxhkd
    redshift
    dwmblocks
    cheese
    wine
    winetricks
    scrot
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
    # This nixpkgs Ghostty package is Linux-only; install the macOS app separately.
    # Let ncurses win the collision with Ghostty's terminfo entry.
    (lib.lowPrio ghostty)
    peek
    devour
    pamixer
    steam-run
  ]
  ++ optionals isDarwin [
    ffmpeg
  ];

  # Fonts
  fonts = [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    proggyfonts
    ubuntu-classic
    jetbrains-mono
  ]
  # Just the Nerd Font icon/glyph font — pairs with the real families above
  # (JetBrains Mono, Fira Code, Noto, etc.) so terminal icons work without
  # pulling in ~50 full patched nerd-font packages.
  ++ [
    nerd-fonts.symbols-only
  ];

  # System utilities (might not be needed on all systems)
  system = [
    cowsay
    perl
    ncurses
  ]
  ++ optionals isLinux [
    glibcLocales
    locale
  ];

  # Environment-specific package sets
  environments = {
    minimal = core;
    server = core ++ development;
    desktop = core ++ development ++ desktop ++ fonts ++ system;
    headless = core ++ development ++ system;
  };
in
environments.${environment}
