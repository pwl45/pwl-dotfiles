# PLACEHOLDER — replace this on the real P53.
#
# This file MUST be regenerated on the actual machine, because it encodes that
# machine's disk UUIDs, CPU, and kernel modules. After installing NixOS 26.05
# on the P53, run:
#
#   sudo nixos-generate-config --show-hardware-config \
#     > ~/pwl-dotfiles/system/hosts/p53/hardware-configuration.nix
#
# Until you do, `nixos-rebuild ... #p53` will fail with "no root filesystem",
# which is expected. The stub below only lets the flake evaluate; it is NOT
# bootable.
{ lib, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Placeholder root filesystem — overwrite with the generated config.
  fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
}
