(import ./d2.1)

(defn gen-space
  []
  (var acc @[])
  (for i 0 100 (for j 0 100 (array/push acc {:noun i :verb j})))
  acc)

(defn get-puzzle
  []
  (string/split "," (string/slice (slurp (os/realpath "d2.1.txt")) 0 -2)))

(defn produce-result
  [noun verb]
  (+ (* noun 100) verb))

(defn search-for [outcome space]
  (var res 0)
  (each nv space
    (def start-state (populate-state (map scan-number (get-puzzle)) (nv :noun) (nv :verb)))
    (def final-state (exc-op start-state 0))
    (print nv outcome)
    (if (= outcome (final-state 0))
      (set res nv)))
  res)

#(def noun-verb (search-for 19690720 (gen-space)))
#(produce-result (noun-verb :noun) (noun-verb :verb))
