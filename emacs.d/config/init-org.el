;;; init-org.el -- Initialize org mode

;;; Commentary:

;;; Code:
(use-package org)

(global-set-key "\C-cs" 'org-store-link)
(global-set-key "\C-ci" 'org-insert-link)
(global-set-key "\C-co" 'org-open-at-point)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cc" 'org-capture)
(global-set-key "\C-cb" 'org-iswitchb)

(setq org-directory "~/grive/org")
(setq org-default-notes-file (concat org-directory "/notes.org"))
(setq org-agenda-files '("~/grive/org/agenda"))
(setq org-refile-targets '(
   (nil :maxlevel . 2)              ; refile to headings in the current buffer
   (org-agenda-files :maxlevel . 2) ; refile to any of these files
   ))

;;(setq org-capture-templates
;; '(("t" "Todo" entry (file+headline "~/org/capture.org" "Tasks")
;;    "* TODO %?\n  %i\n  %a")
;;   ("j" "Pyrofex JIRA issues wannabes" entry (file+headline "~/org/pyrofex-jira.org" "JIRA issues")
;;        "* TODO %?\n  %i\n  %a")
;;   ("p" "Pyrofex work" entry (file+datetree "~/org/pyrofex-log.org")
;;        "* %? %U")))
(provide 'init-org)
;;; init-org.el ends here
