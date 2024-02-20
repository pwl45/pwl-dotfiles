{ config, pkgs, firefox-addons,custom-dwmblocks,nixvim,... }:
let
  vim-airline-themes = pkgs.vimUtils.buildVimPlugin {
    name = "vim-airline-themes";
    src = pkgs.fetchFromGitHub {
      owner = "vim-airline";
      repo = "vim-airline-themes";
      rev = "a9aa25ce323b2dd04a52706f4d1b044f4feb7617";
      hash = "sha256-XwlNwTawuGvbwq3EbsLmIa76Lq5RYXzwp9o3g7urLqM";
    };
  };
in
  {
    imports = [
    # For home-manager
    nixvim.homeManagerModules.nixvim
  ];
  home.username = "alice";
  home.homeDirectory = "/home/alice";
  nixpkgs.overlays = [
    (self: super: {
      dwmblocks = super.dwmblocks.overrideAttrs (oldattrs: {
        src = custom-dwmblocks; 
      });
    })
  ]; 
  nixpkgs.config = {

      allowUnfree = true;

      permittedInsecurePackages = [
        "openssl-1.1.1w"
      ];
    };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.
  home.packages = with pkgs; [
     hello
      htop
      fortune
      cowsay
      emacs
      perl
      glibcLocales
      locale 
      python3 
      zsh
      fzf
      bat
      fd
      eza
      sxhkd
      redshift
      dwmblocks
      firefox
      scrot
      aws-workspaces
      gnome.cheese
      mpv
      sxiv
      pavucontrol
      pulsemixer
      brightnessctl
      cargo
      rustc
      zathura
      nerdfonts
      qbittorrent
    
    #Use Emacs from the overlay
    # (emacsOverlay.emacsGit)
  ];
  programs.vim = {
    enable = true; 
    plugins = with pkgs.vimPlugins; [
      nvim-base16
    ];
  };

    programs.neovim = {
      enable = false;
      withPython3 = true;
      # # viAlias = true;
      # # vimAlias = true;
      # # vimdiffAlias = true;
       plugins = with pkgs.vimPlugins; [
         coq_nvim
         nvim-base16
       ];
    };

    programs.nixvim = {
      enable = true;
       plugins = {
         # bufferline.enable = true;
         lsp = {
           enable = true;
           servers = {
             rust-analyzer = {
               enable = true;
               installCargo=true;
               installRustc=true;
             };
             clangd.enable = true;
             nixd.enable = true;
             pyright.enable = true;
           };
         };
         treesitter = {
            enable = true;
            disabledLanguages = [
              "nix"
            ];
         };
         surround.enable=true;
         airline = {
           enable = true;
           theme = "serene";
         };
         fugitive.enable = true;
         coq-nvim = {
            enable = true;
            installArtifacts = true;
            autoStart = true;
            recommendedKeymaps = false;
         };
         coq-thirdparty.enable = true;
       };
       globals.mapleader = " "; # Sets the leader key to comma
       options = {
         number = true;         # Show line numbers
         relativenumber = true; # Show relative line numbers
         shiftwidth = 4;
         tabstop = 4;
       };
       clipboard.register = "unnamedplus";
       clipboard.providers.xclip.enable = true;
       extraPlugins = with pkgs.vimPlugins; [
         vim-commentary
         vim-sleuth
         vim-dispatch
         polyglot
         vim-rooter
         vim-colorschemes
         mru
         fzf-vim
         vim-airline-themes
       ];
       keymaps = [
         {
           mode = "n";
           key = "<C-Space>";
           action = "<cmd>update<CR>";
         }
       ];
       extraConfigVim = ''
         let g:polyglot_disabled = ['autoindent', 'sensible']

         let g:coq_settings = { "keymap.jump_to_mark": "",  "keymap.manual_complete": "", "xdg":v:true  }

         " Keybindings
         ino <silent><expr> <Esc>   pumvisible() ? "\<C-e><Esc>" : "\<Esc>"
         ino <silent><expr> <C-c>   pumvisible() ? "\<C-e><C-c>" : "\<C-c>"
         ino <silent><expr> <BS>    pumvisible() ? "\<C-e><BS>"  : "\<BS>"
         ino <silent><expr> <CR>    pumvisible() ? (complete_info().selected == -1 ? "\<C-e><CR>" : "\<C-y>") : "\<CR>"
         ino <silent><expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
         ino <silent><expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<BS>"

         " C-h is what the teriminal reads as shift backspace - I don't like that being used for nav marks
         " replacing that with C-f or C-d
         inoremap <silent><expr> <C-h>   pumvisible() ? "\<C-e><BS>"  : "\<BS>"
         " ino <C-f>                  <C-\><C-N><Cmd>lua COQ.Nav_mark()<CR>

         "hooooo boy is this nice.
         ino jkl                  <C-\><C-N><Cmd>lua COQ.Nav_mark()<CR>
         ino lkj                  <C-\><C-N><Cmd>lua COQ.Nav_mark()<CR>

         " ino <C-d>                  <C-\><C-N><Cmd>lua COQ.Nav_mark()<CR>

         let g:airline_powerline_fonts = 1
         " Remaps

         " use Q for (q)uestions
         nnoremap Q K 

         " Use j and k to jump visual lines, not actual lines. 
         " use gj and gk to do what j and k normally do
         nnoremap j gj
         nnoremap k gk
         nnoremap gj j
         nnoremap gk k

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
         nmap <leader>mg :Magit<CR>
         " MRU shortcut: (f)iles (r)ecent
         nmap <leader>mr :MRU<CR>
         nmap <leader>fr :MRU<CR>
         nmap <leader>ff :Files<CR>

         " nnoremap <leader>ff <cmd>Telescope find_files<cr>
         nmap <leader>F :Files ~<CR>
         nmap <leader>fg :Rg<CR>
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
         :nnoremap <leader>sv :source $MYVIMRC<cr>:AirlineRefresh<cr>

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
         colorscheme desert256


       '';
    };


  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    ".screenrc".source = ./.screenrc;
    ".config/emacs/config.org".source = ./emacs/config.org;
    ".config/emacs/init.el".source = ./emacs/init.el;
    ".config/emacs/early-init.el".source = ./emacs/early-init.el;
    ".config/emacs/setup_scripts".source = ./emacs/setup_scripts;
    # ".config/nvim/init.vim".source = ./nvim/init.vim;
    # ".config/nvim/coq-config.vim".source = ./nvim/coq-config.vim;
    # ".config/nvim/lsp.lua".source = ./nvim/lsp.lua;
    ".config/sxhkd/sxhkdrc".source = ./sxhkd/sxhkdrc;
    ".config/aliasrc".source = ./aliasrc;
    ".zshrc".source = ./.zshrc;
    ".xinitrc".source = ./.xinitrc;

  };

  programs.firefox = {
    enable = true;
  };

  programs.home-manager.enable = true;
}
