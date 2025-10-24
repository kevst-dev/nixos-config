{ config, lib, pkgs, ... }:
{
  imports = [ ../../modules/system.nix ];
  
  # Configuración específica de WSL
  wsl.enable = true;
  networking.hostName = "wsl";
  wsl.defaultUser = "kevst";
  
  # Versión de NixOS para compatibilidad de datos con estado
  system.stateVersion = "25.05";
}