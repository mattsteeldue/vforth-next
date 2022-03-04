( ZX-Next Copper )

NEEDS COPPER

( ZX-Next Copper - Example )
NEEDS LAYERS

COP-STOP
  HEX
  00   00    COP-WAIT   \ Wait for scan-line 0, pos 0
  08   16    COP-MOVE   \ Shift 2 pixel in Layer2 Horizontal Scroll (16h)
  60   00    COP-WAIT   \ Wait for scan-line 96 = 60h
  00   16    COP-MOVE   \ Shift 0 pixel in Layer2 Horizontal Scroll (16h)
             COP-HALT

LAYER2
DECIMAL 11 LIST
COP-START

