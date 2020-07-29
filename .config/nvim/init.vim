echo "loading init.vim"
" 検索キーワードをハイライトしないように設定
set nohlsearch
" カーソルラインの強調表示を有効化
set cursorline
" 行番号を表示
set number
"入力中のコマンドをステータスに表示
set showcmd
" カッコ
set showmatch
set matchtime=1
let loaded_matchparen = 1
set matchpairs& matchpairs+=<:>
set helplang=ja,en
" ステータスラインを表示
set laststatus=2 " ステータスラインを常に表示
set statusline=%F%r%h%= " ステータスラインの内容

" インクリメンタル検索を有効化
set incsearch

" 補完時の一覧表示機能有効化
set wildmenu wildmode=list:full
set ignorecase
set tabstop=4
set expandtab
set showtabline=2
set shiftwidth=4
set autoindent
set smartindent
set smartcase
set list  " 空白文字の可視化
set listchars=tab:>-,trail:-,eol:?,extends:>,precedes:<,nbsp:% " 空白文字の表示形式
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
set completeopt-=popup

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
nnoremap <silent><leader>m :make
nnoremap <silent><leader>w :w<CR>
nnoremap <silent><leader>n :<C-u>setlocal relativenumber!<CR>
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
inoremap <silent>jj <ESC>
inoremap <silent>っｊ <ESC>
inoremap <expr> <Tab> pumvisible() ? "\<DOWN>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<UP>" : "\<S-Tab>"

" text objects mapping
onoremap 8 i(
onoremap 2 i"
onoremap 7 i'
onoremap @ i`
onoremap [ i[
onoremap { i{

onoremap a8 a(
onoremap a2 a"
onoremap a7 a'
onoremap a@ a`
onoremap a[ a[
onoremap a{ a{



" command!

augroup MyAutoCmd
  autocmd!
augroup END

" syntax
autocmd BufRead,BufNewFile *.launch set filetype=xml

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
" dein.vimが存在してなければgithubからclone
if &runtimepath !~# '/dein.vim'
	if !isdirectory(s:dein_repo_dir)
		execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
	endif
	execute 'set runtimepath+='.fnamemodify(s:dein_repo_dir, ':p')
endif

if dein#load_state(s:dein_dir)
	call dein#begin(s:dein_dir)
    call dein#load_toml(s:config_dir.'/dein.toml', {'lazy':0})
    call dein#load_toml(s:config_dir.'/dein_lazy.toml', {'lazy':1})
    call dein#remote_plugins()
	call dein#end()
	call dein#save_state()
endif

call dein#add('tomasr/molokai')
colorscheme molokai

filetype plugin indent on

if dein#check_install()
	call dein#install()
endif

syntax on





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
    if dein#check_install('neoterm')==0
        execute ":Tnew"
    else
        call termopen(&shell, {'on_exit': 'OnExit'})
        set filetype=terminal
    endif
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


au MyAutoCmd BufNewFile,BufRead *.toml call s:Syntax_range_dein()
function! s:Syntax_range_dein() abort
    let start = '^\s*hook_\%('.
                \'add\|source\|post_source\|post_update'.
                \'\)\s*=\s*%s'
    call SyntaxRange#Include(printf(start, "'''"), "'''", 'vim', '')
    call SyntaxRange#Include(printf(start, '"""'), '"""', 'vim', '')
endfunction






