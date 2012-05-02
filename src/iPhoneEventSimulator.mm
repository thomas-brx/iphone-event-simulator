/*
iPhoneEventSimulator.h

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
*/

#import <netinet/in.h>
#import "iPhoneEventSimulator.h"


@implementation iPhoneEventSimulator

+ (iPhoneEventSimulator *)sharedSimulatorWithPort:(NSUInteger)port
{
	static iPhoneEventSimulator *sharedSingleton;
	
	@synchronized(self)
	{
		if (!sharedSingleton)
			sharedSingleton = [[iPhoneEventSimulator alloc] initWithPort:port];
		
		return sharedSingleton;
	}
#endif
}

void readCallback(
		  CFSocketRef s,
		  CFSocketCallBackType callbackType,
		  CFDataRef address,
		  const void *data,
		  void *info
		 ) {
	iPhoneEventSimulator *self = (__bridge iPhoneEventSimulator *)info;
	const UInt8 *p = CFDataGetBytePtr((CFDataRef)data);

	UInt16 i = ntohs(*(UInt16 *)(p + 1));
	BOOL isUp = p[0];
	
	void (^handler)();
	
	if (isUp) {
		handler = [self upHandler:i];
	} else {
		handler = [self downHandler:i];
	}
	
	if (handler)
		handler();
}

- (void (^)())upHandler:(UInt16)key
{
	if (key >= 512)
		return nil;
	return keyUpHandlers[key];
}

- (void (^)())downHandler:(UInt16)key
{
	if (key >= 512)
		return nil;
	return keyDownHandlers[key];
}

- (id)initWithPort:(NSUInteger)port
{
	if ((self = [super init])) {
		sockHandle = socket(AF_INET, SOCK_DGRAM, 0);
		struct sockaddr_in sa;
		sa.sin_family = AF_INET;
		sa.sin_addr.s_addr = htonl(INADDR_ANY);
		sa.sin_port = htons(port);
		bind(sockHandle, (struct sockaddr *)&sa, sizeof(sa));
		
		CFSocketContext socketContext = {0, (__bridge void *)self, NULL, NULL,	NULL};
		cfSocket = CFSocketCreateWithNative(NULL, sockHandle, kCFSocketDataCallBack, readCallback, &socketContext);
		cfSource = CFSocketCreateRunLoopSource(NULL, cfSocket, 0);
		CFRunLoopAddSource(CFRunLoopGetCurrent(), cfSource, kCFRunLoopDefaultMode);		
	}
	
	return self;
}

- (void)addHandlersForKey:(EventCode)key keyDown:(void (^)())downBlock keyUp:(void (^)())upBlock
{
	if (key > 512)
		return;

	keyUpHandlers[key] = upBlock;
	keyDownHandlers[key] = downBlock;
}

- (void)resetHandlers
{
	for (int i = 0 ; i < 512 ; i++) {
		keyUpHandlers[i] = nil;
		keyDownHandlers[i] = nil;
	}
}

- (void)dealloc
{
	[self resetHandlers];
	CFRunLoopRemoveSource(CFRunLoopGetCurrent(), cfSource, kCFRunLoopDefaultMode);
	CFSocketInvalidate(cfSocket);
	CFRelease(cfSource);
	CFRelease(cfSocket);
	close(sockHandle);
	cfSource = NULL;
	cfSocket = NULL;
}


@end
