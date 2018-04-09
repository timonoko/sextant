
'(%Z%%M% %R%.%L%.%B%.%S% %E% %Y%)
'(MIKKO-3 (2 / 10 - 2002) (21 : 28 : 22 8))
(defq *package* APUJA)

(defun post-poned () (prog1 (reverse (apuja *POSTPONED-FLOAT*)) (setq *POSTPONED-FLOAT* nil)))

(defmacro postpone-float
 (x)
 (` setq *POSTPONED-FLOAT*
  (eval (cadr (make-float-expr (macroexpand '(cons , x *POSTPONED-FLOAT*)))))))

(defun koe2 ()
 (float (list (+ 1 2) (+ 300000 2))))

(defun list-macro
 (x)
 (if x
  (list 'cons (car x) (list-macro (cdr x)))))

(defun one-item/line
 (x)
 (if
  (atom x)
  (progn (print x) (cr))
  (progn
   (printc 40)
   (cr)
   (mapc x one-item/line)
   (printc 41)
   (cr))))

(defmacro tan
 (x)
 (list
  '/
  (list 'sin x)
  (list 'cos x)))

(defmacro cos
 (x)
 (list
  'sin
  (list '- '(/ pi 2) x)))

(defq *FLOAT-OPET*
 ((plus + 2 0)
  (difference - 2 0)
  (times * 2 0)
  (quotient / 2 0)
  (lessp l 2 0)
  (greaterp g 2 0)
  (eqn e 2 0)
  (sub1 - 2 1)
  (1- - 2 1)
  (add1 + 2 1)
  (1+ + 2 1)
  (sin s 1)
  (arctan r 1)
  (abs a 1)
  (sqrt q 1)
  (cons c 2 'n)
  (list list-macro *)
  (integer i 1)))

(defq pi 3.1415926536E+00)

(defun arctan (x) (apuja (list 'r x)))

(defun sexplode
 (x)
 (cons 32
  (if
   (atom x)
   (explode x)
   (let
    ((c (list nil)))
    (mapc x
     (function
      (lambda
       (y)
       (unless (atom y) (nconc c (list 32 40)))
       (nconc c (sexplode y))
       (unless (atom y) (nconc c (list 32 41))))))
    (cdr c)))))

(defun no-apuja
 (x)
 (if (equal (car x) 'apuja) (cadr x) x))

(defun format
 (y x)
 (apuja (list 'f x (or y 0))))

(defun sin (x) (apuja (list 's x)))

(defun koe ()
 (display-mode 18)
 (setq *POSTPONED-FLOAT*)
 (for
  (z 1 20)
  (color z)
  (for
   (x 0 200 2)
   (postpone-float
    (cons
     (* x 3)
     (integer
      (* 120 (+ (* 0.2 z) (sin (/ x z))))))))
  (point 0 0)
  (mapc
   (post-poned)
   (function (lambda (x) (draw (car x) (cdr x)))))))

(defun integer (x) (apuja (list 'i x)))

(defun fib
 (x)
 (float
  (if
   (< x 2)
   x
   (+ (fib (1- x)) (fib (- x 2))))))

(defmacro float (x) (make-float-expr (macroexpand x)))

(defun make-float-expr
 (x)
 (if
  (atom x)
  (if
   (and
    (identp x)
    (let
     ((x2 (car (explode x))))
     (or
      (< 47 x2 58)
      (member x2 '(43 45 46)))))
   (list 'quote x)
   x)
  (if
   (and (atom (car x)) (assoc (car x) *FLOAT-OPET*))
   (if
    (eq (caddr (assoc (car x) *FLOAT-OPET*)) '*)
    (make-float-expr
     ((eval (cadr (assoc (car x) *FLOAT-OPET*))) (cdr x)))
    (list
     'apuja
     (cons
      'list
      (cons
       (list 'quote (cadr (assoc (car x) *FLOAT-OPET*)))
       (cons
        (no-apuja (make-float-expr (cadr x)))
        (if
         (= 2 (caddr (assoc (car x) *FLOAT-OPET*)))
         (list
          (if
           (caddr x)
           (no-apuja (make-float-expr (caddr x)))
           (cadddr (assoc (car x) *FLOAT-OPET*))))))))))
   (cons (make-float-expr (car x)) (make-float-expr (cdr x))))))

(defun apuja
 (x)
 (out (create 'temp1.txt))
 (one-item/line x)
 (close (out))
 (out 0)
 (unless *APUJA-STRINGI*
  (setq *APUJA-STRINGI*
   (str-compress
    (quote
     (47 67 32 97 112 117 106 97 32 60 32 116 101 109
      112 49 46 116 120 116 32 62 32 116 101 109 112 50
      46 116 120 116)))))
 (fast-spawn () *APUJA-STRINGI*)
 (read-from-file 'temp2.txt))

(defq APUJA
 (post-poned postpone-float koe2 list-macro one-item/line tan
  cos *FLOAT-OPET* pi arctan sexplode no-apuja format sin
  koe integer fib float make-float-expr apuja APUJA))
