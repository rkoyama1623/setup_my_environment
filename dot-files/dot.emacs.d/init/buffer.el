;; backup directory
(setq backup-directory "~/.bak")
;; autosave directory
(setq auto-save-directory "~/.bak")

;; Backup file (foo.txt~)

;; ;; Simple Way
;; (setq backup-directory-alist
;;   (cons (cons ".*" (expand-file-name "~/.emacs.d/backup"))
;;         backup-directory-alist))

;; ;; Complex Way
;; ;; Enable to make backup file if backup-directory do not exist
(setq make-backup-files t)
(if (and (boundp 'backup-directory)
         (not (fboundp 'make-backup-file-name-original)))
    (progn
      ;; rename make-backup-file-name to make-back-file-name-original
      (fset 'make-backup-file-name-original
            (symbol-function 'make-backup-file-name))
      ;; override default make-backup-file-name function
      (defun make-backup-file-name (filename)
        (if (and (file-exists-p (expand-file-name backup-directory))
                 (file-directory-p (expand-file-name backup-directory)))
            (concat (expand-file-name backup-directory) 
                    "/" (file-name-nondirectory filename))
          (make-backup-file-name-original filename)))))

;; auto-save file (#foo.txt#)
(setq auto-save-default t)
;; ;;Simple Way
;; (setq auto-save-file-name-transforms
;;       `((".*", (expand-file-name "~/.emacs.d/backup/") t)))

;; Complex
;; Check if auto-save-directory exists
(if (and (boundp 'auto-save-directory)
         (not (fboundp 'make-auto-save-file-name-original)))
    (progn
      ;; rename make-backup-file-name to make-back-file-name-original
      (fset 'make-auto-save-file-name-original
            (symbol-function 'make-auto-save-file-name))
      ;; override default make-backup-file-name function
      (defun make-auto-save-file-name ()
        (if (and (file-exists-p (expand-file-name auto-save-directory))
                 (file-directory-p (expand-file-name auto-save-directory)))
            (concat (expand-file-name auto-save-directory) 
                    "/"
                    (concat "#" (file-name-nondirectory (buffer-name)) "#"))
          (make-auto-save-file-name-original)))))

;; Saving Interval
(setq auto-save-timeout 10)     ;; 秒   (デフォルト : 30)
(setq auto-save-interval 100)   ;; 打鍵 (デフォルト : 300)
