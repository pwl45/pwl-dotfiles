{ pkgs, ... }: {
  enable = true;
  plugins = {
    # neotest.adapters.plenary.enable = true;
    # plenary.enable = true;
    bufferline.enable = true;
    web-devicons.enable = true;
    lsp = {
      enable = true;
      servers = {
        # rust-analyzer = {
        #   enable = true;
        #   installCargo = true;
        #   installRustc = true;
        # };
        clangd.enable = true;
        # tsserver.enable = true;
        nixd.enable = true;
        pyright.enable = true;
        # bashls.enable = true;
      };
      keymaps.lspBuf = {
        "gD" = "definition";
        "gI" = "implementation";
        "gC" = "code_action";
        "<leader>rn" = "rename";
        "Q" = "hover";
      };
    };
    copilot-vim.enable = true;
    avante.enable = true;
    treesitter = {
      enable = true;
      settings.highlight.disable = [ "nix" ];
    };
    render-markdown.enable = true;
    vim-surround.enable = true;
    lualine = { enable = true; };
    fugitive.enable = true;
    cmp = {
      enable = true;
      autoEnableSources = true;
      settings = {
        sources =
          [ { name = "nvim_lsp"; } { name = "path"; } { name = "buffer"; } ];
        mapping = {
          "<C-d>" = "cmp.mapping.scroll_docs(-4)";
          "<C-e>" = "cmp.mapping.close()";
          "<C-f>" = "cmp.mapping.scroll_docs(4)";
          "<CR>" = "cmp.mapping.confirm({ select = false })";
          "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
          "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
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
  opts = {
    number = true; # Show line numbers
    relativenumber = false; # Show relative line numbers
    shiftwidth = 4;
    tabstop = 4;
  };
  clipboard.register = "unnamedplus";
  clipboard.providers.xclip.enable = true;
  extraPlugins = with pkgs.vimPlugins; [
    vim-commentary
    # nerdcommenter
    vim-sleuth
    vim-dispatch
    polyglot
    vim-rooter
    vim-colorschemes
    mru
    fzf-vim
    plenary-nvim
    nvim-spectre
  ];

  extraConfigLuaPost = builtins.readFile ./extra-lua-config.lua;

  extraConfigVim = builtins.readFile ./extra-vim-config.vim;
}
