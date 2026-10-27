# Imagen oficial de SWI-Prolog (ya incluye las librerías HTTP)
FROM swipl:latest

# Para que se lean bien los acentos de los comentarios
ENV LANG=C.UTF-8

# Carpeta de trabajo: aquí deben estar server.pl, las reglas, los datos y static/
WORKDIR /app
COPY . /app

# Render asigna el puerto con la variable PORT y server.pl ya la lee
CMD ["swipl", "server.pl"]
