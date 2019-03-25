%*******************************************************************************
%                                    AETOILE
%*******************************************************************************

/*
Rappels sur l'algorithme

- structures de donnees principales = 2 ensembles : P (etat pendants) et Q (etats clos)
- P est dedouble en 2 arbres binaires de recherche equilibres (AVL) : Pf et Pu

   Pf est l'ensemble des etats pendants (pending states), ordonnes selon
   f croissante (h croissante en cas d'egalite de f). Il permet de trouver
   rapidement le prochain etat a developper (celui qui a f(U) minimum).

   Pu est le meme ensemble mais ordonne lexicographiquement (selon la donnee de
   l'etat). Il permet de retrouver facilement n'importe quel etat pendant

   On gere les 2 ensembles de façon synchronisee : chaque fois qu'on modifie
   (ajout ou retrait d'un etat dans Pf) on fait la meme chose dans Pu.

   Q est l'ensemble des etats deja developpes. Comme Pu, il permet de retrouver
   facilement un etat par la donnee de sa situation.
   Q est modelise par un seul arbre binaire de recherche equilibre.

Predicat principal de l'algorithme :

   aetoile(Pf,Pu,Q)

   - reussit si Pf est vide ou bien contient un etat minimum terminal
   - sinon on prend un etat minimum U, on genere chaque successeur S et les valeurs g(S) et h(S)
	 et pour chacun
		si S appartient a Q, on l'oublie
		si S appartient a Ps (etat deja rencontre), on compare
			g(S)+h(S) avec la valeur deja calculee pour f(S)
			si g(S)+h(S) < f(S) on reclasse S dans Pf avec les nouvelles valeurs
				g et f
			sinon on ne touche pas a Pf
		si S est entierement nouveau on l'insere dans Pf et dans Ps
	- appelle recursivement etoile avec les nouvelles valeurs NewPF, NewPs, NewQs

*/

%*******************************************************************************

:- ['avl.pl'].       % predicats pour gerer des arbres bin. de recherche
:- ['taquin.pl'].    % predicats definissant le systeme a etudier

%*******************************************************************************
display_list([]).
display_list([A|B]) :-
  format('NewState = ~w\t\t[F,H,G] = ~w\tFather = ~w\tRule = ~w~n',A),
  display_list(B).

main :-
	initial_state(S0),
	heuristique2(S0,H0),
	F0 is H0,
	G0 is 0,
	empty(Pf),
	empty(Pu),
	empty(Q),
	insert([[F0,H0,G0], S0], Pf, NewPf),
	insert([S0, [F0,H0,G0], nil, nil],Pu,NewPu),
	aetoile(NewPf, NewPu, Q).

%*******************************************************************************

aetoile(Pf,Ps,_):-
	empty(Pf),
	empty(Ps),
	nl, writeln('PAS de SOLUTION: L’ETAT FINAL N’EST PAS ATTEIGNABLE!').

aetoile(Pf, Pu, Qs) :-
	suppress_min([[F,H,G],U], Pf, NewPf),
	suppress([U,[F,H,G],Pere,A], Pu, NewPu),
	(final_state(U)->
		affiche_solution(Qs),
 		nl, writeln(A),
        	nl, writeln(U)
	;	
		expand(U,G,PuElements),
		loop_successors(PuElements, Qs, NewPf, NewPu, NextIterPf, NexIterPu),
		insert([U,[F,H,G],Pere,A], Qs, NextIterQs),
		aetoile(NextIterPf, NexIterPu, NextIterQs)
	).

affiche_solution(Qs):-	
	put_flat(Qs).
	
	

process_successors(Node,Qs,_,_,_,_):-	belongs(Node,Qs).

process_successors([U,ValU,PereU,ActionU], Qs, Pf, Pu, NewPf, NewPu):-
	suppress([U,Vala,Perea,Actiona], Pu, InterPu),
	suppress([Vala,U], Pf, InterPf),
	(ValU @< Vala ->
	  insert([U,ValU,PereU,ActionU], Pu, InterPu),
	  insert([ValU,U], Pf, InterPf),
	  NewPf = InterPf,
	  NewPu = InterPu 
	;
 	  NewPf = Pf,
	  NewPu = Pu
	).

process_successors([U,[F,H,G],Pere,A], Qs, Pf, Pu, NewPf, NewPu):-
	insert([U,[F,H,G],Pere,A], Pu, NewPu),
	insert([[F,H,G],U], Pf, NewPf).

loop_successors([], Qs, Pf, Pu, Pf, Pu).
	
loop_successors([U|R], Qs, Pf, Pu, NewPf, NewPu):-
	process_successors(U, Qs, Pf, Pu, InterPf, InterPu),
	loop_successors(R, Qs, InterPf, InterPu, NewPf, NewPu).
	


expand(U,G,PuElements):-
	findall([X,S2], (rule(X,   1, U, S2)), ListSuccess),
	findall([S2,[FF,HH,GG],U,X],(member([X,S2], ListSuccess), heuristique2(S2,HH), GG is G + 1, FF is GG + HH), PuElements).
