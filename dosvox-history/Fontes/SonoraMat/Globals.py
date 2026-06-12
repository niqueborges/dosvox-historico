##########################################################################################
#
#		Globals.py
#
#		Definições de constantes globais
#
#		Projeto: 	SonoraMat
#		Data: 		16.04.2018
#		Alterações:	
#
##########################################################################################

##########################################################################################
#					Tipos de Tokens
##########################################################################################

class TK:
	undef	=  0	# indefinido
	eoe		=  1	# fim de expressão

	var		= 10	# variável
	num		= 11	# número
	literal	= 12	# elemento falado literalmente
	decl	= 13	# declaração de literal

	oper	= 20	# operador
	operr	= 21	# operador relacional
	index	= 22	# subscrito (_)
	super	= 23	# superscrito (^, ', '' ou ''')
	sep		= 24	# , ou ;

	left	= 30	# ( [ {
	right	= 31	# ( ] }

	func1	= 40	# função esperando 1 argumento
	func2	= 41	# função esperando 2 argumentos
	funcn	= 42	# função esperando n argumentos
	funcp	= 43	# função posfixa (lida depois do argumento)
	funci	= 44	# função opcionalmente sucedida de _
	funcis	= 45	# função opcionalmente sucedida de _ e ^

	font	= 50	# controle de fonte

##########################################################################################
#					Tipos de Nós da Árvore de Expressão
##########################################################################################

class ET:
	none	=  0	# O nó não contém informação útil (logo, não deveria existir, hahaha)
	literal	=  1	# O nó contém informação a ser traduzida literalmente
	oper	=  2	# O nó contém um operador
	operr	=  3	# O nó contém um operador relacional
	func	=  4	# O nó contém uma função
	funcp	=  5	# O nó contém uma função cujo nome deve ser lido após o argumento
	group	=  6	# O nó contém uma subexpressão agrupada por (), [] ou {}
	matrix	=  7	# O nó contém uma matriz
	line	=  8	# O nó contém um modificador ' (linha)
	font	=  9	# O nó contem um comando para mudança de fonte