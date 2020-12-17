#C-c C-p [Start repl] (ijanet)
#C-c C-b [Eval buffer] (ijanet-eval-buffer)
#C-c C-l [Eval line] (ijanet-eval-line)
#C-c C-r [eval region] (ijanet-eval-region)

(defn calc-fuel
  [m]
  (let
      [m-new (max 0 (- (math/floor (/ m 3)) 2))]
    (if (pos? m-new)
      (+ m-new (calc-fuel m-new))
      0)))

(sum (map
      (fn [m] (calc-fuel (scan-number m)))
      (array/slice
       (string/split "\n" (slurp (os/realpath "d1.1.txt"))) 0 -2)))

