;; tabbing
(setq-default tab-width 4
              indent-tabs-mode nil)

;; align
(require 'align nil t)

;; auto-insert
(require 'autoinsert nil t)
(add-hook 'find-file-not-found-hooks #'auto-insert)
(setq auto-insert-directory "~/.emacs.d/insert/"
      auto-insert-query nil
      auto-insert-alist nil)

;; automatically make script executable
(add-hook 'after-save-hook
          #'executable-make-buffer-file-executable-if-script-p)

;; path function
(defun backward-kill-path-element ()
  (interactive)
  (let ((pt (point)))
    (when (not (bolp))
      (backward-char)
      (re-search-backward "/" nil t)
      (forward-char)
      (when (= (point) pt) (call-interactively 'move-beginning-of-line))
      (kill-region (point) pt))))

;; For folding
;; C coding style
(add-hook 'c-mode-hook '(lambda () (hs-minor-mode 1)))
;; C++ coding style
(add-hook 'c++-mode-hook '(lambda () (hs-minor-mode 1)))
;; Scheme coding style
(add-hook 'scheme-mode-hook '(lambda () (hs-minor-mode 1)))
;; Elisp coding style
(add-hook 'emacs-lisp-mode-hook '(lambda () (hs-minor-mode 1)))
;; Lisp coding style
(add-hook 'lisp-mode-hook '(lambda () (hs-minor-mode 1)))
;; Python coding style
(add-hook 'python-mode-hook '(lambda () (hs-minor-mode 1)))

(define-key global-map (kbd "C-\\") 'hs-toggle-hiding)
;; vrml coding style
(add-hook 'vrml-mode-hook '(lambda () (hs-minor-mode 1)))

;;xml folding
(require 'hideshow)
(require 'sgml-mode)
(require 'nxml-mode)

(add-to-list 'hs-special-modes-alist
             '(nxml-mode
               "<!--\\|<[^/>]*[^/]>"
               "-->\\|</[^/>]*[^/]>"
               "<!--"
               sgml-skip-tag-forward
               nil))
(add-hook 'nxml-mode-hook 'hs-minor-mode)

;; optional key bindings, easier than hs defaults
(define-key nxml-mode-map (kbd "C-\\") 'hs-toggle-hiding)

;; remove space
(defun remove-all-space (start end)
  "remove space"
  (interactive "r")
  (save-excursion
    (save-restriction
      (narrow-to-region start end)
      (goto-char (point-min))
      (replace-string " " "")
      (goto-char (point-min))
      (replace-string "　" "")
      (goto-char (point-min))
      (replace-string "\n" "")
      )))
(put 'upcase-region 'disabled nil)

;; cua-mode
(cua-mode t)
(setq cua-enable-cua-keys nil)
(define-key global-map (kbd "C-x SPC") 'cua-set-rectangle-mark)
