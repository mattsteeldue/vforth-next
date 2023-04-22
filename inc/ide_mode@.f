\
\ ide_mode@.f
\
.( IDE_MODE@ )
\
\ Query current NextBasic display mode
\ Returned registers 
\ reg a: current mode
\ reg b: character width in pixel
\ reg d: current paper (layer10 and layer2)
\ reg e: current ink (layer10 and layer2)
\
\               hl    de    bc   a 
\ _________________________________________________
\
\ LAYER0    : $1620 $000F $0800 $00 ( 00 00 00 00 )
\ LAYER10   : $0C20 $FF00 $0400 $01 ( 00 00 00 01 )
\ LAYER11   : $1840 $000F $0400 $05 ( 00 00 01 01 )
\ LAYER12   : $1840 $0000 $0800 $09 ( 00 00 10 01 )
\ LAYER13   : $1840 $0038 $0400 $0D ( 00 00 11 01 )
\ LAYER2    : $1840 $0038 $0400 $02 ( 00 00 00 10 ) 

BASE @

: IDE_MODE@ ( -- hl de bc a )      
    0 0 0 0
    [ HEX ] 01D5 M_P3DOS [ DECIMAL ]
    44 ?ERROR
;

BASE !
