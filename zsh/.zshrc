# ~/.zshrc: executed by zsh for interactive shells.
# Ported from bash/.bashrc — kept the same behaviour, expressed in zsh idioms.

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# --- History -----------------------------------------------------------------
# Equivalent of bash's HISTCONTROL=ignoreboth (ignore dups + space-prefixed),
# histappend, and the HISTSIZE/HISTFILESIZE settings.
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=2000
setopt HIST_IGNORE_ALL_DUPS   # don't record duplicate commands
setopt HIST_IGNORE_SPACE      # don't record commands starting with a space
setopt APPEND_HISTORY         # append rather than overwrite
setopt INC_APPEND_HISTORY     # write each command as it's entered
setopt SHARE_HISTORY          # share history across running shells

# zsh checks the window size automatically, so no checkwinsize equivalent needed.

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set colours (for wezterm compatibility)
export COLORTERM=truecolor

# --- Prompt ------------------------------------------------------------------
# Coloured user@host:cwd prompt, mirroring the bashrc PS1.
setopt PROMPT_SUBST
PROMPT='${debian_chroot:+($debian_chroot)}%F{green}%n@%m%f:%F{blue}%~%f%# '

# If this is an xterm, set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    precmd() { print -Pn "\e]0;${debian_chroot:+($debian_chroot)}%n@%m: %~\a" }
    ;;
esac

# --- Completion --------------------------------------------------------------
autoload -Uz compinit && compinit
# allow bash-style completion scripts (used by nvm) to load
autoload -Uz bashcompinit && bashcompinit
# colourise the completion menu using LS_COLORS
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# --- Colours & aliases -------------------------------------------------------
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Extra aliases (mirror of bash's ~/.bash_aliases hook)
[ -f ~/.zsh_aliases ] && source ~/.zsh_aliases

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('$HOME/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
        . "$HOME/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# Start ssh-agent if it is not already running
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)" > /dev/null
fi

# Add your default key (optional: remove if you prefer manual adding)
ssh-add ~/.ssh/id_rsa 2>/dev/null

export EDITOR="vim"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
