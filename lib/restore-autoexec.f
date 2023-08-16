\
\ restore-autoexec.f
\
\    ##  USE WITH CARE  ##


\ First check there is NOOP 
' ABORT >BODY 9 CELLS + @
' NOOP - 14 ?ERROR

\ Then restore AUTOEXEC
' AUTOEXEC
' ABORT >BODY 9 CELLS + !


