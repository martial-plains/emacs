(require 'package)
(require 'org)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize)
(package-refresh-contents)
(package-install 'f)
(package-install 'htmlize)

(message "Emacs directory: %s" user-emacs-directory)

(require 'f)
(require 'ox-publish)
(require 'htmlize)

(setq org-confirm-babel-evaluate nil
      org-html-validation-link nil
      make-backup-files nil)

(with-temp-buffer
  (find-file "config.org")
  (org-html-export-to-html))

(message "Project generated!")
