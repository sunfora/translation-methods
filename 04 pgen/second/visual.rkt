#lang racket
(require "types.rkt" "parser.rkt" pict pict/tree-layout racket/match)

(define (calc str)
  (call-with-input-string str parse))

(provide calc)
