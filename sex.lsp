
'(%Z%%M% %R%.%L%.%B%.%S% %E% %Y%)
'(MIKKO-3 (2 / 10 - 2002) (23 : 13 : 11 32))
(defq *package* SEX)

(defun tan (x) (float (/ (sin x) (cos x))))

(defun sexkoe ()
 (let
  ((dee (date)) (tii (time)))
  (GHADECSEMI
   (nth 4 dee)
   (nth 2 dee)
   (nth 0 dee)
   (- (nth 0 tii) 3)
   (nth 2 tii)
   (nth 4 tii))
  (H_calcu GHA DEC 60 25)
  (list (format 2 Hc) (format 2 azimuth))))

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

(defun GHADECSEMI
 (year month day hour min sec)
 (load-coef month)
 (float
  (progn
   (setq UT (+ hour (/ min 60) (/ sec 3600)))
   (setq X (/ (+ day (/ UT 24)) 32))
   (setq R (+ R0 (* R1 X)))
   (setq DEC
    (+ Dec0
     (* X
      (+ Dec1
       (* X
        (+ Dec2 (* X (+ Dec3 (* Dec4 X)))))))))
   (setq E
    (+ E0
     (* X
      (+ E1
       (* X
        (+ E2 (* X (+ E3 (* E4 X)))))))))
   (setq SEMI (+ SD0 (* SD1 X)))
   (setq GHA_Aries (+ R UT))
   (setq GHA (mod360 (* 15 (+ E UT)))))))

(defun load-coef
 (month)
 (in (open 'newdata.dat))
 (repeat
  (setq Month_number (read))
  (setq R0 (read))
  (setq R1 (read))
  (setq Dec0 (read))
  (setq Dec1 (read))
  (setq Dec2 (read))
  (setq Dec3 (read))
  (setq Dec4 (read))
  (setq E0 (read))
  (setq E1 (read))
  (setq E2 (read))
  (setq E3 (read))
  (setq E4 (read))
  (setq SD0 (read))
  (setq SD1 (read))
  (= Month_number month))
 (close (in))
 (in 0))

(defun rad (x) (float (* pi (/ x 180))))

(defun degrees (x) (float (/ (* x 180) pi)))

(defq SEX
 (tan sexkoe koe GHADECSEMI load-coef rad degrees SEX mod360 expt H_calcu arcsin arccos))

(defun mod360
 (x)
 (float
  (if
   (< x 0)
   (mod360 (+ x 360))
   (if (> x 360) (mod360 (- x 360)) x))))

(defun expt
 (x y)
 (float
  (if
   (= y 0)
   1
   (* x (expt x (- y 1))))))

(defun H_calcu
 (GHA DEC lat long)
 (float
  (let
   ((S) (C) (X) (A))
   (setq LHA (mod360 (+ GHA long)))
   (setq S (sin (rad DEC)))
   (setq C (* (cos (rad DEC)) (cos (rad LHA))))
   (setq Hc
    (degrees
     (arcsin
      (+
       (* S (sin (rad lat)))
       (* C (cos (rad lat)))))))
   (setq X
    (/
     (-
      (* S (cos (rad lat)))
      (* C (sin (rad lat))))
     (cos (rad Hc))))
   (if
    (> X 1)
    (setq X 1)
    (if (< X -1) (setq X -1)))
   (setq A (degrees (arccos X)))
   (if (> A 0) (setq A (- A 180)))
   (if
    (> LHA 180)
    (setq azimuth A)
    (setq azimuth (- 0 A)))
   Hc)))

(defun arcsin
 (x)
 (float
  (arctan (/ x (sqrt (- 1 (* x x)))))))

(defun arccos
 (x)
 (float
  (arctan (/ (sqrt (- 1 (* x x))) x))))
