# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac


# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# --------------------------------------------------------------------------------
# Added
# --------------------------------------------------------------------------------

parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
export PS1="\u@\h \[\e[32m\]\w \[\e[91m\]\$(parse_git_branch)\[\e[00m\]$ "

# History Management
shopt -s histappend
export HISTCONTROL=ignoreboth:erasedups
export PROMPT_COMMAND="history -n; history -w; history -c; history -r"
# Remove duplicates from history while preserving order
tac "$HISTFILE" | awk '!x[$0]++' >| /tmp/tmpfile  && 
    tac /tmp/tmpfile >| "$HISTFILE"
rm /tmp/tmpfile

# Increase history size for better command recall
export HISTSIZE=10000
export HISTFILESIZE=10000

export HISTTIMEFORMAT="%F %T "  # Add timestamps to history
export HISTIGNORE="ls:ll:cd:pwd:bg:fg:history"  # Don't record common commands

# Enable partial history search with Up/Down arrows
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# Autostart tmux with intelligent checks
if command -v tmux &> /dev/null && # verify tmux installation
   [ -n "$PS1" ] &&                # ensure interactive shell
   [[ ! "$LAUNCHED" == "vscode" ]] && # skip in VSCode
   [[ ! "$TERM" =~ screen ]] &&    # skip in screen
   [[ ! "$TERM" =~ tmux ]] &&      # skip in tmux terminal
   [ -z "$TMUX" ]; then            # skip if already in tmux
  tmux new-session -A -s main
fi
# --------------------------------------------------------------------------------
# Aliases
# --------------------------------------------------------------------------------

# Better directory listing
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias lh='ls -lh'  # Human readable sizes
alias lsd='ls -d */'  # List directories only

# Set to prevent overwritting. Now > must be used as >| to overwrite
set -o noclobber

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias cdh='cd ~'
alias back='cd -'
alias ..2='cd ../..'
alias ..3='cd ../../..'
alias ..4='cd ../../../..'

# Shorcuts
alias update='sudo apt update'
alias cl='clear'

# System commands with safer defaults
alias mkdir='mkdir -pv'
alias cp='cp -i'
alias mv='mv -i'
# Prevent accidental data loss and system changes
alias rm='rm -i'       # Prompt before every removal
# Prevent root-owned directory operations that could break system
alias chmod='chmod --preserve-root'  # Prevent recursive chmod on root
alias chown='chown --preserve-root'  # Prevent recursive chown on root

# System information
alias h='history'

# Network utilities
alias ports='netstat -tulanp'
alias localip='hostname -I'    # Show all local IP addresses
alias publicip='curl -s ifconfig.me'  # Show public IP - useful for remote access setup
alias ports='netstat -tulanp'  # Show all active ports and their processes
alias listening='netstat -tunlp'  # Show only listening ports - good for security audits

# tmux management
alias tmux_rel='tmux source-file ~/.tmux.conf'
alias trel='tmux source-file ~/.tmux.conf'
alias tmuxes='tmux ls'
alias ta='tmux attach -t'
alias tnew='tmux new -s'

# Git shortcuts
alias ga='git add'
alias gaa='git add .'
alias gc='git commit -m'
alias gst='git status'
alias pull='git pull'
alias push='git push'

# Because typing 'python3' every time is so 2019
alias python=python3
alias pip=pip3

# The "oops" section - because we're all human
alias sl='ls'
alias cd..='cd ..'
alias grpe='grep'
alias gti='git'

# Memory and CPU monitoring shortcuts
alias df='df -h'
alias du='du -h'
alias meminfo='free -m -l -h'  # Detailed memory usage in human readable format
alias cpuinfo='lscpu'          # CPU architecture information
alias disk='df -h | grep -v tmpfs'  # Disk usage excluding temporary filesystems
# Process monitoring - helps identify resource hogs
alias psmem='ps auxf | sort -nr -k 4 | head -10'  # Shows top 10 memory-consuming processes
alias pscpu='ps auxf | sort -nr -k 3 | head -10'  # Shows top 10 CPU-consuming processes

# Enhanced grep
alias grep='grep --color=auto'     # Highlight matches in grep output
alias egrep='egrep --color=auto'   # Same for extended grep
alias fgrep='fgrep --color=auto'   # Same for fixed string grep

# Command line productivity
export EDITOR=vim      # Use vim as default editor
export VISUAL=vim      # Use vim for visual editing
set -o vi             # Enable vi-style command line editing

