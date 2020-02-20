" highlight Normal ctermbg=black ctermfg=grey
" highlight StatusLine term=none cterm=none ctermfg=black ctermbg=black
" highlight CursorLine term=none cterm=none ctermfg=none ctermbg=darkgrey
" $B8!:w%-!<%o!<%I$r%O%$%i%$%H$7$J$$$h$&$K@_Dj(B
set nohlsearch
" $B%+!<%=%k%i%$%s$N6/D4I=<($rM-8z2=(B
set cursorline
" $B9THV9f$rI=<((B
set number
"$BF~NOCf$N%3%^%s%I$r%9%F!<%?%9$KI=<((B
set showcmd
" $B%+%C%3(B
set showmatch
set matchtime=1
let loaded_matchparen = 1
set matchpairs& matchpairs+=<:>
set helplang=ja,en
" $B%9%F!<%?%9%i%$%s$rI=<((B
set laststatus=2 " $B%9%F!<%?%9%i%$%s$r>o$KI=<((B
set statusline=%F%r%h%= " $B%9%F!<%?%9%i%$%s$NFbMF(B

" $B%$%s%/%j%a%s%?%k8!:w$rM-8z2=(B
set incsearch

" $BJd40;~$N0lMwI=<(5!G=M-8z2=(B
set wildmenu wildmode=list:full
set ignorecase
set tabstop=4
set expandtab
set showtabline=2
set shiftwidth=4
set autoindent
set smartindent
set smartcase
set list  " $B6uGrJ8;z$N2D;k2=(B
set listchars=tab:>-,trail:-,eol:?,extends:>,precedes:<,nbsp:% " $B6uGrJ8;z$NI=<(7A<0(B
set nrformats-=octal
set hidden
set history=50
set virtualedit=block
set t_Co=256
scriptencoding utf-8
set encoding=utf-8
set fileencodings=iso-2022-jp,euc-jp,sjis,utf-8
set autochdir
set hidden

"shortcut keys
"
let mapleader = "\<Space>"
nmap s [window]
nnoremap <silent>[window]s :split<Enter>
nnoremap <silent>[window]v :vsplit<Enter>
nnoremap <silent>[window]h <C-w>h
nnoremap <silent>[window]j <C-w>j
nnoremap <silent>[window]k <C-w>k
nnoremap <silent>[window]l <C-w>l
nnoremap <silent>[window]w <C-w>w
nnoremap <silent>[window]t :tabnew<Enter>
nnoremap <silent>[window]n gt
nnoremap <silent>[window]p g<S-t>
nnoremap <silent><leader>k :bnext<CR>
nnoremap <silent><leader>j :bprev<CR>
nnoremap <silent><leader>p :Denite buffer file/rec buffer<CR>
nnoremap <silent><leader>b :Denite buffer<CR>
nnoremap <silent><leader>h :Denite help<CR>
nnoremap <silent><leader>m :make
nnoremap <silent><leader>w :w<CR>
function! InitDefx()
    call dein#source('defx.vim')
    :Defx -listed -resume
endfunction
nnoremap <silent><leader>f :call InitDefx()<CR>
" nnoremap <leader>
" nnoremap <leader>
" nnoremap <leader>
" nnoremap <leader>
tnoremap jj <C-\><C-n>
nnoremap j gj
nnoremap k gk
nnoremap gj j
nnoremap gk k
noremap ZZ <Nop>
noremap ZQ <Nop>
noremap Q <Nop>
noremap <C-space> <Nop>
nnoremap <F3> :<C-u>setlocal relativenumber!<CR>
inoremap <silent>jj <ESC>
inoremap <silent>$B$C#j(B <ESC>
inoremap <expr> <Tab> pumvisible() ? "\<DOWN>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<UP>" : "\<S-Tab>"


" command!

augroup MyAutoCmd
  autocmd!
augroup END


" pulugins

" dein.vim
if &compatible
	set nocompatible
endif

if has("unix")
    let s:vim_home = expand('~/.cacheaaa')
elseif has("win32")
    let s:vim_home = expand('$HOME/vimfiles')
endif

let s:dein_dir =  s:vim_home . '/dein'
let s:config_dir =  expand('~/.config/nvim')
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'
" dein.vim$B$,B8:_$7$F$J$1$l$P(Bgithub$B$+$i(Bclone
if &runtimepath !~# '/dein.vim'
	if !isdirectory(s:dein_repo_dir)
		execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
	endif
	execute 'set runtimepath+='.fnamemodify(s:dein_repo_dir, ':p')
endif

if dein#load_state(s:dein_dir)
	call dein#begin(s:dein_dir)
    call dein#load_toml(s:config_dir.'/dein.toml', {'lazy':0})
"    call dein#load_toml(s:config_dir.'/dein_lazy.toml', {'lazy':0})

"    call dein#load_toml(s:toml_dir.'/general.toml', {'lazy':0})
"    call dein#load_toml(s:toml_dir.'/lightline.toml', {'lazy':0})
"    call dein#load_toml(s:toml_dir.'/denite.toml', {'lazy':0})
"    call dein#load_toml(s:toml_dir.'/defx.toml', {'lazy':0})
"    call dein#load_toml(s:toml_dir.'/deoplete.toml', {'lazy':0})
"    call dein#load_toml(s:toml_dir.'/neosnippet.toml', {'lazy':0})
"    call dein#load_toml(s:toml_dir.'/slimv.toml',{'lazy':0})
"    call dein#load_toml(s:toml_dir.'/im_control.toml',{'lazy':0})
"    call dein#load_toml(s:toml_dir.'/vim-markdown.toml',{'lazy':0})
"    call dein#load_toml(s:toml_dir.'/memo.toml',{'lazy':0})
"    call dein#load_toml(s:toml_dir.'/haskell.toml',{'lazy':0})
"    call dein#load_toml(s:toml_dir.'/quickrun.toml',{'lazy':0})
"    call dein#load_toml(s:toml_dir.'/deol.toml', {'lazy':0})
    call dein#remote_plugins()
	call dein#end()
	call dein#save_state()
endif

filetype plugin indent on

if dein#check_install()
	call dein#install()
endif

syntax on


" language server protocol
if executable('clangd')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'clangd',
        \ 'cmd': '{server_info->['clangd', '-background-index']},
        \ 'whitelist': ['c', 'cpp', 'objcpp'],
        \})
endif

" LSP C++
lua require'nvim_lsp'.clangd.setup{}

" Open terminal on new buffer

autocmd VimEnter * if @% == '' && s:GetBufByte() == 0 | call Term() |endif
function! s:GetBufByte()
    let byte = line2byte(line('$') + 1)
    if byte == -1
         return 0
    else
         return byte - 1
    endif
endfunction

function! Term()
    call termopen(&shell, {'on_exit': 'OnExit'})
    call deoplete#enable()
endfunction

function! CloseLastTerm()
    if len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) == 1
        :q
    endif
endfunction

function! OnExit(job_id, code, event)
    if a:code == 0
        call CloseLastTerm()
    endif
endfunction


function! CloseBuf()
    if len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) == 1
        :q
    else
        :bd
    endif
endfunction

nnoremap <silent> <leader>q :up!<CR>:call CloseBuf()<CR>

autocmd BufLeave * if exists('b:term_title') && exists('b:terminal_job_pid') | execute ":file term" . b:terminal_job_pid . "/" . b:term_title


" vimscriptsyntax in toml

au MyAutoCmd BufNewFile,BufRead *.toml call s:Syntax_range_dein()
function! s:Syntax_range_dein() abort
    let start = '^\s*hook_\%('.
                \'add\|source\|post_source\|post_update'.
                \'\)\s*=\s*%s'
    call SyntaxRange#Include(printf(start, "'''"), "'''", 'vim', '')
    call SyntaxRange#Include(printf(start, '"""'), '"""', 'vim', '')
endfunction



