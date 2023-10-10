" let fortune = system('/home/paul/scripts/line-fortunes.sh')
let mapleader =" "
let g:python3_host_prog = 'python3.9' 
let g:EasyMotion_do_mapping = 0
let g:polyglot_disabled = ['autoindent', 'sensible']
" TODO:
" Give yourself some nice insert mode bindings!"  
  " EOL, newl, left, right, etc. 
  " may be challenging with how fucking [REDACTED] terminals are with their six total characters

"Folded by default: Plugin installation, variable settings {{{
  " plugshit ---------------------- {{{
    if ! filereadable(system('echo -n "${XDG_CONFIG_HOME:-$HOME/.config}/nvim/autoload/plug.vim"'))
      echo "Downloading junegunn/vim-plug to manage plugins..."
      silent !mkdir -p ${XDG_CONFIG_HOME:-$HOME/.config}/nvim/autoload/
      silent !curl "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" > ${XDG_CONFIG_HOME:-$HOME/.config}/nvim/autoload/plug.vim
      autocmd VimEnter * PlugInstall
    endif

    call plug#begin(system('echo -n "${XDG_CONFIG_HOME:-$HOME/.config}/nvim/plugged"'))
    Plug 'airblade/vim-rooter'
    Plug 'vim-airline/vim-airline'
    Plug 'easymotion/vim-easymotion'
    Plug 'flazz/vim-colorschemes'
    Plug 'jreybert/vimagit'
    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    Plug 'junegunn/fzf.vim'
    Plug 'neovim/nvim-lspconfig'
    " Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install' }
    " Plug 'poliquin/stata-vim'
    " Plug 'preservim/nerdtree'
    Plug 'vim-airline/vim-airline-themes'
    Plug 'sheerun/vim-polyglot'
    " tpope plugins are simple, essential, and portable. amazing.
    Plug 'tpope/vim-commentary'
    Plug 'tpope/vim-dispatch'
    Plug 'tpope/vim-fugitive'
    Plug 'tpope/vim-sleuth'
    Plug 'tpope/vim-surround'
    " kinda sucks, but use sometimes anyway
    Plug 'yegappan/mru'

    Plug 'nvim-lua/plenary.nvim'
    Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.0' }
    " Plug 'frazrepo/vim-rainbow'
    " Plug 'kana/vim-textobj-user'

    " coq: its own beast
    Plug 'ms-jpq/coq_nvim', {'branch': 'coq'}
    Plug 'ms-jpq/coq.artifacts', {'branch': 'artifacts'}
    Plug 'ms-jpq/coq.thirdparty', {'branch': '3p'}
    " Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
    " Plug 'vim-syntastic/syntastic'
    " Plug 'neoclide/coc.nvim', {'branch': 'release'}
    " Plug 'osyo-manga/vim-over'
    " call PlugDisable()
    call plug#end()
  " }}}

  "Setting default variables ------------------- {{{
    set title
    set bg=light
    set go=a
    set mouse=a
    set clipboard+=unnamedplus
    " set hidden
    set showmode
    set ruler
    set laststatus=2
    set showcmd
    set hlsearch
    set inccommand=nosplit
    set ignorecase
    set smartcase
    set number "relativenumber
    set encoding=utf-8
    " set tabstop=2 shiftwidth=2 softtabstop=2 expandtab
    " echom &shiftwidth

    " Splits open at the bottom and right, which is intuitive, unlike vim defaults.
    set splitbelow splitright
    " Enable commandline autocompletion:
    set wildmode=longest,list,full
    set nocompatible
    syntax on
    " filetype off
    filetype plugin on

  " end setting default variables}}}
  "Setting plugin variables ------------------- {{{
    " Necessary for cool symbols in airline statusbar
    let g:airline_powerline_fonts = 1
    let g:EasyMotion_smartcase = 1
    let g:rooter_change_directory_for_non_project_files = 'current'



      " end setting plugin variables}}}
    "}}}
    "let g:python3_host_prog = "python3.9"
    "comment both of these if you're running in minimal mode
    source $HOME/.config/nvim/lsp.lua
    source $HOME/.config/nvim/coq-config.vim

    " lua << EOF

    " EOF

" Search and movement remaps
  "TODO: Make mapping for jumping between functions in (python, java, c)

  nnoremap Q K 
  " Use j and k to jump visual lines, not actual lines. 
  " use gj and gk to do what j and k normally do
  nnoremap j gj
  nnoremap k gk
  nnoremap gj j
  nnoremap gk k

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
  " " lets you use C-Enter (with my st binding) like o
  " inoremap <C-CR> <C-o>o
  " nnoremap <C-CR> o

  " use Q for (q)uestions

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

  " vim-easymotion:
  " easymotion-s2: bidirectional search for two characters over multiple lines.
  " honestly hardly ever use this, mmight remove
  " nnoremap s <Plug>(easymotion-s2)
  " easymotion-sl: bidrectional search for signle char over current line.
    " nnoremap f <Plug>(easymotion-sl) 
    " This is TERRIBLE for making macros and whatnot
    " Use only if you're really dumb; find another binding probably.
  " easymotion-sl: bidrectional search for signle char over current line.
    " nnoremap t <Plug>(easymotion-tl)
    " This is TERRIBLE for making macros and whatnot
    " Use only if you're really dumb; find another binding probably.
" Remaps for around/in next/last parentheses. Not very useful, but cool.

  onoremap in( :<c-u>normal! f(vi(<cr>
  onoremap in) :<c-u>normal! f(vi(<cr>
  onoremap an( :<c-u>normal! f(va(<cr>
  onoremap an) :<c-u>normal! f(va(<cr>
  onoremap if :<c-u>normal!  ?\\begin{figure}<cr>V/\\end{figure}<cr>

   
  " negro eth negro eth(b8i)

  onoremap n$ :<c-u>normal! f$vf$<cr>
  onoremap i$ :<c-u>normal! T$vt$<cr>
  onoremap a$ :<c-u>normal! F$vf$<cr>

  onoremap J }
  onoremap K {

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
  " (q)uit
  :nnoremap <leader>qq :bd<cr>
  "careful with this one
  :nnoremap <leader>Q :q!<cr>

" 
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
  nmap <leader>mg :Magit<CR>
  " MRU shortcut: (f)iles (r)ecent
  nmap <leader>mr :MRU<CR>
  nmap <leader>fr :MRU<CR>
  nmap <leader>ff :Files<CR>

  " nnoremap <leader>ff <cmd>Telescope find_files<cr>
  nmap <leader>F :Files ~<CR>
  nmap <leader>fg :Rg<CR>
  " (n)erd tree
  " nmap <leader>n :NERDTreeToggle<CR>
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
  :nnoremap <leader>sv :source $MYVIMRC<cr>:AirlineRefresh<cr>

" Auto commands
  augroup general:
    autocmd!
    " Disables automatic commenting on newline:
    autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
  augroup end

  augroup dumbfiledetection:
    autocmd!
    autocmd BufReadPost *.html set filetype=html
  augroup end

  augroup savecmds:
    autocmd!
    " autocmd BufWritePost *.tex silent! execute "!pdflatex % >/dev/null 2>&1" | redraw!
    " autocmd BufWritePost *.tex Make!
    " autocmd BufWritePost *sxhkdrc !killall sxhkd; setsid sxhkd &
    " TODO: Break this out into a function, save original cursor position with a mark and go back.
    " autocmd BufWritePre * %s/\s\+$//e
    " autocmd BufWritePre * %s/\n\+\%$//e
    " autocmd BufWritePre *.[ch] %s/\%$/\r/e
  augroup end

  augroup filetype_tmp
      autocmd!
      " Fold some less interesting stuff
      autocmd BufEnter *.tex echo "bryce"
      " autocmd BufEnter *.tmp echo "bryce"
      autocmd BufEnter *.term :call HideAll()
      " autocmd BufEnter *.term norm G
  augroup end

  augroup filetype_vim
      autocmd!
      " Fold some less interesting stuff
      autocmd FileType vim setlocal foldmethod=marker
  augroup end
  augroup filetype_tex
      autocmd!
      " Fold some less interesting stuff

      autocmd FileType tex inoremap jke \begin{enumerate}<CR>\end{enumerate}<ESC>O\item
      autocmd FileType tex inoremap jki \item
      autocmd FileType tex inoremap jks \bigskip<cr>
      autocmd FileType tex inoremap jkc \cite{}<left>
      autocmd FileType tex nnoremap <leader>bs i\bigskip<cr><esc>
      " autocmd FileType tex inoremap jki \item[.]<left><left>
      " autocmd FileType tex inoremap sdf <Esc>:call TexMath()<CR>a
      autocmd FileType tex inoremap sdf $$<left>
      autocmd FileType tex inoremap fds <ESC>f$a
      autocmd FileType tex nnoremap <leader>$ :norm ysiW$<CR>
      autocmd FileType tex nnoremap <leader>tt :!tail -n 50 *.log<CR>
  augroup end

  augroup filetype_md
    autocmd FileType markdown nnoremap <leader>md :Dispatch! markdown % > %.html<CR>
  augroup end

  augroup filetype_py
      autocmd FileType python inoremap jkp print()<left>
      autocmd FileType python inoremap jkf for i in range():<left><left>
      autocmd FileType python inoremap jkc if :<left>
      autocmd FileType python inoremap jke if :<CR><BS>else:<up><left>

  augroup end

  augroup filetype_html
      autocmd FileType html inoremap jkl <a href="">here</a><esc>10h
      autocmd FileType html inoremap jkc <code></code><left><left><left><left><left><left><left>
      autocmd FileType html inoremap sdf <code></code><left><left><left><left><left><left><left>
      autocmd FileType html inoremap jkp <p></p><left><left><left><left>
      autocmd FileType html inoremap fds <esc>f>a
      autocmd FileType python inoremap jkf for i in range():<left><left>
      autocmd FileType python inoremap jkc if :<left>
      autocmd FileType python inoremap jke if :<CR><BS>else:<up><left>

  augroup end

  augroup filteype_c
      autocmd!
      " Fold some less interesting stuff
      autocmd FileType c inoremap jkp printf("\n");<left><left><left><left><left>
      autocmd FileType c inoremap jkpp printf("\n");<left><left><left><left><left>
      autocmd FileType c inoremap jkpf printf("\n");<left><left><left><left><left>
      autocmd FileType c inoremap jkpe fprintf(stderr,"\n");<left><left><left><left><left>
      autocmd FileType c inoremap jkpd printf("%d\n",);<left><left>
      autocmd FileType c inoremap jkps printf("%s\n",);<left><left>
      autocmd FileType c inoremap jki if(){<CR>}<up><right><right>
      autocmd FileType c inoremap jke if(){<CR>}else{<CR>}<up><up><right><right>
      autocmd FileType c inoremap jkE if(){<CR>}else if (){<CR>}<up><up><right><right>
      autocmd FileType c inoremap jkc if(){<CR>}<up><right><right>
      autocmd FileType c inoremap jkf for(int i = 0; i < ; i++){<CR>}<up><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right>
      autocmd FileType c inoremap jkj for(int j = 0; j < ; j++){<CR>}<up><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right>
      autocmd FileType c inoremap jkk for(int k = 0; k < ; k++){<CR>}<up><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right>
      autocmd FileType c inoremap jkw while(){<CR>}<up><right><right><right><right><right>
  augroup end

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
  nmap <leader>dd :let g:rooter_manual_only = 1<cr>:cd %:p:h<cr>:echo getcwd() ';' GetManual()<cr>
  nmap <leader>rr :RooterToggle<cr> :echo GetManual() 'dirs'<cr>
  nmap <Leader>bl <c-^>
  nmap <Leader>bb :Buffers<CR>
" Turns off highlighting on the bits of code that are changed, so the line that is changed is highlighted but the actual text that has changed stands out on the line and is readable.
if &diff
  highlight! link DiffText MatchParen
endif
" nnoremap <leader>g :set operatorfunc=<SID>GrepOperator<cr>g@
" vnoremap <leader>g :<c-u>call <SID>GrepOperator(visualmode())<cr>
vnoremap <leader>mo :<c-u>call <SID>moveout()<cr>

function! s:sort(str)
    silent execute "grep! -R " . shellescape(@@) . " ."
    let @@ = saved_unnamed_register
endfunction

function s:moveout()
    let saved_unnamed_register = @@


    " save name of original file
    let original_file=expand('%')

    " get name of new file
    let new_file = input('Enter new filename: ')

    " cut selected block (copying to clipboard)
    " normal! ignores remaps, c *will* cut to clipboard
    execute "normal! `<v`>c\\input{" . new_file . "}"
    execute "edit" new_file
    normal! Gp
    write

    execute "edit" original_file
    write
    
    let @@ = saved_unnamed_register
endfunction

function! s:GrepOperator(type)
    let saved_unnamed_register = @@

    if a:type ==# 'v'
        normal! `<v`>y
    elseif a:type ==# 'char'
        normal! `[v`]y
    else
        return
    endif

    silent execute "grep! -R " . shellescape(@@) . " ."
    copen

    let @@ = saved_unnamed_register
endfunction

function! GetManual()
    if g:rooter_manual_only
  return 'manual'
    else 
  return 'automatic'
    endif
endfunction



" Toggling bottom statusbar: mapped to <leader>h {{{
  let s:hidden_all = 0
  function! ToggleHiddenAll()
    if s:hidden_all  == 0
      let s:hidden_all = 1
      set noshowmode
      set noruler
      set laststatus=0
      set noshowcmd
    else
      let s:hidden_all = 0
      set showmode
      set ruler
      set laststatus=2
      set showcmd
    endif
  endfunction
  " TODO: <leader>h is far too valuable of binding to waste on this function. C
  " Change when you find something better for it.
  nnoremap <leader>h :call ToggleHiddenAll()<CR>
"}}}

" Statusline stuff
  " set statusline+=%#warningmsg#
  " set statusline+=%{FugitiveStatusline()}
  " set statusline+=%{SyntasticStatuslineFlag()}
  " set statusline+=%*
  let g:airline#extensions#tabline#enabled = 1
  " let g:airline#extensions#tabline#fnamemod = ':t'
  let g:airline_theme='serene'

nnoremap <C-h> 2<C-w>>
nnoremap <C-l> 2<C-w><
function! HideAll()
  set noshowmode
  set noruler
  set laststatus=0
  set noshowcmd
endfunction
" Colorscheme stuff

    " god i love this colorscheme
    "makes me feel like muad-dib himself
    colorscheme desert256 
    " hi Normal guibg=dark ctermbg=none
    nnoremap <leader>cs :colorscheme<space>
    nnoremap <leader>cd :colorscheme<space><c-r>"<CR>


    " source a line. should really only be used on vimscript
    nnoremap <leader>sl yy:<c-r>"<CR>
    nnoremap <leader>at :AirlineTheme<space>
    " dracula mode
    nnoremap <leader>dm :colorscheme<space> 256_noir<cr> :AirlineTheme lucius<cr>
    " elflord mode
    nnoremap <leader>em :colorscheme<space> elflord<cr> :AirlineTheme dark<cr>
" echo "for(char **wordv = words.we_wordv; *wordv; puts(*(wordv++)));"
" echom &shiftwidth
