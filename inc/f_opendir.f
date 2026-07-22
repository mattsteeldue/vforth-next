\
\ f_opendir.f
\
.( F_OPENDIR )
\
\ EXPERIMENTAL redefinition -- shadows the core F_OPENDIR. Must be loaded
\ with INCLUDE, never NEEDS: the core word already satisfies NEEDS's
\ already-in-dictionary check, so NEEDS would silently skip this file.
\
\ Adds a wildcard parameter and requests esx_mode_use_wildcards ($20) on
\ top of the core's esx_mode_lfn_only ($10), so NextZXOS filters directory
\ entries itself. The SAME wildcard z-string must then be passed as a2 to
\ the core F_READDIR on every call -- the core word already threads a2
\ into DE correctly for the syscall, so no shadow redefinition of
\ F_READDIR is needed, and no Forth-side WILDCARD? matching either.
\
\ Self-contained: does not jr into the core's shared F_Open_Exit/F_Read_Exit
\ (their addresses are internal to the compiled core, not safely
\ referenceable from here) -- the small exit sequence is duplicated inline,
\ verified instruction-for-instruction against project/vForth18_DOES/source
\ /next-opt0.asm. The core's "dot-command compatibility" HL override
\ (push hl / pop ix right before the syscall) is intentionally NOT
\ reproduced -- unverified for dot-command invocation; interactive use only.
\

BASE @
HEX

\ given a z-string address a and a null-terminated wildcard z-string wc,
\ open a file-handle to the directory, requesting OS-side wildcard
\ filtering. Return 0 on success, True flag on error.
CODE F_OPENDIR  ( a wc -- fh f )

    E1 C,               \ pop     hl          hl = wc (wildcard z-string)
    DD C, E3 C,         \ ex      (sp),ix     ix = a  (directory path)
    D5 C,               \ push    de          save real RSP
    C5 C,               \ push    bc          save real IP
    EB C,               \ ex      de,hl       de = wc
    06 C, 30 C,         \ ld      b,$30       lfn_only | use_wildcards
    3E C, 43 C,         \ ld      a,'C'       default drive
    F3 C,               \ di
    CF C, A3 C,         \ rst     $08 / $A3   F_OPENDIR syscall
    5F C,               \ ld      e,a         e = handle / errcode
    16 C, 00 C,         \ ld      d,$00
    FB C,               \ ei
    D9 C,               \ exx
    C1 C,               \ pop     bc
    D1 C,               \ pop     de
    DD C, E1 C,         \ pop     ix
    D9 C,               \ exx
    D5 C,               \ push    de          fh
    ED C, 62 C,         \ sbc     hl,hl       flag
    E5 C,               \ push    hl
    D9 C,               \ exx
    DD C, E9 C,         \ jp      (ix)        NEXT

    SMUDGE

BASE !
