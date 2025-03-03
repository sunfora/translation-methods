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

@(base-eval '(require "visual.rkt"))

@examples[ 
  #:label #f  
  #:eval base-eval

  (eval:error (parse-string " "))
  (visual "!a & b")
]
