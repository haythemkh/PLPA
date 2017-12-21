%%%%%%%%%%%%%%%%%%%%%%%%%%% 1ère Question %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   La structure la plus simple pour représenter un couple est de
% représenter chaque couple (G,D) de la façon suivante G/D, c'est-à-dire
% en vue de représenter une liste de couples, cela se fera de la façon
% suivante [G1/D1, G2/D3, G3/D3]. Ainsi de cette façon, on représente
% une liste de 3 éléments.

%%%%%%%%%%%%%%%%%%%%%%%%%%% 2ème Question %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Lorsque la liste est vide, c'est-à-dire qu'il n'y a aucune reine sur
% l'échiquier le programme doit se terminer sans aucune erreur afin
% d'indiquer que rien ne se passera.

safe(L1/C1,L2/C2):-
	L1 =\= L2,
	C1 =\= C2,
	L1 - L2 =\= C1 - C2,
	L1 - L2 =\= C2 - C1,
	L2 - L1 =\= C1 - C2,
	L2 - L1 =\= C2 - C1.

no_attack(_,[]):-!.
no_attack(T,[R]):- safe(T,R),!.
no_attack(T1,[T2|R]):- safe(T1,T2), no_attack(T1,R).

%%%%%%%%%%%%%%%%%%%%%%%%%%% 3ème Question %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Oui et non: Non, c'est parce que elle est limitée à la résolution
% du problème des 8-reines et oui parce qu'elle peut être généralisée en
% vue de la rendre compatible avec le problème des n-reines.

correct_config_eight([]):-!.
correct_config_eight([X/Y|R]):-
	correct_config_eight(R),
	domain_n(8,M), member(X,M), member(Y,M),
	no_attack(X/Y,R).
	
%%%%%%%%%%%%%%%%%%%%%%%%%%% 4ème Question %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Ce prédicat sert à la résolution du problème des 8-reines.

solution_eight(X):-
	length(X,8),
	correct_config_eight(X).
	
%%%%%%%%%%%%%%%%%%%%%%%%%%% 5ème Question %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   La dernière solution génère toutes les combinaisons possibles sans 
% imposer une certaine norme ou un certain ordre ce qui génère beaucoup
% de doublons.
% Ici, j'ordonne la solution à générer via le length.

correct_config_eight_ordered([]):-!.
correct_config_eight_ordered([X/Y|R]):-
	correct_config_eight_ordered(R),
	domain_n(8,M), member(X,M), member(Y,M),
	length([X/Y|R], X),
	no_attack(X/Y,R).
	
solution_eight_ordered(X):-
	length(X,8),
	correct_config_eight_ordered(X).		
	
%%%%%%%%%%%%%%%%%%%%%%%%%%% 6ème Question %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Ici, j'adapte seulement l'ancien correct_config_eight pour qu'il
% soit possible à être utilisé pour la résolution du problème des 
% n-reines.

correct_config_n([],_):-!.
correct_config_n([X/Y|R],N):-
	correct_config_n(R,N),
	domain_n(N,M), member(X,M), member(Y,M),
	length([X/Y|R], X),
	no_attack(X/Y,R).
	
%    À travers le prédicat ci-dessous, on génère une liste de solution
% à la problèmatique des n-reines via le print.

solution_n(N):-
	length(X,N),
	correct_config_n(X,N),
	print(X).

%%%%%%%%%%%%%%%%%%%%%%% FONCTIONS UTILITAIRES %%%%%%%%%%%%%%%%%%%%%%%%%%
%   Cette fonction génère une liste de N éléments tel que tous ses 
% éléments sont des entiers de 1 à N triés par ordre croissant et par
% incrémentation de 1.

domain_n(1,[1]):-!.
domain_n(N,[N|R]):-
	N > 0,
	K is N-1,
	domain_n(K,R).
