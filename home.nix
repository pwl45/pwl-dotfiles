{ config, pkgs, firefox-addons, custom-dwmblocks, nixvim, unstablePkgs, ... }:
{
  imports = [
    # For home-manager
    nixvim.homeManagerModules.nixvim
  ];
  home.username = "alice";
  home.homeDirectory = "/home/alice";
  nixpkgs.overlays = [
    (self: super: {
      dwmblocks =
        super.dwmblocks.overrideAttrs (oldattrs: { src = custom-dwmblocks; });
    })
  ];
  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [ "openssl-1.1.1w" ];
  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  home.packages = import ./packages.nix { inherit pkgs unstablePkgs; };


  programs.neovim = {
    enable = false;
    withPython3 = true;
    plugins = with pkgs.vimPlugins; [ coq_nvim nvim-base16 ];
  };

  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    ".config/emacs/config.org".source = ./emacs/config.org;
    ".config/emacs/init.el".source = ./emacs/init.el;
    ".config/emacs/early-init.el".source = ./emacs/early-init.el;
    ".config/emacs/setup_scripts".source = ./emacs/setup_scripts;

    # Uncomment if you want to manage neovim with config files
    # ".config/nvim/init.vim".source = ./nvim/init.vim;
    # ".config/nvim/coq-config.vim".source = ./nvim/coq-config.vim;
    # ".config/nvim/lsp.lua".source = ./nvim/lsp.lua;
    ".config/sxhkd/sxhkdrc".source = ./sxhkd/sxhkdrc;
    ".config/aliasrc".source = ./aliasrc;
    ".zshrc".source = ./.zshrc;
    ".xinitrc".source = ./.xinitrc;

  };

  programs.firefox = { enable = true; };
  programs.home-manager.enable = true;

  programs.nixvim = import ./nixvim-config.nix { inherit pkgs; };
}
