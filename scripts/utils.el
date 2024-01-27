;;; This function returns t if the current frame is in fullscreen mode, nil otherwise.
(defun emacs-is-fullscreen ()
  (eq (frame-parameter nil 'fullscreen) 'fullboth))

;;; Return t if Emacs is running in a terminal, nil otherwise.
(defun is-in-terminal ()
    (not (display-graphic-p)))

(provide 'utils)