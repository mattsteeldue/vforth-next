\
\ 014-pictured-output.f
\ Formatted numeric output: <# # #S HOLD SIGN #>.
\
\ The pictured numeric output words build a formatted number string
\ right-to-left in an internal scratch area, i.e. PAD.  The process:
\
\   1.  <#          begin; the scratch area PAD is reset
\   2.  # or #S     convert digits (least significant first)
\   3.  HOLD        insert literal characters (e.g., '$', '.')
\   4.  SIGN        insert '-' if sign argument is negative
\   5.  #>          end; return address and length of the result
\
\ These words work on unsigned double-precision numbers (ud).  To
\ format a single-cell integer, convert it first: for unsigned values
\ use 0 (zero) as the high cell; for signed, use NEEDS S>D which
\ sign-extends to a double.
\
\ Example pattern for a signed integer:
\   n DUP ABS  0  <# #S  ROT SIGN  #>  TYPE
\     (dup for sign, absolute value, zero-extend, convert, add sign)
\
\ Reference: sec.2.12.5
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   014 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 014 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 014: pictured output loaded. ) CR
.(     Type NEWTASK to unload.   ) CR

NEEDS S>D


\ ===========================================================================
\ 1. The building blocks
\ ===========================================================================
\
\ <# ( -- )       begin pictured numeric output
\ # ( ud -- ud' ) extract one digit; inserts it into the output string
\ #S ( ud -- 0. ) extract all remaining digits (until double is zero)
\ HOLD ( c -- )   insert character c into the output string
\ SIGN ( n -- )   insert '-' if n is negative; nothing if positive
\ #> ( xd -- addr len )  end; addr and len of the built string
\
\ The result of #> is a transient string in an internal buffer.
\ Consume it (e.g., with TYPE) before calling <# again.
\
\   255  0  <# #S #>  TYPE CR     => 255    (format unsigned double)
\   $41  0  <# #S [CHAR] $ HOLD #>  TYPE CR => $41   (hex with $)


\ ===========================================================================
\ 2. Formatting unsigned hex numbers
\ ===========================================================================
\
\ To print an unsigned single in a specific base, set BASE, use S>D
\ or 0 as the high word, then build.  Reset BASE before TYPE.

: .HEX4  ( u -- )
    \ Print u as exactly 4 hex digits with a leading $.
    HEX
    0  <#  #  #  #  #  [CHAR] $ HOLD  #>
    DECIMAL  TYPE  CR ;

: .HEX2  ( u -- )
    \ Print the low byte of u as exactly 2 hex digits.
    $FF AND  HEX
    0  <#  #  #  [CHAR] $ HOLD  #>
    DECIMAL  TYPE  CR ;

.( Try: $1234 .HEX4  ) CR    \ => $1234
.( Try: $41   .HEX2  ) CR    \ => $41


\ ===========================================================================
\ 3. Formatting signed integers
\ ===========================================================================
\
\ SIGN inserts '-' if its argument is negative; nothing otherwise.
\ The pattern:  n DUP ABS S>D <# #S ROT SIGN #>
\   - DUP saves the sign
\   - ABS takes the absolute value
\   - S>D converts to double for <# #S
\   - ROT brings the saved sign to TOS for SIGN

: .SIGNED  ( n -- )
    \ Print a signed integer.
    DUP ABS  S>D  <# #S  ROT SIGN  #>  TYPE  CR ;

.( Try: -42 .SIGNED  ) CR    \ => -42
.( Try: 100 .SIGNED  ) CR    \ => 100


\ ===========================================================================
\ 4. Right-aligned in a field width
\ ===========================================================================
\
\ To right-align in a field of w characters, pad with spaces on the left.
\ HOLD inserts characters from the RIGHT; inserting leading spaces must
\ be done at the end (they are LAST in the build order but appear first
\ in the result):

: .RIGHT  ( n w -- )
    \ Print n right-aligned in a field w characters wide.
    SWAP  S>D  <# #S  #>     ( w addr len )
    ROT  OVER  -              ( addr len pad )
    0 MAX  SPACES             ( addr len )
    TYPE ;

.( Try: 42    6 .RIGHT   ) CR   \ =>     42
.( Try: -1234 8 .RIGHT   ) CR   \ =>    -1234


\ ===========================================================================
\ 5. Decimal point insertion
\ ===========================================================================
\
\ HOLD can insert any character, including a decimal point.  To format
\ a fixed-point value (e.g., n represents n/100):
\
\   : .CENTS  ( n -- )    \ n is whole-cents value, display as pounds.pp
\       S>D  <#  #  #  [CHAR] . HOLD  #S  #>  TYPE  CR ;
\
\   1234 .CENTS     => 12.34
\   7    .CENTS     => 0.07

: .CENTS  ( n -- )
    \ Display n as a decimal with 2 decimal places (n = value * 100).
    S>D  <#  #  #  [CHAR] . HOLD  #S  #>  TYPE  CR ;

.( Try: 1234 .CENTS  ) CR    \ => 12.34
.( Try:    7 .CENTS  ) CR    \ => 0.07


\ ===========================================================================
\ 6. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ (Pictured output builds strings; tests check the string length/content
\ indirectly via TYPE to the output stream.)
\
\ NEEDS TESTING
\ T{  255 0 <# #S #>  NIP  -> 3    }T   \ "255" is 3 chars long
\ T{  0   0 <# #S #>  NIP  -> 1    }T   \ "0" is 1 char
\ T{  $FF 0 HEX <# # # #> DECIMAL NIP -> 2 }T
