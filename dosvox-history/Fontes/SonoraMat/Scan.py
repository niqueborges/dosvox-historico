##########################################################################################
#
#		Scan.py
#
#		Analisador Léxico
#
#		Projeto: 	SonoraMat
#		Data: 		16.04.2018
#		Alterações: 15.08.2018
#
##########################################################################################

from Globals		import *
from SymbolTable	import *

import re

##########################################################################################
#					Classe Token (definição de um elemento léxico)
##########################################################################################

class Token:
#	Construtor

	def __init__ (self, type, val, entry = None):
		self.type  = type
		self.val   = val
		self.entry = entry

##########################################################################################
#					Classe Scanner (o analisador léxico)
##########################################################################################

class Scanner:

##########################################################################################
#			Métodos visíveis externamente
##########################################################################################

#	Construtor
	def __init__ (self, expr):
		self.eoe    = Token (TK.eoe, "<FIM>")		# Token correspondente ao fim da expressão

		self.tokens = self.__gettokens (expr)
		self.toklen = len (self.tokens)
		self.tokidx = 0

#	Obtém o token corrente
	def gettoken (self):
		return self.tokens[self.tokidx] if self.tokidx < self.toklen else self.eoe

#	Avança para o próximo token
	def movetonexttoken (self):
		self.tokidx += 1

#	Percurso da lista de tokens (para depuração apenas)
	def loop (self):
		for t in self.tokens:
			yield t

##########################################################################################
#			Métodos privados
##########################################################################################

	def __parse_declaration (self, text):
		def process_declaration (decl):
			p = decl.find ("=", 0)
			if p < 0: return

			id   = decl[:p].strip()
			text = decl[p+1:].strip()

			if text == "função" or text == "funcao":
				SymbolTable.new (id, TK.funcn, id)
			elif text == "remove":
				SymbolTable.unset (id)
			else:
				SymbolTable.new (id, TK.literal, text)

		for decl in re.split ("[;,]", text):    # text.split (";"):
			process_declaration (decl)

#	Decompõe a expressão em uma lista de tokens
	def __gettokens (self, str):
		TERM		= chr (1)					# terminador
		line    	= str + TERM + TERM			# acrescenta 2 terminadores à linha (ver comentário abaixo)
		current 	= 0							# o primeiro caractere é o corrente
		tokens		= []						# lista de tokens a ser retornada pela função

		c = line[current]

		while True:
			# Pula os separadores
			while c == ' ' or c == '\t':
				current += 1; c = line[current]

			# FIM DA LINHA
			if c == TERM:
				break

			# '\' ou LETRA
			if c == "\\" or c.isalpha():
				val = c
				current += 1; c = line[current]

				while c.isalpha():
					val += c
					current += 1; c = line[current]

				# Trata os 3 casos patológicos: "o.", "o+" e "O/"
				if (val == "o" and (c == '.' or c == '+')) or (val == "O" and c == '/'):
					val += c
					current += 1; c = line[current]	

				v = SymbolTable.get (val)
				if v == None:
					token = Token (TK.var, val)				# É um nome qualquer de variável
				else:
					token = Token (v.token, val, v)			# Está na tabela
			# DÍGITO
			elif c.isdigit():
				val  = ""
				real = False

				while c.isdigit():
					val += c
					current += 1; c = line[current]

				if c == '.':
					real = True
					val += c

					current += 1; c = line[current]
					while c.isdigit():
						val += c
						current += 1; c = line[current]

				if c == 'e' or c == 'E':
					real = True
					val += c

					current += 1; c = line[current]
					if c == '-' or c == '+':
						val += c
						current += 1; c = line[current]

					while c.isdigit():
						val += c
						current += 1; c = line[current]

				token = Token (TK.num, val)
			# :: (declarações)
			elif c == ":" and line[current + 1] == c:
				val = ""
				current += 2; c = line[current]

				while c != TERM and (c != ":" or line[current + 1] != c):
					val += c
					current += 1; c = line[current]

				if c != TERM:
					current += 2; c = line[current]

				self.__parse_declaration (val)
				token = None								# Nada é gerado
			# OUTROS CARACTERES
			else:
				# os 2 terminadores acrescentados ao final de "line" garantem que o código seguinte
				# não provocará violação na indexação
				val  = c + line[current + 1] + line[current + 2]
				size = 3

				while size > 0:
					if SymbolTable.get (val) != None:
						break
					val = val[:-1]							# remove o último caractere de val
					size -= 1

				if size == 0:
					token = Token (TK.undef, c); size = 1
				else:
					v = SymbolTable.get (val)				# Se chega aqui, está certamente na tabela
					token = Token (v.token, val, v)

				current += size; c = line[current]

			if token != None: tokens.append (token)

		return tokens

##########################################################################################
#			Teste do Módulo
##########################################################################################

if __name__ == "__main__":
	toknames = {
		TK.undef:	"undef",
		TK.eoe:		"end",
		TK.var:		"var",
		TK.num:		"num",
		TK.literal:	"literal",
		TK.oper:	"oper",
		TK.operr:	"operr",
		TK.index:	"index",
		TK.super:	"super",
		TK.sep:		"sep",
		TK.left:	"left",
		TK.right:	"right",
		TK.func1:	"func1",
		TK.func2:	"func2",
		TK.funcn:	"funcn",
		TK.funcp:	"funcp",
		TK.funci:	"funci",
		TK.funcis:	"funcis",
		TK.font:	"font"
	}

	sc = Scanner ("a + b - sqrt(x * y)")

	print ("\n".join ([str (t.val) + " " + toknames[t.type] + (" <" + t.entry.text + ">" if t.entry != None else "") for t in sc.loop()]))
