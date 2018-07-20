(define (domain belkan-domain)	       ; Comment: adding location caused fail
	(:requirements :adl :typing :fluents)
	(:types  entrega recoge - jugador
			jugador personajes objetos  - locatable
			location
			orienta
			zonas)
	
	(:predicates 
		(tiene ?x - location ?y - location ?o - orienta )
		(esta ?x - locatable ?y - location)
		(llevaMochila ?x - jugador ?y - objetos)
		(llevaMano ?x - jugador ?y - objetos)
		(mano ?x - jugador)
		(mochila ?x - jugador)
		(orientacion ?x - jugador ?y - orienta)
		(libre ?x - location)
		(tieneobjeto ?x - personajes)
		(es ?x - location ?y - zonas)
		(llevoBikini ?x - jugador)
		(llevoZapatillas ?x - jugador)
	)

	(:functions
		(distancia ?x ?y - location)
		(distancia-total)
		(puntos ?x - personajes ?y - objetos)
		(puntos-totales)
		(tambolsillo ?x - personajes)
		(bolsillo ?x - personajes)
		(puntosjugador ?j - entrega)
	)
  
	(:action GIRAR-IZQUIERDA
	     :parameters (?o - orienta ?j - jugador)
	     :precondition (orientacion ?j ?o)
	     :effect (and (when (orientacion ?j norte) (and (not(orientacion ?j ?o)) (orientacion ?j oeste) ))
					(when (orientacion ?j oeste) (and (not(orientacion ?j ?o)) (orientacion ?j sur) ))
					(when (orientacion ?j sur) (and (not(orientacion ?j ?o)) (orientacion ?j este) ))
					(when (orientacion ?j este) (and (not(orientacion ?j ?o)) (orientacion ?j norte) ))
				 )
	)

	(:action GIRAR-DERECHA
	     :parameters (?o - orienta ?j - jugador)
	     :precondition (orientacion ?j ?o)
	     :effect (and (when (orientacion ?j norte) (and (not(orientacion ?j ?o)) (orientacion ?j este) ))
					(when (orientacion ?j oeste) (and (not(orientacion ?j ?o)) (orientacion ?j norte) ))
					(when (orientacion ?j sur) (and (not(orientacion ?j ?o)) (orientacion ?j oeste) ))
					(when (orientacion ?j este) (and (not(orientacion ?j ?o)) (orientacion ?j sur) ))
				 )
	)

	(:action COGER
			:parameters (?j - recoge ?l - location ?ob - objetos)
			:precondition (and (esta ?j ?l) (esta ?ob ?l) (not(mano ?j)))
			:effect (and (when (esta bikini ?l) (llevoBikini ?j)) (when (esta zapatillas ?l) (llevoZapatillas ?j)) (llevaMano ?j ?ob) (not(esta ?ob ?l)) (libre ?l) (mano ?j))
	)
	
	(:action DEJAR
			:parameters (?j - jugador ?l - location ?ob - objetos)
			:precondition (and (esta ?j ?l) (libre ?l) (llevaMano ?j ?ob) (not(es ?l agua)) (not(es ?l bosque)))
			:effect (and (when (and (llevaMano ?j bikini) (not(llevaMochila ?j bikini))) (not(llevoBikini ?j))) (when (and (llevaMano ?j zapatillas) (not(llevaMochila ?j zapatillas))) (not(llevoZapatillas ?j))) (not(llevaMano ?j ?ob)) (not(libre ?l)) (esta ?ob ?l) (not(mano ?j)))
	)

	(:action DEJAR-AGUA
			:parameters (?j - jugador ?l - location ?ob - objetos)
			:precondition (and (esta ?j ?l) (libre ?l) (llevaMano ?j ?ob) (es ?l agua) (not(llevaMano ?j bikini)))
			:effect (and (when (and (llevaMano ?j zapatillas) (not(llevaMochila ?j zapatillas))) (not(llevoZapatillas ?j))) (not(llevaMano ?j ?ob)) (not(libre ?l)) (esta ?ob ?l) (not(mano ?j)))
	)

	(:action DEJAR-BOSQUE
			:parameters (?j - jugador ?l - location ?ob - objetos)
			:precondition (and (esta ?j ?l) (libre ?l) (llevaMano ?j ?ob) (es ?l bosque) (not(llevaMano ?j zapatillas)))
			:effect (and (when (and (llevaMano ?j bikini) (not(llevaMochila ?j bikini))) (not(llevoBikini ?j))) (not(llevaMano ?j ?ob)) (not(libre ?l)) (esta ?ob ?l) (not(mano ?j)))
	)

	(:action ENTREGAR
			:parameters (?j - entrega ?l - location ?p - personajes ?ob - objetos)
			:precondition (and (esta ?j ?l) (esta ?p ?l) (llevaMano ?j ?ob) (not(llevaMano ?j bikini)) (not(llevaMano ?j zapatillas)) (< (bolsillo ?p) (tambolsillo ?p)))
			:effect (and (not(llevaMano ?j ?ob)) (tieneobjeto ?p) (not(mano ?j)) (increase (puntos-totales) (puntos ?p ?ob)) (increase (bolsillo ?p) 1) (increase (puntosjugador ?j) (puntos ?p ?ob)) )
	)

	(:action ENTREGAR-A-ROBOT
			:parameters (?j1 - recoge ?j2 - entrega ?l - location ?ob - objetos)
			:precondition (and (esta ?j1 ?l) (esta ?j2 ?l) (llevaMano ?j1 ?ob) (not(mano ?j2)))
			:effect (and (when (llevaMano ?j1 bikini) (llevoBikini ?j2)) (when (llevaMano ?j1 zapatillas) (llevoZapatillas ?j2)) (when (and(llevaMano ?j1 bikini) (not(llevaMochila ?j1 bikini))) (not(llevoBikini ?j1))) (when (and(llevaMano ?j1 zapatillas) (not(llevaMochila ?j1 zapatillas))) (not(llevoZapatillas ?j1))) (not(llevaMano ?j1 ?ob)) (not(mano ?j1)) (llevaMano ?j2 ?ob) (mano ?j2) )
	)

	(:action IR
			:parameters (?j - jugador ?l1 - location ?l2 - location ?o - orienta)
			:precondition (and (esta ?j ?l1) (orientacion ?j ?o) (tiene ?l1 ?l2 ?o) (not(es ?l2 precipicio)) (not(es ?l2 agua)) (not(es ?l2 bosque)))
			:effect (and (not(esta ?j ?l1)) (esta ?j ?l2) (increase (distancia-total) (distancia ?l1 ?l2)))
	)

	(:action IR-AGUA
			:parameters (?j - jugador ?l1 - location ?l2 - location ?o - orienta)
			:precondition (and (esta ?j ?l1) (orientacion ?j ?o) (tiene ?l1 ?l2 ?o) (es ?l2 agua) (llevoBikini ?j))
			:effect (and (not(esta ?j ?l1)) (esta ?j ?l2) (increase (distancia-total) (distancia ?l1 ?l2)))
	)

	(:action IR-BOSQUE
			:parameters (?j - jugador ?l1 - location ?l2 - location ?o - orienta)
			:precondition (and (esta ?j ?l1) (orientacion ?j ?o) (tiene ?l1 ?l2 ?o) (es ?l2 bosque) (llevoZapatillas ?j))
			:effect (and (not(esta ?j ?l1)) (esta ?j ?l2) (increase (distancia-total) (distancia ?l1 ?l2)))
	)

	(:action GUARDAR
			:parameters (?j - jugador ?ob - objetos)
			:precondition (and (not(mochila ?j)) (llevaMano ?j ?ob))
			:effect (and (mochila ?j) (llevaMochila ?j ?ob) (not(mano ?j)) (not(llevaMano ?j ?ob)))
	)

	(:action SACAR
			:parameters (?j - jugador ?ob - objetos)
			:precondition (and (llevaMochila ?j ?ob) (not(mano ?j)))
			:effect (and (mano ?j) (llevaMano ?j ?ob) (not(mochila ?j)) (not(llevaMochila ?j ?ob)) )
	)
)