/* clima */
/* clima ( temperatura, abrigo máximo, ¿se necesita capa exterior?, abrigo de la prenda exterior ) */
/* Nota: Se considera al 0 como "ninguno", es decir, en el clima caluroso no se necesita de una capa externa */

clima(calor, 1, no, 0).
clima(templado, 2, no, 2).
clima(templado, 2, si, 2).
clima(frio, 3, si, 3).
