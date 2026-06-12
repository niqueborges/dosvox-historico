##########################################################################################
#
#		LianeVoice.py
#
#		Interface para a voz Liane
#
#		Projeto: 	SonoraMat
#		Data: 		16.04.2018
#		Alterações:
#
##########################################################################################

from time		import sleep
from ctypes		import *

def cvt(s): return s.encode("latin_1")

##########################################################################################
#					Classe LianeVoice
##########################################################################################

class LianeVoice:

##########################################################################################
#			Métodos visíveis externamente
##########################################################################################

#	Construtor
	def __init__(self):
		self.__rate   = 60
		self.__pitch  = 50
		self.__volume = 80

		path = "C:\\winvox\\Lianetts\\"

		self.__dll = windll.LoadLibrary (path + "lianelib.dll")

		self.__dll.lianeTTS_open (cvt (path + "br4"),\
								  cvt (path + "portug.nrl"),\
								  cvt (path + "portug.exc"),\
								  cvt (path + "portug.abr"),\
								  cvt (path + "portug.pro"),\
								  cvt (path + "portug.dfn"))

		self.__dll.lianeTTS_config (self.__rate, self.__pitch)

#	Obtém o número de vozes
	def getVoiceCount (self):
		return 1

#	Obtém o nome, dado o índice da voz
	def getVoiceName (self, voice):
		return "DosVox Liane Desktop - Português (Brasil)"

#	Obtém/Estabelece o número da voz corrente
	@property
	def voice (self):
		return 1

	@voice.setter
	def voice (self, index):
		pass

#	Obtém/Estabelece o volume (de 0 a 100)
	@property
	def volume (self):
		return self.__volume

	@volume.setter
	def volume (self, value):
		if value < 0:
			value = 0
		elif value > 100:
			value = 100

		self.__volume = value

#	Obtém/Estabelece a altura (de 0 a 100)
	@property
	def pitch (self):
		return self.__pitch

	@pitch.setter
	def pitch (self, value):
		if value < 0:
			value = 0
		elif value > 100:
			value = 100

		self.__pitch = value
		self.__dll.lianeTTS_config (self.__rate, self.__pitch)

#	Obtém/Estabelece a velocidade (de 0 a 100)
	@property
	def rate (self):
		return  self.__rate

	@rate.setter
	def rate (self, value):
		if value < 0:
			value = 0
		elif value > 100:
			value = 100

		self.__rate = value
		self.__dll.lianeTTS_config (self.__rate, self.__pitch)

#	Fala um texto
	def speak (self, text):
		self.__dll.lianeTTS_speak (cvt (text))
		sleep (0.1)
		self.__dll.lianeTTS_wait()

#	Para de falar
	def cancel (self):
		self.__dll.lianeTTS_stop()

#	Pausa a fala
	def pause (self, switch):
		if switch:
			self.__dll.lianeTTS_stop()

#	Retoma a fala
	def resume (self, text):
		pass

#   Para de falar e fecha o sintetizador
	def terminate (self):
		self.__dll.lianeTTS_close()

##########################################################################################
#			Teste do Módulo
##########################################################################################

if __name__ == "__main__":
	v = LianeVoice ()

	v.speak ("Árvores que dão frutos")
	v.speak ("Árvores que dão frutos")
	v.speak ("Árvores que dão frutos")

	print   ("Número de vozes: ", v.getVoiceCount ())
	print   ("Voz atual: ",       v.getVoiceName (v.voice))

	input ("Tecle ENTER para terminar")

	v.terminate()