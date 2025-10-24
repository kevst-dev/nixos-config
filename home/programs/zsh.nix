{ config, pkgs, ... }: 
{
  # ==========================================================================
  # Configuración híbrida de Zsh
  # ==========================================================================
  # 
  # ENFOQUE HÍBRIDO:
  # - Home Manager gestiona plugins y configuración base
  # - Dotfiles personalizados mantienen estructura modular
  # - envExtra carga la ruta del zsh personalizado
  # - initExtra carga configuración personalizada al final
  #
  # ORDEN DE CARGA:
  # 1. Home Manager: configuración base + plugins
  # 2. initExtra: carga nuestra configuración personalizada
  # ==========================================================================

  programs.zsh = {
    enable = true;
    
    # Plugins gestionados por Home Manager
    plugins = [
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-syntax-highlighting";
          rev = "0.8.0";
          sha256 = "sha256-iJdWopZwHpSyYl5/FQXEW7gl/SrKaYDEtTH9cGP7iPo=";
        };
      }
    ];

    # Variables que necesitan estar disponibles siempre
    envExtra = ''
      export DOTFILES_DIR="$HOME/nixos-config/dotfiles"
      export ZSH_DIR="$DOTFILES_DIR/zsh"
    '';

    # Cargar configuración personalizada después de cargar los plugins
    initExtra = ''
      # Cargar nuestra configuración modular personalizada
      [[ -f "$ZSH_DIR/.zshrc" ]] && source "$ZSH_DIR/.zshrc"
    '';
  };

}