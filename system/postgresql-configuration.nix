{ config, lib, pkgs, ... }:
let cfg = config.services.postgresql;
in {
  options.services.postgresql = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable PostgreSQL server.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.postgresql = {
      enable = true;
      package = pkgs.postgresql_14;
      initialScript = pkgs.writeText "initial-postgres.sql" ''
        CREATE DATABASE general;
        \c general
        CREATE SCHEMA tables;
        CREATE TABLE tables.table (
          id int PRIMARY KEY,
          name varchar
        );
      '';
    };

    # Ensure the PostgreSQL service is started
    systemd.services.postgresql.wantedBy = [ "multi-user.target" ];
  };
}
