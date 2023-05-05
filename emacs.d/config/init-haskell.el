;;; init-haskell.el -- Initialize packages used for Haskell development

;;; Commentary:

;;; Code:
;; if you want to change prefix for lsp-mode keybindings.
(use-package haskell-mode
  :init (setq haskell-stylish-on-save nil)
)

(use-package elm-mode)
(use-package lsp-haskell) ;; add lsp-haskell explicitly or emacs is going to complain

(use-package lsp-mode
  :init
  ;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
  (setq lsp-keymap-prefix "C-c l")
  (setq lsp-file-watch-threshold 2000)
  (setq lsp-enable-on-type-formatting nil)
  :hook (;; replace XXX-mode with concrete major-mode(e. g. python-mode)
         ((haskell-mode elm-mode) . lsp-deferred)
         ;; if you want which-key integration
         (lsp-mode . lsp-enable-which-key-integration))
  :commands lsp-deferred)

;; optionally
(use-package lsp-ui :commands lsp-ui-mode)
;; if you are helm user
(use-package helm-lsp :commands helm-lsp-workspace-symbol)

;; optionally if you want to use debugger
;; (use-package dap-mode)
;; (use-package dap-LANGUAGE) to load the dap adapter for your language

;; optional if you want which-key integration
(use-package which-key
    :config
    (which-key-mode))

;; (use-package flycheck-haskell)
;; (add-hook 'haskell-mode-hook #'flycheck-haskell-setup)

(provide 'init-haskell)
;;; init-haskell.el ends here
