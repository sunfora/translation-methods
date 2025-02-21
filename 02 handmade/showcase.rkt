#lang scribble/manual
@(require (for-label racket))
@(require scribble-math)
@(require scribble/base)
@(require scribble/example)
@(require racket/sandbox)
@(require scribble-include-text)
@(require racket/file)
@(require scribble/core)
@(require scribble/html-properties)
@(require racket/port)
@(require racket/pretty)

@title[
       #:style (with-html5 manual-doc-style)
       #:tag "problem"
       #:version ""
       ]{showcase}

@section{Тестики и примеры}

@(define base-eval 
      (parameterize ([sandbox-output 'string]
                     [sandbox-error-output 'string]
                     [sandbox-memory-limit 50])
        (make-base-eval)))

@(base-eval '(require pict racket/port "lex.rkt" "parser.rkt" pict/tree-layout racket/match))

@(base-eval  
   '(define (draw-tree tree)
      (define (term-text txt)
              (cc-superimpose
                (filled-rectangle 30 30 #:color "white" 
                         #:border-color "blue")
                (text txt)))
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
     (naive-layered (viz tree) #:x-spacing 15)))

@(base-eval
 '(define (parse-string str)
    (call-with-input-string str parser)))
@(base-eval
 '(define (visual str)
    (draw-tree (parse-string str))))

@examples[ 
  #:label #f  
  #:eval base-eval

  (eval:error (parse-string " "))
  (visual "!a & (b ^ c | d)")
]
