#C-c C-p [Start repl] (ijanet)
#C-c C-b [Eval buffer] (ijanet-eval-buffer)
#C-c C-l [Eval line] (ijanet-eval-line)
#C-c C-r [eval region] (ijanet-eval-region)

(defn populate-state
  [state val1 val2]
  (put state 1 val1)
  (put state 2 val2))

(defn op-1
  [state pos1 pos2 pos3]
  (put state pos3 (+ (state pos1) (state pos2))))

(defn op-2
  [state pos1 pos2 pos3]
  (put state pos3 (* (state pos1) (state pos2))))

#(if (not= 99 (state ipointer))
    # (print ipointer
    # 	   " "
    # 	   (state ipointer)
    # 	   " on "
    # 	   (state (state (+ 1 ipointer)))
    # 	   " "
    # 	   (state (state (+ 2 ipointer)))
    # 	   " in "
    # 	   (state (+ 3 ipointer))))

(defn exc-op
  [state ipointer]
  (case (state ipointer)
    1 (exc-op (op-1 state
		    (state (+ 1 ipointer))
		    (state (+ 2 ipointer))
		    (state (+ 3 ipointer)))
	      (+ 4 ipointer))
    2 (exc-op (op-2 state
		    (state (+ 1 ipointer))
		    (state (+ 2 ipointer))
		    (state (+ 3 ipointer)))
	      (+ 4 ipointer))
    99 state))

(def state (exc-op (populate-state (map scan-number (string/split "," (string/slice (slurp (os/realpath "d2.1.txt")) 0 -2))) 12 2) 0))

