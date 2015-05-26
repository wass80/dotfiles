## prompt# {{{
autoload -Uz colors; colors
autoload -Uz vcs_info
autoload -Uz add-zsh-hook
autoload -Uz is-at-least

# 以下の3つのメッセージをエクスポートする
#   $vcs_info_msg_0_ : 通常メッセージ用 (緑)
#   $vcs_info_msg_1_ : 警告メッセージ用 (黄色)
#   $vcs_info_msg_2_ : エラーメッセージ用 (赤)
zstyle ':vcs_info:*' max-exports 3

zstyle ':vcs_info:*' enable git svn hg bzr
# 標準のフォーマット(git 以外で使用)
# misc(%m) は通常は空文字列に置き換えられる
zstyle ':vcs_info:*' formats '(%s)-[%b]'
zstyle ':vcs_info:*' actionformats '(%s)-[%b]' '%m' '<!%a>'
zstyle ':vcs_info:(svn|bzr):*' branchformat '%b:r%r'
zstyle ':vcs_info:bzr:*' use-simple true


if is-at-least 4.3.10; then
    # git 用のフォーマット
    # git のときはステージしているかどうかを表示
    zstyle ':vcs_info:git:*' formats '[%b]' '%c%u %m'
    zstyle ':vcs_info:git:*' actionformats '[%b]' '%c%u %m' '<!%a>'
    zstyle ':vcs_info:git:*' check-for-changes true
    zstyle ':vcs_info:git:*' stagedstr "+"    # %c で表示する文字列
    zstyle ':vcs_info:git:*' unstagedstr "-"  # %u で表示する文字列
fi

# hooks 設定
if is-at-least 4.3.11; then
    # git のときはフック関数を設定する

    # formats '(%s)-[%b]' '%c%u %m' , actionformats '(%s)-[%b]' '%c%u %m' '<!%a>'
    # のメッセージを設定する直前のフック関数
    # 今回の設定の場合はformat の時は2つ, actionformats の時は3つメッセージがあるので
    # 各関数が最大3回呼び出される。
    zstyle ':vcs_info:git+set-message:*' hooks \
        git-hook-begin \
        git-untracked \
        git-push-status \
        git-nomerge-branch \
        git-stash-count

    # フックの最初の関数
    # git の作業コピーのあるディレクトリのみフック関数を呼び出すようにする
    # (.git ディレクトリ内にいるときは呼び出さない)
    # .git ディレクトリ内では git status --porcelain などがエラーになるため
    function +vi-git-hook-begin() {
        if [[ $(command git rev-parse --is-inside-work-tree 2> /dev/null) != 'true' ]]; then
            # 0以外を返すとそれ以降のフック関数は呼び出されない
            return 1
        fi

        return 0
    }

    # untracked フィアル表示
    #
    # untracked ファイル(バージョン管理されていないファイル)がある場合は
    # unstaged (%u) に ? を表示
    function +vi-git-untracked() {
        # zstyle formats, actionformats の2番目のメッセージのみ対象にする
        if [[ "$1" != "1" ]]; then
            return 0
        fi

        if command git status --porcelain 2> /dev/null \
            | awk '{print $1}' \
            | command grep -F '??' > /dev/null 2>&1 ; then

        # unstaged (%u) に追加
        hook_com[unstaged]+='?'
        fi
    }

    # push していないコミットの件数表示
    #
    # リモートリポジトリに push していないコミットの件数を
    # pN という形式で misc (%m) に表示する
    function +vi-git-push-status() {
    # zstyle formats, actionformats の2番目のメッセージのみ対象にする
    if [[ "$1" != "1" ]]; then
        return 0
    fi

    if [[ "${hook_com[branch]}" != "master" ]]; then
        # master ブランチでない場合は何もしない
        return 0
    fi

    # push していないコミット数を取得する
    local ahead
    ahead=$(command git rev-list origin/master..master 2>/dev/null \
        | wc -l \
        | tr -d ' ')

    if [[ "$ahead" -gt 0 ]]; then
        # misc (%m) に追加
        hook_com[misc]+="(p${ahead})"
    fi
    }

    # マージしていない件数表示
    #
    # master 以外のブランチにいる場合に、
    # 現在のブランチ上でまだ master にマージしていないコミットの件数を
    # (mN) という形式で misc (%m) に表示
    function +vi-git-nomerge-branch() {
    # zstyle formats, actionformats の2番目のメッセージのみ対象にする
    if [[ "$1" != "1" ]]; then
        return 0
    fi

    if [[ "${hook_com[branch]}" == "master" ]]; then
        # master ブランチの場合は何もしない
        return 0
    fi

    local nomerged
    nomerged=$(command git rev-list master..${hook_com[branch]} 2>/dev/null | wc -l | tr -d ' ')

    if [[ "$nomerged" -gt 0 ]] ; then
        # misc (%m) に追加
        hook_com[misc]+="(m${nomerged})"
    fi
    }

    # stash 件数表示
    #
    # stash している場合は :SN という形式で misc (%m) に表示
    function +vi-git-stash-count() {
    # zstyle formats, actionformats の2番目のメッセージのみ対象にする
    if [[ "$1" != "1" ]]; then
        return 0
    fi

    local stash
    stash=$(command git stash list 2>/dev/null | wc -l | tr -d ' ')
    if [[ "${stash}" -gt 0 ]]; then
        # misc (%m) に追加
        hook_com[misc]+=":S${stash}"
    fi
    }

fi

function _update_vcs_info_msg() {
    local -a messages
    local prompt

    LANG=en_US.UTF-8 vcs_info

    if [[ -z ${vcs_info_msg_0_} ]]; then
        # vcs_info で何も取得していない場合はプロンプトを表示しない
        prompt=""
    else
        # vcs_info で情報を取得した場合
        # $vcs_info_msg_0_ , $vcs_info_msg_1_ , $vcs_info_msg_2_ を
        # それぞれ緑、黄色、赤で表示する
        [[ -n "$vcs_info_msg_0_" ]] && messages+=( "%F{green}${vcs_info_msg_0_}%f" )
        [[ -n "$vcs_info_msg_1_" ]] && messages+=( "%F{yellow}${vcs_info_msg_1_}%f" )
        [[ -n "$vcs_info_msg_2_" ]] && messages+=( "%F{red}${vcs_info_msg_2_}%f" )

        # 間にスペースを入れて連結する
        prompt="${(j: :)messages}"
    fi

    RPROMPT="$prompt"
}
add-zsh-hook precmd _update_vcs_info_msg

setopt prompt_subst
function zle-line-init zle-keymap-select {
PROMPT="
%{${fg[yellow]}%}%h:%~%{${reset_color}%}
%(?.%{$fg[green]%}.%{$fg[cyan]%})(%(!.#.)%(?!-＿-) !;＿;%) )${${KEYMAP/vicmd/|}/(main|viins)/<}%{${reset_color}%} "
zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select
SPROMPT="%{$fg[cyan]%}%{$suggest%}(-＿-)?< %B%r%b %{$fg[cyan]%}でしょうか? [(y)es,(n)o,(a)bort,(e)dit]:${reset_color} "

function command_not_found_handler() {
    echo "$fg[cyan](;-＿-)< $0 というコマンドは見当たりませんが${reset_color}"
}

# }}}

## title bar# {{{
echo -ne "\033]0;${USER}@${HOST%%.*}\007"
# }}}
## keybind# {{{
bindkey -v
bindkey -r '^X'
export KEYTIMEOUT=1
autoload -Uz select-word-style
select-word-style default
zstyle ':zle:*' word-chars " /=;@:{},|"
zstyle ':zle:*' word-style
bindkey "^P" up-line-or-history

bindkey "^N" down-line-or-history
bindkey '^R' history-incremental-pattern-search-backward
bindkey '^S' history-incremental-pattern-search-forward
function chpwd() {
    ls_abbrev
}
function ls_abbrev() {
    if [[ ! -r $PWD ]]; then
        return
    fi
    # -a : Do not ignore entries starting with ..
    # -C : Force multi-column output.
    # -F : Append indicator (one of */=>@|) to entries.
    local cmd_ls='ls'
    local -a opt_ls
    opt_ls=('-aCF' '--color=always')
    case "${OSTYPE}" in
        freebsd*|darwin*)
            if type gls > /dev/null 2>&1; then
                cmd_ls='gls'
            else
                # -G : Enable colorized output.
                opt_ls=('-aCFG')
            fi
            ;;
    esac

    local ls_result
    ls_result=$(CLICOLOR_FORCE=1 COLUMNS=$COLUMNS command $cmd_ls ${opt_ls[@]} | sed $'/^\e\[[0-9;]*m$/d')

    local ls_lines=$(echo "$ls_result" | wc -l | tr -d ' ')

    if [ $ls_lines -gt 10 ]; then
        echo "$ls_result" | head -n 5
        echo '         ...'
        echo "$ls_result" | tail -n 5
        echo "$(command ls -1 -A | wc -l | tr -d ' ') files exist"
    else
        echo "$ls_result"
    fi
}
function do_enter() {
    if [ -n "$BUFFER" ]; then
        zle accept-line
        return 0
    fi
    echo
    ls_abbrev
    if [ "$(git rev-parse --is-inside-work-tree 2> /dev/null)" = 'true' ]; then
        echo
        echo -e "\e[0;33m--- git status ---\e[0m"
        git status -sb
    fi
    echo
    echo
    zle reset-prompt
    return 0
}
zle -N do_enter
bindkey '^m' do_enter
function separate(){
    echo -n $fg_bold[yellow]
    for i in $(seq 1 $COLUMNS); do
        echo -n '~'
    done
    echo -n $reset_color
}

# }}}
## action option# {{{
setopt auto_cd # ディレクトリ名だけでcd
setopt auto_pushd # cdの時にpushd
setopt pushd_ignore_dups # 同じディレクトリをpushしない
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history # 保存先
setopt share_history # コマンド履歴を共有
setopt hist_ignore_all_dups # 履歴重複削除
setopt hist_reduce_blanks # 空白履歴削除
setopt extended_glob # 拡張ワイルドカード表現
setopt ignore_eof # Ctrl-Dで終了しない
setopt correct # もしかして
autoload -U compinit; compinit
setopt list_packed # 補完表示を詰める
setopt auto_param_keys # カッコ補完
setopt auto_param_slash # ディレクトリ名の後ろのスラッシュを補完
setopt numeric_glob_sort # 数値順
setopt nolistbeep # beepを鳴らさない
setopt long_list_jobs # jobsの時にプロセスidも知る
setopt noflowcontrol # 画面更新停止(ctrl-S)させない

# alias
if builtin command -v trash.sh > /dev/null; then
	alias rm='trash.sh -i'
	export TRASHLIST=~/.trashlist # Where trash list is written
	export TRASHBOX=~/.Trash # Where trash will be moved in
	export MAXTRASHBOXSIZE=1024
	export MAXTRASHSIZE=`echo $MAXTRASHBOXSIZE "*" 0.1|bc -l|cut -d. -f1`
fi

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
alias vi='vim'
alias g='git'
alias tmux='tmux -2'
function take () { mkdir -p "$@" && eval cd "\"\$$#\"";}
autoload -Uz zmv

alias mmv='noglob zmv -W'

alias youdl="~/cw/python/youtube-dl/youtube_dl/__main__.py"
function addnicolist() {
    /bin/ruby ~/cw/ruby/getmylistids.rb $1 | tee -a ~/cw/db/Temp/nicofab.txt
}

### global alias
alias -g G='| grep'
alias -g L='| less -N'
alias -g H='| head'
alias -g T='| tail'
alias -g S='| sort'
alias -g U='| nkf -w'
alias -g W='| wc'
alias -g X='| xargs'
# }}}
## packages# {{{
# パッケージ管理システムを読み込む。
source ~/.zsh.d/package.zsh

### auto-fu
#package-install github hchbaw/auto-fu.zsh
#source $(package-directory hchbaw/auto-fu.zsh)/auto-fu.zsh
## auto-fuを初期化する。
#zle-line-init() {
#    auto-fu-init
#}
#zle -N zle-line-init
#zle -N zle-keymap-select auto-fu-zle-keymap-select
#
## auto-fuをカスタマイズする。
### Enterを押したときは自動補完された部分を利用しない。
#afu+cancel-and-accept-line() {
#    ((afu_in_p == 1)) && { afu_in_p=0; BUFFER="$buffer_cur" }
#    zle afu+accept-line
#}
#zle -N afu+cancel-and-accept-line
#bindkey -M afu "^M" afu+cancel-and-accept-line

### z
package-install github rupa/z
source $(package-directory rupa/z)/z.sh
precmd() {
    _z --add "$(pwd -P)"
}

### syntax-highlighting
package-install github zsh-users/zsh-syntax-highlighting
source $(package-directory zsh-users/zsh-syntax-highlighting)/zsh-syntax-highlighting.zsh

### history increment search
package-install github zsh-users/zaw
source $(package-directory zsh-users/zaw)/zaw.zsh
bindkey '^R' zaw-history

# }}}

## rbenv
if [ -d ${HOME}/.rbenv  ] ; then
  export PATH=$HOME/.rbenv/bin:$PATH
  eval "$(rbenv init - zsh)"
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

## general
export PATH="/home/vagrant/.bin/:$PATH"

