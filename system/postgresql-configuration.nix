{ config, lib, pkgs, ... }: {

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;
    ensureDatabases = [ "nextcloud" ];
    ensureUsers = [{ name = "nextcloud"; }];
    authentication = ''
      local all all trust
      host all all 127.0.0.1/32 md5
      host all all ::1/128 md5
    '';
    initialScript = pkgs.writeText "backend-initScript" ''
      CREATE ROLE myuser WITH LOGIN PASSWORD 'mypass' CREATEDB;
    '';
  };
}
