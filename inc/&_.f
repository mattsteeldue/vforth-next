\
\ &.4.f
\
.( *.4 )
\

\ Geometrical approach.
\ We want to multiply two fixed-point values with 12 bits of integer part and 4 fractional (12:4)
\ Before computing x*y, add $8000 to both factors then multiply them as unsigned.
\ That is: (x + $8000)*(y + $8000) = x*y + (x+y)*$8000 + $40000000.
\ Multiplying two (12:4) numbers yelds a (24:8) that needs a final >>4 to scale to get 12:4 again
\ and all this happens MOD $10000, then the big $40000000 can be ignored.
\ So we have to subtract a (x+y)$8000 from the result before the final >>4.
\ ... or a (x+y)$08000 after the final >>4 scaling.
\ this is 


( Product routine for 12:4 fixed point )
needs assembler
code *_     ( n1 n2 -- n3 )
    exx
    pop     de|              \  de <- ABC.D
    pop     hl|              \  hl <- abc.d

    ldx     bc|  $8000 NN,
    addhl   bc|              \ x+$8000
    exdehl
    addhl   bc|              \ y+$8000
\
    ld      b'|  h|          
    ld      c'|  l|
    addhl   de|
    push    hl|              \ save x+y for later, the two $8000 cancel out.
    ld      h'|  b|
    ld      l'|  c|
\ Unsigned product uses the following concept:
\    HL  *
\    DE  =
\  -----   
\    Yy        Yy        Yy := E*L   
\   Ww      sT t        Ww  := E*H    sTt := Ww+Xx   
\   Xx    --------      Xx  := D*L     rq := t+Y   
\  Zz        r qy      Zz   := D*H     Uu := Zz+sT+r
\ ------    Zz         
\  Uuqy                
\                           \   cf  a  hl  de  bc    tos
                            \   --  -  --  --  --    ---
    ld      b'|  l|         \          HL  DE  L       
    ld      c'|  e|         \          H.  D.  LE      
    ld      e'|  l|         \          H.  DL  LE      
    ld      l'|  d|         \          HD  DL  LE      
    push    hl|             \          ..  DL  LE    HD
    ld      l'|  c|         \          HE  DL  LE    HD
    mul                     \          HE  Xx  LE    HD
    exdehl                  \          Xx  HE  LE    HD
    mul                     \          Xx  Ww  LE    HD
    xora     a|             \       0  Xx  Ww  LE    HD
    addhl   de|             \    s  0  Tt  ..  LE    HD
    adca     a|             \    .  s  Tt      LE    HD
    ld      e'|  c|         \       s  Tt   E  L.    HD
    ld      d'|  b|         \       s  Tt  LE  .     HD
    mul                     \       s  Tt  Yy        HD
    ld      b'|  a|         \       .  Tt  Yy  s     HD
    ld      c'|  h|         \          .t  Yy  sT    HD
    ld      a'|  d|         \       Y   t  .y  sT    HD
    adda     l|             \    r  q   .   y  sT    HD
    ld      h'|  a|         \    r  .  q.   y  sT    HD
    ld      l'|  e|         \    r     qy   .  sT    HD
    pop     de|             \    r     qy  HD  sT      
    mul                     \    r     qy  Zz  sT      
    exdehl                  \    r     Zz  qy  sT      
    adchl   bc|             \    .     Uu  qy  ..      
\
\ scale HLDE from 24:8 to 12:4
    ldn     b'|  4 N,
    bsrlde,b
    exdehl
    bslade,b
    ld      a'|  h|
    ora      e|
    ld      h'|  a|
\
\ final subtract (x+y) * $0800  by shifting 11 places.
    pop     de|
    ldn     b'|  11 N,
    bslade,b
    sbchl   de|
\
    push    hl|
    exx
    jpix
    c;

