#Liane TTS Driver - Feb/2011
#Created by the Serpro-LianeTTS project
#By Antonio Borges, Anibal Teles (NCE/UFRJ)
#    and the Serpro Accessibility Group
#NVDA support by Cleverson Uliana
#Copyright (C) 2011 - Serpro Brasil and NCE/UFRJ

#synthDrivers/liane.py
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
	""" Liane TTS driver.
	"""
	name="liane"
	description=_("Liane TTS")

	supportedSettings= [
		SynthDriver.PitchSetting(),
		SynthDriver.RateSetting() ]

	@classmethod
	def check(cls):
		try:
			p="C:\\winvox\\Lianetts\\"
			f=open(p+"lianelib.dll", "rb")	
			return True
		except:
			return False

	def __init__(self):
		self._rate = 70
		self._pitch = 50
		self._volume = 80
		self._lastIndex = 0
		self.spklist = []

		p="C:\\winvox\\Lianetts\\"
		self.bib=windll.LoadLibrary(p+"lianelib.dll")
		self.bib.lianeTTS_open (p+"br4",\
					p+"portug.nrl",\
					p+"portug.exc",\
					p+"portug.abr",\
					p+"portug.pro",\
					p+"portug.dfn")
		self.bib.lianeTTS_config(self._rate, self._pitch)
		self.pumping = False;

		self.awakener = SynthAwake()
		self.awakener.setCallback(self.pump)
		self.awakener.start()

	def terminate(self):
		self.awakener.stop()
		self.bib.lianeTTS_close()

	def speakText(self, text, index=None):
		self.spklist.append((text,index))
		self.pump()
		self.awakener.fast()

	def pump(self):
		if self.pumping: return
		self.pumping = True;
		if self.spklist==[]:
			self.awakener.slow()
		elif self.bib.lianeTTS_isSpeaking()==0:
			(text, self.lastIndex)=self.spklist.pop(0)
			try:			
				tx=text.encode('utf-8', 'replace')
				self.bib.lianeTTS_utfSpeak(tx)
			except:
				pass
		self.pumping = False;
                
	def cancel(self):
		self.spklist = []
		self.bib.lianeTTS_stop()

	#def speakCharacter(self, text, index=None):
	#	pass

	def _get_lastIndex(self):
		return self._lastIndex

	def _getAvailableVoices(self):
		return [synthDriverHandler.VoiceInfo (0, "Liane")]

	def _get_rate(self):
		return self._rate

	def _set_rate(self,value):
		self._rate=int(value)
		self.bib.lianeTTS_config(self._rate, self._pitch)

	def _get_pitch(self):
		return self._pitch

	def _set_pitch(self,value):
		self._pitch=int(value)
		self.bib.lianeTTS_config(self._rate, self._pitch)
