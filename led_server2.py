import os
import glob
import time

import RPi.GPIO as GPIO, time, os  

import socket
import sys

# Import SPI library (for hardware SPI) and MCP3008 library.
import Adafruit_GPIO.SPI as SPI
import Adafruit_MCP3008

#  Set up the photocell
def read_light (LightPin):
        
        DEBUG = 1
        GPIO.setmode(GPIO.BCM)
        reading = 0
        GPIO.setup(LightPin, GPIO.OUT)
        GPIO.output(LightPin, GPIO.LOW)
        time.sleep(0.1)

        GPIO.setup(LightPin, GPIO.IN)
        # This takes about 1 millisecond per loop cycle
        while (GPIO.input(LightPin) == GPIO.LOW):
                reading += 1
        return reading

# Set up rain sensor
def read_rain():
    # Software SPI configuration:
    CLK  = 18
    MISO = 23
    MOSI = 24
    CS   = 25
    mcp = Adafruit_MCP3008.MCP3008(clk=CLK, cs=CS, miso=MISO, mosi=MOSI)

    rainVal = mcp.read_adc(0)
    return rainVal

# Set up the thermometer
def read_temp_raw():
    os.system('modprobe w1-gpio')
    os.system('modprobe w1-therm')

    base_dir = '/sys/bus/w1/devices/'
    device_folder = glob.glob(base_dir + '28*')[0]
    device_file = device_folder + '/w1_slave'

    f = open(device_file, 'r')
    lines = f.readlines()
    f.close()
    return lines

def read_temp():
    lines = read_temp_raw()
    while lines[0].strip()[-3:] != 'YES':
        time.sleep(0.2)
        lines = read_temp_raw()
    equals_pos = lines[1].find('t=')
    if equals_pos != -1:
        temp_string = lines[1][equals_pos+2:]
        return temp_string

# Create a TCP/IP socket
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Bind the socket to the port
server_address = ('localhost', 10000)
print >>sys.stderr, 'starting up on %s port %s' % server_address
sock.bind(server_address)

# Listen for incoming connections
sock.listen(1)

while True:
    # Wait for a connection
    print >>sys.stderr, 'waiting for a connection'
    connection, client_address = sock.accept()

    try:
        print >>sys.stderr, 'connection from', client_address

        # Receive the data in small chunks and retransmit it
        while True:
            lightData = str(read_light(27))
            rainData = str(read_rain()/10)
            time.sleep(1)
            tempData = read_temp()
            if lightData and tempData and rainData:
                print >>sys.stderr, 'sending light data'
                print (lightData)
                connection.sendall(lightData)
                print >>sys.stderr, 'sending temperature data'
                print (tempData)
                connection.sendall(tempData)
                print >>sys.stderr, 'sending rain data'
                print (rainData)
                connection.sendall(rainData)
            else:
                print >>sys.stderr, 'no more data'
                break
            
    finally:
        # Clean up the connection
        connection.close()
