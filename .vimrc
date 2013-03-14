set nocompatible
filetype off
filetype plugin indent off

""""NeoBundle
""""run ":NeoBundleInstall"
if has('vim_starting')
  set runtimepath+=~/.vim/neobundle.vim.git
  call neobundle#rc(expand('~/.vim/.bundle'))
endif

"colorscheme
"NeoBundle "tomasr/molokai"
"NeoBundle "altercation/vim-colors-solarized"
NeoBundle "fugalh/desert.vim"
NeoBundle "nanotech/jellybeans.vim"
NeoBundle "w0ng/vim-hybrid"

"powerline
NeoBundle "Lokaltog/vim-powerline"

"quickrun anything
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
    map <F5> <Plug>(quickrun)
NeoBundle "osyo-manga/shabadou.vim"
"RSpec
let g:quickrun_config['ruby.rspec'] = { 'command': 'rspec' }
augroup UjihisaRSpec
    autocmd!
    autocmd BufWinEnter,BufNewFile *_rspec.rb set filetype=ruby.rspec
    autocmd BufWinEnter,BufNewFile *_spec.rb set filetype=ruby.rspec
augroup END

"run at ideone
NeoBundle "mattn/webapi-vim"
NeoBundle "mattn/ideone-vim"
"undo tree
NeoBundle "sjl/gundo.vim"
"completion
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
    inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
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

"completion end
NeoBundle 'taichouchou2/vim-endwise.git'
    let g:endwise_no_mappings=1

"git
NeoBundle 'tpope/vim-fugitive'
"unite git
NeoBundle 'kmnk/vim-unite-giti'

"file buffer ...etc
NeoBundle "Shougo/unite.vim"
    ""insert mode start
    let g:unite_enable_start_insert=1
    ""buffer list
    noremap <C-P> :Unite buffer<CR>
    ""file list
    noremap <C-N> :Unite -buffer-name=file file<CR>
    ""recently files list
    noremap <C-Z> :Unite file_mru<CR>
    ""twice esc quit
    au FileType unite nnoremap <silent> <buffer> <ESC><ESC> :q<CR>
    au FileType unite inoremap <silent> <buffer> <ESC><ESC> <ESC>:q<CR>
    ""short cut directory
    call unite#set_substitute_pattern('file', '^\~', escape($HOME, '\'), -2)
    call unite#set_substitute_pattern('file', '\\\@<! ', '\\ ', -20)
    call unite#set_substitute_pattern('file', '\\ \@!', '/', -30)
    ""open new tab
    call unite#custom_default_action('file', 'tabopen')
NeoBundle "ujihisa/unite-colorscheme"
NeoBundle "osyo-manga/unite-quickfix"

"for unite
NeoBundle 'Shougo/vimproc', {
    \ 'build' : {
    \     'windows' : 'make -f make_mingw32.mak',
    \     'cygwin' : 'make -f make_cygwin.mak',
    \     'mac' : 'make -f make_mac.mak',
    \     'unix' : 'make -f make_unix.mak',
    \    },
    \ }
NeoBundle "Shougo/vimshell"
"file tree
NeoBundle "Shougo/vimfiler"
"reference
NeoBundle "thinca/vim-ref"
    "K search
"outline create
NeoBundle "h1mesuke/unite-outline"

""html
"quick coding html css
NeoBundleLazy "mattn/zencoding-vim" ,{
 \ 'autoload' : {'filetypes' : ['html','css']}}

""ruby
NeoBundleLazy 'Shougo/neocomplcache-rsense' ,{
 \ 'autoload' : {'filetypes' : 'ruby' }}
let g:rsenseHome = '/cygwin/lib/ruby/gems/1.9.1/gems/rsence-2.2.5'
NeoBundle 'vim-ruby/vim-ruby'
    :let ruby_space_errors = 1

""""action
"mouse enable
"if has('mouse')
"  set mouse=a
"endif
"clipboard shear
set clipboard+=unnamed
"deleat backspace word
set backspace=indent,eol,start
"multi word gap when cursor
set ambiwidth=double
"highlight search
set hlsearch
"c type indent
set cindent
"tab into space
set smarttab
set tabstop=4
set expandtab
set shiftwidth=4
"no comment at new line
autocmd! CursorMoved,CursorMoved * setlocal formatoptions-=ro
"change search in UpperCase
set ignorecase
set smartcase
"no using octed
set nrformats-=octal
"use ja help
set helplang=ja,en
"edit many buffer
set hidden
"backup directory
set directory=~/.tmp
set backupdir=~/.tmp
set viminfo+=n~/.tmp

""""display
"use desert
colorscheme hybrid
"lisp rainbow parents
let lisp_rainbow=1
"line number
set number
"slash of pass
set shellslash
"indent
set autoindent
"comand in statusline
set showcmd
"status line
set laststatus=2
set statusline=%<[%n]%m%r%h%w%{'['.(&fenc!=''?&fenc:&enc).':'.&ff.']'}%y\ 
if winwidth(0)>=130
  set statusline+=%F
else
  set statusline+=%t
endif
set statusline+=%=\ \ %1l/%L,%c%V\ \ %p
"""last space visiable
set list
set listchars=tab:^\ ,trail:~
"syntax
syntax on

""デフォルトのZenkakuSpaceを定義
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

""""keymap
"new line by enter
noremap <CR> O<ESC>

"filetype
filetype plugin indent on

