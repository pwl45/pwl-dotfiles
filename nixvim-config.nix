# A nixvim module, not a plain attrset: `pkgs` here is nixvim's own instance,
# built from the nixpkgs it pins and tests against. Everything below, including
# `extraPlugins`, therefore resolves against that instance rather than our
# flake's, so neovim never sees two nixpkgs at once. See flake.nix for the
# matching `follows` removal.
{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  enable = true;
  plugins = {
    # neotest.adapters.plenary.enable = true;
    # plenary.enable = true;
    bufferline.enable = true;
    web-devicons = {
      enable = true;
      autoLoad = true;
    };
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
    # copilot-vim.enable = true;
    # Copilot: provides the LSP for sidekick's Next Edit Suggestions (NES)
    # AND inline ghost-text completion. auto_trigger shows ghost text as you
    # type; accept with <C-j> (sidekick still owns <Tab> for NES). Panel (the
    # multi-suggestion split) stays off.
    # copilot-lua = {
    #   enable = true;
    #   settings = {
    #     panel.enabled = false;
    #     suggestion = {
    #       enabled = true;
    #       auto_trigger = true;
    #       keymap = {
    #         accept = "<C-j>";
    #         accept_word = false;
    #         accept_line = false;
    #         next = "<M-]>";
    #         prev = "<M-[>";
    #         dismiss = "<C-]>";
    #       };
    #     };
    #   };
    # };
    # AI sidekick: Copilot NES + integrated AI CLI terminal.
    # Keymaps (<tab>, <leader>a*, <c-.>) live in extra-lua-config.lua.
    # sidekick = {
    #   enable = true;
    #   settings = {
    #     cli.mux = {
    #       backend = "tmux";
    #       enabled = true;
    #     };
    #   };
    # };
    treesitter = {
      enable = true;
      highlight = {
        enable = true;
        disable = [
          "dockerfile"
          "nix"
        ];
      };
      settings = {
        indent = {
          enable = true;
        };
      };
    };
    render-markdown = {
      enable = true;
      luaConfig.post =
        let
          fileTypes = [
            "markdown"
            "vimwiki"
          ];
        in
        ''
          require('render-markdown').setup({
              file_types = { ${builtins.concatStringsSep "," (map (x: "'" + x + "'") fileTypes)} },
              })
        '';
    };
    vim-surround.enable = true;
    lualine = {
      enable = true;
    };
    fugitive.enable = true;
    cmp = {
      enable = true;
      autoEnableSources = true;
      settings = {
        sources = [
          { name = "nvim_lsp"; }
          { name = "path"; }
          { name = "buffer"; }
        ];
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
    vim-polyglot
    vim-rooter
    vim-colorschemes
    mru
    fzf-vim
    plenary-nvim
    nvim-spectre
    vim-devicons
  ];

  extraConfigLuaPost = builtins.readFile ./extra-lua-config.lua;

  extraConfigVim = builtins.readFile ./extra-vim-config.vim;
}
