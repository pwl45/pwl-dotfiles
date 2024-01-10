(add-to-list 'load-path "~/.config/emacs/setup_scripts")

;; Elpaca package manager!
(require 'elpaca-setup)
;; Move buffers around!
(require 'buffer-move)

(use-package undo-tree
  :init
  (global-undo-tree-mode)
  )
(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-vsplit-window-right t)
  (setq evil-undo-system 'undo-tree)

  (evil-mode)
  )
(use-package evil-collection
  :after evil
  :config
  (setq evil-collection-mode-list '(dashhboard dired ibuffer))
  (evil-collection-init))
(use-package evil-tutor)
;;(with-eval-after-load 'evil-maps
;;(define-key evil-motion-state-map (kbd "SPC") nil)
;;(define-key evil-motion-state-map (kbd "RET") nil)
;;(define-key evil-motion-state-map (kbd "TAB") nil)
;;)


;;Turns off elpaca-use-package-mode current declaration
;;Note this will cause the declaration to be interpreted immediately (not deferred).
;;Useful for configuring built-in emacs features.
(use-package emacs :elpaca nil :config (setq ring-bell-function #'ignore))

;; Don't install anything. Defer execution of BODY
;; (elpaca nil (message "deferred"))

(use-package evil-commentary
  :config
  (setq evil-commentary-mode t)
  )

(use-package general
  :config
  (general-evil-setup)
  ;; set up 'SPC' as the global leader key
  (general-create-definer pwl/leader-keys
    :states '(normal insert visual emacs)
    :keymaps 'override
    :prefix "SPC" ;; set leader
    :global-prefix "M-SPC") ;; access leader in insert mode

  ;; Basic QOL maps
  (pwl/leader-keys
    "wq" '((lambda () (interactive) (save-buffer) (kill-emacs)) :wk "Write and quit")
    )

  ;; Buffer Navigation
  (pwl/leader-keys
    "SPC" '(counsel-M-x :wk "Counsel M-x")
    "." '(find-file :wk "Find file")
    "fc" '((lambda () (interactive) (find-file "~/.config/emacs/config.org")) :wk "Edit emacs config")
    "fr" '(counsel-recentf :wk "Find recent files")
    "ff" '(helm-multi-files :wk "Fuzzy find files in helm")
    "fg" '(helm-rg :wk "rip grep for files with helm")
    "rg" '(helm-rg :wk "rip grep for files with helm")
    "TAB TAB" '(comment-line :wk "Comment lines")
    )

  ;; Buffer Navigation
  (pwl/leader-keys
    "b" '(:ignore t :wk "buffer")
    "bb" '(switch-to-buffer :wk "Switch buffer")
    "bi" '(ibuffer :wk "Ibuffer")
    "bk" '(kill-this-buffer :wk "Kill this buffer")
    "bn" '(next-buffer :wk "Next buffer")
    "bp" '(previous-buffer :wk "Previous buffer")
    "bl" '((lambda () (interactive) (switch-to-buffer (other-buffer (current-buffer) 1))) :wk "Last buffer")
    "br" '(revert-buffer :wk "Reload buffer")

    )

  ;; elisp evaluation
  (pwl/leader-keys
    "e" '(:ignore t :wk "Evaluate")
    "eb" '(eval-buffer :wk "Evaluate elisp in buffer")
    "ed" '(eval-defun :wk "Evaluate defun containing or after point")
    "ee" '(eval-defun :wk "Evaluate elisp expression")
    "el" '(eval-last-sexp :wk "Evaluate elisp expression before point")
    "er" '(eval-last-sexp :wk "Evaluate elisp in region"))

  ;; help
  (pwl/leader-keys
    "h" '(:ignore t :wk "Help")
    "hf" '(describe-function :wk "Describe function")
    "hv" '(describe-variable :wk "Describe variable")
    "hb" '(describe-bindings :wk "Describe bindings")
    ;;"hrr" '((lambda () (interactive) (load-file user-init-file)) :wk "Reload emacs config"))
    "hrr" '((lambda () (interactive) 
              (load-file user-init-file)
              (ignore (elpaca-process-queues)) )
            :wk "Reload emacs config"))

  ;; window movement
  (pwl/leader-keys
    "w" '(:ignore t :wk "Windows")
    ;; Window splits
    "w c" '(evil-window-delete :wk "Close window")
    "w n" '(evil-window-new :wk "New window")
    "w s" '(evil-window-split :wk "Horizontal split window")
    "w v" '(evil-window-vsplit :wk "Vertical split window")
    ;; Window motions
    "w h" '(evil-window-left :wk "Window left")
    "w j" '(evil-window-down :wk "Window down")
    "w k" '(evil-window-up :wk "Window up")
    "w l" '(evil-window-right :wk "Window right")
    "w w" '(evil-window-next :wk "Goto next window")
    ;; Move Windows
    "w H" '(buf-move-left :wk "Buffer move left")
    "w J" '(buf-move-down :wk "Buffer move down")
    "w K" '(buf-move-up :wk "Buffer move up")
    "w L" '(buf-move-right :wk "Buffer move right"))

  (pwl/leader-keys
    "m" '(:ignore t :wk "Org")
    "m a" '(org-agenda :wk "Org agenda")
    "m e" '(org-export-dispatch :wk "Org export dispatch")
    "m i" '(org-toggle-item :wk "Org toggle item")
    "m t" '(org-todo :wk "Org todo")
    "m B" '(org-babel-tangle :wk "Org babel tangle")
    "m T" '(org-todo-list :wk "Org todo list"))

  (pwl/leader-keys
    "m b" '(:ignore t :wk "Tables")
    "m b -" '(org-table-insert-hline :wk "Insert hline in table"))

  (pwl/leader-keys
    "m d" '(:ignore t :wk "Date/deadline")
    "m d t" '(org-time-stamp :wk "Org time stamp"))

  (pwl/leader-keys
    "d" '(:ignore t :wk "Dired")
    "d d" '(dired :wk "Open dired")
    "d j" '(dired-jump :wk "Dired jump to current")
    "d p" '(peep-dired :wk "Peep-dired"))

  (defun save-and-escape ()
    "Save the buffer and escape from the current mode."
    (interactive)
    (save-buffer)
    (evil-normal-state))

  (general-define-key
   :states '(normal insert visual)
   "C-SPC" 'save-and-escape)

  ;; Simple remaps for normal mode
  (general-define-key
   :states 'normal
   "Q" 'evil-lookup
   "J" 'evil-forward-paragraph
   "K" 'evil-backward-paragraph
   "H" 'evil-first-non-blank
   "L" 'evil-end-of-line
   "j" 'evil-next-visual-line
   "k" 'evil-previous-visual-line

)

  ;; Simple remaps for visual mode
  (general-define-key
   :states 'visual
   "H" 'evil-first-non-blank
   "L" 'evil-end-of-line)

  ;; S - substitute command skeleton and move the cursor between the two slashes
  ;; this is annoyingly difficult, have to do minibuffer-with-setup-hook
  (general-define-key
   :states 'normal
   :keymaps 'override
   "S" (lambda ()
         (interactive)
         (minibuffer-with-setup-hook
             (lambda () (backward-char 2))
           (evil-ex "%s//g"))
         )
   )

  (general-define-key
   :states 'visual
   :keymaps 'override
   "S" (lambda ()
         (interactive)
         (minibuffer-with-setup-hook
             (lambda () (backward-char 2))
           (evil-ex "'<,'>s//g")
           )
         )
   )

  ;; nnoremap c "_c
  (defvar my/original-evil-change-command (lookup-key evil-normal-state-map "c"))
  (defun my/evil-change-to-blackhole ()
    (interactive)
    (let ((evil-this-register ?_))
      (call-interactively my/original-evil-change-command)))
  (general-define-key
   :states '(normal visual)
   "c" 'my/evil-change-to-blackhole)

  ;; nnoremap C "_C
  (defvar my/original-evil-change-to-end-of-line-command (lookup-key evil-normal-state-map "C"))
  (defun my/evil-change-to-end-of-line-to-blackhole ()
    (interactive)
    (let ((evil-this-register ?_))
      (call-interactively my/original-evil-change-to-end-of-line-command)))
  (general-define-key
   :states '(normal visual)
   "C" 'my/evil-change-to-end-of-line-to-blackhole)


  )

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(global-display-line-numbers-mode 1)
(global-visual-line-mode t)

(set-face-attribute 'default nil
                    :font "JetBrains Mono"
                    :height 110
                    :weight 'medium)
(set-face-attribute 'variable-pitch nil
                    :font "Ubuntu"
                    :height 120
                    :weight 'medium)
(set-face-attribute 'fixed-pitch nil
                    :font "JetBrains Mono"
                    :height 110
                    :weight 'medium)

;; Makes commented text and keywords italics
;; This works in emacsclient but not emacs
;; Your font must have an italic face available
(set-face-attribute 'font-lock-comment-face nil
                    :slant 'italic)
(set-face-attribute 'font-lock-keyword-face nil
                    :slant 'italic)

(add-to-list 'default-frame-alist '(font . "JetBrains Mono-11"))

(setq-default lin-spacing 0.12)

(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "<C-wheel-up>") 'text-scale-increase)
(global-set-key (kbd "<C-wheel-down>") 'text-scale-decrease)

(use-package all-the-icons
  :ensure t
  :if (display-graphic-p))

(use-package all-the-icons-dired
  :hook (dired-mode . (lambda () (all-the-icons-dired-mode t))))

(add-to-list 'custom-theme-load-path "~/.config/emacs/themes")

(use-package doom-themes
  :ensure t
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (load-theme 'doom-acario-dark t)

  ;; Enable flashing mode-line on errors
  ;; (doom-themes-visual-bell-config)
  ;; Enable custom neotree theme (all-the-icons must be installed!)
  ;; or for treemacs users
  (setq doom-themes-treemacs-theme "doom-atom") ; use "doom-colors" for less minimal icon theme
  (doom-themes-treemacs-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

(setq inhibit-startup-screen t)

(use-package hl-todo
  :hook ((org-mode . hl-todo-mode)
         (prog-mode . hl-todo-mode))
  :config
  (setq hl-todo-highlight-punctuation ":"
        hl-todo-keyword-faces
        `(("TODO"       warning bold)
          ("FIXME"      error bold)
          ("HACK"       font-lock-constant-face bold)
          ("REVIEW"     font-lock-keyword-face bold)
          ("NOTE"       success bold)
          ("DEPRECATED" font-lock-doc-face bold))))

(use-package rainbow-mode
  :diminish
  :hook org-mode prog-mode)

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :config
  (setq doom-modeline-height 35      ;; sets modeline height
        doom-modeline-bar-width 5    ;; sets right bar width
        doom-modeline-persp-name t   ;; adds perspective name to modeline
        doom-modeline-persp-icon t)) ;; adds folder icon next to persp name

(use-package diminish)

(use-package rainbow-delimiters
  :hook ((emacs-lisp-mode . rainbow-delimiters-mode)
  (clojure-mode . rainbow-delimiters-mode)))

(use-package dashboard
  :ensure t 
  :init
  ;;(setq initial-buffer-choice 'dashboard-open)
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-file-icons t)
  (setq dashboard-banner-logo-title "Emacs Is More Than A Text Editor!")
  ;;(setq dashboard-startup-banner 'logo) ;; use standard emacs logo as banner
  ;;(setq dashboard-startup-banner "/home/dt/.config/emacs/images/emacs-dash.png")  ;; use custom image as banner
  (setq dashboard-center-content nil) ;; set to 't' for centered content
  (setq dashboard-items '((recents . 5)
                          (agenda . 5 )
                          (bookmarks . 3)
                          (projects . 3)
                          (registers . 3)))
  :custom
  (dashboard-modify-heading-icons '((recents . "file-text")
                                    (bookmarks . "book")))
  :config
  (dashboard-setup-startup-hook))
(setq inhibit-startup-screen t)

;; Scroll one line at a time
(setq scroll-step 1)
(setq scroll-conservatively 10000)

;; make word mappings go past underscore
;; ciw diw cw dw, etc.
(modify-syntax-entry ?_ "w")
(add-hook 'prog-mode-hook
          (lambda ()
            (modify-syntax-entry ?_ "w")))

;; fill in closing things
(electric-pair-mode)

(setq backup-directory-alist '((".*" . "~/.Trash")))

(use-package eshell-syntax-highlighting
  :after esh-mode
  :config
  (eshell-syntax-highlighting-global-mode +1))

;; eshell-syntax-highlighting -- adds fish/zsh-like syntax highlighting.
;; eshell-rc-script -- your profile for eshell; like a bashrc for eshell.
;; eshell-aliases-file -- sets an aliases file for the eshell.

(setq eshell-rc-script (concat user-emacs-directory "eshell/profile")
      eshell-aliases-file (concat user-emacs-directory "eshell/aliases")
      eshell-history-size 5000
      eshell-buffer-maximum-lines 5000
      eshell-hist-ignoredups t
      eshell-scroll-to-bottom-on-input t
      eshell-destroy-buffer-when-process-dies t
      eshell-visual-commands'("bash" "fish" "htop" "ssh" "top" "zsh"))

(use-package vterm
  :config (setq shell-file-name "/bin/bash"))

(use-package sudo-edit)

(global-set-key [escape] 'keyboard-escape-quit)

(use-package dired-open
  :config
  (setq dired-open-extensions '(("gif" . "sxiv")
                                ("jpg" . "sxiv")
                                ("png" . "sxiv")
                                ("mkv" . "mpv")
                                ("mp4" . "mpv"))))

;; (use-package peep-dired
;;   :after dired
;;   :hook (evil-normalize-keymaps . peep-dired-hook)
;;   :config
;;   (evil-define-key 'normal dired-mode-map (kbd "h") 'dired-up-directory)
;;   (evil-define-key 'normal dired-mode-map (kbd "l") 'dired-open-file) ; use dired-find-file instead if not using dired-open package
;;   (evil-define-key 'normal peep-dired-mode-map (kbd "j") 'peep-dired-next-file)
;;   (evil-define-key 'normal peep-dired-mode-map (kbd "k") 'peep-dired-prev-file)
;;   )

;;(add-hook 'peep-dired-hook 'evil-normalize-keymaps)

(defun my/company-complete-or-newline ()
  "Complete the selection if a company suggestion is highlighted, otherwise insert a newline."
  (interactive)
  (if (and (company-manual-begin) company-selection-changed)
      (company-complete-selection)
    (newline)))

(use-package company
  :defer 2
  :diminish
  :custom
  (company-begin-commands '(self-insert-command))
  (company-idle-delay .05)
  (company-minimum-prefix-length 1)
  (company-show-numbers t)
  (company-tooltip-align-annotations 't)
  (global-company-mode t)
  (company-tng-mode t)
  :config
  (define-key company-active-map (kbd "RET") #'my/company-complete-or-newline)
  (define-key company-active-map [return] #'my/company-complete-or-newline)
  (add-to-list 'company-backends 'company-dabbrev-code)
  (setq company-dabbrev-code-ignore-case t)
  (setq company-dabbrev-downcase nil)
  (setq company-dabbrev-code-everywhere t)
  (setq company-dabbrev-code-modes t)
  (setq company-dabbrev-code-other-buffers 'all)

  )


;; (with-eval-after-load 'company


(use-package company-box
  :after company
  :diminish
  :hook (company-mode . company-box-mode))

(use-package helm
  :ensure t  ; Make sure the package is installed automatically
  :init
  ;; You can set Helm-specific initialization settings here
  :config
  ;; (require 'helm-config)  ; Load Helm configuration

  ;; Set Helm as the default completion mechanism
  (helm-mode 1)
  (setq helm-mode-fuzzy-match t)
  (setq helm-completion-in-region-fuzzy-match t)

  ;; Bind the Helm command to a key combination, e.g., "C-x C-f" for `helm-find-files`
  ;; (global-set-key (kbd "C-x C-f") #'helm-find-files)
  ;; (global-set-key (kbd "M-x") #'helm-M-x)
  ;; (global-set-key (kbd "C-x b") #'helm-buffers-list)
  ;; ... and other key bindings as needed

  ;; You can customize Helm further using `setq` and other configuration commands
  )
(use-package helm-rg
  :ensure t  ; Automatically install the package if not already installed
  :config
  ;; Optional: put any configuration you want to execute after helm-rg is loaded
)

(use-package fzf
  :bind
    ;; Don't forget to set keybinds!
  :config
  (setq fzf/args "-x --color bw --print-query --margin=1,0 --no-hscroll"
        fzf/executable "fzf"
        fzf/git-grep-args "-i --line-number %s"
        ;; command used for `fzf-grep-*` functions
        ;; example usage for ripgrep:
        ;; fzf/grep-command "rg --no-heading -nH"
        fzf/grep-command "grep -nrH"
        ;; If nil, the fzf buffer will appear at the top of the window
        fzf/position-bottom t
        fzf/window-height 15))

(use-package flycheck
  :ensure t
  :defer t
  :diminish
  :init (global-flycheck-mode))

(use-package ivy
  :bind
  ;; ivy-resume resumes the last Ivy-based completion.
  (("C-c C-r" . ivy-resume)
   ("C-x B" . ivy-switch-buffer-other-window))
  :custom
  (setq ivy-use-virtual-buffers t)
  (setq ivy-count-format "(%d/%d) ")
  (setq enable-recursive-minibuffers t)
  :diminish
  :config
  (ivy-mode))

(use-package counsel
  :after ivy
  :diminish
  :config (counsel-mode))

(use-package ivy-rich
  :after ivy
  :ensure t
  :init (ivy-rich-mode 1) ;; this gets us descriptions in M-x.
  :custom
  (ivy-virtual-abbreviate 'full
                          ivy-rich-switch-buffer-align-virtual-buffer t
                          ivy-rich-path-style 'abbrev)
  :config
  (ivy-set-display-transformer 'ivy-switch-buffer
                               'ivy-rich-switch-buffer-transformer))

(use-package all-the-icons-ivy-rich
  :ensure t
  :diminish
  :init (all-the-icons-ivy-rich-mode 1))

;; TODO

(use-package toc-org
  :commands toc-org-enable
  :init (add-hook 'org-mode-hook 'toc-org-enable))

(add-hook 'org-mode-hook 'org-indent-mode)
(use-package org-bullets)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

;; ;; Enable electric indent globally
(electric-indent-mode 1)

;; Disable electric indent in org-mode by adding a hook
(add-hook 'org-mode-hook (lambda () (electric-indent-local-mode -1)))
(setq org-edit-src-content-indentation 0)

(require 'org-tempo)

(use-package projectile
  ;;:diminish
  :init
  (projectile-mode +1)
  :config
  (setq projectile-project-search-path '("~"))
)

(use-package which-key
  :init
  (which-key-mode 1)
  :config
  (setq which-key-side-window-location 'bottom
        which-key-sort-order #'which-key-key-order-alpha
        which-key-sort-uppercase-first nil
        which-key-add-column-padding 1
        which-key-max-display-columns nil
        which-key-min-display-lines 6
        which-key-side-window-slot -10
        which-key-side-window-max-height 0.25
        which-key-idle-delay 0.8
        which-key-max-description-length 25
        which-key-allow-imprecise-window-fit nil
        which-key-separator " → " ))

(use-package rust-mode)

(use-package terraform-mode
  :ensure t
  :mode (("\\.tf\\'" . terraform-mode)
         ("\\.tf\\.erb\\'" . terraform-mode)))
;;(use-package ruby-mode)
(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-deferred)
  :hook ((python-mode . lsp-deferred)  ;; LSP start automatically for Python
         (rust-mode . lsp-deferred)    ;; And for Rust
         (cc-mode . lsp-deferred)    ;; And for C/C++
         (js-mode . lsp-deferred)        ;; And for JavaScript
         (terraform-mode . lsp-deferred) ;; And for Terraform
         (ruby-mode . lsp-deferred) ;; And for ruby
         ;; Add other major modes that you want LSP to support
         )
  :config
  (setq lsp-enable-symbol-highlighting t)
  (setq lsp-signature-auto-activate nil)
  (setq lsp-auto-guess-root t)
  (setq +format-with-lsp nil)
  (setq lsp-enable-indentation nil)
  (setq lsp-enable-on-type-formatting nil)
)
 ;; You can adjust LSP settings here

(use-package tree-sitter
  :ensure t
  :config
  (global-tree-sitter-mode)
  (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode))
