(local fmt string.format)

;; Encoder nicked from http://lua-users.org/wiki/BaseSixtyFour
(fn encode [content]
  (fn transpose [i]
    (let [enc-map [:A :B :C :D :E :F :G :H :I :J :K :L :M :N :O :P
                   :Q :R :S :T :U :V :W :X :Y :Z :a :b :c :d :e :f
                   :g :h :i :j :k :l :m :n :o :p :q :r :s :t :u :v
                   :w :x :y :z :0 :1 :2 :3 :4 :5 :6 :7 :8 :9 :+ :/]]
      (. enc-map (+ 1 i))))

  (fn three-wide->four-wide [three-char-wide-string]
    (let [(a b c) (string.byte three-char-wide-string 1 3)]
      (.. (transpose (-> (bit.rshift a 2)))
          (transpose (-> (bit.band a 3)
                         (bit.lshift 4)
                         (bit.bor (bit.rshift b 4))))
          (transpose  (-> (bit.band b 15)
                          (bit.lshift 2)
                          (bit.bor (bit.rshift c 6))))
          (transpose (-> (bit.band c 63))))))

  (let [padding (-> (length content)
                    (- 1)
                    (% 3)
                    (* -1)
                    (+ 2))
        unpadded (-> (.. content (string.rep "\0" padding))
                     (string.gsub "..." three-wide->four-wide))
        padded (-> unpadded
                   (string.sub 1 (-> (# unpadded)
                                     (- padding)))
                   (.. (string.rep := padding)))]
    (values padded)))

(fn provide [content metadata opts on-complete]
  ;; TODO: an industrious person could create a metadata.filetype -> ray.so language map
  (let [default-opts {:padding 64 ; 16 32 64 128
                      :language :auto
                      :darkmode false
                      :colors :midnight ; candy breeze midnight sunset crimson falcon meadow raindrop
                      :background true}
        encoded (encode content)
        title (or metadata.filename "untitled")
        url (fmt "https://ray.so?title=%s&padding=%d&colors=%s&language=%s&background=%s&darkMode=%s&code=%s"
                 (or opts.title metadata.filename "untilted") ;; note: set via metadata not provider options
                 (or opts.padding default-opts.padding)
                 (or opts.colors default-opts.colors)
                 (or opts.language default-opts.language)
                 (or opts.background default-opts.background)
                 (or opts.darkmode default-opts.darkmode)
                 encoded)]
    (on-complete url nil)))

(values provide)
