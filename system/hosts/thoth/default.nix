{ ... }:

# Host: thoth, the NUC mini PC (hermes agent, TV-connected).
{
  imports = [
    ../../common.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "thoth";

  pwl.username = "thoth";

  # First release installed on this machine; never change it.
  system.stateVersion = "26.05";

  # Add compress=zstd and noatime to the btrfs entries in hardware-configuration.nix.
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
  };

  # hermes runs as user services; keep them alive without a login session.
  users.users.thoth.linger = true;
}