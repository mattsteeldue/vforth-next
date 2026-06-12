\
\ 040-next-registers.f
\ ZX Next hardware registers (NextRegs): REG!, REG@, SPEED!.
\
\ The ZX Next extends the Z80 with a set of 256 hardware registers
\ accessible via two I/O ports: $243B (select) and $253B (data).
\ vForth provides REG! and REG@ for convenient access.  The CPU
\ clock speed is controlled via register $07 through the SPEED! and
\ SPEED@ wrapper words.
\
\ Reference: sec.8
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   040 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 040 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 040: ZX Next hardware registers loaded. ) CR
.(     Type NEWTASK to unload.                ) CR

NEEDS REG!
NEEDS REG@
NEEDS SPEED!
NEEDS SPEED@

\ ===========================================================================
\ 1. REG! and REG@ -- access Next registers
\ ===========================================================================
\
\   REG! ( value reg# -- )   write byte value to Next register reg#
\   REG@ ( reg# -- value )   read byte from Next register reg#
\
\ Hardware access sequence:
\   Write reg# to port $243B  (select register)
\   Write value to port $253B (write data)    -- for REG!
\   Read  value from port $253B               -- for REG@
\
\ Example: read machine ID (should return $08 for ZX Next)
\   HEX $00 REG@ .      \ should print 8
\
\ Example: write then read (round-trip test on reg $05, LED reg)
\   $AA $05 REG!
\   $05 REG@ .           \ should print AA

\ ===========================================================================
\ 2. Key Next register map
\ ===========================================================================
\
\ Reg $00 : Machine ID  (read-only)  $08 = ZX Next
\ Reg $01 : Core version hi byte    (read-only)
\ Reg $03 : Machine type / config   (read-only)
\ Reg $05 : Peripheral 1 register
\ Reg $06 : Peripheral 2 register
\ Reg $07 : CPU speed
\            0 = 3.5 MHz  (original ZX Spectrum speed)
\            1 = 7.0 MHz
\            2 = 14.0 MHz
\            3 = 28.0 MHz  (maximum)
\ Reg $08 : Peripheral 3 register
\            bit 1 = enable Turbosound (AY Turbosound)
\ Reg $09 : Peripheral 4 register
\ Reg $0A : Next version lo byte    (read-only)
\ Reg $10 : Palette index
\ Reg $11 : Palette value (8-bit)
\ Reg $12 : Layer 2 RAM page (base page for Layer2 frame buffer)
\ Reg $14 : Global transparency color
\ Reg $15 : Sprite and layer control
\ Reg $17 : Video timing (0=VGA 28MHz ... 7=Digital 27MHz)
\ Reg $22 : LoRes control
\ Reg $40 : Palette index (second register)
\ Reg $69 : Display control 1 (Layer2 enable, Timex mode, etc.)
\ Reg $70 : Layer2 control (256-color mode, IIGS etc.)

\ ===========================================================================
\ 3. SPEED! and SPEED@ -- CPU clock speed
\ ===========================================================================
\
\   SPEED! ( n -- )  set CPU speed 0=3.5MHz 1=7MHz 2=14MHz 3=28MHz
\   SPEED@ ( -- n )  return current CPU speed 0-3
\
\ Both words use Next register $07.
\ SPEED! masks n with 3 before writing.
\ SPEED@ reads the register and masks with 3.
\
\ Example: switch to maximum speed
\   3 SPEED!
\   \ ... do fast work ...
\   0 SPEED!        \ restore to 3.5 MHz for compatibility

\ ===========================================================================
\ 4. Demo: read and display system information
\ ===========================================================================

HEX

: .NEXT-INFO  ( -- )
    CLS
    ." ZX Next system information:" CR
    ." Machine ID  (reg $00): " $00 REG@ U. CR
    ." Core hi     (reg $01): " $01 REG@ U. CR
    ." Core lo     (reg $0A): " $0A REG@ U. CR
    ." CPU speed   (reg $07): " $07 REG@ 3 AND U. CR
    ." Video timing(reg $17): " $17 REG@ 7 AND U. CR
    ." L2 RAM page (reg $12): " $12 REG@ U. CR
    ." Trans. color(reg $14): " $14 REG@ U. CR
;

DECIMAL

\ ===========================================================================
\ 5. Demo: speed switching with timing measurement
\ ===========================================================================

NEEDS ms

: SPEED-DEMO  ( -- )
    ." Current speed: " SPEED@ . CR
    ." Switching to 28 MHz..." CR
    3 SPEED!
    ." Now at: " SPEED@ . CR
    500 ms
    ." Restoring 3.5 MHz..." CR
    0 SPEED!
    ." Now at: " SPEED@ . CR
;

\ ===========================================================================
\ 6. Demo: safe register modify (read-modify-write)
\ ===========================================================================
\
\ Many Next registers have multiple bit-fields.  Use a
\ read-modify-write pattern to change only the bits you need.
\
\ Example: enable Turbosound (bit 1 of reg $08) without
\ affecting other bits:

HEX
: ENABLE-TURBOSOUND  ( -- )
    $08 REG@          \ read current value
    %00000010 OR      \ set bit 1
    $08 REG!          \ write back
;

: DISABLE-TURBOSOUND  ( -- )
    $08 REG@
    %11111101 AND     \ clear bit 1
    $08 REG!
;
DECIMAL

\ ===========================================================================
\ 7. Demo: read/write round-trip test
\ ===========================================================================
\
\ Peripheral 2 register ($06) is readable/writable.  The following
\ saves the current value, writes a test pattern, reads it back,
\ then restores the original.

HEX
: REG-ROUNDTRIP  ( -- )
    $06 REG@ >R               \ save current value
    $55 $06 REG!              \ write test pattern
    $06 REG@ ." Wrote $55, read: " U. CR
    $AA $06 REG!
    $06 REG@ ." Wrote $AA, read: " U. CR
    R> $06 REG!               \ restore
;
DECIMAL

\ ===========================================================================
\ 8. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ NEEDS TESTING
\ T{  $00 REG@  ->  8  }T           \ machine ID should be 8
\ T{  0 SPEED!  0 SPEED@  ->  0  }T \ set and read back
\ T{  2 SPEED!  2 SPEED@  ->  2  }T
\ T{  0 SPEED!  ->  }T              \ restore safe speed
