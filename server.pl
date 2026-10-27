/* Servidor web: expone el motor Prolog por HTTP.
   Solo infraestructura: no contiene logica del sistema experto. */

:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_files)).

/* Cambiar el nombre si el archivo principal se llama distinto */
:- consult('outfits.pl').

:- http_handler(root(api/opciones), handle_opciones, []).
:- http_handler(root(api/recomendar), handle_recomendar, [method(post)]).
:- http_handler(root(.), servir_estaticos, [prefix]).

max_resultados(15).

servir_estaticos(Request) :- http_reply_from_files(static, [], Request).

/* GET /api/opciones: las opciones del menu salen de los hechos de Prolog */
handle_opciones(_) :-
    findall(L, formalidad_escenario(L, _), Ls), list_to_set(Ls, Lugares),
    findall(T, clima(T, _, _, _), Ts), list_to_set(Ts, Temperaturas),
    findall(S, temporada_valida(S), Temporadas),
    findall(C, capas_validas(C), Capas),
    reply_json_dict(_{lugares: Lugares, temperaturas: Temperaturas,
                      temporadas: Temporadas, capas: Capas}).

/* POST /api/recomendar con {"lugar","temperatura","temporada","capas"} */
handle_recomendar(Request) :-
    catch(procesar(Request), _, responder_interno).

procesar(Request) :-
    http_read_json_dict(Request, Datos, [value_string_as(atom)]),
    (   get_dict(lugar, Datos, Lugar),
        get_dict(temperatura, Datos, Temp),
        get_dict(temporada, Datos, Temporada),
        get_dict(capas, Datos, Capas0)
    ->  normaliza_capas(Capas0, Capas),
        once(recomendar(Lugar, Temp, Temporada, Capas, Resultado)),
        responder(Resultado, Lugar, Temp, Temporada)
    ;   reply_json_dict(_{estado: error, codigo: datos_incompletos,
                          mensaje: "Faltan datos en la consulta."}, [status(400)])
    ).

normaliza_capas(C, N) :- atom(C), atom_number(C, N), !.
normaliza_capas(C, C).

responder(error(Codigo), _, _, _) :-
    mensaje_error(Codigo, Mensaje),
    reply_json_dict(_{estado: error, codigo: Codigo, mensaje: Mensaje}, [status(400)]).
responder(ok(Pares), Lugar, Temp, Temporada) :-
    length(Pares, Total),
    max_resultados(Max),
    primeros(Max, Pares, Mostrar),
    maplist(outfit_json(Lugar, Temp, Temporada), Mostrar, Outfits),
    length(Mostrar, Mostrados),
    reply_json_dict(_{estado: ok, total: Total, mostrados: Mostrados, outfits: Outfits}).

responder_interno :-
    reply_json_dict(_{estado: error, codigo: error_interno,
                      mensaje: "Error interno del servidor."}, [status(500)]).

mensaje_error(lugar_invalido, "El lugar no es valido.").
mensaje_error(temperatura_invalida, "La temperatura no es valida.").
mensaje_error(temporada_invalida, "La temporada no es valida.").
mensaje_error(capas_invalidas, "El numero de capas no es valido.").

primeros(N, Lista, Lista) :- length(Lista, L), L =< N, !.
primeros(N, Lista, Primeros) :- length(Primeros, N), append(Primeros, _, Lista).

/* Conversion de terminos Prolog a JSON */
outfit_json(Lugar, Temp, Temporada, Puntaje-Outfit,
            _{puntaje: Puntaje, prendas: Prendas, explicacion: Exp}) :-
    maplist(prenda_json, Outfit, Prendas),
    (   once(explicacion(Lugar, Temp, Temporada, Outfit,
                         explicacion(Niveles, Abrigo, Parejas, NumCapas)))
    ->  maplist(pareja_json, Parejas, ParejasJ),
        Exp = _{formalidad_lugar: Niveles, abrigo_maximo: Abrigo,
                parejas: ParejasJ, capas: NumCapas}
    ;   Exp = null
    ).

prenda_json(Tipo-Color, _{tipo: Tipo, color: Color}).

pareja_json(par(C1, C2, Motivo), _{color1: C1, color2: C2, motivo: M}) :-
    motivo_texto(Motivo, M).

motivo_texto(conjunto(Id), M) :- !, format(atom(M), 'conjunto ~w', [Id]).
motivo_texto(Motivo, Motivo).

/* Arranque: usa la variable PORT si existe (Render, Railway), si no el 8080 */
:- initialization(iniciar, main).

iniciar :-
    (   getenv('PORT', P), atom_number(P, Puerto) -> true ; Puerto = 8080 ),
    http_server(http_dispatch, [port(Puerto)]),
    format("Servidor en http://localhost:~w~n", [Puerto]),
    thread_get_message(_).
