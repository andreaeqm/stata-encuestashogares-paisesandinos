clear all
set more off


global enahopre "..."
global enahopost "..."

global collapsed "..."


cd "$enahopre"

**********************************************************************
* Importar la base de datos filtrando por las variables de interés
**********************************************************************

use conglome vivienda hogar codperso estrato ubigeo p203 p204 p205 p206 p207 p208a p301a ocupinf p506r4 p507 fac500a ocu500 i524a1 d529t i530a d536 i538a1 d540t i541a d543 d544t p512a p513t p512b using "$enahopre/enaho01a-2023-500.dta", clear

keep if p204==1 & (p203!=8 & p203!=9) & !missing(p203)  //solo miembros del hogar

keep if ocu500==1 // solo pea ocupada

save "enaho_empleo.dta", replace


**********************************************************************
* Clasificar los empleos según condición bioeconómica
**********************************************************************

* Importar el clasificador (elaboración propia) y convertirlo a dta

import excel "$enahopre/clasif_b.xlsx", sheet("clasif_b") firstrow clear
rename codrev4 p506r4

destring p506r4, replace
isid p506r4
save "clasif_b.dta", replace

* Hacer un merge con la base de datos de empleo para el 2023

use "enaho_empleo.dta", clear

merge m:1 p506r4 using "clasif_b.dta"

keep if _merge==3

drop _merge

save "enaho_pea.dta", replace

**********************************************************************
* Creación de variables para indicadores
**********************************************************************

use "enaho_pea.dta", clear


* Variables geográficas

recode estrato (1/5=0 "Urbano")(6/8=1 "Rural"), gen(rural)  //urbano

tostring ubigeo, replace

gen departamento = substr(ubigeo,1,2) // Corregido: ubigeo -> ubigeo_
destring departamento, replace
label var departamento "Departamento"
#delimit ;
label define departamento_etiq
1 "Amazonas" 2 "Ancash" 3 "Apurimac" 4 "Arequipa"
5 "Ayacucho" 6 "Cajamarca" 7 "Callao" 8 "Cusco"
9 "Huancavelica" 10 "Huanuco" 11 "Ica" 12 "Junin"
13 "La Libertad" 14 "Lambayeque" 15 "Lima" 16 "Loreto"
17 "Madre de Dios" 18 "Moquegua" 19 "Pasco" 20 "Piura"
21 "Puno" 22 "San Martin" 23 "Tacna" 24 "Tumbes"
25 "Ucayali" ;
#delimit cr
label values departamento departamento_etiq


* Variables demográficas
recode p207 (1=0 "Hombre") (2=1 "Mujer"), gen(mujer)  //sexo

gen edad=p208a  //edad

gen g_edad=.  //grupo etario
replace g_edad=1					if edad>=14	& edad<=25
replace g_edad=2					if edad>=26	& edad<=40
replace g_edad=3					if edad>=41	& edad<=65
replace g_edad=4					if edad>=66

label define gedad_etiq 1 "14-25" 2 "26-40" 3 "41-65" 4 ">65" 
label values g_edad gedad_etiq 


gen niv_edu=1 			if (p301a==1 | p301a==2 | p301a==3 | p301a==4 | p301a==12)  
	replace niv_edu=2 				if (p301a==5 | p301a==6 )
	replace niv_edu=3				if (p301a==7 | p301a==9 | p301a==8 | p301a==10 | p301a==11)

label define ne_etiq	1 "Bajo" 2 "Medio" 3 "Alto"
				
label values niv_edu ne_etiq


* Variables ocupacionales

gen tipo_empleo=.  //tipo de ocupación
replace tipo_empleo=1					if p507==1
replace tipo_empleo=2					if (p507==3 | p507==4)
replace tipo_empleo=3					if p507==6 
replace tipo_empleo=4					if p507==2 
replace tipo_empleo=5					if (p507==5 | p507==7)
replace tipo_empleo=6					if p507==7

label define tipo_empleo_etiq 1 "Empleador" 2 "Asalariados" 3 "Empleado doméstico" 4 "Cuenta propia" 5 "Familiar o no remunerado" 6 "Otro"

label values tipo_empleo tipo_empleo_etiq 


* Tamaño de empresa

gen       tamahno=1 if p512b>=1  & p512b<11
replace tamahno=2 if p512b>=11 & p512b<51
replace tamahno=3 if p512b>50
replace tamahno=4 if p512b==. & (p512a==1 | p512a==2 )
label define tamahno 1 "De 1 a 10 trabajadores" 2 "De 11 a 50 trabajadores" /// 
3 "De 51 a más trabajadores" 4 "No especificado", replace
label value tamahno tamahno



* Cambiar la variable status a categórica y modificar sus etiquetas

encode status, gen(status_bio)

recode status_bio (1=1 "Caracteristico") (2/3=0 "No caracteristico"), gen(bio_2)


encode status, gen(status_temp)

drop status

rename status_temp status

label define status_labels 1 "Bioeconomia" ///
                           2 "Bioeconomia extendida" ///
                           3 "No bioeconomia", replace

label values status status_labels

save "enaho_pea_bio.dta", replace



**********************************************************************
* Colapsar datos por indicador considerando el diseño muestral
**********************************************************************


use "enaho_pea_bio.dta", clear

* Participación de cada categoría bioeconómica en la PEA ocupada


preserve

collapse (sum) peso_estimado=fac500a, by(status)
format peso_estimado %12.0fc
gen pais = 1

save "$collapsed/tabla1_per.dta", replace
restore

* Tabla de cantidad de empleados en la bioeconomía, por actividad 

preserve

collapse (sum) peso_estimado=fac500a if status==1, by(p506r4)
format peso_estimado %12.0fc
gen pais = 1

outsheet p506r4 peso_estimado using trabajos1.csv, comma replace

restore

* Tabla de cantidad de empleados en la bioeconomía extendida, por actividad 

preserve

collapse (sum) peso_estimado=fac500a if status==2, by(p506r4)
format peso_estimado %12.0fc
gen pais = 1

outsheet p506r4 peso_estimado using trabajos2.csv, comma replace

restore


* Sexo


preserve

collapse (sum) peso_estimado=fac500a, by(status mujer)
format peso_estimado %12.0fc
gen pais = 1

save "$collapsed/sexo_per.dta", replace

restore

* Rural


preserve

collapse (sum) peso_estimado=fac500a, by(status rural)
format peso_estimado %12.0fc
gen pais = 1

save "$collapsed/rural_per.dta", replace

restore

* Grupo etario

preserve

collapse (sum) peso_estimado=fac500a, by(status g_edad)
format peso_estimado %12.0fc
gen pais = 1

save "$collapsed/gedad_per.dta", replace

restore


* Nivel educativo


preserve

collapse (sum) peso_estimado=fac500a, by(status niv_edu)
format peso_estimado %12.0fc
gen pais = 1

save "$collapsed/nivedu_per.dta", replace

restore

* Tamaño de empresa


preserve

collapse (sum) peso_estimado=fac500a, by(status tamahno)
format peso_estimado %12.0fc
gen pais = 1

save "$collapsed/tamanio_per.dta", replace

restore

* Tipo de empleo

preserve

collapse (sum) peso_estimado=fac500a, by(status tipo_empleo)
format peso_estimado %12.0fc
gen pais = 1

save "$collapsed/tipoempleo_per.dta", replace

restore


* Distribución del empleo en cada categoría por departamento


collapse (sum) peso_estimado=fac500a, by(status_bio departamento)

save "departamentos_bio.dta", replace

**********************************************************************
* Mapa
**********************************************************************

use departamentos_bio.dta, replace
reshape wide peso_estimado, i(departamento) j(status_bio)

rename peso_estimado1 caracteristico
rename peso_estimado2 extendido
rename peso_estimado3 no_caracteristico

save "departamentos_bio.dta", replace


use "departamentos_bio.dta", replace

gen pea_total_region = caracteristico + extendido + no_caracteristico

gen pct_caracteristico = (caracteristico / pea_total_region) * 100
gen pct_extendido = (extendido / pea_total_region) * 100
gen pct_no_bio = (no_caracteristico / pea_total_region) * 100

save "part_bio.dta", replace


* Convertir el mapa en shapefile a dta

*ssc install shp2dta

shp2dta using "DEPARTAMENTOS_LIMITES/DEPARTAMENTOS.shp", coordinates("aux_perdep_xy.dta") ///
database("aux_perdep_shp.dta") genid(id_departamento) replace


use "aux_perdep_shp", clear

rename id_departamento departamento

merge 1:1 departamento using "part_bio.dta", keep(master match)

format %12.2fc pct_caracteristico pct_extendido pct_no_bio

* Creación de cada mapa

*ssc install spmap

spmap pct_caracteristico using "aux_perdep_xy.dta", id(departamento) ///
												fcolor(Reds) ///
												clnumber(8) ///
												subtitle("Bioeconomía característica") name (bio1, replace) 

spmap pct_extendido using "aux_perdep_xy.dta", id(departamento) ///
												fcolor(Reds) ///
												clnumber(8) ///
												subtitle("Bioeconomía extendida") name (bio2, replace) 
												
spmap pct_no_bio using "aux_perdep_xy.dta", id(departamento) ///
												fcolor(Reds) ///
												clnumber(8) ///
												subtitle("No bioeconomía") name (bio3, replace) 


* Unión de los tres mapas en un solo gráfico		

												
graph combine bio1 bio2 bio3, row(1) col(3) iscale(0.6) imargin(zero) ///
		title("Perú: participación del empleo según categoría bioeconómica" "por región, 2023") note("Elaboración propia con base a ENAHO 2023") ysize(5) xsize(10)

graph export "mapa_participacion.png", replace	




