\
\ M_GETSETDRV.f
\

BASE @

\ Get or set the default drive.
\ b1 = 0 to get the current default drive
\ b1 <> 0 to set the default drive; bits 7..3 = drive letter (0=A...15=P),
\         bits 2..0 are ignored (use 1 to ensure a is non-zero)
\ b2 = default drive, encoded as bits 7..3 = drive letter, bits 2..0 = 0
\ return 0 on success, True flag on error
\
\ NOTE: setting the default drive here does not change NextBASIC's own
\ LOAD/SAVE drives (LODDRV/SAVDRV); most calls needing a drive accept
\ '*' (default) or '$' (system) directly and do not require this call.
\
( M_GETSETDRV  via RST 08 hook $89 )
CODE M_GETSETDRV ( b1 -- b2 f )

    HEX
    E1 C,               \  pop   hl|              \ hl = byte b1
    DD C, E5 C,         \  push  ix|
    D5 C,               \  push  de|              \ save Return Stack Pointer
    C5 C,               \  push  bc|              \ save Instruction Pointer
    7D C,               \  ld    a'|   l|         \ a = entry value

    \ for dot-command compatibility
    E5 C,               \  push  hl|
    DD C, E1 C,         \  pop   ix|

    F3 C,               \  di
    CF C, 89 C,         \  rst   08|   $89 C,
    FB C,               \  ei

    C1 C,               \  pop   bc|              \ restore Instruction Pointer
    D1 C,               \  pop   de|              \ restore Return Stack Pointer
    DD C, E1 C,         \  pop   ix|               \ restore ix

    6F C,               \  ld    l'|   a|         \ l = a2, returned drive code
    26 C, 00 C,         \  ldn   h'|   0 N,       \ h = 0, zero-extend
    E5 C,               \  push  hl|              \ a2

    ED C, 62 C,         \  sbchl hl|
    E5 C,               \  push  hl|
    DD C, E9 C,         \  Next

    FORTH
    SMUDGE

BASE !
