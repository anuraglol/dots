if status is-interactive
    # Commands to run in interactive sessions can go here
    # Add to ~/.config/fish/config.fish
    set -x LANG en_US.UTF-8
    set -x LC_ALL en_US.UTF-8
    set -x GTK_IM_MODULE xim

    nvm use lts --silent
end

# pnpm
set -gx PNPM_HOME "/home/anurag/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
    set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

# aliases
alias cls="clear"
alias nf="neofetch"
alias vim="nvim"
alias n="nvim"
alias ff="fastfetch"
alias pn="pnpm"
alias pni="pnpm i"

alias c="nvim"

source ~/miniconda3/etc/fish/conf.d/conda.fish
zoxide init fish | source

function toggle-dns
    ~/Documents/dev/scripts/dns-toggle-script.sh
end
