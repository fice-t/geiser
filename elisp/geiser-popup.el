;; geiser-popup.el -- popup windows

;; Copyright (C) 2009, 2010 Jose Antonio Ortega Ruiz

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the Modified BSD License. You should
;; have received a copy of the license along with this program. If
;; not, see <http://www.xfree86.org/3.3.6/COPYRIGHT2.html#5>.

;; Start date: Sat Feb 07, 2009 14:05

(require 'view)


;;; Support for defining popup buffers and accessors:

(defvar geiser-popup--registry nil)

(defun geiser-popup--setup-view-mode ()
  (view-mode-enable)
  (set (make-local-variable 'view-no-disable-on-exit) t)
  (setq view-exit-action
	(lambda (buffer)
	  (with-current-buffer buffer
	    (bury-buffer)))))

(defmacro geiser-popup--define (base name mode)
  (let ((get-buff (intern (format "geiser-%s--buffer" base)))
        (pop-buff (intern (format "geiser-%s--pop-to-buffer" base)))
        (with-macro (intern (format "geiser-%s--with-buffer" base)))
        (method (make-symbol "method"))
        (buffer (make-symbol "buffer")))
  `(progn
     (add-to-list 'geiser-popup--registry ,name)
     (defun ,get-buff ()
       (or (get-buffer ,name)
           (with-current-buffer (get-buffer-create ,name)
             (,mode)
             (geiser-popup--setup-view-mode)
             (current-buffer))))
     (defun ,pop-buff (&optional ,method)
       (let ((,buffer (,get-buff)))
         (unless (eq ,buffer (current-buffer))
           (cond ((eq ,method 'buffer) (view-buffer ,buffer))
                 ((eq ,method 'frame) (view-buffer-other-frame ,buffer))
                 (t (view-buffer-other-window ,buffer))))))
     (defmacro ,with-macro (&rest body)
       (let ((buff ',get-buff))
         `(with-current-buffer (funcall ',buff)
            (let ((inhibit-read-only t))
              ,@body))))
     (put ',with-macro 'lisp-indent-function 'defun))))

(put 'geiser-popup--define 'lisp-indent-function 1)


;;; Reload support:

(defun geiser-popup-unload-function ()
  (dolist (name geiser-popup--registry)
    (when (buffer-live-p (get-buffer name))
      (kill-buffer name))))


(provide 'geiser-popup)
;;; geiser-popup.el ends here
