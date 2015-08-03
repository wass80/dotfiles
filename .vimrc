set nocompatible
filetype off
filetype plugin indent off
" core "{{{
"" NeoBundle "{{{ 
if has('vim_starting')
  set runtimepath+=~/.vim/bundle/neobundle.vim
endif
call neobundle#begin(expand('~/.vim/bundle/'))
NeoBundleFetch 'Shougo/neobundle.vim'
""}}}
"" ideone"{{{
NeoBundle "mattn/webapi-vim"
""}}}
"" vimproc "{{{
if !has('gui_running')
NeoBundle 'Shougo/vimproc', {
\ 'build' : {
\     'windows' : 'make -f make_mingw32.mak',
\     'cygwin' : 'make -f make_cygwin.mak',
\     'mac' : 'make -f make_mac.mak',
\     'unix' : 'make -f make_unix.mak',
\    },
\ }
end
""}}}
"" submode "{{{
NeoBundle "kana/vim-submode"
let g:submode_keep_leaving_key=1
let g:submode_always_show_submode=1
let g:submode_timeout=0
""}}}
"" vital "{{{
NeoBundle "vim-jp/vital.vim"
"...
""}}}
"}}}
" apperance "{{{
"" display number "{{{
set number
""}}}
"" colorscheme "{{{
NeoBundle "w0ng/vim-hybrid"
NeoBundle "chriskempson/vim-tomorrow-theme"

autocmd ColorScheme * highlight LineNr ctermfg=247 guifg=#909090
autocmd ColorScheme * highlight SpecialKey ctermfg=247 guifg=#606060
autocmd ColorScheme * highlight NonText ctermfg=247 guifg=#606060
" autocmd ColorScheme * highlight VertSplit ctermfg=246 ctermbg=239
set t_Co=256
syntax on
""}}}
"" character hilight "{{{
"set cursorline
set list
set listchars=tab:^\ ,trail:~,eol:_

set hlsearch
" turn off highlight on enter twice
nnoremap <silent><Esc><Esc> :<C-u>nohlsearch<CR>
nnoremap <silent><C-l><C-l> :<C-u>nohlsearch<CR>

" highlight parenttheses
let g:lisp_instring = 1
let g:lisp_rainbow = 1

function! ZenkakuSpace()
  highlight ZenkakuSpace cterm=underline ctermfg=darkgrey gui=underline guifg=darkgrey
endfunction

if has('syntax')
  augroup ZenkakuSpace
    autocmd!
    " ZenkakuSpaceをカラーファイルで設定するなら次の行は削除
    autocmd ColorScheme       * call ZenkakuSpace()
    " 全角スペースのハイライト指定
    autocmd VimEnter,WinEnter * match ZenkakuSpace /　/
    autocmd VimEnter,WinEnter * match ZenkakuSpace '\%u3000'
  augroup END
  call ZenkakuSpace()
endif
""}}}
"" indent highlight "{{{
NeoBundle 'nathanaelkane/vim-indent-guides' 
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_color_change_percent = 20
let g:indent_guides_exclude_filetypes = ['help', 'nerdtree', 'tagbar', 'unite']
""}}}
"" folding "{{{
NeoBundle 'LeafCage/foldCC'
set foldmethod=marker
set foldtext=FoldCCtext()
set foldcolumn=1
set fillchars=vert:\|
noremap zs za
"}}}
"" lightline "{{{
NeoBundle 'itchyny/lightline.vim'
set laststatus=2
set cmdheight=2
set showcmd
let g:lightline = {
\   'colorscheme': 'wombat',
\   'mode_map': {'c': 'NORMAL'},
\   'active': {
\     'left': [
\       ['mode', 'paste'],
\       ['fugitive', 'gitgutter', 'filename',],
\     ],
\     'right': [
\       ['lineinfo'],
\       ['filetype'],
\       ['charcode', 'fileformat', 'fileencoding'],
\     ]
\   },
\   'component_function': {
\     'modified': 'MyModified',
\     'readonly': 'MyReadonly',
\     'filename': 'MyFilename',
\     'fugitive': 'MyFugitive',
\     'lineinfo': 'MyLineinfo',
\     'fileformat': 'MyFileformat',
\     'filetype': 'MyFiletype',
\     'fileencoding': 'MyFileencoding',
\     'mode': 'MyMode',
\     'syntastic': 'SyntasticStatuslineFlag',
\     'charcode': 'MyCharCode',
\     'gitgutter': 'MyGitGutter',
\   },
\   'separator': {'left': '', 'right': ''},
\   'subseparator': {'left': '|', 'right': '|'}
\}

function! MyModified()
    return &ft =~ 'help\|vimfiler\|gundo' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction

function! MyReadonly()
    return &ft !~? 'help\|vimfiler\|gundo' && &ro ? 'RO' : ''
endfunction

function! MyFilename()
    return ('' != MyReadonly() ? MyReadonly() . ' ' : '') .
                \ (&ft == 'vimfiler' ? vimfiler#get_status_string() :
                \  &ft == 'unite' ? unite#get_status_string() :
                \  &ft == 'vimshell' ? substitute(b:vimshell.current_dir,expand('~'),'~','') :
                \ '' != expand('%:t') ? expand('%:t') : '[No Name]') .
                \ ('' != MyModified() ? ' ' . MyModified() : '')
endfunction

function! MyFugitive()
    try
        if &ft !~? 'vimfiler\|gundo' && exists('*fugitive#head')
            let _ = fugitive#head()
            return strlen(_) ? 'ﾄ'._ : ''
        endif
    catch
    endtry
    return ''
endfunction

function! MyLineinfo()
    return printf("%d/%d:%d", line("."), line('$'), col('.'))
endfunction

function! MyFileformat()
    return winwidth('.') > 70 ? &fileformat : ''
endfunction

function! MyFiletype()
    return winwidth('.') > 70 ? (strlen(&filetype) ? &filetype : 'no ft') : ''
endfunction

function! MyFileencoding()
    return winwidth('.') > 70 ? (strlen(&fenc) ? &fenc : &enc) : ''
endfunction

function! MyMode()
    return winwidth('.') > 60 ? lightline#mode() : ''
endfunction

function! MyGitGutter()
    if ! exists('*GitGutterGetHunkSummary')
                \ || ! get(g:, 'gitgutter_enabled', 0)
                \ || winwidth('.') <= 90
        return ''
    endif
    let symbols = [
                \ g:gitgutter_sign_added . '+',
                \ g:gitgutter_sign_modified . 'M',
                \ g:gitgutter_sign_removed . '-'
                \ ]
    let hunks = GitGutterGetHunkSummary()
    let ret = []
    for i in [0, 1, 2]
        if hunks[i] > 0
            call add(ret, symbols[i] . hunks[i])
        endif
    endfor
    return join(ret, ' ')
endfunction

function! MyCharCode()
    if winwidth('.') <= 70
        return ''
    endif

    " Get the output of :ascii
    redir => ascii
    silent! ascii
    redir END

    if match(ascii, 'NUL') != -1
        return 'NUL'
    endif

    " Zero pad hex values
    let nrformat = '0x%02x'

    let encoding = (&fenc == '' ? &enc : &fenc)

    if encoding == 'utf-8'
        " Zero pad with 4 zeroes in unicode files
        let nrformat = '0x%04x'
    endif

    " Get the character and the numeric value from the return value of :ascii 
    " This matches the two first pieces of the return value, e.g.
    " "<F> 70" => char: 'F', nr: '70'
    let [str, char, nr; rest] = matchlist(ascii, '\v\<(.{-1,})\>\s*([0-9]+)')

    " Format the numeric value
    let nr = printf(nrformat, nr)

    return "'". char ."' ". nr
endfunction
""}}}
"}}}
" exec "{{{
"" quickrun&fix "{{{
NeoBundle "thinca/vim-quickrun"
NeoBundle "osyo-manga/shabadou.vim"
NeoBundle "osyo-manga/unite-quickfix"
let g:quickrun_config = {
\   "_" : {
\       "runner" : "vimproc",
\       "runner/vimproc/updatetime" : 40,
\       "hook/quickfix_replate_tempname_to_bufnr/enable_exit" : 1,
\       "hook/quickfix_replate_tempname_to_bufnr/priority_exit" : -10,
\       "outputter/buffer/split" : ":botright 5sp",
\       "hook/turret/enable" : 1,
\       "hook/turret/wait" : 5,
\       "hook/turret/redraw" : 1,
\   },
\   "cpp" : {
\       "command": "g++",
\       "cmdopt": "-std=c++0x",
\   },
\}
nmap <Space>q <Plug>(quickrun)
nnoremap <expr><silent> <C-c> quickrun#is_running() ? quickrun#sweep_sessions() : "\<C-c>"
""}}}
"" syntax check "{{{
NeoBundle "osyo-manga/vim-watchdogs"
NeoBundle "jceb/vim-hier"
NeoBundle "dannyob/quickfixstatus"
NeoBundle "tomtom/quickfixsigns_vim"
let s:config = {
\    "watchdogs_checker/_" : {
\        "hook/close_quickfix/enable_exit" : 1,
\    },
\}
""}}}
"" wandbox "{{{
NeoBundle "rhysd/wandbox-vim"
""}}}
"" shell "{{{
NeoBundle "Shougo/vimshell"
""}}}
"" browser{{{
NeoBundle 'tyru/open-browser.vim'
""}}}
"}}}
" view "{{{
"" use ja help "{{{
set helplang=ja,en
""}}}
"" Unite "{{{
NeoBundle "Shougo/unite.vim"
NeoBundle 'kmnk/vim-unite-giti'
NeoBundle "ujihisa/unite-colorscheme"
NeoBundle "Shougo/neomru.vim"
NeoBundle "tsukkee/unite-help"
NeoBundle "Shougo/unite-outline"
NeoBundle "osyo-manga/unite-fold"
NeoBundle "yuku-t/vim-ref-ri"
let g:unite_enable_start_insert=1
let g:unite_enable_ignore_case = 1
let g:unite_enable_smart_case = 1
""buffer list
noremap <space>b :<C-u>Unite buffer<CR>
""file list
if executable("ag")
    nnoremap <space>f :<C-u>Unite file_rec/async:
    let g:unite_source_find_command = 'ag'
    let g:unite_source_rec_async_command =
                \ 'ag --follow --nocolor --nogroup --hidden -g ""'
    let g:unite_source_grep_command = 'ag'
    let g:unite_source_grep_default_opts = '--nogroup --nocolor'
    let g:unite_source_grep_recursive_opt = ''
else
    nnoremap <space>f :<C-u>Unite file_rec:
endif
nnoremap <space>d :<C-u>Unite directory_rec:
"" grep
nnoremap <space>e  :<C-u>Unite grep -buffer-name=search-buffer<CR>
""recently files list
noremap <space>z :<C-u>Unite file_mru<CR>
nnoremap <space>y :<C-u>Unite directory_rec:~<CR>
"" show outline
noremap <space>o :<C-u>Unite outline<CR>
"" shoe regster
noremap <space>r :<C-u>Unite register<CR>
"" unite source
noremap <space>u :<C-u>Unite source<CR>
"" gist
noremap <space>t :<C-u>Unite gista<CR>
"" mapping
noremap <space>\ :<C-u>Unite mapping<CR>
"" resume
noremap <space>0 :<C-u>UniteResume<CR>
""twice esc quit
au FileType unite nnoremap <silent> <buffer> <ESC><ESC> :q<CR>
au FileType unite inoremap <silent> <buffer> <ESC><ESC> <ESC>:q<CR>
""}}}
"" reference K:search" {{{
NeoBundle "thinca/vim-ref"
""}}}
"" tag "{{{
NeoBundle 'tsukkee/unite-tag'
nnoremap <silent> <C-]> :<C-u>Unite -immediately -no-start-insert tag:<C-r>=expand('<cword>')<CR><CR>
nnoremap <buffer> <C-t> :<C-u>Unite jump<CR>
if executable("ctags")
NeoBundle 'alpaca-tc/alpaca_tags'
let g:alpaca_tags#config = {
\   '_' : '-R --sort=yes --languages=+Ruby --languages=-js,JavaScript',
\   'js' : '--languages=+js',
\   '-js' : '--languages=-js,JavaScript',
\   'vim' : '--languages=+Vim,vim',
\   'php' : '--languages=+php',
\   '-vim' : '--languages=-Vim,vim',
\   '-style': '--languages=-css,scss,js,JavaScript,html',
\   'scss' : '--languages=+scss --languages=-css',
\   'css' : '--languages=+css',
\   'java' : '--languages=+java $JAVA_HOME/src',
\   'ruby': '--languages=+Ruby',
\   'coffee': '--languages=+coffee',
\   '-coffee': '--languages=-coffee',
\   'bundle': '--languages=+Ruby',
\   }
augroup AlpacaTags
    autocmd!
    if exists(':Tags')
        autocmd BufWritePost Gemfile TagsBundle
        autocmd BufEnter * TagsSet
        autocmd BufWritePost * TagsUpdate
    endif
augroup END
endif
""}}}
"}}}
" manager "{{{
"" backup directory "{{{
set directory=~/.vim/tmp
set backupdir=~/.vim/tmp
set viminfo+=n~/.vim/tmp/viminfo.txt
set undodir=~/.vim/tmp
""}}}
"" fugitive "{{{
NeoBundle "tpope/vim-fugitive"
noremap <space>g :Gstatus<CR>
""}}}
"" diff tool "{{{
NeoBundle 'lambdalisue/vim-unified-diff'
set diffexpr=unified_diff#diffexpr()
set diffopt=filler,vertical
"}}}
"" gist "{{{
NeoBundle "lambdalisue/vim-gista"
let g:gista#github_user = "wass80"
" let g:gista#update_on_write = 1
" let g:gista#gist_api_url = 'https://gist.github.com'
let g:gista#directory = expand('~/.gista/')
let g:gista#token_directory = g:gista#directory . 'tokens/' 
"" }}}
"" vimcoder"{{{
NeoBundle "vim-scripts/VimCoder.jar"
"}}}
"}}}
" completion "{{{
"" command completion "{{{
set wildmenu
set wildmode=longest:full,full
"}}}
"" neocomplcache "{{{
NeoBundle "Shougo/neocomplete"
NeoBundle "Shougo/neosnippet.vim"
NeoBundle "wass80/neosnippet-snippets"

let g:neosnippet#snippets_directory='~/.vim/bundle/neosnippet-snippets/neosnippets/'

let g:neocomplete#enable_at_startup = 1
let g:neocomplete#enable_smart_case = 1
let g:neocomplete#sources#syntax#min_keyword_length = 3
let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'

" Define keyword.
if !exists('g:neocomplete#keyword_patterns')
    let g:neocomplete#keyword_patterns = {}
endif
let g:neocomplete#keyword_patterns['default'] = '\h\w*'

inoremap <expr><C-g>     neocomplete#undo_completion()
inoremap <expr><C-l>     neocomplete#complete_common_string()

" <CR>: close popup and save indent.
inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
function! s:my_cr_function()
  return neocomplete#close_popup() . "\<CR>"
  " For no inserting <CR> key.
  "return pumvisible() ? neocomplete#close_popup() : "\<CR>"
endfunction
" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
" SuperTab like snippets behavior.
imap <expr><TAB> pumvisible() ? "\<C-n>"
\: neosnippet#expandable_or_jumpable() ?
\ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
smap <expr><TAB> neosnippet#jumpable() ?
\ "\<Plug>(neosnippet_jump)"
\: "\<TAB>"

" <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
inoremap <expr><C-y>  neocomplete#close_popup()
inoremap <expr><C-e>  neocomplete#cancel_popup()

" Plugin key-mappings.
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)

" For snippet_complete marker.
if has('conceal')
  set conceallevel=2 concealcursor=i
endif

" Enable omni completion.
augroup omni
    autocmd!
    autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
    autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
    autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
    autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
    autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
augroup END

" Enable heavy omni completion.
if !exists('g:neocomplete#sources#omni#input_patterns')
  let g:neocomplete#sources#omni#input_patterns = {}
endif
let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'
autocmd FileType ruby setlocal omnifunc=rubycomplete#Complete
if !exists('g:neocomplete#force_omni_input_patterns')
  let g:neocomplete#force_omni_input_patterns = {}
endif
let g:neocomplete#force_omni_input_patterns.ruby = '[^. *\t]\.\w*\|\h\w*::'
""}}}
"" rsense "{{{
NeoBundleLazy 'marcus/rsense', { 'autoload' : {
\ 'filetypes': 'ruby',
\ }}
NeoBundleLazy 'supermomonga/neocomplete-rsense.vim', { 'autoload' : {
\ 'filetypes': 'ruby',
\ }}
""}}}
"" completion "end" "{{{
NeoBundle 'taichouchou2/vim-endwise.git'
let g:endwise_no_mappings=1
""}}}
"}}}
" cursor & search "{{{
"" search setting "{{{
" change search in UpperCase
set ignorecase
set smartcase
"}}}
"" addtional pair % "{{{
if !exists('loaded_matchit')
  runtime macros/matchit.vim
endif
""}}}
"" easy cursor moving "{{{
NeoBundle 'Lokaltog/vim-easymotion'
let g:EasyMotion_keys = 'hjklasdfgyuiopqwertnmzxcvbHJKLASDFGYUIOPQWERTNMZXCVB'
let g:EasyMotion_grouping = 1
let g:EasyMotion_do_mapping = 0
let g:EasyMotion_smartcase = 1
let g:EasyMotion_skipfoldedline = 0
let g:EasyMotion_startofline=0
let g:EasyMotion_enter_jump_first = 1
if(has('migemo'))
    let g:EasyMotion_use_migemo = 1
endif
hi EasyMotionTarget ctermbg=none ctermfg=red
hi EasyMotionShade  ctermbg=none ctermfg=blue
map s <Plug>(easymotion-s2)
nmap <Space>/ <Plug>(easymotion-sn)
xmap <Space>/ <Plug>(easymotion-sn)
omap <Space>/ <Plug>(easymotion-tn)
let g:EasyMotion_startofline=0
map <Space>j <Plug>(easymotion-j)
map <Space>k <Plug>(easymotion-k)
map <Space>w <Plug>(easymotion-bd-wl)
map <Space>W <Plug>(easymotion-bd-el)
" continue f
NeoBundle 'rhysd/clever-f.vim'
let g:clever_f_use_migemo=1
let g:clever_f_chars_match_any_signs=1
""}}}
"" multple cursors "{{{
NeoBundle "terryma/vim-multiple-cursors"
"}}}
"}}}
" operation "{{{
"" basic "{{{
" warp japanese
set formatoptions+=mM
" deleat backspace word
set backspace=indent,eol,start
" visiable around cursor
set scrolloff=5
" c type indent
set cindent
" tab into space
set smarttab
set tabstop=4
set expandtab
set shiftwidth=4
" no using octed
set nrformats-=octal
" no comment at new line
augroup nocr
    autocmd!
    autocmd CursorMoved,CursorMoved * setlocal formatoptions-=ro
augroup END
" new line by enter
noremap <CR> a<CR><ESC>
" without shift
noremap <Space>h ^
noremap <Space>l $
noremap <Space>b %
" one char insert
nnoremap <space>i i_<ESC>r
" go normal mode with jj
inoremap jj <Esc>

" ignore Q
nnoremap Q gq
""}}}
"" textobj "{{{
NeoBundle 'kana/vim-operator-user.git'
NeoBundle 'emonkak/vim-operator-comment'
map co <Plug>(operator-comment)
map cO <Plug>(operator-uncomment)
NeoBundle 'kana/vim-operator-replace.git'
map R  <Plug>(operator-replace)
NeoBundle 'rhysd/vim-operator-surround'
noremap gh gd
map gy <Plug>(operator-surround-append)
map gd <Plug>(operator-surround-delete)
map gc <Plug>(operator-surround-replace)
NeoBundle 'thinca/vim-visualstar'
NeoBundle 'tyru/operator-star.vim'
map *  <Plug>(operator-*)
map g*  <Plug>(operator-g*)
map #  <Plug>(operator-#)
map g#  <Plug>(operator-g#)

NeoBundle 'kana/vim-textobj-user'
NeoBundle 'kana/vim-textobj-line'
" al / il
NeoBundle 'kana/vim-textobj-indent'
" ai / ii
NeoBundle 'kana/vim-textobj-function'
let g:textobj_function_no_default_key_mappings=1
omap iF <Plug>(textobj-function-i)
omap aF <Plug>(textobj-function-a)
vmap iF <Plug>(textobj-function-i)
vmap aF <Plug>(textobj-function-a)
NeoBundle 'thinca/vim-textobj-between'
" af* / if*
NeoBundle 'kana/vim-textobj-entire'
let g:textobj_entire_no_default_key_mappings=1
omap ao <Plug>(textobj-entire-a)
omap io <Plug>(textobj-entire-i)
vmap aE <Plug>(textobj-entire-a)
vmap iE <Plug>(textobj-entire-i)
NeoBundle 'osyo-manga/vim-textobj-multiblock'
omap ab <Plug>(textobj-multiblock-a)
omap ib <Plug>(textobj-multiblock-i)
vmap ab <Plug>(textobj-multiblock-a)
vmap ib <Plug>(textobj-multiblock-i)
NeoBundle 'kana/vim-textobj-fold'
" az / iz
NeoBundle 'rhysd/vim-textobj-ruby'
" ar / ir
NeoBundle 'rbonvall/vim-textobj-latex'
" a\, a$, aq, aQ, ae
NeoBundle 'sgur/vim-textobj-parameter'
"a, / i,
NeoBundle 'glts/vim-textobj-comment'
"ac / ic
NeoBundle 'kana/vim-textobj-syntax'
"ay / iy

""}}}
"" repeat plugin command "{{{
NeoBundle "tpope/vim-repeat"
""}}}
"" undo tree "{{{
NeoBundle "sjl/gundo.vim"
""}}}
"" packing x "{{{
NeoBundle 'kana/vim-submode'
"}}}
"" aline text "{{{
NeoBundle "junegunn/vim-easy-align"
" Start interactive EasyAlign in visual mode (e.g. vip<Enter>)
vmap <Enter> <Plug>(EasyAlign)
" Start interactive EasyAlign for a motion/text object (e.g. <Leader>aip)
nmap ga <Plug>(EasyAlign)
""}}}
"" move text in virtual mode "{{{
NeoBundle "t9md/vim-textmanip"
xmap <C-j> <Plug>(textmanip-move-down)
xmap <C-k> <Plug>(textmanip-move-up)
xmap <C-h> <Plug>(textmanip-move-left)
xmap <C-l> <Plug>(textmanip-move-right)
""}}}
"" interactive substitute "{{{
NeoBundle "osyo-manga/vim-over"
nnoremap <silent> <Space>s :OverCommandLine <CR>
vnoremap <silent> <Space>s :OverCommandLine '<,'>s/<CR>
""}}}
"" disable F1 "{{{
map <F1> <nop>
cmap <F1> <nop>
imap <F1> <nop>
vmap <F1> <nop>
"}}} 
"" continue visual "{{{
vnoremap > >gv
vnoremap < <gv
vnoremap <C-a> <C-a>gv
vnoremap <C-X> <C-X>gv
"}}} 
"}}} 
" window & tab "{{{
"" smooth scroll "{{{
NeoBundle "yonchu/accelerated-smooth-scroll"
"}}}
"" edit many buffer "{{{
set hidden
""}}}
"" window position "{{{
nnoremap <M-h> <C-w>h
nnoremap <M-j> <C-w>j
nnoremap <M-k> <C-w>k
nnoremap <M-l> <C-w>l
""}}}
"}}}
" language "{{{
"" cpp "{{{
NeoBundleLazy 'vim-jp/cpp-vim', {
\ 'autoload' : {'filetypes' : 'cpp'}}
""}}}
"" ruby "{{{

""}}}
"" slim "{{{
NeoBundleLazy 'slim-template/vim-slim',{
\ 'autoload' : {'filetypes' : 'slim' }}
augroup Slim
    autocmd!
    autocmd BufWinEnter,BufNewFile *.slim set filetype=slim
augroup END
""}}}
"" haskell "{{{
NeoBundleLazy 'kana/vim-filetype-haskell', { 'filetypes': ['haskell'] }
NeoBundleLazy 'eagletmt/ghcmod-vim', { 'filetypes': ['haskell'] }
NeoBundleLazy 'ujihisa/neco-ghc', { 'commands': ['GhcModType'] }
noremap <space>m :GhcModType<CR>
NeoBundleLazy 'ujihisa/ref-hoogle', { 'filetypes': ['haskell'] }
NeoBundleLazy 'ujihisa/unite-haskellimport', { 'filetypes': ['haskell'] }
""}}}
"" markdown "{{{
NeoBundle 'rcmdnk/vim-markdown',{
\ 'autoload' : {'filetypes' : 'markdown' }}
NeoBundleLazy 'joker1007/vim-markdown-quote-syntax',{
\ 'autoload' : {'filetypes' : 'markdown' }}
""}}}
"" html "{{{
NeoBundleLazy 'taichouchou2/html5.vim' ,{
\ 'autoload' : {'filetypes' : 'html'}}
NeoBundleLazy 'mattn/emmet-vim' ,{
\ 'autoload' : {'filetypes' : ['html','css']}}
""}}}
"" css "{{{
NeoBundleLazy 'hail2u/vim-css3-syntax' ,{
\ 'autoload' : {'filetypes' : 'css'}}
""}}}
"" coffeescript "{{{
NeoBundle 'kchmck/vim-coffee-script' ,{
\ 'autoload' : {'filetypes' : 'coffeescript' }}
""}}}
"" js "{{{
NeoBundle 'jelera/vim-javascript-syntax' ,{
\ 'autoload' : {'filetypes' : 'javascript' }}
NeoBundle 'jiangmiao/simple-javascript-indenter' ,{
\ 'autoload' : {'filetypes' : 'javascript' }}
NeoBundle 'mattn/jscomplete-vim' ,{
\ 'autoload' : {'filetypes' : 'javascript' }}
"}}}
"" json "{{{
NeoBundle 'vim-scripts/JSON.vim' ,{
\ 'autoload' : {'filetypes' : 'json' }}

au BufRead,BufNewFile *.json set filetype=json
""}}}
"}}}
call neobundle#end()
" after "{{{
"" vital
let s:V = vital#of('vital')
"" colorscheme
colorscheme Tomorrow-Night-Bright
"" shabadou
call quickrun#module#register(shabadou#make_quickrun_hook_anim(
\   "turret",
\   ['{:}-', '{:}--', '{:}---', '{:}----', '{:}-----', '{:}<the cake is a lie.'],
\   12,
\), 1)
"" watchdogs
call extend(g:quickrun_config, s:config)
unlet s:config
call watchdogs#setup(g:quickrun_config)
let g:watchdogs_check_BufWritePost_enable = 1
"" unite
""short cut directory
call unite#custom#substitute('files', '\$\w\+', '\=eval(submatch(0))', 200)
call unite#custom#substitute('files', '^@@', '\=fnamemodify(expand("#"), ":p:h")."/"', 2)
call unite#custom#substitute('files', '^@', '\=getcwd()."/*"', 1)
call unite#custom#substitute('files', '^;r', '\=$VIMRUNTIME."/"')
call unite#custom#substitute('files', '^\~', escape($HOME, '\'), -2)
call unite#custom#substitute('files', '\\\@<! ', '\\ ', -20)
call unite#custom#substitute('files', '\\ \@!', '/', -30)
""open new tab
call unite#custom_default_action('file', 'tabopen')
"" back and back "{{{
call submode#enter_with('undo/redo', 'n', '', 'g-', 'g-')
call submode#enter_with('undo/redo', 'n', '', 'g+', 'g+')
call submode#map('undo/redo', 'n', '', '-', 'g-')
call submode#map('undo/redo', 'n', '', '+', 'g+')
""}}}
"" packing x "{{{
function! s:my_x()
    undojoin
    normal! x
endfunction
nnoremap <silent> <Plug>(my-x) :<C-u>call <SID>my_x()<CR>
call submode#enter_with('my_x', 'n', '', 'x', 'x')
call submode#map('my_x', 'n', 'r', 'x', '<Plug>(my-x)')
"}}}
"" tab move "{{{
call submode#enter_with('changetab', 'n', '', 'gt', 'gt')
call submode#enter_with('changetab', 'n', '', 'gT', 'gT')
call submode#map('changetab', 'n', '', 't', 'gt')
call submode#map('changetab', 'n', '', 'T', 'gT')
let s:Math = s:V.import('Math')
function! s:SIDP()
	  return '<SNR>' . matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SIDP$') . '_'
  endfunction
  function! s:movetab(nr)
	    execute 'tabmove' s:Math.modulo(tabpagenr() + a:nr - 1, tabpagenr('$'))
    endfunction
    let s:movetab = ':<C-u>call ' . s:SIDP() . 'movetab(%d)<CR>'
    call submode#enter_with('movetab', 'n', '', '<Space>ct', printf(s:movetab, 1))
    call submode#enter_with('movetab', 'n', '', '<Space>cT', printf(s:movetab, -1))
    call submode#map('movetab', 'n', '', '<Space>t', printf(s:movetab, 1))
    call submode#map('movetab', 'n', '', '<Space>T', printf(s:movetab, -1))
    unlet s:movetab
""}}}
"" window size "{{{
call submode#enter_with('winsize', 'n', '', '<C-w>>', '<C-w>>')
call submode#enter_with('winsize', 'n', '', '<C-w><', '<C-w><')
call submode#enter_with('winsize', 'n', '', '<C-w>+', '<C-w>-')
call submode#enter_with('winsize', 'n', '', '<C-w>-', '<C-w>+')
call submode#map('winsize', 'n', '', '>', '<C-w>>')
call submode#map('winsize', 'n', '', '<', '<C-w><')
call submode#map('winsize', 'n', '', '+', '<C-w>-')
call submode#map('winsize', 'n', '', '-', '<C-w>+')
""}}}
"}}}
NeoBundleCheck
filetype plugin indent on

