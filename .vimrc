set nocompatible
filetype off
filetype plugin indent off
" core "{{{
"" NeoBundle "{{{ 
if has('vim_starting')
  set runtimepath+=~/.vim/bundle/neobundle.vim
  call neobundle#begin(expand('~/.vim/bundle/'))
  NeoBundleFetch 'Shougo/neobundle.vim'
  call neobundle#end()
endif
""}}}
"" ideone"{{{
NeoBundle "mattn/webapi-vim"
""}}}
"" vimproc "{{{
NeoBundle 'Shougo/vimproc', {
\ 'build' : {
\     'windows' : 'make -f make_mingw32.mak',
\     'cygwin' : 'make -f make_cygwin.mak',
\     'mac' : 'make -f make_mac.mak',
\     'unix' : 'make -f make_unix.mak',
\    },
\ }
""}}}
"" submode "{{{
NeoBundle "kana/vim-submode"
let g:submode_keep_leaving_key=1
let g:submode_always_show_submode=1
let g:submode_timeout=0
""}}}
"" vital "{{{
NeoBundle "vim-jp/vital.vim"
let s:V = vital#of('vital')
""}}}
"}}}
" apperance "{{{
"" display number "{{{
set number
""}}}
"" colorscheme "{{{
NeoBundle "w0ng/vim-hybrid"
set t_Co=256
syntax on
colorscheme hybrid
""}}}
"" character hilight "{{{
function! ZenkakuSpace()
highlight ZenkakuSpace cterm=underline ctermfg=darkgrey gui=underline guifg=darkgrey
endfunction

set cursorline
set list
set listchars=tab:^\ ,trail:~

set hlsearch
" turn off highlight on enter twice
nnoremap <silent><Esc><Esc> :<C-u>nohlsearch<CR>
nnoremap <silent><C-l><C-l> :<C-u>nohlsearch<CR>

let lisp_rainbow=1

" multi word gap when cursor
set ambiwidth=double
if has('syntax')
    augroup ZenkakuSpace
        autocmd!
        autocmd VimEnter,WinEnter * match ZenkakuSpace /　/
    augroup END
    call ZenkakuSpace()
endif
""}}}
"" indent hilight "{{{
NeoBundle 'nathanaelkane/vim-indent-guides' 
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_start_level = 2
let g:indent_guides_guide_size = 1
let g:indent_guides_auto_colors=0
autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd   ctermbg=239
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven  ctermbg=237
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
call quickrun#module#register(shabadou#make_quickrun_hook_anim(
\   "turret",
\   ['{:}-', '{:}--', '{:}---', '{:}----', '{:}-----', '{:}<cake is a lie.'],
\   12,
\), 1)
let g:quickrun_config = {
\   "_" : {
\       "runner" : "vimproc",
\       "runner/vimproc/updatetime" : 40,
\       "hook/quickfix_replate_tempname_to_bufnr/enable_exit" : 1,
\       "hook/quickfix_replate_tempname_to_bufnr/priority_exit" : -10,
\       "outputter/buffer/split" : ":botright 8sp",
\       "hook/turret/enable" : 1,
\       "hook/turret/wait" : 5,
\       "hook/turret/redraw" : 1,
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
call extend(g:quickrun_config, s:config)
unlet s:config
call watchdogs#setup(g:quickrun_config)
let g:watchdogs_check_BufWritePost_enable = 1
""}}}
"" wandbox "{{{
NeoBundle "rhysd/wandbox-vim"
""}}}
"" shell "{{{
NeoBundle "Shougo/vimshell"
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
let g:unite_enable_start_insert=1
""buffer list
noremap <space>b :Unite buffer<CR>
""file list
noremap <space>f :Unite -buffer-name=file file<CR>
""recently files list
noremap <space>z :Unite file_mru<CR>
"" show outline
noremap <space>o :Unite outline<CR>
"" shoe regster
noremap <space>r :Unite register<CR>
"" unite source
noremap <space>u :Unite source<CR>
"" gist
noremap <space>t :Unite gista<CR>
"" mapping
noremap <space>\ :Unite mapping<CR>
""twice esc quit
au FileType unite nnoremap <silent> <buffer> <ESC><ESC> :q<CR>
au FileType unite inoremap <silent> <buffer> <ESC><ESC> <ESC>:q<CR>
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
""}}}
"" reference K:search" {{{
NeoBundle "thinca/vim-ref"
""}}}
"}}}
" manager "{{{
"" backup directory "{{{
set directory=~/.vim/tmp
set backupdir=~/.vim/tmp
set viminfo+=n~/.vim/tmp/viminfo.txt
""}}}
"" fugitive "{{{
NeoBundle 'tpope/vim-fugitive'
noremap <space>g :Gstatus<CR>
""}}}
"" gist "{{{
NeoBundle "lambdalisue/vim-gista"
let g:gista#github_user = "wass80"
"" }}}
"}}}
" completion "{{{
"" ommand completion "{{{
set wildmenu
set wildmode=longest:full,full
"}}}
"" neocomplcache "{{{
NeoBundle "Shougo/neocomplete"
NeoBundle "Shougo/neosnippet.vim"
NeoBundle "Shougo/neosnippet-snippets"
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
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" Enable heavy omni completion.
if !exists('g:neocomplete#sources#omni#input_patterns')
  let g:neocomplete#sources#omni#input_patterns = {}
endif
let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'
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
"" search word on cursor "{{{
NeoBundle "thinca/vim-visualstar" 
map * <Plug>(visualstar-*)N
map # <Plug>(visualstar-#)N
""}}}
"" easy cursor moving "{{{
NeoBundle 'Lokaltog/vim-easymotion'
let g:EasyMotion_keys = 'hjklasdfgyuiopqwertnmzxcvbHJKLASDFGYUIOPQWERTNMZXCVB'
let g:EasyMotion_grouping = 1
let g:EasyMotion_do_mapping = 0
let g:EasyMotion_smartcase = 1
let g:EasyMotion_skipfoldedline = 0
" need +migemo
" let g:EasyMotion_use_migemo = 1

hi EasyMotionTarget ctermbg=none ctermfg=red
hi EasyMotionShade  ctermbg=none ctermfg=blue
" s all search
map s <Plug>(easymotion-s2)
" search label
nmap / <Plug>(easymotion-sn)
xmap / <Plug>(easymotion-sn)
omap / <Plug>(easymotion-tn)
nnoremap g/ /
xnoremap g/ /
onoremap g/ /
" continue f
NeoBundle 'rhysd/clever-f.vim'
"let g:clever_f_use_migemo=1
let g:clever_f_chars_match_any_signs=1
""}}}
"" multple cursors "{{{
NeoBundle "terryma/vim-multiple-cursors"
"}}}
"}}}
" operation "{{{
"" basic "{{{
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
autocmd! CursorMoved,CursorMoved * setlocal formatoptions-=ro
" new line by enter
noremap <CR> a<CR><ESC>
" without shift
noremap <Space>h ^
noremap <Space>l $
noremap <Space>j 10j
noremap <Space>k 10k
nnoremap <Space>/ *
noremap <Space>b %
" one char insert
nnoremap <space>i i_<ESC>r
" go normal mode with jj
inoremap jj <Esc>

" ignore Q
nnoremap Q gq
""}}}
"" srround and textobj "{{{
NeoBundle "tpope/vim-surround"
NeoBundle 'kana/vim-operator-user.git'
NeoBundle 'kana/vim-operator-replace.git'
map R  <Plug>(operator-replace)
NeoBundle 'kana/vim-textobj-user'
NeoBundle 'kana/vim-textobj-line'
NeoBundle 'kana/vim-textobj-indent'
NeoBundle 'kana/vim-textobj-function'
NeoBundle 'thinca/vim-textobj-between'
NeoBundle 'osyo-manga/vim-textobj-multiblock'
omap ab <Plug>(textobj-multiblock-a)
omap ib <Plug>(textobj-multiblock-i)
vmap ab <Plug>(textobj-multiblock-a)
vmap ib <Plug>(textobj-multiblock-i)
""}}}
"" repeat plugin command "{{{
NeoBundle "tpope/vim-repeat"
""}}}
"" undo tree "{{{
NeoBundle "sjl/gundo.vim"
""}}}
"" back and back "{{{
call submode#enter_with('undo/redo', 'n', '', 'g-', 'g-')
call submode#enter_with('undo/redo', 'n', '', 'g+', 'g+')
call submode#map('undo/redo', 'n', '', '-', 'g-')
call submode#map('undo/redo', 'n', '', '+', 'g+')
""}}}
"" packing x "{{{
NeoBundle 'kana/vim-submode'
function! s:my_x()
    undojoin
    normal! x
endfunction
nnoremap <silent> <Plug>(my-x) :<C-u>call <SID>my_x()<CR>
call submode#enter_with('my_x', 'n', '', 'x', 'x')
call submode#map('my_x', 'n', 'r', 'x', '<Plug>(my-x)')
"}}}
"" register ring "{{{
NeoBundle "LeafCage/yankround.vim"
nmap p <Plug>(yankround-p)
xmap p <Plug>(yankround-p)
nmap P <Plug>(yankround-P)
nmap <space>p <Plug>(yankround-prev)
nmap <space>p <Plug>(yankround-next)
let g:yankround_dir = '~/.vim/tmp/yankround'
"}}}
"" aline text "{{{
NeoBundle "junegunn/vim-easy-align"
""}}}
"" move text in virtual mode "{{{
NeoBundle "t9md/vim-textmanip"
xmap <C-j> <Plug>(textmanip-move-down)
xmap <C-k> <Plug>(textmanip-move-up)
xmap <C-h> <Plug>(textmanip-move-left)
xmap <C-l> <Plug>(textmanip-move-right)
""}}}"" interactive substitute "{{{
NeoBundle "osyo-manga/vim-over"
nnoremap <silent> <Space>s :OverCommandLine<CR>
""}}}
"}}} 
" window & tab "{{{
"" basic "{{{
" edit many buffer
set hidden
"}}}
"" tab move "{{{
let s:Math = s:V.import('Math')
function! s:SIDP()
	  return '<SNR>' . matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SIDP$') . '_'
  endfunction
  function! s:movetab(nr)
	    execute 'tabmove' s:Math.modulo(tabpagenr() + a:nr - 1, tabpagenr('$'))
    endfunction
    let s:movetab = ':<C-u>call ' . s:SIDP() . 'movetab(%d)<CR>'
    call submode#enter_with('movetab', 'n', '', 'gt', printf(s:movetab, 1))
    call submode#enter_with('movetab', 'n', '', 'gT', printf(s:movetab, -1))
    call submode#map('movetab', 'n', '', 't', printf(s:movetab, 1))
    call submode#map('movetab', 'n', '', 'T', printf(s:movetab, -1))
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
"" window position "{{{
nnoremap <M-h> <C-w>h
nnoremap <M-j> <C-w>j
nnoremap <M-k> <C-w>k
nnoremap <M-l> <C-w>l
""}}}
"}}}
" language "{{{
"" ruby "{{{

""}}}
"" slim "{{{
NeoBundle 'slim-template/vim-slim',{
\ 'autoload' : {'filetypes' : 'slim' }}
augroup Slim
    autocmd!
    autocmd BufWinEnter,BufNewFile *.slim set filetype=slim
augroup END
""}}}
"" haskell "{{{

""}}}
"" markdown "{{{
NeoBundle 'rcmdnk/vim-markdown',{
\ 'autoload' : {'filetypes' : 'markdown' }}
NeoBundle 'joker1007/vim-markdown-quote-syntax',{
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
""}}}kk
"" coffeescript "{{{
NeoBundle 'kchmck/vim-coffee-script' ,{
\ 'autoload' : {'filetypes' : 'coffeescript' }}
""}}}
"" js "{{{
NeoBundle 'taichouchou2/vim-javascript' ,{
\ 'autoload' : {'filetypes' : 'javascript' }}
"}}}
"" json "{{{
NeoBundle 'vim-scripts/JSON.vim' ,{
\ 'autoload' : {'filetypes' : 'json' }}

au BufRead,BufNewFile *.json set filetype=json
""}}}
filetype plugin indent on

