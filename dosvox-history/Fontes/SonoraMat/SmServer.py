##########################################################################################
#
#		Server.py
#
#		Servidor SonoraMat Multithreaded
#
#		Projeto: 	SonoraMat
#		Data: 		07.11.2018
#		Alterações:
#
##########################################################################################

import socket, threading
from Translate import FL, Translate

class SonoraMatServer (object):
	def __init__ (self, host, port):
		self.encoding = "latin-1"

		self.host = host
		self.port = port

		self.sock = socket.socket (socket.AF_INET, socket.SOCK_STREAM)
		self.sock.setsockopt (socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

		self.sock.bind ((self.host, self.port))
		self.sock.listen (5)

		while True:
			client, address = self.sock.accept()
			threading.Thread (target = self.listenToClient, args = (client, address)).start()

	def send (self, client, str):
		client.send (str.encode (self.encoding))

	def listenToClient (self, client, address):
		tts  = Translate ("asciimath", "advanced")
		size = 1024
		tid  = str (threading.get_ident())

		while True:
			try:
				data = client.recv (size)

				if data:
					s = str (data.decode (self.encoding)).rstrip ("\n").rstrip ("\r")
					t = tts.translate_text (s)
					print (tid + ": <" + s + "> => <" + t + ">")
					self.send (client, t)
				else:
					raise error (tid + ": Cliente desconectou\n")
			except:
				print (tid + ": Encerrando\n")
				client.close()
				return False

if __name__ == "__main__":
	SM_PORT = 51956
	SonoraMatServer ('', SM_PORT)