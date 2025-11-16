# Análisis comparativo del empleo en la bioeconomía (Perú, Ecuador, Colombia)

## Objetivo

Este proyecto analiza y compara la estructura del empleo bioeconómico en Perú, Ecuador y Colombia. El objetivo es clasificar la Población Económicamente Activa (PEA) ocupada en tres categorías (empleo bioeconómico, bioeconómico extendido y no bioeconómico) basándose en una clasificación de actividades según códigos CIIU predefinida.

El análisis se realiza a partir de encuestas de cada país:
* **Perú:** Encuesta Nacional de Hogares (ENAHO)
* **Ecuador:** Encuesta Nacional de Empleo, Desempleo y Subempleo (ENEMDU)
* **Colombia:** Gran Encuesta Integrada de Hogares (GEIH)

## Herramientas

El proyecto se desarrolló en Stata. La metodología se divide en dos fases principales, reflejadas en la estructura de los `dofiles`:

### Fase 1: limpieza y procesamiento por país

Se utiliza un script para cada encuesta. Cada script realiza el proceso de limpieza, preparación de variables, clasificación CIIU y colapso de los datos para obtener los indicadores de interés. Además generan mapas para indicar la participación relativa de la PEA ocupada en empleos de la bioeconomía respecto de la PEA ocupada total a nivel regional. 

* `1_limpieza_peru.do`: Procesa la ENAHO (Perú)
* `2_limpieza_ecuador.do`: Procesa la ENEMDU (Ecuador).
* `3_limpieza_colombia.do`: Procesa la GEIH (Colombia).

Los resultados de esta fase son 21 bases de datos (`.dta`) colapsadas para los 7 indicadores, una por cada país.

### Fase 2: Armonización y Gráficos Comparativos

El script `4_graficos_finales.do` unifica (`merge`) las tres bases de datos de indicadores y genera los gráficos comparativos finales que permiten contrastar la situación del empleo bioeconómico en el grupo de países andinos.

## Resultados

A continuación, se presentan algunos de los resultados visuales generados por los scripts.

### Mapa de empleo según condición bioeconómica en Colombia

<img width="913" height="548" alt="mapa_participacion" src="https://github.com/user-attachments/assets/77c01ce4-f54c-4bb7-8ee8-cdb11d5247cf" />


### Gráficos Comparativos (Perú, Ecuador, Colombia)

<img width="769" height="615" alt="empleobio" src="https://github.com/user-attachments/assets/2bc496c9-37d2-40c8-b86e-5bae5b1517d6" />

<img width="369" height="615" alt="rural" src="https://github.com/user-attachments/assets/5c2e6ad8-0040-43a1-b20e-e6f12cd27a4e" />


## Nota sobre los Datos

Para replicar el análisis, los `dofiles` deben ejecutarse en un entorno que contenga acceso a las bases de las encuestas mencioandas, ajustando las rutas (`globals`) de entrada y salida en cada script. Los archivos `.dta` colapsados en `/output_data` son los insumos directos para el script `4_graficos_finales.do`.
