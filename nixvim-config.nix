{ pkgs, ... }: {
  enable = true;
  plugins = {
    bufferline.enable = true;
    lsp = {
      enable = true;
      servers = {
        # rust-analyzer = {
        #   enable = true;
        #   installCargo = true;
        #   installRustc = true;
        # };
        # clangd.enable = true;
        nixd.enable = true;
        pyright.enable = true;
      };
    };
    treesitter = {
      enable = true;
      disabledLanguages = [ "nix" ];
    };
    surround.enable = true;
    lualine = { enable = true; };
    fugitive.enable = true;
    nvim-cmp = {
      enable = true;
      sources =
        [ { name = "nvim_lsp"; } { name = "path"; } { name = "buffer"; } ];
      mapping = {
        "<C-d>" = "cmp.mapping.scroll_docs(-4)";
        "<C-e>" = "cmp.mapping.close()";
        "<C-f>" = "cmp.mapping.scroll_docs(4)";
        "<CR>" = "cmp.mapping.confirm({ select = false })";
        "<S-Tab>" = {
          action = "cmp.mapping.select_prev_item()";
          modes = [ "i" "s" ];
        };
        "<Tab>" = {
          action = "cmp.mapping.select_next_item()";
          modes = [ "i" "s" ];
        };
      };
    };
  };
  colorschemes.ayu.enable = true;
  # colorschemes.oxocarbon.enable = true;
  # colorschemes.palette.enable = true;
  # colorschemes.melange.enable = true;
  # colorschemes.rose-pine.enable = true;
  # colorschemes.nord.enable = true;
  # colorschemes.dracula.enable = true;
  # colorschemes.catppuccin.enable = true;
  globals.mapleader = " "; # Sets the leader key to comma
  options = {
    number = true; # Show line numbers
    relativenumber = false; # Show relative line numbers
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
  ];

  extraConfigLuaPost = ''
    vim.cmd[[
    ]]
  '';

  extraConfigVim = builtins.readFile ./extra-vim-config.vim;
}
