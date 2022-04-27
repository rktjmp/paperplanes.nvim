(fn list-put [sequence val ?pos]
  "Insert value into [...] at position if given, returns sequence"
  (if ?pos
    (doto sequence (table.insert ?pos val))
    (doto sequence (table.insert val))))

(fn list-append [sequence seq]
  "Append sequence to tail of sequence, returns sequence"
  (accumulate [s sequence
               _ val (ipairs seq)]
              (doto s (table.insert val))))

(fn map-put [map key val]
  "Insert value into map under key, returns map"
  (doto map (tset key val)))

(fn reduce [enum into func]
  "reducer that calls pairs over enum"
  (accumulate [acc into key val (pairs enum)]
              (func key val acc)))

(fn ireduce [enum into func]
  "reducer that calls ipairs over enum"
  (accumulate [acc into idx val (ipairs enum)]
              (func idx val acc)))
{: ireduce
 : reduce
 : map-put
 : list-put
 : list-append}
