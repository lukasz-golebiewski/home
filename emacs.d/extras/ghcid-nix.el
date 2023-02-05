;; Really basic ghcid+nix+cabal support in emacs with compilation-mode
;; Use M-x ghcid-nix to launch

;;; Requires the following values in .dir.locals
;;;((nil . (
;;;  (eval . (setq nix-shell-default-directory "path/to/dir/with/shell|default.nix"))
;;;  (eval . (setq ghcid-nix-target "path/to/dir/with/cabal/file"))
;;;)))
(require 'term)

(setq ghcid-nix-process-name "ghcid-nix")

(define-minor-mode ghcid-nix-mode
  "A minor mode for ghcid-nix terminals
Use `ghcid-nix' to start a ghcid-nix session in a new buffer. The process
will start in the directory of your current buffer.
It is based on `compilation-mode'. That means the errors and
warnings can be clicked and the `next-error'(\\[next-error]) and
`previous-error'(\\[previous-error]) commands will work as usual.
To configure where the new buffer should appear, customize your
`display-buffer-alist'. For instance like so:
    (add-to-list
     \\='display-buffer-alist
     \\='(\"*ghcid-nix*\"
       (display-buffer-reuse-window   ;; First try to reuse an existing window
        display-buffer-at-bottom      ;; Then try a new window at the bottom
        display-buffer-pop-up-window) ;; Otherwise show a pop-up
       (window-height . 18)      ;; New window will be 18 lines
       ))
If the window that shows ghcid-nix changes size, the process will not
recognize the new height until you manually restart it by calling
`ghcid-nix' again.
"
  :lighter " Ghcid-Nix"
  (when (fboundp 'nlinum-mode) (nlinum-mode -1))
  (linum-mode -1)
  (compilation-minor-mode))


;; Compilation mode does some caching for markers in files, but it gets confused
;; because ghcid-nix reloads the files in the same process. Here we parse the
;; 'Reloading...' message from ghcid-nix and flush the cache for the mentioned
;; files. This approach is very similar to the 'omake' hacks included in
;; compilation mode.
(add-to-list
  'compilation-error-regexp-alist-alist
  '(ghcid-nix-reloading
    "Reloading\\.\\.\\.\\(\\(\n  .+\\)*\\)" 1 nil nil nil nil
    (0 (progn
         (let* ((filenames (cdr (split-string (match-string 1) "\n  "))))
           (dolist (filename filenames)
             (compilation--flush-file-structure filename)))
         nil))
    ))
(add-to-list 'compilation-error-regexp-alist 'ghcid-nix-reloading)


(defun ghcid-nix-buffer-name ()
  (concat "*" ghcid-nix-process-name "*"))

(defun ghcid-nix-cabal-cmd (target)
  (format "cabal new-repl %s" target))

;; TODO Pass in compilation command like compilation-mode
(defun ghcid-nix-command (h)
    (format "ghcid -c \"%s\" -h %s\n" (ghcid-nix-cabal-cmd ghcid-nix-target) h))

(defun ghcid-nix-get-buffer ()
  "Create or reuse a ghcid-nix buffer with the configured name and
display it. Return the window that shows the buffer.
User configuration will influence where the buffer gets shown
exactly. See `ghcid-nix-mode'."
  (display-buffer (get-buffer-create (ghcid-nix-buffer-name)) '((display-buffer-reuse-window))))

(defun ghcid-nix-start (dir)
  "Start ghcid-nix in the specified directory"

  (with-selected-window (ghcid-nix-get-buffer)

    (setq next-error-last-buffer (current-buffer))
    (setq-local default-directory dir)

    ;; Only now we can figure out the height to pass along to the ghcid-nix process
    (let ((height (- (window-body-size) 1)))

      (term-mode)
      (term-line-mode)  ;; Allows easy navigation through the buffer
      (ghcid-nix-mode)

      (setq-local term-buffer-maximum-size height)
      (setq-local scroll-up-aggressively 1)
      (setq-local show-trailing-whitespace nil)

      (term-exec (ghcid-nix-buffer-name)
           ghcid-nix-process-name
           "nix-shell"
           nil
           (list "--command" (ghcid-nix-command height)))

      )))

(defun ghcid-nix-kill ()
  (let* ((ghcid-nix-buf (get-buffer (ghcid-nix-buffer-name)))
         (ghcid-nix-proc (get-buffer-process ghcid-nix-buf)))
    (when (processp ghcid-nix-proc)
      (progn
        (set-process-query-on-exit-flag ghcid-nix-proc nil)
        (kill-process ghcid-nix-proc)
        ))))

;; TODO Close stuff if it fails
(defun ghcid-nix ()
  "Start a ghcid-nix process in a new window. Kills any existing sessions.
The process will be started in the directory of the buffer where
you ran this command from."
  (interactive)
  (ghcid-nix-start nix-shell-default-directory))

;; Assumes that only one window is open
(defun ghcid-nix-stop ()
  "Stop ghcid-nix"
  (interactive)
  (ghcid-nix-kill)
  (kill-buffer (ghcid-nix-buffer-name)))

(provide 'ghcid-nix)
