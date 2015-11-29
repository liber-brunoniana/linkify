#lang racket
(require racket/function
         racket/list
         racket/match
         racket/string
         xml
         sugar
         frog/xexpr-map
         xml/xexpr)


; this function is what maps the HTML tree to a linkified tree
(define (linkify-xexpr str href)
  (lambda (xexpr parents)
    (match* (xexpr parents)
      ;; Match text not under an anchor tag
      [((? string? s) (not (list-no-order `(a . ,_) _ ...)))
       (list* (add-between (regexp-split (pregexp (string-append "\\b" str "\\b")) s) `(a ([href ,href]) ,str)))]
      [(x _) `(,x)])))


(define files
  (list->set
   (filter-not (compose (curry regexp-match? #rx",") path->string)
               (filter (compose (curry regexp-match? #rx"html") path->string)
                       (directory-list "../import/")))))

(define people-files
  (list->set
   (filter (compose (curry regexp-match? #rx",") path->string)
               (filter (compose (curry regexp-match? #rx"html") path->string)
                       (directory-list "../import/")))))
(define (name->fil n)
  (let ([m (flatten
            (map (curryr string-split " ")
                 (string-split n ",")))])
    (if (< (length m) 3)
        (name->fl n)
        (string-append (second m) " " (third m) " " (first m)))))

(define (name->fl n)
  (let ([m (flatten
            (map (curryr string-split " ")
                 (string-split n ",")))])
    (string-append (second m) " " (first m))))

(define (linkify f fs blas)
  (call-with-input-file* (build-path "../import/" f)
    (λ (p) (foldl (λ (e s)
                    (let ([x (xexpr-map (linkify-xexpr (blas (path->string (remove-ext e))) (path->string e)) s)])
                      x))
                  ((compose string->xexpr
                            (λ (v) (string-append "<article>" v "</article>"))
                            port->string) p)
                  (set->list fs)))))


(displayln "Stage 1")
(for/set ([f files])
  (displayln f)
  (let ([m (xexpr->string (linkify f (set-remove files f) identity))])
    (with-output-to-file
        (build-path "../import/" f)
      (thunk (printf m))
      #:exists 'replace)))

(displayln "Stage 2")
(for/set ([f files])
  (displayln f)
  (let ([m (xexpr->string (linkify f (set-remove people-files f) identity))])
    (with-output-to-file
        (build-path "../import/" f)
      (thunk (printf m))
      #:exists 'replace)))

(displayln "Stage 3")
(for/set ([f files])
  (displayln f)
  (let ([m (xexpr->string (linkify f (set-remove people-files f) name->fl))])
    (with-output-to-file
        (build-path "../import/" f)
      (thunk (printf m))
      #:exists 'replace)))

(displayln "Stage 4")
(for/set ([f files])
  (displayln f)
  (let ([m (xexpr->string (linkify f (set-remove people-files f) name->fil))])
    (with-output-to-file
        (build-path "../import/" f)
      (thunk (printf m))
      #:exists 'replace)))
