# ==============================
# Tùy chọn Zsh
# ==============================
setopt autocd interactivecomments magicequalsubst nonomatch notify numericglobsort promptsubst
WORDCHARS=${WORDCHARS//\/}
PROMPT_EOL_MARK=""

# ==============================
# Bindkey
# ==============================
bindkey -e
bindkey ' ' magic-space
bindkey '^U' backward-kill-line
bindkey '^[[3;5~' kill-word '^[[3~' delete-char
bindkey '^[[1;5C' forward-word '^[[1;5D' backward-word
bindkey '^[[5~' beginning-of-buffer-or-history '^[[6~' end-of-buffer-or-history
bindkey '^[[H' beginning-of-line '^[[F' end-of-line '^[[Z' undo

# ==============================
# Completion
# ==============================
autoload -Uz compinit
compinit -d ~/zsh/zcompdump
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name '' verbose true rehash true use-compctl false
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# ==============================
# Lịch sử
# ==============================
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=2000
setopt hist_expire_dups_first hist_ignore_dups hist_ignore_space hist_verify

# ==============================
# Thời gian lệnh
# ==============================
TIMEFMT=$'\nreal\t%E\nuser\t%U\nsys\t%S\ncpu\t%P'

# ==============================
# Prompt
# ==============================
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi
case "$TERM" in xterm*) color_prompt=yes;; esac
force_color_prompt=yes

configure_prompt() {
    case "$PROMPT_ALTERNATIVE" in
        twoline)
            PROMPT=$'%F{%(#.blue.green)}┌──${debian_chroot:+($debian_chroot)─}${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV))─}(%B%F{%(#.red.blue)}%n%b%F{%(#.blue.green)})-[%B%F{reset}%(6~.%-1~/…/%4~.%5~)%b%F{%(#.blue.green)}]\n└─%B%(#.%F{red}#.%F{blue}$)%b%F{reset} '
            ;;
        oneline)
            PROMPT=$'${debian_chroot:+($debian_chroot)}${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV))}%B%F{%(#.red.blue)}%n@%m%b%F{reset}:%B%F{%(#.blue.green)}%~%b%F{reset}%(#.#.$) '
            RPROMPT=
            ;;
        backtrack)
            PROMPT=$'${debian_chroot:+($debian_chroot)}${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV))}%B%F{red}%n@%m%b%F{reset}:%B%F{blue}%~%b%F{reset}%(#.#.$) '
            RPROMPT=
            ;;
    esac
}
PROMPT_ALTERNATIVE=twoline
NEWLINE_BEFORE_PROMPT=yes

if [ "$color_prompt" = yes ]; then
    VIRTUAL_ENV_DISABLE_PROMPT=1
    configure_prompt
    if [ -f ~/zsh/zsh-syntax-highlighting.zsh ]; then
        . ~/zsh/zsh-syntax-highlighting.zsh
        ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
        ZSH_HIGHLIGHT_STYLES=(
            [default]=none
            [unknown-token]=underline
            [reserved-word]='fg=cyan,bold'
            [suffix-alias]='fg=green,underline'
            [global-alias]='fg=green,bold'
            [precommand]='fg=green,underline'
            [commandseparator]='fg=blue,bold'
            [autodirectory]='fg=green,underline'
            [path]=bold
            [globbing]='fg=blue,bold'
            [history-expansion]='fg=blue,bold'
            [command-substitution]=none
            [command-substitution-delimiter]='fg=magenta,bold'
            [process-substitution]=none
            [process-substitution-delimiter]='fg=magenta,bold'
            [single-hyphen-option]='fg=green'
            [double-hyphen-option]='fg=green'
            [back-quoted-argument]=none
            [back-quoted-argument-delimiter]='fg=blue,bold'
            [single-quoted-argument]='fg=yellow'
            [double-quoted-argument]='fg=yellow'
            [dollar-quoted-argument]='fg=yellow'
            [rc-quote]='fg=magenta'
            [dollar-double-quoted-argument]='fg=magenta,bold'
            [back-double-quoted-argument]='fg=magenta,bold'
            [back-dollar-quoted-argument]='fg=magenta,bold'
            [assign]=none
            [redirection]='fg=blue,bold'
            [comment]='fg=black,bold'
            [named-fd]=none
            [numeric-fd]=none
            [arg0]='fg=cyan'
            [bracket-error]='fg=red,bold'
            [bracket-level-1]='fg=blue,bold'
            [bracket-level-2]='fg=green,bold'
            [bracket-level-3]='fg=magenta,bold'
            [bracket-level-4]='fg=yellow,bold'
            [bracket-level-5]='fg=cyan,bold'
            [cursor-matchingbracket]=standout
        )
    fi
else
    PROMPT='${debian_chroot:+($debian_chroot)}%n@%m:%~%(#.#.$) '
fi
unset color_prompt force_color_prompt

toggle_oneline_prompt(){
    [[ "$PROMPT_ALTERNATIVE" = oneline ]] && PROMPT_ALTERNATIVE=twoline || PROMPT_ALTERNATIVE=oneline
    configure_prompt
    zle reset-prompt
}
zle -N toggle_oneline_prompt
bindkey ^P toggle_oneline_prompt

# ==============================
# Tiêu đề terminal
# ==============================
case "$TERM" in
    xterm*)
        TERM_TITLE=$'\e]0;${debian_chroot:+($debian_chroot)}${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV))}%n@%m: %~\a'
        ;;
esac
precmd() {
    print -Pnr -- "$TERM_TITLE"
    [[ "$NEWLINE_BEFORE_PROMPT" = yes ]] && { [[ -z "$_NEW_LINE_BEFORE_PROMPT" ]] && _NEW_LINE_BEFORE_PROMPT=1 || print ""; }
}

# ==============================
# Màu lệnh & alias
# ==============================
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    export LS_COLORS="$LS_COLORS:ow=30;44:"
    alias ls='ls --color=auto' grep='grep --color=auto' fgrep='fgrep --color=auto' egrep='egrep --color=auto' diff='diff --color=auto' ip='ip --color=auto'
    export LESS_TERMCAP_mb=$'\E[1;31m' LESS_TERMCAP_md=$'\E[1;36m' LESS_TERMCAP_me=$'\E[0m'
    export LESS_TERMCAP_so=$'\E[01;33m' LESS_TERMCAP_se=$'\E[0m' LESS_TERMCAP_us=$'\E[1;32m' LESS_TERMCAP_ue=$'\E[0m'
    zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
    zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
fi

# ==============================
# Plugin
# ==============================
[[ -f ~/zsh/zsh-autosuggestions.zsh ]] && { . ~/zsh/zsh-autosuggestions.zsh; ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#999'; }
[[ -f ~/zsh/zsh_command_not_found ]] && . ~/zsh/zsh_command_not_found

# ==============================
# Input method
# ==============================
export GTK_IM_MODULE=ibus

alias history='history 0'
alias ll='ls -l' la='ls -A' l='ls -CF'
alias battery='upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep capacity | cut -d ':' -f2 | xargs'
