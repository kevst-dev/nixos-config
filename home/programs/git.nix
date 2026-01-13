{pkgs, ...}: {
  home.packages = [pkgs.gh];

  programs.git = {
    enable = true;

    settings = {
      core.autocrlf = "input"; # Convierte CRLF a LF al hacer commit
      core.eol = "lf"; # Usa LF como line ending
    };
  };
}
