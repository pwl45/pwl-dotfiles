let g:python3_host_prog = trim(system('which python3'))
let g:surround_no_mappings = v:true

set hlsearch
set inccommand=nosplit
set ignorecase
set smartcase
set scrolloff=10
set autoread
let g:polyglot_disabled = ['autoindent', 'sensible']
let g:rooter_patterns = ['.git', 'Makefile', '*.sln', 'build/env.sh', '=bazel-out']

" C-h is what the teriminal reads as shift backspace - I don't like that being used for nav marks
" replacing that with C-f or C-d
inoremap <silent><expr> <C-h>   pumvisible() ? "\<C-e><BS>"  : "\<BS>"

" Remaps
" use Q for (q)uestions
nnoremap Q K 

" Use j and k to jump visual lines, not actual lines. 
" use gj and gk to do what j and k normally do

nnoremap <C-g> :let @+ = expand('%')<CR><C-g>
nnoremap Z :let @+ = expand('%:p')<CR> C-g


nnoremap <leader>sl yy:<c-r>"<CR>

" Make big H,J,K,L more intuitive
" i think recursive is better here: cJ, for example, will change to the end of a paragraph. that's pretty nice. 
nnoremap Q K 
nnoremap J }
nnoremap K {
nnoremap H ^

" it is utterly disgusting that default vim makes you type shift-6/4 to go to the beginning/end of a line
nnoremap L $
vnoremap H ^
vnoremap L $
onoremap J }
onoremap K {

" center on searches
nnoremap n nzz
nnoremap N Nzz
inoremap <C-f> <Esc>n

" maybe not necessary, but "go to reference" is a solid mnemonic
nnoremap gr *

" make capital Y behave like capital C, capital D, etc.
nnoremap Y y$

"make big copies put you at the end of where you copied 
nnoremap yap yap}
vnoremap y ygv<esc>

"Don't want text I'm removing to be copied
nnoremap c "_c
nnoremap C "_C
vnoremap c "_c
vnoremap C "_C

"keep us in visual mode after in/unindenting text
vnoremap < <gv
vnoremap > >gv

" (S)ubstitute
nnoremap S :%s//g<Left><Left>
vnoremap S :s//g<Left><Left>

" (s)earch (w)hole word
nnoremap <leader>sw /\<\><Left><Left>

" Remaps for around/in next/last parentheses. Not very useful, but cool.
onoremap in( :<c-u>normal! f(vi(<cr>
onoremap in) :<c-u>normal! f(vi(<cr>
onoremap an( :<c-u>normal! f(va(<cr>
onoremap an) :<c-u>normal! f(va(<cr>
onoremap if :<c-u>normal!  ?\\begin{figure}<cr>V/\\end{figure}<cr>
" Remaps for around/in next/last $. Not very useful, but cool.
onoremap n$ :<c-u>normal! f$vf$<cr>
onoremap i$ :<c-u>normal! T$vt$<cr>
onoremap a$ :<c-u>normal! F$vf$<cr>


" onoremap i<space> iW
onoremap <space> W
onoremap i<space> iW
" onoremap <space> :<c-u>normal! vE<cr>


" QOL maps to make saving and quitting files easier
" (s)ave
:inoremap <C-Space> <esc>:update<cr>
:nnoremap <C-Space> :update<cr>
:vnoremap <C-Space> :<c-u>update<cr>
:nnoremap <C-CR> :update<CR>:Make!<CR>
:inoremap <C-CR> <esc>:update<CR>:Make!<CR>
:vnoremap <C-CR> :<c-u>update<CR>:Make!<CR>
:vnoremap <leader>ss :<c-u>update<cr>
:nnoremap <leader>ss :update<cr>
:nnoremap <leader>mm :update<cr>:!make<cr>
:nnoremap <leader>ma :Make! all<CR>
:vnoremap <leader>ss :<c-u>update<cr>
:nnoremap <leader>su :sort u <cr>
:vnoremap <leader>su :sort u <cr>

" (w)rite and (q)uit
:nnoremap <leader>wq :wq<cr>

" emulate C-a and C-e from emacs
inoremap <C-a> <C-o>^
inoremap <C-e> <C-o>$

" Remaps for changing until symbols
" (why do ct<sym> when you can just do c<sym>)
" TODO: Do more of these without removing existing vim functionality
" and maybe make it less repetitive. 
" :nnoremap c<space> cW
" :nnoremap d<space> dt<space>
:nnoremap c. ct.
:nnoremap d. dt.
:nnoremap c: ct:
:nnoremap d: dt:
:nnoremap c; ct;
:nnoremap d; dt;

" Uncategorized leader maps
" Spell-check: (o)rthography
nmap <leader>o :setlocal spell! spelllang=en_us<CR>
" (m)a(g)it shortcut:
" MRU shortcut: (f)iles (r)ecent
nmap <leader>mr :MRU<CR>
nmap <leader>fr :MRU<CR>
if exists('g:vscode')
  nmap <leader>ff :<Cmd>lua require('vscode').action('find-it-faster.findFiles')<CR><CR>
else
  nmap <leader>ff :GFiles<CR>
endif
if exists('g:vscode')
  " TODO: Find a way to find files with --no-ignore
  " nmap <leader>F  :<Cmd>lua require('vscode') .action('find-it-faster.findFiles', { fdArgs = { '-H', '--no-ignore' } })<CR><CR>
else
  nmap <leader>F :Files<CR>
endif

if exists('g:vscode')
  nmap <leader>fg :<Cmd>lua require('vscode').action('find-it-faster.findWithinFiles')<CR><CR>
else
  nmap <leader>fg :Rg<CR>
endif
" (n)erd tree
nmap <leader>p :!pdflatex %<CR>
nmap <leader>P :!pdflatex main.tex<CR>

" quick maps for editing common config files
" (e)dit (v)imrc
:nnoremap <leader>ev :e $MYVIMRC<cr>
:nnoremap <leader>el :e $HOME/.config/nvim/lsp.lua<cr>
" (v)im (v)ertical (open vimrc in vertical split)
:nnoremap <leader>vv :vs $MYVIMRC<cr>
" (e)dit (v)imrc
:nnoremap <leader>ez :vs $HOME/.zshrc<cr>
:nnoremap <leader>cc :!make<cr>
" (s)ource (v)imrc
" :nnoremap <leader>sv :source $MYVIMRC<cr>:AirlineRefresh<cr>

" Shortcutting split navigation, saving a keypress:
nmap <Leader>w <C-w>
nmap <Leader>wf :vs<cr>:Files<cr>
nmap <Leader>wg :vs<cr>:Files ~<cr>
nmap <Leader>wF :vs<cr>:Files ~<cr>

" Shortcutting file navigation. TODO: Make this better, use projectile or something similar.
" (l)ist and switch buffers
" nmap <Leader>l :ls<CR>:b<space>
nmap <Leader>. :e<Space><c-r>=getcwd()<cr>/
nmap <Leader>, :e<Space>
nmap <Leader>bl <c-^>
nmap <Leader>bb :Buffers<CR>
" colorscheme desert256
let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'FugitiveHead'
      \ },
      \ }

augroup NixFmt
  autocmd!
  autocmd BufWritePost *.nix silent !nixfmt %
augroup END


augroup general:
  autocmd!
  " Disables automatic commenting on newline:
  autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
augroup end

augroup filetypes:
  autocmd BufNewFile,BufRead *.sky set filetype=bzl
  autocmd BufNewFile,BufRead *.arxml set filetype=xml
augroup end



if exists('g:vscode')
  :Copilot disable
endif
filetype plugin on
