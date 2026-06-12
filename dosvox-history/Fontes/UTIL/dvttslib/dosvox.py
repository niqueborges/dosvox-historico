#synthDrivers/serpro
#Dosvox TTS Driver - July/2007
#By Antonio Borges e Anibal Teles (NCE/UFRJ)
#Copyright (C) 2007 - NCE/UFRJ - Projeto DOSVOX

#A part of NonVisual Desktop Access (NVDA)
#Copyright (C) 2006-2007 NVDA Contributors <http://www.nvda-project.org/>
#This file is covered by the GNU General Public License.
#See the file COPYING for more details.

import os
import baseObject
import debug
from ctypes import *
import threading
import time

class SynthAwake (threading.Thread):

	speed = 0.3
	running = False

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

class SynthDriver(baseObject.autoPropertyObject):

	hasVoice=True
	hasPitch=True
	hasRate=True
	hasVolume=False
	hasVariant=False
	hasInflection=False

	description=_("Dosvox TTS Synthesizer Driver")
	name="dosvox"
	libpath="c:\\winvox\\fontes\\dvttslib\\"

	bib=0
	_rate=70
	_pitch=50
	_volume=100
	_voice=1
	spklist=[]
	lastIndex=None
	awakener=None
	
	def check(self):
		try:
			p=self.libpath
			f=open(p+"dvttslib.dll", "rb")	
			return True
		except:
			return False

	def initialize(self):
		p=self.libpath
		self.bib=windll.LoadLibrary(p+"dvttslib.dll")
		self.bib.dvTTS_open ()
		self.bib.dvTTS_config(70, 50)
		self.bib.dvTTS_speak ("Dosvox TTS")
		self.bib.dvTTS_wait()
		self.bib.dvTTS_speak ("Dosvox TTS")
		self.bib.dvTTS_wait()
		self.bib.dvTTS_speak ("Dosvox TTS")
		self.bib.dvTTS_wait()
		self.pumping = False;
		self.awakener = SynthAwake()
		self.awakener.setCallback(self.pump)
		self.awakener.start()
		return True

	def terminate(self):
		self.awakener.stop()
		self.bib.dvTTS_close()

	def speakText(self,text,wait=False,index=None):
		self.spklist.append(index)
		self.spklist.append(text)
		self.pump()
		self.awakener.fast()
		if wait is False:
			return
		while self.spklist!=[]:
			if not self.pumping:
				self.pump()
			time.sleep(0.1)
		while self.bib.dvTTS_isSpeaking():
			time.sleep(0.1)

	def pump(self):
		self.pumping = True;
		if self.spklist==[]:
			self.awakener.slow()
		elif self.bib.dvTTS_isSpeaking()==0:
			self.lastIndex=self.spklist.pop(0)
			text=self.spklist.pop(0)
			tx=text.encode('utf-8', 'replace')
			self.bib.dvTTS_utfSpeak(tx)
		self.pumping = False;
                
	def pause(self, switch):
		if switch:
			self.cancel()
			
	def _get_lastIndex(self):
		return self.lastIndex
 
	def cancel(self):
		self.spklist = []
		self.bib.dvTTS_stop()

	def _get_voice(self):
		return 1

	def _set_voice(self,value):
		pass

	def _get_voiceCount(self):
		return 1

	def getVoiceName(self,num):
		return "Dosvox TTS"

	def _get_rate(self):
		return self._rate

	def _set_rate(self,value):
		self.bib.dvTTS_config(value, self._pitch)
		self._rate=value

	def _get_pitch(self):
		return self._pitch

	def _set_pitch(self,value):
		self.bib.dvTTS_config(self._rate, value)
		self._pitch=value

	def _get_volume(self):
		return 100

	def _set_volume(self,value):
		pass

	def _get_variant(self):
		return 1

	def _set_variant(self,val):
		pass

	def _get_variantCount(self):
		return 1

	def _get_inflection(self):
		return 0

	def _set_inflection(self,val):
		pass
