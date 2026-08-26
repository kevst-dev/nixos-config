{username, ...}: {
  sops = {
    age.keyFile = "/home/${username}/.config/sops/age/keys.txt";
    defaultSopsFile = ../../secrets/sagan.yaml;
    secrets = {
      forgejo_sagan_ssh_key = {
        path = "/home/${username}/.ssh/forgejo_sagan_ed25519";
        owner = username;
        group = username;
        mode = "0600";
      };
    };
  };
}
