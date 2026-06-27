\
\ l2-ram-page.f
\
\ Layer 2 active RAM page: the first 8K MMU7 page of the Layer 2
\ framebuffer, computed once at load time from NextReg $12 (the Layer 2
\ RAM bank, expressed in 16K units; one 16K bank = two 8K MMU7 pages).
\ Shared by LAYER2-GRAPHICS (256x192) and LAYER22-GRAPHICS (320x256).
\
.( L2-RAM-PAGE )

BASE @  HEX
    12 REG@ 2*  CONSTANT  L2-RAM-PAGE
BASE !
