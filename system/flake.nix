{
  description = "Paul's NixOS configurations (multi-host)";

  # Each host pins its own nixpkgs so machines can run different NixOS releases
  # independently (the T480 on 24.11, the P53 on 26.05).
  inputs = {
    nixpkgs-2411.url = "nixpkgs/nixos-24.11";
    nixpkgs-2605.url = "nixpkgs/nixos-26.05";
  };

  outputs = { self, nixpkgs-2411, nixpkgs-2605, ... }:
    let
      mkHost = nixpkgs: hostModule:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ hostModule ];
        };
    in {
      nixosConfigurations = {
        t480 = mkHost nixpkgs-2411 ./hosts/t480;
        p53 = mkHost nixpkgs-2605 ./hosts/p53;
      };
    };
}
