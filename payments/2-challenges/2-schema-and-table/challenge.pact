;; ========================================================
;;                   1-module-and-keyset
;; ========================================================

;; define and read a keyset named admin-keyset
(define-keyset 'admin-keyset (read-keyset "admin-keyset"))
;; create a module named payments that gives access to admin-keyset
(module payments-module 'admin-keyset
;; ========================================================
;;                   2-define-schemas-and-table
;; ========================================================
;; define the schema for payments including balance as type decimal and keyset as type keyset
  (defschema payments
    @doc " payments schema "
    balance:decimal
    keyset:keyset
  )
  ;; define the payments-table using the schema {payments} created above
  (deftable payments-table:{payments})
)