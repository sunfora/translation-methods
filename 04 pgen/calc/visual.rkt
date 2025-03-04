#lang racket
(require "types.rkt" "parser.rkt" pict pict/tree-layout racket/match)

(define (parse-string str)
  (call-with-input-string str parse))

(provide parse-string)
