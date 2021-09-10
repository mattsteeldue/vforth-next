2021-08-10

ON REAL Sinclair ZX Spectrum Next
---------------------------------

1. Intall, just copy SD/tools/vForth content into SD  at C:/tools/vForth
   or extract the very same content from the latest vforth-next/download/vForth_15e*.zip file

2. Run, from File-Browser execute the Basic program C:/tools/vForth/Forth15_Loader.bas



ON EMULATOR CSpect
------------------

The operations of points 1. and 2. has to be performed within an SD image like   tbblue.mmc  



DEBIAN / UBUNTU / LINUX-LITE
----------------------------

Install the latest  "Mono"  cross platform open source .NET framework

  $ sudo apt install mono-complete

start CSpect

  $ mono CSpect.exe -sound -tv -w3  -zxnext -nextrom  -mmc=./tbblue.mmc



WINDOWS / MACOS / ..
--------------------
THere is a very nice quickstart guide by marco's retrobits
https://retrobits.altervista.org/blog/dogday-cspect-quickstart/



