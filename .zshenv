# ailas
if builtin command -v trash.sh > /dev/null; then
	alias rm='trash.sh -i'
	export TRASHLIST=~/.trashlist # Where trash list is written
	export TRASHBOX=~/.Trash # Where trash will be moved in
	export MAXTRASHBOXSIZE=1024
	export MAXTRASHSIZE=`echo $MAXTRASHBOXSIZE "*" 0.1|bc -l|cut -d. -f1`
fi

if builtin command -v hub > /dev/null; then
  function git(){hub "$@"}
fi
#sudo pip install thefuck
if builtin command -v fuck > /dev/null; then
  eval "$(thefuck --alias f)"
fi

# added by travis gem
[ -f /home/vagrant/.travis/travis.sh ] && source /home/vagrant/.travis/travis.sh

alias gpp='g++ -std=c++11 -Winit-self -Wfloat-equal -Wno-sign-compare -Wunsafe-loop-optimizations -Wshadow -Wall -Wextra -D_GLIBCXX_DEBUG'
alias tmux='tmux -2'
alias t='tmux -2'
function take () { mkdir -p "$@" && eval cd "\"\$$#\"";}
autoload -Uz zmv

alias mmv='noglob zmv -W'

alias youdl="~/cw/python/youtube-dl/youtube_dl/__main__.py"
function addnicolist() {
    /bin/ruby ~/cw/ruby/getmylistids.rb $1 | tee -a ~/cw/db/Temp/nicofab.txt
}

export LESS='-j10 --no-init --quit-if-one-screen' 

alias po='popd'
alias cp='cp -i'
alias mv='mv -i'
alias df='df -h'
alias du='du -h'
alias grep='grep --color'                     # show differences in colour
alias ls='ls -hF --color=tty'                 # classify files in colour
alias dir='ls --color=auto --format=vertical'
alias vdir='ls --color=auto --format=long'
alias ll='ls -l'                              # long list
alias la='ls -A'                              # all but . and ..
alias l='ls -CF'                              #
alias tree='tree -CF'
alias htree='tree -hDF'

alias vi='vim'
alias v='vim'

alias g='git'
alias ga='git add'
alias gap='git add -p'
alias gc='git commit -v'
alias gcm='git commit -m'
alias gcp='git commit -p -v'
alias gcpm='git commit -p -m'
alias gb='git checkout -b'
alias go='git checkout'
alias gf='git fetch'
alias gl='git lg'
alias gd='git d'
alias gds='git ds'

alias a='./a.out'

alias ac='git add . && git commit '


alias mail='sed -e '"'"'1!b;s/^/To: wasss80@gmail.com\nSubject: FromOhtan\n\n/'"'"'| sendmail -t'


### global alias
alias -g G='| grep'
alias -g L='| less -N'
alias -g H='| head -n'
alias -g T='| tail'
alias -g S='| sort'
alias -g W='| wc'
alias -g X='| xargs'
alias -g B='| ruby -e'
alias -g U='--help 2>&1 | less'
alias -g V='| vim -R -'

alias -g ND='*(/om[1])' # newest directory
alias -g NF='*(.om[1])' # newest file

# colored man
man() {
  env \
    LESS_TERMCAP_mb=$(printf "\e[1;33m") \
    LESS_TERMCAP_md=$(printf "\e[1;33m") \
    LESS_TERMCAP_me=$(printf "\e[0m") \
    LESS_TERMCAP_se=$(printf "\e[0m") \
    LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
    LESS_TERMCAP_ue=$(printf "\e[0m") \
    LESS_TERMCAP_us=$(printf "\e[1;32m") \
    man "$@"
}

# path# {{{
if builtin command -v direnv > /dev/null; then
  eval "$(direnv hook zsh)"
fi

# anyenv
if [ -d $HOME/.anyenv ] ; then
    export PATH="$HOME/.anyenv/bin:$PATH"
    eval "$(anyenv init -)"
    for D in `ls $HOME/.anyenv/envs`
    do
      export PATH="$HOME/.anyenv/envs/$D/shims:$PATH"
    done
fi

## opam
if [ -d ${HOME}/.opam/opam-init/init.zsh ] ; then
  . ${HOME}/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true
fi

## rsense
if [ -d ${HOME}/.rsense-0.3  ] ; then
    export RSENSE_HOME=$HOME/.rsense-0.3
fi

## cabal
if [ -d ${HOME}/.cabal  ] ; then
  export PATH=$HOME/.cabal/bin:$PATH
fi

## luajit
export PATH="/usr/local/luajit/bin/:$PATH"

## vim
export PATH="/usr/local/vim/bin/:$PATH"

# go
export GOPATH=$HOME/.go
export PATH="$GOPATH/bin/:$PATH"

## general
export PATH="~/.bin/:$PATH"

# }}}
