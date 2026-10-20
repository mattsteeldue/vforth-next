\
\ lib/MDR.f
\
\ v-Forth 1.8 - NextZXOS version - build 2026-10-19
\ MIT License (c) 1990-2026 Matteo Vitturi
\
\ Read-only access to ZX Microdrive cartridge images (.MDR files):
\ catalogue and extraction of a single file to the SD card.
\ A Forth port of the read side of mdr.pl, rev. 2022-12-01
\ ( https://github.com/mattsteeldue/zxmdr ).
\
\ Usage:
\   MDR-CAT  M2.MDR                     \ catalogue of the cartridge
\   MDR-GET  M2.MDR  !Blocks  BLK.TXT   \ extract !Blocks to BLK.TXT
\
\ MDR-GET never overwrites: the host file must not exist yet.
\ A PRINT file (OPEN #) is written as plain bytes. A program, code
\ or array file is written with its +3DOS header, so that NextBASIC
\ can LOAD it straight away.
\ Cartridge and file names are single words: no spaces allowed.
\
\ .MDR format: 254 sectors of 543 bytes, then the write-protect byte.
\ Each sector:
\     0  HDFLAG  1       14  HDCHK  checksum of bytes 0-13
\     1  HDNUMB  sector number 254..1
\     4  HDNAME  cartridge label, 10 bytes, blank padded
\    15  RECFLG  bit 1: EOF record, bit 2: reset for a PRINT file
\    16  RECNUM  record number within the file, from 0
\    17  RECLEN  bytes used in this record, up to 512
\    19  RECNAM  file name, 10 bytes, blank padded
\    29  DESCHK  checksum of bytes 15-28
\    30  DATA    512 bytes
\   542  DCHK    checksum of the 512 data bytes
\ A checksum is the sum of the bytes modulo 255.
\ Record 0 of a non-PRINT file starts with 9 bytes: type (0 program,
\ 1 number array, 2 character array, 3 code), length, start address,
\ vars offset (program) or variable name (array), autostart line.
\
\ The whole cartridge is distilled into a table of 254 entries of 16
\ bytes each, transient, above PAD: about 5K of free dictionary space
\ are needed while MDR-CAT or MDR-GET is running, nothing afterwards.
\
\ Error messages used (all already in the block file):
\   #2  Dictionary full: less than 5K free above HERE
\  #34  Checksum error: printed, not raised
\  #41  NextZXOS Open error   #42 Close error   #43 File not found
\  #45  NextZXOS Pos error    #46 Read error    #47 Write error

.( MDR )

MARKER NO-MDR

BASE @

DECIMAL

\ how many sectors were read, and the cartridge label
VARIABLE MDR-N
CREATE   MDR-LABEL  10 ALLOT

\ file handles: cartridge and host file, -1 when closed
VARIABLE MDR-FH    -1 MDR-FH !
VARIABLE MDR-OH    -1 MDR-OH !

\ z-string file names, the wanted name blank padded, the +3DOS header
CREATE   MDR-FN     64 ALLOT
CREATE   MDR-HOST   64 ALLOT
CREATE   MDR-WANT   10 ALLOT
CREATE   MDR-HDR     8 ALLOT

\ sectors whose header or descriptor checksum is wrong
VARIABLE MDR-WARN

\ kind of the file at hand: 0 Prog, 1 Numb, 2 Char, 3 Code, 4 Scrn, 5 Prnt
VARIABLE MDR-K

\ last file listed by MDR-CAT, its size, bytes still to write by MDR-GET
VARIABLE MDR-PREV
CREATE   MDR-SZ      4 ALLOT
VARIABLE MDR-LEFT

.( .)

\ the transient table, and the sector buffer just above it
: MDR-TAB ( -- a )
    PAD 256 +
;

: MDR-BUF ( -- a )
    MDR-TAB 4064 +              \ 254 entries of 16 bytes
;

\ there must be room for all of it below the stack
: MDR-ROOM ( -- )
    SP@ MDR-BUF 600 + U< 2 ?ERROR
;

\ entry i of the table:
\   +0 HDNUMB  +1 status: 0 free, 1 used, 2 bad
\   +2 RECFLG  +3 RECNUM  +4 RECLEN  +6 RECNAM
: MDR-ENTRY ( i -- a )
    4 LSHIFT MDR-TAB +
;

: MDR-NAME ( i -- a )
    MDR-ENTRY 6 +
;

: MDR-USED? ( i -- f )
    MDR-ENTRY 1+ C@ 1 =
;

\ first record of a file
: MDR-HEAD? ( i -- f )
    DUP MDR-USED?  SWAP MDR-ENTRY 3 + C@ 0=  AND
;

\ close whatever is still open
: MDR-CLOSE ( -- )
    MDR-FH @ 0< 0= IF  MDR-FH @ F_CLOSE DROP  -1 MDR-FH !  THEN
    MDR-OH @ 0< 0= IF  MDR-OH @ F_CLOSE DROP  -1 MDR-OH !  THEN
;

\ like ?ERROR, but close the files before giving up
: MDR-ERROR ( f n -- )
    SWAP IF  MDR-CLOSE  ERROR  ELSE  DROP  THEN
;

.( .)

\ sum of n bytes at a, modulo 255
: MDR-SUM ( a n -- c )
    0 0 2SWAP  BOUNDS ?DO  I C@ 0 D+  LOOP
    255 UM/MOD DROP
;

\ xor of n bytes at a
: MDR-XOR ( a n -- c )
    0 -ROT  BOUNDS ?DO  I C@ XOR  LOOP
;

\ the 14 bytes at a do not match the checksum that follows them
: MDR-CHK? ( a -- f )
    DUP 14 MDR-SUM  SWAP 14 + C@  = 0=
;

\ the sector in MDR-BUF is unusable, by the same test as mdr.pl:
\ sector number 255, or a wrong data checksum on all-zero-xor data
: MDR-BAD? ( -- f )
    MDR-BUF 1+ C@ 255 =
    MDR-BUF 30 + 512 MDR-SUM  MDR-BUF 542 + C@  = 0=
    IF  MDR-BUF 30 + 512 MDR-XOR 0=  OR  THEN
;

\ status of the sector in MDR-BUF: 0 free, 1 used, 2 bad
: MDR-STATUS ( -- n )
    MDR-BAD? IF  2  EXIT  THEN
    MDR-BUF 15 + C@ 2 AND  MDR-BUF 17 + @ 512 AND  OR
    IF  1  ELSE  0  THEN
;

\ distil the sector in MDR-BUF into entry i
: MDR-KEEP ( i -- )
    MDR-ENTRY >R
    MDR-BUF 1+ C@  R@ C!
    MDR-BUF 15 +  R@ 2+  14 CMOVE
    MDR-STATUS  DUP R> 1+ C!
    2 = 0= IF
        MDR-BUF MDR-CHK?  MDR-BUF 15 + MDR-CHK?  OR
        IF  1 MDR-WARN +!  THEN
        MDR-LABEL C@ 0= IF  MDR-BUF 4 +  MDR-LABEL  10 CMOVE  THEN
    THEN
;

.( .)

\ parse the next word into a z-string at a
: MDR-ZSTR ( a -- cccc )
    BL WORD COUNT  DUP 0= 43 ?ERROR
    63 MIN >R
    OVER R@ CMOVE
    R> +  0 SWAP C!
;

\ parse the next word as a cartridge file name, blank padded
: MDR-PARSE ( -- cccc )
    MDR-WANT 10 BLANK
    BL WORD COUNT  DUP 0= 43 ?ERROR
    10 MIN  MDR-WANT SWAP CMOVE
;

: MDR-OPEN ( -- )
    MDR-ROOM
    MDR-FN MDR-HDR 1 F_OPEN  41 ?ERROR  MDR-FH !
;

\ read the whole cartridge into the table
: MDR-SCAN ( -- )
    0 MDR-N !  0 MDR-WARN !  0 MDR-LABEL C!
    254 0 DO
        MDR-BUF 543 MDR-FH @ F_READ  46 MDR-ERROR
        543 < IF
            LEAVE
        ELSE
            I MDR-KEEP  I 1+ MDR-N !
        THEN
    LOOP
;

\ move to byte n of sector i
: MDR-SEEK ( i n -- )
    SWAP 543 UM*  ROT 0 D+
    MDR-FH @ F_SEEK  45 MDR-ERROR
;

\ read the 9 bytes that open record 0 into MDR-BUF
: MDR-DETAIL ( i -- )
    30 MDR-SEEK
    MDR-BUF 9 MDR-FH @ F_READ  46 MDR-ERROR  DROP
;

\ kind of the file whose record 0 is entry i, detail in MDR-BUF
: MDR-KIND ( i -- n )
    MDR-ENTRY  DUP 4 + @ 0= 0=  SWAP 2+ C@ 4 AND 0=  AND
    IF  5  EXIT  THEN
    MDR-BUF C@  DUP 3 > IF  DROP 5  EXIT  THEN
    DUP 3 = IF
        MDR-BUF 1+ @ 6912 =  MDR-BUF 3 + @ 16384 =  AND
        IF  1+  THEN
    THEN
;

.( .)

\ compare two 10-byte names, byte by byte: <0, 0, >0
: MDR-CMP ( a1 a2 -- n )
    0  10 0 DO
        DROP  OVER I + C@  OVER I + C@  -
        DUP IF  LEAVE  THEN
    LOOP
    NIP NIP
;

\ bytes held by the used sectors of the file named as entry i
: MDR-SIZE ( i -- d )
    MDR-NAME  0 0 ROT
    MDR-N @ 0 DO
        I MDR-USED? IF
            DUP I MDR-NAME MDR-CMP 0= IF
                -ROT  I MDR-ENTRY 4 + @ 0 D+  ROT
            THEN
        THEN
    LOOP
    DROP
;

: MDR-U.R ( u n -- )
    >R 0 R> D.R
;

: .MDR-TYPE ( n -- )
    DUP 0 = IF  ." Prog"  THEN
    DUP 1 = IF  ." Numb"  THEN
    DUP 2 = IF  ." Char"  THEN
    DUP 3 = IF  ." Code"  THEN
    DUP 4 = IF  ." Scrn"  THEN
        5 = IF  ." Prnt"  THEN
;

\ one line of the catalogue: the file whose record 0 is entry i
: MDR-LINE ( i -- )
    DUP MDR-DETAIL
    DUP MDR-KIND MDR-K !
    DUP MDR-SIZE MDR-SZ 2!
    CR  MDR-K @ .MDR-TYPE
    MDR-K @ 5 = IF  MDR-SZ 2@  ELSE  MDR-BUF 1+ @ 0  THEN
    8 D.R SPACE
    MDR-NAME 10 TYPE
    MDR-K @ 5 = IF  EXIT  THEN
    MDR-BUF 3 + @ 7 MDR-U.R
    MDR-SZ 2@ 7 D.R
    MDR-K @ 0= IF
        MDR-BUF 5 + @ 7 MDR-U.R
        MDR-BUF 7 + @  DUP 32768 U< IF  7 MDR-U.R  ELSE  DROP  THEN
    THEN
    MDR-K @ 1 = IF  4 SPACES  MDR-BUF 5 + C@ 64 + 127 AND EMIT  ." ()"  THEN
    MDR-K @ 2 = IF  3 SPACES  MDR-BUF 5 + C@ 127 AND EMIT  ." $()"  THEN
;

.( .)

\ the name of file i sorts after the one listed last
: MDR-AFTER? ( i -- f )
    MDR-PREV @  DUP 0< IF  2DROP 1  EXIT  THEN
    MDR-NAME SWAP MDR-NAME MDR-CMP 0<
;

\ next file to list in name order, -1 when none is left
: MDR-NEXT ( -- i )
    -1  MDR-N @ 0 DO
        I MDR-HEAD? IF  I MDR-AFTER? IF
            DUP 0< IF
                DROP I
            ELSE
                I MDR-NAME OVER MDR-NAME MDR-CMP 0< IF  DROP I  THEN
            THEN
        THEN  THEN
    LOOP
;

\ bytes in the sectors whose status is n
: MDR-COUNT ( n -- d )
    0 SWAP
    MDR-N @ 0 DO
        I MDR-ENTRY 1+ C@ OVER = IF  SWAP 1+ SWAP  THEN
    LOOP
    DROP 512 UM*
;

: MDR-KB ( d -- )
    512 0 D+  1024 UM/MOD NIP  6 MDR-U.R  ."  K"
;

: MDR-TOTALS ( -- )
    0 0  MDR-N @ 0 DO
        I MDR-USED? IF  I MDR-ENTRY 4 + @ 0 D+  THEN
    LOOP
    CR  2DUP 12 D.R ."  total used" MDR-KB
    2 MDR-COUNT  CR  2DUP 12 D.R ."  total bad " MDR-KB
    0 MDR-COUNT  CR  2DUP 12 D.R ."  total free" MDR-KB
    MDR-WARN @ IF  CR MDR-WARN @ . ." sectors: " 34 MESSAGE  THEN
;

\ catalogue of the cartridge named next
: MDR-CAT ( -- cccc )
    MDR-FN MDR-ZSTR
    MDR-OPEN MDR-SCAN
    CR ." Header: " MDR-LABEL 10 TYPE CR
    CR ." Type   Bytes Filename    Addr. Actual   Vars   Line"
    -1 MDR-PREV !
    BEGIN
        MDR-NEXT  DUP 0< 0=  ?TERMINAL 0= AND
    WHILE
        DUP MDR-LINE  MDR-PREV !
    REPEAT
    DROP CR
    MDR-TOTALS
    MDR-CLOSE
;

.( .)

\ record 0 of the wanted file; error #43 if there is none
: MDR-FIND ( -- i )
    -1  MDR-N @ 0 DO
        I MDR-HEAD? IF
            I MDR-NAME MDR-WANT MDR-CMP 0= IF  DROP I  LEAVE  THEN
        THEN
    LOOP
    DUP 0< IF                   \ show the wanted name, not the last word
        MDR-WANT 10 -TRAILING  DUP HERE C!  HERE 1+ SWAP CMOVE
    THEN
    DUP 0< 43 MDR-ERROR
;

\ the sector holding record r of the wanted file, -1 if none
: MDR-REC ( r -- i )
    -1 SWAP  MDR-N @ 0 DO
        I MDR-USED? IF
            I MDR-ENTRY 3 + C@ OVER = IF
                I MDR-NAME MDR-WANT MDR-CMP 0= IF  NIP I SWAP  LEAVE  THEN
            THEN
        THEN
    LOOP
    DROP
;

\ create the host file: with a +3DOS header unless it is a PRINT file
\ the header is built from the detail of record 0, still in MDR-BUF
: MDR-CREATE ( -- )
    MDR-HDR 8 ERASE
    MDR-K @ 5 < IF
        MDR-BUF C@     MDR-HDR C!
        MDR-BUF 1+ @   MDR-HDR 1+ !
        MDR-BUF C@ 0= IF
            MDR-BUF 7 + @  MDR-HDR 3 + !        \ autostart line
            MDR-BUF 5 + @  MDR-HDR 5 + !        \ vars offset
        THEN
        MDR-BUF C@  DUP 1 =  SWAP 2 =  OR IF
            MDR-BUF 5 + @  MDR-HDR 3 + !        \ variable name
            MDR-BUF 7 + @  MDR-HDR 5 + !
        THEN
        MDR-BUF C@ 3 = IF
            MDR-BUF 3 + @  MDR-HDR 3 + !        \ start address
            32768          MDR-HDR 5 + !
        THEN
        $46                             \ write, new file, with header
    ELSE
        $06                             \ write, new file
    THEN
    MDR-HOST MDR-HDR ROT F_OPEN  41 MDR-ERROR  MDR-OH !
;

\ append record r, held in sector i, to the host file
: MDR-COPY ( r i -- r )
    DUP 30 MDR-SEEK
    MDR-BUF 513 MDR-FH @ F_READ  46 MDR-ERROR  DROP
    MDR-BUF 512 MDR-SUM  MDR-BUF 512 + C@  = 0= IF
        CR ." record " OVER .  34 MESSAGE
    THEN
    MDR-ENTRY 4 + @                     \ r len
    OVER 0=  MDR-K @ 5 < AND IF  9  ELSE  0  THEN
    MDR-BUF OVER +  -ROT -              \ r a n
    MDR-K @ 5 < IF  MDR-LEFT @ MIN  DUP NEGATE MDR-LEFT +!  THEN
    DUP IF
        MDR-OH @ F_WRITE  47 MDR-ERROR  DROP
    ELSE
        2DROP
    THEN
;

\ extract a file from a cartridge: MDR-GET cartridge name hostfile
: MDR-GET ( -- cccc cccc cccc )
    MDR-FN MDR-ZSTR  MDR-PARSE  MDR-HOST MDR-ZSTR
    MDR-OPEN MDR-SCAN
    MDR-FIND
    DUP MDR-DETAIL  MDR-KIND MDR-K !
    MDR-BUF 1+ @ MDR-LEFT !
    MDR-CREATE
    0 BEGIN
        DUP MDR-REC  DUP 0< 0=
    WHILE
        MDR-COPY 1+
    REPEAT
    2DROP
    MDR-OH @ F_CLOSE  -1 MDR-OH !  42 MDR-ERROR
    MDR-CLOSE
;

\ NEEDS MDR loads this module
: MDR ( -- )
    CR ." MDR-CAT  cartridge"
    CR ." MDR-GET  cartridge name hostfile"
;

BASE !
