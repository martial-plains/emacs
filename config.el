(add-to-list 'load-path "~/.config/emacs/scripts/")

(setq native-comp-async-report-warnings-errors nil)

(require 'elpaca-setup)  ;; The Elpaca Package Manager
(require 'buffer-move)   ;; Buffer-move for better window management
(require 'utils)

(setq user-full-name "AIH"
      user-mail-address "a.i.harvey@icloud.com")

(setq-default
 delete-by-moving-to-trash t                      ; Delete files to trash
 window-combination-resize t                      ; take new window space from all other windows (not just current)
 x-stretch-cursor t)                              ; Stretch cursor to the glyph width

(display-time-mode 1)                             ; Enable time in the mode-line
(global-subword-mode 1)                           ; Iterate through CamelCase words

(require 'battery)
(if (and battery-status-function
         (not (equal (alist-get ?L (funcall battery-status-function))
                     "N/A")))
    (prin1-to-string `(display-battery-mode 1))
  "")

(display-battery-mode 1)

(if (and (eq system-type 'darwin) (not (is-in-terminal)))
    (menu-bar-mode t)  ; Activate the menubar spell
  (menu-bar-mode -1)) ; Conceal it from mere mortals

(tool-bar-mode -1) ; Vanquish the toolbar dragons

(scroll-bar-mode -1) ; Hush, sweet scrollbar nymphs!

(if (is-in-terminal)
    (xterm-mouse-mode 1))

(if (is-in-terminal)
    (use-package xclip
      :init (xclip-mode 1)))

(setq evil-vsplit-window-right t
      evil-split-window-below t)

(defun prompt-for-buffer--prompt-for-buffer-around (&rest _)
  (with-eval-after-load '(evil-window-split evil-window-vsplit)
    (consult-buffer)))

(advice-add 'prompt-for-buffer :after #'prompt-for-buffer-prompt-for-buffer-around)

(with-eval-after-load 'general
  (with-eval-after-load 'evil
    ;; setup up 'SPC' as the global leader key
    (general-create-definer aih/leader-keys
      :states '(normal insert virtual emacs)
      :keymaps 'override
      :prefix "SPC" ;; set leader
      :global-prefix "M-SPC") ;; access leader in insert mode

    (aih/leader-keys
      "w" '(:ignore t :wk "Windows")
      "w q" '(evil-window-delete :wk "Close window")
      "w n" '(evil-window-new :wk "New window")
      ;; Resizing
      "w +" '(enlarge-window :wk "Increase window height")
      "w -" '(shrink-window :wk "Increase window height")
      ;; Navigation
      "w h" '(evil-window-left :wk "Window left")
      "w j" '(evil-window-down :wk "Window down")
      "w k" '(evil-window-up :wk "Window up")
      "w l" '(evil-window-right :wk "Window right")
      "w w" '(evil-window-next :wk "Goto next window")
      ;; Splitting Windows
      "w s" '(evil-window-split :wk "Horizontal split window")
      "w v" '(evil-window-vsplit :wk "Vertical split window")
      ;; Swapping Windows
      "w H" '(buf-move-left :wk "Buffer move left")
      "w J" '(buf-move-down :wk "Buffer move down")
      "w K" '(buf-move-up :wk "Buffer move up")
      "w L" '(buf-move-right :wk "Buffer move right"))))

(global-display-line-numbers-mode 1)
(global-visual-line-mode t)

(set-frame-parameter nil 'alpha-background 100)
(add-to-list 'default-frame-alist '(alpha-background . 100))

(defun set-transparency (alpha)
  "Set the transparency of the current frame."
  (interactive "nEnter transparency percentage (0-100): ")
  (let* ((active-alpha (or (cdr (assq 'alpha (frame-parameters))) 100))
         (new-alpha (cons alpha alpha)))
    (set-frame-parameter nil 'alpha new-alpha)
    (message "Transparency set to %d%%" alpha)))

(with-eval-after-load 'general
  (general-evil-setup)
  (general-nmap
    :prefix "SPC"
    :wk "Toggle Transparency"
    "c t" 'set-transparency))

(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "<C-wheel-up>") 'text-scale-increase)
(global-set-key (kbd "<C-wheel-down>") 'text-scale-decrease)

(use-package evil
  :init         ;; tweak evil's configuration before loading it
  (setq evil-want-integration t) ;; This is optional since it's already set to true
  (setq evil-want-keybinding nil)
  (setq evil-vsplit-window-right t)
  (setq evil-split-window-below t)
  (evil-mode))

(use-package evil-collection
  :after evil
  :config
  (setq evil-collection-mode-list '(dashboard dired ibuffer))
  (evil-collection-init))

(use-package evil-surround
  :ensure t
  :config
  (global-evil-surround-mode 1))

(use-package evil-commentary
  :init (evil-commentary-mode))

(use-package evil-easymotion
  :config
  (evilem-default-keybindings "SPC"))

(use-package evil-tutor)

;; Turns off elpaca-use-package-mode current declaration
;; Note this will cause the declaration to be interpreted immediately (not deferred).
;; Useful for configuring built-in emacs features.
(use-package emacs :ensure nil :config (setq ring-bell-function #'ignore))

;; Don't install anything. Defer execution of BODY
(elpaca nil (message "deferred"))

;; Display the cursor correctly in the terminal (because even cursors deserve respect)
(if (is-in-terminal)
    (use-package evil-terminal-cursor-changer
      :init(evil-terminal-cursor-changer-activate))) ; or (etcc-on)

(use-package counsel
  :after ivy
  :config (counsel-mode))

(use-package ivy
  :bind
  ;; ivy-resume resumes the last Ivy-based completion.
  (("C-c C-r" . ivy-resume)
   ("C-x B" . ivy-switch-buffer-other-window))
  :custom
  (setq ivy-use-virtual-buffers t)
  (setq ivy-count-format "(%d/%d) ")
  (setq enable-recursive-minibuffers t)
  :config
  (ivy-mode))

(use-package all-the-icons-ivy-rich
  :ensure t
  :init (all-the-icons-ivy-rich-mode 1))

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

(use-package flycheck
  :hook ('after-init-hook #'global-flycheck-mode))

(setq backup-directory-alist `((".*" . ,temporary-file-directory))
      backup-by-copying t    ; Don't delink hardlinks (because hardlinks are like codependent
      version-control t      ; Use version numbers on backups (because even code deserves a sequel
      delete-old-versions t  ; Automatically delete excess backups (because clutter is the enemy
      kept-new-versions 20   ; How many of the newest versions to keep (because history is a bestseller
      kept-old-versions 5    ; And how many of the old (because vintage code is timeless
      )

(set-face-attribute 'default nil
                    :font "Cascadia Code"
                    :height 110
                    :weight 'medium)
(set-face-attribute 'variable-pitch nil
                    :font "Courier New"
                    :height 120
                    :weight 'medium)
(set-face-attribute 'fixed-pitch nil
                    :font "Cascadia Code"
                    :height 110
                    :weight 'medium)
;; Makes commented text and keywords italics.
;; This is working in emacsclient but not emacs.
;; Your font must have an italic face available.
(set-face-attribute 'font-lock-comment-face nil
                    :slant 'italic)
(set-face-attribute 'font-lock-keyword-face nil
                    :slant 'italic)

;; This sets the default font on all graphical frames created after restarting Emacs.
;; Does the same thing as 'set-face-attribute default' above, but emacsclient fonts
;; are not right unless I also add this method of setting the default font.
(add-to-list 'default-frame-alist '(font . "Cascadia Code"))

;; Uncomment the following line if line spacing needs adjusting.
(setq-default line-spacing 0.12)

(defvar +emoji-rx
  (let (emojis)
    (map-char-table
     (lambda (char set)
       (when (eq set 'emoji)
         (push (copy-tree char) emojis)))
     char-script-table)
    (rx-to-string `(any ,@emojis)))
  "A regexp to find all emoji-script characters.")

(setq emoji-alternate-names
      '(("🙂" ":)")
        ("😄" ":D")
        ("😉" ";)")
        ("🙁" ":(")
        ("😆" "laughing face" "xD")
        ("🤣" "ROFL face")
        ("😢" ":'(")
        ("🥲" ":')")
        ("😮" ":o")
        ("😑" ":|")
        ("😎" "cool face")
        ("🤪" "goofy face")
        ("🤥" "pinnochio face" "liar face")
        ("😠" ">:(")
        ("😡" "angry+ face")
        ("🤬" "swearing face")
        ("🤢" "sick face")
        ("😈" "smiling imp")
        ("👿" "frowning imp")
        ("❤️" "<3")
        ("🫡" "o7")
        ("👍" "+1")
        ("👎" "-1")
        ("👈" "left")
        ("👉" "right")
        ("👆" "up")
        ("💯" "100")
        ("💸" "flying money")))

(with-eval-after-load 'general
  (when (>= emacs-major-version 29)
    (general-create-definer aih/leader-keys
      :states '(normal insert virtual emacs)
      :keymaps 'override
      :prefix "SPC" ;; set leader
      :global-prefix "M-SPC") ;; access leader in insert mode
    (aih/leader-keys
      "e" '(:ignore t :wk "Emoji")
      "e s" '(emoji-search :wk "Search")
      "e r" '(emoji-recent :wk "Recent")
      "e l" '(emoji-list :wk "List")
      "e d" '(emoji-describe :wk "Describe")
      "e i" '(emoji-insert :wk "Insert"))
    ))

(use-package dracula-theme
  :ensure t
  :load-path "themes"
  :config
  (load-theme 'dracula t))

(setq display-line-numbers-type 'relative)

(use-package dashboard
  :ensure t
  :init
  (setq initial-buffer-choice 'dashboard-open)
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-file-icons t)
  (setq dashboard-banner-logo-title "Emacs Is More Than A Text Editor!")
  ;; Uncomment the next line if you want the standard Emacs logo as your banner:
  ;; (setq dashboard-startup-banner 'logo)
  ;; Or embrace the official Emacs logo for maximum enchantment:
  (setq dashboard-startup-banner 'official)  
  (setq dashboard-center-content nil) ;; set to 't' for centered content

  ;; Customize your dashboard items – because variety is the spice of startup life:
  (setq dashboard-items '((recents . 5)
                          (agenda . 5 )
                          (bookmarks . 3)
                          (projects . 3)
                          (registers . 3)))
  :custom
  ;; Modify heading icons for that extra dash of flair:
  (dashboard-modify-heading-icons '((recents . "file-text")
                                    (bookmarks . "book")))

  ;; Only invoke the magic if you're not already on a quest (i.e., started with arguments):
  :if (< (length command-line-args) 2)

  ;; And now, let the curtain rise! 🌟
  :config
  (dashboard-setup-startup-hook))

(use-package general
  :config
  (general-evil-setup)

  ;; setup up 'SPC' as the global leader key
  (general-create-definer aih/leader-keys
    :states '(normal insert virtual emacs)
    :keymaps 'override
    :prefix "SPC" ;; set leader
    :global-prefix "M-SPC") ;; access leader in insert mode

  ;; Navigate the code cosmos with finesse:
  (aih/leader-keys
    "f f" '(find-file :wk "Find file")
    "f c" '((lambda () (interactive) (find-file (concat user-emacs-directory "config.org"))) :wk "Edit emacs config")
    "f D" '(find-file :wk "Delete file")
    "f s" '(save-buffer :wk "Save file"))

  ;; Exit gracefully (because even code needs an exit strategy):
  (aih/leader-keys
    "q q" '(save-buffers-kill-terminal :wk "Quit"))

  ;; Comment lines like a poet (because code is poetry, right?):
  (aih/leader-keys
    "TAB TAB" '(comment-line :wk "Comment lines"))

  ;; Buffer ballet – pirouette through buffers:
  (aih/leader-keys
    "b" '(:ignore t :wk "buffer")
    "bb" '(switch-to-buffer :wk "Switch buffer")
    "bk" '(kill-this-buffer :wk "Kill this buffer")
    "bn" '(next-buffer :wk "Next buffer")
    "bp" '(previous-buffer :wk "Previous buffer")
    "br" '(revert-buffer :wk "Revert buffer"))

  ;; Channel your inner sorcerer – evaluate elisp incantations:
  (aih/leader-keys
    "C-e" '(:ignore t :wk "Evaluate")
    "C-e b" '(eval-buffer :wk "Evaluate elisp in buffer")
    "C-e d" '(eval-defun :wk "Evaluate defun containing or after point")
    "C-e e" '(eval-expression :wk "Evaluate and elisp expression")
    "C-e l" '(eval-last-sexp :wk "Evaluate elisp expression before point")
    "C-e r" '(eval-region :wk "Evaluate elisp in region"))

  ;; Seek wisdom from the ancient scrolls (because help is never too far):
  (aih/leader-keys
    "h" '(:ignore t :wk "Help")
    "h f" '(describe-function :wk "Describe function")
    "h v" '(describe-variable :wk "Describe variable")
    ;;"h r r" '((lambda () (interactive) (load-file "~/.config/emacs/init.el")) :wk "Reload emacs config"))
    "h r r" '(reload-init-file :wk "Reload emacs config"))

  ;; Toggle modes like a light switch (because code needs ambiance):
  (aih/leader-keys
    "t" '(:ignore t :wk "Toggle")
    "t l" '(display-line-numbers-mode :wk "Toggle line numbers")
    "t t" '(visual-line-mode :wk "Toggle truncated lines"))

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
        which-key-allow-imprecise-window-fit t
        which-key-separator " → " ))

(use-package magit)

(use-package company 
  :ensure t
  :custom
  (setq company-idle-delay 0.5
        company-minimum-prefix-length 2)
  (setq company-show-numbers t)
  (add-hook 'evil-normal-state-entry-hook #'company-abort)) ;; Make aborting less annoying.

(use-package info-colors
  :commands (info-colors-fontify-node))

(add-hook 'Info-selection-hook 'info-colors-fontify-node)

(use-package doom-modeline
   :ensure t
   :init (doom-modeline-mode 1))

(setq doom-modeline-height 45)

(use-package centaur-tabs
  :demand
  :config
  (centaur-tabs-mode t)
  (setq centaur-tabs-height 36
        centaur-tabs-set-icons t
        centaur-tabs-modified-marker "o"
        centaur-tabs-close-button "×"
        centaur-tabs-set-bar 'above
        centaur-tabs-gray-out-icons 'buffer)
  :bind
  ("C-<prior>" . centaur-tabs-backward)
  ("C-<next>" . centaur-tabs-forward))

(use-package nerd-icons
  ;; :custom
  ;; The Nerd Font you want to use in GUI
  ;; "Symbols Nerd Font Mono" is the default and is recommended
  ;; but you can use any other Nerd Font if you want
  ;; (nerd-icons-font-family "Symbols Nerd Font Mono")
  :config
  (setcdr (assoc "m" nerd-icons-extension-icon-alist)
          (cdr (assoc "matlab" nerd-icons-extension-icon-alist))))

(setq +zen-text-scale 0.8)

(defvar +zen-serif-p t
  "Whether to use a serifed font with `mixed-pitch-mode'.")

;; The value `org-modern-hide-stars' is set to:

(defvar +zen-org-starhide t
  "The value `org-modern-hide-stars' is set to.")

(use-package writeroom-mode
  :config
  (defvar-local +zen--original-org-indent-mode-p nil)
  (defvar-local +zen--original-mixed-pitch-mode-p nil)
  (defun +zen-enable-mixed-pitch-mode-h ()
    "Enable `mixed-pitch-mode' when in `+zen-mixed-pitch-modes'."
    (when (apply #'derived-mode-p +zen-mixed-pitch-modes)
      (if writeroom-mode
          (progn
            (setq +zen--original-mixed-pitch-mode-p mixed-pitch-mode)
            (funcall (if +zen-serif-p #'mixed-pitch-serif-mode #'mixed-pitch-mode) 1))
        (funcall #'mixed-pitch-mode (if +zen--original-mixed-pitch-mode-p 1 -1)))))
  (defun +zen-prose-org-h ()
    "Reformat the current Org buffer appearance for prose."
    (when (eq major-mode 'org-mode)
      (setq display-line-numbers nil
            visual-fill-column-width 60
            org-adapt-indentation nil)
      (when (featurep 'org-modern)
        (setq-local org-modern-star '("🙘" "🙙" "🙚" "🙛")
                    ;; org-modern-star '("🙐" "🙑" "🙒" "🙓" "🙔" "🙕" "🙖" "🙗")
                    org-modern-hide-stars +zen-org-starhide)
        (org-modern-mode -1)
        (org-modern-mode 1))
      (setq
       +zen--original-org-indent-mode-p org-indent-mode)
      (org-indent-mode -1)))
  (defun +zen-nonprose-org-h ()
    "Reverse the effect of `+zen-prose-org'."
    (when (eq major-mode 'org-mode)
      (when (bound-and-true-p org-modern-mode)
        (org-modern-mode -1)
        (org-modern-mode 1))
      (when +zen--original-org-indent-mode-p (org-indent-mode 1))))
  (cl-loop for var in '(display-line-numbers
                     visual-fill-column-width
                     org-adapt-indentation
                     org-modern-mode
                     org-modern-star
                     org-modern-hide-stars)
        do (cl-pushnew var writeroom--local-variables :test #'eq))
  (add-hook 'writeroom-mode-enable-hook #'+zen-prose-org-h)
  (add-hook 'writeroom-mode-disable-hook #'+zen-nonprose-org-h))

(use-package treemacs
  :ensure t
  :defer t
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  (progn
    (setq treemacs-collapse-dirs                   (if treemacs-python-executable 3 0)
          treemacs-deferred-git-apply-delay        0.5
          treemacs-directory-name-transformer      #'identity
          treemacs-display-in-side-window          t
          treemacs-eldoc-display                   'simple
          treemacs-file-event-delay                2000
          treemacs-file-extension-regex            treemacs-last-period-regex-value
          treemacs-file-follow-delay               0.2
          treemacs-file-name-transformer           #'identity
          treemacs-follow-after-init               t
          treemacs-expand-after-init               t
          treemacs-find-workspace-method           'find-for-file-or-pick-first
          treemacs-git-command-pipe                ""
          treemacs-goto-tag-strategy               'refetch-index
          treemacs-header-scroll-indicators        '(nil . "^^^^^^")
          treemacs-hide-dot-git-directory          t
          treemacs-indentation                     2
          treemacs-indentation-string              " "
          treemacs-is-never-other-window           nil
          treemacs-max-git-entries                 5000
          treemacs-missing-project-action          'ask
          treemacs-move-forward-on-expand          nil
          treemacs-no-png-images                   nil
          treemacs-no-delete-other-windows         t
          treemacs-project-follow-cleanup          nil
          treemacs-persist-file                    (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
          treemacs-position                        'left
          treemacs-read-string-input               'from-child-frame
          treemacs-recenter-distance               0.1
          treemacs-recenter-after-file-follow      nil
          treemacs-recenter-after-tag-follow       nil
          treemacs-recenter-after-project-jump     'always
          treemacs-recenter-after-project-expand   'on-distance
          treemacs-litter-directories              '("/node_modules" "/.venv" "/.cask")
          treemacs-project-follow-into-home        nil
          treemacs-show-cursor                     nil
          treemacs-show-hidden-files               t
          treemacs-silent-filewatch                nil
          treemacs-silent-refresh                  nil
          treemacs-sorting                         'alphabetic-asc
          treemacs-select-when-already-in-treemacs 'move-back
          treemacs-space-between-root-nodes        t
          treemacs-tag-follow-cleanup              t
          treemacs-tag-follow-delay                1.5
          treemacs-text-scale                      nil
          treemacs-user-mode-line-format           nil
          treemacs-user-header-line-format         nil
          treemacs-wide-toggle-width               70
          treemacs-width                           35
          treemacs-width-increment                 1
          treemacs-width-is-initially-locked       t
          treemacs-workspace-switch-cleanup        nil)

    ;; The default width and height of the icons is 22 pixels. If you are
    ;; using a Hi-DPI display, uncomment this to double the icon size.
    ;;(treemacs-resize-icons 44)

    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode 'always)
    (when treemacs-python-executable
      (treemacs-git-commit-diff-mode t))

    (pcase (cons (not (null (executable-find "git")))
                 (not (null treemacs-python-executable)))
      (`(t . t)
       (treemacs-git-mode 'deferred))
      (`(t . _)
       (treemacs-git-mode 'simple)))

    (treemacs-hide-gitignored-files-mode nil))
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t d"   . treemacs-select-directory)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))

(use-package treemacs-evil
  :after (treemacs evil)
  :ensure t)

(use-package treemacs-icons-dired
  :hook (dired-mode . treemacs-icons-dired-enable-once)
  :ensure t)

(use-package treemacs-magit
  :after (treemacs magit)
  :ensure t)

(use-package treemacs-persp ;;treemacs-perspective if you use perspective.el vs. persp-mode
  :after (treemacs persp-mode) ;;or perspective vs. persp-mode
  :ensure t
  :config (treemacs-set-scope-type 'Perspectives))

(use-package treemacs-tab-bar ;;treemacs-tab-bar if you use tab-bar-mode
  :after (treemacs)
  :ensure t
  :config (treemacs-set-scope-type 'Tabs))

(use-package rainbow-mode
  :diminish
  :hook org-mode prog-mode)

(use-package rainbow-delimiters
  :hook ((emacs-lisp-mode . rainbow-delimiters-mode)
         (clojure-mode . rainbow-delimiters-mode)))

(use-package perspective
  :custom
  ;; NOTE! I have also set 'SCP =' to open the perspective menu.
  ;; I'm only setting the additional binding because setting it
  ;; helps suppress an annoying warning message.
  (persp-mode-prefix-key (kbd "C-c M-p"))
  :init
  (persp-mode)
  :config
  ;; Sets a file to write to when we save states
  (setq persp-state-default-file "~/.config/emacs/sessions"))

;; This will group buffers by persp-name in ibuffer.
(add-hook 'ibuffer-hook
          (lambda ()
            (persp-ibuffer-set-filter-groups)
            (unless (eq ibuffer-sorting-mode 'alphabetic)
              (ibuffer-do-sort-by-alphabetic))))

;; Automatically save perspective states to file when Emacs exits.
(add-hook 'kill-emacs-hook #'persp-state-save)

(use-package elcord
  :commands elcord-mode
  :config
  (setq elcord-use-major-mode-as-main-icon t))

(defvar +text-mode-left-margin-width 1
  "The `left-margin-width' to be used in `text-mode' buffers.")

(defun +setup-text-mode-left-margin ()
  (when (and (derived-mode-p 'text-mode)
             (not (and (bound-and-true-p visual-fill-column-mode)
                       visual-fill-column-center-text))
             (eq (current-buffer) ; Check current buffer is active.
                 (window-buffer (frame-selected-window))))
    (setq left-margin-width (if display-line-numbers
                                0 +text-mode-left-margin-width))
    (set-window-buffer (get-buffer-window (current-buffer))
                       (current-buffer))))

(add-hook 'window-configuration-change-hook #'+setup-text-mode-left-margin)
(add-hook 'display-line-numbers-mode-hook #'+setup-text-mode-left-margin)
(add-hook 'text-mode-hook #'+setup-text-mode-left-margin)

(remove-hook 'text-mode-hook #'display-line-numbers-mode)

(use-package org-modern
  :hook (org-mode . org-modern-mode)
  :config
  (setq org-modern-star '("◉" "○" "✸" "✿" "✤" "✜" "◆" "▶")
        org-modern-table-vertical 1
        org-modern-table-horizontal 0.2
        org-modern-list '((43 . "➤")
                          (45 . "–")
                          (42 . "•"))
        org-modern-todo-faces
        '(("TODO" :inverse-video t :inherit org-todo)
          ("PROJ" :inverse-video t :inherit +org-todo-project)
          ("STRT" :inverse-video t :inherit +org-todo-active)
          ("[-]"  :inverse-video t :inherit +org-todo-active)
          ("HOLD" :inverse-video t :inherit +org-todo-onhold)
          ("WAIT" :inverse-video t :inherit +org-todo-onhold)
          ("[?]"  :inverse-video t :inherit +org-todo-onhold)
          ("KILL" :inverse-video t :inherit +org-todo-cancel)
          ("NO"   :inverse-video t :inherit +org-todo-cancel))
        org-modern-footnote
        (cons nil (cadr org-script-display))
        org-modern-block-fringe nil
        org-modern-block-name
        '((t . t)
          ("src" "»" "«")
          ("example" "»–" "–«")
          ("quote" "❝" "❞")
          ("export" "⏩" "⏪"))
        org-modern-progress nil
        org-modern-priority nil
        org-modern-horizontal-rule (make-string 36 ?─)
        org-modern-keyword
        '((t . t)
          ("title" . "𝙏")
          ("subtitle" . "𝙩")
          ("author" . "𝘼")
          ("email" . #("" 0 1 (display (raise -0.14))))
          ("date" . "𝘿")
          ("property" . "☸")
          ("options" . "⌥")
          ("startup" . "⏻")
          ("macro" . "𝓜")
          ("bind" . #("" 0 1 (display (raise -0.1))))
          ("bibliography" . "")
          ("print_bibliography" . #("" 0 1 (display (raise -0.1))))
          ("cite_export" . "⮭")
          ("print_glossary" . #("ᴬᶻ" 0 1 (display (raise -0.1))))
          ("glossary_sources" . #("" 0 1 (display (raise -0.14))))
          ("include" . "⇤")
          ("setupfile" . "⇚")
          ("html_head" . "🅷")
          ("html" . "🅗")
          ("latex_class" . "🄻")
          ("latex_class_options" . #("🄻" 1 2 (display (raise -0.14))))
          ("latex_header" . "🅻")
          ("latex_header_extra" . "🅻⁺")
          ("latex" . "🅛")
          ("beamer_theme" . "🄱")
          ("beamer_color_theme" . #("🄱" 1 2 (display (raise -0.12))))
          ("beamer_font_theme" . "🄱𝐀")
          ("beamer_header" . "🅱")
          ("beamer" . "🅑")
          ("attr_latex" . "🄛")
          ("attr_html" . "🄗")
          ("attr_org" . "⒪")
          ("call" . #("" 0 1 (display (raise -0.15))))
          ("name" . "⁍")
          ("header" . "›")
          ("caption" . "☰")
          ("results" . "🠶"))))

(use-package org-ol-tree
  :ensure (:host github
                 :repo "Townk/org-ol-tree")
  :commands org-ol-tree
  :config
  (setq org-ol-tree-ui-icon-set
        (if (and (display-graphic-p)
                 (fboundp 'all-the-icons-material))
            'all-the-icons
          'unicode))
  (org-ol-tree-ui--update-icon-set))

(with-eval-after-load 'general
  (with-eval-after-load 'org
    ;; setup up 'SPC' as the global leader key
    (general-create-definer aih/leader-keys
      :states '(normal insert virtual emacs)
      :keymaps 'override
      :prefix "SPC" ;; set leader
      :global-prefix "M-SPC") ;; access leader in insert mode

    (aih/leader-keys
      "O" '(org-ol-tree :wk "Outline"))))

(use-package org-auto-tangle
  :load-path "site-lisp/org-auto-tangle/"    ;; this line is necessary only if you cloned the repo in your site-lisp directory 
  :defer t
  :hook (org-mode . org-auto-tangle-mode))

(use-package ob-http
  :commands org-babel-execute:http)

(use-package org-transclusion
  :commands org-transclusion-mode
  :init
  (with-eval-after-load 'general
    (with-eval-after-load 'org
      ;; setup up 'SPC' as the global leader key
      (general-create-definer aih/leader-keys
        :states '(normal insert virtual emacs)
        :keymaps 'override
        :prefix "SPC" ;; set leader
        :global-prefix "M-SPC") ;; access leader in insert mode

      (aih/leader-keys
        "<f12>" '(org-transclusion-mode :wk "Transclusion Mode")))))

(use-package org-chef
  :commands (org-chef-insert-recipe org-chef-get-recipe-from-url))

(use-package toc-org
  :commands toc-org-enable
  :init (add-hook 'org-mode-hook 'toc-org-enable))

(add-hook 'org-mode-hook 'org-indent-mode)
(use-package org-bullets)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

(electric-indent-mode -1)

(require 'org-tempo)

(use-package org-remoteimg :ensure (:host github :repo "gaoDean/org-remoteimg"))

;; optional: set this to wherever you want the cache to be stored
;; (setq url-cache-directory "~/.cache/emacs/url")

(setq org-display-remote-inline-images 'cache) ;; enable caching

(setq org-confirm-babel-evaluate nil
      org-src-fontify-natively t
      org-src-tab-acts-natively t)

(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (perl       . t)
   (python     . t)
   (js         . t)
   (css        . t)
   (sass       . t)
   (C          . t)
   (java       . t)
   (shell      . t))
 )

(remove-hook 'text-mode-hook #'visual-line-mode)

(add-hook 'text-mode-hook #'auto-fill-mode)

(cl-defmacro lsp-org-babel-enable (lang)
  "Support LANG in org source code block."
  (setq centaur-lsp 'lsp-mode)
  (cl-check-type lang stringp)
  (let* ((edit-pre (intern (format "org-babel-edit-prep:%s" lang)))
         (intern-pre (intern (format "lsp--%s" (symbol-name edit-pre)))))
    `(progn
       (defun ,intern-pre (info)
         (let ((file-name (->> info caddr (alist-get :file))))
           (unless file-name
             (setq file-name (make-temp-file "babel-lsp-")))
           (setq buffer-file-name file-name)
           (lsp-deferred)))
       (put ',intern-pre 'function-documentation
            (format "Enable lsp-mode in the buffer of org source block (%s)."
                    (upcase ,lang)))
       (if (fboundp ',edit-pre)
           (advice-add ',edit-pre :after ',intern-pre)
         (progn
           (defun ,edit-pre (info)
             (,intern-pre info))
           (put ',edit-pre 'function-documentation
                (format "Prepare local buffer environment for org source block (%s)."
                        (upcase ,lang))))))))
(defvar org-babel-lang-list
  '("go" "python" "ipython" "bash" "sh"))
(dolist (lang org-babel-lang-list)
  (eval `(lsp-org-babel-enable ,lang)))

(use-package lsp-pyright
  :ensure t
  :hook (python-mode . (lambda ()
                         (require 'lsp-pyright)
                         (lsp))))  ; or lsp-deferred

(use-package rustic)

(use-package lsp-sourcekit
  :after lsp-mode
  :config
  (setq lsp-sourcekit-executable (string-trim (shell-command-to-string "xcrun --find sourcekit-lsp"))))

(use-package swift-mode
  :hook (swift-mode . (lambda () (lsp))))
