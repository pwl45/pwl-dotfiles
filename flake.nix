{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; # Note: default is currently unstable, but leaving this so we can pin to nixpkgs stable when/if we want to.
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager"; # Remove release-24.05 to use latest
      inputs.nixpkgs.follows = "nixpkgs"; # Changed to follow unstable
    };
    nixvim = {
      url = "github:nix-community/nixvim"; # Remove nixos-24.05 to use latest
      # Deliberately NOT following our nixpkgs: nixvim's modules are coupled to
      # the nixpkgs it pins/tests against, so let it use its own (which tracks
      # unstable anyway). Overriding it is unsupported and triggers a warning.
    };
    custom-dwmblocks.url = "github:pwl45/pwl-dwmblocks";
    custom-dwmblocks.flake = false;
    custom-dmenu.url = "github:pwl45/dmenu-flexipatch";
    custom-dmenu.flake = false;
    custom-dwm.url = "github:pwl45/pwl-dwm";
    custom-st.url = "github:pwl45/pwl-st";
    custom-st.flake = false;
    custom-dwm.flake = false;
    hermes-agent = {
      url = "github:NousResearch/hermes-agent";
      inputs.nixpkgs.follows = "nixpkgs"; # Reuse our nixpkgs to avoid a second copy
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      custom-dwmblocks,
      custom-dmenu,
      custom-dwm,
      custom-st,
      nixvim,
      nixpkgs-unstable,
      hermes-agent,
      ...
    }:
    let
      mkHomeConfiguration =
        {
          username,
          system,
          environment,
        }:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          customPkgs = nixpkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
            dmenu = pkgs.callPackage custom-dmenu { };
          };
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit custom-dwmblocks;
            inherit custom-dmenu;
            inherit custom-dwm;
            inherit custom-st;
            inherit nixvim;
            inherit system;
            # hermes-agent has no Darwin build, so it's null there (home.nix
            # only appends it when non-null). On Linux, use the `messaging`
            # variant so python-telegram-bot, discord.py, and slack-sdk are
            # bundled — the read-only Nix store can't be pip-installed at runtime.
            hermesAgent =
              if pkgs.stdenv.hostPlatform.isDarwin then null else hermes-agent.packages.${system}.messaging;
            inherit customPkgs; # Pass the custom packages to home.nix
            inherit username environment;
            unstablePkgs = nixpkgs-unstable.legacyPackages.${system};
          };
          modules = [ ./home.nix ];
        };
    in
    {
      # Shared by every machine with this username and Nix platform.
      homeConfigurations = {
        "paul@x86_64-linux" = mkHomeConfiguration {
          username = "paul";
          system = "x86_64-linux";
          environment = "desktop";
        };
        "paul.lapey@aarch64-darwin" = mkHomeConfiguration {
          username = "paul.lapey";
          system = "aarch64-darwin";
          environment = "headless";
        };
      };
    };
}
