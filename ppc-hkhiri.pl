:-include(libtp2).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
solve(Num,Xs,Ys/*,B*/):-
	data(Num,C,Ts),
	length(Ts,NbCarres),
	length(Xs,NbCarres),
	length(Ys,NbCarres),
	in_domain(Xs,Ys,Ts,C),
	Vi is C-1,
	constraints(Xs,Ys,Ts,C,Vi),
	no_overlap(Xs,Ys,Ts),
	fd_labeling(Xs/*,[backtracks(B)]*/),
	fd_labeling(Ys/*,[backtracks(B)]*/),
	printsol('out',Xs,Ys,Ts).
	
/* Respecter les intervalles */
in_domain([],[],[],_):-!.
in_domain([Xi|Xs],[Yi|Ys],[Ti|Ts],C):-
	CT is C-Ti,
	fd_domain(Xi,0,CT),
	fd_domain(Yi,0,CT),
	Xi+Ti #=< C,
	Yi+Ti #=< C,
	in_domain(Xs,Ys,Ts,C).
		
/* Pas de chevauchement */
no_overlap_elems(_,_,_,[],[],[]):-!.
no_overlap_elems(Xi,Yi,Ti,[Xj|Xs],[Yj|Ys],[Tj|Ts]):-
	Xi+Ti #=< Xj #\/ Xj+Tj #=< Xi #\/ Yi+Ti #=< Yj #\/ Yj+Tj #=< Yi,
	no_overlap_elems(Xi,Yi,Ti,Xs,Ys,Ts).

no_overlap([],[],[]):-!.
no_overlap([Xi|Xs],[Yi|Ys],[Ti|Ts]):-
	no_overlap_elems(Xi,Yi,Ti,Xs,Ys,Ts),
	no_overlap(Xs,Ys,Ts).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
/* Génération d'un tableau de booléen qui map chacune des valeurs du
  tableau des X */
gen_bool_table(_,[],[],[]).
gen_bool_table(L,[X|Xs],[T|Ts],[B|Bs]):- 
	fd_domain(B,0,1),
	(X #=< L #/\L #< X + T )#\<=> (#\B),
	gen_bool_table(L,Xs,Ts,Bs).
	
/* Calcul du produit scalaire */
calc_prod([],[],0):-!.
calc_prod([Xi|Xs],[Yi|Ys],P):-
	calc_prod(Xs,Ys,Ps),
	P #= Ps + Xi*Yi.
	
/* Vérification de la somme des tailles des carrées sur une ligne
  ne dépasse pas la taille du grand carré */
sum_line(L,X,T,C):- 
	gen_bool_table(L,X,T,B),
	calc_prod(T,B,C).

/* Vérification appliquée sur toutes les lignes horizontales
  et verticales du carré */
constraints(X,Y,Ti,T,0):-
	sum_line(0,X,Ti,T),
	sum_line(0,Y,Ti,T),!.
constraints(X,Y,Ti,T,Cpt):-
	sum_line(Cpt,X,Ti,T),
	sum_line(Cpt,Y,Ti,T),
	Vi is Cpt-1,
	constraints(X,Y,Ti,T,Vi).
	
/* Stratégie de recherche: Rajout du prédicat constraints(X,Y,Ti,T,Cpt) 
  au prédicat de résolution ainsi que labeling, assign, minmin, backtracking
  et le nombre de solution */
solve2(Num,Xs,Ys,B,NbSol):-
	data(Num,C,Ts),
	length(Ts,N),
	length(Xs,N),
	length(Ys,N),
	in_domain(Xs,Ys,Ts,C),
	no_overlap(Xs,Ys,Ts),
	Vi is C-1,
	constraints(Xs,Ys,Ts,C,Vi),
	labeling(Xs,Ys,assign,minmin,B,NbSol),
	printsol('out2',Xs,Ys,Ts).
/*****************************************
Assign et Data = 2 => B = 805
Assign et Data = 3 => B = 1956
Assign et Data = 4 => B = 9391

InDomain et Data = 2 => B = 9038				
InDomain et Data = 3 => Pas de solution

Assign est plus efficiente !
*****************************************/
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
/* Implémentation de l'algorithme de tri par insertion en vue
  d'implémenter la symétrie */
insert(X,[],[X]):-!.
insert(Xi,[Yi|Ys],[Xi,Yi|Ys]):-
	Xi #=< Yi,!.
insert(Xi,[Yi|L1],[Yi|L2]):-
	Xi #> Yi,
	insert(Xi,L1,L2).

tri_par_ins([],[]):-!.
tri_par_ins([X|L],L1):-
	tri_par_ins(L,L2),
	insert(X,L2,L1).
	
/* Rajout du tri par insertion pour la symétrie de la solution
   et l'élimination des doublons */
solve3(Num,Xs,Ys,B,NbSol):-
	data(Num,C,Ts),
	length(Ts,NbCarres),
	length(Xt,NbCarres),
	tri_par_ins(Xt,Xs),
	length(Ys,NbCarres),
	in_domain(Xs,Ys,Ts,C),
	no_overlap(Xs,Ys,Ts),
	Vi is C-1,
	constraints(Xs,Ys,Ts,C,Vi),
	labeling(Xs,Ys,assign,minmin,B,NbSol),
	printsol('out3',Xs,Ys,Ts).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
