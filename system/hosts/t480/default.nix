{ pkgs, ... }:

# Host: ThinkPad T480
{
  imports = [
    ../../common.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "t480";

  # The 100 MiB EFI partition shared with Windows fits one NixOS generation.
  boot.loader.systemd-boot.configurationLimit = 1;

  hardware.acpilight.enable = true;
  environment.systemPackages = [ pkgs.brightnessctl ];

  # First NixOS release installed on THIS machine. Never change it — it keeps
  # stateful data (databases, etc.) compatible. See common.nix for the full note.
  system.stateVersion = "23.11";

  # T480-only: mount the Windows dual-boot partition.
  fileSystems."/mnt/windows" = {
    fsType = "ntfs-3g";
    device = "/dev/nvme0n1p3";
    options = [
      "rw"
      "windows_names"
      "uid=1000"
      "gid=100"
      "fmask=133"
      "dmask=022"
    ];
  };
  nix.settings.trusted-users = [
    "root"
    "paul"
  ];

}
