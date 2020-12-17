;; pt1
(defun read-file (file)
  (with-open-file (stream file)
    (loop for line = (read-line stream nil)
       while line
       collect (parse-integer line))))

(defun calc-fuel-cost (mass)
  (- (floor (/ mass 3)) 2))

(print (reduce '+ (mapcar #'calc-fuel-cost (read-file "data/d1.txt"))))

;; pt2
(defun calc-mod-fuel (module-size)
  (let ((module-fuel (calc-fuel-cost module-size)))
    (if (<= module-fuel 0)
        0
        (+ module-fuel (calc-mod-fuel module-fuel)))))

(print  (reduce '+ (mapcar #'calc-mod-fuel (read-file "data/d1.txt"))))
