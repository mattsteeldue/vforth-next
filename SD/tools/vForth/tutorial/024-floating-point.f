\
\ 024-floating-point.f
\ Floating-point arithmetic: lib/floating.f.
\
\ vForth provides software floating-point using the ZX Spectrum's ROM
\ calculator routines.  Numbers are stored as 32-bit values occupying
\ two consecutive cells on the stack (stack notation: fp).
\
\ The floating-point library must be explicitly activated:
\   NEEDS FLOATING    -- load the library
\   FLOATING          -- switch number input to accept decimals (e.g. 3.14)
\   INTEGER           -- switch back to integer input
\ These two words modify NMODE user variable setting 1 or 0 respectively.
\ The NUMBER interpreter checks this variable to decide whether interpret
\ a string as a floating-point or as a double integer.
\
\ WARNING: 
\ forgetting FLOATING before entering fp numbers causes silent misparsing
\ (they are interpreted as double integers instead). Always pair FLOATING with
\ INTEGER before and after interactive fp work.
\
\ Because fp values occupy two cells, most fp words use the same
\ stack depth as their double-integer equivalents (D+, DABS, etc.).
\
\ Key words loaded by NEEDS FLOATING:
\   Arithmetic: F+  F-  F*  F/  FNEGATE  FABS  F**  FMOD
\   Comparison: F0<  F0>  F<  F>
\   Conversion: FLOAT (n->fp)  FIX (fp->addr n)  F>D  D>F
\   Output:     F.  F.R  PLACES
\   Constants:  PI  DEG>RAD  RAD>DEG
\   Trig:       FSIN  FCOS  FTAN  FEXP  FSQRT
\
\ NO-FLOATING removes the library and restores integer mode.
\
\ Starting FORTH (Brodie): no Brodie counterpart (vForth extension)
\ Reference: 3.7 - lib/floating.f
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   024 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 024 TUTORIAL
\

MARKER NO-THIS

: NEWTASK  NOOP  NO-THIS;

CR
.( --- Tutorial 024: floating point loaded. ) CR
.(     Type NEWTASK to restore integer mode. ) CR

NEEDS FLOATING

' NO-FLOATING  ' NEWTASK >BODY !


\ ===========================================================================
\ 1. Activating floating-point mode
\ ===========================================================================
\
\ After NEEDS FLOATING the library is present but integer input is still
\ the default.  Call FLOATING to switch the parser so that numbers with
\ a decimal point (3.14, -1.5, 0.001) are parsed as fp values.
\
\ FLOATING   -- switch to floating-point input mode
\ INTEGER    -- switch back to integer input mode
\
\ Forgetting to restore INTEGER after interactive fp work is a common
\ mistake: subsequent integer literals with a decimal separator would
\ be misinterpreted.

FLOATING
.( Floating-point input active. )  CR


\ ===========================================================================
\ 2. Basic arithmetic
\ ===========================================================================
\
\ F+ F- F* F/  all take two fp values and leave one:
\   ( fp1 fp2 -- fp3 )
\
\   3.0  2.0  F+  F.     => 5.0000e0
\   3.0  2.0  F-  F.     => 1.0000e0
\   3.0  2.0  F*  F.     => 6.0000e0
\   7.0  2.0  F/  F.     => 3.5000e0
\
\ FNEGATE ( fp -- fp' )   changes sign
\ FABS    ( fp -- fp' )   absolute value
\
\   -3.0  FNEGATE  F.    => 3.0000e0
\   -2.5  FABS     F.    => 2.5000e0
CR
.( Try: 3.0 2.0 F+ F. ) CR     \ => 5.0000e0
.( Try: 7.0 2.0 F/ F. ) CR     \ => 3.5000e0
.( Try: -3.0 FNEGATE F. ) CR   \ => 3.0000e0


\ ===========================================================================
\ 3. Comparison words
\ ===========================================================================
\
\ F0<  ( fp -- f )    true if fp < 0
\ F0>  ( fp -- f )    true if fp > 0
\ F<   ( fp1 fp2 -- f )  true if fp1 < fp2
\ F>   ( fp1 fp2 -- f )  true if fp1 > fp2
\
\   -1.0 F0<  .    => -1  (true)
\    1.0 F0<  .    => 0   (false)
\   3.0  5.0  F<  .  => -1  (true)

.( Try: -1.0 F0<  . ) CR    \ => -1
.( Try: 3.0 5.0 F< . ) CR   \ => -1


\ ===========================================================================
\ 4. Conversion between integers and fp
\ ===========================================================================
\
\ FLOAT ( n -- fp )    convert single integer to fp
\ FIX   ( fp -- a n ) convert fp to integer pair (for output / rounding)
\ D>F   ( d -- fp )   convert double to fp
\ F>D   ( fp -- d )   convert fp to double (truncates)
\
\   42  FLOAT  F.    => 4.2000e1
\s   3.7  F>D   D.    => 3  (truncated)

.( Try: 42  FLOAT F. ) CR      \ => 42.
.( Try: 3.7 F>D   D. ) CR      \ => 3


\ ===========================================================================
\ 5. Output formatting
\ ===========================================================================
\
\ F.  ( fp -- )     print fp with current PLACES decimal digits + space
\ F.R ( fp u -- )   print fp right-aligned in a field of u characters
\ PLACES ( n -- )   set the number of decimal places printed by F. (default 4)
\
\   PI F.          => 3.1416e0    (with PLACES = 4 as default)
\   2 PLACES
\   PI F.          => 3.14e0

.( PI = ) PI F. CR
2 PLACES
.( PI with 2 places: ) PI F. CR
4 PLACES


\ ===========================================================================
\ 6. Mathematical functions
\ ===========================================================================
\
\ FSQRT ( fp -- fp' )   square root
\ FEXP  ( fp -- fp' )   e^fp
\ FSIN  ( fp -- fp' )   sine (radians)
\ FCOS  ( fp -- fp' )   cosine (radians)
\ FTAN  ( fp -- fp' )   tangent (radians)
\ F**   ( fp1 fp2 -- fp3 )  fp1 raised to fp2
\
\ DEG>RAD ( fp -- fp' )   degrees to radians
\ RAD>DEG ( fp -- fp' )   radians to degrees
\
\   4.0 FSQRT F.        => 2.
\   PI 2.0 F/ FSIN F.   => 1.     (sin(pi/2) = 1)

.( Try: 4.0 FSQRT F.        ) CR   \ => 2.
.( Try: 45.0 DEG>RAD FSIN F.) CR   \ => 0.7071 (sin 45 deg)


\ ===========================================================================
\ 7. FCONSTANT  --  named fp constants
\ ===========================================================================
\
\ FCONSTANT is an alias for 2CONSTANT.  Use it to store fp values:
\
\   1.5  FCONSTANT HALF-THREE
\   HALF-THREE F.      => 1.5

INTEGER   \ switch back to integer mode for safety

.( Switched back to INTEGER mode. ) CR
.( Try: FLOATING before using fp numbers. ) CR


\ ===========================================================================
\ 8. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ NEEDS TESTING
\ FLOATING
\ T{  3.0 2.0 F+    -> (fp=5.0)   }T   \ manual check
\ T{  4.0 FSQRT     -> (fp=2.0)   }T
\ T{  -1.0 F0<      -> -1         }T
\ T{  42 FLOAT F>D  -> 42 0       }T
\ INTEGER
