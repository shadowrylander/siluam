;; Yo!


;; [[file:early-init.org::*Yo!][Yo!:1]]
;;; $EMACSDIR/early-init.el -*- lexical-binding: t; -*-
(defvar pre-user-emacs-directory (file-name-directory (or load-file-name buffer-file-name)))

(setq package-enable-at-startup nil)

;; (load (concat pre-user-emacs-directory "siluam/package-config.el"))
;; (load (concat pre-user-emacs-directory "siluam/straight-config.el"))
;; (load (concat pre-user-emacs-directory "siluam/quelpa.el"))

(defvar meq/var/windows (member system-type '(windows-nt ms-dos)))
(defvar meq/var/slash (if meq/var/windows "\\" "/"))
;; Yo!:1 ends here

;; Electric Sheep

;; I have an Android device running [[https://termux.com/][Termux]], so:


;; [[file:early-init.org::*Electric Sheep][Electric Sheep:1]]
(defvar meq/var/phone
    (ignore-errors (string-match-p (regexp-quote "Android") (shell-command-to-string "uname -a"))))
(when meq/var/phone (load (concat pre-user-emacs-directory "siluam" meq/var/slash "scroll-bar.el")))
;; Electric Sheep:1 ends here

;; Sorry, got nothing for this

;; I also use [[WSLg][https://github.com/microsoft/wslg]]:


;; [[file:early-init.org::*Sorry, got nothing for this][Sorry, got nothing for this:1]]
(defvar meq/var/wsl
    (ignore-errors (string-match-p
                    (regexp-quote "microsoft-standard-WSL")
                    (shell-command-to-string "uname -a"))))
;; Sorry, got nothing for this:1 ends here

;; BTW, I use NixOS

;; BTW, I use [[https://nixos.org/][NixOS]]:


;; [[file:early-init.org::*BTW, I use NixOS][BTW, I use NixOS:1]]
(defvar meq/var/nixos
    (ignore-errors (string-match-p (regexp-quote "nixos") (shell-command-to-string "uname -a"))))
;; BTW, I use NixOS:1 ends here

;; RESISTENCE IS FUTILE

;; #+begin_export html
;; <p align="center"><a href="https://github.com/emacscollective/borg"><img src="borg.gif"></a></p>
;; #+end_export


;; [[file:early-init.org::*RESISTENCE IS FUTILE][RESISTENCE IS FUTILE:1]]
(setq borg-drones-directory (concat pre-user-emacs-directory "lib" meq/var/slash))

(defun meq/require-and-load (pkg)
    (add-to-list 'load-path (concat pre-user-emacs-directory "siluam" meq/var/slash pkg) t)
    (require (intern pkg)))
(mapc 'meq/require-and-load '("emacsql" "emacsql-sqlite" "closql"))
(unless (or
          meq/var/phone
          ;; meq/var/windows
          ) (meq/require-and-load "epkg"))
(meq/require-and-load "borg")
;; RESISTENCE IS FUTILE:1 ends here



;; First of all, let's make the error message a /little/ more descriptive:


;; [[file:early-init.org::*RESISTENCE IS FUTILE][RESISTENCE IS FUTILE:2]]
(defun meq/borg--call-git-advice (pkg &rest args)
  (let ((process-connection-type nil)
        (buffer (generate-new-buffer
                 (concat " *Borg Git" (and pkg (concat " " pkg)) "*"))))
    (if (eq (apply #'call-process "git" nil buffer nil args) 0)
        (kill-buffer buffer)
      (with-current-buffer buffer
        (special-mode))
      (pop-to-buffer buffer)
      (error "Borg Git: %s %s:\n\n%s" pkg args (buffer-string)))))
(advice-add #'borg--call-git :override #'meq/borg--call-git-advice)
;; RESISTENCE IS FUTILE:2 ends here



;; I most likely already checked the code of the package I want to install:


;; [[file:early-init.org::*RESISTENCE IS FUTILE][RESISTENCE IS FUTILE:3]]
(advice-add #'borg--maybe-confirm-unsafe-action :override #'ignore)
;; RESISTENCE IS FUTILE:3 ends here



;; And I would not like to reuse my ~gitdir~:


;; [[file:early-init.org::*RESISTENCE IS FUTILE][RESISTENCE IS FUTILE:4]]
(advice-add #'borg--maybe-reuse-gitdir :override #'ignore)
;; RESISTENCE IS FUTILE:4 ends here

;; [[file:early-init.org::*RESISTENCE IS FUTILE][RESISTENCE IS FUTILE:5]]
(defun meq/borg-build-advice (clone &optional activate)
  "Build the clone named CLONE.
Interactively, or when optional ACTIVATE is non-nil,
then also activate the clone using `borg-activate'."
  (interactive (list (borg-read-clone "Build drone: ") t))
  (borg--build-noninteractive clone)
  (when activate (borg-activate clone)))
(advice-add #'borg--maybe-absorb-gitdir :override #'ignore)
(advice-add #'borg-build :override #'meq/borg-build-advice)

(defun meq/borg-assimilate-advice (package url &optional partially)
  "Assimilate the package named PACKAGE from URL.
If `epkg' is available, then only read the name of the package
in the minibuffer and use the url stored in the Epkg database.
If `epkg' is unavailable, the package is not in the database, or
with a prefix argument, then also read the url in the minibuffer.
With a negative prefix argument only add the submodule but don't
build and activate the drone."
  (interactive
   (nconc (borg-read-package "Assimilate package: " current-prefix-arg)
          (list (< (prefix-numeric-value current-prefix-arg) 0))))
  (borg--maybe-confirm-unsafe-action "assimilate" package url)
  (message "Assimilating %s..." package)
  (unless (equal (borg-get package "s8472") "true")
      (borg--maybe-reuse-gitdir package)
      (borg--call-git
        package
        "-C" borg-top-level-directory
        "submodule"
        "add"
        "-f"
        "--depth" "1"
        "--name" package
        url
        (or
          (borg-get package "path")
          (concat
            (string-remove-prefix borg-user-emacs-directory borg-drones-directory)
            meq/var/slash
            package)))
      (borg--sort-submodule-sections ".gitmodules")
      (borg--call-git package "add" ".gitmodules")
      (borg--maybe-absorb-gitdir package))
  (unless partially
    (borg-build package)
    (borg-activate package))
  (borg--refresh-magit)
  (message "Assimilating %s...done" package))
(advice-add #'borg-assimilate :override #'meq/borg-assimilate-advice)

(defun meq/borg-drones-advice (func &rest args)
  (let* ((barg (pop args))
          (assimilating (pop args)))
    (seq-filter #'(lambda (pkg*) (interactive)
      (let* ((pkg (car pkg*))
              (path* (cl-getf (cdr pkg*) 'path))
              (path (cond ((listp path*) (car path*))
                          ((stringp path*) path*)))
              (exists (file-exists-p (borg-worktree pkg))))
        (and (not (string-match-p (regexp-quote "\\") pkg))
            (not (string-match-p (regexp-quote "/") pkg))
            (or
              (and assimilating (not exists))
              (and exists (not assimilating)))
            (string=
                  (string-remove-suffix pkg path)
                  (string-remove-prefix borg-user-emacs-directory borg-drones-directory)))))
      (funcall func barg))))
(advice-add #'borg-drones :around #'meq/borg-drones-advice)

(defvar meq/var/update (member "--update" command-line-args)) (delete "--update" command-line-args)
(defvar meq/var/update-packages (member "--update-packages" command-line-args))
(delete "--update-packages" command-line-args)
(defvar meq/var/update-profiles (member "--update-profiles" command-line-args))
(delete "--update-profiles" command-line-args)
(when (or meq/var/update meq/var/update-packages) (mapc #'borg-build (mapcar #'car (borg-drones t))))

;; Adapted From: https://github.com/hlissner/doom-emacs/blob/develop/early-init.el
(setq load-prefer-newer t)

(mapc #'(lambda (pkg*) (interactive)
  (let* ((pkg (symbol-name pkg*)))
    (if (file-exists-p (concat pre-user-emacs-directory "lib" meq/var/slash pkg))
        (borg-activate pkg)
        (borg-assimilate pkg (borg-get pkg "url")))
    (require pkg*))) '(packed auto-compile no-littering gcmh))

(auto-compile-on-load-mode)
(auto-compile-on-save-mode)
(gcmh-mode 1)

(global-auto-revert-mode 1) (auto-revert-mode 1)
(if (file-exists-p (concat pre-user-emacs-directory "lib/org"))
  (if (file-exists-p (concat pre-user-emacs-directory "lib/org/lisp/org-loaddefs.el"))
    (borg-activate "org")
    (borg-build "org" t))
  (borg-assimilate "org" (borg-get "org" "url")))
(require 'org-loaddefs)

;; Adapted From: https://github.com/emacscollective/borg/blob/master/borg.el#L912
(defun meq/call (program buffer-name &rest args)
  (let ((process-connection-type nil)
        (buffer (generate-new-buffer buffer-name)))
    (if (eq (apply #'call-process program nil buffer nil args) 0)
        (kill-buffer buffer)
      (with-current-buffer buffer
        (special-mode))
      (pop-to-buffer buffer)
      (error "%s: %s:\n\n%s" program args (buffer-string)))))

(defun meq/call-tangle (file)
  (meq/call (concat
                pre-user-emacs-directory
                "settings"
                meq/var/slash
                "org-tangle.sh") "*literally-configuring*" file))

;; Adapted From: https://code.orgmode.org/bzg/org-mode/src/master/lisp/org.el#L222
(defun meq/org-babel-load-file-advice (file &optional compile)
  "Load Emacs Lisp source code blocks in the Org FILE.
This function exports the source code using `org-babel-tangle'
and then loads the resulting file using `load-file'.  With
optional prefix argument COMPILE, the tangled Emacs Lisp file is
byte-compiled before it is loaded."
  (interactive "fFile to load: \nP")
  (let ((tangled-file (concat (file-name-sans-extension file) ".el")))
    ;; Tangle only if the Org file is newer than the Elisp file.
    (unless (org-file-newer-than-p
                tangled-file
                (file-attribute-modification-time
                    (file-attributes (file-truename file))))
        (meq/call-tangle file))
    (if compile
        (progn
            (byte-compile-file tangled-file)
            (load tangled-file)
            (message "Compiled and loaded %s" tangled-file))
        (load-file tangled-file)
        (message "Loaded %s" tangled-file))))

(advice-add #'org-babel-load-file :override #'meq/org-babel-load-file-advice)

(defun meq/reload-early-init nil (interactive) (org-babel-load-file
    (concat pre-user-emacs-directory "early-init.aiern.org")
    t))
(meq/reload-early-init)
;; RESISTENCE IS FUTILE:5 ends here
