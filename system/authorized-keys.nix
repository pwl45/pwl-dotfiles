{ config, ... }:

{
  # SSH public keys for the primary user (pwl.username); safe to commit.
  users.users.${config.pwl.username}.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKQeUNo0ygkaX3/4zg4vZf5fpltxOEmLjKdh4duEHcmw paul@t480"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJnfjQAF84pwDS6/Mlzo9hrg3r1WJuoBX3LZ4ODx8Gjc paul@p53"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHjNcOEr5aR2wITslzSH65xQ7khQ2OFiKxb+ryy6t8oM thoth@thoth"
  ];
}
