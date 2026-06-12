#Dosvox TTS Driver - Feb/2011
#By Antonio Borges(NCE/UFRJ)
#NVDA support by Cleverson Uliana
#Copyright (C) 1994 - NCE/UFRJ

#synthDrivers/dosvox.py
#A part of NonVisual Desktop Access (NVDA)
#Copyright (C) 2006-2008 NVDA Contributors <http://www.nvda-project.org/>
#This file is covered by the GNU General Public License.
#See the file COPYING for more details.

import synthDriverHandler
from synthDriverHandler import SynthDriver

from ctypes import *
import threading
import time

class SynthAwake (threading.Thread):

	speed = 0.2

	def setCallback(self, callback):
		self.callback = callback
                
	def slow(self):
		self.speed = 0.2

	def fast(self):
		self.speed = 0.1

	def stop(self):
		self.running = False

	def run(self):
		self.running = True
		while self.running:
			self.callback()
			time.sleep (self.speed)


class SynthDriver(synthDriverHandler.SynthDriver):
	""" Dosvox TTS driver.
	"""
	name="dosvox"
	description=_("Dosvox TTS")

	supportedSettings= [
		SynthDriver.RateSetting() ]

	@classmethod
	def check(cls):
		try:
			p="C:\\winvox\\lianetts\\"
			f=open(p+"dosvoxlib.dll", "rb")	
			return True
		except:
			return False

	def __init__(self):
		self._rate = 70
		self.spklist = []

		p="C:\\winvox\\lianetts\\"
		self.bib=windll.LoadLibrary(p+"dosvoxlib.dll")
		self.bib.dosvoxTTS_open()
		self.bib.dosvoxTTS_config(self._rate)
		self.pumping = False;

		self.awakener = SynthAwake()
		self.awakener.setCallback(self.pump)
		self.awakener.start()

	def terminate(self):
		self.awakener.stop()
		self.bib.dosvoxTTS_close()

	def speakText(self, text, index=None):
		self.spklist.append((text,index))
		self.pump()
		self.awakener.fast()

	def pump(self):
		if self.pumping: return
		self.pumping = True;
		if self.spklist==[]:
			self.awakener.slow()
		elif self.bib.dosvoxTTS_isSpeaking()==0:
			(text, self.lastIndex)=self.spklist.pop(0)
			try:			
				tx=text.encode('utf-8', 'replace')
				self.bib.dosvoxTTS_utfSpeak(tx)
			except:
				pass
		self.pumping = False;
                
	def cancel(self):
		self.spklist = []
		self.bib.dosvoxTTS_stop()

	def speakCharacter(self, text, index=None):
		self.bib.dosvoxTTS_soletra(text)
	
	def _getAvailableVoices(self):
		return [synthDriverHandler.VoiceInfo (0, "Dosvox")]

	def _get_rate(self):
		return self._rate

	def _set_rate(self,value):
		self._rate=int(value)
		self.bib.dosvoxTTS_config(self._rate, self._pitch)
