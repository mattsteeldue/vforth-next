Forth on Sinclair ZX Spectrum Next

vForth1.413n

On April 27th 2020, I received my  ZX Spectrum Next  (Accelerated)  and immediately tried to port my Forth to the Next environment. 
The purpose was to make Screens / BLOCKs system available using ZxNextOS APIs. 
Having done it in the past for ZX Microdrive and MGT Disciple floppy diskette  I really thought it was worth give a try on ZxNextOs.
I'm putting here the version that are stable enough to be published.

Screens are stored in a file inside the SD card called "!Blocks.txt" 8 MBytes long and it can hold 16.384 Screens (while MGT version can hold 1.560 and Microdrive 254 only). 

In this implementation a Screen is equivalent to a BLOCK that is 512 bytes, for backward compatibility reasons.

Among the other things, I implemented an ASSEMBLER vocabulary with Z80N extension op-codes with custom notation as explained in Wiki pages.  
