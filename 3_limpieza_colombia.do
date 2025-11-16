clear all
set more off

global geihpre "..."

global geihpost "..."

global collapsed "..."

cd "$geihpre"


**********************************************************************
* Crear la base de datos para el año 2023 
**********************************************************************


* Append de todos los meses para PEA ocupada y todos los encuestados

use jan-Ocupados.DTA, clear

append using "feb-Ocupados.DTA" "mar-Ocupados.DTA" "apr-Ocupados.DTA" "may-Ocupados.DTA" "jun-Ocupados.DTA" "jul-Ocupados.DTA" "ago-Ocupados.DTA" "sep-Ocupados.DTA" "oct-Ocupados.DTA" "nov-Ocupados.DTA" "dic-Ocupados.DTA"

save "ocupados.dta", replace

use jan-Personas.DTA, replace
append using "feb-Personas.DTA" "mar-Personas.DTA" "apr-Personas.DTA" "may-Personas.DTA" "jun-Personas.DTA" "jul-Personas.DTA" "ago-Personas.DTA" "sep-Personas.DTA" "oct-Personas.DTA" "nov-Personas.DTA" "dic-Personas.DTA"

save "personas.dta", replace

* Filtro de variables 

use P3039 P3271 P6040 P3042 P3042S1 P3042S2 P3043 P3043S1 DIRECTORIO SECUENCIA_P ORDEN using "$geihpre/personas.dta", clear

save "personas_filtered.dta", replace

use CLASE P6920	P6915 P3069 P6430 FEX_C18 DPTO AREA RAMA4D_R4 RAMA2D_R4 DIRECTORIO SECUENCIA_P ORDEN using "$geihpre/ocupados.dta", clear

save "ocupados_filtered.dta", replace


* Merge usando el identificador sugerido por la guía metodológica de uso de la encuesta

use personas_filtered.dta, replace
merge 1:1 DIRECTORIO SECUENCIA_P ORDEN using ocupados_filtered.dta
keep if _merge==3

drop _merge
save datos_empleo.dta, replace /// Esta es la base de datos para el 2023

**********************************************************************
* Clasificar los empleos según condición bioeconómica
**********************************************************************

* Importar el clasificador (elaboración propia) y convertirlo a dta

import excel "$geihpre/clasif_b.xlsx", sheet("clasif_b") firstrow clear

encode Status, gen(status_temp) 
drop Status
rename status_temp status

save clasif_b.dta, replace

* Hacer un merge con la base de datos de empleo para el 2023

use datos_empleo.dta, clear

merge m:1 RAMA4D_R4 using "clasif_b.dta"

drop if _merge==2

replace status = . if _merge==1

drop _merge

save datos_empleo.dta, replace

**********************************************************************
* Creación de variables para indicadores
**********************************************************************

use datos_empleo.dta, clear

* Generación de la variable sexo
			
		gen mujer = .
		replace mujer = 0 if P3271 ==1 
		replace mujer = 1 if P3271 ==2
			
		label var mujer "Hombre / Mujer"
		label define sexo 0 "Hombre" 1 "Mujer"
		label values mujer sexo
		
* Edad de la persona	

		gen edad = P6040
		label var edad "Edad de la persona"
		
* Definición de Grupos Etarios
	
		gen g_edad=.  //grupo etario
		replace g_edad=1					if edad>=14	& edad<=25
		replace g_edad=2					if edad>=26	& edad<=40
		replace g_edad=3					if edad>=41	& edad<=65
		replace g_edad=4					if edad>=66

		label define gedad_etiq 1 "14-25" 2 "26-40" 3 "41-65" 4 ">65" 
		label values g_edad gedad_etiq 
		
* Rural 	
		
		destring CLASE, replace

		recode CLASE (1=0 "Urbano")(2=1 "Rural"), gen(rural)  

* Definicion del numero de personas por empresa

		gen tamahno = .
		replace tamahno = 1 if (P3069 == 1 | P3069 == 2 | P3069 == 3 | P3069 == 4)
		replace tamahno = 2 if (P3069 == 5 | P3069 == 6 | P3069 == 7)
		replace tamahno = 3 if (P3069 == 8 | P3069 == 9 | P3069 == 10)

label define tamahno 1 "De 1 a 10 trabajadores" 2 "De 11 a 50 trabajadores" 3 "De 51 a más trabajadores", replace
label value tamahno tamahno
		
		
* Tipos de Ocupados: Asalariados, Cuenta propia, empleados domesticos y otros....

gen tipo_empleo=.  //tipo de ocupación
replace tipo_empleo=1					if P6430==5 
replace tipo_empleo=2					if (P6430==1 | P6430==2 | P6430==8)
replace tipo_empleo=3					if P6430==3
replace tipo_empleo=4					if P6430==4
replace tipo_empleo=5					if (P6430==6 | P6430==7)
replace tipo_empleo=6					if P6430==9

label define tipo_empleo 1 "Empleador" 2 "Asalariados" 3 "Empleado doméstico" 4 "Cuenta propia" 5 "Familiar o no remunerado" 6 "Otro"

label values tipo_empleo tipo_empleo

* Nivel educativo: clasificación en un indicador comparable con otros países de sistemas educativos distintos


gen niv_edu=1 			if (P3042==1 | P3042==2 | P3042==3 )  
	replace niv_edu=2 				if (P3042==4 | P3042==5 | P3042==6)
	replace niv_edu=3				if (P3042==7 | P3042==8 | P3042==9 |P3042==10 |P3042==11 | P3042==12 | P3042==13)
	replace niv_edu=. if (P3042==99)

label define ne_etiq	1 "Bajo" 2 "Medio" 3 "Alto"
				
label values niv_edu ne_etiq

* Departamentos


gen departamento = substr(DPTO,1,2) // Corregido: ubigeo -> ubigeo_
destring departamento, replace
label var departamento "Departamento"
#delimit ;
label define departamento_etiq
05	"ANTIOQUIA" 08	"ATLANTICO" 11	"BOGOTA" 13	"BOLIVAR" 15 "BOYACA" 17 "CALDAS" 18	"CAQUETA" 19	"CAUCA" 20	"CESAR" 23	"CORDOBA" 25	"CUNDINAMARCA" 27	"CHOCO" 41	"HUILA" 44	"LA GUAJIRA" 47	"MAGDALENA" 50	"META" 52	"NARIÑO" 54	"NORTE DE SANTANDER" 63	"QUINDIO" 66	"RISALRALDA" 68	"SANTANDER" 70	"SUCRE" 73	"TOLIMA" 76	"VALLE" 81	"ARAUCA" 85	"CASANARE" 86	"PUTUMAYO" 88	"SAN ANDRES" 91	"AMAZONAS" 94	"GUAINIA"  95 "GUAVIARE"  99 "VICHADA";
#delimit cr
label values departamento departamento_etiq

gen ocu = 1

save empleo_final.dta, replace


**********************************************************************
* Colapsar datos por indicador considerando el diseño muestral
**********************************************************************


use empleo_final.dta, clear


* Participación de cada categoría bioeconómica en la PEA ocupada

preserve

collapse (count) ocu [pw = FEX_C18/12], by(status)
rename ocu peso_estimado
format peso_estimado %12.0fc
gen pais = 2

save "$collapsed/tabla1_col.dta", replace

restore

* Tabla de cantidad de empleados en la bioeconomía, por actividad 

preserve

collapse (count) ocu if status==1 [pw = FEX_C18/12], by(RAMA4D_R4)
format ocu %12.0fc
gen pais = 1

outsheet RAMA4D_R4 ocu using trabajos1.csv, comma replace

restore

* Tabla de cantidad de empleados en la bioeconomía extendida, por actividad 

preserve

collapse (count) ocu if status==2 [pw = FEX_C18/12], by(RAMA4D_R4)
format ocu %12.0fc
gen pais = 1

outsheet RAMA4D_R4 ocu using trabajos2.csv, comma replace

restore


* Sexo

preserve

collapse (count) ocu [pw = FEX_C18/12], by(status mujer)
rename ocu peso_estimado
format peso_estimado %12.0fc
gen pais = 2

save "$collapsed/sexo_col.dta", replace

restore



* Rural

preserve

collapse (count) ocu [pw = FEX_C18/12], by(status rural)
rename ocu peso_estimado
format peso_estimado %12.0fc
gen pais = 2

save "$collapsed/rural_col.dta", replace

restore



* Grupo etario

preserve

collapse (count) ocu [pw = FEX_C18/12], by(status g_edad)
rename ocu peso_estimado
format peso_estimado %12.0fc
gen pais = 2

save "$collapsed/gedad_col.dta", replace

restore


* Nivel educativo

preserve

collapse (count) ocu [pw = FEX_C18/12], by(status niv_edu)
rename ocu peso_estimado
format peso_estimado %12.0fc
gen pais = 2

save "$collapsed/nivedu_col.dta", replace

restore


* Tamaño de empresa


preserve

collapse (count) ocu [pw = FEX_C18/12], by(status tamahno)
rename ocu peso_estimado
format peso_estimado %12.0fc
gen pais = 2

save "$collapsed/tamanio_col.dta", replace

restore


* Tipo de empleo


preserve

collapse (count) ocu [pw = FEX_C18/12], by(status tipo_empleo)
rename ocu peso_estimado
format peso_estimado %12.0fc
gen pais = 2

save "$collapsed/tipoempleo_col.dta", replace

restore


* Distribución del empleo en cada categoría por departamento


collapse (count)  ocu [pw = FEX_C18/12], by(status departamento)

save "departamentos_bio.dta", replace

use departamentos_bio.dta, replace
reshape wide ocu, i(departamento) j(status)

rename ocu1 bioeconomia
rename ocu2 bioeconomiaext
rename ocu3 nobioeconomia

save "departamentos_bio.dta", replace

**********************************************************************
* Mapa
**********************************************************************

use departamentos_bio.dta, clear

gen pea_total_region = bioeconomia + bioeconomiaext + nobioeconomia
gen pct_caracteristico = (bioeconomia / pea_total_region) * 100
gen pct_extendido = (bioeconomiaext / pea_total_region) * 100
gen pct_no_bio = (nobioeconomia / pea_total_region) * 100


save "part_bio.dta", replace


* Convertir el mapa en shapefile a dta

*ssc install shp2dta


shp2dta using "MGN_ADM_DPTO_POLITICO.shp", coordinates("aux_perdep_xy.dta") ///
database("aux_perdep_shp.dta") genid(id_departamento) replace


use "aux_perdep_shp", clear

destring dpto_ccdgo, replace
rename dpto_ccdgo departamento

save "aux_perdep_shp", replace


* Creación de cada mapa


use "aux_perdep_shp", clear


merge 1:1 departamento using "part_bio.dta", keep(master match)

format %12.2fc pct_caracteristico pct_extendido pct_no_bio


spmap pct_caracteristico using "aux_perdep_xy.dta", id(id_departamento) ///
												fcolor(Reds) ///
												clnumber(8) ///
												subtitle("Bioeconomía característica")  name (bio1, replace) 

spmap pct_extendido using "aux_perdep_xy.dta", id(id_departamento) ///
												fcolor(Reds) ///
												clnumber(8) ///
												subtitle("Bioeconomía extendida") name (bio2, replace) 
												
spmap pct_no_bio using "aux_perdep_xy.dta", id(id_departamento) ///
												fcolor(Reds) ///
												clnumber(8) ///
												subtitle("No bioeconomía") name (bio3, replace) 

* Unión de los tres mapas en un solo gráfico
												
graph combine bio1 bio2 bio3, row(1) col(3) iscale(0.5)  ///
		title("Colombia: participación del empleo según categoría bioeconómica" "por región, 2023") note("Elaboración propia con base a GEIH 2023") ysize(6) xsize(10)

graph export "mapa_participacion.png", replace	


