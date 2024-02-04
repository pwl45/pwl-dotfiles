{ config, pkgs, ... }:

{
  home.username = "alice";
  home.homeDirectory = "/home/alice";
    nixpkgs.overlays = [
      # (self: super: {
      #   dwmblocks = super.dwmblocks.overrideAttrs (oldattrs: {
      #     src = fetchGit {
      #       url = "https://github.com/pwl45/pwl-dwmblocks";
      #       rev = "289e25e70131773d935510303d187409912520a5";
      #     }; 
      #   });
      # })
      # (self: super: {
      #   st = super.st.overrideAttrs (oldattrs: rec {
      #     buildInputs = oldattrs.buildInputs ++ [ pkgs.harfbuzz ];
      #     src = fetchGit {
      #       url = "https://github.com/pwl45/pwl-st";
      #       rev = "7ab4862a38df97915924ee2a5f32307ce0aec170";
      #     }; 
      #   });
      # })
    ]; 


  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.
  home.packages = with pkgs; [
    hello
    htop
    fortune
    cowsay
    nerdfonts
    emacs
    perl
    glibcLocales
    locale 
    python3 
    zsh
    fzf
    fd
    sxhkd
    redshift
    dwmblocks
    unclutter
    #
    #Use Emacs from the overlay
    # (emacsOverlay.emacsGit)
  ];

  programs.neovim = {
    enable = true;
    withPython3 = true;
    plugins = with pkgs.vimPlugins; [
      coq_nvim
    ];
  };


  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    ".screenrc".source = ./.screenrc;
    ".config/emacs/config.org".source = ./emacs/config.org;
    ".config/emacs/init.el".source = ./emacs/init.el;
    ".config/emacs/early-init.el".source = ./emacs/early-init.el;
    ".config/emacs/setup_scripts".source = ./emacs/setup_scripts;
    ".config/nvim/init.vim".source = ./nvim/init.vim;
    ".config/nvim/coq-config.vim".source = ./nvim/coq-config.vim;
    ".config/nvim/lsp.lua".source = ./nvim/lsp.lua;
    ".config/sxhkd/sxhkdrc".source = ./sxhkd/sxhkdrc;
    ".config/aliasrc".source = ./aliasrc;
    ".zshrc".source = ./.zshrc;
    ".xinitrc".source = ./.xinitrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };


  programs.home-manager.enable = true;
}
