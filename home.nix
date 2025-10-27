{ config, pkgs, custom-dwmblocks, custom-dmenu, nixvim, customPkgs, unstablePkgs
, ... }:
let
  mdcodecat =
    pkgs.writeScriptBin "mdcodecat" (builtins.readFile ./mdcodecat.py);
in {
  imports = [
    # For home-manager
    nixvim.homeManagerModules.nixvim
  ];

  # error: The option `home-manager' does not exist
  # home-manager.useGlobalPkgs = true;

  home.username = "paul";
  home.homeDirectory = "/home/paul";
  nixpkgs.overlays = [
    (self: super: {
      dwmblocks =
        super.dwmblocks.overrideAttrs (oldattrs: { src = custom-dwmblocks; });
    })
    (self: super: {
      dmenu = super.dmenu.overrideAttrs (oldattrs: { src = custom-dmenu; });
    })
  ];
  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = _: true;
    permittedInsecurePackages =
      [ "openssl-1.1.1w" "nix-2.16.2" "freeimage-unstable-2021-11-01" ];
  };
  # nixvim.useGlobalPackages = true;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  home.packages =
    import ./packages.nix { inherit pkgs unstablePkgs customPkgs mdcodecat; };

  programs.neovim = {
    enable = false;
    withPython3 = true;
    plugins = with pkgs.vimPlugins; [ coq_nvim ];
  };

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
    ".ssh/config".source = ./ssh/config;

  };

  programs.git = {
    enable = true;
    userName = "Paul Lapey";
    userEmail = "plapey45@gmail.com";
  };
  programs.home-manager.enable = true;

  services.redshift = {
    enable = true;
    dawnTime = "08:00";
    duskTime = "23:00";
    temperature = {
      day = 5500;
      night = 3700;
    };
    provider = "geoclue2";
  };
  programs.nixvim = import ./nixvim-config.nix {
    pkgs = pkgs // { config.allowUnfree = true; }; # <-- ADD THIS
  };
}
