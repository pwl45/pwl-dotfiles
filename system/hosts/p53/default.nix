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

  # NVIDIA Quadro RTX 3000 + Intel UHD 630 — PRIME Sync mode.
  # Sync keeps the dGPU always on but external monitors via the USB-C dock
  # (physically wired through the NVIDIA GPU) work without any xrandr hacks.
  # Bus IDs from `dmesg`: Intel 0000:00:02.0, NVIDIA 0000:01:00.0.
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    prime = {
      sync.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}
