import RPi.GPIO as GPIO
import socket
import sys
from time import sleep

# setup motors 
GPIO.setmode(GPIO.BOARD)
 
Motor1A = 16
Motor1B = 18
Motor1E = 22
 
Motor2A = 19
Motor2B = 21
Motor2E = 23
 
GPIO.setup(Motor1A,GPIO.OUT)
GPIO.setup(Motor1B,GPIO.OUT)
GPIO.setup(Motor1E,GPIO.OUT)
 
GPIO.setup(Motor2A,GPIO.OUT)
GPIO.setup(Motor2B,GPIO.OUT)
GPIO.setup(Motor2E,GPIO.OUT)

# setup socket connection to computer
host = '169.254.0.2'
port= 51717

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind((host, port))
s.listen(5)

# create connection and spin motors depending on value
while True:
	conn, address = s.accept()
	
	try:
		while True:
			output = conn.recv(32)
			int_output = int(output.strip())

			print int_output
			
			# go forwards
			if int_output == 1:
				GPIO.output(Motor1A,GPIO.HIGH)
				GPIO.output(Motor1B,GPIO.LOW)
				GPIO.output(Motor1E,GPIO.HIGH)
 
				GPIO.output(Motor2A,GPIO.HIGH)
				GPIO.output(Motor2B,GPIO.LOW)
				GPIO.output(Motor2E,GPIO.HIGH)

				conn.sendall(str(1))
			elif int_output == 2:
				GPIO.output(Motor1A,GPIO.LOW)
				GPIO.output(Motor1B,GPIO.HIGH)
				GPIO.output(Motor1E,GPIO.HIGH)
 
				GPIO.output(Motor2A,GPIO.LOW)
				GPIO.output(Motor2B,GPIO.HIGH)
				GPIO.output(Motor2E,GPIO.HIGH)

				conn.sendall(str(2))
			elif int_output == 3:
				GPIO.output(Motor1E,GPIO.LOW)
				GPIO.output(Motor2E,GPIO.LOW)
				conn.sendall(str(3))
			else:
				conn.sendall(str(-1))
	finally:
		conn.close() 
		GPIO.cleanup()
