--------------
 LIST OF DEMO
--------------

A demo can be loaded using the Forth command sequence

  import demo/<source.f>

Where <source.f> has to be specified as one of the file available in 
./demo directory. Usually a demo won't start by itself, but has to be
started using the last defined word. 


  
Fedora.f
--------
Adaptation of Patrick Kaell's Fedora hat draw that uses standard GRAPHICS l
ibrary. To forget this demo you can give TASK, that's a marker that restores 
things as they were before import-ing this source file.



Chomp-chomp.f
-------------
Simple pac-man like game. Your character can be controlled using keyboard 
via arrows keys or using Kempston joystick. Ghosts movement are completely
random. Once loaded, you have to give GAME to start it.
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
zones to be able to load one image while the previous is still displayed.

