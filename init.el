;; [TODO] To do this a portable file, it must be put under VCS.
;; Need to ensure the presence of all the packages I need
;; for my setup.
;; Define hooks for certain modes, and init modes and packages
;; considered necessary or common to a variety of projects.

;; Proposal of organization for this init file
;; 1. Whatever emacs adds by default
;; 2. Package ensurance (install if not present)
;; 3. Package customizations
;; 4. Hooks

;; TODO: reset up to manage language IDE support through LSP

;; List of packages required by my setup
(defconst required-package-list
  (list 'magit
	'projectile
	'projectile-rails
	'go-mode
	'go-autocomplete
	'multiple-cursors
	'slim-mode
	'robe
	'company
	'clojure-mode
	'cider
	'which-key
	'avy
	'restclient
	'exec-path-from-shell
	'zeno-theme
	'solarized-theme))

;; Init custom seupt by installing list of specified packages
(defun init-setup (packages)
  ;; (package-refresh-contents) 		; How do we refresh conditionally? 
  (if (not (null (car packages)))
      (progn
	(unless (package-installed-p (car packages))
	  (package-install (car packages)))
	(init-setup (cdr packages)))))

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(when (>= emacs-major-version 24)
  (require 'package)
  (add-to-list
   'package-archives
   ;; '("melpa" . "http://stable.melpa.org/packages/") ; many packages won't show if using stable
   '("melpa" . "https://melpa.org/packages/")
   t))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("c433c87bd4b64b8ba9890e8ed64597ea0f8eb0396f4c9a9e01bd20a04d15d358" "a325ba05dc3b5c2fa89af0ff354bbbe90251fb1a6e6d5682977cebe61ce72ab7" "2809bcb77ad21312897b541134981282dc455ccd7c14d74cc333b6e549b824f3" default)))
 '(max-mini-window-height 10)
 '(package-selected-packages
   (quote
    (go-autocomplete exec-path-from-shell restclient elpy solarized-theme zeno-theme ## avy which-key cider clojure-mode company magit multiple-cursors slim-mode projectile-rails go-mode))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; Install packages required by my setup
(init-setup required-package-list)

;; Requiring this as projectile-rails will show some errors
;; (when using native indexing instead of alien)
;; if this package is not required before its initialization
(require 'subr-x)
;; Init electric-pair-mode upon Emacs startup
(electric-pair-mode +1)

;; Init projectile upon Emacs startup
(projectile-mode +1)
;; native will take into account .projectile files as opposed to alien
;; Consider going back to alien. Seems to be faster. Find a way to ignore
;; files with alien
(setq projectile-indexing-method 'native)
;; Enabling caching to avoid indexing project everytime a search is performed
;; (this happens at least with native indexing)
(setq projectile-enable-caching t)
(define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)

;; Init linecount mode
(when (version<= "26.0.50" emacs-version )
  (global-display-line-numbers-mode))

;; Set keybindings for multiple-cursors
(require 'multiple-cursors)

(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)    (global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)

;; Ruby mode enhancing

;; Prevent Ruby from adding encoding at first line of file
(setq ruby-insert-encoding-magic-comment nil)

;; Robe for intelligent code navigation and completion
(require 'robe)
(add-hook 'ruby-mode-hook 'robe-mode)

;; For completion
(global-company-mode t)

(eval-after-load 'company
  '(push 'company-robe company-backends))

;; Clojure, CIDER mode enhancing

;; Setting this to true to enable sshing into remote hosts to establish connection with
;; an nREPL server.
;; Employed to establish connection with running leiningen repl server running inside vm.
(setq nrepl-use-ssh-fallback-for-remote-hosts t)

;; Make sure to start lein repl in port 36096 in vagrant vm.
;; Otherwise, will fall back to ask for specifics.
(setq cider-known-endpoints
      '(("vagrant" "127.0.0.1" "36096")))

;; Enabling cider mode when clojure mode enabled
(add-hook 'clojure-mode-hook 'cider-mode)

;; Python mode enhancing
;; (defun my/python-mode-hook ()
;;   (add-to-list 'company-backends 'company-jedi))

;; (add-hook 'python-mode-hook 'my/python-mode-hook)

;; Go mode enhancing
;; TODO: enable Guru. Download is failing. Perhaps requires a more recent version than 1.10
(defun set-exec-path-from-shell-PATH ()
  (let ((path-from-shell (replace-regexp-in-string
                          "[ \t\n]*$"
                          ""
                          (shell-command-to-string "$SHELL --login -i -c 'echo $PATH'"))))
    (setenv "PATH" path-from-shell)
    (setq eshell-path-env path-from-shell) ; for eshell users
    (setq exec-path (split-string path-from-shell path-separator))))

(when window-system (set-exec-path-from-shell-PATH))

(setenv "GOPATH" "/Users/htellechea/go")
(add-to-list 'exec-path "/User/htellechea/go/bin")

(defun my-go-mode-hook ()
  ;; Use goimports instead of go-fmt
  (setq gofmt-command "goimports")
  ;; Call Gofmt before saving                                                    
  (add-hook 'before-save-hook 'gofmt-before-save)
  ;; Go oracle 
  (load-file "$GOPATH/src/golang.org/x/tools/cmd/oracle/oracle.el")
  ;; Godef jump key binding                                                      
  (local-set-key (kbd "M-.") 'godef-jump)
  (local-set-key (kbd "M-*") 'pop-tag-mark)
  )

(add-hook 'go-mode-hook 'my-go-mode-hook)

(defun auto-complete-for-go ()
  (auto-complete-mode 1))
(add-hook 'go-mode-hook 'auto-complete-for-go)

(with-eval-after-load 'go-mode
   (require 'go-autocomplete))

;; Enable which-key-mode by default
(require 'which-key)
(which-key-mode)

;; By default, set popup window to appear on the right
(which-key-setup-side-window-right)

;; Set favorite color theme
(load-theme 'zeno t)

