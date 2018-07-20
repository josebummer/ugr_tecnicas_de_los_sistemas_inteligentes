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
  :equality ;; Añado esto para las comparaciones

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
            (destino ?p - person ?c - city) ;; Para tener almacenado los destinos de las personas
            (no-puede-volar ?a) ;; Para saber si por la duracion del vuelo el avión ya no puede volar más
            (puede-volar ?a);; Al contrario que el anterior
             )
(:functions (fuel ?a - aircraft)
            (distance ?c1 - city ?c2 - city)
            (slow-speed ?a - aircraft)
            (fast-speed ?a - aircraft)
            (slow-burn ?a - aircraft)
            (fast-burn ?a - aircraft)
            (capacity ?a - aircraft)
            (refuel-rate ?a - aircraft)
            (pasajeros ?a - aircraft) ;;Para saber el número de pasajeros que lleva un avion determinado
            (max-pasajeros ?a - aircraft);; Para saber el número máximo de pasajeros que puede llevar un avion determinado.
            (total-fuel-used ?a - aircraft) ;; Modifico esta función para indicar el total del fuel por avion
            (duracion ?a - aircraft);; Duración de vuelo de cada avion
            (max-duracion ?a - aircraft);; Duracion maxima del vuelo de un avion
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
  (<= (+ (total-fuel-used ?a) (* (distance ?c1 ?c2) (slow-burn ?a))) (fuel-limit)))
  
;; Exactamente igual que el anterior pero para vuelos rápidos
(:derived 
  
  (cumple-fuel-limit-fast ?a - aircraft ?c1 - city ?c2 - city)
  (<= (+ (total-fuel-used ?a) (* (distance ?c1 ?c2) (fast-burn ?a))) (fuel-limit)))

;;Compruebo si el avión puede volar más con el límite de las horas de vuelo
(:derived 
  
  (puede-volar ?a - aircraft)
  (< (duracion ?a) (max-duracion ?a)))

;; Al contrario que el anterior, compruebo que ya no puede volar por las horas de vuelo que lleva
(:derived 
  
  (no-puede-volar ?a - aircraft)
  (>= (duracion ?a) (max-duracion ?a)))

;; Esta tarea la he creado para embarcar a todos los pasajeros que se encuentren en una misma ciudad, y lleven el mismo destino.
;;El avion y persona estan en la misma ciudad, entonces embarca a todas las personas que se encuentren en esa
;; ciudad y tengan el mismo destino
(:task embarcar
	:parameters(?a - aircraft ?c - city)
	
	(:method recurre1
		:precondition (and (at ?p - person ?c1 - city)
						(at ?a - aircraft ?c1 - city)
						(destino ?p - person ?c - city)
						(< (pasajeros ?a) (max-pasajeros ?a)))
		:tasks (
				(board ?p ?a ?c1)
				(embarcar ?a ?c)
		)
	)
	
	(:method caso-base
   :precondition():tasks())
)

;; Igual que el anterior pero para desembarcar, es decir,
;; el avion esta en la ciudad destino de una persona, por lo que desembarca a todas las personas que su ciudad destino sea esa.
(:task desembarcar
	:parameters(?a - aircraft ?c - city)
	
	(:method recurre1
		:precondition (and (in ?p - person ?a - aircraft)
						(at ?a - aircraft ?c - city)
						(destino ?p - person ?c - city))
		:tasks (
				(debark ?p ?a ?c)
				(desembarcar ?a ?c)
		)
	)
	
	(:method caso-base
   :precondition():tasks())
)


;; Modifico ahora esta tarea para hacerla recursiva, por lo que elimino los parámetros que tenía anteriormente.
(:task transport-persons
	:parameters ()
 
   (:method Case1 ;si esta montada en el avion y el avion esta en la ciudad destino de la persona
	  :precondition (and (in ?p - person ?a - aircraft)
                        (destino ?p - person ?c - city)
			                 (at ?a - aircraft ?c - city)
                       (= ?c ?c)
                  )
				     
	  :tasks ( 
	  	      (desembarcar ?a ?c)
            (transport-persons)
            )
  )

  (:method Case2 ;Si no puedo hacer nada por las restricciones y tengo pasajeros, los suelto
	  :precondition (and (in ?p - person ?a - aircraft)
                        (at ?a - aircraft ?c - city)
                       (no-puede-volar ?a))
				     
	  :tasks ( 
            (debark ?p ?a ?c)
            (transport-persons)
      ))
				
				
	(:method Case3 ;si no est� en la ciudad destino y avion y persona estan en la misma ciudad y el avion esta vacio
	  :precondition (and (at ?p - person ?c1 - city)
			                 (at ?a - aircraft ?c1 - city)
                       (destino ?p - person ?c -city)
                       (not (= ?c1 ?c))
                       (not (in ?p2 - person ?a - aircraft))
                       (< (pasajeros ?a) (max-pasajeros ?a))
                       (puede-volar ?a))
				     
	  :tasks ( 
		        (embarcar ?a ?c)
            (transport-persons))
      )

  (:method Case6 ;si no esta en la ciudad destino y el avion y la persona no estan en la misma ciudad y el avion esta vacio
	  :precondition (and (at ?p - person ?c1 - city)
                        (not (destino ?p - person ?c1 - city))
			                 (at ?a - aircraft ?c2 - city)
                       (not (= ?c1 ?c2))
                       (not (in ?p2 - person ?a - aircraft))
                       (puede-volar ?a))
				     
	  :tasks ( 
		        (mover-avion ?a ?c2 ?c1)
            (transport-persons))
      )

    (:method Case4 ;si no est� en la ciudad destino y avion y persona estan en la misma ciudad, el avion tiene pasajeros con mismo destino
	  :precondition (and (at ?p1 - person ?c1 - city)
			                 (at ?a - aircraft ?c1 - city)
                       (destino ?p1 - person ?c -city)
                       (not (= ?c1 ?c))
                       (in ?p2 - person ?a - aircraft)
                       (destino ?p2 - person ?c -city)
                       (< (pasajeros ?a) (max-pasajeros ?a))
                       (puede-volar ?a))
				     
	  :tasks ( 
		        (embarcar ?a ?c)
            (transport-persons))
  )

  (:method Case5 ;si no est� en la ciudad destino y avion y persona estan en la misma ciudad, el avion tiene pasajeros con distinto destino
	  :precondition (and (at ?p1 - person ?c1 - city)
			                 (at ?a - aircraft ?c1 - city)
                       (destino ?p1 - person ?c -city)
                       (not (= ?c1 ?c))
                       (in ?p2 - person ?a - aircraft)
                       (destino ?p2 - person ?c2 - city)
                       (not (= ?c ?c2))
                       (<= (+ (distance ?c1 ?c2) (distance ?c2 ?c)) (+ (+ (distance ?c1 ?c2) (distance ?c2 ?c1)) (distance ?c1 ?c)))
                       (< (pasajeros ?a) (max-pasajeros ?a))
                       (puede-volar ?a))
				     
	  :tasks ( 
		        (embarcar ?a ?c)
            (embarcar ?a ?c2)
            (transport-persons))
  )
		

    (:method Case7 ;si el avion y la persona no estan en la misma ciudad y el avion lleva gente con mismo destino
	  :precondition (and (at ?p - person ?c1 - city)
                        (destino ?p - person ?c2 - city)
			                 (at ?a - aircraft ?c3 - city)
                       (not (= ?c1 ?c2))
                       (not (= ?c1 ?c3))
                       (in ?p2 - person ?a - aircraft)
                       (destino ?p2 - person ?c2 - city)
                       (= ?p2 ?p2)
                       (= ?c2 ?c2)
                       (< (pasajeros ?a) (max-pasajeros ?a))
                       (puede-volar ?a))
				     
	  :tasks ( 
            (embarcar ?a ?c1)
            (embarcar ?a ?c2)
		        (mover-avion ?a ?c3 ?c1)
            (transport-persons))
      )

      (:method Case8 ;si el avion y la persona no estan en la misma ciudad y el avion lleva gente con distinto destino
	  :precondition (and (at ?p - person ?c1 - city)
                        (destino ?p - person ?c3 - city)
			                 (at ?a - aircraft ?c2 - city)
                       (not (= ?c1 ?c2))
                       (not (= ?c1 ?c3))
                       (in ?p2 - person ?a - aircraft)
                       (destino ?p2 - person ?c - city)
                       (not (= ?c ?c1))
                       (not (= ?c ?c2))
                       (not (= ?c ?c3))
                       (< (pasajeros ?a) (max-pasajeros ?a))
                       (<= (+ (+ (distance ?c2 ?c1) (distance ?c1 ?c3)) (distance ?c3 ?c) ) (+ (+ (distance ?c2 ?c) (distance ?c ?c1)) (distance ?c1 ?c3) ))
                       (puede-volar ?a))
				     
	  :tasks ( 
            (embarcar ?a ?c1)
            (embarcar ?a ?c)
            (embarcar ?a ?c3)
		        (mover-avion ?a ?c2 ?c1)
            (transport-persons))
      )


      (:method Case9 ;ya estaría la gente cargada, ahora toca llevar a la gente a sus destinos
	  :precondition (and (in ?p - person ?a - aircraft)
                        (at ?a - aircraft ?c1 - city)
                        (destino ?p - person ?c - city)
                        (not (= ?c1 ?c))
                       (puede-volar ?a))
				     
	  :tasks ( 
            (mover-avion ?a ?c1 ?c)
            (transport-persons)
      ))

      (:method Caso-base ;caso base para finalizar
	  :precondition ()
				     
	  :tasks ()
      )
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

   ;; Por último, si no puede volar significaría que no cumple las restricciones del fuel
   ;; por lo que ponemos a ese avión con su duración de vuelo al máximo del mismo para que suelte
   ;; a los pasajeros y así pueda llevarlos otro avión

  (:method no-puede-moverse
  :precondition ()
  :tasks (
          (:inline () (assign (duracion ?a) (max-duracion ?a)))
         )
   )

  )
 
(:import "Primitivas-Zenotravel.pddl") 


)
