Forth on Sinclair ZX Spectrum Next

vForth1.52

On April 27th 2020, I received my  ZX Spectrum Next  (Accelerated)  and immediately tried to port my Forth to the Next environment. 
The purpose was to make Screens / BLOCKs system available using ZxNextOS APIs. 
Having done it in the past for ZX Microdrive and MGT Disciple floppy diskette  I really thought it was worth give a try on ZxNextOs.
I'm putting here the version stable enough to be published, along with any evolution and improvement.

Screens are stored in a single file inside the SD card called "!Blocks.txt", 16 MBytes long, that it can hold 16.383 Screens 1 KB each 
Previous MGT or Microdrive version had 512 Bytes Screens and just 1.560 or 254x7 = 1.778 Screens, respectively. 
In this latest implementation a Screen is 1024 Bytes, that is two 512 bytes BLOCKs, accessed using ZxNextOS APIs. 
A "Full Screen Editor" facility - EDIT - provides a way to view and edit a Screen at a time.
A "Large file EDitor" LED, that uses all RAM availabler, provides a way to edit any source file up to 17.500 text lines, 85 characters each row.

All 1.792K user RAM is made available through MMU7 on which any 8K-page can be fitted in à-la "EMS" way.
For String storage purpose, an HEAP facility grants access to 64K of space via FAR and POINTER definitions.

A new  MOUSE  library has been introduced to provide a "interrupt-driven" mouse arrow-pointer to interact with your Forth application.
Then a new  AY  library is working-in-progress to be used along.

I implemented an  ASSEMBLER  vocabulary with a peculiar notation, gracefully adapted for FORTH systems, as explained in Wiki pages 
<https://github.com/mattsteeldue/forth-next/wiki>. This ASSEMBLER provides the newest Z80N extension op-codes.

The Documentation, the Wiki in this repository are getting shape, I suggesto to pay a visit.
