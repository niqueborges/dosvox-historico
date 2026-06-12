##########################################################################################
#
#		SAPIVoice.py
#
#		Interface para as vozes SAPI
#
#		Projeto: 	SonoraMat
#		Data: 		16.04.2018
#		Alterações:
#
##########################################################################################

from comtypes.client import CreateObject

##########################################################################################
#					Classe SAPIFlags (indicadores para o método speak)
##########################################################################################

class SAPIFlags:
	SVSFDefault				=  0
	SVSFlagsAsync			=  1
	SVSFPurgeBeforeSpeak	=  2
	SVSFIsFilename			=  4
	SVSFIsXML				=  8
	SVSFIsNotXML			= 16
	SVSFPersistXML			= 32

##########################################################################################
#					Classe SAPIVoice
##########################################################################################

class SAPIVoice:

##########################################################################################
#			Métodos visíveis externamente
##########################################################################################

#	Construtor
	def __init__ (self):
		self.__tts     = CreateObject ('sapi.SPVoice')
		self.__voices  = self.__tts.GetVoices ()
		self.__nvoices = len (self.__voices)

		# Procura alguma voz em português

		voice = 1		# default, se não encontrar

		for i, v in enumerate (self.__voices):
			if "ortug" in v.GetDescription ():
				voice = i + 1
				break

		self.voice = voice
		self.rate  = 60
	
#	Obtém o número de vozes
	def getVoiceCount (self):
		return self.__nvoices

#	Obtém o nome da voz
	def getVoiceName (self, index):
		if 0 < index <= self.__nvoices:
			return self.__voices[index - 1].GetDescription ()
		else:
			return "Voz inexistente"

#	Obtém/Estabelece o número da voz corrente
	@property
	def voice (self):
		return self.__voice

	@voice.setter
	def voice (self, index):
		if index < 1:
			index = 1
		elif index > self.__nvoices:
			index = self.__nvoices

		self.__tts.Voice = self.__voices[index - 1]
		self.__voice = index

#	Obtém/Estabelece o volume (de 0 a 100)
	@property
	def volume (self):
		return self.__tts.volume

	@volume.setter
	def volume (self, value):
		if value < 0:
			value = 0
		elif value > 100:
			value = 100

		self.__tts.Volume = value

#	Obtém/Estabelece a altura (de 0 a 100)
	@property
	def pitch (self):
		return 50

	@pitch.setter
	def pitch (self, value):
		pass

#	Obtém/Estabelece a velocidade (de 0 a 100)
	@property
	def rate (self):
		return (self.__tts.Rate + 10) * 5		# ajusta para a faixa externa (0 a 100)

	@rate.setter
	def rate (self, value):
		if value < 0:
			value = 0
		elif value > 100:
			value = 100

		self.__tts.Rate = value // 5 - 10		# ajusta para a faixa interna (-10 a 10)

#	Fala um texto, com possíveis diretivas XML
	def speak (self, text):
		self.__tts.Speak (text, SAPIFlags.SVSFIsXML|SAPIFlags.SVSFlagsAsync)

#	Cancela a fala
	def cancel (self, text):
		pass

#	Pausa a fala
	def pause (self, text):
		self.__tts.Pause ()

#	Retoma a fala
	def resume (self, text):
		self.__tts.Resume ()

#   Para de falar e fecha o sintetizador
	def terminate (self):
		pass

##########################################################################################
#			Teste do Módulo
##########################################################################################
	
if __name__ == "__main__":
	v = SAPIVoice ()

	v.speak('<pitch middle="5">a mais b<silence msec=\"10\"/><pitch middle="-5">vezes c</pitch></pitch>')
	v.speak('a mais<silence msec=\"10\"/> <pitch middle="5">b vezes c</pitch>')
	v.speak('<spell>a</spell> elevado a <rate speed="4"><spell>n</spell> mais 2</rate>')
	v.speak('<rate speed="4"><spell>a</spell> elevado a <spell>n</spell></rate><silence msec="10"/> mais 2')

	print   ("Número de vozes: ", v.getVoiceCount ())
	print   ("Voz atual: ",       v.getVoiceName (v.voice))

	input ("Tecle ENTER para terminar")

	v.terminate()