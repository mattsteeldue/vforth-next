This directory conains a few Visual Studio Code projects that compile the same
".bin" binary code as the corresponding ".f" Forth source.

So, compilation can be done "istantly" using Visual Studio Code or "waiting" a
few minutes by running the compilation course from within Forth system itself
via "10 LOAD". 

This means that -- for real -- Forth compiles itself, in fact, 
this compilation course compiles twice the same Forth source, the first targeting
normally some upper memory, the second targeting back the original "origin".

A byte comparison can be done between the CODE saved via ZX Spectrum SAVE
the usual way and the binary produced via Visual Studio Code to ensure both produce
the same output.

