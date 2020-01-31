(require 'cl)
(require 'package)
(package-initialize)

;; Add melpa to pull packages
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/"))

(add-to-list 'package-pinned-packages '(cider . "melpa-stable") t)

;; install all packages that will be assumed to be present later
(let* ((package--builtins nil)
       (packages
        '(auto-compile         ; automatically compile Emacs Lisp libraries
          company              ; Modular text completion framework
          color-theme-sanityinc-tomorrow ; purcell color theme
          drag-stuff           ; Drag stuff around in Emacs
          focus                ; Dim color of text in surrounding sections
          idle-require         ; load elisp libraries while Emacs is idle
          git-gutter-fringe    ; Fringe version of git-gutter.el
          golden-ratio         ; Automatic resizing windows to golden ratio
          helm                 ; Incremental and narrowing framework
          helm-ag              ; the silver searcher with helm interface
          helm-company         ; Helm interface for company-mode
          helm-dash            ; Offline documentation using Dash docsets.
          helm-projectile      ; Helm integration for Projectile
          helm-swoop           ; Efficiently hopping squeezed lines
          magit                ; control Git from Emacs
          markdown-mode        ; Emacs Major mode for Markdown-formatted files
          material-theme       ; A Theme based on Google Material Design
          multiple-cursors     ; Multiple cursors for Emacs
          olivetti             ; Minor mode for a nice writing environment
          org                  ; Outline-based notes management and organizer
          org-ref              ; citations bibliographies in org-mode
          pdf-tools            ; Emacs support library for PDF files
          projectile           ; projectile ??
          use-package          ;
          try                  ; Try out Emacs packages
          which-key)))         ; Display available keybindings in popup
  (ignore-errors ;; This package is only relevant for Mac OS X.
    (when (memq window-system '(mac ns))
      (push 'exec-path-from-shell packages)
      (push 'reveal-in-osx-finder packages))
    (let ((packages (remove-if 'package-installed-p packages)))
      (when packages
        ;; Install uninstalled packages
        (package-refresh-contents)
        (mapc 'package-install packages)))))

;; mac specific modifications
;; includes environemnt variables form the shell
;; reset meta key to command key
(when (memq window-system '(mac ns))
  (setq ns-pop-up-frames nil
        mac-option-modifier nil
        mac-command-modifier 'meta
        x-select-enable-clipboard t)
  (exec-path-from-shell-initialize)
  (when (fboundp 'mac-auto-operator-composition-mode)
    (mac-auto-operator-composition-mode 1)))'

;; idle-require saves requirement loading until emacs has down time 
(require 'idle-require)             ; Need in order to use idle-require

(dolist (feature
         '(auto-compile             ; auto-compile .el files
           ox-latex                 ; the latex-exporter (from org)
           ox-md                    ; Markdown exporter (from org)
           recentf                  ; recently opened files
           tex-mode))               ; TeX, LaTeX, and SliTeX mode commands
  (idle-require feature))

(setq idle-require-idle-delay 5)
(idle-require-mode 1)

;;;;;;;;;;;;;;;;;;;;;;;;
;;;; customizations ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;
(setq auto-revert-interval 1            ; Refresh buffers fast
      custom-file (make-temp-file "")   ; Discard customization's
      default-input-method "TeX"        ; Use TeX when toggling input method
      echo-keystrokes 0.1               ; Show keystrokes asap
      recentf-max-saved-items 100       ; Show more recent files
      ring-bell-function 'ignore        ; Quiet
      sentence-end-double-space nil)    ; No double space
;; Some mac-bindings interfere with Emacs bindings.
(when (boundp 'mac-pass-command-to-system)
  (setq mac-pass-command-to-system nil))

;; set local buffer variable defaults
(setq-default fill-column 79                    ; Maximum line width
              indent-tabs-mode nil              ; Use spaces instead of tabs
	      scroll-preserve-screen-position 'always ;
	      save-interprogram-paste-before-kill t  ; rotate through kill-ring
              split-width-threshold 160         ; Split verticly by default
              split-height-threshold nil        ; Split verticly by default
              auto-fill-function 'do-auto-fill) ; Auto-fill-mode everywhere

;; allow 'y'/'n' instead of 'yes'/'no'
(fset 'yes-or-no-p 'y-or-n-p)

;; move all emacs autosaves to /.emacs.d directory
(defvar emacs-autosave-directory
  (concat user-emacs-directory "autosaves/")
  "This variable dictates where to put auto saves. It is set to a
  directory called autosaves located wherever your .emacs.d/ is
  located.")

;; Sets all files to be backed up and auto saved in a single directory.
(setq backup-directory-alist
      `((".*" . ,emacs-autosave-directory))
      auto-save-file-name-transforms
      `((".*" ,emacs-autosave-directory t)))


(set-language-environment "UTF-8")
(add-hook 'doc-view-mode-hook 'auto-revert-mode)

;;;;;;;;;;;;;;;;;;;;;;
;;;; Modes ;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;
(dolist (mode
         '(tool-bar-mode                ; No toolbars, more room for text
           scroll-bar-mode))              ; No scroll bars either
  (funcall mode 0))

(dolist (mode
         '(column-number-mode           ; Show column number in mode line
           delete-selection-mode        ; Replace selected text
           dirtrack-mode                ; directory tracking in *shell*
           drag-stuff-global-mode       ; Drag stuff around
           global-company-mode          ; Auto-completion everywhere
           global-git-gutter-mode       ; Show changes latest commit
           global-prettify-symbols-mode ; Greek letters should look greek
           recentf-mode                 ; Recently opened files
           show-paren-mode              ; Highlight matching parentheses
           which-key-mode))             ; Available keybindings in popup
  (funcall mode 1))

(when (version< emacs-version "24.4")
  (eval-after-load 'auto-compile
    '((auto-compile-on-save-mode 1))))  ; compile .el files on save

;;;;;;;;;;;;;;;;;;;
;;; visuals ;;;;;;;
;;;;;;;;;;;;;;;;;;;
(require 'color-theme-sanityinc-tomorrow)

(color-theme-sanityinc-tomorrow--define-theme night)

(cond ((member "Hasklig" (font-family-list))
       (set-face-attribute 'default nil :font "Hasklig-14"))
      ((member "Inconsolata" (font-family-list))
       (set-face-attribute 'default nil :font "Inconsolata-14")))

;; consider 'git-gutter which is more customizable and works in defferent modes
(require 'git-gutter-fringe)

(dolist (p '((git-gutter:added    . "#0c0")
             (git-gutter:deleted  . "#c00")
             (git-gutter:modified . "#c0c")))
  (set-face-foreground (car p) (cdr p))
  (set-face-background (car p) (cdr p)))

;; pretty greek symbols
(setq-default prettify-symbols-alist '(("lambda" . ?λ)
                                       ("delta" . ?Δ)
                                       ("gamma" . ?Γ)
                                       ("phi" . ?φ)
                                       ("psi" . ?ψ)))

;;;;;;
;; PDF
;; takes a few seconds to load, but only does so on the first one
(add-hook 'pdf-tools-enabled-hook 'auto-revert-mode)
(add-to-list 'auto-mode-alist '("\\.pdf\\'" . pdf-tools-install))

;;;;;;
;; company instead of auto-complete
;; TODO : explore auto-complete
(setq company-idle-delay 0
      company-echo-delay 0
      company-dabbrev-downcase nil
      company-minimum-prefix-length 2
      company-selection-wrap-around t
      company-transformers '(company-sort-by-occurrence
                             company-sort-by-backend-importance))

;;;;;
;; Helm
(require 'helm)
(require 'helm-config)

(setq helm-split-window-in-side-p t
      helm-M-x-fuzzy-match t
      helm-buffers-fuzzy-matching t
      helm-recentf-fuzzy-match t
      helm-move-to-line-cycle-in-source t
      projectile-completion-system 'helm)

(when (executable-find "ack")
  (setq helm-grep-default-command
        "ack -Hn --no-group --no-color %e %p %f"
        helm-grep-default-recurse-command
        "ack -H --no-group --no-color %e %p %f"))

(set-face-attribute 'helm-selection nil :background "cyan")

(helm-mode 1)
(helm-projectile-on)
(helm-adaptive-mode 1)

;;;;;
;; Calendar
;; Show week numbers in calendar
(defun calendar-show-week (arg)
  "Displaying week number in calendar-mode."
  (interactive "P")
  (copy-face font-lock-constant-face 'calendar-iso-week-face)
  (set-face-attribute
   'calendar-iso-week-face nil :height 0.7)
  (setq calendar-intermonth-text
        (and arg
             '(propertize
               (format
                "%2d"
                (car (calendar-iso-from-absolute
                      (calendar-absolute-from-gregorian
                       (list month day year)))))
               'font-lock-face 'calendar-iso-week-face))))

(calendar-show-week t)

;;;;;
;; Flyspell

;; on the fly spellcheck enables whenever in text mode
(add-hook 'text-mode-hook 'turn-on-flyspell)

;; spell check in comments and strings for code
(add-hook 'prog-mode-hook 'flyspell-prog-mode)

(defadvice turn-on-flyspell (before check nil activate)
  "Turns on flyspell only if a spell-checking tool is installed."
  (when (executable-find ispell-program-name)))
(defadvice flyspell-prog-mode (before check nil activate)
  "Turns on flyspell only if a spell-checking tool is installed."
  (when (executable-find ispell-program-name)))

;;;;; Org
(setq org-src-fontify-natively t
      org-src-tab-acts-natively t
      org-confirm-babel-evaluate nil
      org-edit-src-content-indentation 0)

(require 'org)

;; set key for agenda
(global-set-key (kbd "C-c a") 'org-agenda)

;;file to save todo items
(setq org-agenda-files (quote ("/Users/cblackburn/tracking/todo.org")))

;;set priority range from A to C with default A
(setq org-highest-priority ?A)
(setq org-lowest-priority ?C)
(setq org-default-priority ?A)

;;set colours for priorities
(setq org-priority-faces '((?A . (:foreground "LightSteelBlue" :weight bold))
                           (?B . (:foreground "#F0DFAF"))
                           (?C . (:foreground "OliveDrab"))))

;;open agenda in current window
(setq org-agenda-window-setup (quote current-window))

;;capture todo items using C-c c t
(define-key global-map (kbd "C-c c") 'org-capture)
(setq org-capture-templates
      '(("t" "todo" entry (file+headline "/Users/cblackburn/tracking/todo.org" "Tasks")
         "* TODO [#A] %?")))

;; automatically set todo items with current day's scheduled date
(setq org-capture-templates
      '(("t" "todo" entry (file+headline "/Users/cblackburn/tracking/todo.org" "Tasks")
         "* TODO [#A] %?\nSCHEDULED: %(org-insert-time-stamp (org-read-date nil t \"+0d\"))\n")))

;; set diary file to calendar. integrate cal to agenda
(setq diary-file "/Users/cblackburn/tracking/cal")
(setq org-agenda-include-diary t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Interactive functions;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; remember to use these

(defun jump-to-symbol-internal (&optional backwardp)
  "Jumps to the next symbol near the point if such a symbol
exists. If BACKWARDP is non-nil it jumps backward."
  (let* ((point (point))
         (bounds (find-tag-default-bounds))
         (beg (car bounds)) (end (cdr bounds))
         (str (isearch-symbol-regexp (find-tag-default)))
         (search (if backwardp 'search-backward-regexp
                   'search-forward-regexp)))
    (goto-char (if backwardp beg end))
    (funcall search str nil t)
    (cond ((<= beg (point) end) (goto-char point))
          (backwardp (forward-char (- point beg)))
          (t  (backward-char (- end point))))))

(defun jump-to-previous-like-this ()
  "Jumps to the previous occurrence of the symbol at point."
  (interactive)
  (jump-to-symbol-internal t))

(defun jump-to-next-like-this ()
  "Jumps to the next occurrence of the symbol at point."
  (interactive)
  (jump-to-symbol-internal))

(defun duplicate-thing (comment)
  "Duplicates the current line, or the region if active. If an argument is
given, the duplicated region will be commented out."
  (interactive "P")
  (save-excursion
    (let ((start (if (region-active-p) (region-beginning) (point-at-bol)))
          (end   (if (region-active-p) (region-end) (point-at-eol))))
      (goto-char end)
      (unless (region-active-p)
        (newline))
      (insert (buffer-substring start end))
      (when comment (comment-region start end)))))

(defun tidy ()
  "Ident, untabify and unwhitespacify current buffer, or region if active."
  (interactive)
  (let ((beg (if (region-active-p) (region-beginning) (point-min)))
        (end (if (region-active-p) (region-end) (point-max))))
    (indent-region beg end)
    (whitespace-cleanup)
    (untabify beg (if (< end (point-max)) end (point-max)))))

;; jump between tex and pdf in org-mode
(defun org-sync-pdf ()
  (interactive)
  (let ((headline (nth 4 (org-heading-components)))
        (pdf (concat (file-name-base (buffer-name)) ".pdf")))
    (when (file-exists-p pdf)
      (find-file-other-window pdf)
      (pdf-links-action-perform
       (cl-find headline (pdf-info-outline pdf)
                :key (lambda (alist) (cdr (assoc 'title alist)))
                :test 'string-equal)))))

;; global scale mode to increase/decrease text size
(lexical-let* ((default (face-attribute 'default :height))
               (size default))

  (defun global-scale-default ()
    (interactive)
    (setq size default)
    (global-scale-internal size))

  (defun global-scale-up ()
    (interactive)
    (global-scale-internal (incf size 20)))

  (defun global-scale-down ()
    (interactive)
    (global-scale-internal (decf size 20)))

  (defun global-scale-internal (arg)
    (set-face-attribute 'default (selected-frame) :height arg)
    (set-temporary-overlay-map
     (let ((map (make-sparse-keymap)))
       (define-key map (kbd "C-=") 'global-scale-up)
       (define-key map (kbd "C-+") 'global-scale-up)
       (define-key map (kbd "C--") 'global-scale-down)
       (define-key map (kbd "C-0") 'global-scale-default) map))))

;;----------------------------------------------------------------------------
;; Delete the current file
;;----------------------------------------------------------------------------
(defun delete-this-file ()
  "Delete the current file, and kill the buffer."
  (interactive)
  (unless (buffer-file-name)
    (error "No file is currently being edited"))
  (when (yes-or-no-p (format "Really delete '%s'?"
                             (file-name-nondirectory buffer-file-name)))
    (delete-file (buffer-file-name))
    (kill-this-buffer)))

;;----------------------------------------------------------------------------
;; Rename the current file
;;----------------------------------------------------------------------------
(defun rename-this-file-and-buffer (new-name)
  "Renames both current buffer and file it's visiting to NEW-NAME."
  (interactive "sNew name: ")
  (let ((name (buffer-name))
        (filename (buffer-file-name)))
    (unless filename
      (error "Buffer '%s' is not visiting a file!" name))
    (progn
      (when (file-exists-p filename)
        (rename-file filename new-name 1))
      (set-visited-file-name new-name)
      (rename-buffer new-name))))


;;;;;
;; LaTex
(add-to-list 'auto-mode-alist '("\\.tex\\'" . latex-mode))

(setq-default bibtex-dialect 'biblatex)

(eval-after-load 'org
  '(add-to-list 'org-latex-packages-alist '("" "minted")))
(setq org-latex-listings 'minted)

(eval-after-load 'tex-mode
  '(setcar (cdr (cddaar tex-compile-commands)) " -shell-escape "))

(eval-after-load 'ox-latex
  '(setq org-latex-pdf-process
         '("latexmk -pdflatex='pdflatex -shell-escape -interaction nonstopmode' -pdf -f %f")))

;;-----------------------------------------
;; platformIO mode
;;-----------------------------------------

;; 11/23/19
;; platformio only runs if .ini is in root, but defaults root to .git base
;; instead of the actually directory ...
;; try to reconfig projectile to fix?
(use-package projectile
  :ensure t
  :defer 2
  :config
  (projectile-mode)
  (use-package helm-projectile
    :ensure t
    :bind ("C-c p h")
    :config (helm-projectile-on)))

(require 'platformio-mode)

;; Add the required company backend.
(add-to-list 'company-backends 'company-irony)

(add-to-list 'projectile-project-root-files "platformio.ini")

;; Enable irony for all c++ files, and platformio-mode only
;; when needed (platformio.ini present in project root).
(add-hook 'c++-mode-hook (lambda ()
                           (irony-mode)
                           (irony-eldoc)
                           (platformio-conditionally-enable)))

;; Use irony's completion functions.
(add-hook 'irony-mode-hook
          (lambda ()
            (define-key irony-mode-map [remap completion-at-point]
              'irony-completion-at-point-async)

            (define-key irony-mode-map [remap complete-symbol]
              'irony-completion-at-point-async)

            (irony-cdb-autosetup-compile-options)))
            
;; Setup irony for flycheck.
(add-hook 'flycheck-mode-hook 'flycheck-irony-setup)

;;;;;
;; markdown
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))

(defun insert-markdown-inline-math-block ()
  "Inserts an empty math-block if no region is active, otherwise wrap a
math-block around the region."
  (interactive)
  (let* ((beg (region-beginning))
         (end (region-end))
         (body (if (region-active-p) (buffer-substring beg end) "")))
    (when (region-active-p)
      (delete-region beg end))
    (insert (concat "$math$ " body " $/math$"))
    (search-backward " $/math$")))

(add-hook 'markdown-mode-hook
          (lambda ()
            (auto-fill-mode 0)
            (visual-line-mode 1)
            (local-set-key (kbd "C-c b") 'insert-markdown-inline-math-block)) t)

;;;;;;;;;;;;;;;;;;;;;;
;;;; key bindings ;;;;
;;;;;;;;;;;;;;;;;;;;;;
(defvar custom-bindings-map (make-keymap)
  "A keymap for custom bindings.")

; expand-region
(define-key custom-bindings-map (kbd "C->")  'er/expand-region)
(define-key custom-bindings-map (kbd "C-<")  'er/contract-region)

; mulitple-cursors
(define-key custom-bindings-map (kbd "C-c e")  'mc/edit-lines)
(define-key custom-bindings-map (kbd "C-c a")  'mc/mark-all-like-this)
(define-key custom-bindings-map (kbd "C-c n")  'mc/mark-next-like-this)

; magit
(define-key custom-bindings-map (kbd "C-c m") 'magit-status)

; company
(define-key company-active-map (kbd "C-d") 'company-show-doc-buffer)
(define-key company-active-map (kbd "C-n") 'company-select-next)
(define-key company-active-map (kbd "C-p") 'company-select-previous)
(define-key company-active-map (kbd "<tab>") 'company-complete)

; helm
(define-key company-mode-map (kbd "C-:") 'helm-company)
(define-key company-active-map (kbd "C-:") 'helm-company)

(define-key custom-bindings-map (kbd "C-c h")   'helm-command-prefix)
(define-key custom-bindings-map (kbd "M-x")     'helm-M-x)
(define-key custom-bindings-map (kbd "M-y")     'helm-show-kill-ring)
(define-key custom-bindings-map (kbd "C-x b")   'helm-mini)
(define-key custom-bindings-map (kbd "C-x C-f") 'helm-find-files)
(define-key custom-bindings-map (kbd "C-c h d") 'helm-dash-at-point)
(define-key custom-bindings-map (kbd "C-c h o") 'helm-occur)
(define-key custom-bindings-map (kbd "C-c h g") 'helm-google-suggest)
(define-key custom-bindings-map (kbd "M-i")     'helm-swoop)
(define-key custom-bindings-map (kbd "M-I")     'helm-multi-swoop-all)

(define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action)
(define-key helm-map (kbd "C-i")   'helm-execute-persistent-action)
(define-key helm-map (kbd "C-z")   'helm-select-action)

; built-in
(define-key custom-bindings-map (kbd "M-u")         'upcase-dwim)
(define-key custom-bindings-map (kbd "M-c")         'capitalize-dwim)
(define-key custom-bindings-map (kbd "M-l")         'downcase-dwim)
(define-key custom-bindings-map (kbd "M-]")         'other-frame)
(define-key custom-bindings-map (kbd "C-j")         'newline-and-indent)
(define-key custom-bindings-map (kbd "C-c s")       'ispell-word)
(define-key custom-bindings-map (kbd "C-c c")       'org-capture)
(define-key custom-bindings-map (kbd "C-c <up>")    'windmove-up)
(define-key custom-bindings-map (kbd "C-c <down>")  'windmove-down)
(define-key custom-bindings-map (kbd "C-c <left>")  'windmove-left)
(define-key custom-bindings-map (kbd "C-c <right>") 'windmove-right)
(define-key custom-bindings-map (kbd "C-c t")
  (lambda () (interactive) (org-agenda nil "n")))

; custom functions
(define-key global-map          (kbd "M-p")     'jump-to-previous-like-this)
(define-key global-map          (kbd "M-n")     'jump-to-next-like-this)
(define-key custom-bindings-map (kbd "M-,")     'jump-to-previous-like-this)
(define-key custom-bindings-map (kbd "M-.")     'jump-to-next-like-this)
(define-key custom-bindings-map (kbd "C-c C-0") 'global-scale-default)
(define-key custom-bindings-map (kbd "C-c C-=") 'global-scale-up)
(define-key custom-bindings-map (kbd "C-c C-+") 'global-scale-up)
(define-key custom-bindings-map (kbd "C-c C--") 'global-scale-down)
(define-key custom-bindings-map (kbd "C-c j")   'cycle-spacing-delete-newlines)
(define-key custom-bindings-map (kbd "C-c d")   'duplicate-thing)
(define-key custom-bindings-map (kbd "<C-tab>") 'tidy)
(define-key custom-bindings-map (kbd "M-§")     'toggle-shell)
(define-key custom-bindings-map (kbd "C-c C-q")
  '(lambda ()
     (interactive)
     (focus-mode 1)
     (focus-read-only-mode 1)))
(with-eval-after-load 'org
  (define-key org-mode-map (kbd "C-'") 'org-sync-pdf))

(define-minor-mode custom-bindings-mode
  "A mode that activates custom-bindings."
  t nil custom-bindings-map)

