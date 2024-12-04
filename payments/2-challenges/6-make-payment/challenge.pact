
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

  ;; --------------------------------------------------------
  ;;                          3.3-pay
  ;; --------------------------------------------------------
      
  ;; define a function named pay that takes parameters from, to, and amount
  (defun pay (from to amount)
      @doc " define a function named pay that takes parameters from, to, and amount "
      ;; use with-read to view the payments-table of the account from. bind the balance and keyset of this account to from-bal and keyset
      (with-read payments-table from {"balace":= from-bal, "ketset":= keyset}
        ;; enforce that the keyset is the keyset of the account
        (enforce-keyset keyset)
        ;; use with-read to view the balance of the to-bank account. bind this balance to a variable named to-bank-bal
        (with-read payments-table to {"balance":= to-bank-bal}
        ;; enforce that the amount being transferred is greater than 0
        (enforce (>= amount 0) "Amount being trasferred should be greater than 0")
        ;; enforce that the balance of the user transferring value is greater than what is being transferred
        (enforce (>= from-bal amount) "The balance of the user transferring value should be greater than what is being transferred")
        ;; update payments-table to reflect the new balance of the from account.
        (update payments-table from {"balance": (- from-bal amount)})        
        ;; update the payments-table to reflect the new balance of the to-bal account.
        (update payments-table to {"balance": (+ to-bank-bal amount)})
        
        ;; return a formatted string to say that the from account has paid the to account the amount paid
        (format "{} account has paid the {} account the {} paid" [from to amount]))))
)

;; ========================================================
;;                        4-create-table
;; ========================================================

;; create payments-table
(create-table payments-table)

;; ========================================================
;;                       5-create-accounts
;; ========================================================

;; create account for Sarah with initial value of 100.25
(create-account "Sarah" 100.25 (read-keyset "sarah-keyset"))
;; create account for James with initial value of 250.0
(create-account "James" 250.0 (read-keyset "james-keyset"))

;; ========================================================
;;                        6-make-payment
;; ========================================================

;; do payment of 25.0 from Sarah to James
(pay "Sarah" "James" 25.0)

;; read Sarah's balance as Sarah
(format "Sarah's balance is {}" [(get-balance "Sarah")])

;; read James' balance as JAMES
(format "James's balance is {}" [(get-balance "James")])