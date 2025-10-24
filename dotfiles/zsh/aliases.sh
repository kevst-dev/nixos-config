#!/bin/zsh

# =============================================================================
# Aliases de Git
# =============================================================================

# Comandos básicos de git
alias g='git'
alias gst='git status'
alias ga='git add'
alias gc='git commit'
alias gac='git add . && git commit'

# Gestión de ramas
alias gb='git branch'
alias gch='git checkout'
alias gnb='git checkout -b'

# Operaciones remotas
alias gcl='git clone'
alias gr='git remote'
alias gf='git fetch'
alias gpl='git pull'
alias gpom='git pull origin master'
alias gpu='git push'
alias gpuom='git push origin master'

# Diff y restauración
alias gd='git diff'
alias gre='git restore'
alias grs='git restore --staged .'

# Merge
alias gm='git merge'

# Listado de archivos
alias gt='git ls-tree -r master --name-only'

# Aliases de log - formato visual mejorado
# glg: --graph (gráfico ASCII de ramas) + --abbrev-commit (hash corto) + 
#      --decorate (nombres de ramas/tags) + --format (formato personalizado) + 
#      --all (todas las ramas)
alias glg="git log \
    --graph \
    --abbrev-commit \
    --decorate \
    --format=format:'\
        %C(bold green)%h%C(reset) - \
        %C(bold cyan)%aD%C(reset) %C(bold yellow)(%ar)%C(reset)\
        %C(auto)%d%C(reset)%n\
        %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' \
    --all"
alias gl="glg -5"
