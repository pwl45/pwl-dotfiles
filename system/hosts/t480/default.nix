{ ... }:

# Host: ThinkPad T480 (nixpkgs pinned to nixos-24.11 in ../../flake.nix)
{
  imports = [
    ../../common.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "t480";

  # Backlight control via the `light` CLI (used by the brightness keybinds).
  # Removed from nixpkgs after 24.11 — when this host moves to 26.05+, switch
  # to brightnessctl / hardware.acpilight like the p53 host.
  programs.light.enable = true;

  # First NixOS release installed on THIS machine. Never change it — it keeps
  # stateful data (databases, etc.) compatible. See common.nix for the full note.
  system.stateVersion = "23.11";

  # T480-only: mount the Windows dual-boot partition.
  fileSystems."/mnt/windows" = {
    fsType = "ntfs-3g";
    device = "/dev/nvme0n1p3";
    options =
      [ "rw" "windows_names" "uid=1000" "gid=100" "fmask=133" "dmask=022" ];
  };
}
