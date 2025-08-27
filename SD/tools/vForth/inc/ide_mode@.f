\
\ ide_mode@.f
\
.( IDE_MODE@ )

: IDE_MODE@ ( -- hl de bc a )      
    0 0 0 0
    $01D5 M_P3DOS 
    #44 ?ERROR
;

\ ____________________________________________________________________
\
\ Query current NextBasic display mode
\ Returned registers 
\ reg a: current mode
\ reg b: character width in pixel
\ reg c: flagbits: 0:reduced-height, 4:double-width, 5:double-height
\ reg d: current paper (layer10 and layer2)
\ reg e: current attribtutes (layer0, layer11, layer13) or ink (layer10, layer2)
\ reg h: printable lines on screen
\ reg l: printable columns on screen
\
\               hl    de    bc   a    bits of a
\ _________________________________________________
\
\ LAYER0    : $1620 $000F $0800 $00 ( 00 00 00 00 )
\ LAYER10   : $0C20 $010E $0400 $01 ( 00 00 00 01 )
\ LAYER11   : $1840 $000E $0400 $05 ( 00 00 01 01 )
\ LAYER12   : $1840 $0000 $0800 $09 ( 00 00 10 01 )
\ LAYER13   : $1840 $000E $0400 $0D ( 00 00 11 01 )
\ LAYER2    : $1840 $02D8 $0400 $02 ( 00 00 00 10 ) 
\ ____________________________________________________________________
