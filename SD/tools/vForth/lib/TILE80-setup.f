\
\ TILE80-SETUP.f
\
\ MIT License (c) 1990-2025 Matteo Vitturi     
\
\ This must run with non-dot vForth version.
\
\ This script reads from ROM the standard character set and saves file
\ ./Layer3-charset-80.bin containing the bitmap definition 80 columns 

\ Tile grid is kept at $4000 (Tilemap Base Address)
\ 80 columns grid is 80*32*1 = 2560 = $0A00 in size and the Definition uses
\ 1-bit color, put charset at $5400-$5AFF, 1 bit remains 1 bit
\ Max 224 char defs available, we use the first 96.
\ Control chars (<$20) aren't stored.

MARKER FORGET-THIS-TASK
NEEDS PAD"
NEEDS SAVE-BYTES
NEEDS INVERT

\ ______________________________

CREATE UDGS HEX
    0000 , 0000 , 0000 , 0000 ,    
    0F0F , 0F0F , 0000 , 0000 ,    
    F0F0 , F0F0 , 0000 , 0000 ,    
    FFFF , FFFF , 0000 , 0000 ,    

    0000 , 0000 , 0F0F , 0F0F ,    
    0F0F , 0F0F , 0F0F , 0F0F ,    
    F0F0 , F0F0 , 0F0F , 0F0F ,    
    FFFF , FFFF , 0F0F , 0F0F ,    

    0000 , 0000 , F0F0 , F0F0 ,    
    0F0F , 0F0F , F0F0 , F0F0 ,    
    F0F0 , F0F0 , F0F0 , F0F0 ,    
    FFFF , FFFF , F0F0 , F0F0 ,    

    0000 , 0000 , FFFF , FFFF ,    
    0F0F , 0F0F , FFFF , FFFF ,    
    F0F0 , F0F0 , FFFF , FFFF ,    
    FFFF , FFFF , FFFF , FFFF ,    

\ 80 columns mode, 1-bit color
\ Copy charset to 5400-5AFF, 1 bit remains 1 bit
\ Max 224 char defs available, we use the first 96.
\ control chars aren't stored
\
: TILE-80-DEF
    $5C36 @ #256 +  \ printable only
    $5700  $5400 DO
        DUP C@        \ DUP 2/  OR
        I C!
        1+
    LOOP DROP
    UDGS $5700 #128 CMOVE  
    UDGS $5780 #128 CMOVE  
\   $5400 $5800 $0300 CMOVE \ duplicate printable
    $5700 $5400 DO
        I C@ \ INVERT 
        I $0400 + C!
    LOOP
;

\ ______________________________

NEEDS UNLINK
UNLINK C:LIB/TILE80-CHARSET.bin

PAD" ./LIB/TILE80-CHARSET.bin"


CLS
TILE-80-DEF
$5400 #224 8 * 
SAVE-BYTES

FORGET-THIS-TASK
QUIT
