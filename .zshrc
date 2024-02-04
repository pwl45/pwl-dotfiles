# Modified version of Luke's config for the Zoomer Shell

# Enable colors and change prompt:
# fortune | cowsay
# $HOME/scripts/simple-unix
autoload -U colors && colors
# PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b "
# PS1="%B%{$fg[green]%}%n%{$fg[green]%}@%{$fg[green]%}%M%{$fg[white]%}:%{$fg[blue]%}%~%{$reset_color%}$%b "
# PS1="%B%{$fg[green]%}%n%{$fg[green]%}: %{$fg[blue]%}%~%{$reset_color%}$%b "
# PS1='%~: '

# startp=$( echo -n "\x11" )
# endp=$( echo -n "\x14" )
# PS1="${startp}%F{160%}%~%{$reset_color%}:%b ${endp}"
PS1="%F{160%}%~%{$reset_color%}: "
# History in cache directory:
HISTSIZE=1000000
SAVEHIST=1000000
HISTFILE=$HOME/.zhistory
MYVIMRC=$HOME/.config/nvim/init.vim
export EDITOR=nvim

# Basic auto/tab complete:
autoload -U compinit && compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)		# Include hidden files.

# vi mode
bindkey -v
export KEYTIMEOUT=1

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# Change cursor shape for different vi modes.
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'
  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.


# Use lf to switch directories and bind it to ctrl-o
lfcd () {
    tmp="$(mktemp)"
    lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        rm -f "$tmp"
        [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
    fi
}
# bindkey -s '^o' 'lfcd\n'


# Set nvim as manpager
export MANPAGER="nvim +Man!"

# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line

alias history="history 1"
# Load aliases and shortcuts if existent.
# [ -f "$HOME/.config/shortcutrc" ] && source "$HOME/.config/shortcutrc"
[ -f "$HOME/.config/aliasrc" ] && source "$HOME/.config/aliasrc"

# neofetch


fpath=(~/zsh-completions/src $fpath)


# preexec() {
#     exec > >(tee ~/.command.out&)
# }


# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
if [ -n "${commands[fzf-share]}" ]; then
  source "$(fzf-share)/key-bindings.zsh"
  source "$(fzf-share)/completion.zsh"
fi
export FZF_DEFAULT_COMMAND="fd -HI"
export FZF_DEFAULT_OPTS="--reverse --height 70%"
export FZF_COMPLETION_TRIGGER=''

xset r rate 300 50
setxkbmap -option ctrl:nocaps

[ -e "$HOME/.zsh/plugins/zsh-system-clipboard/zsh-system-clipboard.zsh" ] || 
    ( mkdir -p $HOME/.zsh/plugins/ && git clone https://github.com/kutsan/zsh-system-clipboard $HOME/.zsh/plugins/zsh-system-clipboard )
source "$HOME/.zsh/plugins/zsh-system-clipboard/zsh-system-clipboard.zsh"
# Load zsh-syntax-highlighting; should be last.
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null 
export PATH="$HOME/.local/share/gem/ruby/3.0.0/bin:$PATH"
