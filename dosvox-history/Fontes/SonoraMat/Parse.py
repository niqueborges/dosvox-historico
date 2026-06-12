##########################################################################################
#
#		Parse.py
#
#		Analisador Sintático
#
#		Projeto: 	SonoraMat
#		Data: 		16.04.2018
#		Alterações:	29.08.2018, 07.11.2018
#
##########################################################################################

from Globals		import *
from Scan			import *

##########################################################################################
#					Classe ExprNode (Nó da árvore de expressões)
##########################################################################################

class ExprNode():

##########################################################################################
#			Métodos visíveis externamente
##########################################################################################

#	Construtor
	def __init__ (self, type, token, arg, index, super):
		self.type  = type
		self.token = token
		self.arg   = arg
		self.index = index
		self.super = super

#	Impressão (para depuração apenas)
	def print (self):
		def printarg (arg):
			if arg == None:
				return ""

			if (isinstance (arg, ExprNode)):
				t = [arg.print()]
			else:
				t = [printarg (n) for n in arg]

			return " ".join(t)

		s = []

		if self.type != ET.group:
			s.append (self.token.val)

		if self.type == ET.func:
			if self.index != None: s.append ("_" + printarg (self.index))
			if self.super != None: s.append ("^" + printarg (self.super))
			if self.arg   != None: s.append ("(" + printarg (self.arg) + ")")
		else:
			if self.arg   != None: s.append ("(" + printarg (self.arg) + ")")
			if self.index != None: s.append ("_" + printarg (self.index))
			if self.super != None: s.append ("^" + printarg (self.super))

		return "".join(s)

##########################################################################################
#					Classe Expr
##########################################################################################

class Expr():

##########################################################################################
#			Métodos visíveis externamente
##########################################################################################

#	Construtor
	def __init__ (self, expr):
		self.scanner = Scanner (expr)
		self.match = {"(": ")", "[": "]", "{": "}", ")": "(", "]": "[", "}": "{"}

#	Analisador sintático
	def parse (self):
		return self.__parseExpr (["\n"])

##########################################################################################
#			Métodos privados
##########################################################################################

#	Desfaz um agrupamento
	def __undo_group (self, e):
		return e.arg if e.type == ET.group else e

#	Simplifica a expressão unitária
	def __simplify_expr (self, e):
		return e if len(e) > 1 else e[0]

#	pula
	def __parse_skip (self, t):
		return (ET.none, None, None, None)

#	erro de sintaxe
	def __parse_syntax_error (self, t):
		print (t.val + " inesperado")
		return (ET.none, None, None, None)

#	var, num ou texto
	def __parse_literal (self, t):
		return (ET.literal, None, None, None)

#	operador
	def __parse_oper (self, t):
		return (ET.oper, None, None, None)

#	operador relacional
	def __parse_operr (self, t):
		return (ET.operr, None, None, None)

#	sequência
	def __parse_seq (self, t, match):
		seq = []
		self.scanner.movetonexttoken()

		a = self.__parseExpr([",", match])
		seq.append (self.__simplify_expr (a))

		while self.scanner.gettoken().val == ",":
			self.scanner.movetonexttoken()

			a = self.__parseExpr([",", match])
			seq.append (self.__simplify_expr (a))

		if self.scanner.gettoken().val == match:
			self.scanner.movetonexttoken()
		else:
			print ("Esperava " + match + " (veio " + self.scanner.gettoken().val + ")")

		return seq

#	matriz
	def __parse_matrix (self, t):
		match = self.match[t.val]

		lines = []

		while self.scanner.gettoken().val != match:
			line = self.__parse_seq (t, match)
			lines.append (line)

			if self.scanner.gettoken().val == ",":
				self.scanner.movetonexttoken()

		self.scanner.movetonexttoken()

		return lines

#	(, [ ou {
	def __parse_group (self, t):
		if t.val == self.scanner.gettoken().val:	# [[ ou ((
			return (ET.matrix, self.__parse_matrix (t), None, None)

		m = self.match[t.val]
		arg = self.__parseExpr ([m])
		if len(arg) == 1: arg = arg[0]

		t = self.scanner.gettoken()
		if t.val != m:
			print ("Esperava " + m + " (e não " + t.val + ")")

		self.scanner.movetonexttoken()

		return (ET.group, arg, None, None)

#	), ] ou }
	def __parse_endgroup (self, t):
		print (t.val + " inesperado")
		return (ET.none, None, None, None)

#	F S
	def __parse_func1 (self, t):
		super = None
		t = self.scanner.gettoken()

		if t.type == TK.index:									# trata _
			self.scanner.movetonexttoken()
			index = self.__undo_group (self.__parseSimpleExpr())
			t = self.scanner.gettoken()

		if t.type == TK.super:
			self.scanner.movetonexttoken()
			if t.val[0] == "'":
				super = ExprNode (ET.line, t, None, None, None)
			else:
				super = self.__undo_group (self.__parseSimpleExpr())

		arg = self.__parseSimpleExpr()
		if arg.type == ET.group and isinstance (arg.arg, ExprNode): arg = arg.arg

		return (ET.func, arg, None, super)

#	F S S
	def __parse_func2 (self, t):
		arg = []
		arg.append (self.__undo_group (self.__parseSimpleExpr()))
		arg.append (self.__undo_group (self.__parseSimpleExpr()))

		return (ET.func, arg, None, None)

#	F (S, S, ..., S)
	def __parse_funcn (self, t):
		super = None
		index = None
		arg = []

		t = self.scanner.gettoken()

		if t.type == TK.index:									# trata _
			self.scanner.movetonexttoken()
			index = self.__undo_group (self.__parseSimpleExpr())
			t = self.scanner.gettoken()

		if t.type == TK.super:
			self.scanner.movetonexttoken()
			if t.val[0] == "'":
				super = ExprNode (ET.line, t, None, None, None)
			else:
				super = self.__undo_group (self.__parseSimpleExpr())

		t = self.scanner.gettoken()

		if t.type == TK.left:
			m = self.match[t.val]
			arg = self.__parse_seq (t, m)
			if len(arg) == 1:
				arg = arg[0]
				if isinstance (arg, ExprNode) and arg.type == ET.group: arg = arg.arg

		if not isinstance (arg, ExprNode) and len(arg) == 0:
			return (ET.literal, None, index, super)

		return (ET.func, arg, index, super)

#	F S, com F lido posfixamente
	def __parse_funcp (self, t):
		return (ET.funcp, self.__parseSimpleExpr(), None, None)

#	F_I
	def __parse_funci (self, t):
		t = self.scanner.gettoken()

		if t.type == TK.index:
			self.scanner.movetonexttoken()
			index = self.__undo_group (self.__parseSimpleExpr(False))
		else:
			index = None

		arg = self.__parseSimpleExpr()

		return (ET.func, arg, index, None)

#	F_I_S
	def __parse_funcis (self, t):
		t = self.scanner.gettoken()

		if t.type == TK.index:
			self.scanner.movetonexttoken()
			index = self.__undo_group (self.__parseSimpleExpr(False))
		else:
			index = None

		t = self.scanner.gettoken()

		if t.type == TK.super:
			self.scanner.movetonexttoken()
			super = self.__undo_group (self.__parseSimpleExpr(False))
		else:
			super = None

		arg = self.__parseSimpleExpr()

		return (ET.func, arg, index, super)

#	Font S
	def __parse_font (self, t):
		return (ET.font, self.__parseSimpleExpr(), None, None)

#	Dicionário de funções específicas (uma para cada tipo de token)
	__parse = {
		TK.undef:	__parse_skip,
		TK.eoe:		__parse_skip,
		TK.var:		__parse_literal,
		TK.num:		__parse_literal,
		TK.literal:	__parse_literal,
		TK.oper:	__parse_oper,
		TK.operr:	__parse_operr,
		TK.index:	__parse_syntax_error,
		TK.super:	__parse_syntax_error,
		TK.sep:		__parse_syntax_error,
		TK.left:	__parse_group,
		TK.right:	__parse_endgroup,
		TK.func1:	__parse_func1,
		TK.func2:	__parse_func2,
		TK.funcn:	__parse_funcn,
		TK.funcp:	__parse_funcp,
		TK.funci:	__parse_funci,
		TK.funcis:	__parse_funcis,
		TK.font:	__parse_font
	}

#	Analisa expressões simples
	def __parseSimpleExpr(self, process_index_super = True):
		t = self.scanner.gettoken(); self.scanner.movetonexttoken()

		(type, arg, index, super) = self.__parse[t.type] (self, t)	# chama a função específica, de acordo com o token corrente

		if type != ET.none and process_index_super:
			nt = self.scanner.gettoken()

			if nt.type == TK.index:									# trata _
				self.scanner.movetonexttoken()
				index = self.__undo_group (self.__parseSimpleExpr())
				nt = self.scanner.gettoken()

			if nt.type == TK.super:									# trata ^ e '
				self.scanner.movetonexttoken()
				if nt.val[0] == "'":
					super = ExprNode (ET.line, nt, None, None, None)
				else:
					super = self.__undo_group (self.__parseSimpleExpr())

		return ExprNode (type, t, arg, index, super)				# o retorno é um ExprNode, com as informações coletadas

#	Analisa expressões complexas
	def __parseExpr (self, delim):
		expr = []

		t = self.scanner.gettoken()

		while t.type != TK.eoe and not (t.val in delim):
			expr.append (self.__parseSimpleExpr())
			t = self.scanner.gettoken()

		return expr													# o retorno é uma lista de ExprNode's

##########################################################################################
#			Teste do Módulo
##########################################################################################

if __name__ == "__main__":
	e = Expr ("a_j^(2+i) + b - sin^3(x * y) / sqrt 22.2 + (sum_(i=1)^n a_i)^3 * min(a,b,c)")
	print ("\n".join ([n.print() for n in e.parse()]))