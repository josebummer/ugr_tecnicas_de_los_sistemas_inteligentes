(define (domain belkan-domain)	       ; Comment: adding location caused fail
	(:requirements :strips :equality :typing)
	(:types  jugador personajes objetos  - locatable
			location
			orienta)
	
	(:predicates 
		(tiene ?x - location ?y - location ?o - orienta )
		(esta ?x - locatable ?y - location)
		(llevaMano ?y - objetos)
		(mano ?j)
		(orientacion ?o - orienta)
		(libre ?x - location)
		(tieneobjeto ?x - personajes)
	)
  
	(:action GIRAR-IZQUIERDA
	     :parameters (?o - orienta)
	     :precondition (orientacion ?o)
	     :effect (and (when (orientacion norte) (and (not(orientacion ?o)) (orientacion oeste) ))
					(when (orientacion oeste) (and (not(orientacion ?o)) (orientacion sur) ))
					(when (orientacion sur) (and (not(orientacion ?o)) (orientacion este) ))
					(when (orientacion este) (and (not(orientacion ?o)) (orientacion norte) ))
				 )
	)

	(:action GIRAR-DERECHA
	     :parameters (?o - orienta)
	     :precondition (orientacion ?o)
	     :effect (and (when (orientacion norte) (and (not(orientacion ?o)) (orientacion este) ))
					(when (orientacion oeste) (and (not(orientacion ?o)) (orientacion norte) ))
					(when (orientacion sur) (and (not(orientacion ?o)) (orientacion oeste) ))
					(when (orientacion este) (and (not(orientacion ?o)) (orientacion sur) ))
				 )
	)

	(:action COGER
			:parameters (?j - jugador ?l - location ?ob - objetos)
			:precondition (and (esta ?j ?l) (esta ?ob ?l) (not(mano ?j)))
			:effect (and (mano ?j) (llevaMano ?ob) (not(esta ?ob ?l)) (libre ?l))
	)
	
	(:action DEJAR
			:parameters (?j - jugador ?l - location ?ob - objetos)
			:precondition (and (esta ?j ?l) (libre ?l) (llevaMano ?ob))
			:effect (and (not(llevaMano ?ob)) (not(mano ?j)) (not(libre ?l)) (esta ?ob ?l))
	)

	(:action ENTREGAR
			:parameters (?j - jugador ?l - location ?p - personajes ?ob - objetos)
			:precondition (and (esta ?j ?l) (esta ?p ?l) (llevaMano ?ob))
			:effect (and (not(llevaMano ?ob)) (not(mano ?j)) (tieneobjeto ?p))
	)

	(:action IR
			:parameters (?j - jugador ?l1 - location ?l2 - location ?o - orienta)
			:precondition (and (esta ?j ?l1) (orientacion ?o) (tiene ?l1 ?l2 ?o))
			:effect (and (not(esta ?j ?l1)) (esta ?j ?l2))
	)
)