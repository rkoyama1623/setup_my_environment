(add-hook 'markdown-mode-hook
	(lambda ()
	  (defun open-with-shiba ()
	    "open a current markdown file with shiba"
	    (interactive)
	    (start-process "shiba" "*shiba*" "shiba" "--detach" buffer-file-name))
	  (define-key markdown-mode-map (kbd "C-c C-c") 'open-with-shiba)))

