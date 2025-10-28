{ config, pkgs, ... }: {
  # Zoxide - navegación inteligente de directorios
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
