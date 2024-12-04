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
  ;; --------------------------------------------------------
  ;;                        3.1-create-account
  ;; --------------------------------------------------------
  
    ;; define a function create-account with parameters id, initial-balance, and keyset
    (defun create-account (id initial-balance keyset)
      @doc " define a function create-account with parameters id, initial-balance, and keyset "
      ;; uses enforce-keyset to ensure that the account is being created by the administrator
      (enforce-keyset 'admin-keyset)
      ;; uses enforce to ensure an initial-balance > 0
      (enforce (> initial-balance 0.0) "Initial balance should be greater than 0")
      ;; insert the initial-balance and keyset into the payments-table
      (insert payments-table id {"balance": initial-balance, "keyset": keyset})) 
    ;; --------------------------------------------------------
    ;;                        3.2-get-balance
    ;; --------------------------------------------------------
    
      ;; define a function get-balance that takes an argument id
      (defun get-balance (id)
        @doc " define a function get-balance that takes an argument id "
        ;; uses with-read to view the id from the payments-table
        ;; bind the value of the balance and keyset of the given id to variables named balance and keyset
        ;; use enforce-one to check that the keyset of the user calling the function is either the admin-keyset or the keyset of the provided id
        (with-read payments-table id {"balance":= balance, "keyset":= keyset}      
          (enforce-one "Access Denied" [(enforce-keyset 'admin-keyset) (enforce-keyset keyset)])
        ;; return balance
        balance))    
)