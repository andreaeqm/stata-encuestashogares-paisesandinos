clear all
set more off

global enemdupre "..."

global enemdupost "..."

global collapsed "..."


cd "$enemdupre"

**********************************************************************
* Importar la base de datos filtrando por las variables de interés
**********************************************************************

import spss "BDDenemdu_personas_2023_anual.sav"

keep area	ciudad	conglomerado	panelm	vivienda	hogar	p01	p02	p03	p10a	p10b	p12a	p12b	p20	p24	p25	p26	p27	p28	p29	p40	p41	p42	p47a	p47b	p48	p49	estrato	fexp	nnivins	ingrl	ingpc	condact	empleo	desempleo	secemp	rama1	prov	dominio	pobreza	epobreza	upm	id_vivienda	id_hogar	id_persona	periodo	mes

drop if condact == 0 | condact == 7 | condact == 8 | condact == 9

save "empleo_2023.dta", replace

**********************************************************************
* Clasificar los empleos según condición bioeconómica
**********************************************************************

* Importar el clasificador (elaboración propia) y convertirlo a dta

import excel "clasif_b.xlsx", sheet("clasif_b") firstrow clear

encode status, gen(status_temp) 
drop status
rename status_temp status

destring p40, replace

save clasif_b.dta, replace

* Hacer un merge con la base de datos de empleo para el 2023

use empleo_2023.dta, clear

merge m:1 p40 using "clasif_b.dta"

drop if _merge==2

drop _merge

save datos_empleo.dta, replace

**********************************************************************
* Creación de variables para indicadores
**********************************************************************


use datos_empleo.dta, replace

* Variables geográficas

recode area (1=0 "Urbano")(2=1 "Rural"), gen(rural)  

* provincia ya está

* Variables demográficas
recode p02 (1=0 "Hombre") (2=1 "Mujer"), gen(mujer)  //sexo

gen edad=p03  //edad

gen g_edad=.  //grupo etario
replace g_edad=1					if edad>=14	& edad<=25
replace g_edad=2					if edad>=26	& edad<=40
replace g_edad=3					if edad>=41	& edad<=65
replace g_edad=4					if edad>=66

label define gedad_etiq 1 "14-25" 2 "26-40" 3 "41-65" 4 ">65" 
label values g_edad gedad_etiq 


gen niv_edu=1 			if (p10a==1 | p10a==2 | p10a==3 | p10a==4)  
	replace niv_edu=2 				if (p10a==5 | p10a==6 | p10a==7)
	replace niv_edu=3				if (p10a==8 | p10a==9 | p10a==10)

label define ne_etiq	1 "Bajo" 2 "Medio" 3 "Alto"
				
label values niv_edu ne_etiq


* Variables ocupacionales

** Variables sobre la ocupación principal 

gen tipo_empleo=.  //tipo de ocupación
replace tipo_empleo=1					if p42==5
replace tipo_empleo=2					if (p42==1 | p42==2 | p42==3 | p42==4)
replace tipo_empleo=3					if p42==10 
replace tipo_empleo=4					if p42==6
replace tipo_empleo=5					if (p42==7  | p42== 8 | p42== 9)

label define tipo_empleo_etiq 1 "Empleador" 2 "Asalariados" 3 "Empleado doméstico" 4 "Cuenta propia" 5 "Familiar o no remunerado" 
label values tipo_empleo tipo_empleo_etiq 


** Variables ocupacionales en general

gen       tamahno=1 if p47b>=1  & p47b<11
replace tamahno=2 if p47b>=11 & p47b<51
replace tamahno=3 if p47b>50
replace tamahno=4 if p47b==.
label define tamahno 1 "De 1 a 10 trabajadores" 2 "De 11 a 50 trabajadores" /// 
3 "De 51 a más trabajadores" 4 "No especificado", replace
label value tamahno tamahno

save datos_bio.dta, replace


**********************************************************************
* Colapsar datos por indicador considerando el diseño muestral
**********************************************************************

use datos_bio.dta, replace


* Participación de cada categoría bioeconómica en la PEA ocupada


preserve

collapse (sum) peso_estimado=fexp, by(status)
format peso_estimado %12.0fc
gen pais = 3

save "$collapsed/tabla1_ec.dta", replace

restore

* Tabla de cantidad de empleados en la bioeconomía, por actividad 

preserve

collapse (sum) peso_estimado=fexp if status==1, by(p40)
format peso_estimado %12.0fc
gen pais = 1

outsheet p40 peso_estimado using trabajos1.csv, comma replace

restore

* Tabla de cantidad de empleados en la bioeconomía extendida, por actividad 

preserve

collapse (sum) peso_estimado=fexp if status==2, by(p40)
format peso_estimado %12.0fc
gen pais = 1

outsheet p40 peso_estimado using trabajos2.csv, comma replace

restore


* Sexo


preserve

collapse (sum) peso_estimado=fexp, by(status mujer)
format peso_estimado %12.0fc
gen pais = 3

save "$collapsed/sexo_ec.dta", replace

restore


* Rural


preserve

collapse (sum) peso_estimado=fexp, by(status rural)
format peso_estimado %12.0fc
gen pais = 3

save "$collapsed/rural_ec.dta", replace

restore



* Grupo etario



preserve

collapse (sum) peso_estimado=fexp, by(status g_edad)
format peso_estimado %12.0fc
gen pais = 3

save "$collapsed/gedad_ec.dta", replace

restore

* Nivel educativo

preserve

collapse (sum) peso_estimado=fexp, by(status niv_edu)
format peso_estimado %12.0fc
gen pais = 3

save "$collapsed/nivedu_ec.dta", replace

restore

* Tamaño de empresa


preserve

collapse (sum) peso_estimado=fexp, by(status tamahno)
format peso_estimado %12.0fc
gen pais = 3

save "$collapsed/tamanio_ec.dta", replace

restore


* Tipo de empleo


preserve

collapse (sum) peso_estimado=fexp, by(status tipo_empleo)
format peso_estimado %12.0fc
gen pais = 3

save "$collapsed/tipoempleo_ec.dta", replace

restore



* Distribución del empleo en cada categoría por departamento


collapse (sum) peso_estimado=fexp, by(status prov)

save "prov_bio.dta", replace


**********************************************************************
* Mapa
**********************************************************************

use "prov_bio.dta", clear


gen pea_total_region = caracteristico + extendido + no_caracteristico

gen pct_caracteristico = (caracteristico / pea_total_region) * 100
gen pct_extendido = (extendido / pea_total_region) * 100
gen pct_no_bio = (no_caracteristico / pea_total_region) * 100

save "part_bio.dta", replace


* Convertir el mapa en shapefile a dta

*ssc install shp2dta


shp2dta using "LIMITE_PROVINCIAL_CONALI_CNE_2022.shp", coordinates("aux_perdep_xy.dta") ///
database("aux_perdep_shp.dta") genid(id_prov) replace


* Desplazamiento de regiones para mejor visualización


use "aux_perdep_xy.dta", clear


summarize _X _Y if _ID == 20  // Coordenadas de Galápagos
summarize _X _Y if _ID != 20  // Coordenadas del Continente


local x_shift = 880000 

replace _X = _X + `x_shift' if _ID == 20


save "aux_perdep_xy.dta", replace

* Creación de cada mapa


use "aux_perdep_shp", clear

rename id_prov prov

merge 1:1 prov using "part_bio.dta"
drop if _merge==1

format pct_caracteristico %12.2fc
format pct_extendido %12.2fc
format pct_no_bio %12.2fc

*ssc install spmap
spmap pct_caracteristico using "aux_perdep_xy.dta", id(prov) ///
												fcolor(Reds) ///
												clnumber(8) ///
												subtitle("Bioeconomía característica") name (bio1, replace) 

spmap pct_extendido using "aux_perdep_xy.dta", id(prov) ///
												fcolor(Reds) ///
												clnumber(8) ///
												subtitle("Bioeconomía extendida") name (bio2, replace) 
												
spmap pct_no_bio using "aux_perdep_xy.dta", id(prov) ///
												fcolor(Reds) ///
												clnumber(8) ///
												subtitle("No bioeconomía") name (bio3, replace) 

* Unión de los tres mapas en un solo gráfico		
												
graph combine bio1 bio2 bio3, row(1) col(3) iscale(0.6) imargin(medium) ///
		title("Ecuador: participación del empleo según categoría bioeconómica por región, 2023") note("Elaboración propia con base a ENEMDU 2023") ysize(5) xsize(10)

graph export "mapa_participacion.png", replace

