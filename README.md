# FisioISA – Base de datos

Proyecto académico de diseño de una base de datos relacional para la gestión de una clínica de fisioterapia.

## Contenido

- `TABLAS.sql`: creación de la base de datos, tablas, relaciones y consultas de ejemplo.
- `FUNCIONES.sql`: funciones almacenadas.
- `PROCEDIMIENTOS.sql`: procedimientos almacenados.
- `TRIGGERS.sql`: triggers de validación.

## Orden recomendado de ejecución

1. `TABLAS.sql`
2. `FUNCIONES.sql`
3. `PROCEDIMIENTOS.sql`
4. `TRIGGERS.sql`

Los scripts están preparados para un entorno MySQL/MariaDB compatible con la sintaxis utilizada en el proyecto. Puede ser necesario adaptar algunas instrucciones según la versión concreta del gestor.

## Privacidad y datos de ejemplo

Esta copia se ha preparado para compartir el código sin incluir los registros de ejemplo que contenían nombres, documentos identificativos, datos de contacto y textos de historiales clínicos. También se han retirado las llamadas de prueba que utilizaban esos registros.

Por tanto, las tablas se crean vacías: para ejecutar consultas o probar funciones, procedimientos y triggers, primero habrá que cargar datos ficticios propios. No se han modificado intencionadamente las definiciones principales de tablas, funciones, procedimientos ni triggers.

## Contexto

Trabajo académico realizado en equipo. Los datos y el sistema son de carácter demostrativo y no deben utilizarse para gestionar información clínica real.
