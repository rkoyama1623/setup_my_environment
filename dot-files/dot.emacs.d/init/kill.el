;; Sync Clip Board
;; linux
(defun copy-from-linux (text &optional rest)
  (let* ((process-connection-type nil)
         (proc (start-process "xsel" "*Messages*" "xsel" "-b" "-i")))
    (process-send-string proc text)
    (process-send-eof proc)))
(defun paste-to-linux ()
  (shell-command-to-string "xsel -b -o"))
;; os x
(defun copy-from-osx ()
  (shell-command-to-string "pbpaste"))

(defun paste-to-osx (text &optional push)
  (let ((process-connection-type nil))
    (let ((proc (start-process "pbcopy" "*Messages*" "pbcopy")))
      (process-send-string proc text)
      (process-send-eof proc))))

;; switch based on os
(if (eq system-type 'darwin)
    (progn
      (setq interprogram-cut-function 'paste-to-osx)
      (setq interprogram-paste-function 'copy-from-osx))
  (progn
    (setq interprogram-cut-function 'paste-to-linux)
    (setq interprogram-paste-function 'copy-from-linux)))
