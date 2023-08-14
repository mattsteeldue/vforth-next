\
\ abort~.f
\
\
.( ABORT" )
\

NEEDS S"

\
\ Used inside a colon-definition in the form
\   
\    flag  ABORT" message"
\
\ at run-time flag is evaluated, and if it's non-zero prints the message
\ and executes ABORT to return to command-prompt.
\
: ABORT" ( f -- ccc )
    [COMPILE]  IF
    [COMPILE]     S" 
     COMPILE      TYPE
     COMPILE      -1
     COMPILE      ERROR
    [COMPILE]  THEN
;
IMMEDIATE
