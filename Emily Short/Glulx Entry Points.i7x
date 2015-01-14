Version 10/150114 of Glulx Entry Points (for Glulx only) by Emily Short begins here.

"Provides hooks to allow the author to write specialized multimedia behavior that would normally go through HandleGlkEvent. This is a rather dull utility library that will be of most use to authors wanting to write Glulx extensions compatible with other Glulx extensions already in use."

Use authorial modesty.

Section - Use option

[As of version 10, Glulx Entry Points has a somewhat more flexible approach to event handling than did earlier versions: Whereas the latter consulted one of eight separate rulebooks depending on the event type, Glulx Input Loops passes the event type into a single parametrized rulebook. This means, for example, that we can have a general rule for event handling that fires no matter what the event, alongside the usual event-based rules. It allows us to group events by broader type (e.g. events generated by the player vs. events generated by the system).

Many existing extensions are based on the older system, however, and we would break those extensions if we simply removed the older event-handling rulebooks. So, we retain them, and Glulx Entry Points will (by default) still pass event-handling to those rulebooks. This means that existing code will continue to work as before, and we can also use the new parameterized rulebook if we like.

This use option disables the old rulebooks, and should be used only when we know that we are not using an extension that depends on the old rulebooks.]

Use direct event handling translates as (- Constant DIRECT_GLK_EVENT_HANDLING; -).


Section - New rulebooks

[This first set of rulebooks--the event-handling rulebooks--are now deprecated in favor of the "glulx input handling rulebook".]
The glulx timed activity rules is a rulebook.
The glulx redrawing rules is a rulebook.
The glulx arranging rules is a rulebook.
The glulx sound notification rules is a rulebook.
The glulx mouse input rules is a rulebook.
The glulx character input rules is a rulebook.
The glulx line input rules is a rulebook.
The glulx hyperlink rules is a rulebook.

The glulx zeroing-reference rules is a rulebook.
The glulx resetting-windows rules is a rulebook.
The glulx resetting-streams rules is a rulebook.
The glulx resetting-filerefs rules is a rulebook.
The glulx resetting-channels rules is a rulebook.
The glulx object-updating rules is a rulebook.


Section - Global variables

Current glulx rock is a number that varies.
Current glulx rock-ref is a number that varies.

Glulx replacement command is some indexed text that varies.

Library input context is a number variable. [This describes the event context in which input was received, e.g. whether the Inform library was awaiting line input or char input. If 0, the library was awaiting line input, if 1, char input. This is not as useful as an event-typed value would be; with such a value, we could detect any input context--e.g., we are waiting for hyperlink input. Perhaps a future version of Glulx Entry Points will discard the old convention in favor of a more expansive system.]


Section - Gestalts

To decide whether glulx character input is supported:
	(- ( glk_gestalt(gestalt_CharInput, 0) ) -)

To decide whether glulx mouse input is supported:
	(- ( glk_gestalt(gestalt_MouseInput, winType_AllTypes) ) -)

To decide whether glulx graphic-window mouse input is supported:
	(- ( glk_gestalt(gestalt_MouseInput, winType_Graphics) ) -)

To decide whether glulx text-grid mouse input is supported:
	(- ( glk_gestalt(gestalt_MouseInput, winType_TextGrid) ) -)

To decide whether glulx timekeeping is supported:
	(- ( glk_gestalt(gestalt_Timer, 0) ) -)

To decide whether glulx graphics is supported:
	(- ( glk_gestalt(gestalt_Graphics, 0) ) -)

To decide whether glulx text-buffer graphics is supported:
	(- ( glk_gestalt(gestalt_DrawImage, winType_TextBuffer) ) -)

To decide whether glulx graphic-window graphics is supported:
	(- ( glk_gestalt(gestalt_DrawImage, winType_Graphics) ) -)

To decide whether glulx PNG transparency is supported:
	(- ( glk_gestalt(gestalt_GraphicsTransparency, 0) ) -)

To decide whether glulx sound is supported:
	(- ( glk_gestalt(gestalt_Sound, 0) ) -)

To decide whether glulx mod sound is supported:
	(- ( glk_gestalt(gestalt_SoundMusic, 0) ) -)

To decide whether glulx sound volume is supported:
	(- ( glk_gestalt(gestalt_SoundVolume, 0) ) -)

To decide whether glulx sound notification is supported:
	(- ( glk_gestalt(gestalt_SoundNotify, 0) ) -)

To decide whether glulx hyperlinks are supported:
	(- ( glk_gestalt(gestalt_Hyperlinks, 0) ) -)



Section - Update GGRecoverObjects() to identify sound channels

Include (-
Replace GGRecoverObjects;
-) before "Glulx.i6t".

Include (-

[ GGRecoverObjects id;
    ! If GGRecoverObjects() has been called, all these stored IDs are
    ! invalid, so we start by clearing them all out.
    ! (In fact, after a restoreundo, some of them may still be good.
    ! For simplicity, though, we assume the general case.)
    gg_mainwin = 0;
    gg_statuswin = 0;
    gg_quotewin = 0;
    gg_scriptfref = 0;
    gg_scriptstr = 0;
    gg_savestr = 0;
    statuswin_cursize = 0;
    gg_foregroundchan = 0;
    gg_backgroundchan = 0;
    #Ifdef DEBUG;
    gg_commandstr = 0;
    gg_command_reading = false;
    #Endif; ! DEBUG
    ! Also tell the game to clear its object references.
    IdentifyGlkObject(0);

    id = glk_stream_iterate(0, gg_arguments);
    while (id) {
        switch (gg_arguments-->0) {
            GG_SAVESTR_ROCK: gg_savestr = id;
            GG_SCRIPTSTR_ROCK: gg_scriptstr = id;
            #Ifdef DEBUG;
            GG_COMMANDWSTR_ROCK: gg_commandstr = id;
                                 gg_command_reading = false;
            GG_COMMANDRSTR_ROCK: gg_commandstr = id;
                                 gg_command_reading = true;
            #Endif; ! DEBUG
            default: IdentifyGlkObject(1, 1, id, gg_arguments-->0);
        }
        id = glk_stream_iterate(id, gg_arguments);
    }

    id = glk_window_iterate(0, gg_arguments);
    while (id) {
        switch (gg_arguments-->0) {
            GG_MAINWIN_ROCK: gg_mainwin = id;
            GG_STATUSWIN_ROCK: gg_statuswin = id;
            GG_QUOTEWIN_ROCK: gg_quotewin = id;
            default: IdentifyGlkObject(1, 0, id, gg_arguments-->0);
        }
        id = glk_window_iterate(id, gg_arguments);
    }

    id = glk_fileref_iterate(0, gg_arguments);
    while (id) {
        switch (gg_arguments-->0) {
            GG_SCRIPTFREF_ROCK: gg_scriptfref = id;
            default: IdentifyGlkObject(1, 2, id, gg_arguments-->0);
        }
        id = glk_fileref_iterate(id, gg_arguments);
    }

	if (glk_gestalt(gestalt_Sound, 0)) {
		id = glk_schannel_iterate(0, gg_arguments);
		while (id) {
			switch (gg_arguments-->0) {
				GG_FOREGROUNDCHAN_ROCK: gg_foregroundchan = id;
				GG_BACKGROUNDCHAN_ROCK: gg_backgroundchan = id;
				default: IdentifyGlkObject(1, 3, id, gg_arguments-->0);
			}
			id = glk_schannel_iterate(id, gg_arguments);
		}
		if (gg_foregroundchan ~= 0) { glk_schannel_stop(gg_foregroundchan); }
		if (gg_backgroundchan ~= 0) { glk_schannel_stop(gg_backgroundchan); }
	}

    ! Tell the game to tie up any loose ends.
    IdentifyGlkObject(2);
];

-) after "Glulx.i6t".



Section - IdentifyGlkObject routine

Include (-

[ IdentifyGlkObject phase type ref rock;
	if ( phase == 0 )
	{
		! Zero out references to our objects.
		if ( FollowRulebook( (+ glulx zeroing-reference rules +) ) && RulebookSucceeded() )
		{
			rtrue;
		}
	}

	if ( phase == 1 )
	{
		! Reset our windows, streams and filerefs.
		(+ current glulx rock +) = rock;
		(+ current glulx rock-ref +) = ref;
		switch (type)
		{
			0: ! it's a window 
				FollowRulebook( (+ glulx resetting-windows rules +) );
			1 : ! it's a stream
				FollowRulebook( (+ glulx resetting-streams rules +) );
			2 : ! it's a file reference
				FollowRulebook( (+ glulx resetting-filerefs rules +) );
			3 : ! it's a sound channel
				FollowRulebook( (+ glulx resetting-channels rules +) );
		}
		return;
	}

	if ( phase == 2 )
	{
		! Update our objects.
		if ( FollowRulebook( (+ glulx object-updating rules +) ) && RulebookSucceeded() )
		{
			rtrue;
		}
	}
];

-) before "Glulx.i6t".


Section - Event types

A g-event is a kind of value. The g-events are timer-event, char-event, line-event, mouse-event, arrange-event, redraw-event, sound-notify-event, and hyperlink-event.

To decide which g-event is null-event: (- 0 -)


Section - Events dependent on the player

Definition: A g-event is independent of the player rather than dependent on the player if it is timer-event or it is sound-notify-event or it is arrange-event or it is redraw-event.


Section - Wrappers for event structure, return values, etc

To wait for glk input:
	(- glk_select(gg_event); -)

To decide whether the current input context is line input:
	(- ( (+ library input context +) == 0 ) -)

To decide whether the current input context is char/character input:
	(- ( (+ library input context +) == 1 ) -)
	
To decide which g-event is the current glk event:
	(- evGlobal-->0 -)
	
To decide what number is the window of the current glk event:
	(- evGlobal-->1 -)
	
To decide what number is the character code returned:
	(- evGlobal-->2 -)

To decide what number is input replacement:
	(- 2 -)

To decide what number is input continuation:
	(- 1 -)


Section - Event Handling

[This is an I7 version of the event handling that was included in the I6 HandleGlkEvent routine in previous versions of Glulx Entry Points, with minor changes to allow any event type to provide a replacement command. Converted to I7 code in version 10.]

To decide what number is the value returned by glk event handling (this is the handle glk event rule):
	now glulx replacement command is "";
	follow the glulx input handling rules for the current glk event;
	if the outcome of the rulebook is the replace player input outcome:
		decide on input replacement;
	if the outcome of the rulebook is the require input to continue outcome:
		decide on input continuation;
	follow the command-counting rules;
	if the rule succeeded:
		follow the input-cancelling rules;
		follow the command-showing rules;
		follow the command-pasting rules;
		if the [command-pasting] rule succeeded:
			decide on input replacement.


Section - HandleGlkEvent routine

Include (- Array evGlobal --> 4; -) before "Glulx.i6t".

Include (- 

  [ HandleGlkEvent ev context abortres newcmd cmdlen i ;
      for (i=0:i<3:i++) evGlobal-->i = ev-->i;
      (+ library input context +) = context;
      return (+ value returned by glk event handling +) ;
  ];

-) before "Glulx.i6t".


Section - Useful function wrappers

To update/redraw the/-- status line:
	(- DrawStatusLine(); -)

To print prompt:
	(- PrintPrompt(); -)


Section - The glulx input handling rulebook

[These rules route input to the separate event-handling rulebooks originally used by older versions of Glulx Entry Points. They do nothing if we have activated the direct event handling use option.]

The glulx input handling rules are a g-event based rulebook. The glulx input handling rules have outcomes replace player input (success) and require input to continue (success).

Last glulx input handling rule for a timer-event when the direct event handling option is not active (this is the redirect to GEP timed activity rule):
	abide by the glulx timed activity rules.

Last glulx input handling rule for a char-event when the direct event handling option is not active (this is the redirect to GEP character input rule):
	abide by the glulx character input rules.

Last glulx input handling rule for a line-event when the direct event handling option is not active (this is the redirect to GEP line input rule):
	follow the glulx line input rules;
	if the rule succeeded:
		replace player input.

Last glulx input handling rule for a mouse-event when the direct event handling option is not active (this is the redirect to GEP mouse input rule):
	abide by the glulx mouse input rules.

Last glulx input handling rule for an arrange-event when the direct event handling option is not active (this is the redirect to GEP arranging rule):
	abide by the glulx arranging rules.

Last glulx input handling rule for a redraw-event when the direct event handling option is not active (this is the redirect to GEP redrawing rule):
	abide by the glulx redrawing rules.

Last glulx input handling rule for a sound-notify-event when the direct event handling option is not active (this is the redirect to GEP sound notification rule):
	abide by the glulx sound notification rules.

Last glulx input handling rule for a hyperlink-event when the direct event handling option is not active (this is the redirect to GEP hyperlink rule):
	abide by the glulx hyperlink rules.



Section - Debounce arrange events - unindexed

[ Gargoyle sends an arrange event while the user is dragging the window borders, but we really only want one event at the end. Debounce the arrange event to ignore the earlier ones. ]

Arranging now in GEP is a truth state variable. Arranging now in GEP is false.

First glulx input handling rule for an arrange-event while arranging now in GEP is false (this is the debounce arrange event rule):
	let i be 0; [ for the I6 polling code to use ]
	let final return value be a number;
	let arrange again be true;
	[ Poll for further arrange events ]
	while 1 is 1:
		poll for events in GEP;
		if the current event number in GEP is 0:
			break;
		otherwise if the current glk event is an arrange-event:
			next;
		[ We have a different event ]
		otherwise:
			[ Run the arrange rules ]
			let temp event type be the current glk event;
			set the current glk event in GEP to an arrange-event;
			now final return value is the glulx input handling rules for an arrange event;
			set the current glk event in GEP to temp event type;
			now arrange again is false;
			now final return value is the value returned by glk event handling;
			break;
	[ Run the arrange rules if we didn't get another event type ]
	if arrange again is true:
		now final return value is the glulx input handling rules for an arrange event;
	[ Return values ]
	if final return value is input replacement:
		replace player input;
	if final return value is input continuation:
		require input to continue;
	rule fails;

To decide what number is the glulx input handling rules for an arrange event:
	let final return value be a number;
	now arranging now in GEP is true;
	now final return value is the value returned by glk event handling;
	now arranging now in GEP is false;
	decide on final return value;

To poll for events in GEP:
	(- glk_select_poll( gg_event ); for ( tmp_0 = 0 : tmp_0 < 3 : tmp_0++) { evGlobal-->tmp_0 = gg_event-->tmp_0; } -).

To decide what number is the current event number in GEP:
	(- evGlobal-->0 -).

To set the current glk event in GEP to (ev - a g-event):
	(- evGlobal-->0 = {ev}; -).



Section - Command-counting rules

The command-counting rules are a rulebook.

A command-counting rule (this is the ordinary checking for content rule):
	if the number of characters in the glulx replacement command is 0, rule fails;
	rule succeeds.


Section - Input-cancelling rules
	
The input-cancelling rules are a rulebook.

An input-cancelling rule (this is the cancelling input in the main window rule):
	cancel line input in the main window;
	cancel character input in the main window;
	
To cancel line input in the/-- main window:
	(- glk_cancel_line_event(gg_mainwin, GLK_NULL); -)
	
To cancel character input in the/-- main window:
	(- glk_cancel_char_event(gg_mainwin); -)


Section - Command showing rules

The command-showing rules are a rulebook.

A command-showing rule (this is the print text to the input prompt rule):
	say input-style-for-glulx;
	say Glulx replacement command;
	say roman type;

To say input-style-for-Glulx: 
	(- glk_set_style(style_Input); -)
 

Section - Command pasting rules

The command-pasting rules are a rulebook. 

A command-pasting rule (this is the glue replacement command into parse buffer rule): 
	change the text of the player's command to the Glulx replacement command;
	rule succeeds.



Glulx Entry Points ends here.

---- Documentation ----

Please note that this extension is provided as a framework and as a basis for other extensions. Thanks to Eliuk Blau and Jon Ingold for pointing out some bugs in version 5, and to Erik Temple for the patch handling input cancellation that brings us to version 7.


Chapter: Events

Glulx allows the author to set responses to certain events:

	Timer       - event repeated at fixed intervals
	CharInput   - keystroke input in a window
	LineInput   - full line of input in a window
	MouseInput  - mouse input in a window
	Arrange     - some windows sizes have changed
	Redraw      - graphic windows need redrawing
	SoundNotify - sound finished playing
	Hyperlink   - selection of a hyperlink in a window

As of version 10, Glulx Entry Points provides a rulebook, the "glulx input handling rules" so that the author can add responses to the these events without himself having to include any Inform 6 code. The glulx input handling rules is a parameterized rulebook, meaning that the author can specify which event or events a given rule responds to by specifying a kind of value, the "g-event". The g-events corresponding to the events types described above are:

	timer-event
	char-event
	line-event
	mouse-event
	arrange-event
	redraw-event
	sound-notify-event
	hyperlink-event

It is also possible to refer to groups of g-events using adjectives. Two adjectives are provided, though the user could of course create more. These are:

	independent of the player - includes timer events, sound notification events, arrange events, and redraw events.
	dependent on the player - includes all other events, i.e. the events that can only happen due to player input.

We can get basic information about the last event handled using these phrases:

	current glk event - the g-event type last handled.
	window of the current glk event - if the last event was associated with a window (char-event, line-event, mouse-event, or hyperlink-event), this contains the number of the window's glk reference.

The glulx input handling rulebook replaces the set of eight rulebooks defined in versions of Glulx Entry Points previous to version 9. These rulebooks, listed below, should be considered deprecated and may be removed in a future version of the extension, but for now they will still work just as they did in past versions:

	The glulx timed activity rules is a rulebook.
	The glulx redrawing rules is a rulebook.
	The glulx arranging rules is a rulebook.
	The glulx mouse input rules is a rulebook.
	The glulx character input rules is a rulebook.
	The glulx line input rules is a rulebook.
	The glulx sound notification rules is a rulebook.
	The glulx hyperlink rules is a rulebook.

If you are certain that you do not need these rulebooks in a project (i.e., you are not using extensions that employ them), you can stop Inform from calling them by declaring the use option:

	Use direct event handling.


Chapter: Replacement Commands 

One of the things we may want to do -- especially with mouse input or hyperlinks -- is generate a command for the player. To do this, we set the value of Glulx replacement command to whatever string of text we want to turn into the player's command. If we do this, Inform will treat whatever command we issued in "Glulx replacement command" as though the player had typed it at the command prompt. The extension Basic Hyperlinks builds on this infrastructure and provides an example of how to make use of these features. 

Because the Glulx replacement command is indexed text, it is possible to build on to the string automatically, if for some reason we need to auto-generate our recommended commands. 


Chapter: IdentifyGlkObject

We also have a series of rulebooks for handling the stages of IdentifyGlkObject:
	
	The glulx zeroing-reference rules is a rulebook.
	The glulx resetting-windows rules is a rulebook.
	The glulx resetting-streams rules is a rulebook.
	The glulx resetting-filerefs rules is a rulebook.
	The glulx resetting-channels rules is a rulebook.
	The glulx object-updating rules is a rulebook.

Examples of the use of these can be seen in the extension Simple Graphics Windows. 


Chapter: Checking on Feature Support (Glulx Gestalts)

We can test whether the player's interpreter is prepared to support various multimedia features using the following phrases from Glulx Entry Points:
	
	if glulx character input is supported...
	if glulx mouse input is supported...
	if glulx graphic-window mouse input is supported...
	if glulx text-grid mouse input is supported...
	if glulx timekeeping is supported...
	if glulx graphics is supported...
	if glulx text-buffer graphics is supported...
	if glulx graphic-window graphics is supported...
	if glulx PNG transparency is supported...
	if glulx sound is supported...
	if glulx mod sound is supported...
	if glulx sound volume is supported...
	if glulx sound notification is supported...
	if glulx hyperlinks are supported...

Of these:
	"mouse input" refers to our ability to detect clicks at all
	"timekeeping" to the ability to use a real-time timer
	"graphics" to the ability to use any graphics
	"text-buffer" and "graphic-window" graphics to the ability to use graphics specifically in the main window or in a window specially created for graphics
	"PNG transparency" to whether it will be possible to layer PNG images with transparent alpha channels (this is very useful for manipulating sprites)
	"sound" to playing any sound, and "mod sound" to sounds specifically in MOD format
	"sound volume" to the ability to control the volume
	"sound notification" to detecting when a sound finishes playing
	"hyperlinks" to the ability to insert mouseclick-sensitive links in the main body of text

These can be used during play to avoid using Glulx features that aren't supported, or at the start of play to warn the player that the chosen interpreter is unable to present the full experience intended by the author.


Section: A Note on Sound Support

Currently Inform is not designed to support sound output properly across all systems. The Mac OS X IDE will not play sounds in-game, so if we are developing a sound-rich game on the Mac, we will need to test the sounds by releasing the game file and playing it on a separate interpreter; at the time of writing, the best Mac sound support was provided by Gargoyle.


Chapter: Useful Phrases

Two phrases that may be useful to those working with Glulx input/output are provided:

	update the status line - calls the Inform library's routine to refresh the status window
	print prompt - calls the Inform library's routine to print the command prompt


Example: * Input Handling - Very basic use of the glulx input handling rules. Shows how to detect events according to whether they are generated by player input, how to override the player's typed input with a replacement command, and how to use the "current glk event" phrase.

	Include version 10 of Glulx Entry Points by Emily Short.
	
	Use direct event handling.
	
	Glk Testing is a room.
	
	Glulx input handling rule for an independent of the player g-event:
	say "[bracket]Non-input event detected: [current glk event][close bracket][line break]".
		
	Glulx input handling rule for a dependent on the player g-event:
		say "[bracket]Player input detected: [current glk event][close bracket][line break]".
		
	Glulx input handling rule for a line-event:
		now the Glulx replacement command is "jump".


Example: * Working Without Sound - Printing a warning at the beginning of the game if the interpreter does not use sound.

	*: "Working Without Sound"

	Include Glulx Entry Points by Emily Short.

	Include Basic Screen Effects by Emily Short.

	First when play begins:
		unless glulx sound is supported:
			say "This game uses sound effects extensively. The interpreter you're using is unable to play sounds, so you will be missing part of the intended experience.
		
Would you like to continue anyway?";
			unless the player consents:
				stop game abruptly.

	Royal Albert Hall is a room.
	
	Test me with "listen".
