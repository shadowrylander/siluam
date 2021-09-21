;; Ho, Ho, Ho!


;; [[file:init.org::*Ho, Ho, Ho!][Ho, Ho, Ho!:1]]
;;; $EMACSDIR/init.el -*- lexical-binding: t; -*-
(when (version< emacs-version "27") (load (concat
                                            (file-name-directory load-file-name)
                                            "early-init.el")))

(defun meq/reload-first-init nil (interactive) (meq/cl (meq/ued* "init.aiern.org")))
(meq/reload-first-init)
;; Ho, Ho, Ho!:1 ends here
