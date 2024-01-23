{ config, pkgs, ... }:

{
  home.username = "alice";
  home.homeDirectory = "/home/alice";


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
    ".config/nvim/init.vim".source = ./nvim/init.vim;
    ".config/nvim/coq-config.vim".source = ./nvim/coq-config.vim;
    ".config/nvim/lsp.lua".source = ./nvim/lsp.lua;
    ".config/sxhkd/sxhkdrc".source = ./sxhkd/sxhkdrc;
    ".config/aliasrc".source = ./aliasrc;
    ".zshrc".source = ./.zshrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };


  programs.home-manager.enable = true;

}
