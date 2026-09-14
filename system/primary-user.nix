{ lib, ... }:
{
  # Primary user on this host; appliance hosts override it (see hosts/thoth).
  options.pwl.username = lib.mkOption {
    type = lib.types.str;
    default = "paul";
  };
}