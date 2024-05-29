{ config, lib, pkgs, ... }: {
  services.nextcloud = {
    enable = true;
    hostName = "nextcloud.local";
    config = {
      dbtype = "pgsql";
      dbuser = "nextcloud";
      dbhost = "/run/postgresql";
      dbname = "nextcloud";
      adminuser = "admin";
      adminpassFile = "/home/paul/testfl";
    };
  };
}
