#C-c C-p [Start repl] (ijanet)
#C-c C-b [Eval buffer] (ijanet-eval-buffer)
#C-c C-l [Eval line] (ijanet-eval-line)
#C-c C-r [eval region] (ijanet-eval-region)

(sum (map
      (fn [m] (- (math/floor (/ (scan-number m) 3)) 2))
      (array/slice
       (string/split "\n" (slurp (os/realpath "d1.1.txt")))
       0
       -2)))
