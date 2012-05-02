#!/usr/bin/python

"""
iPhoneEventSimulator.py

Copyright (c) 2012, Thomas Broquist
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met: 

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer. 
2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution. 

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

The views and conclusions contained in the software and documentation are those
of the authors and should not be interpreted as representing official policies, 
either expressed or implied, of the FreeBSD Project.
"""

import pygame, sys, socket, struct
from pygame.locals import *

fpsClock = pygame.time.Clock()

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind(('',0))
sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)

pygame.init()

print "Broadcasting key-events to port 10552, hit Ctrl-C to stop. Make sure the pygame app (without window) has focus" 

while True:
    for event in pygame.event.get():
        if event.type == QUIT:
            pygame.quit()
            sock.close()
            sys.exit
        elif event.type == KEYDOWN:
            sock.sendto(struct.pack('!?H', False, event.key), ('<broadcast>', 10552))
        elif event.type == KEYUP:
            sock.sendto(struct.pack('!?H', True, event.key), ('<broadcast>', 10552))

    fpsClock.tick(30)
