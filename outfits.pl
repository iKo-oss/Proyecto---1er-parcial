/* Creador de outfits */

/* Cargar los archivos*/
:- consult('clima.pl').
:- consult('closet.pl').
:- consult('colores.pl').
:- consult('escenarios.pl').
:- consult('prendas.pl').

/* Regla 0: Entradas válidas */
/* lugar_valido ( lugar ), temperatura_valida ( temperatura ), temporada_valida ( temporada ), capas_validas ( capas ) */
/* Comprueban que el lugar exista en los escenarios, que la temperatura exista en el clima, que la temporada sea válida y que las capas sean 1, 2, 3 o todas */
/* Nota: todas significa que el usuario acepta de 1 a 3 capas */
lugar_valido(Lugar) :- formalidad_escenario(Lugar, _), !.
temperatura_valida(Temp) :- clima(Temp, _, _, _), !.
temporada_valida(Temporada) :- member(Temporada, [otonio, invierno, primavera, verano, neutros]).
capas_validas(todas).
capas_validas(Capas) :- member(Capas, [1, 2, 3]).





/* Regla: Datos completos de una ropa */
/* ropa_datos ( tipo, color, zona, capa, abrigo, formalidad ) */
/* Dada una ropa del clóset (tipo y color), devuelve su zona, capa, abrigo y formalidad buscando el tipo en el catálogo */
/* Nota: Si el tipo puede usarse en dos capas, la misma ropa da una respuesta por cada capa */
ropa_datos(Tipo, Color, Zona, Capa, Abrigo, Formalidad) :-
    ropa(Tipo, Color),
    prenda(Zona, Tipo, Capa, Abrigo, Formalidad).





/* Regla: Dos colores combinan dada una temporada */
/* combinan ( temporada, color 1, color 2 ) */
/* Es verdadera si los colores son iguales, si alguno es neutro o si ambos están en un mismo conjunto de la temporada */
/* Nota: El orden de los colores no importa, por eso cada caso se revisa en ambos sentidos */
combinan(_, Color, Color).
combinan(_, Color1, _) :- color_neutro(Color1).
combinan(_, _, Color2) :- color_neutro(Color2).
combinan(Temporada, Color1, Color2) :-
    temporada_paleta(Temporada, _, Lista),
    member(Color1, Lista),
    member(Color2, Lista).





/* Regla: Color permitido en la temporada */
/* color_permitido ( temporada, color ) */
/* Es verdadera si el color es neutro o aparece en algún conjunto de la temporada */
/* Nota: La temporada neutros no tiene conjuntos, por eso en ella solo pasan los colores neutros */
color_permitido(_, Color) :- color_neutro(Color).
color_permitido(Temporada, Color) :-
    temporada_paleta(Temporada, _, Lista),
    member(Color, Lista).





/* Regla: Formalidad segun el escenario */
/* formalidad_adecuada ( lugar, formalidad de la prenda ) */
/* Es verdadera si la formalidad de la prenda difiere como máximo en 1 de la del lugar */
formalidad_adecuada(Lugar, FormalidadPrenda) :-
    formalidad_escenario(Lugar, FormalidadLugar),
    abs(FormalidadPrenda - FormalidadLugar) =< 1.





/* Regla: Abrigo segun el clima */
/* abrigo_adecuado ( temperatura, abrigo de la prenda ) */
/* Es verdadera si el abrigo de la prenda es menor o igual al abrigo máximo de la temperatura */
/* Nota: Se compara prenda por prenda, los abrigos no se suman */
/* Nota: En templado hay dos hechos, por eso puede repetir resultados */
abrigo_adecuado(Temp, AbrigoPrenda) :-
    clima(Temp, AbrigoMaximo, _, _),
    AbrigoPrenda =< AbrigoMaximo.







/* Regla: Prenda apta */
/* ropa_apta ( lugar, temperatura, zona, capa, tipo, color ) */
/* Es verdadera si la ropa es de la zona y la capa pedidas y su formalidad y abrigo son adecuados */
ropa_apta(Lugar, Temp, Zona, Capa, Tipo, Color) :-
    ropa_datos(Tipo, Color, Zona, Capa, Abrigo, Formalidad),
    formalidad_adecuada(Lugar, Formalidad),
    abrigo_adecuado(Temp, Abrigo).







/* Regla: Capa exterior según el clima */
/* exterior_valida ( temperatura, tipo de la prenda de capa 3 ), sin_exterior_valido ( temperatura ) */
/* La primera es verdadera si la prenda de capa 3 abriga al menos lo que pide el clima, la segunda, si el clima permite ir sin capa extwrior */
/* Nota: En templado hay un hecho con si y otro con no, por eso ahí la capa exterior es opcional y la decide el usuario */
exterior_valida(Temp, Tipo) :-
    clima(Temp, _, _, AbrigoMinimo),
    prenda(torso, Tipo, 3, Abrigo, _),
    Abrigo >= AbrigoMinimo.
sin_exterior_valido(Temp) :- clima(Temp, _, no, _).







/* Regla: Torso */
/* torso ( lugar, temperatura, temporada, número de capas, torso ) */
/* Arma el torso con prendas aptas en capas crecientes, siempre empezando en la capa 1, con colores que combinan y cumpliendo la capa exterior del clima */
/* Nota: Con 2 capas hay dos formas (capas 1 y 2, o capas 1 y 3), por eso hay dos cláusulas con 2 */
/* Nota: Solo se compara el tipo con las capas 1 y 2, porque ningún tipo de capa 3 puede usarse en otra capa */
/* Nota: Los colores se revisan con la regla de colores (la siguiente), que además comprueba que cada color sea de la temporada */

/* capa 1 */
torso(Lugar, Temp, Temporada, 1, [Tipo1-Color1]) :-
    ropa_apta(Lugar, Temp, torso, 1, Tipo1, Color1),
    colores_combinan(Temporada, [Color1]),
    sin_exterior_valido(Temp).

/* capa 1 y 2 */
torso(Lugar, Temp, Temporada, 2, [Tipo1-Color1, Tipo2-Color2]) :-
    ropa_apta(Lugar, Temp, torso, 1, Tipo1, Color1),
    ropa_apta(Lugar, Temp, torso, 2, Tipo2, Color2),
    Tipo1 \== Tipo2,
    colores_combinan(Temporada, [Color1, Color2]),
    sin_exterior_valido(Temp).

/* capa 1 y 3 */
torso(Lugar, Temp, Temporada, 2, [Tipo1-Color1, Tipo3-Color3]) :-
    ropa_apta(Lugar, Temp, torso, 1, Tipo1, Color1),
    ropa_apta(Lugar, Temp, torso, 3, Tipo3, Color3),
    colores_combinan(Temporada, [Color1, Color3]),
    exterior_valida(Temp, Tipo3).

/* capa 1, 2 y 3 */
torso(Lugar, Temp, Temporada, 3, [Tipo1-Color1, Tipo2-Color2, Tipo3-Color3]) :-
    ropa_apta(Lugar, Temp, torso, 1, Tipo1, Color1),
    ropa_apta(Lugar, Temp, torso, 2, Tipo2, Color2),
    Tipo1 \== Tipo2,
    ropa_apta(Lugar, Temp, torso, 3, Tipo3, Color3),
    colores_combinan(Temporada, [Color1, Color2, Color3]),
    exterior_valida(Temp, Tipo3).


/* Regla: Piernas */
/* piernas ( lugar, temperatura, tipo, color ) */
/* Devuelve una prenda de la zona piernas, de capa 1, que sea apta */
piernas(Lugar, Temp, Tipo, Color) :- ropa_apta(Lugar, Temp, piernas, 1, Tipo, Color).







/* Regla: Colores de todo el outfit */
/* colores_combinan ( temporada, lista de colores ) */
/* Es verdadera si todos los colores son de la temporada y no existe ninguna pareja de colores que no combine */
colores_combinan(Temporada, Colores) :-
    \+ ( member(Color, Colores), \+ color_permitido(Temporada, Color) ),
    \+ ( member(Color1, Colores), member(Color2, Colores), \+ combinan(Temporada, Color1, Color2) ).





/* Regla: Formalidad entre prendas */
/* formalidad_compatible ( outfit ) */
/* Es verdadera si no existe ninguna pareja de prendas del outfit que difiera en más de 1 de formalidad */
/* Nota: Sirve para evitar mezcalr prendas que no, como una playera con un pantalon de vestir */
formalidad_compatible(Outfit) :-
    \+ ( member(Tipo1-Color1, Outfit),
         member(Tipo2-Color2, Outfit),
         ropa_datos(Tipo1, Color1, _, _, _, Formalidad1),
         ropa_datos(Tipo2, Color2, _, _, _, Formalidad2),
         abs(Formalidad1 - Formalidad2) > 1 ).




/* Regla: Outfit completo */
/* outfit ( lugar, temperatura, temporada, capas, outfit ) */
/* Une el torso con las piernas y comprueba los colores y la formalidad de todo el outfit, para devolver una lista de pares Tipo-Color */
/* Nota: Una consulta da muchos outfits porque Prolog prueba todas las combinaciones (backtracking) */
outfit(Lugar, Temp, Temporada, Capas, Outfit) :-
    capas_elegidas(Capas, NumCapas),
    torso(Lugar, Temp, Temporada, NumCapas, Torso),
    piernas(Lugar, Temp, TipoPiernas, ColorPiernas),
    append(Torso, [TipoPiernas-ColorPiernas], Outfit),
    colores_de(Outfit, Colores),
    colores_combinan(Temporada, Colores),
    formalidad_compatible(Outfit).

/* capas_elegidas ( capas, número de capas ) */
/* Convierte lo que pidió el usuario en un número de capas, y si pidió todas prueba 1, 2 y 3 */
capas_elegidas(todas, NumCapas) :- member(NumCapas, [1, 2, 3]).
capas_elegidas(NumCapas, NumCapas) :- member(NumCapas, [1, 2, 3]).

/* colores_de ( outfit, lista de colores ) */
/* Saca la lista de colores de las prendas de un outfit */
colores_de(Outfit, Colores) :- findall(Color, member(_-Color, Outfit), Colores).


/* Regla: Colección sin repetidos */
/* outfits ( lugar, temperatura, temporada, capas, lista de outfits ) */
/* Reúne todos los outfits de una consulta y quita los repetidos, que pueden aparecwr por los hechos dobles */
/* Nota: Si no hay ningún outfit, devuelve la lista vacía */
outfits(Lugar, Temp, Temporada, Capas, Lista) :-
    findall(Outfit, outfit(Lugar, Temp, Temporada, Capas, Outfit), Todos),
    sort(Todos, Lista).





/* Regla: Explicación */
/* explicacion ( lugar, temperatura, temporada, outfit, explicación ) */
/* Devuelve explicacion ( niveles de formalidad del lugar, abrigo máximo, parejas de colores, número de capas ) */
/* Nota: Cada pareja se devuelve como par ( color 1, color 2, motivo ) */
/* Nota: El motivo es igual si son el mismo color, conjunto si ambos están en un mismo conjunto de la temporada, o neutro si alguno es neutro */
/* Nota: Un lugar puede tener dos niveles de formalidad, por eso se devuelven en una lista */
explicacion(Lugar, Temp, Temporada, Outfit, explicacion(Niveles, AbrigoMaximo, Parejas, NumCapas)) :-
    findall(Nivel, formalidad_escenario(Lugar, Nivel), Niveles),
    once(clima(Temp, AbrigoMaximo, _, _)),
    findall(par(Color1, Color2, Motivo),
            ( append(_, [_-Color1 | Resto], Outfit),
              member(_-Color2, Resto),
              motivo_pareja(Temporada, Color1, Color2, Motivo) ),
            Parejas),
    length(Outfit, Prendas),
    NumCapas is Prendas - 1.

/* motivo_pareja ( temporada, color 1, color 2, motivo ) */
/* Busca por qué combinan dos colores: primero si son iguales, luego si están en un mismo conjunto y si no, es porque alguno es neutro */
motivo_pareja(_, Color, Color, igual) :- !.
motivo_pareja(Temporada, Color1, Color2, conjunto(Id)) :-
    temporada_paleta(Temporada, Id, Lista),
    member(Color1, Lista),
    member(Color2, Lista), !.
motivo_pareja(_, _, _, neutro).





/* Regla: Puntaje por temporada */
/* puntaje ( outfit, puntaje ) */
/* Cuenta cuántas prendas del outfit tienen un color que no es neutro */
/* Nota: La regla 9 solo deja pasar colores de la temporada, por eso esos colores son de la temporada elegida */
/* Nota: En la temporada neutros el puntaje siempre es 0 */
puntaje(Outfit, Puntaje) :-
    findall(Color, ( member(_-Color, Outfit), \+ color_neutro(Color) ), Lista),
    length(Lista, Puntaje).





/* Regla: Recomendar */
/* recomendar ( lugar, temperatura, temporada, capas, resultado ) */
/* Es la regla que usará la página web, donde valida las entradas, arma los outfits sin repetidos y los ordena del mayor puntaje al menor */
/* Nota. El puntaje se da con que tan cercano es lo que sgiere el programa con la temporada que pieido el usuario*/
/* Nota: El resultado es error si alguna entrada es inválida, o ok en caso contrario*/
recomendar(Lugar, _, _, _, error(lugar_invalido)) :- \+ lugar_valido(Lugar), !.
recomendar(_, Temp, _, _, error(temperatura_invalida)) :- \+ temperatura_valida(Temp), !.
recomendar(_, _, Temporada, _, error(temporada_invalida)) :- \+ temporada_valida(Temporada), !.
recomendar(_, _, _, Capas, error(capas_invalidas)) :- \+ capas_validas(Capas), !.
recomendar(Lugar, Temp, Temporada, Capas, ok(Ordenados)) :-
    outfits(Lugar, Temp, Temporada, Capas, Lista),
    findall(Puntaje-Outfit, ( member(Outfit, Lista), puntaje(Outfit, Puntaje) ), Pares),
    keysort(Pares, Ascendente),
    reverse(Ascendente, Ordenados).
