import OSC
import time
from gtts import gTTS
import os
import socket
import threading
from OSC import OSCClient, OSCMessage
from OSC import OSCServer
import collections
import statistics


server = OSCServer( ("localhost", 12001) )
server.timeout = 0
run = True

# this method of reporting timeouts only works by convention
# that before calling handle_request() field .timed_out is 
# set to False
def handle_timeout(self):
    self.timed_out = True

# funny python's way to add a method to an instance of a class
import types
server.handle_timeout = types.MethodType(handle_timeout, server)

#server.addMsgHandler("/wek/outputs",response)

array = []
current_output = 1.0
count = 0
not_count = 0

run = True

loop_element = 0
thread_flag = True



d = collections.deque([],maxlen = 1)



def respond_voice(value):

	print "Initialized respond"


	global current_output
	global d
	global not_count
	global thread_flag
	print "\nResponse Generating"
        print d[0]
	if d[0] != current_output:
		not_count = not_count + 1
		if not_count > 1:
			thread_flag = False

			if d[0] == 1.0 :
				print "Straight"
				speech('Straight')
				current_output = 1.0
			if d[0] == 2.0 :
				print "Turn"
				speech('Turn')
				current_output = 2.0
                        '''
			if d[0] == 3.0 :
				print "Obstacle"
				speech('Obstacle')
				current_output = 3.0
                        
                        if d[0] == 4.0 :
				print "Straight"
				speech('Straight')
				current_output = 4.0
			'''
			
	thread_flag = True
	return


def response(path,tags, args, source):
	#print args[0]
	global count
	global not_count
	global current_output
	global thread_flag	

	global d
        stat_array = []
	for i in range(10):
            stat_array.append(args[i])
        mode = statistics.mode(stat_array)
        '''
        print mode
        '''
	#print args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7]
	
	d.append(mode)
	#print current_output
	#print d[0]
	if mode != current_output:
		if mode == 1.0:
                    print "Straight"
                elif mode == 2.0:
                    print "Turn"
		respond_voice(mode)

		
	

server.addMsgHandler("/wek/outputs",response)

def each_frame():
    # clear timed_out flag
    server.timed_out = False
    # handle all pending requests then return
    while not server.timed_out:
        server.handle_request()


def speech(input_text):
	
	tts = gTTS(text=input_text,lang = 'en')
	tts.save("good.mp3")
	os.system("mpg321 good.mp3")


def main():
    """This runs the protocol on port 8000"""
    
    while run:
    	time.sleep(1)
    	each_frame()
    server.close()

if __name__ == '__main__':
    main()


