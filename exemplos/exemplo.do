*Exemplo
**********************************************************************************************************************
clear all
sysuse auto

cd "C:\LOCALDOSARQUIVOS"
run "fisher.do"
run "rank.do"

* fisher: Implementa o teste de Fisher (exato e simulado) 
*           syntax fisher depvar vartratamento [if] [in] [, a(1) b(0) sim(0) alpha(0.05)]
*        Des.: Modelo implicito: Y(1) = a.Y(0) + b (Equacao (*)) (valores potenciais)
*                                Y = Y(0) + T . (Y(1) - Y(0))
*                                T = 1, se tratado 
*                                    0, se nao tratado
*         Opcoes:     
*            a - Inclinacao de (*). Valor Padrao: 1
*            b - Intercepto de (*). Valor Padrao: 0
*            sim - Numero de simulacoes para o teste de Fisher Simulado. Se zero, calcula o teste exato. Valor Padrao: 0
*            alpha - Nivel de signficancia para o teste de fisher simulado. Caso sim = 0, este valor e ignorado.
*          
*         Saidas:
*            e(tfisher) - Estatistica de calculada sob T observado
*            e(pfisher) - p-valor do teste de fisher
*            e(se_pfisher) - Erro padrao do p-valor do teste de fisher (para teste o teste simulado de fisher)
	fisher mpg foreign, sim(5000)

* rank: Cria uma variavel de rank 
*           syntax varoriginal [if] [in] , [normalizado] generate(varrank)
*       Des.: Cria uma variavel de rank (varrank) com base na variavel original (varoriginal)
*       Opcoes:     
*           normalizado - Cria variavel de rank normalizada/relativa (centrada em zero)

	rank mpg, generate(mpgrank)
	fisher mpgrank foreign, sim(5000)

