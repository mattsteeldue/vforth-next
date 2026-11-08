\
\ lib/ZAP~.f
\

.( ZAP" )

\ Save a single .nex file for standalone execution, without vForth
\ itself: it starts from the NextZXOS Browser (or .nexload), with no
\ BASIC loader and no addresses to keep aligned.

\ Usage:
\ ' cccc  ZAP" filename.nex"

\ Example:
\ INCLUDE DEMO/CHOMP-CHOMP.F
\ NEEDS ZAP"
\ ' GAME  ZAP" chomp-chomp.nex"
\
\ The extension is not added: write it.  The image is prepared as ZAP
\ does (lib/ZAP.f, loaded first): it boots straight into cccc, it leaves
\ through BYE at the end of cccc and on any error, it is saved with
\ WARNING at 0, and it is the dictionary as it was just before NEEDS ZAP,
\ so NEEDS ZAP" must come last.  The live session is left as it was.
\
\ The file holds the 16K banks 5, 2 and 0 (screen, system variables,
\ dictionary, user area and buffers), the heap banks HP has reached
\ (16 and up), and any bank added with  n NEX-BANK  before ZAP" (e.g. the
\ data bank 19 of chomp-chomp).  Banks are numbered as BASIC does.
\
\ There is no BASIC to go back to: BYE ends in a soft reset of the Next.
\ The 16 bytes just below ORIGIN, unused by the core, hold the entry
\ stub (IY to the system variables, then ORIGIN, i.e. a COLD start) and
\ the address BYE returns to, through the SP of the .nex header, where
\ NEXTREG 2,1 resets the machine.
\
\ Error #67 "defined after NEEDS ZAP": the word would not be in the image.
\ Error #14 "Patching the wrong definition": as for ZAP.
\ Error #10 "Wrong array index": NEX-BANK takes 0 to 111.
\ Error -18 "Parsed string overflow": the file name is over 47 chars.

\ it sets the marker NO-ZAP: ZAP" is out of the image too
NEEDS ZAP

BASE @

DECIMAL

\ ________________________________________________________________________

\ 512 bytes header (https://wiki.specnext.dev/NEX_file_format)
CREATE NEX-HEADER 512 ALLOT

\ address of offset u inside NEX-HEADER
: +HEADER ( u -- a )
    NEX-HEADER +
;

\ file-handle of the .nex being written
VARIABLE NEX-FH

\ include the 16K bank n in the .nex
: NEX-BANK ( n -- )
    111 OVER U< 10 ?ERROR
    1 SWAP 18 + +HEADER C!
;


\ the 8K pages a vForth session sees at $4000-$DFFF: banks 5, 2 and the
\ first half of 0.  They are written from there, the others through MMU7.
CREATE LOW-PAGES  $0A C, $0B C, $04 C, $05 C, $00 C,

\ address at which 8K page p can be read, mapping it in MMU7 if needed
: PAGE-AT ( p -- a )
    $E000 SWAP                  \ a p
    5 0 DO
        DUP LOW-PAGES I + C@ = IF
            NIP I 13 LSHIFT $4000 + SWAP
        THEN
    LOOP                        \ a p
    OVER $E000 = IF
        MMU7!
    ELSE
        DROP
    THEN
;

\ write 8K page p, return the error flag only
: WRITE-PAGE ( p -- f )
    PAGE-AT 8192 NEX-FH @ WRITE
;


\ order of the bank data in the file: 5,2,0,1,3,4, then 6,7,8,...,111
CREATE NEX-FIRST  5 C, 2 C, 0 C, 1 C, 3 C, 4 C,

: NEX-ORDER ( i -- n )
    DUP 6 < IF
        NEX-FIRST + C@
    THEN
;

\ write every bank flagged in the header, in file order
: WRITE-BANKS ( -- f )
    0                           \ f
    112 0 DO
        I NEX-ORDER             \ f n
        DUP 18 + +HEADER C@ IF
            2* DUP WRITE-PAGE   \ f p f1
            SWAP 1+ WRITE-PAGE  \ f f1 f2
            OR OR
        ELSE
            DROP
        THEN
    LOOP
;


\ ________________________________________________________________________

\ The 16 bytes below ORIGIN, as the image holds them:
\ +0   ld iy,$5C3A  jp ORIGIN   entry (PC of the header), cold start
\ +7   three bytes the entry push of ColdRoutine overwrites
\ +10  the address BYE returns to (SP of the header points here)
\ +12  nextreg 2,1              soft reset
: NEX-STUB ( -- a )
    0 +ORIGIN 16 -
;

HEX
CREATE NEX-CODE
    FD C, 21 C, 5C3A ,          \ ld   iy, $5C3A
    C3 C, 0 +ORIGIN ,           \ jp   ORIGIN
    0 C, 0 C, 0 C,
    0 +ORIGIN 4 - ,             \ return address of BYE
    ED C, 91 C, 02 C, 01 C,     \ nextreg 2, 1
DECIMAL

\ the live bytes the stub replaces for the write
CREATE NEX-SAVED 16 ALLOT

: NEX-STUB-ON ( -- )
    NEX-STUB NEX-SAVED 16 CMOVE
    NEX-CODE NEX-STUB  16 CMOVE
;

: NEX-STUB-OFF ( -- )
    NEX-SAVED NEX-STUB 16 CMOVE
;


\ set the fields that depend on the image: SP, PC, banks and their count,
\ RAM required (768K is enough up to bank 47)
: NEX-HEADER! ( -- )
    NEX-STUB 10 + 12 +HEADER !
    NEX-STUB      14 +HEADER !
    5 NEX-BANK  2 NEX-BANK  0 NEX-BANK
    HEAP-BANKS 0 DO
        I 16 + NEX-BANK
    LOOP
    0 112 0 DO
        I 18 + +HEADER C@ +
    LOOP
    9 +HEADER C!
    0 112 48 DO
        I 18 + +HEADER C@ OR
    LOOP
    8 +HEADER C!
;


\ ________________________________________________________________________

\ ZAP"
\ Usage:
\ ' cccc ZAP" filename.nex"
\ Given a xt, create or overwrite "filename.nex"
\ the patch, the stub and WARNING at 0 last for the bank writes alone:
\ no error can be raised meanwhile
: ZAP" ( xt -- cccc )
    DUP ZAP-LIMIT U< 0= 67 ?ERROR
    ?PATCHED 14 ?ERROR
    [CHAR] " WORD COUNT         \ xt a n
    DUP 47 > -18 ?ERROR
    FN 48 ERASE
    FN SWAP CMOVE               \ xt
    \ no buffer may be left marked for update in the image
    FLUSH
    NEX-HEADER!
    ZAP-OPEN NEX-FH !
    .FN
    NEX-HEADER 512 NEX-FH @ WRITE   \ xt f
    MMU7@ >R
    WARNING @ >R  0 WARNING !
    NEX-STUB-ON
    SWAP ZAP-PATCH ZAP-IMAGE    \ f
    WRITE-BANKS OR              \ f
    ZAP-LIVE ZAP-UNPATCH
    NEX-STUB-OFF
    R> WARNING !
    R> MMU7!
    NEX-FH @ CLOSE-CHECK
;


\ ________________________________________________________________________

\ The fixed fields of the header

NEX-HEADER 512 ERASE

\ "Next" string and file version: "V1.0", "V1.1" or "V1.2"
CREATE NEX-MAGIC ," NextV1.2"
NEX-MAGIC COUNT 0 +HEADER SWAP CMOVE

\ RAM required: 0 = 768k, 1 = 1792k              (8, set by ZAP")
\ Number of 16k Banks to Load: 0-112              (9, set by ZAP")

\ Loading-screen blocks in file (bit-flags): none
  0 10  +HEADER  C!

\ Border colour: 0-7
  7 11  +HEADER  C!

\ Stack Pointer                                   (12, set by ZAP")
\ Program counter (0 = don't run, just load)      (14, set by ZAP")

\ Number of extra files
  0 16  +HEADER  !

\ byte flag (0/1) of 16k banks included in the file, from offset 18,
\ in regular order 0..111                         (set by NEX-BANK)

\ Layer2 "loading bar", its colour, loading delay per bank, start delay
  0 130  +HEADER  C!
  0 131  +HEADER  C!
  0 132  +HEADER  C!
  0 133  +HEADER  C!

\ Preserve current Next-Registers values (0 = reset machine state)
  0 134  +HEADER  C!

\ Required core version: major, minor, subminor
  3 135  +HEADER  C!
  0 136  +HEADER  C!
  0 137  +HEADER  C!

\ Timex HiRes colour / Layer 2 palette offset: no screen, unused
  0 138  +HEADER  C!

\ Entry bank, mapped into slot 3 ($C000-$FFFF): bank 0, as under BASIC
  0 139  +HEADER  C!

\ File handle address: 0 = the loader closes the .nex file
  0 140  +HEADER  !


BASE !
