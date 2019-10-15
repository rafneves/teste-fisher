/*
 * fisher.do - IMPLEMENTAR O TESTE EXATO DE FISHER E O TESTE DE FISHER
 * 	       SIMULADO
 */
capture program drop fisher
program define fisher, eclass byable(recall) 
	version 10
	syntax varlist(min=2 max=2 numeric) [if] [in] [, a(real 1) b(real 0) sim(integer 0) alpha(real 0.05)]

	if ((`alpha' <= 0) | (`alpha' >= 1)){
		display as error "Opção" as input " alpha " as error "tem de estar entre zero e um."
		exit 198
	}

	if (`a' == 0){
		display as error "Opção" as input " a " as error "não pode ser zero."
		exit 198
	}

	if (`sim' < 0){
		display as error "Opção" as input " sim " as error "não pode ser negativa."
		exit 198
	}

	tokenize `varlist'
	quietly {
		gen __vtrat = ((`2' != 0) & (`2' != 1))
		sum __vtrat
		local maxvtrat r(max)
		drop __vtrat
	}

	if (`maxvtrat' != 0){
		display as error "Variável de tratamento " as input "`2'" as error " " as error "só pde assumir os valores 0 e 1."
		exit 198
	}
	

	marksample touse
	mata:fishertst("`varlist'", "`touse'", `a', `b', `sim')

	if (`sim' == 0){
		display as txt "Teste de Fisher: Variável " as input "`1'" as txt ", a = " as input "`a'" as txt ", b = " as input "`b'" as txt " estatística " as res e(tfisher) as txt ", p-valor do teste exato de fisher " as res e(pfisher)	
	} 
	else {
		local zcritico = invnormal(1 - `alpha'/2)
		display as txt "Teste de Fisher: Variável " as input "`1'" as txt ", a = " as input "`a'" as txt ", b = " as input "`b'" as txt  as txt " estatística " as res e(tfisher) as txt ", p-valor do teste simulado de fisher " as res e(pfisher) as txt " (desv. padrao " as res e(se_pfisher) as txt "). Intervalo de Confiança (" as res 100*(1 - `alpha') as res "%" as txt ") [" as res e(pfisher) - `zcritico'*e(se_pfisher)  as txt "," as res e(pfisher) + `zcritico'*e(se_pfisher)  as txt "]"
	}
end

version 10
mata:
real scalar fisher_ext(y, w, real scalar nunids, real scalar ntrat, real scalar tobs, real scalar a, real scalar b){
	/* MATRIZ COM AS COMBINACOES POSSIVEIS, EXCETO (0, ..., 0) E (1, ..., 1) */
	real scalar res, j
	tmpw = J(nunids, 1,0)
	res = 0
	j = 0
 
	for(i=1; i <= ntrat; ++i) 
		tmpw = tmpw + e(i,nunids)'
	
	info = cvpermutesetup(tmpw)
	while ((p=cvpermute(info)) != J(0,1,.)){
		tmpy = ((p :* (a*y + b*(1 :- w))) + ((1 :- p) :* (y - w*b))) :/ (1 :+ w*(a :- 1))
		tmpT = (p' * tmpy) / sum(p) - ((1 :- p)' * tmpy) / sum(1 :- p)
		res = res + (abs(tmpT) >= abs(tobs))							      
		j++
	}
	return(res/j)
}

real scalar fisher_sim(y, w, real scalar nunids, real scalar ntrat, real scalar tobs, real scalar a, real scalar b, real scalar sim){
	real scalar i, nsel, res
	p = J(nunids, 1,0)
	res = 0
	
	for (i=1; i <= sim; ++i){
		nsel = 0
		for(j=1; j<=nunids; j++){
			p[j] = (runiform(1,1) <= ((ntrat - nsel) / (nunids - j)))
			nsel = nsel + p[j]
		}

	    tmpy = ((p :* (a*y + b*(1 :- w))) + ((1 :- p) :* (y - w*b))) :/ (1 :+ w*(a :- 1))
		tmpT = (p' * tmpy) / sum(p) - ((1 :- p)' * tmpy) / sum(1 :- p)
		res = res + (abs(tmpT) >= abs(tobs))
	}
	
	return(res/sim)
}

void fishertst(string scalar varlist, string scalar touse, real scalar a, real scalar b, real scalar sim){
	tkvlist = tokens(varlist)
	y = st_data(., tkvlist[1], touse)
	w = st_data(., tkvlist[2], touse)

	ntrat = sum(w)
	nunids = rows(w)

	tobs = ((w' * y) / ntrat) - (((1 :- w)' * y) / (nunids - ntrat))

	if (any(ceil(w) :!= w) || min(w) != 0 || max(w) != 1)
		_error(3300)

	st_numscalar("e(tfisher)", tobs)
	if (sim > 0) {
		p = fisher_sim(y, w, nunids, ntrat, tobs, a, b, sim)
		st_numscalar("e(pfisher)", p)
		st_numscalar("e(se_pfisher)", sqrt(p*(1 - p)/sim))	
	} else {
		st_numscalar("e(pfisher)", fisher_ext(y, w, nunids, ntrat, tobs, a, b))
	}
}
end mata
