(ql:quickload :str)

(defun read-file2 (file)
  (with-open-file (stream "data/d2.txt")
    (mapcar #'parse-integer (str:split #\, (read-line stream)))))

(defun gravity-op (op program p1 p2 p3)
  (setf (nth p3 program)
    (funcall op (nth p1 program) (nth p2 program)))
  program)

(defun get-pos (pos program)
  (list (nth (+ pos 1) program) (nth (+ pos 2) program) (nth (+ pos 3) program)))

(defun replace-positions (program noun verb)
  (setf (nth 1 program) noun
	(nth 2 program) verb)
  program)

(defun process-program (program pos)
  (let* ((poss (get-pos pos program))
     (p1 (car poss))
     (p2 (cadr poss))
     (p3 (caddr poss)))
    (cond ((eq (nth pos program) 1)
       (process-program
        (gravity-op #'+ program p1 p2 p3)
        (+ pos 4)))
      ((eq (nth pos program) 2)
       (process-program
        (gravity-op #'* program p1 p2 p3)
        (+ pos 4)))
      ((eq (nth pos program) 99)
       (nth 0 program)))))

(print (process-program (replace-positions (read-file2 "data/d2.txt") 12 2) 0))

(defun solve-noun-verb (objective input-space raw-program)
  (remove-if #'null (loop for input in input-space
		       collect (let* ((test-noun (car input))
				      (test-verb (cdr input))
				      (program (replace-positions raw-program test-noun test-verb))
				      (result-prog (process-program (copy-list program) 0)))
				 (if (eq result-prog objective)
				     (return `(,input ,result-prog)))))))

(defun create-nbyk-input-space (n k)
  (loop for i from 0 to n
     append (loop for j from 0 to k
           collect `(,i . ,j))))

(print (solve-noun-verb 19690720 (create-nbyk-input-space 99 99) (read-file2 "data/d2.txt")))
