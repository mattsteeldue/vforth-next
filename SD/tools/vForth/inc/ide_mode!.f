\
\ ide_mode!.f
\
.( IDE_MODE! )
\
\ Set current NextBasic display mode
\
: IDE_MODE! ( n -- )      
    >R 0 0 R> 1
    $01D5 M_P3DOS 
    #44 ?ERROR
    2DROP 2DROP 
    VIDEO
;

\ ____________________________________________________________________
\
\ 00 : Layer 0    - Standard Spectrum (ULA) mode, 256 w x 192 h pixels, 
\      8 colors total (2 intensities), 32 x 24 cells, 2 colors per cell 
\       
\ 10 : Layer 1,0  - LoRes (Enhanced ULA) mode, 128 w x 96 h pixels, 
\      256 colors total, 1 colour per pixel
\
\ 11 : Layer 1,1  - Standard Res (Enhanced ULA) mode, 256 w x 192 h pixels,
\      256 colors total, 32 x 24 cells, 2 colors per cell
\
\ 12 : Layer 1,2  - Timex HiRes (Enhanced ULA) mode, 512 w x 192 h pixels,
\      256 colors total, only 2 colors on whole screen
\
\ 13 : Layer 1,3  - Timex HiColour (Enhanced ULA) mode, 256 w x 192 h pixels,
\      256 colors total, 32 x 192 cells, 2 colors per cell
\
\ 20 : Layer 2    - 256 w x 192 h pixels, 
\      256 colors total, one colour per pixel
