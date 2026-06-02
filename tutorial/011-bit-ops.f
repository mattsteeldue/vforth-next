\
\ 011-bit-ops.f
\ Bitwise operations: AND OR XOR INVERT LSHIFT RSHIFT SPLIT FLIP.
\
\ The Z80 has an 8-bit ALU; vForth cells are 16 bits.  All bitwise
\ words operate on all 16 bits simultaneously.  Bit 0 is the least-
\ significant (weight 1); bit 15 the most-significant (weight $8000).
\ Negative integers use two's-complement: -1 = $FFFF (all bits set).
\
\ Bitwise operations are the primary tool for:
\   - testing, setting, clearing, and toggling individual bits
\   - packing flag sets into a single cell
\   - manipulating ZX Spectrum Next hardware registers and I/O ports
\
\ LSHIFT and RSHIFT are in the core; they don't require NEEDS.  For a
\ single-position shift, prefer the core primitives 2* (left) and
\ 2/ (arithmetic right).
\
\ Reference: sec.2.12.3
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   011 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 011 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 011: bit operations loaded. ) CR
.(     Type NEWTASK to unload.          ) CR

NEEDS INVERT
NEEDS SPLIT
NEEDS FLIP
NEEDS NOT

\ ===========================================================================
\ 1. AND, OR, XOR  --  core bitwise words
\ ===========================================================================
\
\ AND  ( n1 n2 -- n3 )   bit set only if both inputs have it
\ OR   ( n1 n2 -- n3 )   bit set if either input has it
\ XOR  ( n1 n2 -- n3 )   bit set if exactly one input has it
\
\   %1010 %1100 AND .   => 8     (%1000)
\   %1010 %1100 OR  .   => 14    (%1110)
\   %1010 %1100 XOR .   => 6     (%0110)
\
\ Idioms:
\   mask AND  -- test or clear bits  (0 in mask clears; 1 passes through)
\   mask OR   -- set bits            (1 in mask forces bit on)
\   mask XOR  -- toggle bits         (1 in mask flips; 0 leaves unchanged)


\ ===========================================================================
\ 2. INVERT  --  bitwise NOT
\ ===========================================================================
\
\ INVERT ( n -- n' )   flip all 16 bits.  Equivalent to $FFFF XOR.
\
\   0     INVERT .   => -1    ($FFFF  --  all bits set)
\   $FF   INVERT .   => -256  ($FF00)
\   $8000 INVERT .   => 32767 ($7FFF)
\
\ INVERT turns a bit mask into its complement; used to clear bits:
\   value  mask INVERT AND   -- clear the bits set in mask
\ You have to import via  NEEDS INVERT  before using.


\ ===========================================================================
\ 3. LSHIFT and RSHIFT  --  logical shifts
\ ===========================================================================
\
\ LSHIFT ( n u -- n' )   shift n left  by u bits; vacated bits = 0
\ RSHIFT ( n u -- n' )   shift n right by u bits; vacated bits = 0
\
\ RSHIFT is *logical* (fills with 0).  2/ is *arithmetic* (sign-extends).
\
\   1    4  LSHIFT .   => 16     (2^4)
\   $FF  4  RSHIFT .   => 15     ($0F)
\   $80  1  RSHIFT .   => 64     ($40 -- logical, not $C0)
\
\ For a single-position shift, prefer 2* and 2/ (faster, no NEEDS):
\   n 2*   is faster than   n 1 LSHIFT


\ ===========================================================================
\ 4. Extracting and inserting bit fields
\ ===========================================================================
\
\ Extract bits 5-3 (a 3-bit field) from a value:
\   value  3 RSHIFT  %111 AND
\
\ Insert value v into bits 5-3 of n (field already 0):
\   n  v 3 LSHIFT OR
\
\ Example: ZX Spectrum attribute byte (paper in bits 5-3, ink in bits 2-0)
\   5 3 LSHIFT  2 OR  .   => 42   (%00101010 : paper=5 cyan, ink=2 red)
\   42 3 RSHIFT %111 AND . => 5   (extract paper color)
\   42           %111 AND . => 2   (extract ink color)


\ ===========================================================================
\ 5. Named bit masks  --  the idiomatic approach
\ ===========================================================================
\
\ Avoid magic numbers in hardware code.  Define a CONSTANT for each bit.

$0001 CONSTANT BIT0
$0002 CONSTANT BIT1
$0004 CONSTANT BIT2
$0008 CONSTANT BIT3
$0010 CONSTANT BIT4
$0020 CONSTANT BIT5
$0040 CONSTANT BIT6
$0080 CONSTANT BIT7


\ ===========================================================================
\ 6. Demonstration words
\ ===========================================================================

: BIT-SET?  ( n bit -- f )
    \ True if the given bit position is set in n.
    AND IF -1 ELSE 0 THEN ;

: BIT-SET   ( n bit -- n' )
    OR ;

: BIT-CLEAR  ( n bit -- n' )
    \ Clear the given bit in n.
    INVERT AND ;

: BIT-TOGGLE  ( n bit -- n' )
    XOR ;

: .BITS  ( n -- )
    \ Print n as 16 binary digits, MSB first.
    16 0 DO
        DUP $8000 AND IF  [CHAR] 1  ELSE  [CHAR] 0  THEN  EMIT
        2*
    LOOP  DROP  CR ;

.( Try: $41   BIT0 BIT-SET?  .    ) CR
.( Try: $40   BIT0 BIT-SET   U.   ) CR
.( Try: $41   BIT0 BIT-CLEAR U.   ) CR
.( Try: $1234 .BITS                ) CR


\ ===========================================================================
\ 7. SPLIT and FLIP  --  operating on individual bytes
\ ===========================================================================
\
\ SPLIT ( n -- lo hi )   split n into its low byte (lo) and high byte (hi)
\ FLIP  ( n -- n' )      swap the low byte and high byte of n
\
\ Both live in inc/ and need NEEDS before use.
\
\   $1234 SPLIT . .    => 18 52    (hi=$12=18 is TOS; lo=$34=52 below)
\   $1234 FLIP  .      => $3412
\
\ When lo and hi come from SPLIT they are in 0-255 range, so FLIP
\ reassembles the original cell in one step (no 8 LSHIFT OR needed):
\   $1234 SPLIT FLIP .   => $1234
\
\ Note: FLIP works as a reassembler only for byte values (0-255).
\ For a general 8-bit field not obtained via SPLIT, use 8 LSHIFT OR.
\
\ Practical use: when a 16-bit value holds two 8-bit fields, SPLIT decodes
\ both in one step without manual masking:
\   $2B5F SPLIT   ( lo=$5F  hi=$2B )
\
\ FLIP converts between big-endian and little-endian byte order:
\   $4142 FLIP .   => $4241    ('AB' swapped to 'BA')

: .LO-HI  ( n -- )
    \ Print high and low bytes of n on separate lines.
    SPLIT
    ." hi=" . CR
    ." lo=" . CR ;

: LO-ZERO?  ( n -- f )
    \ True if the low byte of n is zero.
    SPLIT DROP NOT ;

.( Try: $1234 SPLIT . .      ) CR
.( Try: $1234 FLIP  .        ) CR
.( Try: $A05F .LO-HI         ) CR
.( Try: $1200 LO-ZERO?  .    ) CR
.( Try: $1234 LO-ZERO?  .    ) CR


\ ===========================================================================
\ 8. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ NEEDS TESTING
\ T{  %1010 %1100 AND    -> %1000         }T
\ T{  %1010 %1100 OR     -> %1110         }T
\ T{  %1010 %1100 XOR    -> %0110         }T
\ T{  0 INVERT           -> -1            }T
\ T{  1 4 LSHIFT         -> 16            }T
\ T{  $FF 4 RSHIFT       -> $0F           }T
\ T{  $41 BIT0 BIT-SET?  -> -1            }T
\ T{  $41 BIT1 BIT-SET?  -> 0             }T
\ T{  $40 BIT0 BIT-SET   -> $41           }T
\ T{  $41 BIT0 BIT-CLEAR -> $40           }T
\ T{  $41 BIT0 BIT-TOGGLE -> $40          }T
\ T{  $40 BIT0 BIT-TOGGLE -> $41          }T
\ T{  $1234 SPLIT  ->  $34 $12  }T
\ T{  $00FF SPLIT  ->  $FF 0    }T
\ T{  $1234 FLIP   ->  $3412    }T
\ T{  $FF00 FLIP   ->  $00FF    }T
