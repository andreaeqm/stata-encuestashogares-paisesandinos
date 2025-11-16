clear all
set more off


global collapsed "..."


global resultados "..."

cd "$collapsed"

**********************************************************************
* Bucle para hacer un merge de los indicadores por país
**********************************************************************

foreach indicador in tabla1 sexo rural gedad nivedu tamanio tipoempleo {

use `indicador'_per.dta, replace

append using `indicador'_col.dta `indicador'_ec.dta

label define paises 1 "Perú" 2 "Colombia" 3 "Ecuador"
label values pais paises

save `indicador'.dta, replace


}

**********************************************************************
* Gráficos
**********************************************************************

***************** 1. PEA ocupada por categoría bio ***********************

use tabla1.dta, replace

drop if status==.

reshape wide peso_estimado, i(pais) j(status)

graph bar (sum) peso_estimado1 peso_estimado2 peso_estimado3, ///
over(pais) stack percent graphregion(margin(l+5)) ///                  
        legend(position(bottom) rows(1) ///
           label(1 "Bioeconomía") ///
           label(2 "Bioeconomía extendida") ///
           label(3 "No bioeconomía") ///                
           size (vsmall)) ///
		   ytitle("Porcentaje (%)", size(small)) ///
    blabel(bar, position(center) format(%3.1f) color(white)) /// 
    ysize(4) xsize(5) ///
	title("Países andinos: distribución de la PEA ocupada según" "categoría bioeconómica, 2023", size(medium)) note("Elaboración propia con base a ENAHO, GEIH y ENEMDU (2023)")


graph export "$resultados/empleobio.png", replace		


***************** 2. PEA ocupada por sexo y cat bio **********************

use sexo.dta, replace

drop if status==.

reshape wide peso_estimado, i(pais status) j(mujer)


graph hbar (sum) peso_estimado0 peso_estimado1 if pais == 1, ///
    over(status) stack percent ///
    subtitle("Perú") ///
    graphregion(margin(l+5)) ///                  
        legend(position(bottom) rows(1) ///
           label(1 "Hombre") ///
           label(2 "Mujer") ///
           size (vsmall)) ///
    blabel(bar, position(center) format(%3.1f) color(white)) /// 
    name(g_peru_pct, replace) ysize(3) xsize(5)

graph hbar (sum) peso_estimado0 peso_estimado1 if pais == 2, ///
    over(status) stack percent ///
    subtitle("Colombia") ///
    graphregion(margin(l+5)) ///                  
        legend(position(bottom) rows(1) ///
           label(1 "Hombre") ///
           label(2 "Mujer") ///
           size (vsmall)) ///
    blabel(bar, position(center) format(%3.1f) color(white)) /// 
    name(g_colombia_pct, replace) ysize(3) xsize(5)
	
graph hbar (sum) peso_estimado0 peso_estimado1 if pais == 3, ///
    over(status) stack percent ///
    subtitle("Ecuador")  ///
    graphregion(margin(l+5)) ///                  
        legend(position(bottom) rows(1) ///
           label(1 "Hombre") ///
           label(2 "Mujer") ///
           size (vsmall)) ///
    blabel(bar, position(center) format(%3.1f) color(white)) /// 
    name(g_ecuador_pct, replace) ysize(3) xsize(5)


graph combine g_peru_pct g_colombia_pct g_ecuador_pct, row(3) col(1) ysize(10) xsize(6) title("Países andinos: distribución de la PEA ocupada según" "sexo y categoría bioeconómica, 2023", size(medium)) note("Elaboración propia con base a ENAHO, GEIH y ENEMDU (2023)")


graph export "$resultados/sexo.png", replace	


************** 3. PEA ocupada por rural/urbano y cat bio *****************
use rural.dta, replace

drop if status==.

reshape wide peso_estimado, i(pais status) j(rural)


graph hbar (sum) peso_estimado0 peso_estimado1 if pais == 1, ///
    over(status) stack percent ///
    subtitle("Perú") ///
    graphregion(margin(l+5)) ///                  
        legend(position(bottom) rows(1) ///
           label(1 "Urbano") ///
           label(2 "Rural") ///
           size (vsmall)) ///
    blabel(bar, position(center) format(%3.1f) color(white)) /// 
    name(g_peru_pct, replace) ysize(3) xsize(5)

graph hbar (sum) peso_estimado0 peso_estimado1 if pais == 2, ///
    over(status) stack percent ///
    subtitle("Colombia") ///
    graphregion(margin(l+5)) ///                  
        legend(position(bottom) rows(1) ///
           label(1 "Urbano") ///
           label(2 "Rural") ///
           size (vsmall)) ///
    blabel(bar, position(center) format(%3.1f) color(white)) /// 
    name(g_colombia_pct, replace) ysize(3) xsize(5)
	
graph hbar (sum) peso_estimado0 peso_estimado1 if pais == 3, ///
    over(status) stack percent ///
    subtitle("Ecuador")  ///
    graphregion(margin(l+5)) ///                  
        legend(position(bottom) rows(1) ///
           label(1 "Urbano") ///
           label(2 "Rural") ///
           size (vsmall)) ///
    blabel(bar, position(center) format(%3.1f) color(white)) /// 
    name(g_ecuador_pct, replace) ysize(3) xsize(5)


graph combine g_peru_pct g_colombia_pct g_ecuador_pct, row(3) col(1) ysize(10) xsize(6) title("Países andinos: distribución de la PEA ocupada según" "estrato y categoría bioeconómica, 2023", size(medium)) note("Elaboración propia con base a ENAHO, GEIH y ENEMDU (2023)")


graph export "$resultados/rural.png", replace	


***************** 4. PEA ocupada por g etario y cat bio *****************

use gedad.dta, replace

drop if status==.

reshape wide peso_estimado, i(pais status) j(g_edad)



graph hbar (sum) peso_estimado1 peso_estimado2 peso_estimado3 peso_estimado4 if pais == 1, ///
    over(status) stack percent ///
    subtitle("Perú") ///
    graphregion(margin(l+5)) ///                  
        legend(position(bottom) rows(1) ///
           label(1 "14-25") ///
           label(2 "26-40") ///
           label(3 "41-65") ///
           label(4 ">65") ///                       
           size (vsmall)) ///
    blabel(bar, position(center) format(%3.1f) color(white)) /// 
    name(g_peru_pct, replace) ysize(3) xsize(5)
	
graph hbar (sum) peso_estimado1 peso_estimado2 peso_estimado3 peso_estimado4 if pais == 2, ///
    over(status) stack percent ///
    subtitle("Colombia") ///
    graphregion(margin(l+5)) ///                  
    legend(position(bottom) rows(1) ///
           label(1 "14-25") ///
           label(2 "26-40") ///
           label(3 "41-65") ///
           label(4 ">65") ///                       
           size (vsmall)) ///    
		   blabel(bar, position(center) format(%3.1f) color(white)) /// 
    name(g_colombia_pct, replace) ysize(3) xsize(5)
	
	
graph hbar (sum) peso_estimado1 peso_estimado2 peso_estimado3 peso_estimado4 if pais == 3, ///
    over(status) stack percent ///
    subtitle("Ecuador") ///
    graphregion(margin(l+5)) ///                  
    legend(position(bottom) rows(1) ///
           label(1 "14-25") ///
           label(2 "26-40") ///
           label(3 "41-65") ///
           label(4 ">65") ///                       
           size (vsmall)) ///
    blabel(bar, position(center) format(%3.1f) color(white)) /// 
    name(g_ecuador_pct, replace) ysize(3) xsize(5)
	

graph combine g_peru_pct g_colombia_pct g_ecuador_pct, row(3) col(1) ysize(10) xsize(6) title("Países andinos: distribución de la PEA ocupada según" "grupo etario y categoría bioeconómica, 2023", size(medium)) note("Elaboración propia con base a ENAHO, GEIH y ENEMDU (2023)")


graph export "$resultados/gedad.png", replace		



**************** 5. PEA ocupada por nivedu y cat bio ********************

use nivedu.dta, replace

drop if status==.

recode niv_edu (1=1 "Baja") (2=2 "Media") (3=3 "Alta") (.=4 "No reporta"), gen(nivedu)


drop if niv_edu == .

drop nivedu
reshape wide peso_estimado, i(pais status) j(niv_edu)


graph hbar (sum) peso_estimado1 peso_estimado2 peso_estimado3 if pais == 1, ///
    over(status) stack percent ///
    subtitle("Perú") ///
    graphregion(margin(l+5)) ///                  
        legend(position(bottom) rows(1) ///
           label(1 "Bajo") ///
           label(2 "Medio") ///
           label(3 "Alto") ///                    
           size (vsmall)) ///
    blabel(bar, position(center) format(%3.1f) color(white)) /// 
    name(g_peru_pct, replace) ysize(3) xsize(5)
	
graph hbar (sum) peso_estimado1 peso_estimado2 peso_estimado3 if pais == 2, ///
    over(status) stack percent ///
    subtitle("Colombia") ///
    graphregion(margin(l+5)) ///                  
    legend(position(bottom) rows(1) ///
           label(1 "Bajo") ///
           label(2 "Medio") ///
           label(3 "Alto") ///                    
           size (vsmall)) ///                   
		   blabel(bar, position(center) format(%3.1f) color(white)) /// 
    name(g_colombia_pct, replace) ysize(3) xsize(5)
	
	
graph hbar (sum) peso_estimado1 peso_estimado2 peso_estimado3 if pais == 3, ///
    over(status) stack percent ///
    subtitle("Ecuador") ///
    graphregion(margin(l+5)) ///                  
    legend(position(bottom) rows(1) ///
           label(1 "Bajo") ///
           label(2 "Medio") ///
           label(3 "Alto") ///                    
           size (vsmall)) ///                    
    blabel(bar, position(center) format(%3.1f) color(white)) /// 
    name(g_ecuador_pct, replace) ysize(3) xsize(5)
	

graph combine g_peru_pct g_colombia_pct g_ecuador_pct, row(3) col(1) ysize(10) xsize(6) title("Países andinos: distribución de la PEA ocupada según" "nivel educativo y categoría bioeconómica, 2023", size(medium)) note("Elaboración propia con base a ENAHO, GEIH y ENEMDU (2023)")


graph export "$resultados/nivedu.png", replace		


*********** 6. PEA ocupada por tamanio empresa y cat bio ****************
use tamanio.dta, replace

drop if status==.

reshape wide peso_estimado, i(pais status) j(tamahno)



graph hbar (sum) peso_estimado1 peso_estimado2 peso_estimado3 peso_estimado4 if pais == 1, ///
    over(status) stack percent ///
    subtitle("Perú") ///
    graphregion(margin(l+5)) ///                  
        legend(position(bottom) rows(1) ///
           label(1 "De 1 a 10" "trabajadores") ///
           label(2 "De 11 a 50" "trabajadores") ///
           label(3 "De 51 a más" "trabajadores") ///
           label(4 "No" "especifica") ///                       
           size (vsmall)) ///
    blabel(bar, position(center) size(vsmall) format(%3.1f) color(white)) /// 
    name(g_peru_pct, replace) ysize(3) xsize(5)
	
graph hbar (sum) peso_estimado1 peso_estimado2 peso_estimado3 peso_estimado4 if pais == 2, ///
    over(status) stack percent ///
    subtitle("Colombia") ///
    graphregion(margin(l+5)) ///                  
    legend(position(bottom) rows(1) ///
           label(1 "De 1 a 10" "trabajadores") ///
           label(2 "De 11 a 50" "trabajadores") ///
           label(3 "De 51 a más" "trabajadores") ///
           label(4 "No" "especifica") ///                          
           size (vsmall)) ///    
		   blabel(bar, position(center) size(vsmall) format(%3.1f) color(white)) /// 
    name(g_colombia_pct, replace) ysize(3) xsize(5)
	
	
graph hbar (sum) peso_estimado1 peso_estimado2 peso_estimado3 peso_estimado4 if pais == 3, ///
    over(status) stack percent ///
    subtitle("Ecuador") ///
    graphregion(margin(l+5)) ///                  
    legend(position(bottom) rows(1)  ///
           label(1 "De 1 a 10" "trabajadores") ///
           label(2 "De 11 a 50" "trabajadores") ///
           label(3 "De 51 a más" "trabajadores") ///
           label(4 "No" "especifica") ///                          
           size (vsmall)) ///
    blabel(bar, position(center) size(vsmall) format(%3.1f) color(white)) /// 
    name(g_ecuador_pct, replace) ysize(3) xsize(5)
	

graph combine g_peru_pct g_colombia_pct g_ecuador_pct, row(3) col(1) ysize(10) xsize(6) title("Países andinos: distribución de la PEA ocupada según" "tamaño de empresa y categoría bioeconómica, 2023", size(medium)) note("Elaboración propia con base a ENAHO, GEIH y ENEMDU (2023)")


graph export "$resultados/tamanio.png", replace		





*********** 7. PEA ocupada por tipo de empleo y cat bio ****************
use tipoempleo.dta, replace

drop if status==.

reshape wide peso_estimado, i(pais status) j(tipo_empleo)



graph hbar (sum) peso_estimado1 peso_estimado2 peso_estimado3 peso_estimado4 peso_estimado5 peso_estimado6 if pais == 1, ///
    over(status) stack percent ///
    subtitle("Perú") ///
    graphregion(margin(l+5)) ///                  
        legend(position(bottom) rows(2) ///
           label(1 "Empleador") ///
           label(2 "Asalariado") ///
           label(3 "Empleado" "doméstico") ///
           label(4 "Cuenta propia") ///     
		   label(5 "Familiar o no" "remunerado") /// 
		   label(6 "Otro") ///    
           size (vsmall)) ///
    blabel(bar, position(center) format(%3.1f) color(white) size(vsmall)) /// 
    name(g_peru_pct, replace) ysize(3) xsize(5)
	
graph hbar (sum) peso_estimado1 peso_estimado2 peso_estimado3 peso_estimado4 peso_estimado5 peso_estimado6  if pais == 2, ///
    over(status) stack percent ///
    subtitle("Colombia") ///
    graphregion(margin(l+5)) ///                  
    legend(position(bottom) rows(2) ///
           label(1 "Empleador") ///
           label(2 "Asalariado") ///
           label(3 "Empleado" "doméstico") ///
           label(4 "Cuenta propia") ///     
		   label(5 "Familiar o no" "remunerado") /// 
		   label(6 "Otro") ///                       
           size (vsmall)) ///    
		   blabel(bar, position(center) format(%3.1f) color(white) size(vsmall)) /// 
    name(g_colombia_pct, replace) ysize(3) xsize(5)
	
	
graph hbar (sum) peso_estimado1 peso_estimado2 peso_estimado3 peso_estimado4 peso_estimado5 peso_estimado6  if pais == 3, ///
    over(status) stack percent ///
    subtitle("Ecuador") ///
    graphregion(margin(l+5)) ///                  
    legend(position(bottom) rows(2) ///
           label(1 "Empleador") ///
           label(2 "Asalariado") ///
           label(3 "Empleado" "doméstico") ///
           label(4 "Cuenta propia") ///     
		   label(5 "Familiar o no" "remunerado") /// 
		   label(6 "Otro") ///                      
           size (vsmall)) ///
    blabel(bar, position(center) format(%3.1f) color(white) size(vsmall)) /// 
    name(g_ecuador_pct, replace) ysize(3) xsize(5)
	

graph combine g_peru_pct g_colombia_pct g_ecuador_pct, row(3) col(1) ysize(10) xsize(6) title("Países andinos: distribución de la PEA ocupada según" "tipo de empleo y categoría bioeconómica, 2023", size(medium)) note("Elaboración propia con base a ENAHO, GEIH y ENEMDU (2023)")


graph export "$resultados/tipoempleo.png", replace		
