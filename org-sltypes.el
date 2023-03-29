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
;; Package-Requires: ((emacs "24.3") (org-super-links "0.4"))
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
If a function, the fucntion is called without arguments and
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
If a function, the fucntion is called without arguments and
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

(defun org-sltypes-time-stamp-inactive ()
  "Return an 'org-mode' inactive date stamp."
  (format-time-string (org-time-stamp-format t t) (current-time)))






(provide 'org-sltypes)
;;; org-sltypes.el ends here
