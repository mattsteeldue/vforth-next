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
\ Reference: sec.3
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

NEEDS SPEED!
NEEDS SPEED@
NEEDS ms


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
\ REG! and REG@ are core words: no NEEDS is required.
\
\ Example: read machine ID ($0A on a real ZX Next, $08 on emulators)
\   $00 REG@ .      \ prints 10 on the Next, 8 on CSpect
\
\ Example: write then read (round-trip test on reg $14, the global
\ transparency colour -- harmless, and restored at the end)
\   $14 REG@             \ save the current value (usually $E3)
\   $AA $14 REG!
\   $14 REG@ .           \ should print 170 ($AA)
\   $14 REG!             \ restore the saved value
\
\ Pick the register for such experiments with care: many registers
\ change the machine's configuration.  $05, for instance, holds the
\ joystick modes, 50/60 Hz and the scandoubler -- a wrong value there
\ can leave the display blank.

\ ===========================================================================
\ 2. Key Next register map
\ ===========================================================================
\
\ Reg $00 : Machine ID  (read-only)  $0A = ZX Next, $08 = emulators
\ Reg $01 : Core version major/minor (read-only)
\ Reg $03 : Machine type and timing
\ Reg $05 : Peripheral 1: joystick modes, 50/60 Hz, scandoubler
\ Reg $06 : Peripheral 2: F8/F3 keys, DivMMC, Multiface, PS/2, AY
\ Reg $07 : CPU speed
\            0 = 3.5 MHz  (original ZX Spectrum speed)
\            1 = 7.0 MHz
\            2 = 14.0 MHz
\            3 = 28.0 MHz  (maximum)
\ Reg $08 : Peripheral 3 register
\            bit 1 = enable Turbosound (AY Turbosound)
\ Reg $09 : Peripheral 4 register
\ Reg $0A : Mouse buttons and DPI config
\ Reg $0E : Core version sub-minor number (read-only)
\ Reg $10 : Anti-brick system / core boot (leave it alone)
\ Reg $11 : Video timing variant (0=VGA ... 7=HDMI)
\ Reg $12 : Layer 2 RAM bank (16K bank where the framebuffer begins)
\ Reg $14 : Global transparency color
\ Reg $15 : Sprite and layer control
\ Reg $17 : Layer 2 Y offset
\ Reg $22 : Line interrupt control
\ Reg $40 : Palette index
\ Reg $41 : Palette value (8-bit)
\ Reg $7F : 8-bit storage for the user (no hardware effect)
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


: .NEXT-INFO  ( -- )
    CLS
    ." ZX Next system information:" CR
    ." Machine ID  (reg $00): " $00 REG@ U. CR
    ." Core ver.   (reg $01): " $01 REG@ U. CR
    ." Core sub    (reg $0E): " $0E REG@ U. CR
    ." CPU speed   (reg $07): " $07 REG@ 3 AND U. CR
    ." Video timing(reg $11): " $11 REG@ 7 AND U. CR
    ." L2 RAM bank (reg $12): " $12 REG@ U. CR
    ." Trans. color(reg $14): " $14 REG@ U. CR
;

.( Try .NEXT-INFO )

\ ===========================================================================
\ 5. Demo: speed switching with timing measurement
\ ===========================================================================


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


\ ===========================================================================
\ 7. Demo: read/write round-trip test
\ ===========================================================================
\
\ Register $7F is 8-bit storage reserved for the user: readable and
\ writable, with no effect on the hardware, so it is the safe place
\ for a test pattern.  The following saves the current value, writes
\ a test pattern, reads it back, then restores the original.

: REG-ROUNDTRIP  ( -- )
    $7F REG@ >R               \ save current value
    $55 $7F REG!              \ write test pattern
    $7F REG@ ." Wrote $55, read: " U. CR
    $AA $7F REG!
    $7F REG@ ." Wrote $AA, read: " U. CR
    R> $7F REG!               \ restore
;


\ ===========================================================================
\ 8. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ NEEDS TESTING
\ T{  $00 REG@  ->  8  }T           \ machine ID: 8 on CSpect, 10 on Next
\ T{  0 SPEED!  SPEED@  ->  0  }T   \ set and read back
\ T{  2 SPEED!  SPEED@  ->  2  }T
\ T{  0 SPEED!  ->  }T              \ restore safe speed
