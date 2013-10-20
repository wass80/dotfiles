set nocompatible
filetype off
filetype plugin indent off

"""" NeoBundle"{{{
" run ":NeoBundleInstall"
if has('vim_starting')
  set runtimepath+=~/.vim/neobundle.vim.git
  call neobundle#rc(expand('~/.vim/.bundle'))
endif
"}}}
""" colorscheme"{{{
NeoBundle "tomasr/molokai"
" NeoBundle "altercation/vim-colors-solarized"
NeoBundle "fugalh/desert.vim"
NeoBundle "nanotech/jellybeans.vim"
NeoBundle "w0ng/vim-hybrid"
colorscheme hybrid
"}}}
""" lightline"{{{
NeoBundle 'itchyny/lightline.vim'
let g:lightline = {
            \ 'colorscheme': 'wombat',
            \ 'mode_map': {'c': 'NORMAL'},
            \ 'active': {
            \   'left': [
            \     ['mode', 'paste'],
            \     ['fugitive', 'gitgutter', 'filename'],
            \   ],
            \   'right': [
            \     ['lineinfo', 'syntastic'],
            \     ['percent'],
            \     ['charcode', 'fileformat', 'fileencoding', 'filetype'],
            \   ]
            \ },
            \ 'component_function': {
            \   'modified': 'MyModified',
            \   'readonly': 'MyReadonly',
            \   'fugitive': 'MyFugitive',
            \   'filename': 'MyFilename',
            \   'fileformat': 'MyFileformat',
            \   'filetype': 'MyFiletype',
            \   'fileencoding': 'MyFileencoding',
            \   'mode': 'MyMode',
            \   'syntastic': 'SyntasticStatuslineFlag',
            \   'charcode': 'MyCharCode',
            \   'gitgutter': 'MyGitGutter',
            \ },
            \ 'separator': {'left': '⮀', 'right': '⮂'},
            \ 'subseparator': {'left': '⮁', 'right': '⮃'}
            \ }

function! MyModified()
    return &ft =~ 'help\|vimfiler\|gundo' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction

function! MyReadonly()
    return &ft !~? 'help\|vimfiler\|gundo' && &ro ? '⭤' : ''
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
            return strlen(_) ? '⭠ '._ : ''
        endif
    catch
    endtry
    return ''
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
                \ g:gitgutter_sign_added . ' ',
                \ g:gitgutter_sign_modified . ' ',
                \ g:gitgutter_sign_removed . ' '
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

" https://github.com/Lokaltog/vim-powerline/blob/develop/autoload/Powerline/Functions.vim
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
"}}}
""" quickrun anything"{{{
NeoBundle "thinca/vim-quickrun"
    let g:quickrun_config = {}
    let g:quickrun_config._ = {
                \   "runner" : "vimproc",
                \   "runner/vimproc/updatetime" : 10,
                \   "hook/shabadoubi_touch_henshin/enable" : 1,
                \   "hook/shabadoubi_touch_henshin/wait" : 20,
                \   "hook/close_unite_quickfix/enable_hook_loaded" : 1,
                \   "hook/unite_quickfix/enable_failure" : 1,
                \   "hook/close_quickfix/enable_exit" : 1,
                \   "hook/close_buffer/enable_failure" : 1,
                \   "hook/close_buffer/enable_empty_data" : 1,
                \   "outputter" : "multi:buffer:quickfix",
                \   "outputter/buffer/split" : ":botright 8sp",
                \}
    nmap <F5> <Plug>(quickrun)
    imap <F5> <C-c> <Plug>(quickrun)
    nnoremap <expr><silent> <C-c> quickrun#is_running() ? quickrun#sweep_sessions() : "\<C-c>"
NeoBundle "osyo-manga/shabadou.vim"
"" RSpec
let g:quickrun_config['ruby.rspec'] = { 'command': 'rspec' }
augroup UjihisaRSpec
    autocmd!
    autocmd BufWinEnter,BufNewFile *_rspec.rb set filetype=ruby.rspec
    autocmd BufWinEnter,BufNewFile *_spec.rb set filetype=ruby.rspec
augroup END
"" Cpp
let g:quickrun_config['cpp'] = {
            \   'command' : 'g++',
            \       "cmdopt"    : " -std=gnu++0x",
            \       "exec" : ["%c %o %s -o %s:p:r", "%s:p:r"],
            \       "hook/boost_link/enable" : 0,
            \       "outputter/quickfix/errorformat" : '%f:%l:%c:\ %t%*[^:]:%m,%f:%m',
            \       "outputter/location_list/errorformat" : '%f:%l:%c:\ %t%*[^:]:%m,%f:%m'
            \}
"" CoffeeScript
let g:quickrun_config['javascript'] = {
            \   'command' : 'node',
            \   'exec' : ['node "`cygpath -w %s`"']
            \}
let g:quickrun_config['coffee'] = {
            \   'command' : 'coffee',
            \   'outputter/quickfix/errorformat ' : '%m',
            \   'hook/close_buffer/enable_failure' : 0,
            \   'exec' : ['%c "`cygpath -w %s`"']
            \}
"" Haskell
let g:quickrun_config['haskell'] = {
            \   'command' : 'runghc',
            \   'exec' : ['%c "`cygpath -w %s`"']
            \}
"" Java
let g:quickrun_config['java'] = {
            \   'command' : 'gcj',
            \   'exec' : ['%c --main=%s:t:r -o %s:p:r.exe %s','%s:p:r.exe']
            \}
"" markdown
let g:quickrun_config['markdown'] = {
            \   'command' : 'pandoc',
            \   'args': '--mathjax',
            \   'exec' : ['%c %o "`cygpath -w %s`"'],
            \   'outputter': 'browser',
            \}
"}}}
""" run at ideone"{{{
NeoBundle "mattn/webapi-vim"
NeoBundle "mattn/ideone-vim"
"}}}
""" undo tree"{{{
NeoBundle "sjl/gundo.vim"
"}}}
""" completion"{{{
NeoBundle "Shougo/neocomplcache"
NeoBundle "Shougo/neosnippet"
    " Use neocomplcache.
    let g:neocomplcache_enable_at_startup = 1
    " Use smartcase.
    let g:neocomplcache_enable_smart_case = 1
    " Use camel case completion.
    let g:neocomplcache_enable_camel_case_completion = 1
    " Use underbar completion.
    let g:neocomplcache_enable_underbar_completion = 1
    " Set minimum syntax keyword length.
    let g:neocomplcache_min_syntax_length = 3
    let g:neocomplcache_lock_buffer_name_pattern = '\*ku\*'
    " Zen coding
    let g:use_zen_complete_tag = 1
    " Plugin key-mappings.
    imap <C-k>     <Plug>(neocomplcache_snippets_expand)
    smap <C-k>     <Plug>(neocomplcache_snippets_expand)
    inoremap <expr><C-g>    neocomplcache#undo_completion()
    inoremap <expr><C-l>    neocomplcache#complete_common_string()
    " Recommended key-mappings.
    " <CR>: close popup and save indent.
    "inoremap <expr><CR> pumvisible() ? neocomplcache#close_popup() : "\<CR>"
    " <TAB>: completion.
    imap <expr><TAB> neosnippet#jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : pumvisible() ? "\<C-n>" : "\<TAB>"
    smap <expr><TAB> neosnippet#jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
    noremap <expr><S-TAB>  pumvisible() ? "\<C-p>" : "\<S-TAB>" 
    " For snippet_complete marker.
    if has('conceal') 
        set conceallevel=2 concealcursor=i
    endif
    " <C-h>, <BS>: close popup and delete backword char.
    " remap expr
    inoremap <expr><C-h> neocomplcache#smart_close_popup()."\<C-h>"
    inoremap <expr><BS> neocomplcache#smart_close_popup()."\<C-h>"
    inoremap <expr><C-y> neocomplcache#close_popup()
    inoremap <expr><C-e> neocomplcache#cancel_popup()
    " Enable omni completion.
    autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
    autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
    autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
    autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
NeoBundle 'honza/snipmate-snippets'
let g:neosnippet#snippets_directory='~/.vim/.bundle/snipmate-snippets/snippets,~/.vim/mysnippets'
NeoBundle 'Rip-Rip/clang_complete'
    let g:neocomplcache_force_overwrite_completefunc=1
    if !exists("g:neocomplcache_force_omni_patterns")
            let g:neocomplcache_force_omni_patterns = {}
    endif
    let g:neocomplcache_force_omni_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|::'
    let g:clang_user_options = '-std=c++11'
    let g:clang_complete_auto = 0
    let g:clang_auto_select = 0
"}}}
""" completion "end""{{{
NeoBundle 'taichouchou2/vim-endwise.git'
    let g:endwise_no_mappings=1
"}}}
""" use template"{{{
NeoBundle 'mattn/sonictemplate-vim'
"}}}
""" git"{{{
NeoBundle 'tpope/vim-fugitive'
noremap <space>g :Gstatus<CR>
""" git diff
NeoBundle "airblade/vim-gitgutter"
""" unite git
NeoBundle 'kmnk/vim-unite-giti'
"}}}
""" file buffer ...etc"{{{
NeoBundle "Shougo/unite.vim"
""insert mode start
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
NeoBundle "ujihisa/unite-colorscheme"
NeoBundle "osyo-manga/unite-quickfix"
"}}}
""" for unite"{{{
NeoBundle 'Shougo/vimproc', {
\ 'build' : {
\     'windows' : 'make -f make_mingw32.mak',
\     'cygwin' : 'make -f make_cygwin.mak',
\     'mac' : 'make -f make_mac.mak',
\     'unix' : 'make -f make_unix.mak',
\    },
\ }
"}}}
""" outline create"{{{
NeoBundle "Shougo/unite-outline"
"}}}
""" shell"{{{
NeoBundle "Shougo/vimshell"
"}}}
""" file tree"{{{
NeoBundle "Shougo/vimfiler"
"}}}
""" help search"{{{
NeoBundle "tsukkee/unite-help"
    " Execute help.
    nnoremap <C-h>  :<C-u>Unite -start-insert help<CR>
    " Execute help by cursor keyword.
    nnoremap <silent> g<C-h>  :<C-u>UniteWithCursorWord help<CR>"}}}
""" search word on cursor"{{{
NeoBundle "thinca/vim-visualstar"
map * <Plug>(visualstar-*)N
map # <Plug>(visualstar-#)N
"}}}
""" reference K:search"{{{
NeoBundle "thinca/vim-ref"
"}}}
""" folding text"{{{
NeoBundle 'LeafCage/foldCC'
"}}}
""" srround and textobj"{{{
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
"}}}
""" easy caret move to the char"{{{
NeoBundle "Lokaltog/vim-easymotion"
    let g:EasyMotion_keys = 'hjklasdfgyuiopqwertnmzxcvbHJKLASDFGYUIOPQWERTNMZXCVB'
    " use ;w ;h..
    let g:EasyMotion_leader_key = ";"
    let g:EasyMotion_grouping = 1
    hi EasyMotionTarget ctermbg=none ctermfg=red
    hi EasyMotionShade  ctermbg=none ctermfg=blue
    " continue f
NeoBundle 'rhysd/clever-f.vim'
"}}}
""" move text in virtual mode"{{{
NeoBundle "t9md/vim-textmanip"
xmap <C-j> <Plug>(textmanip-move-down)
xmap <C-k> <Plug>(textmanip-move-up)
xmap <C-h> <Plug>(textmanip-move-left)
xmap <C-l> <Plug>(textmanip-move-right)
"}}}
""" register ring"{{{
NeoBundle "vim-scripts/YankRing.vim"
"}}}
""" change the word to another word"{{{
NeoBundle "AndrewRadev/switch.vim"
nnoremap ! :Switch<CR>
"}}}
""" vim restart"{{{
NeoBundle "tyru/restart.vim"
"}}}
""" indent highlight"{{{
NeoBundle 'nathanaelkane/vim-indent-guides'
let g:indent_guides_auto_colors=0
autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  ctermbg=grey
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven ctermbg=darkgrey
let g:indent_guides_guide_size=1
let g:indent_guides_enable_on_vim_startup=0
au FileType coffee,ruby,javascript,python IndentGuidesEnable
nmap <silent><Leader>ig <Plug>IndentGuidesToggle
"}}}
""" html"{{{
"" quick coding html css
NeoBundleLazy 'mattn/zencoding-vim' ,{
\ 'autoload' : {'filetypes' : ['html','css']}}
"}}}
""" ruby"{{{
NeoBundleLazy 'Shougo/neocomplcache-rsense' ,{
\ 'autoload' : {'filetypes' : 'ruby' }}
let g:rsenseHome = '/cygwin/lib/ruby/gems/1.9.1/gems/rsence-2.2.5'
NeoBundle 'vim-ruby/vim-ruby'
:let ruby_space_errors = 1
"}}}
""" coffeescript"{{{
" syntax + auto compile
NeoBundle 'kchmck/vim-coffee-script' ,{
\ 'autoload' : {'filetypes' : 'coffeescript' }}

" auto compile when save
"autocmd BufWritePost *.coffee silent CoffeeMake! -cb | cwindow | redraw!
"}}}
""" json"{{{
NeoBundle 'vim-scripts/JSON.vim' ,{
\ 'autoload' : {'filetypes' : 'json' }}

au BufRead,BufNewFile *.json set filetype=json
"}}}
""" haskell"{{{
" syntax
NeoBundle 'dag/vim2hs' ,{
\ 'autoload' : {'filetypes' : 'haskell' }}
" completion
NeoBundle 'ujihisa/neco-ghc' ,{
\ 'autoload' : {'filetypes' : 'haskell' }}
" for unite
NeoBundle 'eagletmt/unite-haddock' ,{
\ 'autoload' : {'filetypes' : 'haskell' }}
" ghcmod
NeoBundle 'eagletmt/ghcmod-vim' ,{
\ 'autoload' : {'filetypes' : 'haskell' }}

" }}}
""" markdown"{{{
NeoBundle 'tyru/open-browser.vim'
"}}}
"""" action"{{{
" mouse enable
if has('mouse')
set mouse=a
endif
" clipboard shear
set clipboard+=unnamed
" deleat backspace word
set backspace=indent,eol,start
" multi word gap when cursor
set ambiwidth=double
" visiable around cursor
set scrolloff=5
" highlight search
set hlsearch
" c type indent
set cindent
" tab into space
set smarttab
set tabstop=4
set expandtab
set shiftwidth=4
" no comment at new line
autocmd! CursorMoved,CursorMoved * setlocal formatoptions-=ro
" change search in UpperCase
set ignorecase
set smartcase
" no using octed
set nrformats-=octal
" use ja help
set helplang=ja,en
" edit many buffer
set hidden
" backup directory
set directory=~/.tmp
set backupdir=~/.tmp
set viminfo+=n~/.tmp
" folding
set foldmethod=marker
set foldtext=foldCC#foldtext()
set foldcolumn=1
set fillchars=vert:\|
" tab page
" Anywhere SID.
function! s:SID_PREFIX()
    return matchstr(expand('<sfile>'), '<SNR>\d\+_\zeSID_PREFIX$')
endfunction

" set tabline.
function! s:my_tabline()  "{{{
    let s = ''
    for i in range(1, tabpagenr('$'))
        let bufnrs = tabpagebuflist(i)
        let bufnr = bufnrs[tabpagewinnr(i) - 1]  " first window, first appears
        let no = i  " display 0-origin tabpagenr.
        let mod = getbufvar(bufnr, '&modified') ? '!' : ' '
        let title = fnamemodify(bufname(bufnr), ':t')
        let s .= '%'.i.'T'
        let s .= '%#' . (i == tabpagenr() ? 'TabLineSel' : 'TabLine') . '#'
        let s .= no . '⮁' . title
        let s .= mod
        let s .= '%#TabLineFill# '
    endfor
    let s .= '%#TabLineFill#%T%=%#TabLine#'
    return s
endfunction "}}}
let &tabline = '%!'. s:SID_PREFIX() . 'my_tabline()'
set showtabline=2
" The prefix key.
nnoremap    [Tag]   <Nop>
nmap    , [Tag]
" Tab jump
for n in range(1, 9)
    execute 'nnoremap <silent> [Tag]'.n  ':<C-u>tabnext'.n.'<CR>'
endfor
map <silent> [Tag]c :tablast <bar> tabnew<CR>
map <silent> [Tag]x :tabclose<CR>
map <silent> [Tag]n :tabnext<CR>
map <silent> [Tag]p :tabprevious<CR>
map <silent> [Tag]s :Unite tab<CR>
"}}}
"""" display"{{{
" lisp rainbow parents
let lisp_rainbow=1
" line number
set number
" slash of pass
set shellslash
" indent
set autoindent
" comand in statusline
set showcmd
" status line
set laststatus=2
set statusline=%<[%n]%m%r%h%w%{'['.(&fenc!=''?&fenc:&enc).':'.&ff.']'}%y\ 
if winwidth(0)>=130
set statusline+=%F
else
set statusline+=%t
endif
set statusline+=%=\ \ %1l/%L,%c%V\ \ %p
" last space visiable
set list
set listchars=tab:^\ ,trail:~
" highlight cursor
set cursorline
" syntax
syntax on

"" デフォルトのZenkakuSpaceを定義
function! ZenkakuSpace()
highlight ZenkakuSpace cterm=underline ctermfg=darkgrey gui=underline guifg=darkgrey
endfunction

if has('syntax')
augroup ZenkakuSpace
autocmd!
" 全角スペースのハイライト指定
autocmd VimEnter,WinEnter * match ZenkakuSpace /　/

augroup END
call ZenkakuSpace()
endif
"}}}
"""" keymap"{{{
" new line by enter
noremap <CR> a<CR><ESC>
" easy type
noremap zs za
" turn off highlight on enter twice
nnoremap <silent><Esc><Esc> :<C-u>nohlsearch<CR>
nnoremap <silent><C-l><C-l> :<C-u>nohlsearch<CR>
" without shift
noremap <Space>h ^
noremap <Space>l $
nnoremap <Space>/ *
noremap <Space>p %
" one char insert
nnoremap <space>i i_<ESC>r
" copy clipboard
noremap <Space>y :w !cat > /dev/clipboard<CR><CR>
" ignore Q
nnoremap Q gq
"}}}
" filetype
filetype plugin indent on

