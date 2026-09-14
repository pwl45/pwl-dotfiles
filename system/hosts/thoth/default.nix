{ ... }:

# Host: thoth — NUC mini PC (always-on hermes agent box, TV-connected).
# The username stays `paul`: identity throughout the flake tree (home flake
# identities map, authorized-keys, hermes ~/.hermes) is keyed on the user.
# `thoth` is only the machine's hostname.
{
  imports = [
    ../../common.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "thoth";

  # First NixOS release installed on THIS machine. Never change it. If
  # nixos-generate-config produced a different value during install, match it.
  system.stateVersion = "26.05";

  # btrfs: monthly scrub against silent corruption. Also add
  #   options = [ "compress=zstd" "noatime" ]
  # to the btrfs fileSystems entries that nixos-generate-config writes into
  # ./hardware-configuration.nix on first bootstrap.
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
  };

  # Hermes runs as user-level services; linger keeps them alive without an
  # active login session (and after unattended reboots — matches the BIOS
  # "power on after power failure" setting).
  users.users.paul.linger = true;
}