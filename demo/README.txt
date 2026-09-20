--------------
 LIST OF DEMO
--------------

A demo can be loaded using the Forth command sequence

  import demo/<source.f>

Where <source.f> has to be specified as one of the file available in 
./demo directory. Usually a demo starts by itself, but it can be started 
using the last defined word. 


  
Fedora.f
--------
Adaptation of Patrick Kaell's Fedora hat draw that uses standard GRAPHICS 
library. To forget this demo you can give TASK, that's a marker that restores 
things as they were before import-ing this source file.



Chomp-chomp.f
-------------
Simple pac-man like game. Your character can be controlled using keyboard
via arrows keys or using Kempston joystick. Each of the four ghosts follows
its own arcade targeting rule: Blinky (red) heads straight for you, Pinky
(magenta) aims four cells ahead to cut you off, Inky (cyan) doubles the
vector running from Blinky to the cell ahead of you, and Ted (yellow)
charges until he is within eight cells and then backs off to his corner.
They alternate between chasing and scattering to their own corners, all
turn round together whenever that mode changes, and they travel at 75% of
your speed - 50% while frightened. Once loaded, you have to give GAME to
start it.
Game speed is a parameter rather than an accident of how many sprites get
drawn: TICK-FRAMES holds how many 50Hz video frames one game tick lasts
(5 by default), so  3 TICK-FRAMES !  makes the whole game quicker.
Clearing a maze moves you on to the next one. The first is compiled into
the game, so a standalone executable never depends on the block file; the
other three live on Screen 740 and up, two Screens each, and can be
redrawn with EDIT without recompiling anything -  n MAZE-CHECK  then
reports whether maze n still holds together (borders sealed, tunnel
mouths paired, nothing walled off, the sprite start cells intact). Line 0
of each of the two Screens is a title comment rather than maze data, so
INDEX shows a readable label instead of a wall of glyphs.
util/chomp-maze.py does the same checks from the host, and draws the maze
as pixels so a layout can be seen before it is played.
 n TEST-LEVEL  starts the game straight at maze n (0 is the compiled
one), which is handy for trying out a layout you just edited without
first clearing every level before it.
To forget this demo you have to give COLD.
This demo also come with a subdirectory named chomp-chomp that contains
the result of execution of ZAP definition that is the simplest way to 
produce a standalone executable of this game.



Color-Picker.f
--------------
This demo shows Layer-2 color palette and interrupt-driven Mouse capability.
There are two entry-point: COLOR-PICKER and PICK-COLOR and to forget this
demo you can type NO-MOUSE that disable and forget mouse portion too.



Bmp-Demo.f
----------
Show Layer-2 graphics mode capability showing 14 images available in 
directory /demos/bmp256converts/bitmaps/ standard distro
 
    critters.bmp  
    diehard.bmp   
    et.bmp        
    et2.bmp       
    freddy.bmp    
    friday.bmp    
    future.bmp    
    indian.bmp    
    jaws.bmp      
    krull.bmp     
    rocky.bmp     
    teenwolf.bmp  
    term.bmp      
    trouble.bmp   

Since the loading of each .bpm file takes some time, uses two distinct RAM
group of pages to be able to load one image while the previous image is still 
displayed. This demo auto-starts.



Layer3-Demo1.f
--------------
First demo to show how Layer3 mode work. Since vForth origin location is $6363
here we use part of Display-File itself for Tilemap base addresses.
Tilemap Base Address is set at $4000 for both 40 and 80 columns examples.
80 columns Tile Definitions lies at $5400-$5AFF, 1-bit per pixel, allowing 224 
distinct character-definitions, and since the first 32 are non-printable we can
cover all 1-byte possible characters.
40 columns Tile Definitions lies at $4A00-$5AFF, 4-bits per pixel. This allows
only 136 character-definitions much more colorful if we know how to use them.
We define four colours (yellow, red, magenta, white) always using a blue back-
ground color, then the screen is filled with ASCII characters.
Running this demo using non-dot vForth version lets you appreciate how Display-
File memory is filled with data before showing the correct result.
Dot-version shows a jammed character-set, see next demo instead.


Layer3-Demo2.f
--------------
This #2 demo is almost identical to #1, but all data are loaded from SD where
we previously saved running Layer3-Demo2-setup.f auxiliary source file.
For this reason, dot-version works as fine as non-dot version.



Brot.f
------
Mandelbrot set on Layer 2, computed entirely in 16-bit scaled (fixed point)
integers: the value n stands for n/256. The arithmetic is explained step
by step in tutorial 064. Entry point is DEMO, which draws the default
view and waits for any key before switching back to the text screen.
Zoom by setting a new view before calling DEMO again:
  cx cy span WINDOW  ( hundredths, e.g. -50 60 120 WINDOW )
  DEMO
Mind the iteration count: the loop gives up after 15 rounds and calls the
point "inside", so a view aimed close to the boundary - the seahorse
valley, e.g. -75 10 60 WINDOW - comes out almost entirely black. Deeper
views need more iterations, and more shades in COLOR-TAB.

