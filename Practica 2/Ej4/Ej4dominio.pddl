(define (domain belkan-domain)	       ; Comment: adding location caused fail
	(:requirements :adl :typing :fluents)
	(:types  jugador personajes objetos  - locatable
			location
			orienta
			zonas)
	
	(:predicates 
		(tiene ?x - location ?y - location ?o - orienta )
		(esta ?x - locatable ?y - location)
		(llevaMochila ?x - objetos)
		(llevaMano ?x - objetos)
		(mano ?x - jugador)
		(mochila ?x - jugador)
		(orientacion ?x - orienta)
		(libre ?x - location)
		(tieneobjeto ?x - personajes)
		(es ?x - location ?y - zonas)
		(llevoBikini ?j)
		(llevoZapatillas ?j)
	)

	(:functions
		(distancia ?x ?y - location)
		(distancia-total)
		(puntos ?x - personajes ?y - objetos)
		(puntos-totales)
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
			:effect (and (when (esta bikini ?l) (llevoBikini ?j)) (when (esta zapatillas ?l) (llevoZapatillas ?j)) (llevaMano ?ob) (not(esta ?ob ?l)) (libre ?l) (mano ?j))
	)

	(:action DEJAR
			:parameters (?j - jugador ?l - location ?ob - objetos)
			:precondition (and (esta ?j ?l) (libre ?l) (llevaMano ?ob) (not(es ?l agua)) (not(es ?l bosque)))
			:effect (and (when (and (llevaMano bikini) (not(llevaMochila bikini))) (not(llevoBikini ?j))) (when (and (llevaMano zapatillas) (not(llevaMochila zapatillas))) (not(llevoZapatillas ?j))) (not(llevaMano ?ob)) (not(libre ?l)) (esta ?ob ?l) (not(mano ?j)))
	)

	(:action DEJAR-AGUA
			:parameters (?j - jugador ?l - location ?ob - objetos)
			:precondition (and (esta ?j ?l) (libre ?l) (llevaMano ?ob) (es ?l agua) (not(llevaMano bikini)))
			:effect (and (when (and (llevaMano zapatillas) (not(llevaMochila zapatillas))) (not(llevoZapatillas ?j))) (not(llevaMano ?ob)) (not(libre ?l)) (esta ?ob ?l) (not(mano ?j)))
	)

	(:action DEJAR-BOSQUE
			:parameters (?j - jugador ?l - location ?ob - objetos)
			:precondition (and (esta ?j ?l) (libre ?l) (llevaMano ?ob) (es ?l bosque) (not(llevaMano zapatillas)))
			:effect (and (when (and (llevaMano bikini) (not(llevaMochila bikini))) (not(llevoBikini ?j))) (not(llevaMano ?ob)) (not(libre ?l)) (esta ?ob ?l) (not(mano ?j)))
	)

	(:action ENTREGAR
			:parameters (?j - jugador ?l - location ?p - personajes ?ob - objetos)
			:precondition (and (esta ?j ?l) (esta ?p ?l) (llevaMano ?ob) (not(llevaMano bikini)) (not(llevaMano zapatillas)))
			:effect (and (not(llevaMano ?ob)) (tieneobjeto ?p) (not(mano ?j)) (increase (puntos-totales) (puntos ?p ?ob)))
	)

	(:action IR
			:parameters (?j - jugador ?l1 - location ?l2 - location ?o - orienta)
			:precondition (and (esta ?j ?l1) (orientacion ?o) (tiene ?l1 ?l2 ?o) (not(es ?l2 precipicio)) (not(es ?l2 agua)) (not(es ?l2 bosque)))
			:effect (and (not(esta ?j ?l1)) (esta ?j ?l2) (increase (distancia-total) (distancia ?l1 ?l2)))
	)

	(:action IR-AGUA
			:parameters (?j - jugador ?l1 - location ?l2 - location ?o - orienta)
			:precondition (and (esta ?j ?l1) (orientacion ?o) (tiene ?l1 ?l2 ?o) (es ?l2 agua) (llevoBikini ?j))
			:effect (and (not(esta ?j ?l1)) (esta ?j ?l2) (increase (distancia-total) (distancia ?l1 ?l2)))
	)

	(:action IR-BOSQUE
			:parameters (?j - jugador ?l1 - location ?l2 - location ?o - orienta)
			:precondition (and (esta ?j ?l1) (orientacion ?o) (tiene ?l1 ?l2 ?o) (es ?l2 bosque) (llevoZapatillas ?j))
			:effect (and (not(esta ?j ?l1)) (esta ?j ?l2) (increase (distancia-total) (distancia ?l1 ?l2)))
	)

	(:action GUARDAR
			:parameters (?j - jugador ?ob - objetos)
			:precondition (and (not(mochila ?j)) (llevaMano ?ob))
			:effect (and (mochila ?j) (llevaMochila ?ob) (not(mano ?j)) (not(llevaMano ?ob)))
	)

	(:action SACAR
			:parameters (?j - jugador ?ob - objetos)
			:precondition (and (llevaMochila ?ob) (not(mano ?j)))
			:effect (and (mano ?j) (llevaMano ?ob) (not(mochila ?j)) (not(llevaMochila ?ob)) )
	)
)