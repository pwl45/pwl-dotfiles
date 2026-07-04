{ ... }:

{
  # SSH public keys authorized to log in as `paul` on every host that imports
  # common.nix. Public keys are safe to commit; only the private key is secret.
  # The trailing comment (e.g. paul@t480) is just a label for which key is which.
  users.users.paul.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKQeUNo0ygkaX3/4zg4vZf5fpltxOEmLjKdh4duEHcmw paul@t480"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJnfjQAF84pwDS6/Mlzo9hrg3r1WJuoBX3LZ4ODx8Gjc paul@p53"
  ];
}
