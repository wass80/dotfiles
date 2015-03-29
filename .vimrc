set nocompatible
filetype off
filetype plugin indent off
" core "{{{
"" NeoBundle "{{{ 
if has('vim_starting')
  set runtimepath+=~/.vim/bundle/neobundle.vim
  call neobundle#rc(expand('~/.vim/bundle'))
endif
NeoBundleFetch "Shougo/neobundle.vim"
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
"}}}
" apperance "{{{
"" basic "{{{
set t_Co=256
set number
set cursorline
set list
set listchars=tab:^\ ,trail:~
"}}}
"" colorscheme  "{{{
NeoBundle "w0ng/vim-hybrid"
syntax on
colorscheme hybrid
function! ZenkakuSpace()
highlight ZenkakuSpace cterm=underline ctermfg=darkgrey gui=underline guifg=darkgrey
endfunction

if has('syntax')
    augroup ZenkakuSpace
        autocmd!
        autocmd VimEnter,WinEnter * match ZenkakuSpace /　/
    augroup END
    call ZenkakuSpace()
endif
""}}}
"" lightline  "{{{
NeoBundle 'itchyny/lightline.vim'
set laststatus=2
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
"}}}
" view "{{{
"" Unite "{{{
""}}}
"}}}
" completion "{{{
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
" <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
inoremap <expr><C-y>  neocomplete#close_popup()
inoremap <expr><C-e>  neocomplete#cancel_popup()

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
"}}}
" operation "{{{
"" undo tree "{{{
NeoBundle "sjl/gundo.vim"
""}}}
"}}}
filetype plugin indent on
