##########################################################################################
#
#		SymbolTable.py
#
#		Tabela de Símbolos
#
#		Projeto: 	SonoraMat
#		Data: 		16.04.2018
#		Alterações:	15.08.2018
#
##########################################################################################

from Globals	import *

##########################################################################################
#			Classe SymbolTableEntry (definição da entrada da tabela de símbolos)
##########################################################################################

class SymbolTableEntry:
#	Construtor
	def __init__ (self, token, text, latex = ""):
		self.token = token
		self.text  = text
		self.latex = latex

##########################################################################################
#			Classe SymbolTable (definição da tabela de símbolos)
##########################################################################################

class SymbolTable:

##########################################################################################
#			Métodos visíveis externamente
##########################################################################################

#	Inicialização
	@staticmethod
	def latex ():
		latexsymboltable = {}

		for t in SymbolTable.__symboltable:
			e = SymbolTable.__symboltable[t]
			latexsymboltable[e.latex] = e

		SymbolTable.__symboltable = latexsymboltable

#	Obtém a entrada referente a uma chave
	@staticmethod
	def get (key):
		return SymbolTable.__symboltable.get (key)	# retorna None se não encontrar

#	Modifica o texto da entrada referente a uma chave
	@staticmethod
	def set (key, text):
		if SymbolTable.__symboltable.get(key) == None:
			SymbolTable.__symboltable[key] = SymbolTableEntry (TK.literal, text)
		else:
			SymbolTable.__symboltable[key].text = text

#	Remove uma chave da tabela
	@staticmethod
	def unset (key):
		if SymbolTable.__symboltable.get(key) != None:
			del SymbolTable.__symboltable[key]

#	Cria uma nova entrada referente a uma chave
	@staticmethod
	def new (key, token, text):
		if SymbolTable.__symboltable.get(key) == None:
			SymbolTable.__symboltable[key] = SymbolTableEntry (token, text)
		else:
			SymbolTable.__symboltable[key].text = text

#	Acrescenta métodos especiais de tradução em algumas entradas
	@staticmethod
	def add_special_translation_methods (dict):
		for k in dict:
			SymbolTable.__symboltable[k].trans = dict[k]

#	Percurso pela tabela (apenas para depuração)
	@staticmethod
	def loop():
		for k in SymbolTable.__symboltable:
			yield (k, SymbolTable.__symboltable[k])

##########################################################################################
#			Atributo privado
##########################################################################################

#	A tabela de símbolos (invisível externamente)
	__symboltable = {
		"+":			SymbolTableEntry (TK.oper,		"mais",							"+"),
		"-":			SymbolTableEntry (TK.oper,		"menos",						"-"),
		"*":			SymbolTableEntry (TK.oper,		"vezes",						"\\times"),
		"**":			SymbolTableEntry (TK.oper,		"estrela",						"\\ast" ),
		"***":			SymbolTableEntry (TK.oper,		"estrela bela",					"\\star"),
		"/":			SymbolTableEntry (TK.oper,		"dividido por",					"/"),
		"-:":			SymbolTableEntry (TK.oper,		"dividido por",					"\\div" ),
		"mod":			SymbolTableEntry (TK.oper,		"módulo",						"\\mod"),
		"@":			SymbolTableEntry (TK.oper,		"bola",							"\\circ"),
		"o+":			SymbolTableEntry (TK.oper,		"o+",							"\\oplus"),
		"ox":			SymbolTableEntry (TK.oper,		"?",							"\\otimes"),
		"o.":			SymbolTableEntry (TK.oper,		"o.",							"\\odot"),
		"^^":			SymbolTableEntry (TK.oper,		"e",							"\\wedge"),
		"vv":			SymbolTableEntry (TK.oper,		"ou",							"\\vee"),
		"and":			SymbolTableEntry (TK.oper,		"e",							"\\land"),
		"or":			SymbolTableEntry (TK.oper,		"ou",							"\\lor"),
		"not":			SymbolTableEntry (TK.oper,		"não",							"\\neg"),
		"nn":			SymbolTableEntry (TK.oper,		"interseção",					"\\cap"),
		"uu":			SymbolTableEntry (TK.oper,		"união",						"\\cup"),
		"del":			SymbolTableEntry (TK.oper,		"dê ron",						"\\partial"),
		"+-":			SymbolTableEntry (TK.oper,		"mais ou menos",				"\\pm"),
		"-+":			SymbolTableEntry (TK.oper,		"menos ou mais",				"\\mp"),
		"diamond":		SymbolTableEntry (TK.oper,		"losango",						"\\diamond"),
		"square":		SymbolTableEntry (TK.oper,		"quadradinho",					"\\square"),

		"=":			SymbolTableEntry (TK.operr,		"igual a",						"="),
		"!=":			SymbolTableEntry (TK.operr,		"diferente de",					"\\neq"),
		"<":			SymbolTableEntry (TK.operr,		"menor que",					"<"),
		">":			SymbolTableEntry (TK.operr,		"maior que",					">"),
		"<=":			SymbolTableEntry (TK.operr,		"menor ou igual que",			"\\leq"),
		">=":			SymbolTableEntry (TK.operr,		"maior ou igual que",			"\\geq"),
		"-<":			SymbolTableEntry (TK.operr,		"precede",						"\\prec"),
		">-":			SymbolTableEntry (TK.operr,		"sucede",						"\\succ"),
		"in":			SymbolTableEntry (TK.operr,		"pertence a",					"\\in"),
		"!in":			SymbolTableEntry (TK.operr,		"não pertence a",				"\\notin"),
		"sub":			SymbolTableEntry (TK.operr,		"contido em",					"\\subset"),
		"sup":			SymbolTableEntry (TK.operr,		"contém",						"\\supset"),
		"sube":			SymbolTableEntry (TK.operr,		"contido ou igual a",			"\\subseteq"),
		"supe":			SymbolTableEntry (TK.operr,		"contém ou igual a",			"\\supseteq"),
		"-=":			SymbolTableEntry (TK.operr,		"equivalente a",				"\\equiv"),
		"~=":			SymbolTableEntry (TK.operr,		"congruente a",					"\\cong"),
		"~~":			SymbolTableEntry (TK.operr,		"aproximadamente igual a",		"\\approx"),
		"prop":			SymbolTableEntry (TK.operr,		"proporcional a",				"\\propto"),

		",":			SymbolTableEntry (TK.sep,		"vírgula",						","),
		";":			SymbolTableEntry (TK.sep,		"ponto e vírgula",				";"),
		
		"_":			SymbolTableEntry (TK.index,		"índice",						"_"),
		"^":			SymbolTableEntry (TK.super,		"elevado a",					"^"), 
		"'":			SymbolTableEntry (TK.super,		"linha",						"'"),
		"''":			SymbolTableEntry (TK.super,		"duas linhas",					"''"),
		"'''":			SymbolTableEntry (TK.super,		"três linhas",					"'''"),

		"O/":			SymbolTableEntry (TK.literal,	"vazio",						"\\O"),
		"oo":			SymbolTableEntry (TK.literal,	"infinito",						"\\infty"),
		"aleph":		SymbolTableEntry (TK.literal,	"álef",							"\\aleph"),
		"/_":			SymbolTableEntry (TK.literal,	"ângulo",						"\\angle"),
		":.":			SymbolTableEntry (TK.literal,	"portanto",						"\\therefore"),
		"cdots":		SymbolTableEntry (TK.literal,	"êticétera",					"\\cdots"),
		"vdots":		SymbolTableEntry (TK.literal,	"êticétera vertical",			"\\vdots"),
		"ddots":		SymbolTableEntry (TK.literal,	"êticétera diagonal",			"\\ddots"),
		"\\\\":			SymbolTableEntry (TK.literal,	"contrabarra",					"\\backslash"),

		"CC":			SymbolTableEntry (TK.literal,	"complexos",					"\\C"),
		"NN":			SymbolTableEntry (TK.literal,	"naturais",						"\\N"),
		"QQ":			SymbolTableEntry (TK.literal,	"racionais",					"\\Q"),
		"RR":			SymbolTableEntry (TK.literal,	"reais",						"\\R"),
		"ZZ":			SymbolTableEntry (TK.literal,	"inteiros",						"\\Z"),

		"alpha":		SymbolTableEntry (TK.literal,	"alfa",							"\\alpha"),
		"beta":			SymbolTableEntry (TK.literal,	"beta",							"\\beta"),
		"chi":			SymbolTableEntry (TK.literal,	"quí",							"\\chi"),
		"delta":		SymbolTableEntry (TK.literal,	"delta",						"\\delta"),
		"Delta":		SymbolTableEntry (TK.literal,	"delta",						"\\Delta"),
		"epsilon":		SymbolTableEntry (TK.literal,	"épsilon",						"\\epsilon"),
		"varepsilon":	SymbolTableEntry (TK.literal,	"épsilon",						"\\varepsilon"),
		"eta":			SymbolTableEntry (TK.literal,	"êta",							"\\eta"),
		"gamma":		SymbolTableEntry (TK.literal,	"gama",							"\\gamma"),
		"Gamma":		SymbolTableEntry (TK.literal,	"gama",							"\\Gamma"),
		"iota":			SymbolTableEntry (TK.literal,	"ióta",							"\\iota"),
		"kappa":		SymbolTableEntry (TK.literal,	"capa",							"\\kappa"),
		"lambda":		SymbolTableEntry (TK.literal,	"lâmbida",						"\\lambda"),
		"Lambda":		SymbolTableEntry (TK.literal,	"lâmbida",						"\\Lambda"),
		"mu":			SymbolTableEntry (TK.literal,	"mi",							"\\mu"),
		"nu":			SymbolTableEntry (TK.literal,	"ni",							"\\nu"),
		"omega":		SymbolTableEntry (TK.literal,	"ômega",						"\\omega"),
		"Omega":		SymbolTableEntry (TK.literal,	"ômega",						"\\Omega"),
		"phi":			SymbolTableEntry (TK.literal,	"fi",							"\\phi"),
		"Phi":			SymbolTableEntry (TK.literal,	"fi",							"\\Phi"),
		"varphi":		SymbolTableEntry (TK.literal,	"fi",							"\\varphi"),
		"pi":			SymbolTableEntry (TK.literal,	"pi",							"\\pi"),
		"Pi":			SymbolTableEntry (TK.literal,	"pi",							"\\Pi"),
		"psi":			SymbolTableEntry (TK.literal,	"psi",							"\\psi"),
		"Psi":			SymbolTableEntry (TK.literal,	"psi",							"\\Psi"),
		"rho":			SymbolTableEntry (TK.literal,	"rô",							"\\rho"),
		"sigma":		SymbolTableEntry (TK.literal,	"sigma",						"\\sigma"),
		"Sigma":		SymbolTableEntry (TK.literal,	"sigma",						"\\Sigma"),
		"tau":			SymbolTableEntry (TK.literal,	"tau",							"\\tau"),
		"theta":		SymbolTableEntry (TK.literal,	"téta",							"\\theta"),
		"Theta":		SymbolTableEntry (TK.literal,	"téta",							"\\Theta"),
		"vartheta":		SymbolTableEntry (TK.literal,	"téta",							"\\vartheta"),
		"upsilon":		SymbolTableEntry (TK.literal,	"úpsilon",						"\\upsilon"),
		"xi":			SymbolTableEntry (TK.literal,	"csi",							"\\xi"),
		"Xi":			SymbolTableEntry (TK.literal,	"csi",							"\\Xi"),
		"zeta":			SymbolTableEntry (TK.literal,	"zéta",							"\\zeta"),

		"=>":			SymbolTableEntry (TK.literal,	"implica",						"\\implies"),
		"if":			SymbolTableEntry (TK.literal,	"se",							"\\if"),
		"iff":			SymbolTableEntry (TK.literal,	"se e somente se",				"\\iff"),
		"AA":			SymbolTableEntry (TK.literal,	"para todo",					"\\forall"),
		"EE":			SymbolTableEntry (TK.literal,	"existe",						"\\exists"),
		"_|_":			SymbolTableEntry (TK.literal,	"perpendicular a",				"\\perp"),
		"//":			SymbolTableEntry (TK.literal,	"paralelo a",					"\\parallel"),
		"TT":			SymbolTableEntry (TK.literal,	"supremo",						"\\top"),
		"|--":			SymbolTableEntry (TK.literal,	"é consequência lógica de",		"\\vdash"),
		"|==":			SymbolTableEntry (TK.literal,	"é consequência semântica de",	"\\models"),

		"uarr":			SymbolTableEntry (TK.literal,	"seta pra cima",				"\\uparrow"),
		"darr":			SymbolTableEntry (TK.literal,	"seta pra baixo",				"\\downarrow"),
		"rarr":			SymbolTableEntry (TK.literal,	"seta pra direita",				"\\rightarrow"),
		"->":			SymbolTableEntry (TK.literal,	"tende a",						"\\to"),
		"|->":			SymbolTableEntry (TK.literal,	"mapeado em",					"\\mapsto"),
		"larr":			SymbolTableEntry (TK.literal,	"seta pra esquerda",			"\\leftarrow"),
		"harr":			SymbolTableEntry (TK.literal,	"seta dupla",					"\\leftrightarrow"),
		"rArr":			SymbolTableEntry (TK.literal,	"seta gorda pra direita",		"\\Rightarrow"), 
		"lArr":			SymbolTableEntry (TK.literal,	"seta gorda pra esquerda",		"\\Leftarrow"),
		"hArr":			SymbolTableEntry (TK.literal,	"seta gorda dupla",				"\\Leftrightarrow"),

		"(":			SymbolTableEntry (TK.left,		"abre parênteses",				"("),
		")":			SymbolTableEntry (TK.right,		"fécha",						")"),
		"[":			SymbolTableEntry (TK.left,		"abre colchetes",				"["),
		"]":			SymbolTableEntry (TK.right,		"fécha",						"]"),
		"{":			SymbolTableEntry (TK.left,		"abre chaves",					"{"),
		"}":			SymbolTableEntry (TK.right,		"fécha",						"}"),
		"(:":			SymbolTableEntry (TK.left,		"abre aspa angular",			"\\langle"),
		":)":			SymbolTableEntry (TK.right,		"fecha",						"\\rangle"),
		"|_":			SymbolTableEntry (TK.left,		"abre piso",					"\\lfloor"),
		"_|":			SymbolTableEntry (TK.right,		"fécha piso",					"\\rfloor"),
		"|~":			SymbolTableEntry (TK.left,		"abre teto",					"\\lceil"),
		"~|":			SymbolTableEntry (TK.right,		"fécha teto",					"\\rceil"),

		"sin":			SymbolTableEntry (TK.func1,		"seno",							"\\sin"),
		"cos":			SymbolTableEntry (TK.func1,		"cosseno",						"\\cos"),
		"tan":			SymbolTableEntry (TK.func1,		"tangente",						"\\tan"),
		"csc":			SymbolTableEntry (TK.func1,		"cossecante",					"\\csc"),
		"sec":			SymbolTableEntry (TK.func1,		"secante",						"\\sec"),
		"cot":			SymbolTableEntry (TK.func1,		"cotangente",					"\\cot"),
		"sinh":			SymbolTableEntry (TK.func1,		"seno hiperbólico",				"\\sinh"),
		"cosh":			SymbolTableEntry (TK.func1,		"cosseno hiperbólico",			"\\cosh"),
		"tanh":			SymbolTableEntry (TK.func1,		"tangente hiperbólica",			"\\tanh"),
		"log":			SymbolTableEntry (TK.func1,		"logaritmo",					"\\log"),
		"ln":			SymbolTableEntry (TK.func1,		"logaritmo natural",			"\\ln"),
		"det":			SymbolTableEntry (TK.func1,		"determinante",					"\\det"),
		"dim":			SymbolTableEntry (TK.func1,		"dimensão",						"\\dim"),
		"sqrt":			SymbolTableEntry (TK.func1,		"raiz quadrada",				"\\sqrt"),
		"grad":			SymbolTableEntry (TK.func1,		"gradiente",					"\\nabla"),

		"frac":			SymbolTableEntry (TK.func2,		"divisão",						"\\frac"),
		"root":			SymbolTableEntry (TK.func2,		"raiz",							"\\root"),
		"stackrel":		SymbolTableEntry (TK.func2,		""								"\\stackrel"),

		"gcd":			SymbolTableEntry (TK.funcn,		"máximo divisor comum",			"\\gcd"),
		"lcm":			SymbolTableEntry (TK.funcn,		"mínimo múltiplo comum",		"\\lcm"),
		"min":			SymbolTableEntry (TK.funcn,		"mínimo",						"\\min"),
		"max":			SymbolTableEntry (TK.funcn,		"máximo",						"\\max"),

		"hat":			SymbolTableEntry (TK.funcp,		"chapéu",						"\\hat"),
		"bar":			SymbolTableEntry (TK.funcp,		"barra",						"\\bar"),
		"ul":			SymbolTableEntry (TK.funcp,		"barra embaixo",				"\\ul"), 
		"vec":			SymbolTableEntry (TK.funcp,		"seta",							"\\vec"),
		"dot":			SymbolTableEntry (TK.funcp,		"ponto",						"\\dot"),
		"ddot":			SymbolTableEntry (TK.funcp,		"ponto ponto",					"\\ddot"),

		"lim":			SymbolTableEntry (TK.funci,		"limite",						"\\lim"),
		"oint":			SymbolTableEntry (TK.funci,		"integral fechada",				"\\oint"),

		"int":			SymbolTableEntry (TK.funcis,	"integral",						"\\int"),
		"sum":			SymbolTableEntry (TK.funcis,	"somatório",					"\\sum"),
		"prod":			SymbolTableEntry (TK.funcis,	"produtório",					"\\prod"),
		"^^^":			SymbolTableEntry (TK.funcis,	"conjuntório",					"\\bigwedge"),
		"vvv":			SymbolTableEntry (TK.funcis,	"disjuntório",					"\\bigvee"),
		"uuu":			SymbolTableEntry (TK.funcis,	"união",						"\\bigcup"),
		"nnn":			SymbolTableEntry (TK.funcis,	"interseção",					"\\bigcap"), 

		"bb":			SymbolTableEntry (TK.font,		"",								"\\mathbb"),    
		"bbb":			SymbolTableEntry (TK.font,		"",								"\\mathbbm"),   
		"cc":			SymbolTableEntry (TK.font,		"",								"\\mathscr"),   
		"tt":			SymbolTableEntry (TK.font,		"",								"\\mathrm"),    
		"fr":			SymbolTableEntry (TK.font,		"",								"\\mathfrak"),  
		"sf":			SymbolTableEntry (TK.font,		"",								"\\mathnormal")
	}

##########################################################################################
#			Teste do Módulo
##########################################################################################

if __name__ == "__main__":
	print ("\n".join(["(" + s + ", " + t.latex + ") => " + t.text for (s, t) in SymbolTable.loop()]))