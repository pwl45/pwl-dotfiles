{ config, pkgs, ... }:

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

  # psmouse's SMBus handoff to elan_i2c times out (-110), and since it releases
  # the PS/2 device first, both the touchpad and TrackPoint vanish. Staying on
  # PS/2 costs native multitouch (3+ finger gestures).
  boot.extraModprobeConfig = ''
    options psmouse elantech_smbus=0
  '';

  # NVIDIA Quadro T2000 + Intel UHD 630 — PRIME Reverse Sync mode.
  # reverseSync keeps Intel as the primary scanout GPU (it renders the desktop
  # and drives the internal eDP-1 panel) and exposes the NVIDIA outputs as
  # reverse-PRIME sinks, which matches the P53's wiring: external DP outputs go
  # through the Quadro, not Intel.
  # Bus IDs from `dmesg`: Intel 0000:00:02.0, NVIDIA 0000:01:00.0.
  #
  # KNOWN UNSOLVED ISSUE — internal panel does not return after S3 suspend:
  # backlight stays on, kernel + X stay alive (SSH works), but the panel is
  # black and only a fresh X or a reboot recovers it. Dead ends already ruled
  # out, do NOT repeat them:
  #   * NOT the Intel Coffee Lake PSR bug — `i915.enable_psr=0` changed nothing.
  #   * NOT the dual-GPU / shared-screen coupling — BIOS -> Discrete Graphics
  #     (single NVIDIA GPU, no shared X screen, no "Insufficient permissions"
  #     modeset error) still black-screened on resume, AND renamed every output
  #     (eDP-1 -> DP-3, DP-1-0.x -> DP-0.x) which broke the xrandr-do.sh layout.
  # Conclusion: a fundamental NVIDIA-595-on-this-machine resume bug. Staying on
  # reverseSync because it at least gives a working docked multi-monitor desktop.
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    # EXPERIMENT (resume bug): pin 595.84 instead of the locked nixpkgs default
    # 595.71.05, built against the running kernel. Minor bump on the same branch,
    # low odds of fixing the S3 black-panel bug but cheap to try. If it doesn't
    # help, delete this `package` line to fall back to nvidiaPackages.stable.
    # Hashes from nixos-unstable's nvidia-x11 definition for 595.84.
    package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "595.84";
      sha256_64bit = "sha256-mcQE5SExvye8ptoCaNzOPr7cenOrF0BxqZXPGmxeugY=";
      sha256_aarch64 = "sha256-GloNdDFfmXFVu4FAlNNk2qzqLOuw2N5CKatKkcSrQxk=";
      openSha256 = "sha256-pEmA2tUcOKwUPKy6N0QvS49Pdut4/7Phs/JhjdyBcNY=";
      settingsSha256 = "sha256-QrnBM+sdWO4GanO62rxpHmRrjYkYpl5RD6fIiHq4C4A=";
      persistencedSha256 = "sha256-50xYdgx7EEThbaMp4QS8GADbxj0mhBXh8QQN0tWMwRg=";
    };
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    # Required for suspend/resume to work at all with the proprietary driver:
    # installs the nvidia-suspend/nvidia-resume systemd services that save and
    # restore GPU video memory around sleep. Without this the machine suspends
    # but never wakes (black screen, kernel often still alive underneath).
    # NOTE: this is the plain suspend/resume fix, NOT `.finegrained` (runtime
    # GPU power-down), which we deliberately leave off on this docked machine.
    powerManagement.enable = true;
    prime = {
      reverseSync.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # External monitors reach this laptop as DisplayPort tunneled over Thunderbolt
  # -> MST hub in the ThinkPad TBT3 Dock -> monitors, shown by the NVIDIA driver
  # as MST outputs (DP-1-0.2 / DP-1-0.3). On a boot/resume race the NVIDIA X
  # driver sometimes fails to attach modes to those outputs (xrandr:
  # "connected ... but has no modes") until the dock is physically replugged.
  #
  # fwupd is kept enabled for general BIOS/ME/security firmware updates:
  #   fwupdmgr refresh && fwupdmgr get-updates && fwupdmgr update
  services.fwupd.enable = true;
}
