\
\ M_GETDATE.f
\

BASE @

\ Get the current date/time from the Real Time Clock, if present.
\ date = date in MS-DOS format
\ time = time in MS-DOS format (2-sec precision)
\ hs   = packed cell: high byte = seconds (1-sec precision),
\        low byte = 100ths of second (or $FF if not supported by the
\        RTC module); decode with SPLIT (gives 100ths then seconds)
\ f = 0 on success (RTC present, valid date/time), True flag on error
\ On error, date and time are both returned as 0; hs is undefined.
\
( M_GETDATE  via RST 08 hook $8E )
CODE M_GETDATE ( -- date time hs f )

    HEX
    DD C, E5 C,         \  push  ix|
    D5 C,               \  push  de|             \ save Return Stack Pointer
    C5 C,               \  push  bc|             \ save Instruction Pointer

    F3 C,               \  di
    CF C, 8E C,         \  rst   08|   $8E C,
    FB C,               \  ei

    D9 C,               \  exx                   \ hide bc/de/hl (date/time/hs) away
    C1 C,               \  pop   bc|             \ restore Instruction Pointer
    D1 C,               \  pop   de|             \ restore Return Stack Pointer
    DD C, E1 C,         \  pop   ix|              \ restore ix
    D9 C,               \  exx                   \ bring date/time/hs back

    C5 C,               \  push  bc|             \ date
    D5 C,               \  push  de|             \ time
    E5 C,               \  push  hl|             \ hs (secs/100ths, packed)
    D9 C,               \  exx                   \ restore true ip/rp to view

    ED C, 62 C,         \  sbchl hl|
    E5 C,               \  push  hl|
    DD C, E9 C,         \  Next

    FORTH
    SMUDGE

BASE !
