{ config, lib, pkgs, username, ... }:
{
  imports = [ ../../modules/system.nix ];
  
  # Configuración específica de WSL
  wsl.enable = true;
  networking.hostName = "wsl";
  wsl.defaultUser = username;

  # Configurar zsh como shell por defecto para el usuario
  users.users.${username}.shell = pkgs.zsh;
  
  # Versión de NixOS para compatibilidad de datos con estado
  system.stateVersion = "25.05";
}
