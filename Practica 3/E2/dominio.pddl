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
            )

;; el consecuente "vac�o" se representa como "()" y significa "siempre verdad"
(:derived
  (igual ?x ?x) ())

(:derived 
  (different ?x ?y) (not (igual ?x ?y)))



;; este literal derivado se utiliza para deducir, a partir de la información en el estado actual, 
;; si hay fuel suficiente para que el avión ?a vuele de la ciudad ?c1 a la ?c2
;; se actualiza el significado de este derivada para comprobar realmente con la distancia
;; si se tiene la suficiente gasolina para poder volar desde una ciudad a otra.
(:derived 
  
  (hay-fuel ?a - aircraft ?c1 - city ?c2 - city)
  (>= (fuel ?a) (* (distance ?c1 ?c2) (slow-burn ?a))))

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
				
				
	(:method Case3 ;si no esta en la ciudad destino y avion y persona estan en distinta ciudad
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
 (:method fuel-suficiente ;; este método se escogerá para usar la acción fly siempre que el avión tenga fuel para
                          ;; volar desde ?c1 a ?c2
			  ;; si no hay fuel suficiente el método no se aplicará y la descomposición de esta tarea
			  ;; se intentará hacer con otro método. Cuando se agotan todos los métodos posibles, la
			  ;; descomponsición de la tarea mover-avión "fallará". 
			  ;; En consecuencia HTNP hará backtracking y escogerá otra posible vía para descomponer
			  ;; la tarea mover-avion (por ejemplo, escogiendo otra instanciación para la variable ?a)
  :precondition (hay-fuel ?a ?c1 ?c2)
  :tasks (
          (fly ?a ?c1 ?c2)
         )
   )
   
   
   (:method fuel-insuficiente ;Añadimos este método para en el caso de que el método anterior no se cumpla,
                              ;; lo cual significaría que no tiene fuel, pasaría a comprobar este otro método,
                              ;; y lo que haría sería darse cuenta de que no tiene fuel y repostar para volar.
  :precondition (not(hay-fuel ?a ?c1 ?c2))
  :tasks (
          (refuel ?a ?c1)
		  (fly ?a ?c1 ?c2)
         )
   )
  )
 
(:import "Primitivas-Zenotravel.pddl") 


)
