{ pkgs, ... }:

# Host: ThinkPad P53 (nixpkgs pinned to nixos-26.05 in ../../flake.nix)
{
  imports = [
    ../../common.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "p53";

  # Fresh install on 26.05. Set once; never change afterwards.
  system.stateVersion = "26.05";

  # Backlight control (replaces programs.light, which was removed after 24.11).
  hardware.acpilight.enable = true;
  environment.systemPackages = [ pkgs.brightnessctl ];

  # The P53 has an NVIDIA Quadro + Intel iGPU. If you want the discrete GPU /
  # PRIME offload, add `hardware.nvidia` + `services.xserver.videoDrivers`
  # config here once the machine is up.
}
