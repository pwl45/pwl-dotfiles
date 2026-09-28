{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix # generated at runtime by nixos-infect

  ];

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.hostName = "auth";
  networking.domain = "";
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = false;
    };
    forwardX11 = true;
  };
  environment.systemPackages = with pkgs; [
    git
    neovim
    xclip
    xsel
    hugo
    config.services.headscale.package
    (pkgs.writeShellScriptBin "headscale-paul-key" ''
      set -euo pipefail
      user_id=$(${lib.getExe config.services.headscale.package} users list --output json \
        | ${lib.getExe pkgs.jq} -er '.[] | select(.name == "paul") | .id')
      ${lib.getExe config.services.headscale.package} preauthkeys create \
        --user "$user_id" --expiration 5m --output json
    '')
  ];

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKQeUNo0ygkaX3/4zg4vZf5fpltxOEmLjKdh4duEHcmw alice@nixos"
  ];
  users.users.alice = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "audio"
      "nginx"
    ];
    packages = with pkgs; [
      tree
      nixfmt
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKQeUNo0ygkaX3/4zg4vZf5fpltxOEmLjKdh4duEHcmw alice@nixos"
    ];
  };
  programs.zsh.enable = true;
  users.users.alice.shell = pkgs.zsh;

  services.nginx = {
    enable = true;
    virtualHosts."5.161.116.220" = {
      root = "/var/www/default";
      locations."/" = {
        extraConfig = ''
          try_files $uri $uri/ =404;
          autoindex on;
        '';
      };

    };
    virtualHosts."paullapey.com" = {
      forceSSL = true;
      enableACME = true;
      root = "/var/www/default";
      locations."/" = {
        extraConfig = ''
          try_files $uri $uri/ =404;
          autoindex on;
        '';
      };
    };
    virtualHosts."auth.paullapey.com" = {
      forceSSL = true; # Redirect HTTP to HTTPS
      enableACME = true; # Automatically obtain SSL certificate
      root = "/var/www/default"; # Change this if needed
      locations."/" = {
        proxyPass = "http://localhost:${toString config.services.headscale.port}";
        proxyWebsockets = true;
      };

    };
  };
  networking.firewall = {
    allowedTCPPorts = [
      80
      443
      4431
      8080
    ];
  };

  # Enable ACME (Let's Encrypt) service
  security.acme = {
    acceptTerms = true;
    defaults.email = "plapey45@gmail.com";
  };

  security.sudo.extraRules = [
    {
      users = [ "alice" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/headscale-paul-key";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  services.headscale = {
    enable = true;
    address = "0.0.0.0";
    port = 8080;

    settings = {
      server_url = "https://auth.paullapey.com";
      dns = {
        base_domain = "tail.paullapey.com";
        override_local_dns = false;
      };
    };
  };

  services.tailscale = {
    enable = true;
    extraUpFlags = [ ]; # This ensures no --no-logs-no-support flag is passed
  };

  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  system.stateVersion = "23.11";
  systemd.services.ensure-var-www = {
    description = "Ensure /var/www exists and is owned by nginx";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    script = ''
       mkdir -p /var/www/default
      chown nginx:nginx /var/www/default
      chmod 775 /var/www/default
    '';
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = true;
  };

  nix.settings.trusted-users = [
    "root"
    "alice"
  ];

}
