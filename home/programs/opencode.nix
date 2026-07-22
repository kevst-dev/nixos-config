{
  config,
  pkgs,
  ...
}: {
  # Configuración de OpenCode usando symlinks al repo
  home = {
    packages = with pkgs; [opencode];

    file = {
      ".config/opencode/skills".source =
        config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/nixos-config/dotfiles/opencode/skills";

      ".config/opencode/opencode.json".source =
        config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/nixos-config/dotfiles/opencode/opencode.json";

      ".config/opencode/vibeguard.config.json".source =
        config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/nixos-config/dotfiles/opencode/vibeguard.config.json";

      ".config/opencode/dcp.jsonc".source =
        config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/nixos-config/dotfiles/opencode/dcp.jsonc";
    };
  };
}
