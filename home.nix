{ config, pkgs, custom-dwmblocks, custom-dmenu, custom-dwm, custom-st, nixvim
, customPkgs, unstablePkgs, username, ... }:
let
  mdcodecat =
    pkgs.writeScriptBin "mdcodecat" (builtins.readFile ./mdcodecat.py);
in {
  imports = [
    # For home-manager
    nixvim.homeManagerModules.nixvim
  ];
  home.username = username;
  home.homeDirectory = "/home/${username}";
  nixpkgs.overlays = [
    (self: super: {
      dwmblocks =
        super.dwmblocks.overrideAttrs (oldattrs: { src = custom-dwmblocks; });
    })
    # (self: super: {
    #   dmenu = super.dmenu.overrideAttrs (oldAttrs: { src = custom-dmenu; });
    # })
    (self: super: {
      dwm = super.dwm.overrideAttrs (oldattrs: { src = custom-dwm; });
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
    permittedInsecurePackages = [ "openssl-1.1.1w" "nix-2.16.2" ];
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
  home.packages = import ./packages.nix {
    inherit pkgs unstablePkgs customPkgs custom-st mdcodecat custom-dmenu;
    # Change to "minimal", "server", "headless", or "desktop"
    environment = "desktop"; # REPLACE_ENVIRONMENT_HOOK
  };

  programs.neovim = {
    enable = false;
    withPython3 = true;
    plugins = with pkgs.vimPlugins; [ coq_nvim ];
  };
  programs.zsh.enable = true;

  home.file = {
    ".config/emacs/config.org".source = ./emacs/config.org;
    ".config/emacs/init.el".source = ./emacs/init.el;
    ".config/emacs/early-init.el".source = ./emacs/early-init.el;
    ".config/emacs/setup_scripts/buffer-move.el".source =
      ./emacs/setup_scripts/buffer-move.el;
    ".config/emacs/setup_scripts/elpaca-setup.el".source =
      ./emacs/setup_scripts/elpaca-setup.el;

    # Uncomment if you want to manage neovim with config files
    # ".config/nvim/init.vim".source = ./nvim/init.vim;
    # ".config/nvim/coq-config.vim".source = ./nvim/coq-config.vim;
    ".config/sxhkd/sxhkdrc".source = ./sxhkd/sxhkdrc;
    ".config/aliasrc".source = ./aliasrc;
    ".config/grab.sh".source = ./grab.sh;
    ".config/unroll.sh".source = ./unroll.sh;
    ".zshrc".source = ./.zshrc;
    ".xinitrc".source = ./.xinitrc;
    ".ssh/config.def".source = ./ssh/config;

  };

  # programs.git = {
  #   enable = true;
  #   userName = "Paul Lapey";
  #   userEmail = "plapey45@gmail.com";
  # };
  programs.home-manager.enable = true;

  programs.nixvim = import ./nixvim-config.nix { inherit pkgs; };
}
