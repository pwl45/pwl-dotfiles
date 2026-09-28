{
  description = "Paul's NixOS configurations (multi-host)";

  inputs = {
    nixpkgs-2605.url = "nixpkgs/nixos-26.05";
  };

  outputs = { self, nixpkgs-2605, ... }:
    let
      mkHost = nixpkgs: hostModule:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ hostModule ];
        };
    in {
      nixosConfigurations = {
        auth = mkHost nixpkgs-2605 ./hosts/auth/configuration.nix;
        t480 = mkHost nixpkgs-2605 ./hosts/t480;
        p53 = mkHost nixpkgs-2605 ./hosts/p53;
        thoth = mkHost nixpkgs-2605 ./hosts/thoth;
      };
    };
}
