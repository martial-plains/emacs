;;; This function returns t if the current frame is in fullscreen mode, nil otherwise.
(defun emacs-is-fullscreen ()
  (eq (frame-parameter nil 'fullscreen) 'fullboth))
