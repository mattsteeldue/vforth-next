\
\ lib/MDR.f
\
\ v-Forth 1.8 - NextZXOS version - build 2026-11-02
\ MIT License (c) 1990-2026 Matteo Vitturi
\
\ Access to ZX Microdrive cartridge images (.MDR files): catalogue, sector
\ map, extraction to the SD card, and every change to the cartridge.
\ A Forth port of mdr.pl, rev. 2022-12-01
\ ( https://github.com/mattsteeldue/zxmdr ).
\
\ Usage:
\   MDR-CAT  M2.MDR                     \ catalogue of the cartridge
\   MDR-SECTORS  M2.MDR                 \ sectors of each file, free ones
\   MDR-INFO  M2.MDR                    \ one line per sector
\   MDR-GET  M2.MDR  !Blocks  BLK.TXT   \ extract !Blocks to BLK.TXT
\   MDR-DUMP  M1.MDR  run  RUN.BIN      \ the same, raw bytes only
\   MDR-DUMP32  M2.MDR  !Blocks  B.TXT  \ raw, a line every 32 bytes
\   MDR-DUMPBLOCK  M2.MDR  !Blocks  B.F \ and "\ Screen# n" every 16 lines
\   MDR-GETTAP  M1.MDR  run  RUN.TAP    \ a file to a new .TAP
\   MDR-TAP  M1.MDR  ALL.TAP            \ all the files to a new .TAP
\
\   MDR-NEW  M9.MDR                     \ create an empty cartridge
\   MDR-LABEL  M2.MDR  Forth            \ change the cartridge label
\   MDR-ERASE  M2.MDR  old              \ erase a file
\   MDR-RENAME  M2.MDR  old  new        \ rename a file
\   MDR-COPY  M2.MDR  old  new          \ copy a file on the cartridge
\   MDR-AUTORUN  M1.MDR  run  10        \ LOAD starts it at line 10
\   MDR-NOAUTORUN  M1.MDR  run          \ no more; * for all the programs
\   MDR-FIX  M2.MDR                     \ correct the wrong checksums
\   MDR-PUT  M2.MDR  name  FILE.BIN     \ a host file becomes a PRINT file
\   MDR-PUTTEXT  M2.MDR  name  FILE.TXT \ the same, LF and CR+LF become CR
\   MDR-PUT32  M2.MDR  name  FILE.TXT   \ lines blank padded to 32 bytes
\   MDR-PUTBLOCK  M2.MDR  name  B.F     \ the reverse of MDR-DUMPBLOCK
\   MDR-PUTTAP  M1.MDR  ALL.TAP         \ all the files of a .TAP
\
\ The extracting words never overwrite: the host file must not exist yet.
\ MDR-GET writes a PRINT file (OPEN #) as plain bytes, and a program,
\ code or array file with its +3DOS header, so that NextBASIC can LOAD
\ it straight away. MDR-DUMP writes the bytes only, without the 9 bytes
\ that open record 0. MDR-DUMP32 cuts them in lines of 32, trailing
\ blanks removed, ended by LF: the 32-column screens of the old
\ Microdrive vForth, which MDR-DUMPBLOCK numbers like a source file.
\ Cartridge and file names are single words: no spaces allowed.
\
\ The words that change a cartridge work in place, on the .MDR itself,
\ and ignore the write-protect byte, as mdr.pl does: keep a copy.
\ A name already on the cartridge is refused (#4): a file is replaced by
\ MDR-ERASE and then MDR-PUT, where mdr.pl would replace it at once.
\ Before writing, MDR-PUT and its kin count the sectors they need, by a
\ first pass over the host file: a file too long leaves the cartridge
\ untouched (#65). Sectors are taken as the Interface 1 would, downward,
\ two by two for the motor latency. MDR-ERASE keeps the name and the
\ record number in the sector, as mdr.pl does, so that MDR-SECTORS still
\ lists an erased file, but it clears the data with a right checksum.
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
\ bytes each, plus two bytes of flags per sector, transient, above PAD:
\ about 7K of free dictionary space are needed while a word is running,
\ nothing afterwards.
\
\ Error messages used:
\   #2  Dictionary full: less than 7K free above HERE
\   #4  has already been defined: the name is on the cartridge
\  #34  Checksum error: printed, not raised
\  #41  NextZXOS Open error   #42 Close error   #43 File not found
\  #45  NextZXOS Pos error    #46 Read error    #47 Write error
\  #65  Microdrive full.       #66 Not a program.    (reserved here)

.( MDR )

NEEDS H"  NEEDS S"  NEEDS SHOW-PROGRESS

MARKER NO-MDR

BASE @

DECIMAL

\ how many sectors were read, and the cartridge label
VARIABLE MDR-N
CREATE   MDR-MLAB   10 ALLOT

\ file handles: cartridge and host file, -1 when closed
VARIABLE MDR-FH    -1 MDR-FH !
VARIABLE MDR-OH    -1 MDR-OH !

\ z-string file names, the wanted name blank padded, the +3DOS header
CREATE   MDR-FN     64 ALLOT
CREATE   MDR-HOST   64 ALLOT
CREATE   MDR-WANT   10 ALLOT
CREATE   MDR-TO     10 ALLOT
CREATE   MDR-HDR     8 ALLOT

\ sectors whose header or descriptor checksum is wrong
VARIABLE MDR-WARN

\ kind of the file at hand: 0 Prog, 1 Numb, 2 Char, 3 Code, 4 Scrn, 5 Prnt
VARIABLE MDR-K

\ last file listed by MDR-CAT, its size, bytes still to write by MDR-GET
VARIABLE MDR-PREV
CREATE   MDR-SZ      4 ALLOT
VARIABLE MDR-LEFT

\ the data checksum of the sector at hand is wrong
VARIABLE MDR-DBAD

\ highest sector number, the write-protect byte
VARIABLE MDR-MAXH
VARIABLE MDR-WP

\ labels met, and the one met most often
VARIABLE MDR-NLAB
VARIABLE MDR-ML

\ which files MDR-NEXT lists, the last sector number listed,
\ the bytes of the erased files
VARIABLE MDR-SEL
VARIABLE MDR-LAST
CREATE   MDR-ER      4 ALLOT

\ what an extracting word writes: 0 get, 1 dump, 2 dump32, 3 dumpblock,
\ 4 tap; what a putting word reads: 0 raw, 1 text, 2 put32, 3 putblock
\ and the line of 32 bytes being filled, with its count and the lines done
VARIABLE MDR-MODE
CREATE   MDR-ROW    32 ALLOT
VARIABLE MDR-RN
VARIABLE MDR-ROWS
CREATE   MDR-SCR    ," \ Screen# "
CREATE   MDR-EOL    10 C,

\ the head of the next free sector, the screen MDR-PUTBLOCK is at
VARIABLE MDR-HEADP
VARIABLE MDR-SCRN

\ the sector being filled by a putting word: RECFLG, record number, bytes
\ held; the sectors done; first pass only, counting; a byte to put;
\ empty lines still to put; the last byte was a CR
VARIABLE MDR-RF
VARIABLE MDR-RECN
VARIABLE MDR-FILL
VARIABLE MDR-SECS
VARIABLE MDR-DRY
VARIABLE MDR-C
VARIABLE MDR-PEND
VARIABLE MDR-WASCR

\ .TAP: running xor; a header came for the next data block; ignore it
VARIABLE MDR-TX
VARIABLE MDR-THAS
VARIABLE MDR-SKIP

.( .)

\ the transient table, and the sector buffer just above it
: MDR-TAB ( -- a )
    PAD 256 +
;

: MDR-BUF ( -- a )
    MDR-TAB 4064 +              \ 254 entries of 16 bytes
;

\ then 254 bytes of flags, 254 of groups and 8 labels of 12 bytes
: MDR-FLG ( -- a )
    MDR-BUF 544 +
;

\ then, past the labels: the sector of each number, the sector last
\ numbered so, 255 if none; a buffer for the host file; a line of text
: MDR-MAP ( -- a )
    MDR-FLG 604 +
;

: MDR-IN ( -- a )
    MDR-MAP 256 +
;

: MDR-LN ( -- a )
    MDR-IN 512 +
;

\ there must be room for all of it below the stack
: MDR-ROOM ( -- )
    SP@ MDR-BUF 2200 + U< 2 ?ERROR
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

\ flags of sector i: 2 header, 4 descriptor, 8 data checksum wrong;
\ bits 4-6 the label slot
: MDR-FLAGS ( i -- a )
    MDR-FLG +
;

\ group of sector i, set only on the one that stands for the group:
\ 1 a file, 2 a used file of 0 bytes, 4 an erased file
: MDR-GRP ( i -- a )
    MDR-FLG 254 + +
;

\ label slot n: 10 bytes of label, a count
: MDR-LAB ( n -- a )
    12 *  MDR-FLG 508 + +
;

\ wipe the last mark left on screen by SHOW-PROGRESS
: MDR-UNSPIN ( -- )
    2 SELECT  SPACE 8 EMIT  DEVICE @ SELECT
;

\ close whatever is still open
: MDR-CLOSE ( -- )
    MDR-UNSPIN
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
    MDR-BUF 30 + 512 MDR-SUM  MDR-BUF 542 + C@  = 0=
    DUP MDR-DBAD !
    IF  MDR-BUF 30 + 512 MDR-XOR 0=  ELSE  0  THEN
    MDR-BUF 1+ C@ 255 =  OR
;

\ status of the sector in MDR-BUF: 0 free, 1 used, 2 bad
: MDR-STATUS ( -- n )
    MDR-BAD? IF  2  EXIT  THEN
    MDR-BUF 15 + C@ 2 AND  MDR-BUF 17 + @ 512 AND  OR
    IF  1  ELSE  0  THEN
;

\ compare two 10-byte names, byte by byte: <0, 0, >0
: MDR-CMP ( a1 a2 -- n )
    0  10 0 DO
        DROP  OVER I + C@  OVER I + C@  -
        DUP IF  LEAVE  THEN
    LOOP
    NIP NIP
;

\ the slot of the label at a, counted once more
: MDR-SLOT ( a -- n )
    8 SWAP
    MDR-NLAB @ 0 ?DO
        DUP I MDR-LAB MDR-CMP 0= IF  NIP I SWAP  LEAVE  THEN
    LOOP
    OVER 8 = IF
        MDR-NLAB @ 8 < IF               \ a new label
            NIP  MDR-NLAB @ SWAP  OVER MDR-LAB 10 CMOVE
            0  OVER MDR-LAB 10 + !  1 MDR-NLAB +!
        ELSE                            \ more than 8: the last slot
            2DROP 7
        THEN
    ELSE
        DROP
    THEN
    1  OVER MDR-LAB 10 + +!
;

\ distil the sector in MDR-BUF into entry i
: MDR-KEEP ( i -- )
    DUP MDR-ENTRY >R
    DUP  MDR-BUF 1+ C@ MDR-MAP +  C!
    MDR-BUF 1+ C@  DUP R@ C!  MDR-MAXH @ MAX MDR-MAXH !
    MDR-BUF 15 +  R@ 2+  14 CMOVE
    MDR-STATUS  DUP R> 1+ C!                    \ i st
    MDR-BUF MDR-CHK? 2 AND
    MDR-BUF 15 + MDR-CHK? 4 AND  OR
    MDR-DBAD @ 8 AND  OR                        \ i st flags
    SWAP 2 = 0= IF
        DUP 6 AND IF  1 MDR-WARN +!  THEN
        MDR-BUF 4 + MDR-SLOT  4 LSHIFT  OR
    THEN
    SWAP MDR-FLAGS C!
;

.( .)

\ parse the next word into a z-string at a
: MDR-ZSTR ( a -- cccc )
    BL WORD COUNT  DUP 0= 43 ?ERROR
    63 MIN >R
    OVER R@ CMOVE
    R> +  0 SWAP C!
;

\ parse the next word as a cartridge file name at a, blank padded
: MDR-PARSEA ( a -- cccc )
    DUP 10 BLANK
    BL WORD COUNT  DUP 0= 43 ?ERROR
    10 MIN  ROT SWAP CMOVE
;

: MDR-PARSE ( -- cccc )
    MDR-WANT MDR-PARSEA
;

\ open the cartridge with the mode b
: MDR-OPENM ( b -- )
    MDR-ROOM
    MDR-FN MDR-HDR ROT F_OPEN  41 ?ERROR  MDR-FH !
;

: MDR-OPEN ( -- )
    1 MDR-OPENM
;

\ the label met most often, the first in name order on a tie
: MDR-MASTER ( -- )
    0 MDR-ML !
    MDR-NLAB @ 1 ?DO
        I MDR-LAB 10 + @  MDR-ML @ MDR-LAB 10 + @
        2DUP U< IF
            2DROP
        ELSE
            = IF
                I MDR-LAB  MDR-ML @ MDR-LAB  MDR-CMP 0< IF  I MDR-ML !  THEN
            ELSE
                I MDR-ML !
            THEN
        THEN
    LOOP
    MDR-MLAB 10 BLANK
    MDR-NLAB @ IF  MDR-ML @ MDR-LAB  MDR-MLAB  10 CMOVE  THEN
;

\ entry j has status st and the name of entry i
: MDR-SAME? ( i j st -- f )
    OVER MDR-ENTRY 1+ C@ = IF
        MDR-NAME SWAP MDR-NAME MDR-CMP 0=
    ELSE
        2DROP 0
    THEN
;

\ no sector before i has status st and the name of i
: MDR-FIRST? ( i st -- f )
    -1  2 PICK 0 ?DO
        2 PICK I 3 PICK MDR-SAME? IF  DROP 0  LEAVE  THEN
    LOOP
    NIP NIP
;

\ some used sector with the name of i holds record 0
: MDR-REC0? ( i -- f )
    0  MDR-N @ 0 ?DO
        OVER I 1 MDR-SAME? IF
            I MDR-ENTRY 3 + C@ 0= IF  0=  LEAVE  THEN
        THEN
    LOOP
    NIP
;

\ how many sectors have status st and the name of i
: MDR-CNT ( i st -- n )
    0  MDR-N @ 0 ?DO
        2 PICK I 3 PICK MDR-SAME? IF  1+  THEN
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

\ choose the sector that stands for each file: record 0, or the first
\ sector of a file that has lost it; and for each erased file
: MDR-MARK ( -- )
    MDR-N @ 0 ?DO
        I MDR-ENTRY 1+ C@  DUP 1 = IF
            DROP
            I MDR-ENTRY 3 + C@ IF
                I 1 MDR-FIRST? IF  I MDR-REC0? 0=  ELSE  0  THEN
            ELSE
                -1
            THEN
            IF  I MDR-SIZE OR IF 1 ELSE 2 THEN  I MDR-GRP C!  THEN
        ELSE
            0= IF  I 0 MDR-FIRST? IF  4 I MDR-GRP C!  THEN  THEN
        THEN
    LOOP
;

\ the byte that follows the last sector
: MDR-WPROT ( -- )
    0  MDR-N @ 254 = IF
        MDR-BUF 1 MDR-FH @ F_READ  46 MDR-ERROR
        IF  MDR-BUF C@ OR  THEN
    THEN
    MDR-WP !
;

\ read the whole cartridge into the table
: MDR-SCAN ( -- )
    0 MDR-N !  0 MDR-WARN !  0 MDR-NLAB !  0 MDR-MAXH !
    MDR-FLG 508 ERASE
    MDR-MAP 256 255 FILL
    254 0 DO
        I SHOW-PROGRESS
        MDR-BUF 543 MDR-FH @ F_READ  46 MDR-ERROR
        543 < IF
            LEAVE
        ELSE
            I MDR-KEEP  I 1+ MDR-N !
        THEN
    LOOP
    MDR-WPROT  MDR-MASTER  MDR-MARK  MDR-UNSPIN
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

: MDR-U.R ( u n -- )
    >R 0 R> D.R
;

\ u as n digits, with leading zeros
: MDR-Z. ( u n -- )
    >R 0 <#  R> 0 ?DO  #  LOOP  #> TYPE
;

\ u as n hex digits
: MDR-H. ( u n -- )
    BASE @ >R  HEX  MDR-Z.  R> BASE !
;

\ the 10 bytes of a name or label, a control code as a space
: .MDR-NAME ( a -- )
    10 BOUNDS ?DO
        I C@  DUP BL < IF  DROP BL  THEN  EMIT
    LOOP
;

\ the kind n, 0-5, as 4 letters from a single string in the heap
: .MDR-TYPE ( n -- )
    4 *  S" ProgNumbCharCodeScrnPrnt" DROP +  4 TYPE
;

\ the highest sector number below MDR-LAST among the sectors
\ with status st and the name of i, -1 if none
: MDR-MAXB ( i st -- n )
    -1  MDR-N @ 0 ?DO
        2 PICK I 3 PICK MDR-SAME? IF
            I MDR-ENTRY C@
            DUP MDR-LAST @ <  OVER 3 PICK >  AND IF  NIP  ELSE  DROP  THEN
        THEN
    LOOP
    NIP NIP
;

\ the sector numbers of a file, from the highest: eight at most
: MDR-SECTS ( i st -- )
    256 MDR-LAST !
    9 0 DO
        2DUP MDR-MAXB
        DUP 0< IF  DROP  LEAVE  THEN
        I 8 = IF  DROP  S"  ... " TYPE LEAVE  THEN
        I IF  [CHAR] , EMIT  THEN
        DUP MDR-LAST !  3 MDR-Z.
    LOOP
    2DROP
;

\ a file that has lost its record 0: type Bad!, 512 bytes a sector
: MDR-LOST ( i -- )
    S" Bad!" TYPE  DUP 1 MDR-CNT 512 UM*  8 D.R SPACE  MDR-NAME .MDR-NAME
;

\ type, length and name of the file whose record 0 is entry i
: MDR-FILE ( i -- )
    DUP MDR-DETAIL
    DUP MDR-KIND MDR-K !
    DUP MDR-SIZE MDR-SZ 2!
    MDR-K @ .MDR-TYPE
    MDR-K @ 5 = IF  MDR-SZ 2@  ELSE  MDR-BUF 1+ @ 0  THEN
    8 D.R SPACE
    MDR-NAME .MDR-NAME
;

\ the file has lost its record 0
: MDR-LOST? ( i -- f )
    MDR-ENTRY 3 + C@ 0= 0=
;

\ one line of the catalogue: the file that entry i stands for
: MDR-LINE ( i -- )
    CR
    DUP MDR-LOST? IF
        DUP MDR-LOST  SPACE  1 MDR-SECTS
    ELSE
        MDR-FILE
        MDR-K @ 5 = 0= IF
            MDR-BUF 3 + @ 7 MDR-U.R
            MDR-SZ 2@ 7 D.R
        THEN
        MDR-K @ 0= IF
            MDR-BUF 5 + @ 7 MDR-U.R
            MDR-BUF 7 + @  DUP 32768 U< IF  7 MDR-U.R  ELSE  DROP  THEN
        THEN
        MDR-K @ 1 = IF
            4 SPACES  MDR-BUF 5 + C@ 64 + 127 AND EMIT  S" ()" TYPE
        THEN
        MDR-K @ 2 = IF
            3 SPACES  MDR-BUF 5 + C@ 127 AND EMIT  S" $()" TYPE
        THEN
    THEN
;

\ one line of MDR-SECTORS: the file and its sectors
: MDR-SLINE ( i -- )
    CR
    DUP MDR-LOST? IF  DUP MDR-LOST  ELSE  DUP MDR-FILE  THEN
    SPACE  1 MDR-SECTS
;

\ one line of the erased files: a group of free sectors with the same
\ name, marked by "-", or a used file of 0 bytes
: MDR-FLINE ( i -- )
    DUP MDR-GRP C@ 4 AND IF  0  ELSE  1  THEN      \ i st
    CR S" Free" TYPE
    2DUP MDR-CNT 512 UM*  2DUP MDR-ER 2@ D+ MDR-ER 2!  8 D.R SPACE
    OVER MDR-NAME .MDR-NAME
    DUP IF  SPACE  ELSE  [CHAR] - EMIT  THEN
    S"  sect: " TYPE  MDR-SECTS
;

.( .)

\ the name of file i sorts after the one listed last
: MDR-AFTER? ( i -- f )
    MDR-PREV @  DUP 0< IF  2DROP 1  EXIT  THEN
    MDR-NAME SWAP MDR-NAME MDR-CMP 0<
;

\ next file to list in name order, -1 when none is left;
\ the files are those whose group is in MDR-SEL
: MDR-NEXT ( -- i )
    -1  MDR-N @ 0 DO
        I MDR-GRP C@ MDR-SEL @ AND IF  I MDR-AFTER? IF
            DUP 0< IF
                DROP I
            ELSE
                I MDR-NAME OVER MDR-NAME MDR-CMP 0< IF  DROP I  THEN
            THEN
        THEN  THEN
    LOOP
;

\ list in name order the files of the groups in n, a line each by xt
: MDR-LIST ( xt n -- )
    MDR-SEL !  -1 MDR-PREV !
    BEGIN
        MDR-NEXT  DUP 0< 0=  ?TERMINAL 0= AND
    WHILE
        DUP 2 PICK EXECUTE  MDR-PREV !
    REPEAT
    2DROP
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
    512 0 D+  1024 UM/MOD NIP  6 MDR-U.R  S"  K" TYPE
;

\ the bad sectors, one a line; the highest is the tape junction
: MDR-BADS ( -- )
    MDR-N @ 0 ?DO
        I MDR-ENTRY 1+ C@ 2 = IF
            CR S" Bad " TYPE 512 8 MDR-U.R  13 SPACES
            I MDR-ENTRY C@  DUP 0 MDR-U.R
            MDR-MAXH @ = IF  S"  tape-junction" TYPE  THEN
        THEN
    LOOP
;

\ totals; with f, also the bytes of the erased files
: MDR-TOTALS ( f -- )
    0 0  MDR-N @ 0 DO
        I MDR-USED? IF  I MDR-ENTRY 4 + @ 0 D+  THEN
    LOOP
    CR  2DUP 12 D.R S"  total used  " TYPE MDR-KB
    IF  MDR-ER 2@  CR  2DUP 12 D.R S"  total erased" TYPE MDR-KB  THEN
    2 MDR-COUNT  CR  2DUP 12 D.R S"  total bad   " TYPE MDR-KB
    0 MDR-COUNT  CR  2DUP 12 D.R S"  total free  " TYPE MDR-KB
    MDR-WARN @ IF  CR MDR-WARN @ . S" sectors: " TYPE 34 MESSAGE  THEN
;

\ the rank of label slot i in name order
: MDR-RANK ( i -- n )
    0  MDR-NLAB @ 0 ?DO
        OVER MDR-LAB  I MDR-LAB  MDR-CMP 0> IF  1+  THEN
    LOOP
    NIP
;

\ the label slot whose rank is n
: MDR-RANKED ( n -- i )
    0  MDR-NLAB @ 0 ?DO
        I MDR-RANK  2 PICK = IF  DROP I  LEAVE  THEN
    LOOP
    NIP
;

\ the label, the write protection, every label when there are several
: MDR-HEADER ( -- )
    CR S" Header: " TYPE  MDR-MLAB .MDR-NAME
    MDR-WP @ IF  S"  (write protected)" TYPE  THEN
    MDR-NLAB @ 1 > IF
        MDR-NLAB @ 0 DO
            I MDR-RANKED  CR 8 SPACES  DUP MDR-LAB .MDR-NAME
            S"  (" TYPE  MDR-LAB 10 + @ . S" times)" TYPE
        LOOP
    THEN
    CR
;

\ catalogue of the cartridge named next
: MDR-CAT ( -- cccc )
    MDR-FN MDR-ZSTR
    MDR-OPEN MDR-SCAN
    MDR-HEADER
    CR S" Type   Bytes Filename    Addr. Actual   Vars   Line" TYPE
    [ ' MDR-LINE ] LITERAL  1 MDR-LIST
    CR  MDR-BADS
    0 MDR-TOTALS
    MDR-CLOSE
;

\ the sectors of each file, then the erased files, of the cartridge
\ named next
: MDR-SECTORS ( -- cccc )
    MDR-FN MDR-ZSTR
    MDR-OPEN MDR-SCAN
    MDR-HEADER
    CR S" Type   Bytes Filename   Sector used" TYPE
    [ ' MDR-SLINE ] LITERAL  1 MDR-LIST
    CR  0 0 MDR-ER 2!
    [ ' MDR-FLINE ] LITERAL  6 MDR-LIST
    CR  MDR-BADS
    1 MDR-TOTALS
    MDR-CLOSE
;

\ one line of MDR-INFO: sector, record, flags, length, name, what it is;
\ a wrong checksum: hd! header, de! descriptor, da! data;
\ the label, when it is not the one in the Header line
: MDR-ILINE ( i -- )
    CR  DUP MDR-ENTRY >R
    R@ C@ 3 MDR-Z.  SPACE  R@ 3 + C@ 3 MDR-Z.  SPACE
    R@ 2+ C@ 2 MDR-H.  SPACE  R@ 4 + @ 4 MDR-H.  SPACE
    R@ 6 + .MDR-NAME
    R@ 1+ C@  R> 2+ C@                          \ i st recflg
    OVER 2 = IF
        2DROP DROP  S"  bad" TYPE
    ELSE
        SWAP IF
            DUP 4 AND 0= IF  S"  PRN" TYPE  THEN
            2 AND IF  S"  EOF" TYPE  THEN
            14
        ELSE
            DROP  S"  free" TYPE 6                 \ data of a free sector
        THEN                                    \ i mask
        SWAP MDR-FLAGS C@  DUP ROT AND
        DUP 2 AND IF  S"  hd!" TYPE  THEN
        DUP 4 AND IF  S"  de!" TYPE  THEN
            8 AND IF  S"  da!" TYPE  THEN
        4 RSHIFT 7 AND  DUP MDR-ML @ = IF
            DROP
        ELSE
            SPACE MDR-LAB .MDR-NAME
        THEN
    THEN
;

\ every sector of the cartridge named next, in the order of the file
: MDR-INFO ( -- cccc )
    MDR-FN MDR-ZSTR
    MDR-OPEN MDR-SCAN
    MDR-HEADER
    CR S" Sec Rec Fl Len  Filename" TYPE
    MDR-N @ 0 ?DO
        I MDR-ILINE
        ?TERMINAL IF  LEAVE  THEN
    LOOP
    CR
    MDR-CLOSE
;

.( .)

\ like MDR-ERROR, but ERROR shows the 10-byte name at a, not the last word
: MDR-MISS ( f a n -- )
    >R  OVER IF
        10 -TRAILING  DUP HERE C!  HERE 1+ SWAP CMOVE
    ELSE
        DROP
    THEN
    R> MDR-ERROR
;

\ record 0 of the wanted file; error #43 if there is none
: MDR-FIND ( -- i )
    -1  MDR-N @ 0 DO
        I MDR-HEAD? IF
            I MDR-NAME MDR-WANT MDR-CMP 0= IF  DROP I  LEAVE  THEN
        THEN
    LOOP
    DUP 0<  MDR-WANT 43 MDR-MISS
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

\ the type, length and two parameters of a file, in the +3DOS order that
\ is also the one of a tape header, from the detail of record 0 in MDR-BUF
: MDR-PARAMS ( -- )
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
    THEN
;

\ create the host file: with a +3DOS header unless it is a PRINT file
\ or the bytes only are wanted
: MDR-CREATE ( -- )
    MDR-K @ 5 <  MDR-MODE @ 0=  AND IF
        $46                             \ write, new file, with header
    ELSE
        $06                             \ write, new file
    THEN
    MDR-HOST MDR-HDR ROT F_OPEN  41 MDR-ERROR  MDR-OH !
;

\ write n bytes at a to the host file
: MDR-W ( a n -- )
    DUP IF
        MDR-OH @ F_WRITE  47 MDR-ERROR  DROP
    ELSE
        2DROP
    THEN
;

: MDR-LF ( -- )
    MDR-EOL 1 MDR-W
;

\ blank for mdr.pl's A32: NUL, space, TAB, LF, VT, FF, CR
: MDR-WS? ( c -- f )
    DUP 0=  OVER BL = OR  SWAP 9 - 5 U< OR
;

: MDR-TRIM ( a n -- a n2 )
    BEGIN
        DUP IF  2DUP + 1- C@ MDR-WS?  ELSE  0  THEN
    WHILE
        1-
    REPEAT
;

\ write the line in MDR-ROW, after a "\ Screen# n" header every 16
: MDR-ROW-OUT ( -- )
    MDR-MODE @ 3 =  MDR-ROWS @ 15 AND 0=  AND IF
        MDR-LF MDR-LF  MDR-SCR COUNT MDR-W
        BASE @ >R  DECIMAL
        MDR-ROWS @ 4 RSHIFT 1+  0 <# #S #> MDR-W  MDR-LF
        R> BASE !
    THEN
    MDR-ROW MDR-RN @ MDR-TRIM MDR-W  MDR-LF
    0 MDR-RN !  1 MDR-ROWS +!
;

\ cut n bytes at a in lines of 32
: MDR-ROWS-W ( a n -- )
    BEGIN
        DUP
    WHILE
        DUP 32 MDR-RN @ - MIN >R
        OVER  MDR-ROW MDR-RN @ +  R@ CMOVE
        R@ MDR-RN +!
        R@ -  SWAP R> +  SWAP
        MDR-RN @ 32 = IF  MDR-ROW-OUT  THEN
    REPEAT
    2DROP
;

\ write n bytes at a as the mode wants them
: MDR-OUT ( a n -- )
    MDR-MODE @ 4 = IF  2DUP MDR-XOR  MDR-TX @ XOR  MDR-TX !  THEN
    MDR-MODE @ 2-  2 U< IF  MDR-ROWS-W  ELSE  MDR-W  THEN
;

\ append record r, held in sector i, to the host file
: MDR-XFER ( r i -- r )
    OVER SHOW-PROGRESS
    DUP 30 MDR-SEEK
    MDR-BUF 513 MDR-FH @ F_READ  46 MDR-ERROR  DROP
    MDR-BUF 512 MDR-SUM  MDR-BUF 512 + C@  = 0= IF
        MDR-UNSPIN  CR S" record " TYPE  OVER .  34 MESSAGE
    THEN
    MDR-ENTRY 4 + @                     \ r len
    OVER 0=  MDR-K @ 5 < AND IF  9  ELSE  0  THEN
    MDR-BUF OVER +  -ROT -              \ r a n
    MDR-K @ 5 < IF  MDR-LEFT @ MIN  DUP NEGATE MDR-LEFT +!  THEN
    MDR-OUT
;

\ the tape header block of the file named as entry i, and the head of
\ its data block
: MDR-TAPHDR ( i -- )
    MDR-LN 21 ERASE
    19 MDR-LN !
    MDR-HDR C@  MDR-LN 3 + C!
    MDR-NAME  MDR-LN 4 +  10 CMOVE
    MDR-HDR 1+  MDR-LN 14 +  6 CMOVE
    MDR-LN 2+ 18 MDR-XOR  MDR-LN 20 + C!
    MDR-LN 21 MDR-W
    MDR-LEFT @ 2+  MDR-LN !  255 MDR-LN 2+ C!
    MDR-LN 3 MDR-W
    255 MDR-TX !
;

\ what MDR-BODY needs of the file whose record 0 is entry i
: MDR-PREP ( i -- )
    DUP MDR-DETAIL  MDR-KIND MDR-K !
    MDR-BUF 1+ @ MDR-LEFT !
    MDR-PARAMS
;

\ the wanted file, whose record 0 is entry i, to the open host file
: MDR-BODY ( i -- )
    MDR-MODE @ 4 =  MDR-K @ 5 <  AND IF  MDR-TAPHDR  ELSE  DROP  THEN
    0 BEGIN
        DUP MDR-REC  DUP 0< 0=
    WHILE
        MDR-XFER 1+
    REPEAT
    2DROP
    MDR-RN @ IF  MDR-ROW-OUT  THEN
    MDR-MODE @ 4 =  MDR-K @ 5 <  AND IF
        MDR-LEFT @ IF
            MDR-UNSPIN  CR MDR-WANT .MDR-NAME SPACE  34 MESSAGE
        THEN
        MDR-TX 1 MDR-W
    THEN
;

\ extract a file from a cartridge: cartridge name hostfile;
\ n is what to write, see MDR-MODE
: MDR-EXTRACT ( n -- cccc cccc cccc )
    MDR-MODE !  0 MDR-RN !  0 MDR-ROWS !
    MDR-FN MDR-ZSTR  MDR-PARSE  MDR-HOST MDR-ZSTR
    MDR-OPEN MDR-SCAN
    MDR-FIND
    DUP MDR-PREP
    MDR-CREATE
    MDR-BODY
    MDR-OH @ F_CLOSE  -1 MDR-OH !  42 MDR-ERROR
    MDR-CLOSE
;

\ extract a file: MDR-GET cartridge name hostfile
: MDR-GET ( -- cccc cccc cccc )
    0 MDR-EXTRACT
;

\ the bytes only, without +3DOS header
: MDR-DUMP ( -- cccc cccc cccc )
    1 MDR-EXTRACT
;

\ the bytes only, in lines of 32
: MDR-DUMP32 ( -- cccc cccc cccc )
    2 MDR-EXTRACT
;

\ the bytes only, in lines of 32, a "\ Screen# n" every 16 lines
: MDR-DUMPBLOCK ( -- cccc cccc cccc )
    3 MDR-EXTRACT
;

\ one file to a new .TAP: MDR-GETTAP cartridge name tapfile
: MDR-GETTAP ( -- cccc cccc cccc )
    4 MDR-EXTRACT
;

\ a file of MDR-LIST to the open .TAP; a PRINT file has no place on tape
: MDR-TAP1 ( i -- )
    DUP MDR-LOST? IF  DROP  EXIT  THEN
    DUP MDR-NAME MDR-WANT 10 CMOVE
    DUP MDR-PREP
    MDR-K @ 5 < IF  MDR-BODY  ELSE  DROP  THEN
;

\ all the files to a new .TAP, in name order: MDR-TAP cartridge tapfile
: MDR-TAP ( -- cccc cccc )
    4 MDR-MODE !  0 MDR-RN !  0 MDR-ROWS !
    MDR-FN MDR-ZSTR  MDR-HOST MDR-ZSTR
    MDR-OPEN MDR-SCAN
    MDR-HOST MDR-HDR $06 F_OPEN  41 MDR-ERROR  MDR-OH !
    [ ' MDR-TAP1 ] LITERAL  1 MDR-LIST
    MDR-OH @ F_CLOSE  -1 MDR-OH !  42 MDR-ERROR
    MDR-CLOSE
;

.( .)

\ read and write the cartridge
: MDR-RD ( a n -- )
    MDR-FH @ F_READ  46 MDR-ERROR  DROP
;

: MDR-WR ( a n -- )
    MDR-FH @ F_WRITE  47 MDR-ERROR  DROP
;

\ open for reading and writing, and read the table
: MDR-RW ( -- )
    3 MDR-OPENM MDR-SCAN
    MDR-MAXH @ MDR-HEADP !
;

\ close the cartridge: only now the writes are safe
: MDR-DONE ( -- )
    MDR-FH @ F_CLOSE  -1 MDR-FH !  42 MDR-ERROR
    MDR-CLOSE
;

\ entry i is used and named as at a
: MDR-IS? ( i a -- f )
    OVER MDR-USED? IF
        SWAP MDR-NAME MDR-CMP 0=
    ELSE
        2DROP 0
    THEN
;

\ a file named as at a holds some byte, as mdr.pl means it
: MDR-HAVE? ( a -- f )
    -1 SWAP
    MDR-N @ 0 ?DO
        I OVER MDR-IS? IF  NIP I SWAP  LEAVE  THEN
    LOOP
    DROP
    DUP 0< IF  DROP 0  ELSE  MDR-SIZE OR 0= 0=  THEN
;

\ the file named as at a must exist
: MDR-MUST ( a -- )
    DUP MDR-HAVE? 0=  SWAP 43 MDR-MISS
;

\ the name at a must be free
: MDR-UNUSED ( a -- )
    DUP MDR-HAVE?  SWAP 4 MDR-MISS
;

\ the descriptor in MDR-BUF, from entry i, with its checksum
: MDR-SETDESC ( i -- )
    MDR-ENTRY 2+  MDR-BUF 15 +  14 CMOVE
    MDR-BUF 15 + 14 MDR-SUM  MDR-BUF 29 + C!
;

\ write descriptor, data and checksum in MDR-BUF to sector i
: MDR-SEC ( i -- )
    15 MDR-SEEK  MDR-BUF 15 +  528 MDR-WR
;

\ sector number n, if free
: MDR-FREE? ( n -- i -1 | 0 )
    MDR-MAP + C@
    DUP 255 = IF  DROP 0  EXIT  THEN
    DUP MDR-ENTRY 1+ C@ IF  DROP 0  ELSE  -1  THEN
;

\ how many free sectors can be reached
: MDR-FREES ( -- n )
    0  MDR-MAXH @ 1+ 1 ?DO
        I MDR-FREE? IF  DROP 1+  THEN
    LOOP
;

\ the next free sector, -1 if none: down from the head, and the head
\ goes two sectors further, for the motor latency
: MDR-FFREE ( -- i )
    -1  MDR-HEADP @
    MDR-MAXH @ 1+ 0 DO
        DUP MDR-FREE? IF
            ROT DROP SWAP
            2-  DUP 1 < IF  MDR-MAXH @ +  THEN  MDR-HEADP !
            0  LEAVE
        ELSE
            1-  DUP 1 < IF  DROP MDR-MAXH @  THEN
        THEN
    LOOP
    DROP
;

.( .)

\ free sector i, keeping its name and record number
: MDR-WIPE ( i -- )
    DUP MDR-ENTRY >R
    0 R@ 1+ C!  0 R@ 2+ C!  0 R> 4 + !
    MDR-BUF 30 + 513 ERASE
    DUP MDR-SETDESC  MDR-SEC
;

\ erase a file: MDR-ERASE cartridge name
: MDR-ERASE ( -- cccc cccc )
    MDR-FN MDR-ZSTR  MDR-PARSE
    MDR-RW
    MDR-WANT MDR-MUST
    MDR-N @ 0 ?DO
        I SHOW-PROGRESS
        I MDR-WANT MDR-IS? IF  I MDR-WIPE  THEN
    LOOP
    MDR-DONE
;

\ rename a file: MDR-RENAME cartridge name newname
: MDR-RENAME ( -- cccc cccc cccc )
    MDR-FN MDR-ZSTR  MDR-PARSE  MDR-TO MDR-PARSEA
    MDR-RW
    MDR-WANT MDR-MUST  MDR-TO MDR-UNUSED
    MDR-N @ 0 ?DO
        I SHOW-PROGRESS
        I MDR-WANT MDR-IS? IF
            MDR-TO  I MDR-NAME  10 CMOVE
            I MDR-SETDESC
            I 15 MDR-SEEK  MDR-BUF 15 +  15 MDR-WR
        THEN
    LOOP
    MDR-DONE
;

\ copy sector i of the wanted file to a free one, under the new name
: MDR-DUP1 ( i -- )
    DUP 15 MDR-SEEK  MDR-BUF 15 +  528 MDR-RD
    MDR-FFREE                                   \ i j
    SWAP MDR-ENTRY 2+  OVER MDR-ENTRY 2+  14 CMOVE
    MDR-TO  OVER MDR-NAME  10 CMOVE
    1  OVER MDR-ENTRY 1+  C!
    DUP MDR-SETDESC  MDR-SEC
;

\ copy the sectors holding record r
: MDR-DUPR ( r -- )
    MDR-N @ 0 ?DO
        I MDR-WANT MDR-IS? IF
            I MDR-ENTRY 3 + C@ OVER = IF  I MDR-DUP1  THEN
        THEN
    LOOP
    DROP
;

\ how many sectors the wanted file has, and its highest record number
: MDR-SPAN ( -- n r )
    0 0  MDR-N @ 0 ?DO
        I MDR-WANT MDR-IS? IF
            SWAP 1+ SWAP  I MDR-ENTRY 3 + C@ MAX
        THEN
    LOOP
;

\ copy a file on the cartridge: MDR-COPY cartridge name newname
: MDR-COPY ( -- cccc cccc cccc )
    MDR-FN MDR-ZSTR  MDR-PARSE  MDR-TO MDR-PARSEA
    MDR-RW
    MDR-WANT MDR-MUST  MDR-TO MDR-UNUSED
    MDR-SPAN  SWAP MDR-FREES SWAP U<  65 MDR-ERROR
    1+ 0 DO  I SHOW-PROGRESS  I MDR-DUPR  LOOP
    MDR-DONE
;

\ change the label, repeated in each sector: MDR-LABEL cartridge label
: MDR-LABEL ( -- cccc cccc )
    MDR-FN MDR-ZSTR  MDR-PARSE
    MDR-RW
    MDR-N @ 0 ?DO
        I SHOW-PROGRESS
        I 0 MDR-SEEK  MDR-BUF 15 MDR-RD
        MDR-WANT  MDR-BUF 4 +  10 CMOVE
        MDR-BUF 14 MDR-SUM  MDR-BUF 14 + C!
        I 0 MDR-SEEK  MDR-BUF 15 MDR-WR
    LOOP
    MDR-DONE
;

\ create an empty cartridge, which must not exist yet: MDR-NEW cartridge
: MDR-NEW ( -- cccc )
    MDR-FN MDR-ZSTR
    $06 MDR-OPENM
    254 0 DO
        I SHOW-PROGRESS
        MDR-BUF 543 ERASE
        1 MDR-BUF C!  254 I -  MDR-BUF 1+ C!
        MDR-BUF 4 + 10 BLANK
        MDR-BUF 14 MDR-SUM  MDR-BUF 14 + C!
        MDR-BUF 543 MDR-WR
    LOOP
    MDR-BUF 543 + 1 ERASE
    MDR-BUF 543 +  1 MDR-WR
    MDR-DONE
;

.( .)

\ record 0 of entry i into MDR-BUF
: MDR-READ0 ( i -- )
    30 MDR-SEEK  MDR-BUF 512 MDR-RD
;

\ entry i must be a program
: MDR-PROG ( i -- i )
    DUP MDR-READ0  DUP MDR-KIND  66 MDR-ERROR
;

\ write back record 0 of the program at entry i, with the autorun line n
: MDR-PATCH ( n i -- )
    SWAP  MDR-BUF 7 + !
    MDR-BUF 512 MDR-SUM  MDR-BUF 512 + C!
    30 MDR-SEEK  MDR-BUF 513 MDR-WR
;

\ the program can be started by LOAD from line n, in the current BASE:
\ MDR-AUTORUN cartridge name n
: MDR-AUTORUN ( -- cccc cccc cccc )
    MDR-FN MDR-ZSTR  MDR-PARSE
    BL WORD NUMBER DROP
    MDR-RW
    MDR-FIND MDR-PROG MDR-PATCH
    MDR-DONE
;

\ remove the autorun line, if any, from entry i, if it is a program
: MDR-UNAUTO ( i -- )
    DUP MDR-READ0
    DUP MDR-KIND IF  DROP  EXIT  THEN
    MDR-BUF 7 + @ 32768 U< IF  -1 SWAP MDR-PATCH  ELSE  DROP  THEN
;

\ no more autorun: MDR-NOAUTORUN cartridge name
\ the name * stands for all the programs
: MDR-NOAUTORUN ( -- cccc cccc )
    MDR-FN MDR-ZSTR  MDR-PARSE
    MDR-RW
    MDR-WANT C@ [CHAR] * =  MDR-WANT 1+ C@ BL =  AND IF
        MDR-N @ 0 ?DO
            I SHOW-PROGRESS
            I MDR-GRP C@ 1 AND IF
                I MDR-LOST? 0= IF  I MDR-UNAUTO  THEN
            THEN
        LOOP
    ELSE
        MDR-FIND MDR-PROG MDR-UNAUTO
    THEN
    MDR-DONE
;

\ correct the checksums of sector i, the data one if the sector is bad
: MDR-FIX1 ( i -- f )
    DUP MDR-FLAGS C@
    OVER MDR-ENTRY 1+ C@ 2 = IF  14  ELSE  6  THEN  AND
    DUP 0= IF  NIP  EXIT  THEN                  \ i mask
    OVER 0 MDR-SEEK  MDR-BUF 543 MDR-RD
    DUP 2 AND IF  MDR-BUF 14 MDR-SUM  MDR-BUF 14 + C!  THEN
    DUP 4 AND IF  MDR-BUF 15 + 14 MDR-SUM  MDR-BUF 29 + C!  THEN
        8 AND IF  MDR-BUF 30 + 512 MDR-SUM  MDR-BUF 542 + C!  THEN
    0 MDR-SEEK  MDR-BUF 543 MDR-WR
    -1
;

\ correct the wrong checksums and tell how many sectors changed:
\ MDR-FIX cartridge
: MDR-FIX ( -- cccc )
    MDR-FN MDR-ZSTR
    MDR-RW
    0  MDR-N @ 0 ?DO
        I SHOW-PROGRESS
        I MDR-FIX1 IF  1+  THEN
    LOOP
    MDR-DONE
    CR . S" sectors fixed" TYPE
;

.( .)

\ the sector being filled is done; f tells it ends the file
: MDR-FLUSH ( f -- )
    1 MDR-SECS +!  MDR-SECS @ SHOW-PROGRESS
    MDR-DRY @ IF  DROP  0 MDR-FILL !  EXIT  THEN
    2 AND  MDR-RF @ OR
    MDR-FFREE MDR-ENTRY >R
    R@ 2+ C!
    MDR-RECN @  R@ 3 + C!
    MDR-FILL @  R@ 4 + !
    MDR-WANT  R@ 6 +  10 CMOVE
    1 R@ 1+ C!
    MDR-BUF 30 + MDR-FILL @ +  512 MDR-FILL @ -  ERASE
    MDR-BUF 30 + 512 MDR-SUM  MDR-BUF 542 + C!
    R> MDR-TAB -  4 RSHIFT
    DUP MDR-SETDESC  MDR-SEC
    1 MDR-RECN +!  0 MDR-FILL !
;

\ put n bytes at a in the file being written; a full sector waits for
\ the next byte, since until then it might be the last one
: MDR-PUTS ( a n -- )
    BEGIN
        DUP
    WHILE
        MDR-FILL @ 512 = IF  0 MDR-FLUSH  THEN
        DUP  512 MDR-FILL @ -  MIN >R
        OVER  MDR-BUF 30 + MDR-FILL @ +  R@ CMOVE
        R@ MDR-FILL +!
        R@ -  SWAP R> +  SWAP
    REPEAT
    2DROP
;

: MDR-PUT1 ( c -- )
    MDR-C C!  MDR-C 1 MDR-PUTS
;

\ the file being written ends here
: MDR-EOF ( -- )
    MDR-FILL @ IF  2 MDR-FLUSH  THEN
;

: MDR-BLANKS ( n -- )
    0 ?DO  BL MDR-PUT1  LOOP
;

\ LF becomes CR, and CR+LF becomes CR
: MDR-TEXT ( a n -- )
    BOUNDS ?DO
        I C@  DUP 10 = IF
            DROP  MDR-WASCR @ 0= IF  13 MDR-PUT1  THEN  0
        ELSE
            DUP MDR-PUT1  13 =
        THEN
        MDR-WASCR !
    LOOP
;

\ a line, blank padded to 32 bytes
: MDR-PAD32 ( a n -- )
    TUCK MDR-PUTS  32 SWAP -  0 MAX MDR-BLANKS
;

\ the line is a "\ Screen# n" header
: MDR-SCR? ( a n -- f )
    DUP 11 < IF  2DROP 0  EXIT  THEN
    OVER 10 + C@  48 -  10 U< >R
    DROP 10  MDR-SCR COUNT COMPARE 0=  R> AND
;

\ the number at a, in n bytes
: MDR-SNUM ( a n -- u )
    0 -ROT  BOUNDS ?DO
        I C@ 48 -  DUP 10 U< IF
            SWAP 10 * +
        ELSE
            DROP LEAVE
        THEN
    LOOP
;

\ MDR-PUTBLOCK: complete the screen being written, blank the screens
\ that were skipped, and start screen u
: MDR-SCREEN ( u -- )
    16 MDR-ROWS @ -  0 MAX  32 * MDR-BLANKS
    BEGIN
        MDR-SCRN @ OVER U<
    WHILE
        512 MDR-BLANKS  1 MDR-SCRN +!
    REPEAT
    DROP
    0 MDR-ROWS !  1 MDR-SCRN +!
;

\ a line of MDR-PUTBLOCK: a header, or one of the 16 of a screen
: MDR-BROW ( a n -- )
    2DUP MDR-SCR? IF
        SWAP 10 +  SWAP 10 -  MDR-SNUM MDR-SCREEN
    ELSE
        MDR-ROWS @ 16 < IF
            MDR-PAD32  1 MDR-ROWS +!
        ELSE
            2DROP
        THEN
    THEN
;

: MDR-ROW-IN ( a n -- )
    MDR-MODE @ 3 = IF  MDR-BROW  ELSE  MDR-PAD32  THEN
;

\ the line in MDR-LN is complete: a CR before the LF does not count, and
\ empty lines wait for a line that is not, or they end the file unwritten
: MDR-EOLN ( -- )
    MDR-LN MDR-RN @
    DUP IF  2DUP + 1- C@ 13 = IF  1-  THEN  THEN
    DUP 0= IF
        2DROP  1 MDR-PEND +!
    ELSE
        MDR-PEND @ 0 ?DO  MDR-LN 0 MDR-ROW-IN  LOOP
        0 MDR-PEND !
        MDR-ROW-IN
    THEN
    0 MDR-RN !
;

\ a byte of a line; past 256 bytes they are lost
: MDR-CH ( c -- )
    DUP 10 = IF
        DROP MDR-EOLN
    ELSE
        MDR-RN @ 256 < IF
            MDR-LN MDR-RN @ + C!  1 MDR-RN +!
        ELSE
            DROP
        THEN
    THEN
;

: MDR-CHS ( a n -- )
    BOUNDS ?DO  I C@ MDR-CH  LOOP
;

\ read up to n bytes at a from the host file
: MDR-HR ( a n -- n2 )
    MDR-OH @ F_READ  46 MDR-ERROR
;

\ the whole host file through the filter of MDR-MODE
: MDR-FEED ( -- )
    0 MDR-FILL !  0 MDR-RECN !  0 MDR-SECS !
    0 MDR-RN !  0 MDR-PEND !  0 MDR-WASCR !
    16 MDR-ROWS !  1 MDR-SCRN !
    BEGIN
        MDR-IN  DUP 512 MDR-HR
        DUP
    WHILE
        MDR-MODE @ DUP 0= IF
            DROP MDR-PUTS
        ELSE
            1 = IF  MDR-TEXT  ELSE  MDR-CHS  THEN
        THEN
    REPEAT
    2DROP
    MDR-RN @ IF  MDR-EOLN  THEN
    MDR-EOF
;

\ run xt on the host file twice: first counting the sectors, then, if
\ they are there, writing them
: MDR-2PASS ( xt -- )
    MDR-HOST MDR-HDR 1 F_OPEN  41 MDR-ERROR  MDR-OH !
    1 MDR-DRY !  DUP EXECUTE
    MDR-FREES MDR-SECS @ U<  65 MDR-ERROR
    0 0 MDR-OH @ F_SEEK  45 MDR-ERROR
    0 MDR-DRY !  EXECUTE
    MDR-OH @ F_CLOSE DROP  -1 MDR-OH !
    MDR-DONE
;

\ a host file becomes a PRINT file: cartridge name hostfile;
\ n is how to read it, see MDR-MODE
: MDR-PUTFILE ( n -- cccc cccc cccc )
    MDR-MODE !  0 MDR-RF !
    MDR-FN MDR-ZSTR  MDR-PARSE  MDR-HOST MDR-ZSTR
    MDR-RW
    MDR-WANT MDR-UNUSED
    [ ' MDR-FEED ] LITERAL  MDR-2PASS
;

\ the bytes as they are: MDR-PUT cartridge name hostfile
: MDR-PUT ( -- cccc cccc cccc )
    0 MDR-PUTFILE
;

\ the line ends of a text: MDR-PUTTEXT cartridge name hostfile
: MDR-PUTTEXT ( -- cccc cccc cccc )
    1 MDR-PUTFILE
;

\ lines blank padded to 32 bytes: MDR-PUT32 cartridge name hostfile
: MDR-PUT32 ( -- cccc cccc cccc )
    2 MDR-PUTFILE
;

\ the same, by the "\ Screen# n" headers, each of 16 lines:
\ MDR-PUTBLOCK cartridge name hostfile
: MDR-PUTBLOCK ( -- cccc cccc cccc )
    3 MDR-PUTFILE
;

.( .)

\ warn if c is not the running xor of the .TAP block
: MDR-TCHK ( c -- )
    MDR-TX @ = 0=  MDR-DRY @ 0=  AND IF
        MDR-UNSPIN  CR MDR-WANT .MDR-NAME SPACE  34 MESSAGE
    THEN
;

\ the header block of a .TAP, flag read: the name and the 9 bytes that
\ will open record 0, in MDR-ROW; a type other than 0-3 is ignored
: MDR-THEAD ( -- )
    MDR-LN 18 MDR-HR DROP
    MDR-LN 1+  MDR-WANT  10 CMOVE
    MDR-LN 17 MDR-XOR MDR-TX !  MDR-LN 17 + C@ MDR-TCHK
    MDR-LN C@  DUP MDR-ROW C!
    MDR-LN 11 + @  MDR-ROW 1+ !
    DUP 0= IF
        23813 MDR-ROW 3 + !             \ the PROG of a 48K
        MDR-LN 15 + @  MDR-ROW 5 + !    \ vars offset
        MDR-LN 13 + @  MDR-ROW 7 + !    \ autostart line
    THEN
    DUP 1 =  OVER 2 =  OR IF
        -1 MDR-ROW 3 + !
        MDR-LN 13 + @  MDR-ROW 5 + !
        MDR-LN 15 + @  MDR-ROW 7 + !
    THEN
    DUP 3 = IF
        MDR-LN 13 + @  MDR-ROW 3 + !
        -1 MDR-ROW 5 + !  -1 MDR-ROW 7 + !
    THEN
    4 U< MDR-THAS !
;

\ u bytes of a data block, to the cartridge unless they are to be skipped
: MDR-TDATA ( u -- )
    BEGIN
        DUP
    WHILE
        DUP 512 U< IF  DUP  ELSE  512  THEN
        MDR-IN SWAP MDR-HR                      \ u n
        DUP 0= IF
            NIP
        ELSE
            MDR-IN OVER
            2DUP MDR-XOR  MDR-TX @ XOR  MDR-TX !
            MDR-SKIP @ IF  2DROP  ELSE  MDR-PUTS  THEN
            -
        THEN
    REPEAT
    DROP
;

\ the data block of u bytes that follows a header, and its checksum
: MDR-TFILE ( u -- )
    MDR-THAS @ 0=  MDR-SKIP !
    MDR-SKIP @ 0= IF
        MDR-WANT MDR-HAVE? IF
            1 MDR-SKIP !
            MDR-DRY @ 0= IF
                MDR-UNSPIN  CR MDR-WANT .MDR-NAME SPACE  4 MESSAGE
            THEN
        THEN
    THEN
    MDR-SKIP @ 0= IF
        0 MDR-FILL !  0 MDR-RECN !
        MDR-ROW 9 MDR-PUTS
    THEN
    255 MDR-TX !
    MDR-TDATA
    MDR-IN 1 MDR-HR IF  MDR-IN C@ MDR-TCHK  THEN
    MDR-SKIP @ 0= IF  MDR-EOF  THEN
    0 MDR-THAS !
;

\ the blocks of the host .TAP, one after the other
: MDR-TAPE ( -- )
    0 MDR-SECS !  0 MDR-THAS !
    BEGIN
        MDR-IN 3 MDR-HR 3 =  ?TERMINAL 0=  AND
    WHILE
        MDR-IN @  MDR-IN 2+ C@ 0=  OVER 19 =  AND IF
            DROP MDR-THEAD
        ELSE
            DUP 2 U< IF  DROP  ELSE  2- MDR-TFILE  THEN
        THEN
    REPEAT
;

\ the files of a .TAP on the cartridge; a name already there is skipped
\ with a warning: MDR-PUTTAP cartridge tapfile
: MDR-PUTTAP ( -- cccc cccc )
    4 MDR-RF !
    MDR-FN MDR-ZSTR  MDR-HOST MDR-ZSTR
    MDR-RW
    [ ' MDR-TAPE ] LITERAL  MDR-2PASS
;

\ the help lines of MDR, kept in the heap: an ha each, 0 at the end
CREATE MDR-HELP
    H" MDR-CAT        cartridge"                ,
    H" MDR-SECTORS    cartridge"                ,
    H" MDR-INFO       cartridge"                ,
    H" MDR-GET        cartridge name hostfile"  ,
    H" MDR-DUMP       cartridge name hostfile"  ,
    H" MDR-DUMP32     cartridge name hostfile"  ,
    H" MDR-DUMPBLOCK  cartridge name hostfile"  ,
    H" MDR-GETTAP     cartridge name tapfile"   ,
    H" MDR-TAP        cartridge tapfile"        ,
    H" MDR-NEW        cartridge"                ,
    H" MDR-LABEL      cartridge label"          ,
    H" MDR-ERASE      cartridge name"           ,
    H" MDR-RENAME     cartridge name newname"   ,
    H" MDR-COPY       cartridge name newname"   ,
    H" MDR-AUTORUN    cartridge name line"      ,
    H" MDR-NOAUTORUN  cartridge name|*"         ,
    H" MDR-FIX        cartridge"                ,
    H" MDR-PUT        cartridge name hostfile"  ,
    H" MDR-PUTTEXT    cartridge name hostfile"  ,
    H" MDR-PUT32      cartridge name hostfile"  ,
    H" MDR-PUTBLOCK   cartridge name hostfile"  ,
    H" MDR-PUTTAP     cartridge tapfile"        ,
    0 ,

\ NEEDS MDR loads this module
: MDR ( -- )
    MDR-HELP
    BEGIN
        DUP @ ?DUP
    WHILE
        CR FAR COUNT TYPE  2+
    REPEAT
    DROP
;

BASE !
