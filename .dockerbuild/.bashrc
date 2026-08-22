# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

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
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\] \[\033[01;34m\]\W\[\033[00m\] --> '
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

alias find_and_rm_instr="find /data/hmm_modeling/fingerspelling/ContinuousBigram/instr/ -maxdepth 1 -type f -regextype posix-extended -regex '.*\.[0-9a-fA-F]{8}\..*' -print0 | xargs -0 rm -rf {}"

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

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

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

#### variables and functions defined below
#### assume a specific path structure.

# useful env variables
export CB_DIR="/data/hmm_modeling/fingerspelling/ContinuousBigram"

# aliases
alias count_CB_dir="ls $CB_DIR/ | wc -l"
alias clone_fs="git clone https://github.com/rohit-sridhar/fingerspelling"
alias concat_csvs="awk '(NR == 1) || (FNR > 1)' *.csv > combined.csv"

# useful functions
# directly cleans $1 in CB_DIR.
function clean_CB_dir() {
    if [[ "${1}" == "-h" || "${1}" == "--help" ]]; then
        echo "clean_CB_dir [-h]? [-p]? [dataset]"
        echo "dataset is the subdir directly under"
        echo "ContinuousBigram/data/"
        return
    fi

    if [[ "${1}" == "-p" || "${1}" == "--print" ]]; then
        ls -dlh $CB_DIR/data/$2*/
        ls -dlh $CB_DIR/label/$2*/
        ls -dlh $CB_DIR/scripts/$2*/
        ls -dlh $CB_DIR/commands/$2*/
        ls -dlh $CB_DIR/dict/$2*/
        ls -dlh $CB_DIR/ext/$2*/
        ls -dlh $CB_DIR/grammar/$2*/
        ls -dlh $CB_DIR/mlf/$2*/
        ls -dlh $CB_DIR/output/$2*/
        ls -dlh $CB_DIR/logs/$2*/
        ls -dlh $CB_DIR/models/$2*/
        ls -dlh $CB_DIR/results/$2*/
        return
    fi

    rm -rf $CB_DIR/data/$1*
    rm -rf $CB_DIR/label/$1*
    rm -rf $CB_DIR/scripts/$1*
    rm -rf $CB_DIR/commands/$1*
    rm -rf $CB_DIR/dict/$1*
    rm -rf $CB_DIR/ext/$1*
    rm -rf $CB_DIR/grammar/$1*
    rm -rf $CB_DIR/mlf/$1*
    rm -rf $CB_DIR/output/$1*
    rm -rf $CB_DIR/logs/$1*
    rm -rf $CB_DIR/models/$1*
    rm -rf $CB_DIR/results/$1*
}

function clean_CB_data_labels() {
    if [[ "${1}" == "-h" || "${1}" == "--help" ]]; then
        echo "clean_CB_data_labels [-h]? [-p]? [dataset]"
        echo "dataset is the subdir directly under"
        echo "ContinuousBigram/data/"
        return
    fi

    if [[ "${1}" == "-p" || "${1}" == "--print" ]]; then
        ls -dlh $CB_DIR/data/$2*/
        ls -dlh $CB_DIR/label/$2*/
        return
    fi

    rm -rf $CB_DIR/data/$1*
    rm -rf $CB_DIR/label/$1*
}

function clean_CB_helper_dirs() {
    if [[ "${1}" == "-h" || "${1}" == "--help" ]]; then
        echo "clean_CB_helper_dirs [-h]? [-p]? [dataset]"
        echo "dataset is the subdir directly under"
        echo "ContinuousBigram/data/"
        return
    fi

    if [[ "${1}" == "-p" || "${1}" == "--print" ]]; then
        ls -dlh $CB_DIR/scripts/$2*/
        ls -dlh $CB_DIR/output/$2*/
        ls -dlh $CB_DIR/logs/$2*/
        ls -dlh $CB_DIR/models/$2*/
        ls -dlh $CB_DIR/results/$2*/
        return
    fi

    rm -rf $CB_DIR/scripts/$1*
    rm -rf $CB_DIR/output/$1*
    rm -rf $CB_DIR/logs/$1*
    rm -rf $CB_DIR/models/$1*
    rm -rf $CB_DIR/results/$1*
}

function clean_CB_htk_files() {
    if [[ "${1}" == "-h" || "${1}" == "--help" ]]; then
        echo "clean_CB_htk_files [-h]? [-p]? [dataset]"
        echo "dataset is the subdir directly under"
        echo "ContinuousBigram/data/"
        return
    fi

    if [[ "${1}" == "-p" || "${1}" == "--print" ]]; then
        ls -dlh $CB_DIR/commands/$2*/
        ls -dlh $CB_DIR/dict/$2*/
        ls -dlh $CB_DIR/ext/$2*/
        ls -dlh $CB_DIR/grammar/$2*/
        ls -dlh $CB_DIR/mlf/$2*/
        return
    fi

    rm -rf $CB_DIR/commands/$1*
    rm -rf $CB_DIR/dict/$1*
    rm -rf $CB_DIR/ext/$1*
    rm -rf $CB_DIR/grammar/$1*
    rm -rf $CB_DIR/mlf/$1*
}

# find and delete directories
function find_and_delete_dirs() {
    if [[ "${1}" == "-h" || "${1}" == "--help" ]]; then
        echo "find_and_delete_dirs [root_dir] [dir_pattern]"
        return
    fi
    
    if [[ "${1}" == "-p" || "${1}" == "--print" ]]; then
        find $2 -depth -type d -name "${3}"
    else
        find $1 -depth -type d -name "${2}" -exec rm -rf {} +
    fi
}

function find_and_delete_files() {
    if [[ "${1}" == "-h" || "${1}" == "--help" ]]; then
        echo "find_and_delete_files [-h]? [-p]? [root_dir] [file_pattern]"
        return
    fi
    
    if [[ "${1}" == "-p" || "${1}" == "--print" ]]; then
        find $2 -type f -name "${3}" --delete
    else
        find $1 -type f -name "${2}"
    fi
}

function find_and_grep() {
    if [[ "${1}" == "-h" || "${1}" == "--help" ]]; then
        echo "find_and_grep [-h]? [-p]? [root_dir] [file_pattern] [match_regex]"
        return
    fi

    if [[ "${3}" == "" ]]; then
        find $1 -type f -name "${2}"
    else
        find $1 -type f -name "${2}" -print0 | xargs -0 grep -E "${3}"
    fi
}

function open_files() {
    if [[ "${1}" == "-h" || "${1}" == "--help" ]]; then
        echo "open_files [-h]? [-p]? [root_dir] [file_pattern] [match_regex]?"
    elif [[ "${1}" == "-p" || "${1}" == "--print" ]]; then
        if [[ "${4}" == "" ]]; then
            find $2 -type f -name "${3}"
        else
            find $2 -type f -name "${3}" -print0 | xargs -0 grep -lE "${4}"
        fi
    else
        if [[ "${3}" == "" ]]; then
            vi -p $(find $1 -type f -name "${2}")
        else
            vi -p $(find $1 -type f -name "${2}" -print0 | xargs -0 grep -lE "${3}")
        fi
    fi
}

# Only works in fingerspelling_dl env
# export LD_LIBRARY_PATH=/home/rsridhar37/miniconda3/envs/fingerspelling_dl_new/lib:$LD_LIBRARY_PATH

export KAGGLE_API_TOKEN=KGAT_5404e10a0d20027cddb6ba18756f85d6
export LOCAL_HTK_IMAGE=rohit_hmm_fingerspelling

sudo() {
    # Check if the first argument is a defined bash function
    if [ -n "$1" ] && [ "$(type -t "$1")" = "function" ]; then
        local func_name="$1"
        shift
        # Run sudo, export the target function, and execute it with remaining arguments
        command sudo -E bash -c "$(declare -f "$func_name"); $func_name \"\$@\"" bash "$@"
    else
        # Fallback to standard sudo for regular commands and binaries
        command sudo "$@"
    fi
}

