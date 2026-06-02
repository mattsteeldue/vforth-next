\
\ 023-structures.f
\ Data structures: +FIELD, ENUM, ENUMERATED, 2CONSTANT.
\
\ vForth provides lightweight tools for defining structured data and
\ named integer sets.  None are built into the core; all require NEEDS.
\
\   +FIELD      -- define a named offset within a record
\   ENUM        -- create an auto-incrementing constant generator
\   ENUMERATED  -- create n consecutive constants from 0
\   2CONSTANT   -- named 32-bit (double) constant
\
\ The idioms here work entirely at the Forth layer: no assembler or
\ special syntax.  Records are accessed through address arithmetic;
\ ENUM avoids repetitive CONSTANT definitions.
\
\ Reference: sec.2.12.12
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   023 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 023 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 023: structures loaded. ) CR
.(     Type NEWTASK to unload.   ) CR

NEEDS +FIELD
NEEDS ENUM
NEEDS ENUMERATED
NEEDS 2CONSTANT


\ ===========================================================================
\ 1. +FIELD  --  named record offsets
\ ===========================================================================
\
\ +FIELD ( n "name" -- )
\   Compiles a word that adds n bytes to an address, giving the address
\   of the named field.  Used with a running byte count:
\
\     0
\        2 CELLS +FIELD  pt.x    \ field at offset 0 (2 bytes)
\        2 CELLS +FIELD  pt.y    \ field at offset 2 (2 bytes)
\     CONSTANT POINT-SIZE        \ 4 = total size
\
\   Given an address a:
\     a pt.x  @     => fetch x
\     a pt.y  @     => fetch y
\     a pt.x  !     => store to x

0
    1 CELLS +FIELD  pt.x
    1 CELLS +FIELD  pt.y
CONSTANT POINT-SIZE

CREATE MY-POINT   POINT-SIZE ALLOT

.( POINT-SIZE = ) POINT-SIZE . CR   \ => 4

: INIT-POINT  ( x y addr -- )
    DUP  pt.y  !
         pt.x  ! ;

: .POINT  ( addr -- )
    DUP ." x=" pt.x @ .
        ." y=" pt.y @ . CR ;

10 20 MY-POINT  INIT-POINT
.( MY-POINT: ) MY-POINT .POINT   \ => x=10 y=20


\ ===========================================================================
\ 2. Nested structures
\ ===========================================================================
\
\ A line is a pair of points.  Build on the point layout:

0
    POINT-SIZE +FIELD  ln.a
    POINT-SIZE +FIELD  ln.b
CONSTANT LINE-SIZE

CREATE MY-LINE   LINE-SIZE ALLOT

 1  2  MY-LINE ln.a  INIT-POINT
 3  4  MY-LINE ln.b  INIT-POINT

.( MY-LINE: ) CR
.( A: ) MY-LINE ln.a .POINT
.( B: ) MY-LINE ln.b .POINT


\ ===========================================================================
\ 3. ENUM  --  auto-incrementing constants
\ ===========================================================================
\
\ ENUM name ( -- )
\   Creates a counter word name.  Each call to  name <word>  defines
\   <word> as a CONSTANT with the current counter value, then increments.
\
\   ENUM color
\    color BLACK    \ => CONSTANT BLACK = 0
\    color BLUE     \ => CONSTANT BLUE  = 1
\    color RED      \ => CONSTANT RED   = 2
\    ...

ENUM COLOR
    COLOR BLACK
    COLOR BLUE
    COLOR RED
    COLOR MAGENTA
    COLOR GREEN
    COLOR CYAN
    COLOR YELLOW
    COLOR WHITE

.( BLACK=) BLACK . .(  WHITE=) WHITE . CR   \ => 0  7


\ ===========================================================================
\ 4. ENUMERATED  --  bulk constant creation
\ ===========================================================================
\
\ ENUMERATED ( n -- )  creates the NEXT n tokens as consecutive constants.
\ The constants are named by the following words parsed from the input.
\
\ Equivalent to calling ENUM n times, but more concise:
\
\   8 ENUMERATED  MON TUE WED THU FRI SAT SUN   \ 0..6 (only 7 of 8 needed)

7 ENUMERATED  MON TUE WED THU FRI SAT SUN

.( MON=) MON . .(  FRI=) FRI . .(  SUN=) SUN . CR   \ => 0 4 6


\ ===========================================================================
\ 5. 2CONSTANT  --  named 32-bit constants
\ ===========================================================================
\
\ 2CONSTANT ( d -- )  defines a double constant.
\ When executed it pushes the stored double (lo hi) onto the stack.
\
\   $0000 $C000  2CONSTANT  LAYER2-BASE-D
\   LAYER2-BASE-D  D.    => 49152    ($C000 = 49152)
\
\ Useful for hardware addresses and values that exceed 16-bit range.

$A000     0  2CONSTANT  ROM-COPY-ADDR     \ example address as double
$0001 $0000  2CONSTANT  ONE-D

.( ONE-D: ) ONE-D D. CR    \ => 1


\ ===========================================================================
\ 6. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ NEEDS TESTING
\ T{  POINT-SIZE      -> 4      }T
\ T{  MY-POINT pt.x @ -> 10     }T
\ T{  MY-POINT pt.y @ -> 20     }T
\ T{  BLACK           -> 0      }T
\ T{  WHITE           -> 7      }T
\ T{  MON             -> 0      }T
\ T{  SUN             -> 6      }T
\ T{  ONE-D           -> 1 0    }T
