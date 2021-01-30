echomsg "loading init.vim"
set nohlsearch
set cursorline
set number
set showcmd
set showmatch
set matchtime=1
let loaded_matchparen = 1
set matchpairs& matchpairs+=<:>
set helplang=ja,en
set laststatus=2 " ステータスラインを常に表示
set statusline=%F%r%h%= " ステータスラインの内容
set incsearch
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
" set fileencodings=iso-2022-jp,euc-jp,sjis,utf-8
set autochdir
set hidden
set completeopt-=preview
let g:tex_flavor = "latex"
let g:tex_conceal = ''

"shortcut keys
"
let mapleader = "\<Space>"
"nmap s [window]
"nnoremap <silent>[window]s :split<Enter>
"nnoremap <silent>[window]v :vsplit<Enter>
"nnoremap <silent>[window]h <C-w>h
"nnoremap <silent>[window]j <C-w>j
"nnoremap <silent>[window]k <C-w>k
"nnoremap <silent>[window]l <C-w>l
"nnoremap <silent>[window]w <C-w>w
"nnoremap <silent>[window]m :resize<CR>
nnoremap <silent><leader>k :bnext<CR>
nnoremap <silent><leader>j :bprev<CR>
nnoremap <silent><leader>m :make
nnoremap <silent><leader>w :w!<CR>
nnoremap <silent><leader>n :<C-u>setlocal relativenumber!<CR>
" nnoremap <leader>
" nnoremap <leader>
" nnoremap <leader>
" nnoremap <leader>
" tnoremap <silent><C-j> <C-\><C-n>
tnoremap <silent><C-[> <C-\><C-n>
nnoremap <silent>j gj
nnoremap <silent>k gk
nnoremap gj j
nnoremap gk k
noremap ZZ <Nop>
noremap ZQ <Nop>
noremap q <Nop>
inoremap <UP> <Nop>
inoremap <DOWN> <Nop>
inoremap <RIGHT> <Nop>
inoremap <LEFT> <Nop>
inoremap <S-UP> <Nop>
inoremap <S-DOWN> <Nop>
inoremap <S-RIGHT> <Nop>
inoremap <S-LEFT> <Nop>
noremap Q q
noremap <C-space> <Nop>
" inoremap <silent>jj <ESC>
inoremap <expr><tab> pumvisible() ? "\<C-n>" : "\<tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<UP>" : "\<S-Tab>"
" vnoremap <silent><C-j> <ESC>
" inoremap <silent><C-j> <ESC>



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

lua <<EOF
require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
    disable = {
      'lua',
      'ruby',
      'toml',
      'c_sharp',
      'vue',
    }
  },
  ensure_installed = 'all',
}
EOF



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
        if &filetype == 'neoterm' || &filetype == 'terminal'
            :bn
        else
            :bd
        endif
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


fu Tapi_lcd(buf, cwd) abort
    if has('nvim')
        exe 'lcd '..a:cwd
        return ''
    endif
    let winid = bufwinid(a:buf)
    if winid == -1 || empty(a:cwd)
        return
    endif
    call win_execute(winid, 'lcd '..a:cwd)
endfu


" japanese insert mode
nnoremap <F6> :call JapaneseInserfOn()<CR>
nnoremap <F7> :call JapaneseInsertOff()<CR>
nnoremap <C-]> :call ToggleJapaneseMode()<CR>
inoremap <C-]> <C-o>:call ToggleJapaneseMode()<CR>
tnoremap <C-]> <C-\><C-n>:call ToggleJapaneseMode()<CR>i

let s:japanese_mode = 0
function! JapaneseInsertOff() abort
    if s:japanese_mode == 1
        call system("ibus engine 'xkb:jp::jpn'")
    endif
endfunction

function! JapaneseInserfOn() abort
    if s:japanese_mode == 1
        call system("ibus engine 'mozc-jp'")
    endif
endfunction

function! ToggleJapaneseMode() abort
    let s:japanese_mode = s:japanese_mode? 0 : 1
    let s:japanese_mode_str = s:japanese_mode? 'ON' : 'OFF'
    if s:japanese_mode == 0
        call system("ibus engine 'xkb:jp::jpn'")
    endif
    echo "Japanese mode: " . s:japanese_mode_str
endfunction

autocmd InsertLeave * call JapaneseInsertOff()
autocmd InsertEnter * call JapaneseInserfOn()


echomsg "end init.vim"
