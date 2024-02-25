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
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
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
  };

  outputs = { nixpkgs, home-manager, firefox-addons, custom-dwmblocks, nixvim
    , nixpkgs-unstable, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      # pkgs.firefox-addons = firefox-addons;
    in {
      homeConfigurations."alice" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit custom-dwmblocks;
          inherit firefox-addons;
          inherit nixvim;
          inherit system;
          unstablePkgs = nixpkgs-unstable.legacyPackages.${system};
        };
        # specialArgs = {
        #   # inherit firefox-addons;
        # };       

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ ./home.nix ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };
    };
}
