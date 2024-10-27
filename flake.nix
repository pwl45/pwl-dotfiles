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
    # nixvim = {
    #   url = "github:nix-community/nixvim";
    #   inputs.nixpkgs.follows = "nixpkgs-unstable";
    # };
    custom-dwmblocks.url = "github:pwl45/pwl-dwmblocks";
    custom-dwmblocks.flake = false;
    custom-dmenu.url = "github:pwl45/dmenu-flexipatch";
    custom-dmenu.flake = false;
  };

  outputs = { nixpkgs, home-manager, custom-dwmblocks, custom-dmenu, nixvim
    , nixpkgs-unstable, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      homeConfigurations."paul" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit custom-dwmblocks;
          inherit custom-dmenu;
          inherit nixvim;
          inherit system;
          unstablePkgs = nixpkgs-unstable.legacyPackages.${system};
        };

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ ./home.nix ];

      };
    };
}
