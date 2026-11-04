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
\ String comparison uses COMPARE ( a1 c1 a2 c2 -- n ), a core word since
\ build 2026-10-28.  Up to then the core had only the primitive
\ (COMPARE) ( a1 a2 n -- b ), now a compatibility word in inc/.
\
\ PAD is a scratch buffer above the dictionary, used for temporary string
\ work.  Its address can move after ALLOT -- never store PAD across calls
\ that may modify the dictionary.
\
\ Coming from BASIC: Ch.2, 5, 7, 8, 11, 12  |  doc/basic-to-vforth/
\ Starting FORTH (Brodie): Ch.10  |  vForth screens 877-895
\ Reference: sec.2.12.6, 6.1
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   009 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 009 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 009: strings loaded. ) CR
.(     Type NEWTASK to unload.   ) CR


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
\ 5. String comparison: COMPARE
\ ===========================================================================
\
\ COMPARE ( a1 c1 a2 c2 -- n )
\   Core word.  Compares two addr/len strings byte by byte.
\   Returns:   0 if equal
\              1 if a1 c1 > a2 c2
\             -1 if a1 c1 < a2 c2
\
\ The first min(c1,c2) bytes decide.  When they all match, the shorter
\ string is the lesser: "zoo" comes before "zoology", as in a dictionary.
\ Case is ignored at start-up, as in dictionary search; CASEON makes it
\ count, CASEOFF goes back.
\
\ On a core older than build 2026-10-28, NEEDS COMPARE loads it from inc/.
\ The old primitive (COMPARE) ( a1 a2 n -- b ), one length for both
\ strings, survives as NEEDS (COMPARE).
\
\   CREATE S1  ," Hello!"
\   CREATE S2  ," Hello?"
\   S1 COUNT  S2 COUNT  COMPARE .        => -1        (! < ? in ASCII)
\   S1 COUNT  S1 COUNT  COMPARE .        => 0         (equal)
\   S1 COUNT  S1 COUNT 1-  COMPARE .     => 1         (longer is greater)

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
    COMPARE     ( n )
    0= ;        ( f )

: .COUNTED  ( addr -- )
    \ Print a counted string with a trailing CR.
    COUNT TYPE CR ;
CR
.( Try: GREETING .COUNTED                         ) CR
.( Try: S1 COUNT S2 COUNT SAME-STRING? .          ) CR
.( Try: S1 COUNT 1- S1 COUNT 1- SAME-STRING? .    ) CR
.( Try: S1 COUNT S2 COUNT COMPARE .              ) CR


\ ===========================================================================
\ 8. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ NEEDS TESTING  DECIMAL          \ lib/testing.f leaves BASE in HEX
\ T{  S1 COUNT S1 COUNT COMPARE  ->  0   }T
\ T{  S1 COUNT S2 COUNT COMPARE  ->  -1  }T   \ ! < ?
\ T{  S2 COUNT S1 COUNT COMPARE  ->  1   }T
\ T{  S1 COUNT S1 COUNT 1- COMPARE  ->  1   }T
\ T{  S1 COUNT S1 COUNT SAME-STRING?  -> -1  }T
\ T{  S1 COUNT S2 COUNT SAME-STRING?  ->  0  }T
