{
  description = "Home Manager configuration of Paul";

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
      pkgs = import nixpkgs {
        system = "${system}";
        config.allowUnfree = true;
      };
      nixConfig = { allowUnfree = true; };
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
          inherit nixvim;
          inherit system;
          inherit customPkgs; # Pass the custom packages to home.nix
          unstablePkgs = import nixpkgs-unstable {
            system = "${system}";
            config.allowUnfree = true; # <-- Add this to allow unfree packages
          };
        };

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ ./home.nix ];

      };
    };
}
