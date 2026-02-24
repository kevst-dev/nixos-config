{
  pkgs,
  username,
  ...
}: {
  users.users.${username} = {
    isNormalUser = true;
    shell = pkgs.zsh;
    group = username;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };

  users.groups.${username} = {};
}
