# janet reply key bindings
#(global-set-key (kbd "C-c C-p") 'ijanet)
#(global-set-key (kbd "C-c C-b") 'ijanet-eval-buffer)
#(global-set-key (kbd "C-c C-l") 'ijanet-eval-line)
#(global-set-key (kbd "C-c C-r") 'ijanet-eval-region)

(defn chrf
  [c]
  (unless (and (string? c) (= (length c) 1))
    (error (string/format "expected string of length 1, got %v" c)))
  (c 0))

(defn parse-policy
  [line]
  (tuple (int/s64 ((string/split "-" ((string/split " " line) 0)) 0))
	 (int/s64 ((string/split "-" ((string/split " " line) 0)) 1))
	 (string/slice ((string/split " " line) 1) 0 1)))

(defn parse-password
  [line]
  (string/slice line 5))

(defn check-pw-validity
  [min max pw-count]
  (and (>= max (int/s64 pw-count))
       (<= min (int/s64 pw-count))))

# 0th elem is policy
# 2th elem is char
(defn get-pw-char-count
  [tup]
  (count (fn [x] (= x (chrf ((tup 0) 2))))
	 (tup 1)))

(defn get-min-count
  [tup]
  ((tup 0) 0))

(defn get-max-count
  [tup]
  ((tup 0) 1))

(with [f (file/open "2.txt")]
      (def nums (seq [l :iterate (file/read f :line)]
		     (tuple (parse-policy (string/trim l))
			    (parse-password (string/trim l)))))
      (loop [x :in nums] (print (get-min-count x) " " (get-max-count x) " " (get-pw-char-count x) " " (check-pw-validity
			     (get-min-count x)
			     (get-max-count x)
			     (get-pw-char-count x))))
      (print (count (fn [x] (check-pw-validity
			     (get-min-count x)
			     (get-max-count x)
			     (get-pw-char-count x)))
		    nums)))



