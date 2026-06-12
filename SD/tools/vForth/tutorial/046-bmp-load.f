\
\ 046-bmp-load.f
\ Loading BMP images into Layer 2 memory with BMP-LOAD.
\
\ lib/bmp-load.f provides BMP-LOAD which reads a 256x192 256-color
\ Windows BMP file from the SD card directly into the Layer 2 frame
\ buffer.  The word handles page mapping via MMU7, validates the BMP
\ header, and supports both top-down and bottom-up BMP orientations
\ (determined by the sign of the vertical size field in the header).
\
\ Reference: sec.7.2
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   046 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 046 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 046: BMP image loading loaded. ) CR
.(     Type NEWTASK to unload.             ) CR

NEEDS GRAPHICS

\ ===========================================================================
\ 1. BMP file requirements
\ ===========================================================================
\
\ The BMP file must satisfy all of the following:
\   - Signature "BM" at offset 0
\   - Width  = 256 pixels   (horizontal size at offset $12)
\   - Height = 192 pixels   (vertical size at offset $16, signed)
\   - Color depth = 8 bits per pixel (256-color indexed)
\   - Standard Windows BMP format (BITMAPINFOHEADER)
\
\ The sign of the height field at $16 determines pixel order:
\   Positive height (bottom-up BMP): rows stored from bottom to top
\   Negative height (top-down BMP):  rows stored from top to bottom
\ BMP-LOAD handles both orientations automatically.
\
\ Error codes thrown on failure:
\   38 ($26) : not a valid BMP (bad signature or wrong size)
\   39 ($27) : wrong image dimensions
\   41 ($29) : file open error
\   45 ($2D) : file seek error
\   46 ($2E) : file read error
\   42 ($2A) : file close error

\ ===========================================================================
\ 2. BMP-LOAD -- load BMP into Layer 2
\ ===========================================================================
\
\   BMP-LOAD ( a -- )
\
\   a : address of a "counted-z string" (length byte + text + NUL)
\       as produced by ," or PAD followed by string setup
\
\ BMP-LOAD internally:
\   1. Opens the file
\   2. Reads the 50-byte BMP header to PAD
\   3. Validates signature, width (256), height (192)
\   4. Seeks to the pixel data offset (from header field at $0A)
\   5. Reads 6 groups of 32 rows, mapping the correct Layer 2 8K
\      page into MMU7 for each group
\   6. Closes the file
\
\ After BMP-LOAD, the Layer 2 frame buffer contains the image.
\ Call LAYER2 before BMP-LOAD if you want it to be visible, or
\ call LAYER2 after loading to reveal the image.

\ ===========================================================================
\ 3. BMP-LOAD" -- inline string version
\ ===========================================================================
\
\   BMP-LOAD" filename"    (immediate word, works at interpret time)
\
\ At interpret time:
\   BMP-LOAD" C:/pics/scene.bmp"
\
\ At compile time (inside a : definition):
\   : SHOW-SCENE  BMP-LOAD" C:/pics/scene.bmp" ;
\
\ BMP-LOAD" handles the string setup internally.

\ ===========================================================================
\ 4. Demo: load and display a BMP file
\ ===========================================================================
\
\ To run this demo, place a suitable BMP on the SD card:
\   - Width 256, height 192, 8bpp (256-color)
\   - Saved as C:/demos/test256.bmp
\
\ Then execute:
\   SHOW-BMP

NEEDS WAIT-KEY

: SHOW-BMP  ( -- )
    LAYER2
    CLS
    ." Loading image..." CR
    BMP-LOAD" C:/demos/test256.bmp"
    ." Done. Press any key." CR
    WAIT-KEY DROP
    LAYER0
    CLS
;

\ ===========================================================================
\ 5. Demo: load BMP using a counted-z string variable
\ ===========================================================================
\
\ A counted-z string variable is created with ," inside CREATE:
\
\   CREATE MY-BMP  ," C:/pics/sky.bmp"
\
\ The layout in memory:
\   byte 0    : string length (not including NUL)
\   bytes 1.. : the characters
\   final byte: NUL ($00)
\
\ Pass the variable address to BMP-LOAD:
\   MY-BMP BMP-LOAD
\
\ This is useful when the filename is stored in a variable.

CREATE DEMO-FILE  ," C:/demos/demo.bmp"

: LOAD-DEMO  ( -- )
    LAYER2
    DEMO-FILE BMP-LOAD
    WAIT-KEY DROP
    LAYER0  CLS
;

\ ===========================================================================
\ 6. Demo: BMP slide show
\ ===========================================================================

CREATE SLIDE-A  ," C:/slides/slide1.bmp"
CREATE SLIDE-B  ," C:/slides/slide2.bmp"
CREATE SLIDE-C  ," C:/slides/slide3.bmp"

: SLIDE-SHOW  ( -- )
    LAYER2
    SLIDE-A BMP-LOAD  WAIT-KEY DROP
    SLIDE-B BMP-LOAD  WAIT-KEY DROP
    SLIDE-C BMP-LOAD  WAIT-KEY DROP
    LAYER0  CLS
;

\ ===========================================================================
\ 7. Palette notes
\ ===========================================================================
\
\ BMP files have their own 256-color palette (stored in the header).
\ BMP-LOAD does NOT upload the BMP palette to the ZX Next hardware.
\ The image uses whatever palette is currently active on the Next.
\
\ The default Next palette maps indices to RRRGGGBB colors.
\ For correct display, the BMP palette should match the ZX Next
\ default palette, or you need to upload the BMP palette to the
\ Next's palette registers ($40/$41) separately.
\
\ ATTRIB after BMP-LOAD is unchanged; set it before drawing over
\ the image.

\ ===========================================================================
\ 8. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ BMP-LOAD requires an SD card and specific files.
\ Only structural tests are possible here.
\
\ NEEDS TESTING
\ T{  DEMO-FILE C@  ->  20  }T    \ "C:/demos/demo.bmp" length
