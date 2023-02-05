;;; init-evil.el --- Evil mode bindings

;;; Commentary:

;; see no evil

;;; Code:
(use-package evil
  :ensure t
  :init
  (setq evil-want-keybinding nil)
  :config
  (evil-mode 1))
(use-package evil-collection
  :after evil
  :after company
  :ensure t
  :config
  (evil-collection-init)
)
(use-package evil-leader)
(use-package evil-mc)
(global-evil-mc-mode  1) ;; enable

(evil-define-key 'visual evil-mc-key-map
  "A" #'evil-mc-make-cursor-in-visual-selection-end
  "I" #'evil-mc-make-cursor-in-visual-selection-beg)

(global-evil-leader-mode)

(evil-leader/set-leader "<SPC>")
(evil-leader/set-key
  "ff" 'find-file
  "y" 'helm-show-kill-ring
  "u" 'undo-tree-visualize
  "b" 'switch-to-buffer
  "k" 'kill-buffer
  "gb" 'magit-blame
  "gf" 'magit-log-buffer-file ;; Shows history of the current file
  "gt" 'git-timemachine
  "jd" 'dumb-jump-go-prompt
  "hc" 'haskell-cabal-visit-file
  "er" 'eval-region

  "lfr" 'lsp-find-references
  "lfd" 'lsp-find-definition
  "lrn" 'lsp-rename

  "oo" 'org-open-at-point
  "os" 'org-store-link
  "oi" 'org-insert-link
)

;; folds text
(use-package vimish-fold
  :pin melpa
)
(vimish-fold-global-mode 1)
(evil-leader/set-key
  "vf" 'vimish-fold
  "vd" 'vimish-fold-delete
  "vD" 'vimish-fold-delete-all
  "vu" 'vimish-fold-unfold
  "vU" 'vimish-fold-unfold-all
  "vt" 'vimish-fold-toggle
  "vT" 'vimish-fold-toggle-all
)

(use-package evil-iedit-state)
(define-key evil-normal-state-map (kbd "ge") 'evil-iedit-state/iedit-mode)

;;(global-set-key (kbd "C-c l") 'lsp-ui-peek-find-definitions)
;;(global-set-key (kbd "C-c h") 'lsp-ui-peek-jump-backward)

(use-package evil-surround)
(global-evil-surround-mode 1)

(provide 'init-evil)
;;; init-evil.el ends here
