{ config, pkgs, ... }:

{
  nixpkgs.config = {
    allowUnfree = true;
  };
  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/emacs-overlay/archive/master.tar.gz;
    }))
  ];

  home.username = "paul";
  home.homeDirectory = "/home/paul";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.
  home.packages = with pkgs; [
    hello
    htop
    fortune
    cowsay
    emacs-git
    neovim
    perl
    glibcLocales
    locale 
    virtualbox
    virtualboxWithExtpack
    #
    #Use Emacs from the overlay
    # (emacsOverlay.emacsGit)
  ];

  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    ".screenrc".source = ./.screenrc;
    ".config/emacs/config.org".source = ./emacs/config.org;
    ".config/sxhkd/sxhkdrc".source = ./sxhkd/sxhkdrc;
    ".config/aliasrc".source = ./aliasrc;
    ".config/home-manager/home.nix".source = ./test.nix;
    ".zshrc".source = ./.zshrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };


  home.sessionVariables = {
    LC_ALL = "C";
    LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
  };

  programs.home-manager.enable = true;

}
