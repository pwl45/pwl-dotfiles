{ config, lib, pkgs, ... }:

with lib;

{

  options = {
    environment.binbash = mkOption {
      default = null;
      type = types.nullOr types.path;
      description = ''
        Include a /bin/bash in the system.
      '';
    };
  };

  config = {

    system.activationScripts.binbash = if config.environment.binbash != null then
      let
        bashPath = "${pkgs.bash}/bin/bash"; # Correct path to the bash executable
      in ''
        mkdir -m 0755 -p /bin
        ln -sfn ${bashPath} /bin/.bash.tmp
        mv /bin/.bash.tmp /bin/bash # Correctly place /bin/bash
      ''
      else ''
        rm -f /bin/bash
      '';

  };

}
