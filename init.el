(setq inhibit-startup-message t)

(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(set-fringe-mode 10)

(menu-bar-mode -1)

(setq visible-bell t)

(setq custom-file (expand-file-name "~/.emacs.d/etc/emacs-custom.el"))
(load custom-file 'noerror)

(set-face-attribute 'default nil :font "Victor Mono" :height 120 :weight 'medium)

(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("org" . "https://orgmode.org/elpa/")
			 ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;(use-package command-log-mode)

(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
	 :map ivy-minibuffer-map
	 ("TAB" . ivy-alt-done)
	 ("C-l" . ivy-alt-done)
	 ("C-j" . ivy-next-line)
	 ("C-k" . ivy-previous-line)
	 :map ivy-switch-buffer-map
	 ("C-k" . ivy-previous-line)
	 ("C-l" . ivy-alt-done)
	 ("C-d" . ivy-switch-buffer-kill)
	 :map ivy-reverse-i-search-map
	 ("C-k" . ivy-previous-line)
	 ("C-d" . ivy-switch-buffer-kill))
  :config
  (ivy-mode 1))

(defvar doom-modeline-icon (display-graphic-p))

(use-package doom-modeline
  :ensure t
  :hook (after-init . doom-modeline-mode)
  :custom ((doom-modeline-height 15)))

(use-package all-the-icons
  :if (display-graphic-p))

(use-package doom-themes
  :ensure t
  :config
  (setq doom-themes-enable-bold t
	doom-themes-enable-italic t)
  (load-theme 'doom-one t)

  (doom-themes-visual-bell-config)

  (doom-themes-neotree-config)

  (setq doom-themes-treemacs-theme "doom-atom")
  (doom-themes-treemacs-config)
  (doom-themes-org-config))

(use-package counsel
 :bind (("C-M-j" . 'counsel-switch-buffer)
        :map minibuffer-local-map
        ("C-r" . 'counsel-minibuffer-history))
 :custom
 (counsel-linux-app-format-function #'counsel-linux-app-format-function-name-only)
 :config
 (counsel-mode 1)
 (setq ivy-initial-inputs-alist nil))

(column-number-mode)

(use-package helpful
 :commands (helpful-callable helpful-variable helpful-command helpful-key)
 :custom
 (counsel-describe-function-function #'helpful-callable)
 (counsel-describe-variable-function #'helpful-variable)
 :bind
 ([remap describe-function]	.	counsel-describe-function)
 ([remap describe-command]	.	helpful-command)
 ([remap describe-variable]	.	counsel-describe-variable)
 ([remap describe-key]		.	helpful-key))


(use-package projectile
 :diminish projectile-mode
 :config (projectile-mode)
 :custom ((projectile-completion-system 'ivy))
 :bind-keymap
 ("C-c p" . projectile-command-map))

(use-package better-defaults)


(use-package lsp-mode
  :init
  (setq lsp-keymap-prefix "C-c l"
        read-process-output-max (* 1024 1024)
        lsp-eldoc-enable-hover nil
        lsp-signature-auto-activate nil
	lsp-headerline-breadcrumb-enable nil
	lsp-lens-enable t
	lsp-signature-auto-activate nil
	company-minimum-prefix-length 1)
  :hook ((clojure-mode       . lsp)
         (prog-mode . lsp)
         (lsp-mode           . lsp-enable-which-key-integration))
  :config
  (setenv "PATH" (concat
                   "/usr/local/bin" path-separator
                   (getenv "PATH")))
  (lsp-enable-which-key-integration t)
  (dolist (m '(clojure-mode
               clojurec-mode
               clojurescript-mode
               clojurex-mode))
    (add-to-list 'lsp-language-id-configuration `(,m . "clojure")))
  :commands (lsp lsp-deferred))

(use-package cider)

(use-package company
  :ensure t
  :after lsp-mode
  :hook (lsp-mode . company-mode)
  :bind (:map company-active-map
         ("TAB" . company-complete-selection)
         :map lsp-mode-map
         ("TAB" . company-indent-or-complete-common))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))

(use-package flycheck
  :config
  (add-hook 'prog-mode-hook 'flycheck-mode) ;; always lint my code
  (add-hook 'after-init-hook #'global-flycheck-mode)
  (setq flycheck-emacs-lisp-load-path 'inherit))

(setq gc-cons-threshold (* 100 1024 1024))

(use-package clojure-mode
  :config
  (defun flexiana-return-and-indent ()
   (interactive)
   (insert-char ?\n)
   (cljstyle))
 (setq clojure-align-forms-automatically t
	clojure-indent-style 'align-arguments)
 :hook
  ((clojure-mode . lsp-semantic-tokens-mode)
   (clojure-mode . (lambda () (modify-syntax-entry ?- "w")))))

(use-package which-key
  :defer 0
  :diminish which-key-mode
  :config
  (which-key-mode)
  (setq which-key-idle-delay 0.3))

(use-package rainbow-delimiters)

(add-hook 'clojurescript-mode-hook 'rainbow-delimiters-mode)
(add-hook 'clojure-mode-hook 'rainbow-delimiters-mode)
(add-hook 'cider-mode-hook 'rainbow-delimiters-mode)
;;(add-hook 'clojure-mode-hook 'lsp-semantic-tokens-mode)
;;(add-hook 'clojurescript-mode-hook 'lsp-semantic-tokens-mode)

(use-package smartparens
  :bind
  (("M-s" . sp-unwrap-sexp)
   ("C-<left>" . sp-backward-slurp-sexp)
   ("C-<right>" . sp-forward-slurp-sexp))
  :hook ((clojure-mode . smartparens-strict-mode)
	 (cider-repl-mode . smartparens-strict-mode)
	 (clojurescript-mode . smartparens-strict-mode)
         (lisp-mode . smartparens-strict-mode)
         (emacs-lisp-mode . smartparens-strict-mode)))

(setq cider-eldoc-display-for-symbol-at-point nil)

(add-hook 'minibuffer-setup-hook 'turn-on-smartparens-strict-mode)

(global-display-line-numbers-mode)

(use-package undo-tree)

(global-undo-tree-mode)

(setq cider-repl-display-in-current-window t)

(setq cider-repl-buffer-size-limit 100000)

;; First install the package:
(use-package flycheck-clj-kondo
  :ensure t)


(add-to-list 'load-path "~/.emacs.d/personal")

(require 'cljstyle-mode)
(require 'ligature)
(require 'restclient)
(require 'carbon-now-sh)
(global-ligature-mode 1)

(global-prettify-symbols-mode 1)

;; (add-hook 'clojure-mode-hook (lambda ()
;;              (mapc (lambda (pair) (push pair prettify-symbols-alist))
;;                    '(("not=" . #x2260)))))

(ligature-set-ligatures
 'prog-mode
 '("www" "**" "***" "**/" "*>" "*/" "\\\\" "\\\\\\" "{-" "::"
   ":::" ":=" "!!" "!=" "!==" "-}" "----" "-->" "->" "->>"
   "-<" "-<<" "-~" "#{" "#[" "##" "###" "####" "#(" "#?" "#_"
   "#_(" ".-" ".=" ".." "..<" "..." "?=" "??" ";;" "/*" "/**"
   "/=" "/==" "/>" "//" "///" "&&" "||" "||=" "|=" "|>" "^=" "$>"
   "++" "+++" "+>" "=:=" "==" "===" "==>" "=>" "=>>" "<="
   "=<<" "=/=" ">-" ">=" ">=>" ">>" ">>-" ">>=" ">>>" "<*"
   "<*>" "<|" "<|>" "<$" "<$>" "<!--" "<-" "<--" "<->" "<+"
   "<+>" "<=" "<==" "<=>" "<=<" "<>" "<<" "<<-" "<<=" "<<<"
   "<~" "<~~" "</" "</>" "~@" "~-" "~>" "~~" "~~>" "%%"))

(use-package lsp-ui
  :hook
  (lsp-mode . lsp-ui-mode)
  :bind
  ([remap xref-find-definitions] . lsp-ui-peek-find-definitions)
  ([remap xref-find-references] . lsp-ui-peek-find-references)
  :custom
  (lsp-ui-doc-position 'bottom))

(use-package magit
  :commands magit-status
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)
  :config
  (setq ediff-window-setup-function 'ediff-setup-windows-plain)) ;;use control buffer instead of control frame for ediff

(global-set-key [remap isearch-forward-regexp] 'swiper)

;; ;; (setq backup-directory-alist
;; ;;       `((".*" . ,(expand-file-name "backups/" dotemacs-cache-directory)))
;; ;;       backup-by-copying t
;; ;;       version-control t
;; ;;       kept-old-versions 0
;; ;;       kept-new-versions 20
;; ;;       delete-old-versions t)

;; ;; (let ((dir (expand-file-name "auto-save/" dotemacs-cache-directory)))
;; ;;   (setq auto-save-list-file-prefix (concat dir "saves-")
;; ;;         auto-save-file-name-transforms `((".*" ,(concat dir "save-") t))))

;;  (defun toggle-transparency ()
;;    (interactive)
;;    (let ((alpha (frame-parameter nil 'alpha)))
;;      (set-frame-parameter
;;       nil 'alpha
;;       (if (eql (cond ((numberp alpha) alpha)
;;                      ((numberp (cdr alpha)) (cdr alpha))
;;                      ;; Also handle undocumented (<active> <inactive>) form.
;;                      ((numberp (cadr alpha)) (cadr alpha)))
;;                100)
;;           '(85 . 50) '(100 . 100)))))

;;  (global-set-key (kbd "C-c t") 'toggle-transparency)

(setq history-length 25)
(savehist-mode 1)

(save-place-mode 1)
(global-auto-revert-mode 1)

(global-set-key (kbd "C-c m") 'magit)

(global-set-key
 (kbd "C-c [")
 (lambda ()
   (interactive)
   (insert "()")
   (backward-char 1)))

(global-set-key
 (kbd "S-<left>")
 (lambda ()
   (interactive)
   (when (buffer-file-name)
     (save-buffer))
   (windmove-left)))

(global-set-key
 (kbd "S-<right>")
 (lambda ()
   (interactive)
   (when (buffer-file-name)
     (save-buffer))
   (windmove-right)))

(global-set-key
 (kbd "S-<up>")
 (lambda ()
   (interactive)
   (when (buffer-file-name)
     (save-buffer))
   (windmove-up)))

(global-set-key
 (kbd "S-<down>")
 (lambda ()
   (interactive)
   (when (buffer-file-name)
     (save-buffer))
   (windmove-down)))


(defun restclient-get-header-from-response (header)
    "Get HEADER from the response buffer of restclient.
HEADER should be just the name of the header, e.g.
  \"content-type\" (it is case insensitive)."
    (let* ((case-fold-search t)
           (search-string (format "// %s: " header))
           (match (string-match search-string
                                (buffer-substring-no-properties (point-min)
                                                                (point-max)))))
      (goto-char match)
      (forward-char (length search-string))
      (buffer-substring-no-properties (point)
                                      (progn
                                        (move-end-of-line 1)
                                        (point)))))

;;(add-to-list 'load-path "~/emacs.d/promela") ; location where you cloned promela-mode
;;(require 'promela-mode)
;;(add-to-list 'auto-mode-alist '("\\.pml\\'" . promela-mode))

(use-package treemacs-all-the-icons
  :if (display-graphic-p))


(add-hook 'clojure-mode-hook #'cljstyle-mode)

(defun my-cljstyle-mode-hook ()
  )
