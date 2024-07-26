{
  description = "Home Manager configuration of alice";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
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
