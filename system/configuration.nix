# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  nixpkgs.overlays = [
    (self: super: {
      dwm = super.dwm.overrideAttrs (oldattrs: {
        src = fetchGit {
          url = "https://github.com/pwl45/pwl-dwm";
          rev = "4c09983c128f80f6c1670bc7540f941fe8c56629";
        };
      });
    })
    (self: super: {
      st = super.st.overrideAttrs (oldattrs: rec {
        buildInputs = oldattrs.buildInputs ++ [ pkgs.harfbuzz ];
        src = fetchGit {
          url = "https://github.com/pwl45/pwl-st";
          rev = "7ab4862a38df97915924ee2a5f32307ce0aec170";
        };
      });
    })
  ];

  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./binbash-configuration.nix
  ];

  nix = {
    package = pkgs.nixFlakes;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };
  nixpkgs.config = { allowUnfree = true; };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;

  networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Easiest to use and most distros use this by default.
  networking.networkmanager.enable = true;

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";
  # time.timeZone = "Europe/Madrid";
  time.timeZone = "America/New_York";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "us";
    windowManager.dwm.enable = true;
    displayManager.lightdm.enable = false;
    displayManager.startx.enable = true;
    libinput = { touchpad.tapping = false; };
  };

  # xorg.xbac
  programs.light.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.extraConfig = "load-module module-combine-sink";

  # Enable touchpad support (enabled default in most desktopManager).

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.alice = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" ]; # Enable ‘sudo’ for the user.
    initialPassword = "pw123";
    # packages = with pkgs; [
    #   firefox
    #   tree
    # ];
  };

  users.users.paul = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "audio"
      "docker"
      "networkmanager"
    ]; # Enable ‘sudo’ for the user.
    initialPassword = "pw123";
    # packages = with pkgs; [
    #   firefox
    #   tree
    # ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    libinput
    home-manager
    harfbuzz
    # neovim
    xclip
    dmenu
    xorg.xinit
    dwm
    st
    killall
    wget
    wirelesstools
    git
    xterm
    alacritty
    alsaUtils
    bash
    gnumake
    gcc
    xorg.libX11
    xorg.libXext
    xorg.libXrender
    xorg.libXt
    pinentry-curses
    zip
    unzip
    docker
  ];
  environment.binbash = pkgs.bash;
  virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };
  # services.docker.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  services.openssh = {
    enable = true;
    # You can add additional configuration options here.
    # For example, to disable root login:
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  networking.firewall.allowedTCPPorts = [ 22 ]; # Default SSH port

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # ripgrep
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
    ubuntu_font_family
    jetbrains-mono
  ];
  programs.zsh.enable = true;
  users.users.alice.shell = pkgs.zsh;
  users.users.paul.shell = pkgs.zsh;

  # environment.etc."polkit-1/rules.d/50-org.freedesktop.NetworkManager.rules".text =
  #   ''
  #     polkit.addRule(function(action, subject) {
  #     if (action.id.indexOf("org.freedesktop.NetworkManager.") == 0 &&
  #         subject.isInGroup("wheel")) {
  #       return polkit.Result.YES;
  #     }
  #     });
  #   '';

  system.stateVersion = "23.11"; # Did you read the comment?
  services.pcscd.enable = true;
  programs.gnupg = {
    agent = {
      enable = true;
      pinentryFlavor = "curses";
      enableSSHSupport = true;
    };
  };
}

