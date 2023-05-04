;;; org-sltypes.el --- Create ontologies of links for org-super-links -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2023 Phil Dyer
;;
;; Author: Phil Dyer <https://github.com/PhDyellow>
;; Maintainer: Phil Dyer <phildyer@protonmail.com>
;; Created: March 29, 2023
;; Modified: March 29, 2023
;; Version: 0.0.1
;; Keywords: tools, hypermedia
;; Homepage: https://github.com/PhDyellow/org-sltypes
;; Package-Requires: ((emacs "24.3") (org-super-links "0.4") (cl-lib "0.5"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;; org-sltypes extends org-super=links by providing
;; macros that create functions.
;;
;; org-super-links, out of the box, puts links into
;; a "RELATED" drawer. org-sltypes can be set up to
;; create other link types that are put into
;; different drawers, or placed inline. Both forward
;; links and backward links are handled by the
;; macro.
;;
;; For example
;;
;; (defun my-org-slt-insert-leads-to ()
;;   (interactive)
;;   (org-sltypes-make-insert "FOLLOWS_FROM"
;;                            "LEADS_TO"
;;                            'org-sltypes-time-stamp-inactive
;;                            'org-sltypes-time-stamp-inactive
;;                            nil
;;                            nil))
;;
;; (defun my-org-slt-leads-to ()
;;   (interactive)
;;   (org-sltypes-make-link "FOLLOWS_FROM"
;;                            "LEADS_TO"
;;                            'org-sltypes-time-stamp-inactive
;;                            'org-sltypes-time-stamp-inactive
;;                            nil
;;                            nil))
;;
;;  (define-key org-mode-map
;;    "C-c C-l C-l"
;;    'my-org-slt-insert-leads-to)
;;; Code:

(require 'org-super-links)
(require 'cl-lib)

(defun org-sltypes-time-stamp-inactive ()
  "Return an 'org-mode' inactive date stamp."
  (format "%s "
	  (format-time-string (org-time-stamp-format t t) (current-time))))

;; function that takes toggles and list with link variables and does the right thing
(defun org-sltypes-link (inverse-backlinks-p
			 inline-p
			 use-stored-p
			 backlink-draw
                         link-draw
                         back-pre
                         link-pre
                         back-post
			 link-post)
  "generalised org-super-links.

`inverse-backlinks-p' is experimental, attempts to create a backlink TO current not FROM target node, usually the target node gets a backlink. Undefined behaviour if set with inline-p.

`inline-p' insert forward link inline, not in drawer.

`use-stored-p' use the target stored by org-super-links-store-link, if nil, request a target from user.

BACKLINK-DRAW gives the name of the drawer at the link target.
Nil to insert link under target heading.
LINK-DRAW gives the name of the drawer at the link source.
Nil to insert link at point.

The rest of the parameters set prefix and postfix strings.
If nil, nothing is inserted, if a string, the string is inserted.
If a function, the function is called without arguments and
must return a string.
BACK-PRE
LINK-PRE
BACK-POST
LINK-POST"
  (interactive)
  (when inverse-backlinks-p
    (cl-rotatef link-draw backlink-draw)
    (cl-rotatef back-pre link-pre)
    (cl-rotatef back-post link-post))
  (when inline-p
    (setq link-pre (replace-regexp-in-string "\\(_\\|-\\)" " " (downcase link-draw)) ;; may set to nil
	  (setq link-draw nil)))
  (let ((link-command (if use-stored-p #'org-super-links-insert-link #'org-super-links-link))
	(org-super-links-backlink-into-drawer (if backlink-draw backlink-draw org-super-links-backlink-into-drawer))
        (org-super-links-related-into-drawer (if link-draw link-draw org-super-links-related-into-drawer))
        (org-super-links-backlink-prefix (if back-pre back-pre org-super-links-backlink-prefix))
        (org-super-links-backlink-postfix (if back-post back-post org-super-links-backlink-postfix))
        (org-super-links-link-prefix (if link-pre link-pre org-super-links-link-prefix))
        (org-super-links-link-postfix (if link-post link-post org-super-links-link-postfix)))
    (funcall link-command)))


(defmacro org-sltypes-make-insert (&optional
                                   backlink-draw
                                   link-draw
                                   back-pre
                                   link-pre
                                   back-post
                                   link-post)

  "Call org-super-links-insert-link with preset settings.

org-super-links-insert-link expects a link has been stored by
org-super-links-store-link

Unset parameters (nil) use the current
Global value of the variable as a fallback.

BACKLINK-DRAW gives the name of the drawer at the link target.
Nil to insert link under target heading.
LINK-DRAW gives the name of the drawer at the link source.
Nil to insert link at point.

The rest of the parameters set prefix and postfix strings.
If nil, nothing is inserted, if a string, the string is inserted.
If a function, the function is called without arguments and
must return a string.
BACK-PRE
LINK-PRE
BACK-POST
LINK-POST"

  (let (
        (org-super-links-backlink-into-drawer ,(if backlink-draw backlink-draw org-super-links-backlink-into-drawer))
        (org-super-links-related-into-drawer ,(if link-draw link-draw org-super-links-related-into-drawer))
        (org-super-links-backlink-prefix ,(if back-pre back-pre org-super-links-backlink-prefix))
        (org-super-links-backlink-postfix ,(if back-post back-post org-super-links-backlink-postfix))
        (org-super-links-link-prefix ,(if link-pre link-pre org-super-links-link-prefix))
        (org-super-links-link-postfix ,(if link-post link-post org-super-links-link-postfix)))
    (org-super-links-insert-link)))

(defmacro org-sltypes-make-link (&optional
                                 backlink-draw
                                 link-draw
                                 back-pre
                                 link-pre
                                 back-post
                                 link-post)
  "Call org-super-links-link with preset settings.

org-super-links-link opens a UI for the user to choose
a target.
Unset parameters (nil) use the current
Global value of the variable as a fallback.

BACKLINK-DRAW gives the name of the drawer at the link target.
Nil to insert link under target heading.
LINK-DRAW gives the name of the drawer at the link source.
Nil to insert link at point.

The rest of the parameters set prefix and postfix strings.
If nil, nothing is inserted, if a string, the string is inserted.
If a function, the function is called without arguments and
must return a string.
BACK-PRE
LINK-PRE
BACK-POST
LINK-POST"

  (let (
        (org-super-links-backlink-into-drawer ,(if backlink-draw backlink-draw org-super-links-backlink-into-drawer))
        (org-super-links-related-into-drawer ,(if link-draw link-draw org-super-links-related-into-drawer))
        (org-super-links-backlink-prefix ,(if back-pre back-pre org-super-links-backlink-prefix))
        (org-super-links-backlink-postfix ,(if back-post back-post org-super-links-backlink-postfix))
        (org-super-links-link-prefix ,(if link-pre link-pre org-super-links-link-prefix))
        (org-super-links-link-postfix ,(if link-post link-post org-super-links-link-postfix)))
    (org-super-links-link)))

(defmacro org-sltypes-make-command (func-name insertp
                                              &optional
                                              backlink-draw
                                              link-draw
                                              back-pre
                                              link-pre
                                              back-post
                                              link-post)
  "'org-sltypes-make-command' creates an interactive function 'FUNC-NAME' that calls org-super-links with preset variables.

If INSERTP is t, then the function will call 'org-superlinks-insert-link', which assumes a link has been stored with
'org-super-links-store-link'. Otherwise, the function will call 'org-superlinks-link', which opens a UI for the user
to select a target.

Unset parameters (nil) use the current
Global value of the variable as a fallback.

BACKLINK-DRAW gives the name of the drawer at the link target.
Nil to insert link under target heading.
LINK-DRAW gives the name of the drawer at the link source.
Nil to insert link at point.

The rest of the parameters set prefix and postfix strings.
If nil, nothing is inserted, if a string, the string is inserted.
If a function, the function is called without arguments and
must return a string.
BACK-PRE
LINK-PRE
BACK-POST
LINK-POST"

  (defun ,func-name ()
    (interactive)
    (let (
          (org-super-links-backlink-into-drawer ,(if backlink-draw backlink-draw org-super-links-backlink-into-drawer))
          (org-super-links-related-into-drawer ,(if link-draw link-draw org-super-links-related-into-drawer))
          (org-super-links-backlink-prefix ,(if back-pre back-pre org-super-links-backlink-prefix))
          (org-super-links-backlink-postfix ,(if back-post back-post org-super-links-backlink-postfix))
          (org-super-links-link-prefix ,(if link-pre link-pre org-super-links-link-prefix))
          (org-super-links-link-postfix ,(if link-post link-post org-super-links-link-postfix))
          )
      (,(if insertp org-super-links-insert-link org-super-links-link)))))


(provide 'org-sltypes)
;;; org-sltypes.el ends here
