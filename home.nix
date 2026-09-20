{
  config,
  lib,
  pkgs,
  custom-dwmblocks,
  custom-dwm,
  custom-st,
  nixvim,
  customPkgs,
  unstablePkgs,
  username,
  environment,
  hermesAgent,
  terminalFontPixels,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) isLinux isDarwin;
  mdcodecat = pkgs.writeScriptBin "mdcodecat" (builtins.readFile ./mdcodecat.py);

  ntok = pkgs.writers.writePython3Bin "ntok" {
    libraries = [ pkgs.python3Packages.tiktoken ];
    doCheck = false;
  } (builtins.readFile ./ntok.py);

  selection = import ./packages.nix {
    inherit
      pkgs
      unstablePkgs
      customPkgs
      mdcodecat
      ntok
      environment
      ;
  };

in
{
  imports = [
    # For home-manager
    nixvim.homeModules.nixvim
  ];
  home.username = username;
  home.homeDirectory =
    if pkgs.stdenv.hostPlatform.isDarwin then "/Users/${username}" else "/home/${username}";
  nixpkgs.overlays = [
    (
      final: prev:
      lib.optionalAttrs prev.stdenv.hostPlatform.isLinux {
        dwmblocks = prev.dwmblocks.overrideAttrs (_: {
          src = custom-dwmblocks;
          NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types";
        });
        dwm = prev.dwm.overrideAttrs (old: {
          src = custom-dwm;
          buildInputs = old.buildInputs ++ [ final.libxcb ];
        });
        st = prev.st.overrideAttrs (old: {
          src = custom-st;
          buildInputs = old.buildInputs ++ [ final.harfbuzz ];
        });
      }
      // lib.optionalAttrs (prev.stdenv.hostPlatform.system == "x86_64-linux") {
        claude-code = final.callPackage ./claude-code.nix { };
      }
    )
  ];
  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "openssl-1.1.1w"
      "nix-2.16.2"
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

  # Make the fonts in packages.nix actually resolvable by name on Linux (no-op on Darwin).
  fonts.fontconfig.enable = isLinux;
  xresources.properties = lib.mkIf (isLinux && terminalFontPixels != null) {
    "st.font" = "mono:pixelsize=${toString terminalFontPixels}:antialias=true:autohint=true";
  };
  home.packages =
    selection.packages
    # hermesAgent is null on Darwin (no build there); only append when present.
    ++ pkgs.lib.optional (hermesAgent != null) hermesAgent;
  home.sessionPath = map (pkg: "${lib.getBin pkg}/bin") selection.preferredPackages;

  programs.neovim = {
    enable = false;
    withPython3 = true;
    plugins = with pkgs.vimPlugins; [ coq_nvim ];
  };
  programs.zsh.zprof.enable = true;

  # Out-of-store symlinks: edits to the files in the dotfiles repo are live
  # without a `home-manager switch`. Only re-switch when adding/removing files
  # here or changing other parts of the config.
  #
  # Update `dotfiles` if you move the repo.
  home.file =
    let
      dotfiles = "${config.home.homeDirectory}/pwl-dotfiles";
      link = config.lib.file.mkOutOfStoreSymlink;

      entries =
        dir:
        if builtins.pathExists (./. + "/${dir}") then
          builtins.attrNames (builtins.readDir (./. + "/${dir}"))
        else
          [ ];
      links =
        source: target:
        builtins.listToAttrs (
          map (name: {
            name = "${target}/${name}";
            value.source = link "${dotfiles}/${source}/${name}";
          }) (entries source)
        );
      sharedRules = map (name: builtins.readFile (./. + "/.agents/rules/${name}")) (
        entries ".agents/rules"
      );

      # Agent-specific skills override shared skills with the same name.
      agentFiles =
        links ".agents/rules" ".agents/rules"
        // links ".agents/rules" ".claude/rules"
        // links ".agents/skills" ".agents/skills"
        // links ".agents/skills" ".claude/skills"
        // links ".claude/skills" ".claude/skills"
        // links ".agents/skills" ".codex/skills"
        // links ".codex/skills" ".codex/skills"
        // links ".agents/skills" ".pi/agent/skills"
        // links ".pi/agent/skills" ".pi/agent/skills";
    in
    {
      ".config/emacs/config.org".source = link "${dotfiles}/emacs/config.org";
      ".config/emacs/init.el".source = link "${dotfiles}/emacs/init.el";
      ".config/emacs/early-init.el".source = link "${dotfiles}/emacs/early-init.el";
      ".config/emacs/setup_scripts/buffer-move.el".source =
        link "${dotfiles}/emacs/setup_scripts/buffer-move.el";
      ".config/emacs/setup_scripts/elpaca-setup.el".source =
        link "${dotfiles}/emacs/setup_scripts/elpaca-setup.el";

      # Uncomment if you want to manage neovim with config files
      # ".config/nvim/init.vim".source = link "${dotfiles}/nvim/init.vim";
      # ".config/nvim/coq-config.vim".source = link "${dotfiles}/nvim/coq-config.vim";
      ".config/aliasrc".source = link "${dotfiles}/aliasrc";
      ".config/grab.sh".source = link "${dotfiles}/grab.sh";
      ".config/unroll.sh".source = link "${dotfiles}/unroll.sh";
      ".zshrc".source = link "${dotfiles}/.zshrc";
      ".ssh/config.def".source = link "${dotfiles}/ssh/config";
      ".tmux.conf".source = link "${dotfiles}/.tmux.conf";
      ".config/alacritty/alacritty.toml".source = link "${dotfiles}/alacritty/alacritty.toml";
      ".config/ghostty/config".source = link "${dotfiles}/ghostty/config";
      ".codex/AGENTS.md".text = builtins.concatStringsSep "\n\n" sharedRules;
      ".pi/agent/settings.json".source = link "${dotfiles}/.pi/agent/settings.json";
      ".hermes/config.yaml".source = link "${dotfiles}/hermes/config.yaml";
      # NOTE: ~/.hermes/.env (API keys) and hermes auth state are intentionally
      # NOT tracked — they stay in ~/.hermes outside the repo.

      # zsh plugins, symlinked from the store so .zshrc never git-clones at
      # shell startup. Sources match the paths .zshrc expects under ~/.zsh/plugins.
      ".zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh".source =
        "${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
      ".zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh".source =
        "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh";
      ".zsh/plugins/zsh-system-clipboard/zsh-system-clipboard.zsh".source =
        "${pkgs.zsh-system-clipboard}/share/zsh/zsh-system-clipboard/zsh-system-clipboard.zsh";
      # Extra zsh completions from nixpkgs; .zshrc adds this to fpath before compinit.
      ".zsh/completions".source = "${pkgs.zsh-completions}/share/zsh/site-functions";

    }
    // lib.optionalAttrs isLinux {
      ".config/sxhkd/sxhkdrc".source = link "${dotfiles}/sxhkd/sxhkdrc";
      ".xinitrc".source = link "${dotfiles}/.xinitrc";
    }
    // lib.optionalAttrs isDarwin {
      ".hammerspoon/init.lua".source = link "${dotfiles}/hammerspoon/init.lua";
    }
    // agentFiles;

  # programs.git = {
  #   enable = true;
  #   userName = "Paul Lapey";
  #   userEmail = "plapey45@gmail.com";
  # };
  programs.home-manager.enable = true;

  # Set default model for llm tool
  xdg.configFile."io.datasette.llm/default_model.txt".text = "openrouter/z-ai/glm-5.3";

  programs.nixvim = import ./nixvim-config.nix;

  # GUI file-open (xdg-open) defaults to the first .desktop that claims
  # text/plain; nvim.desktop has Terminal=true which minimal WMs like ours
  # don't honor, so plain emacs.desktop was winning by default. Point it at
  # st+nvim instead.
  xdg.desktopEntries.st-nvim = pkgs.lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    name = "Neovim (st)";
    genericName = "Text Editor";
    comment = "Edit text in st + nvim";
    exec = "st -e nvim %F";
    icon = "nvim";
    terminal = false;
    type = "Application";
    categories = [
      "Utility"
      "TextEditor"
      "Development"
    ];
    mimeType = [
      "text/english"
      "text/plain"
      "text/x-makefile"
      "text/x-c++hdr"
      "text/x-c++src"
      "text/x-chdr"
      "text/x-csrc"
      "text/x-java"
      "text/x-moc"
      "text/x-pascal"
      "text/x-tcl"
      "text/x-tex"
      "application/x-shellscript"
      "text/x-c"
      "text/x-c++"
    ];
  };
  xdg.mimeApps = pkgs.lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/claude-cli" = "claude-code-url-handler.desktop";
      "text/english" = "st-nvim.desktop";
      "text/plain" = "st-nvim.desktop";
      "text/x-makefile" = "st-nvim.desktop";
      "text/x-c++hdr" = "st-nvim.desktop";
      "text/x-c++src" = "st-nvim.desktop";
      "text/x-chdr" = "st-nvim.desktop";
      "text/x-csrc" = "st-nvim.desktop";
      "text/x-java" = "st-nvim.desktop";
      "text/x-moc" = "st-nvim.desktop";
      "text/x-pascal" = "st-nvim.desktop";
      "text/x-tcl" = "st-nvim.desktop";
      "text/x-tex" = "st-nvim.desktop";
      "application/x-shellscript" = "st-nvim.desktop";
      "text/x-c" = "st-nvim.desktop";
      "text/x-c++" = "st-nvim.desktop";
    };
  };

  # macOS keyboard repeat, ~ `xset r rate 300 50` (units ~15ms, applies at next
  # login). The option exists on all platforms; mkIf keeps it Darwin-only.
  targets.darwin.defaults.NSGlobalDomain = pkgs.lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    InitialKeyRepeat = 20; # ~300ms before repeat
    ApplePressAndHold = false; # hold-to-repeat instead of the accent popover
  };

  # home-manager types KeyRepeat as int-only, so the ~50/s fractional rate
  # (1.3 ticks) goes through `defaults` directly, ordered after setDarwinDefaults
  # so it wins over anything that step wrote.
  home.activation.keyRepeatRate = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (
    lib.hm.dag.entryAfter [ "setDarwinDefaults" ] ''
      $DRY_RUN_CMD /usr/bin/defaults write -g KeyRepeat -float 1.3
    ''
  );
}
