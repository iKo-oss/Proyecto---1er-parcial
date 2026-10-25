% Núcleo familiar

% Padres
padre(cesar_roman, cesar_habacuc).
padre(cesar_roman, elisa_itzuri).
padre(cesar_roman, libni_daniela).
madre(claudia, cesar_habacuc).
madre(claudia, elisa_itzuri).
madre(claudia, libni_daniela).

% Abuelos
padre(roman, cesar_roman).
madre(alicia, cesar_roman).
padre(roman, paola).
madre(alicia, paola).
padre(roman, oscar).
madre(alicia, oscar).

padre(juan, claudia).
madre(alejandra, claudia).
padre(juan, elena).
madre(alejandra, elena).
padre(juan, laura).
madre(alejandra, laura).


% regla de hermanos
hermano(X, Y) :-
    (
    padre(P, X), padre(P, Y);
    madre(M, X), madre(M, Y)
    ),
    X \= Y.

% regla de abuelos
abuelo(A, N) :-
    (padre(A, P); madre(A, P)),
    (padre(P, N); madre(P, N)).
    
% regla tíos
tio(X, Y) :-
        hermano(X, N), ((madre(N, Y); padre(N, Y)).
