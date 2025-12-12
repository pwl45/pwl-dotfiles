# Modified version of Luke's config for the Zoomer Shell

# Enable colors and change prompt:
# fortune | cowsay
# $HOME/scripts/simple-unix
autoload -U colors && colors

export PATH="$HOME/.local/bin:$PATH"
if [ -z "$TMUX" ]; then
    # Generate a unique session name with the format YYYY_MM_DD
    session_name="session_$(date +%Y_%m_%d)_$RANDOM"
    # Start a new tmux session with the unique name
    tmux new-session -s "$session_name"
fi

if [[ -n $SSH_CONNECTION ]]; then
  # Include user@hostname in the prompt for SSH sessions
  PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[magenta]%}@%{$fg[blue]%}%M %{$fg[green]%}%~%{$fg[red]%}]%{$reset_color%}:%b "
else
  # Keep your original prompt for non-SSH sessions
    PS1="%F{160}%~%{$reset_color%}"
fi

if [[ -n $IN_NIX_SHELL ]]; then
  PS1="%B%{$fg[cyan]%}[nix-shell]%}$reset_color $PS1"
fi

setopt INC_APPEND_HISTORY

# Share history between all active zsh sessions
setopt SHARE_HISTORY

# Save timestamps in history
setopt EXTENDED_HISTORY
export PROMPT_START="⸢"
export PROMPT_END="⸥"
PS1="${PROMPT_START}${PS1}${PROMPT_END} "

# History in cache directory:
HISTSIZE=1000000
SAVEHIST=1000000
HISTFILE=$HOME/.zhistory
MYVIMRC=$HOME/.config/nvim/init.vim
export EDITOR=nvim
export SUDO_EDITOR=$(which nvim)

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

# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
if [ -n "${commands[fzf-share]}" ]; then
  source "$(fzf-share)/key-bindings.zsh"
  source "$(fzf-share)/completion.zsh"
fi
bindkey '^I' expand-or-complete
export FZF_DEFAULT_COMMAND="fd -HI"
export FZF_DEFAULT_OPTS="--reverse --height 70%"
export FZF_COMPLETION_TRIGGER=''


if [[ -n $DISPLAY ]]; then
    # zsh-system-clipboard
    [ -e "$HOME/.zsh/plugins/zsh-system-clipboard/zsh-system-clipboard.zsh" ] || ( mkdir -p $HOME/.zsh/plugins/ && git clone https://github.com/kutsan/zsh-system-clipboard $HOME/.zsh/plugins/zsh-system-clipboard )
    source "$HOME/.zsh/plugins/zsh-system-clipboard/zsh-system-clipboard.zsh"
    
    # other X things
    xset r rate 300 50
    setxkbmap -option ctrl:nocaps
    killall xcape 2>/dev/null && xcape -e 'Control_L=Escape'
fi

[ -f "$HOME/.config/zsh/.local.zshrc" ] && source "$HOME/.config/zsh/.local.zshrc"

# zsh-syntax-highlighting
[ -e "$HOME/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] ||
    ( mkdir -p $HOME/.zsh/plugins/ && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.zsh/plugins/zsh-syntax-highlighting )
source "$HOME/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# zsh-autosuggestions
[ -e "$HOME/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ] ||
    ( mkdir -p $HOME/.zsh/plugins/ && git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.zsh/plugins/zsh-autosuggestions )
source "$HOME/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"


