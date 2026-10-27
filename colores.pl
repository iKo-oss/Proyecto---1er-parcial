/* Colores */
/* Otoño */
temporada_paleta(otonio, 110, [marron_terracota, marron_oscuro]).
temporada_paleta(otonio, 241, [rojo_vivo, amarillo_claro, ocre_mostaza,verde_petroleo]).

/* Invierno */
temporada_paleta(invierno, 16, [rojo_granate, menta_palido]).
temporada_paleta(invierno, 51, [rojo_carmesi, azul_brillante]).
temporada_paleta(invierno, 60, [amarillo_claro, azul_marino]).
temporada_paleta(invierno, 69, [verde_sage, negro]).

/* Primavera */
temporada_paleta(primavera, 143, [azul_brillante, lavanda, verde_sage]).
temporada_paleta(primavera, 330, [verde_pera, agua_menta, azul_cielo, verde_jade]).

/* Verano */
temporada_paleta(verano, 125, [rosa_palido, turquesa, azul_cobalto]).
temporada_paleta(verano, 189, [amarillo_neon, verde_boscoso, verde_menta]).
temporada_paleta(verano, 60, [amarillo_claro, azul_marino]).

/* PUENTE: CLIMA Y TEMPORADA */

clima_temporada(calor, verano).
clima_temporada(templado, primavera).
clima_temporada(templado, otonio).
clima_temporada(frio, invierno).

/* Colores neutros */
/* Nota: estos colores serán considerados válidos para cualquier temporada*/
color_neutro(blanco).
color_neutro(negro).
color_neutro(gris).
color_neutro(beige).
color_neutro(crema).
color_neutro(azul_marino).
color_neutro(marron_oscuro).
color_neutro(azul_denim). 
/* El azul denim es específico para prendas de mezclilla */
