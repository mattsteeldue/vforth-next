Forth on Sinclair ZX Spectrum Next

vForth1.5

On April 27th 2020, I received my  ZX Spectrum Next  (Accelerated)  and immediately tried to port my Forth to the Next environment. 
The purpose was to make Screens / BLOCKs system available using ZxNextOS APIs. 
Having done it in the past for ZX Microdrive and MGT Disciple floppy diskette  I really thought it was worth give a try on ZxNextOs.
I'm putting here the version that are stable enough to be published.

Screens are stored in a file inside the SD card called "!Blocks.txt" 16 MBytes long and it can hold 16.383 1KiB-Screens (while MGT version and Microdrive - 512 Byte Screens - can hold 1.560 and 254 x 7 = 1.778 respectively). In this latest implementation a Screen is 1024 bytes (at last), two BLOCKs 512 bytes each and accessed using ZxNextOS APIs. A "Full Screen Editor" facility - EDIT - provides a way to view and edit a Screen at a time.

Large 1.792K RAM is made available through MMU7 on which any 8K-page can be fitted in à-la "EMS" way.
For String storage purpose, an HEAP facility grants access to 64K of space via FAR and POINTER definitions.

A "Large file EDitor" LED, that uses all RAM availabler, provides a way to edit any source file up to 17.500 text lines, 85 characters each row.

I implemented an ASSEMBLER vocabulary with notation, gracefully adapted for FORTH systems, as explained in Wiki pages <https://github.com/mattsteeldue/forth-next/wiki>.  
This ASSEMBLER provides the newest Z80N extension op-codes.

The Wiki in this repository is getting some shape, I suggesto to pay a visit.
