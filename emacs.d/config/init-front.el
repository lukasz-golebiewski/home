;;; init-front.el --- Frontend development configuration

;;; Commentary:

;;; Code:

(use-package web-mode
  :mode ("\\.js\\'" "\\.jsx\\'")
  :config
  (setq web-mode-content-types-alist '(("jsx" . "\\.js[x]?\\'")))
  (setq web-mode-enable-auto-quoting nil)) ;; Prevents automatic insertion of quotes

(use-package rjsx-mode
  :mode "\\.jsx?\\'")

(provide 'init-front)
;;; init-front.el ends here
