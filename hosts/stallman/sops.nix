{username, ...}: {
  sops = {
    age.keyFile = "/home/${username}/.config/sops/age/keys.txt";

    defaultSopsFile = ../../secrets/stallman.yaml;

    secrets = {
      github_personal_ssh_key = {
        path = "/home/${username}/.ssh/github_personal_ed25519";
        owner = username;
        group = username;
        mode = "0600";
      };
    };
  };
}
