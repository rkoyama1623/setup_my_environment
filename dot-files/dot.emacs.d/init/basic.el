;; hostname
(defconst short-hostname (or (nth 0 (split-string (system-name) "\\."))
                             (system-name))
  "Host part of function `system-name'.")

;; interactive
(fset 'yes-or-no-p 'y-or-n-p)
