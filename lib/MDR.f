\
\ lib/MDR.f
\
\ v-Forth 1.8 - NextZXOS version - build 2026-10-24
\ MIT License (c) 1990-2026 Matteo Vitturi
\
\ Read-only access to ZX Microdrive cartridge images (.MDR files):
\ catalogue, sector map and extraction of a single file to the SD card.
\ A Forth port of the read side of mdr.pl, rev. 2022-12-01
\ ( https://github.com/mattsteeldue/zxmdr ), .TAP output excluded.
\
\ Usage:
\   MDR-CAT  M2.MDR                     \ catalogue of the cartridge
\   MDR-SECTORS  M2.MDR                 \ sectors of each file, free ones
\   MDR-INFO  M2.MDR                    \ one line per sector
\   MDR-GET  M2.MDR  !Blocks  BLK.TXT   \ extract !Blocks to BLK.TXT
\   MDR-DUMP  M1.MDR  run  RUN.BIN      \ the same, raw bytes only
\   MDR-DUMP32  M2.MDR  !Blocks  B.TXT  \ raw, a line every 32 bytes
\   MDR-DUMPBLOCK  M2.MDR  !Blocks  B.F \ and "\ Screen# n" every 16 lines
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
\ about 6K of free dictionary space are needed while a word is running,
\ nothing afterwards.
\
\ Error messages used (all already in the block file):
\   #2  Dictionary full: less than 6K free above HERE
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

\ what an extracting word writes: 0 get, 1 dump, 2 dump32, 3 dumpblock
\ and the line of 32 bytes being filled, with its count and the lines done
VARIABLE MDR-MODE
CREATE   MDR-ROW    32 ALLOT
VARIABLE MDR-RN
VARIABLE MDR-ROWS
CREATE   MDR-SCR    ," \ Screen# "
CREATE   MDR-EOL    10 C,

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

\ there must be room for all of it below the stack
: MDR-ROOM ( -- )
    SP@ MDR-BUF 1250 + U< 2 ?ERROR
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
    MDR-LABEL 10 BLANK
    MDR-NLAB @ IF  MDR-ML @ MDR-LAB  MDR-LABEL  10 CMOVE  THEN
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
    254 0 DO
        MDR-BUF 543 MDR-FH @ F_READ  46 MDR-ERROR
        543 < IF
            LEAVE
        ELSE
            I MDR-KEEP  I 1+ MDR-N !
        THEN
    LOOP
    MDR-WPROT  MDR-MASTER  MDR-MARK
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

: .MDR-TYPE ( n -- )
    DUP 0 = IF  ." Prog"  THEN
    DUP 1 = IF  ." Numb"  THEN
    DUP 2 = IF  ." Char"  THEN
    DUP 3 = IF  ." Code"  THEN
    DUP 4 = IF  ." Scrn"  THEN
        5 = IF  ." Prnt"  THEN
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
        I 8 = IF  DROP  ."  ... "  LEAVE  THEN
        I IF  [CHAR] , EMIT  THEN
        DUP MDR-LAST !  3 MDR-Z.
    LOOP
    2DROP
;

\ a file that has lost its record 0: type Bad!, 512 bytes a sector
: MDR-LOST ( i -- )
    ." Bad!"  DUP 1 MDR-CNT 512 UM*  8 D.R SPACE  MDR-NAME .MDR-NAME
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
            4 SPACES  MDR-BUF 5 + C@ 64 + 127 AND EMIT  ." ()"
        THEN
        MDR-K @ 2 = IF
            3 SPACES  MDR-BUF 5 + C@ 127 AND EMIT  ." $()"
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
    CR ." Free"
    2DUP MDR-CNT 512 UM*  2DUP MDR-ER 2@ D+ MDR-ER 2!  8 D.R SPACE
    OVER MDR-NAME .MDR-NAME
    DUP IF  SPACE  ELSE  [CHAR] - EMIT  THEN
    ."  sect: "  MDR-SECTS
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
    512 0 D+  1024 UM/MOD NIP  6 MDR-U.R  ."  K"
;

\ the bad sectors, one a line; the highest is the tape junction
: MDR-BADS ( -- )
    MDR-N @ 0 ?DO
        I MDR-ENTRY 1+ C@ 2 = IF
            CR ." Bad " 512 8 MDR-U.R  13 SPACES
            I MDR-ENTRY C@  DUP 0 MDR-U.R
            MDR-MAXH @ = IF  ."  tape-junction"  THEN
        THEN
    LOOP
;

\ totals; with f, also the bytes of the erased files
: MDR-TOTALS ( f -- )
    0 0  MDR-N @ 0 DO
        I MDR-USED? IF  I MDR-ENTRY 4 + @ 0 D+  THEN
    LOOP
    CR  2DUP 12 D.R ."  total used  " MDR-KB
    IF  MDR-ER 2@  CR  2DUP 12 D.R ."  total erased" MDR-KB  THEN
    2 MDR-COUNT  CR  2DUP 12 D.R ."  total bad   " MDR-KB
    0 MDR-COUNT  CR  2DUP 12 D.R ."  total free  " MDR-KB
    MDR-WARN @ IF  CR MDR-WARN @ . ." sectors: " 34 MESSAGE  THEN
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
    CR ." Header: " MDR-LABEL .MDR-NAME
    MDR-WP @ IF  ."  (write protected)"  THEN
    MDR-NLAB @ 1 > IF
        MDR-NLAB @ 0 DO
            I MDR-RANKED  CR 8 SPACES  DUP MDR-LAB .MDR-NAME
            ."  (" MDR-LAB 10 + @ . ." times)"
        LOOP
    THEN
    CR
;

\ catalogue of the cartridge named next
: MDR-CAT ( -- cccc )
    MDR-FN MDR-ZSTR
    MDR-OPEN MDR-SCAN
    MDR-HEADER
    CR ." Type   Bytes Filename    Addr. Actual   Vars   Line"
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
    CR ." Type   Bytes Filename   Sector used"
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
        2DROP DROP  ."  bad"
    ELSE
        SWAP IF
            DUP 4 AND 0= IF  ."  PRN"  THEN
            2 AND IF  ."  EOF"  THEN
            14
        ELSE
            DROP  ."  free"  6                 \ data of a free sector
        THEN                                    \ i mask
        SWAP MDR-FLAGS C@  DUP ROT AND
        DUP 2 AND IF  ."  hd!"  THEN
        DUP 4 AND IF  ."  de!"  THEN
            8 AND IF  ."  da!"  THEN
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
    CR ." Sec Rec Fl Len  Filename"
    MDR-N @ 0 ?DO
        I MDR-ILINE
        ?TERMINAL IF  LEAVE  THEN
    LOOP
    CR
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
\ or the bytes only are wanted;
\ the header is built from the detail of record 0, still in MDR-BUF
: MDR-CREATE ( -- )
    MDR-HDR 8 ERASE
    MDR-K @ 5 <  MDR-MODE @ 0=  AND IF
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
    MDR-MODE @ 2 < IF  MDR-W  ELSE  MDR-ROWS-W  THEN
;

\ extract a file from a cartridge: cartridge name hostfile;
\ n is what to write, see MDR-MODE
: MDR-EXTRACT ( n -- cccc cccc cccc )
    MDR-MODE !  0 MDR-RN !  0 MDR-ROWS !
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
    MDR-RN @ IF  MDR-ROW-OUT  THEN
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

\ NEEDS MDR loads this module
: MDR ( -- )
    CR ." MDR-CAT        cartridge"
    CR ." MDR-SECTORS    cartridge"
    CR ." MDR-INFO       cartridge"
    CR ." MDR-GET        cartridge name hostfile"
    CR ." MDR-DUMP       cartridge name hostfile"
    CR ." MDR-DUMP32     cartridge name hostfile"
    CR ." MDR-DUMPBLOCK  cartridge name hostfile"
;

BASE !
