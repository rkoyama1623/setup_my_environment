;; scroll step
(setq scroll-conservatively 1)

;; whitespace
(require 'whitespace)
;; 空白
(set-face-foreground 'whitespace-space nil)
(set-face-background 'whitespace-space "red")
;; ファイル先頭と末尾の空行
(set-face-background 'whitespace-empty "yellow")
;; タブ
(set-face-foreground 'whitespace-tab nil)
(set-face-background 'whitespace-tab "yellow")
;; 空白文字を強制表示
(set-face-background 'whitespace-trailing "pink")
(set-face-background 'whitespace-hspace "pink")
(setq whitespace-style '(face           ; faceで可視化
                         trailing       ; 行末
                         tabs           ; タブ
                         empty          ; 先頭/末尾の空行
                         spaces         ; 空白
                         ;; space-mark     ; 表示のマッピング
                         tab-mark))
;; スペースは全角のみを可視化
(setq whitespace-space-regexp "\\(\u3000+\\)")
;; タブの表示を変更
(setq whitespace-display-mappings
      '((tab-mark ?\t [?\xBB ?\t])))
;; 発動
(global-whitespace-mode 1)
