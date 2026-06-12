##########################################################################################
#
#		MathReader.py
#
#		Teste do Leitor de Expressões Matemáticas
#
#		Projeto: 	SonoraMat
#		Data: 		16.04.2018
#		Alterações:	27.05.2018, 20.06.2018, 20.08.2018
#
##########################################################################################

from Translate import FL, Translate

import os, sys
import tkinter as tk
from tkinter.filedialog import askopenfilename
from pathlib import Path

##########################################################################################
#					Classe MathReader
##########################################################################################

class MathReader (tk.Tk):
	examples =  [
			"1/3 (2/5 + 3/4)",		# *
			"a * (b + c) - d",		# *
			"x_i = 2",
			"a^2 = b^2 + c^2",
			"a^0 = 1",
			"(x + y)^2 = x^2 + 2xy + y^2",		# *
			"sin x + cos x = 0",
			"sin^2 (log (x))",
			"sin^2 (x) + cos^2 (x) = 1",
			"hat (a+b) = dot a + sqrt (b)",
			"gcd^2 (a, b, c, d, e) = min (x, y)",
			"a^x*a^y = a^(x+y)",
			"a uu b = a + b - a nn b",
			"ln(t) = int_1^t (1/x)dx",
			"::f=funcao::f'(x) = lim_(Delta x -> 0) frac(f(x + Delta x) - f(x))(Delta x)",		# *
			"::f=funcao::f''(x) = 0",		# *
			"::f=funcao,g=funcao::f_1(x+y) = g_2(x-y)",		# *
			"::f=funcao::int_(-oo)^(+oo) f(x)dx",		# *
			"::f=funcao::int_S f(x)dx",		# *
			"log 3^2 = 2 * log 3",
			"frac(-b +- sqrt (b^2 - 4ac))(2a)",
			"[[a,b], [c,d]]",		# *
			"::Rot=funcao:: Rot(theta) = [[cos theta, -sin theta], [sin theta, cos theta]]",		# *
			"[[sqrt 2/2, -sqrt 2/2], [sqrt 2/2, sqrt 2/2]]",		# *
			"[[a_1, a_2, cdots, a_n], [b_1, b_2, cdots, b_n]]",		# *
			"::f=funcao:: f(x) = g(x)"
	];

##########################################################################################
#	Métodos visíveis externamente
##########################################################################################

#	Construtor
	def __init__ (self, parent):
		self.get_all_voices()

		tk.Tk.__init__ (self, parent)
		self.parent = parent
		self.gui ()

		self.set_voice (6)
		self.fluencySlide.set (1)
		self.tts = Translate ("asciimath", "advanced")

#	Obtém as vozes disponíveis
	def get_all_voices (self):
		self.voices = []

#		Procura os drivers dos sintetizadores (estão nos arquivos nomeados *Voice.py)
		for name in os.listdir (os.path.dirname (__file__) or "."):
			if name.endswith ("Voice.py"):
				name = os.path.splitext (name)[0]					# Pressuposto: os nomes do arquivo e da classe coincidem

				if name not in sys.modules:
					try:
						module  = __import__ (name)					# carrega dinamicamente o sintetizador
						synth   = getattr (module, name)()			# executa o construtor
						nvoices = synth.getVoiceCount()				# obtém o número de vozes

						for i in range (1, nvoices + 1):			# coleta as diversas vozes do sintetizador
							self.voices.append ((synth, i, synth.getVoiceName (i)))
					except:
						print ("Erro ao importar o módulo " + name)

#	Estabelece a voz corrente, dado o índice
	def set_voice (self, index):
		if 0 <= index < len (self.voices):
			self.voice_index = index
			(synth, voice, voice_name) = self.voices[index]

			self.synth = synth
			self.synth.voice = voice

			self.volumeSlide.set (self.synth.volume)
			self.rateSlide.set   (self.synth.rate)
			self.pitchSlide.set  (self.synth.pitch)

			self.voicelabel["text"] = "Voz: " + voice_name

#	Cria e posiciona os componentes gráficos
	def gui (self):
#		Criação
		self.menubar = tk.Menu()
		self.config (menu=self.menubar)

		filemenu = tk.Menu (self.menubar, tearoff=0)
		filemenu.add_command (label="Abrir", command=self.OpenFile)
		filemenu.add_command (label="Fim",   command=self.OnEndButtonClick)

		voicemenu = tk.Menu (self.menubar, tearoff=0)

		for i, (synth, voice_number, voice_name) in enumerate (self.voices):
			def call_set_voice(index): return lambda: self.set_voice(index)
			voicemenu.add_command (label=voice_name, command=call_set_voice(i))

		exprmenu = tk.Menu (self.menubar, tearoff=0)

		for e in self.examples:
			def call_set_expr(exp): return lambda: self.OnTextMenuSelect(exp)
			exprmenu.add_command (label=e, command=call_set_expr(e))

		self.menubar.add_cascade (label="Arquivo", menu=filemenu)
		self.menubar.add_cascade (label="Exemplo", menu=exprmenu)
		self.menubar.add_cascade (label="Voz",     menu=voicemenu)

		self.voicelabel = tk.Label (self, text="")

		self.speakButton = tk.Button (self, text="FALAR",  command=self.OnSpeakButtonClick)
		self.clearButton = tk.Button (self, text="LIMPAR", command=self.OnClearButtonClick)

		self.volumeSlide  = tk.Scale (self, label="Volume: ",       from_=0,      to=100,         orient=tk.HORIZONTAL, command=self.OnVolumeSlideClick)
		self.rateSlide    = tk.Scale (self, label="Velocidade: ",   from_=0,      to=100,         orient=tk.HORIZONTAL, command=self.OnRateSlideClick)
		self.pitchSlide   = tk.Scale (self, label="Altura: ",       from_=0,      to=100,         orient=tk.HORIZONTAL, command=self.OnPitchSlideClick)
		self.fluencySlide = tk.Scale (self, label="Textualidade: ", from_=FL.raw, to=FL.advanced, orient=tk.HORIZONTAL, command=self.OnFluencySlideClick)

		self.textarea = tk.Text (self, height=20, width=80)
		scrollbar = tk.Scrollbar (self)

		scrollbar.config (command=self.textarea.yview)
		self.textarea.config (yscrollcommand=scrollbar.set)

#		Posicionamento
		self.grid ()

		self.textarea.grid (column=0, row=0, padx=4, pady=4, columnspan=4, sticky='W')

		self.speakButton.grid (column=1, row=3, pady=8, sticky='WE')
		self.clearButton.grid (column=2, row=3, pady=8, sticky='WE')

		self.volumeSlide.grid  (column=0, row=4)
		self.rateSlide.grid    (column=1, row=4)
		self.pitchSlide.grid   (column=2, row=4)
		self.fluencySlide.grid (column=3, row=4)

		self.voicelabel.grid (column=0, row=5, columnspan=5, sticky='W')

		self.resizable (False, False)
		self.update ()
		self.geometry (self.geometry ())

#	Aciona o sintetizador corrente
	def speak (self, text):
		self.str = self.tts.translate_text (text)
		self.synth.speak (self.str)

#	Obtém de um arquivo o texto a ser lido
	def OpenFile (self):
		try:
			name  = askopenfilename\
					(
						initialdir = os.path.abspath ( __file__ ),
						filetypes  = (("Text File", "*.txt"), ("All Files", "*.*")),
						title      = "Escolha o arquivo"
					)

			with open (name, "r") as fd:
				text = fd.read()
		except:
			text = "Arquivo inexistente"

		self.textarea.delete ("1.0", tk.END)
		self.textarea.insert (tk.END, text)

#	Processa a seleção do texto a ser lido
	def OnTextMenuSelect (self, value):
		self.textarea.delete ("1.0", tk.END)
		self.textarea.insert (tk.END, "`" + value + "`")

#	Processa o click no botão FALAR
	def OnSpeakButtonClick (self):
		print (self.textarea.get ("1.0", tk.END))
		self.speak (self.textarea.get ("1.0", tk.END))

#	Processa o click no botão LIMPAR
	def OnClearButtonClick (self):
		self.textarea.delete ("1.0", tk.END)

#	Processa o click no botão FIM
	def OnEndButtonClick (self):
		exit ()

#	Processa o ajuste de volume
	def OnFluencySlideClick (self, *args):
		self.tts.set_fluency (["raw", "basic", "advanced"][self.fluencySlide.get()])

#	Processa o ajuste de volume
	def OnVolumeSlideClick (self, *args):
		self.synth.volume = self.volumeSlide.get()
        
#	Processa o ajuste de velocidade
	def OnRateSlideClick (self, *args):
		self.synth.rate = self.rateSlide.get()
        
#	Processa o ajuste de altura
	def OnPitchSlideClick (self, *args):
		self.synth.pitch = self.pitchSlide.get()

##########################################################################################
#	Teste do Módulo
##########################################################################################

if __name__ == "__main__":
	app = MathReader (None)
	app.title ("Leitor de Expressões Matemáticas")
	app.mainloop ()