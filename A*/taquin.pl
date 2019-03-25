%:- lib(listut).       % Placer cette directive en commentaire si vous utilisez Swi-Prolog 
   
                      % Sinon ne pas modifier si vous utilisez ECLiPSe Prolog :
                      % -> permet de disposer du predicat nth1(N, List, E)
                      % -> permet de disposer du predicat sumlist(List, S)
                      % (qui sont predefinis en Swi-Prolog)

                      
%***************************
%DESCRIPTION DU JEU DU TAKIN
%***************************

   %********************
   % ETAT INITIAL DU JEU
   %********************   
   % format :  initial_state(+State) ou State est une matrice (liste de listes)
   

initial_state([ [b, h, c],       % C'EST L'EXEMPLE PRIS EN COURS
                [a, f, d],       % 
                [g,vide,e] ]).   % h1=4,   h2=5,   f*=5



% AUTRES EXEMPLES POUR LES TESTS DE  A*

/*
initial_state([ [ a, b, c],        
                [ g, h, d],
                [vide,f, e] ]). % h2=2, f*=2

initial_state([ [b, c, d],
                [a,vide,g],
                [f, h, e]  ]). % h2=10 f*=10
			
initial_state([ [f, g, a],
                [h,vide,b],
                [d, c, e]  ]). % h2=16, f*=20
			
initial_state([ [e, f, g],
                [d,vide,h],
                [c, b, a]  ]). % h2=24, f*=30 

initial_state([ [a, b, c],
                [g,vide,d],
                [h, f, e]]). % etat non connexe avec l'etat final (PAS DE SOLUTION)
*/  


   %******************
   % ETAT FINAL DU JEU
   %******************
   % format :  final_state(+State) ou State est une matrice (liste de listes)
   
final_state([[a, b,  c],
             [h,vide, d],
             [g, f,  e]]).

			 
   %********************
   % AFFICHAGE D'UN ETAT
   %********************
   % format :  write_state(?State) ou State est une liste de lignes a afficher

write_state([]).
write_state([Line|Rest]) :-
   writeln(Line),
   write_state(Rest).
   

%**********************************************
% REGLES DE DEPLACEMENT (up, down, left, right)             
%**********************************************
   % format :   rule(+Rule_Name, ?Rule_Cost, +Current_State, ?Next_State)
   
rule(up,   1, S1, S2) :-
   vertical_permutation(_X,vide,S1,S2).

rule(down, 1, S1, S2) :-
   vertical_permutation(vide,_X,S1,S2).

rule(left, 1, S1, S2) :-
   horizontal_permutation(_X,vide,S1,S2).

rule(right,1, S1, S2) :-
   horizontal_permutation(vide,_X,S1,S2).

   %***********************
   % Deplacement horizontal            
   %***********************
    % format :   horizontal_permutation(?Piece1,?Piece2,+Current_State, ?Next_State)
	
horizontal_permutation(X,Y,S1,S2) :-
   append(Above,[Line1|Rest], S1),
   exchange(X,Y,Line1,Line2),
   append(Above,[Line2|Rest], S2).

   %***********************************************
   % Echange de 2 objets consecutifs dans une liste             
   %***********************************************
   
exchange(X,Y,[X,Y|List], [Y,X|List]).
exchange(X,Y,[Z|List1],  [Z|List2] ):-
   exchange(X,Y,List1,List2).

   %*********************
   % Deplacement vertical            
   %*********************
   
vertical_permutation(X,Y,S1,S2) :-
   append(Above, [Line1,Line2|Below], S1), % decompose S1
   delete(N,X,Line1,Rest1),    % enleve X en position N a Line1,   donne Rest1
   delete(N,Y,Line2,Rest2),    % enleve Y en position N a Line2,   donne Rest2
   delete(N,Y,Line3,Rest1),    % insere Y en position N dans Rest1 donne Line3
   delete(N,X,Line4,Rest2),    % insere X en position N dans Rest2 donne Line4
   append(Above, [Line3,Line4|Below], S2). % recompose S2 

   %***********************************************************************
   % Retrait d'une occurrence X en position N dans une liste L (resultat R) 
   %***********************************************************************
   % use case 1 :   delete(?N,?X,+L,?R)
   % use case 2 :   delete(?N,?X,?L,+R)   
   
delete(1,X,[X|L], L).
delete(N,X,[Y|L], [Y|R]) :-
   delete(N1,X,L,R),
   N is N1 + 1.


   
   
     %**********************************
   % HEURISTIQUES (PARTIE A COMPLETER)
   %**********************************
   
%heuristique(U,H) :-
 %  heuristique1(U, H).  % choisir l'heuristique 
%   heuristique2(U, H).  % utilisee ( 1 ou 2)  
   
   %****************
   %HEURISTIQUE no 1
   %****************
   
   % Calcul du nombre de pieces mal placees dans l'etat courant U
   % par rapport a l'etat final F

cmpL([L1|L1r],[L1|L2r],R):-cmpL(L1r,L2r,R).
cmpL([vide|L1r],[_|L2r],R):-cmpL(L1r,L2r,R).
cmpL([],[],0).
cmpL([L1|L1r],[L2|L2r],R1):-
   cmpL(L1r,L2r,R),
   L1 \= L2,
   L1 \= vide,
   R1 is R + 1. 


heuristique1([],[],0).
heuristique1([U|Ur],[F|Fr], H) :-
    heuristique1(Ur,Fr,H1),
    cmpL(U,F,R),
    H is H1 + R.
  
  
%****************
%HEURISTIQUE no 2
%****************
   
% Somme sur l'ensemble des pieces des distances de Manhattan
% entre la position courante de la piece et sa positon dans l'etat final
% 

row(M, N, Row, Elem) :-
    nth1(N, M, Row),
    member(Elem, Row).

column(M, N, Col,Elem) :-
    transpose(M, MT),
    row(MT, N, Col,Elem).

symmetrical(M) :-
    transpose(M, M).

transpose([[]|_], []) :- !.
transpose([[I|Is]|Rs], [Col|MT]) :-
    first_column([[I|Is]|Rs], Col, [Is|NRs]),
    transpose([Is|NRs], MT).

first_column([], [], []).
first_column([[]|_], [], []).
first_column([[I|Is]|Rs], [I|Col], [Is|Rest]) :-
    first_column(Rs, Col, Rest).


coordonnees([Row,Column], Matrix, Elem):-
	row(Matrix, Row, _, Elem),
    column(Matrix, Column,_,Elem).

cmpC(_,_,vide,0).
cmpC(U,F,Elem,Manhattan):-
    Elem \=vide,
    coordonnees([RowU, ColumnU], U, Elem),
    coordonnees([RowF, ColumnF], F, Elem),
    Manhattan is (abs(RowF-RowU) + abs(ColumnF-ColumnU)).

matrixToList([],[]).

matrixToList([U|Ur], UL):-
    matrixToList(Ur,UL2),
    append(U,UL2,UL).
    
heuristique2(U,H):-
	matrixToList(U,Ul),
 	final_state(F),
 	findall(Y,(member(X,Ul), cmpC(U,F,X,Y)), List),
 	sumlist(List,H).
    


	
