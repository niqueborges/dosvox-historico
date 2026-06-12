##########################################################################################
#
#		Translate.py
#
#		Traduz textos e expressões para cadeias (faláveis) de caracteres
#
#		Projeto: 	SonoraMat
#		Data: 		16.04.2018
#		Alterações:	27.05.2018, 20.06.2018, 08.08.2018, 29.08.2018
#
##########################################################################################

from Globals		import *
from SymbolTable	import *
from Parse			import *

import re

##########################################################################################
#					Classe FL (controle de fluência)
##########################################################################################

class FL:
	raw		 = 0		# o modo obtuso: lê tudo como está, sem processamento
	basic	 = 1		# o modo básico
	advanced = 2		# o modo avançado

##########################################################################################
#					Classe Translate
##########################################################################################

class Translate:

##########################################################################################
#			Métodos visíveis externamente
##########################################################################################

#	Construtor
	def __init__ (self, language="asciimath", fluency = "raw"):
		self.language  = language.lower()
		self.delimiter = "$" if self.language == "latex" else "`"

		self.set_fluency (fluency)
		self.__add_special_translation_methods()

	def set_fluency (self, fluency):
		map	= { "raw": FL.raw, "basic": FL.basic, "advanced": FL.advanced }
		fluency = fluency.lower()
		self.fluency = map[fluency] if fluency in map else FL.basic

#	Obtém a cadeia correspondente à leitura da expressão
	def translate_expression (self, expr):
		expr = Expr (expr).parse()

		if self.fluency > FL.raw:
			expr = self.__search_for_fractions (expr)

		str = self.__trans_expr (expr, 0)

		print (str)

		str = re.sub (r"\s+de\s*([,;:]*\s*)*o ", "do", str)
		str = re.sub (r"\s+de\s*([,;:]*\s*)*a ", "da", str)

		return str

#	Obtém a cadeia correspondente à leitura do texto
	def translate_text (self, text):
		delimiter = self.delimiter
		start     = 0

		p = text.find (delimiter, start)

		if p < 0:											# a cadeia não contém fórmula
			return text

		size  = len (delimiter)
		tsize = len (text)
		ret   = []

		while p >= 0:
			ret.append (text[start:p])

			start = p + size
			p = text.find (delimiter, start)

			if p >= 0:
				ret.append (self.translate_expression (text[start:p]))
				start = p + size
			else:
				ret.append (delimiter)
				start += size

			p = text.find (delimiter, start)

		if start < tsize - 1:
			ret.append (text[start:])

		return "".join (ret)

##########################################################################################
#			Métodos privados
##########################################################################################

#	Instala funções especiais de tradução para certos símbolos
	def __add_special_translation_methods (self):
		if self.language == "latex":
			SymbolTable.latex()

			changes = {
				"\\frac":	  self.__trans_frac,
				"\\root":	  self.__trans_root,
				"\\lim":	  self.__trans_limit,
				"\\int":	  self.__trans_integral,
				"\\oint":	  self.__trans_integral,
				"\\sum":	  self.__trans_ory,
				"\\prod":	  self.__trans_ory,
				"\\bigwedge": self.__trans_ory,
				"\\bigvee":	  self.__trans_ory,
				"\\bigcup":	  self.__trans_ory,
				"\\bigcap":	  self.__trans_ory
			}
		else:
			changes = {
				"frac":		  self.__trans_frac,
				"root":		  self.__trans_root,
				"lim":		  self.__trans_limit,
				"int":		  self.__trans_integral,
				"oint":		  self.__trans_integral,
				"sum":		  self.__trans_ory,
				"prod":		  self.__trans_ory,
				"^^^":		  self.__trans_ory,
				"vvv":		  self.__trans_ory,
				"uuu":		  self.__trans_ory,
				"nnn":		  self.__trans_ory 
			}

		SymbolTable.add_special_translation_methods (changes)

#	Otimiza a leitura de frações
	def __search_for_fractions (self, expr):
		if expr == None or isinstance (expr, ExprNode):
			return expr

		nexpr = []
		lexpr = len (expr)

		i = 0
		while i < lexpr:
			e = expr[i]

			if isinstance (e, ExprNode):
				e.arg   = self.__search_for_fractions (e.arg)
				e.index = self.__search_for_fractions (e.index)
				e.super = self.__search_for_fractions (e.super)

				if 0 < i < lexpr - 1 and e.type == ET.oper and e.token.val == "/":
					l = expr[i - 1]

					if l.type == ET.literal and l.token.type == TK.num:
						r = expr[i + 1]
						if r.type == ET.literal and r.token.type == TK.num:
							token = Token (TK.func2, "frac", SymbolTable.get ("frac"))
							e = ExprNode (ET.func, token, [l, r], None, None)

							if i < lexpr - 2:
								f = expr[i + 2]
								if f.type != ET.oper and f.type != ET.operr:
									e.functional = True

							nexpr.pop()
							i += 1
			else:
				e = self.__search_for_fractions (e)

			nexpr.append (e)
			i += 1

		return nexpr

#	Traduz expoentes
	def __trans_exponent (self, e, level):
		t = []

		if (isinstance (e, ExprNode)):
			if e.type == ET.line:
				t.append (e.token.entry.text)
			elif e.token.type == TK.num:
				n = int (e.token.val)
				if 2 <= n <= 10:
					t.append ("ao" if 2 <= n <= 3 else "à")
					t.append (["quadrado", "cubo", "quarta", "quinta", "sexta", "sétima", "oitava", "nona", "décima"][n - 2])

		if len(t) == 0:
			t.append ("elevado a")
			t.append (self.__trans_expr (e, level + 1))

		return " ".join(t)

#	Traduz subscritos e sobrescritos
	def __trans_index_super (self, e, level):
		t = []

		if e.index != None:
			t.append ("índice")
			t.append (self.__trans_expr (e.index, level + 1))

		if e.super != None:
			t.append (self.__trans_exponent (e.super, level + 1))

		return " ".join(t)

	def __trans_none (self, e, level):
		return ""

#	Traduz elementos literalmente
	def __trans_literal (self, e, level):
		if e.token.entry == None:
			s = e.token.val
		else:
			s = e.token.entry.text

		map = {"a": "áh", "b": "bê", "c": "cê", "d": "dêe", "e": "éh", "f": "éfe", "g": "gê",
				"h": "agá", "i": "íh", "j": "jóta", "k": "cá", "l": "éle", "m": "ême", "n": "êne",
				"o": "óh", "p": "pê", "q": "quê", "r": "érre", "s": "ésse", "t": "tê",
				"u": "úh", "v": "vê", "w": "dábliu", "x": "x", "y": "ípsilon", "z": "zê" }

		ss = ""
		for c in s:
			if map.get (c):
				ss = ss + " " + map[c] + " "
			else:
				ss = ss + " " + c

		t = [ss]

		s = self.__trans_index_super (e, level + 1)
		if s != "": t.append (s)

		return " ".join(t)

#	Traduz operadores
	def __trans_oper (self, e, level):
		if level == 0:
			return ", " + e.token.entry.text + ", "
		else:
			return e.token.entry.text

#	Traduz operadores relacionais
	def __trans_operr (self, e, level):
		if level == 0:
			return "; " + e.token.entry.text
		else:
			return e.token.entry.text

#	Traduz funções
	def __trans_func (self, e, level):
		if hasattr (e.token.entry, "trans"):
			return e.token.entry.trans (e, level + 1)

		t = [e.token.entry.text]

		s = self.__trans_index_super (e, level + 1)
		if s != "": t.append (s)

		t.append ("de")
		t.append (self.__trans_expr (e.arg, level + 1))
		t.append (",")

		return " ".join(t)

#	Traduz funções posfixas
	def __trans_funcp (self, e, level):
		t = [self.__trans_expr (e.arg, level + 1)]
		t.append (e.token.entry.text)

		s = self.__trans_index_super (e, level + 1)
		if s != "": t.append (s)

		return " ".join(t)

#	Traduz subexpressões
	def __trans_group (self, e, level):
		start = ", abre parêntese"
		end = ", fécha, "

		if self.fluency == FL.advanced:
			if not isinstance (e.arg, ExprNode) and len(e.arg) == 3:
				f = e.arg[1]
				if isinstance (f, ExprNode) and f.type == ET.oper:
					map = { "+": "a soma", "-": "a diferença", "*": "o produto", "/": "o quociente" }
					if map.get(f.token.val) != None:
						start = map[f.token.val]
						end = ";"
		elif self.fluency > FL.raw:
			start = ", a expressão"
			end = ";"

		t = [start]
		t.append (self.__trans_expr (e.arg, level + 1))
		t.append (end)

		s = self.__trans_index_super (e, level + 1)

		if s != "":
			t.append (s)

		return " ".join(t)

	def __trans_seq (self, seq, level):
		t = []

		for el in seq:
			t.append (self.__trans_expr (el, level + 1) + "; ")

		return " ".join(t)

#	Traduz matrizes
	def __trans_matrix (self, e, level):
		t = ["Matriz:"]

		lines = e.arg
		i = 1

		for line in lines:
			t.append ("Linha " + str (i) + ": ")
			t.append (self.__trans_seq (line, level + 1))
			i += 1

		t.append ("Fim da matriz")

		return " ".join(t)

#	Traduz comandos para mudança de fonte
	def __trans_font (self, e, level):
		return self.__trans_expr (e.arg, level)

#	Traduz expressões fracionárias
	def __trans_frac (self, e, level):
		num = e.arg[0]
		den = e.arg[1]
		
		if isinstance (num, ExprNode) and isinstance (den, ExprNode) and num.type == ET.literal and den.type == ET.literal and num.token.type == TK.num and den.token.type == TK.num:
			t = [num.token.val]

			n = int (num.token.val)
			d = int (den.token.val)

			if 1 < d <= 10:
				w = ["meio", "terço", "quarto", "quinto", "sexto", "sétimo", "oitavo", "nono", "décimo"][d - 2]
				t.append (w if n == 1 else w + "s")
			else:
				t.append (den.token.val)
				t.append ("avos")

			if hasattr (e, "functional") and e.functional:
				t.append ("de")
		else:
			t = ["divisão,"]
			t.append ("em cima:")
			t.append (self.__trans_expr (num, level + 1))
			t.append (", embaixo:")
			t.append (self.__trans_expr (den, level + 1))
			t.append (";")

			s = self.__trans_index_super (e, level + 1)
			if s != "": t.append (s)

		return " ".join(t)

#	Traduz integrais
	def __trans_integral (self, e, level):
		t = [e.token.entry.text]

		if e.index != None:
			if e.super != None:
				t.append ("de")
				t.append (self.__trans_expr (e.index, level + 1))
				t.append ("a")
				t.append (self.__trans_expr (e.super, level + 1))
			else:
				t.append ("sobre")
				t.append (self.__trans_expr (e.index, level + 1))
			t.append (";")
				
		t.append ("de")
		t.append (self.__trans_expr (e.arg, level + 1))

		return " ".join(t)

#	Traduz raiz
	def __trans_root (self, e, level):
		t = ["raiz"]

		ord = e.arg[0]

		if (isinstance (ord, ExprNode)):
			if ord.token.type == TK.num:
				n = int (ord.token.val)
				if 2 <= n <= 10:
					t.append (["quadrada", "cúbica", "quarta", "quinta", "sexta", "sétima", "oitava", "nona", "décima"][n - 2])
				else:
					t.append ("de ordem")
					t.append (ord.token.val)
		else:
			t.append ("de ordem")
			t.append (self.__trans_expr (ord, level + 1))

		t.append ("de")
		t.append (self.__trans_expr (e.arg[1], level + 1))

		return " ".join(t)

#	Traduz limite
	def __trans_limit (self, e, level):
		t = ["limite"]

		if e.index != None:
			t.append ("quando")
			t.append (self.__trans_expr (e.index, level + 1))

		t.append ("de")
		t.append (self.__trans_expr (e.arg, level + 1))

		return " ".join(t)

#	Traduz "órios" (somatório, produtório, outório, ...)
	def __trans_ory (self, e, level):
		t = [e.token.entry.text]

		if e.index != None:
			s = SymbolTable.get ("=").text
			SymbolTable.set ("=", "variando de")		# Modifica temporariamente o texto do operador "="
			t.append ("para")
			t.append (self.__trans_expr (e.index, level + 1))
			SymbolTable.set ("=", s)					# Restaura o texto do operador "="

		if e.super != None:
			t.append ("até")
			t.append (self.__trans_expr (e.super, level + 1))

		t.append ("de")
		t.append (self.__trans_expr (e.arg, level + 1))

		return " ".join(t)

#	Dicionário de funções específicas (uma para cada tipo de nó)
	__translate_node = {
		ET.none:	__trans_none,
		ET.literal:	__trans_literal,
		ET.oper:	__trans_oper,
		ET.operr:	__trans_operr,
		ET.func:	__trans_func,
		ET.funcp:	__trans_funcp,
		ET.group:	__trans_group,
		ET.matrix:	__trans_matrix,
		ET.line:	__trans_none,
		ET.font:	__trans_font
	}

#	Traduz expressões
	def __trans_expr (self, expr, level):
		if expr == None:
			return ""

		if (isinstance (expr, ExprNode)):
			return self.__translate_node[expr.type](self, expr, level)		# Chama a função específica

		return " ".join([self.__trans_expr (e, level) for e in expr])		# Percorre a lista traduzindo as expressões

##########################################################################################
#			Teste do Módulo
##########################################################################################

if __name__ == "__main__":
	tr = Translate("asciimath", "advanced")
#	print (tr.translate_expression ("lim_(j -> oo)a_j^2 + b - frac(sin^n(x * y))(sqrt 22.2) + root(3)(sum_(i=1)^n a_i) = min(a,b,c)"))
	print (tr.translate_expression ("1/3 (2/5 + 3/4)"))

#	tr = Translate("latex", "advanced")
#	print (tr.translate_expression ("\\lim_{j \\to \\infty}a_j^2 + b - \\frac{\\sin^n(x \\times y)}{\\sqrt 22.2} + \\root{3}{\\sum_{i=1}^n a_i} = \\min(a,b,c)"))
