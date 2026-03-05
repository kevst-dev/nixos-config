{username, ...}: {
  users.users.${username} = {
    isNormalUser = true;
    description = "kevst";
    extraGroups = ["networkmanager" "wheel"];
  };
}
