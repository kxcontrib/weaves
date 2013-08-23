;; weaves
;; Using Emacs support

(load "kdbp-mode")

(autoload 'q-mode "q-mode")
(autoload 'q-help "q-mode")
(autoload 'run-q "q-mode")
(autoload 'kdbp-mode "kdbp-mode")

;; To enable Q mode for *.q files, add the following to your emacs startup
;; file:

(setq auto-mode-alist (cons '("\\.[kq]$" . kdbp-mode) auto-mode-alist))

