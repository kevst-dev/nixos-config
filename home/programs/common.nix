{ config, lib, pkgs, ... }:
{
    # Paquetes comunes para usuarios
    home.packages = with pkgs; [
        # desarrollo
        claude-code
    ];
}     