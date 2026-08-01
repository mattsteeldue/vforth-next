\
\ ide_rtc.f
\
.( IDE_RTC )
\
\ real-time-clock module not present
\

: IDE_RTC ( -- 100ths time date )      
    0 0 0 0 
    $01CC M_P3DOS 
    2DROP
;

