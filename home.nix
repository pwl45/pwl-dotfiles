{
  config,
  pkgs,
  custom-dwmblocks,
  custom-dmenu,
  custom-dwm,
  custom-st,
  nixvim,
  customPkgs,
  unstablePkgs,
  username,
  hermesAgent,
  ...
}:
let
  mdcodecat = pkgs.writeScriptBin "mdcodecat" (builtins.readFile ./mdcodecat.py);

  ntok = pkgs.writers.writePython3Bin "ntok" {
    libraries = [ pkgs.python3Packages.tiktoken ];
    doCheck = false;
  } (builtins.readFile ./ntok.py);

  # `errexit` is omitted deliberately: monitor inspects the exit status of the
  # command it wraps and must stay alive to report it.
  monitor = pkgs.writeShellApplication {
    name = "monitor";
    runtimeInputs = with pkgs; [
      coreutils
      findutils
      procps
      util-linux
    ];
    bashOptions = [
      "nounset"
      "pipefail"
    ];
    text = builtins.readFile ./scripts/monitor.sh;
  };
in
{
  imports = [
    # For home-manager
    nixvim.homeModules.nixvim
  ];
  home.username = username;
  home.homeDirectory = "/home/${username}";
  nixpkgs.overlays = [
    (self: super: {
      dwmblocks = super.dwmblocks.overrideAttrs (oldattrs: {
        src = custom-dwmblocks;
        NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types";
      });
    })
    # (self: super: {
    #   dmenu = super.dmenu.overrideAttrs (oldAttrs: { src = custom-dmenu; });
    # })
    (self: super: {
      dwm = super.dwm.overrideAttrs (oldattrs: {
        src = custom-dwm;
        buildInputs = oldattrs.buildInputs ++ [ pkgs.libxcb ];
      });
    })
    (self: super: {
      st = super.st.overrideAttrs (oldattrs: {
        buildInputs = oldattrs.buildInputs ++ [ pkgs.harfbuzz ];
        src = custom-st;
      });
    })
  ];
  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "openssl-1.1.1w"
      "nix-2.16.2"
    ];
  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # fonts.fontconfig.enable = true;
  home.packages =
    (import ./packages.nix {
      inherit
        pkgs
        unstablePkgs
        customPkgs
        custom-st
        mdcodecat
        ntok
        monitor
        custom-dmenu
        ;
      # Change to "minimal", "server", "headless", or "desktop"
      environment = "desktop"; # REPLACE_ENVIRONMENT_HOOK
    })
    ++ [ hermesAgent ];

  programs.neovim = {
    enable = false;
    withPython3 = true;
    plugins = with pkgs.vimPlugins; [ coq_nvim ];
  };
  # programs.zsh.enable = true;

  # Out-of-store symlinks: edits to the files in the dotfiles repo are live
  # without a `home-manager switch`. Only re-switch when adding/removing files
  # here or changing other parts of the config.
  #
  # Update `dotfiles` if you move the repo.
  home.file =
    let
      dotfiles = "${config.home.homeDirectory}/pwl-dotfiles";
      link = config.lib.file.mkOutOfStoreSymlink;

      # Auto-discover every rule in the dotfiles rules dir and symlink each
      # into ~/.claude/rules individually, so machine-specific rules dropped
      # into ~/.claude/rules directly are left untouched. Contents edit in
      # place; adding/removing a rule file requires a re-switch (readDir runs
      # at eval time).
      ruleFiles = builtins.attrNames (builtins.readDir ./.claude/rules);
      claudeRules = builtins.listToAttrs (
        map (name: {
          name = ".claude/rules/${name}";
          value.source = link "${dotfiles}/.claude/rules/${name}";
        }) ruleFiles
      );
    in
    {
      ".config/emacs/config.org".source = link "${dotfiles}/emacs/config.org";
      ".config/emacs/init.el".source = link "${dotfiles}/emacs/init.el";
      ".config/emacs/early-init.el".source = link "${dotfiles}/emacs/early-init.el";
      ".config/emacs/setup_scripts/buffer-move.el".source =
        link "${dotfiles}/emacs/setup_scripts/buffer-move.el";
      ".config/emacs/setup_scripts/elpaca-setup.el".source =
        link "${dotfiles}/emacs/setup_scripts/elpaca-setup.el";

      # Uncomment if you want to manage neovim with config files
      # ".config/nvim/init.vim".source = link "${dotfiles}/nvim/init.vim";
      # ".config/nvim/coq-config.vim".source = link "${dotfiles}/nvim/coq-config.vim";
      ".config/sxhkd/sxhkdrc".source = link "${dotfiles}/sxhkd/sxhkdrc";
      ".config/aliasrc".source = link "${dotfiles}/aliasrc";
      ".config/grab.sh".source = link "${dotfiles}/grab.sh";
      ".config/unroll.sh".source = link "${dotfiles}/unroll.sh";
      ".zshrc".source = link "${dotfiles}/.zshrc";
      ".xinitrc".source = link "${dotfiles}/.xinitrc";
      ".ssh/config.def".source = link "${dotfiles}/ssh/config";
      ".tmux.conf".source = link "${dotfiles}/.tmux.conf";
      ".config/alacritty/alacritty.toml".source = link "${dotfiles}/alacritty/alacritty.toml";
      ".config/ghostty/config".source = link "${dotfiles}/ghostty/config";

    }
    // claudeRules;

  # programs.git = {
  #   enable = true;
  #   userName = "Paul Lapey";
  #   userEmail = "plapey45@gmail.com";
  # };
  programs.home-manager.enable = true;

  programs.nixvim = import ./nixvim-config.nix;

  # GUI file-open (xdg-open) defaults to the first .desktop that claims
  # text/plain; nvim.desktop has Terminal=true which minimal WMs like ours
  # don't honor, so plain emacs.desktop was winning by default. Point it at
  # st+nvim instead.
  xdg.desktopEntries.st-nvim = {
    name = "Neovim (st)";
    genericName = "Text Editor";
    comment = "Edit text in st + nvim";
    exec = "st -e nvim %F";
    icon = "nvim";
    terminal = false;
    type = "Application";
    categories = [
      "Utility"
      "TextEditor"
      "Development"
    ];
    mimeType = [
      "text/english"
      "text/plain"
      "text/x-makefile"
      "text/x-c++hdr"
      "text/x-c++src"
      "text/x-chdr"
      "text/x-csrc"
      "text/x-java"
      "text/x-moc"
      "text/x-pascal"
      "text/x-tcl"
      "text/x-tex"
      "application/x-shellscript"
      "text/x-c"
      "text/x-c++"
    ];
  };
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/claude-cli" = "claude-code-url-handler.desktop";
      "text/english" = "st-nvim.desktop";
      "text/plain" = "st-nvim.desktop";
      "text/x-makefile" = "st-nvim.desktop";
      "text/x-c++hdr" = "st-nvim.desktop";
      "text/x-c++src" = "st-nvim.desktop";
      "text/x-chdr" = "st-nvim.desktop";
      "text/x-csrc" = "st-nvim.desktop";
      "text/x-java" = "st-nvim.desktop";
      "text/x-moc" = "st-nvim.desktop";
      "text/x-pascal" = "st-nvim.desktop";
      "text/x-tcl" = "st-nvim.desktop";
      "text/x-tex" = "st-nvim.desktop";
      "application/x-shellscript" = "st-nvim.desktop";
      "text/x-c" = "st-nvim.desktop";
      "text/x-c++" = "st-nvim.desktop";
    };
  };
}
