\
\ 009-strings.f
\ String and memory operations: moving, filling, and comparing byte arrays.
\
\ In vForth, as in all Forth systems, a "string" is simply a region of
\ memory described by an address and a length.  There is no special string
\ type.  The two common conventions are:
\
\   addr len      -- address/length pair on the stack (ANS style)
\   addr          -- counted string: length byte at addr, text from addr+1
\
\ COUNT ( addr -- addr+1 len ) converts a counted string to addr/len form.
\ Most output and comparison words expect addr/len.
\
\ String comparison uses the core primitive (COMPARE) rather than the
\ higher-level COMPARE word (which requires NEEDS and has a different
\ stack signature).  (COMPARE) is the raw primitive: ( a1 a2 n -- b ).
\
\ PAD is a scratch buffer above the dictionary, used for temporary string
\ work.  Its address can move after ALLOT -- never store PAD across calls
\ that may modify the dictionary.
\
\ Reference: sec.2.12.6, 3.4
\
\ Load from a clean session:
\   INCLUDE tutorial/009-strings.f
\ To unload and reload interactively:
\   NO-STRINGS
\   INCLUDE tutorial/009-strings.f
\

MARKER NO-STRINGS

CR
.( --- Tutorial 009: strings loaded. ) CR
.(     Type NO-STRINGS to unload.   ) CR


\ ===========================================================================
\ 1. FILL, ERASE, BLANK
\ ===========================================================================
\
\ FILL  ( addr n c -- )   store byte c into n bytes starting at addr
\ ERASE ( addr n -- )     store 0 into n bytes  (equivalent to 0 FILL)
\ BLANK ( addr n -- )     store BL (space, $20) into n bytes
\
\   CREATE BUF  16 ALLOT
\
\   BUF 16 ERASE            ( zero all 16 bytes )
\   BUF 16 $41 FILL         ( fill with 'A' )
\   BUF 16 BLANK            ( fill with spaces )
\
\ FILL is the general primitive; ERASE and BLANK are convenience wrappers.
\ Use ERASE to initialise buffers; use BLANK to pad text fields.

CREATE BUF1  16 ALLOT
BUF1 16 BLANK


\ ===========================================================================
\ 2. CMOVE and CMOVE>
\ ===========================================================================
\
\ CMOVE  ( src dst n -- )   copy n bytes from src to dst, low-to-high
\ CMOVE> ( src dst n -- )   copy n bytes from src to dst, high-to-low
\
\ The direction matters only when source and destination overlap:
\
\   CMOVE  -- safe when dst < src (or no overlap); copies forward.
\   CMOVE> -- safe when dst > src (overlapping, move right); copies backward.
\
\ Non-overlapping example:
\   CREATE SRC  ," Hello"     ( counted string: len byte + 5 chars )
\   CREATE DST  6 ALLOT
\   SRC 1+  DST  5  CMOVE    ( copy 5 chars, skip the count byte )
\   DST 5 TYPE               => Hello
\
\ Overlapping: insert a byte by shifting right
\   BUF1 1+ BUF1  n  CMOVE>  ( shift n bytes one position right in BUF1 )

CREATE SRC1  ," Hello"
CREATE DST1  6 ALLOT
SRC1 1+  DST1  5  CMOVE


\ ===========================================================================
\ 3. Counted strings, COUNT, and ,"
\ ===========================================================================
\
\ COUNT ( addr -- addr+1 len )
\   Splits a counted string into text address and length.
\   The length byte at addr is not included in the returned region.
\
\ ," ( -- )   compile-time: read text up to the closing " and store it
\   as a counted-z-string at HERE: one length byte, the text bytes, and
\   a trailing null byte ($00).  The null is intentional -- it makes the
\   string directly compatible with NextZXOS API calls that expect a
\   C-style zero-terminated string, while the length byte keeps it a
\   valid Forth counted string.  This is a deliberate vForth extension
\   for improved host OS compatibility.
\
\   CREATE GREETING  ," Hello, vForth!"
\   GREETING COUNT TYPE CR    => Hello, vForth!
\   GREETING C@ .             => 14   (length byte)
\   GREETING 15 + C@ .        => 0    (trailing null byte)

CREATE GREETING  ," Hello, vForth!"


\ ===========================================================================
\ 4. TYPE and -TRAILING
\ ===========================================================================
\
\ TYPE ( addr len -- )   emit len characters from addr
\
\ -TRAILING ( addr len -- addr len' )
\   Reduce len to strip trailing spaces.
\   Useful before TYPE when a fixed-length field may be blank-padded.
\
\   CREATE PADDED  ," Hello   "    ( 8 chars, 3 trailing spaces )
\   PADDED COUNT -TRAILING TYPE CR => Hello

CREATE PADDED  ," Hello   "


\ ===========================================================================
\ 5. String comparison: (COMPARE)
\ ===========================================================================
\
\ (COMPARE) ( a1 a2 n -- b )
\   Core primitive.  Compares n bytes at a1 with n bytes at a2.
\   Returns:  0 if equal
\             positive if a1 > a2
\             negative if a1 < a2
\
\ Note: (COMPARE) takes two addresses and a *single* length -- both strings
\ must have the same length.  For strings of different lengths, compare the
\ shorter length first; if equal, the longer one is "greater".
\
\ The higher-level COMPARE ( a1 b1 a2 b2 -- n ) handles unequal lengths
\ and returns -1/0/1, but requires NEEDS COMPARE (loads from inc/).
\
\   CREATE S1  ," Hello!"
\   CREATE S2  ," Hello?"
\   S1 1+  S2 1+  S1 C@  (COMPARE) .    => negative  (! < ? in ASCII)
\   S1 1+  S1 1+  S1 C@  (COMPARE) .    => 0          (equal)

CREATE S1  ," Hello!"
CREATE S2  ," Hello?"


\ ===========================================================================
\ 6. PAD as a scratch buffer
\ ===========================================================================
\
\ PAD ( -- addr )   address of the scratch string buffer above the dictionary.
\
\ PAD is guaranteed to be at least 84 bytes and to be cell-aligned.
\ It is volatile: any word that calls WORD or modifies the dictionary may
\ overwrite it.  Always consume PAD contents before the next dictionary op.
\
\   GREETING COUNT  PAD SWAP  CMOVE    ( copy greeting text to PAD )
\   PAD GREETING C@ TYPE CR            => Hello, vForth!


\ ===========================================================================
\ 7. Demonstration words
\ ===========================================================================

: COPY-STRING  ( src-addr src-len dst-addr -- )
    \ Copy an addr/len string to dst-addr (no count byte written).
    SWAP CMOVE ;

: SAME-STRING?  ( a1 n1 a2 n2 -- f )
    \ Return true (-1) if two addr/len strings are identical.
    ROT         ( a1 a2 n2 n1 )
    OVER        ( a1 a2 n2 n1 n2 )
    <> IF       ( a1 a2 n2 )
        2DROP   ( a1 )
        DROP    ( )
        0       ( ff )
    ELSE        ( a1 a2 n2 )
        (COMPARE)   ( b )
        0=          ( tf )
    THEN ;

: .COUNTED  ( addr -- )
    \ Print a counted string with a trailing CR.
    COUNT TYPE CR ;

.( Try: GREETING .COUNTED                         ) CR
.( Try: S1 COUNT S2 COUNT SAME-STRING? .          ) CR
.( Try: S1 COUNT S1 COUNT SAME-STRING? .          ) CR
." Try: S1 1+  S2 1+  S1 C@  (COMPARE) .          " CR


\ ===========================================================================
\ 8. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ NEEDS TESTING
\ T{  S1 1+ S1 1+ S1 C@ (COMPARE)  ->  0   }T
\ T{  S1 1+ S2 1+ S1 C@ (COMPARE)  ->  -1  }T   \ ! < ?
\ T{  S2 1+ S1 1+ S1 C@ (COMPARE)  ->  1   }T
\ T{  S1 COUNT S1 COUNT SAME-STRING?  -> -1  }T
\ T{  S1 COUNT S2 COUNT SAME-STRING?  ->  0  }T
