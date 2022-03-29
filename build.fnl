(local sn (require :supernova))

(local letters "ABCDEFGHIJKLMNOPQRSTUVWXYZ")

(local scopes (require :scopes))

(local colors {})

(local control {}) 

(fn exists? [candidate]
  (var index (length candidate))
  (var result false)
    
  (while (> index 0)
    (when (. control (string.sub candidate 1 index))
      (set result true))
    (set index (- index 1)))
  result)

(fn uniq []
  (var pending true)
  (var result nil)
  (while pending
   (let [rgb-color [(math.random 0 255) (math.random 0 255) (math.random 0 255)]
         name      (sn.name rgb-color)
         name      (string.lower (string.gsub name " " "-"))
         name      (string.gsub name "-.*" "")]
     (when (not (exists? name))
       (tset control name true)
       (set pending false)
       (set result name))))
  result)

(print (length scopes))

(each [_ scope (pairs scopes)]
  (let [name (uniq)]
    (tset colors scope {:scope scope :name name})))

(var contexts "")

(each [scope color (pairs colors)]
    (set contexts (.. contexts "    - match: " color.name))
    (set contexts (.. contexts "\n      scope: " scope "\n")))

(let [source-file (io.open "template.yml" :r)
            tempalte    (source-file:read :*all)
            result      (string.gsub tempalte "{PLACEHOLDER}" contexts)]
  (let [target-file (io.open "STColors.sublime-syntax" :w)]
    (target-file:write result)
    (target-file:close))
  (source-file:close))


(var demo "")

(var i 0)
(var previous nil)
(each [_ scope (ipairs scopes)]
  (let [color    (. colors scope)
        category (string.gsub scope "%..*" "")]
    (when (not= previous category)
      (set demo (.. demo "\n\n> " category "\n\n"))
      (set i 0))
    (set demo (.. demo color.name " "))
    (set i (+ i 1))
    (when (> i 5)
      (set demo (.. demo "\n"))
      (set i 0))
    (set previous category)

    ))

(let [demo-file (io.open "demo.stcolors" :w)]
    (demo-file:write demo)
    (demo-file:close))
