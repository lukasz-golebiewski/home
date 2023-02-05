;;; init-rust.el -- Initialize packages used for Rust development

;;; Commentary:

;;; Code:
(use-package rust-mode)
(add-hook 'rust-mode-hook #'lsp)

(provide 'init-rust)
;;; init-rust.el ends here
