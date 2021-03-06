(in-package #:kd)

(defun-with-dbg get-triangle-bounds (patch triangle axis)
  (let* ((?0 (get-coord-by-indexes patch triangle 0 axis))
         (?1 (get-coord-by-indexes patch triangle 1 axis))
         (?2 (get-coord-by-indexes patch triangle 2 axis)))
    (values (min ?0 ?1 ?2)
            (max ?0 ?1 ?2))))

(defun-with-dbg old-sah (patch aabb axis-index triangles)
  (let* ((aabb (corners aabb))
         (div-position  (+ 0.25 (random 0.5))))
    (+ (nth axis-index aabb)
       (* div-position (- (nth (+ 3 axis-index) aabb)
                          (nth axis-index aabb))))))

(defun-with-dbg sah (patch axis-index triangles)
  (labels ((sah-cost (pos)
             (let ((CostTrav 1.0)
                   (CostIntersect 1.0)
                   (LeftArea  0.0)
                   (RightArea 0.0)
                   (LeftCount  0)
                   (RightCount 0)
                   (counter 0))
               (dolist (tri triangles)
                 (multiple-value-bind (L R) (get-triangle-bounds patch tri axis-index)
                   (let ((squa (aref (squares patch) counter)))
                     (incf counter)
                     (if (> L pos)
                         (progn ;; rightside
                           (incf RightArea squa)
                           (incf RightCount))
                         (if (< R pos)
                             (progn ;; leftside
                               (incf LeftArea squa)
                               (incf LeftCount))
                             (progn ;; both sides
                               (incf RightArea squa)
                               (incf LeftArea squa)
                               (incf RightCount)
                               (incf LeftCount)))))))
               (+ CostTrav
                  (* CostIntersect
                     (+ (* LeftArea LeftCount)
                        (* RightArea RightCount)))))))
    (let* ((unique-bounds (sort (iter (for tri in triangles)
                                      (for i from 0 below (length triangles))
                                      (multiple-value-bind (left-bound right-bound) (get-triangle-bounds patch tri axis-index)
                                        (adjoining left-bound)
                                        (adjoining right-bound)))
                                #'<))
           (min-pos (car unique-bounds))
           (min-val (sah-cost min-pos))
           (all-sah-values (iter (for position in unique-bounds)
                                 (let ((current-value (sah-cost position)))
                                   (adjoining (list position current-value))
                                   (when (< current-value min-val)
                                     (setf min-val current-value)
                                     (setf min-pos position))))))

      ;; (with-dbg-header 3 (("--------------------~%Running on ~a triangles (result is [~,3f,~,3f]"
      ;;                      (length triangles) min-pos min-val)
      ;;                     (dump all-sah-values)))
      
      (values min-pos
              min-val
              all-sah-values))))
