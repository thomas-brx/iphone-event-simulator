iphone-event-simulator
======================

Map apple keyboard event to events on the iPhone simulator

About:

There are 2 components, one python-script (requires pygame on your system), and sourcecode to link in your app.
The  python-script polls the keyboard for key-down and key-up events and sends broadcasts (UDP) those on the local network.
The Objective-C part will poll for events and trigger event-handlers accordingly.

Usage:

In your app, add the files iPhoneEventSimulator.h and iPhoneEventSimulator.mm.

To register events, first get a copy of the iPhoneEventSimulator singleton:

```Objective-C
// The port 10552 is hardcoded in the python program.
iPhoneEventSimulator *sim = [iPhoneEventSimulator sharedSimulatorWithPort:10552];

// Then register events for different key-codes:
[sim addHandlersForKey:K_LEFT
	   keyDown:^() {
	       [hero moveLeft];
	   }
	     keyUp:^() {
	       [hero stopMoving];
	   }
];
[sim addHandlersForKey:K_ESCAPE
	   keyDown:^() {
	       exit(1);
	   }
	     keyUp:nil
];


// To unregister events:

[sim resetHandlers];
```


Compile and run the app in the simulator. When it is runnning, start the python program from the terminal:

```bash
$ ./bin/iPhoneEventSimulator.py
```

Make sure the spawned Python-app has focus. Now all key-presses are broadcasted and will trigger the corresponding
event-handlers in the iPhone simulator.

Notes:

* The key-codes are defined in the header-file.

* This code should only be used on the simulator, so protect it by:

```Objective-C
\#ifndef TARGET_IPHONE_SIMULATOR
\#endif
```
