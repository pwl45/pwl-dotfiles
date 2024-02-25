{ pkgs, ... }: {
  enable = true;
  plugins = {
    lsp = {
      enable = true;
      servers = {
        rust-analyzer = {
          enable = true;
          installCargo=true;
          installRustc=true;
        };
        clangd = { enable = true; };
        nixd = { enable = true; };
        pyright = { enable = true; };
      };
    };
    treesitter = {
      enable = true;
      disabledLanguages = [ "nix" ];
    };
    surround = { enable=true; };
    airline = {
      enable = true;
      theme = "serene";
    };
    fugitive = { enable = true; };
    coq-nvim = {
      enable = true;
      installArtifacts = true;
      autoStart = true;
      recommendedKeymaps = false;
    };
    coq-thirdparty = { enable = true; };
  };
  globals = { mapleader = " "; }; # Sets the leader key to comma
  options = {
    number = true;         # Show line numbers
    relativenumber = true; # Show relative line numbers
    shiftwidth = 4;
    tabstop = 4;
  };
  clipboard = {
    register = "unnamedplus";
    providers = { xclip = { enable = true; }; };
  };
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
}
