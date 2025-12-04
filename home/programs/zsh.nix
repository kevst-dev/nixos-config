{
  pkgs,
  lib,
  ...
}: {
  # ==========================================================================
  # Configuración híbrida de Zsh
  # ==========================================================================
  #
  # ENFOQUE HÍBRIDO:
  # - Home Manager gestiona plugins y configuración base
  # - Dotfiles personalizados mantienen estructura modular
  # - envExtra carga la ruta del zsh personalizado
  # - initContent carga configuración personalizada al final
  #
  # ORDEN DE CARGA:
  # 1. Home Manager: configuración base + plugins
  # 2. initContent: carga nuestra configuración personalizada
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
      {
        name = "zsh-autosuggestions";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-autosuggestions";
          rev = "v0.7.1";
          sha256 = "sha256-vpTyYq9ZgfgdDsWzjxVAE7FZH4MALMNZIFyEOBLm5Qo=";
        };
      }
      {
        name = "zsh-vi-mode";
        src = pkgs.fetchFromGitHub {
          owner = "jeffreytse";
          repo = "zsh-vi-mode";
          rev = "v0.12.0";
          sha256 = "sha256-EYr/jInRGZSDZj+QVAc9uLJdkKymx1tjuFBWgpsaCFw=";
        };
      }
      {
        name = "zsh-you-should-use";
        src = pkgs.fetchFromGitHub {
          owner = "MichaelAquilina";
          repo = "zsh-you-should-use";
          rev = "1.10.0";
          sha256 = "sha256-dG6E6cOKu2ZvtkwxMXx/op3rbevT1QSOQTgw//7GmSk=";
        };
      }
    ];

    # Variables que necesitan estar disponibles siempre
    envExtra = ''
      export DOTFILES_DIR="$HOME/nixos-config/dotfiles"
      export ZSH_DIR="$DOTFILES_DIR/zsh"
    '';

    # Cargar configuración personalizada después de cargar los plugins
    initContent = lib.mkOrder 1000 ''
      # Cargar nuestra configuración modular personalizada
      [[ -f "$ZSH_DIR/.zshrc" ]] && source "$ZSH_DIR/.zshrc"
    '';
  };
}
