#lang racket
(require "lex.rkt" "parser.rkt" pict pict/tree-layout racket/match)

(define (draw-tree tree)
    (define (term-text txt)
      (define txt-pict (text txt))
            (cc-superimpose
              (filled-rectangle (+ (pict-width txt-pict) 20) 
                                (+ (pict-height txt-pict) 10) 
                                #:color "white" 
                                #:border-color "blue")
              txt-pict))
    (define (nont-text txt)
            (cc-superimpose
              (disk 30   #:color "white" 
                         #:draw-border? #t)
              (text txt)))
   (define (nont-node v)
      (nont-text (symbol->string (object-name v))))
   (define (term-lay txt)
     (tree-layout #:pict 
                  (term-text txt)))

   (define (many-children? x)
     (and (list? x) (not (null? x))))

   (define (viz v)
     (match v
       [(list)
        (term-lay "ε")]
       [(token pos txt) 
        (term-lay txt)]
       [(node (? many-children? x))
        (apply tree-layout #:pict (nont-node v)
               (map viz x))]
       [(node x)
        (tree-layout #:pict (nont-node v)
                     (viz x))]))
   (naive-layered (viz tree) #:x-spacing 15))


(define (parse-string str)
  (call-with-input-string str parser))
(define (visual str)
  (draw-tree (parse-string str)))

(provide parse-string visual)
