;;; init-front.el --- Frontend development configuration

;;; Commentary:

;;; Code:

(use-package web-mode
  :mode ("\\.html?\\'" "\\.css\\'" "\\.vue\\'")
  :config
  (setq web-mode-enable-auto-quoting nil))

(use-package rjsx-mode
  :mode "\\.jsx?\\'")

(provide 'init-front)
;;; init-front.el ends here
