program define rank, eclass byable(recall) sortpreserve
	version 9
	syntax varlist(min=1 max=1 numeric) [if] [in] , [NORMalizado] generate(string)
	tokenize `varlist'
	marksample touse
	
	generate `generate' = .

	quietly {
		sort `1'
		count if `touse'
		local nunids = r(N)

		egen _niguais = count(`1') if `touse', by(`1')
		gen __nmenores_ou_iguais = _n if `touse'
		egen _nmenores_ou_iguais = max(__nmenores_ou_iguais) if `touse', by(`1')
		
		if ("`normalizado'" == "normalizado") {
			replace `generate' = 0.5 + _nmenores_ou_iguais - 0.5*(_niguais) - 0.5*(`nunids' + 1) if `touse'
		 }
		 else {
			replace `generate' = 0.5 + _nmenores_ou_iguais - 0.5*(_niguais) if `touse'
		 }
		drop _niguais __nmenores_ou_iguais _nmenores_ou_iguais
	}
	
end
