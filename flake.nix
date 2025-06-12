{
  description = "Home Manager configuration of alice";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url =
        "github:nix-community/home-manager"; # Remove release-24.05 to use latest
      inputs.nixpkgs.follows = "nixpkgs"; # Changed to follow unstable
    };
    nixvim = {
      url = "github:nix-community/nixvim"; # Remove nixos-24.05 to use latest
      inputs.nixpkgs.follows = "nixpkgs"; # Changed to follow unstable
    };
    custom-dwmblocks.url = "github:pwl45/pwl-dwmblocks";
    custom-dwmblocks.flake = false;
    custom-dmenu.url = "github:pwl45/dmenu-flexipatch";
    custom-dmenu.flake = false;
    custom-dwm.url = "github:pwl45/pwl-dwm";
    custom-st.url = "github:pwl45/pwl-st";
    custom-st.flake = false;
    custom-dwm.flake = false;
  };

  outputs = { nixpkgs, home-manager, custom-dwmblocks, custom-dmenu, custom-dwm
    , custom-st, nixvim, nixpkgs-unstable, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      customPkgs = {
        dmenu =
          pkgs.callPackage custom-dmenu { }; # This will use your default.nix

      };

    in {
      homeConfigurations."paul" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit custom-dwmblocks;
          inherit custom-dmenu;
          inherit custom-dwm;
          inherit custom-st;
          inherit nixvim;
          inherit system;
          inherit customPkgs; # Pass the custom packages to home.nix
          unstablePkgs = nixpkgs-unstable.legacyPackages.${system};
        };
        modules = [ ./home.nix ];
      };
    };
}
