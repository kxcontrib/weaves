; KDB+ mode built with guidance from:
;  http://two-wugs.net/emacs/mode-tutorial.html
;
; At this point, it only implements a subset of
;  Simon Garland's VIM macros.
;
; The first space/tab on the line gets coloured "azure2"
;  to let you know it's a continuation line.
;
; Escapes to/from K are not explicitly supported.
; Only tested on GNU Emacs 21.4.1.
;
; If you have any fixes/enhancements, please send
;  them to the maintainer: Alvin Shih.
;
; Version 0.03.  2007-02-14
;
; Just add something resembling the following to your .emacs:
;   (setq load-path (cons "PATH/TO/site-lisp" load-path))
;   (load "kdbp-mode")
;

(require 'q-minor-mode)

(defvar kdbp-mode-hook nil)

(defface kdbp-mode-continuation-whitespace-face '((t (:background "azure2")))
  "*Face for highlighting continuation whitespace."
  :group 'font-lock :group 'faces)

(defvar kdbp-mode-map
  (let ((kdbp-mode-map (make-keymap)))
;    (define-key kdbp-mode-map "\C-j" 'newline-and-indent)
    kdbp-mode-map)
  "Keymap for KDB+ major mode"
  )

(add-to-list 'auto-mode-alist '("\\.[qk]$" . kdbp-mode))

(defvar kdbp-mode-syntax-table
  (let ((kdbp-mode-syntax-table (make-syntax-table)))
    ; suppress emacs recognition of strings so we have
    ;  control
    (modify-syntax-entry ?\" "_" kdbp-mode-syntax-table)
    (modify-syntax-entry ?_ "w" kdbp-mode-syntax-table)
    (modify-syntax-entry ?$ "." kdbp-mode-syntax-table)

    kdbp-mode-syntax-table)
  "Syntax table for kdbp-mode")

; build an optimized regex to recognize builtin functions
(defun kdbp-builtin-regex-gen ()
  (concat "\\<"
	  (regexp-opt
	   '(
	     "abs" "acos" "aj" "all" "and" "any" "asc" "asin" "asof" "assert" "atan" "attr" "avg"
	     "bin" "boolean" "by" "byte"
	     "ceiling" "char" "cols" "cor" "cos" "count" "cov" "cross" "csv" "cut"
	     "date" "datetime" "dd" "delete" "deltas" "desc" "dev" "differ" "distinct" "do" "dotzs"
	     "each" "enlist" "except" "exec" "exit" "exp"
	     "fby" "fills" "first" "flip" "float" "floor" "from"
	     "get" "getenv" "group" "gtime"
	     "hclose" "hcount" "hdel" "hh" "hopen" "hsym"
	     "iasc" "idesc" "in" "insert" "int" "inter" "inv"
	     "key" "keys"
	     "last" "like" "lj" "load" "log" "long" "lower" "lsq" "ltime" "ltrim"
	     "mavg" "max" "maxs" "mcount" "md5" "mdev" "med" "meta" "min" "mins" "minute" "mm" "mmax" "mmin" "mmu" "mod" "month" "msum"
	     "neg" "next" "not" "null"
	     "or"
	     "peach" "pj" "plist" "prd" "prds" "prev"
	     "rand" "rank" "ratios" "raze" "read0" "read1" "real" "reciprocal" "release" "reverse" "ripcnstr" "rload" "rotate" "rsave" "rtrim"
	     "save" "second" "select" "set" "short" "show" "signum" "sin" "sqrt" "ss" "ssr" "string" "sublist" "sum" "sums" "sv" "symbol" "system"
	     "tables" "tan" "til" "time" "trim" "txf" "type"
	     "uj" "ungroup" "union" "update" "upper" "upsert"
	     "value" "var" "view" "views" "vs"
	     "wavg" "week" "where" "while" "within" "wsum"
	     "xasc" "xbar" "xcol" "xcols" "xdesc" "xexp" "xgroup" "xkey" "xlog" "xprev" "xrank"
	     "year"
	     ) t)
	  "\\>"	)
)

;font-lock-comment-face +
;font-lock-string-face +
;font-lock-keyword-face
;font-lock-builtin-face +
;font-lock-function-name-face +
;font-lock-variable-name-face +
;font-lock-type-face + (sorta)
;font-lock-constant-face +
;font-lock-warning-face +

(defvar kdbp-font-lock-keywords
  (list
   ; block comments or trailing comments
   (cons (concat "\\("
		 "^/[ \t]*\n\\(\\([^\\\\].*\\)?\n\\)*\\\\[ \t]*$"
		 "\\)"
		 "\\|"
		 "\\("
		 "^\\\\[ \t]*\n\\(.\\|\n\\)*"
		 "\\)" )
	 'font-lock-comment-face)
   '("[ \t]//.*" . font-lock-warning-face)
   '("^[ \t]*//.*" . font-lock-warning-face)
   '("[ \t]/.*" . font-lock-comment-face)
   '("^[ \t]*/.*" . font-lock-comment-face)
   ; strings but allowing embedded \"
   ; also need to match \\ to avoid problems with strings like "\\\\"
   '("\"\\(\\\\[\"\\\\]\\|[^\"]\\)*\"" . font-lock-string-face)

   (cons (kdbp-builtin-regex-gen) 'font-lock-builtin-face)

   ; symbol constants
   '("`[:a-zA-Z0-9_][:a-zA-Z0-9_]*" . font-lock-constant-face)

   ; dates and times
   '("[0-9][0-9][0-9][0-9]\\.[01][0-9]\\.[0123][0-9]" . font-lock-constant-face)
   '("[0-9][0-9][0-9][0-9]\\.[01][0-9]m" . font-lock-constant-face)
   '("[012][0-9]:[012345][0-9]\\(:[012345][0-9]\\(\\.[0-9]\\{0,3\\}\\)?\\)?" . font-lock-constant-face)


   ; variable names
   '("\\<[a-zA-Z][a-zA-Z0-9_]*" . font-lock-variable-name-face)

   ; special I/O and IPC functions
   '("[0-2]:" . font-lock-warning-face)
   
   ; nulls
   '("0N[hjemdzuvt]?" . font-lock-constant-face)
   '("0n" . font-lock-constant-face)
   ; infinities
   '("-?0[Ww]" . font-lock-constant-face)
   ; bits
   '("[01]+b" . font-lock-constant-face)


   ; floats and reals
   '("-?[0-9]+\\.[0-9]*\\([eE]-?[0-9][0-9]*\\)?[ef]?" . font-lock-constant-face)
   '("-?[0-9]*\\.[0-9]+\\([eE]-?[0-9][0-9]*\\)?[ef]?" . font-lock-constant-face)

   ; bytes
   '("0x[0-9a-fA-F]+" . font-lock-constant-face)

   ; ints, shorts, longs
   '("-?[0-9]+[hj]?" . font-lock-constant-face)

   ; distinguish similar-looking characters

   ; semicolons in red to make it easier to see function projections
   ; dyadic each is very powerful, but easy to miss visually
   ;  and signals are very important
   ; lists/records can stretch on a bit, so the parens should be visible
   '("[;()',|~]" . font-lock-warning-face)
   '("[:{}`!$]" . font-lock-function-name-face)
   '("[][]" . font-lock-type-face)

   '("^\\([ \t]\\)[ \t]*" 1 'kdbp-mode-continuation-whitespace-face)

   ))

(defun kdbp-mode ()
  "Major Mode for editing KDB+/Q files"
  (interactive)
  (kill-all-local-variables)
  (q-minor-mode)
  (use-local-map kdbp-mode-map)

  (set-syntax-table kdbp-mode-syntax-table)
  ;; (use-local-map q-mode-map)
  (derived-mode-set-keymap 'q-mode)

  (set (make-local-variable 'font-lock-multiline) t)
  (make-local-variable 'font-lock-defaults)
  (setq font-lock-defaults
	'(kdbp-font-lock-keywords nil nil ((?_ . "w"))))

  (setq major-mode 'kdbp-mode)
  (setq mode-name "KDB+")
  (run-hooks 'kdbp-mode-hook))

(provide 'kdbp-mode)

