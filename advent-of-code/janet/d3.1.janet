(defn get-puzzle
  []
  (string/split ","
		(string/slice
		 (slurp (os/realpath "d3.1.txt"))
		 0
		 -2)))
()
