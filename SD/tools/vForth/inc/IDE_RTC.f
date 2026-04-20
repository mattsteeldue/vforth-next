\
\ ide_rtc.f
\
.( IDE_RTC )
\
\ real-time-clock module not present
\
NEEDS .FAT-TIME
NEEDS .FAT-DATE

: IDE_RTC ( -- 100ths time date )      
    0 0 0 0 
    $01cc M_P3DOS 
    0= #56 ?ERROR
;

