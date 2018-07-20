(define (domain zeno-travel)


(:requirements
  :typing
  :fluents
  :derived-predicates
  :negative-preconditions
  :universal-preconditions
  :disjuntive-preconditions
  :conditional-effects
  :htn-expansion

  ; Requisitos adicionales para el manejo del tiempo
  :durative-actions
  :metatags
 )

(:types aircraft person city - object)
(:constants slow fast - object)
(:predicates (at ?x - (either person aircraft) ?c - city)
             (in ?p - person ?a - aircraft)
             (different ?x ?y) (igual ?x ?y)
             (hay-fuel ?a ?c1 ?c2)
			 (hay-fuel-fast ?a ?c1 ?c2) ;; Para la comprobacion de si tenemos fuel pero viajando rapido (zoom) en vez de lento (fly)
			 (cumple-fuel-limit ?a ?c1 ?c2) ;; Para comprobar si cumple la condicion del limite de fuel para volar lentamente.
			 (cumple-fuel-limit-fast ?a ?c1 ?c2) ;; Igual que el anterior pero para los vuelos rapidos
             )
(:functions (fuel ?a - aircraft)
            (distance ?c1 - city ?c2 - city)
            (slow-speed ?a - aircraft)
            (fast-speed ?a - aircraft)
            (slow-burn ?a - aircraft)
            (fast-burn ?a - aircraft)
            (capacity ?a - aircraft)
            (refuel-rate ?a - aircraft)
            (total-fuel-used)
            (boarding-time)
            (debarking-time)
			(fuel-limit) ;; Variable para tener el valor del limite de fuel
            )

;; el consecuente "vac�o" se representa como "()" y significa "siempre verdad"
(:derived
  (igual ?x ?x) ())

(:derived 
  (different ?x ?y) (not (igual ?x ?y)))



;; este literal derivado se utiliza para deducir, a partir de la información en el estado actual, 
;; si hay fuel suficiente para que el avión ?a vuele de la ciudad ?c1 a la ?c2
;; el antecedente de este literal derivado comprueba si el fuel actual de ?a es mayor que 1. 
;; En este caso es una forma de describir que no hay restricciones de fuel. Pueden introducirse una
;; restricción más copleja  si en lugar de 1 se representa una expresión más elaborada (esto es objeto de
;; los siguientes ejercicios).
(:derived 
  
  (hay-fuel ?a - aircraft ?c1 - city ?c2 - city)
  (>= (fuel ?a) (* (distance ?c1 ?c2) (slow-burn ?a))))
  

;;Exactamente igual que el anterior pero comprobando para un vuelo rapido en vez de un lento.
(:derived 
  
  (hay-fuel-fast ?a - aircraft ?c1 - city ?c2 - city)
  (>= (fuel ?a) (* (distance ?c1 ?c2) (fast-burn ?a))))
  
  
;; Aquí compruebo si el fuel que lleva más el que va a gastar supera el límite establecido para ver si puede volar o no (fly).
(:derived 
  
  (cumple-fuel-limit ?a - aircraft ?c1 - city ?c2 - city)
  (<= (+ (total-fuel-used) (* (distance ?c1 ?c2) (slow-burn ?a))) (fuel-limit)))
  
;; Exactamente igual que el anterior pero para vuelos rápidos
(:derived 
  
  (cumple-fuel-limit-fast ?a - aircraft ?c1 - city ?c2 - city)
  (<= (+ (total-fuel-used) (* (distance ?c1 ?c2) (fast-burn ?a))) (fuel-limit)))

(:task transport-person
	:parameters (?p - person ?c - city)
	
  (:method Case1 ; si la persona est� en la ciudad no se hace nada
	 :precondition (at ?p ?c)
	 :tasks ()
   )
	 
   
   (:method Case2 ;si no est� en la ciudad destino, pero avion y persona est�n en la misma ciudad
	  :precondition (and (at ?p - person ?c1 - city)
			                 (at ?a - aircraft ?c1 - city))
				     
	  :tasks ( 
	  	      (board ?p ?a ?c1)
		        (mover-avion ?a ?c1 ?c)
		        (debark ?p ?a ?c )))
				
				
	(:method Case3 ;si no est� en la ciudad destino y avion y persona estan en distinta ciudad
	  :precondition (and (at ?p - person ?c1 - city)
			                 (at ?a - aircraft ?c2 - city))
				     
	  :tasks ( 
		        (mover-avion ?a ?c2 ?c1)
				(board ?p ?a ?c1)
				(mover-avion ?a ?c1 ?c)
				(debark ?p ?a ?c)))
				
	
				
	)
	
(:task mover-avion
 :parameters (?a - aircraft ?c1 - city ?c2 -city)
 
;;Priorizamos primero el vuelo rápido, por lo que lo ponemos en primer lugar para comprobar si podemos volar rápido directamente.

 (:method fuel-suficiente-fast
  :precondition (and (hay-fuel-fast ?a ?c1 ?c2) (cumple-fuel-limit-fast ?a ?c1 ?c2))
  :tasks (
          (zoom ?a ?c1 ?c2)
         )
   )
   
  ;; Despúes, si no tenemos fuel para volar rápido, seguimos priorizandolo y vemos si rellenando el fuel podemos volar rápido sin excedernos del límite.
   (:method fuel-insuficiente-fast
  :precondition (and (not(hay-fuel-fast ?a ?c1 ?c2)) (cumple-fuel-limit-fast ?a ?c1 ?c2))
  :tasks (
          (refuel ?a ?c1)
		  (zoom ?a ?c1 ?c2)
         )
   )

  ;; Y si no hay forma de volar rápido, ya tenemos los métodos de los ejercicios anteriores para volar lento.
 
 (:method fuel-suficiente ;; este método se escogerá para usar la acción fly siempre que el avión tenga fuel para
                          ;; volar desde ?c1 a ?c2
			  ;; si no hay fuel suficiente el método no se aplicará y la descomposición de esta tarea
			  ;; se intentará hacer con otro método. Cuando se agotan todos los métodos posibles, la
			  ;; descomponsición de la tarea mover-avión "fallará". 
			  ;; En consecuencia HTNP hará backtracking y escogerá otra posible vía para descomponer
			  ;; la tarea mover-avion (por ejemplo, escogiendo otra instanciación para la variable ?a)
  :precondition (and (hay-fuel ?a ?c1 ?c2) (cumple-fuel-limit ?a ?c1 ?c2))
  :tasks (
          (fly ?a ?c1 ?c2)
         )
   )
   
   ;Si  no tiene fuel, pasaría a comprobar este otro método,
    ;; y lo que haría sería darse cuenta de que no tiene fuel y repostar para volar (fly).
   
   (:method fuel-insuficiente
  :precondition (and (not(hay-fuel ?a ?c1 ?c2)) (cumple-fuel-limit ?a ?c1 ?c2))
  :tasks (
          (refuel ?a ?c1)
		  (fly ?a ?c1 ?c2)
         )
   )
  )
 
(:import "Primitivas-Zenotravel.pddl") 


)
