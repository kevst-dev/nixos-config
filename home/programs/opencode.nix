{
  config,
  pkgs,
  ...
}: {
  # Configuración de OpenCode usando symlinks al repo
  home = {
    packages = with pkgs; [opencode];

    file.".config/opencode/skills".source =
      config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/nixos-config/dotfiles/opencode/skills";

    file.".config/opencode/opencode.json".source =
      config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/nixos-config/dotfiles/opencode/opencode.json";
  };
}
