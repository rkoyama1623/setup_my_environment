;; this init.el is based on https://github.com/tarao/dotfiles/blob/master/.emacs.d/init.el
;; see also http://tarao.hatenablog.com/entry/20150221/1424518030

;; emacs directory
(when load-file-name
  (setq user-emacs-directory (file-name-directory load-file-name)))

;; el-get
(add-to-list 'load-path (locate-user-emacs-file "el-get/el-get"))
(unless (require 'el-get nil 'noerror)
  (with-current-buffer
      (url-retrieve-synchronously
       "https://raw.githubusercontent.com/dimitri/el-get/master/el-get-install.el")
    (goto-char (point-max))
    (eval-print-last-sexp)))
;; install package
(el-get-bundle init-loader)
(el-get-bundle auto-complete)
(el-get-bundle emacs-evil/evil)
(el-get-bundle code-iai/ros_emacs_utils)
(el-get-bundle elpa:markdown-mode)
(el-get-bundle yaml-mode)

;; load files by init-loader
(require 'init-loader)
(init-loader-load (locate-user-emacs-file "init-loader"))
