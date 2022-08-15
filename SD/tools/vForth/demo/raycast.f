\ 
\ raycast.x
\

\ porting to vForth of page  https://lodev.org/cgtutor/raycasting.html

needs graphics
needs flip

marker this \ you can run "this" to restore memory to this poing

 64  constant screenWidth 
 32  constant screenHeight 
 24  constant mapWidth 
 24  constant mapHeight 

\ WorldMap 24 x 24 grid
HERE
  1 C, 1 C, 1 C, 1 C, 1 C, 1 C, 1 C, 1 C, 1 C, 1 C, 1 C, 1 C, 1 C, 1 C, 1 C, 1 C, 1 C, 1 C, 1 C, 1 C, 1 C, 1 C, 1 C, 1 C, 
  1 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 1 C, 
  1 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 1 C, 
  1 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 1 C, 
  1 C, 0 C, 0 C, 0 C, 0 C, 0 C, 2 C, 2 C, 2 C, 2 C, 2 C, 0 C, 0 C, 0 C, 0 C, 3 C, 0 C, 3 C, 0 C, 3 C, 0 C, 0 C, 0 C, 1 C, 
  1 C, 0 C, 0 C, 0 C, 0 C, 0 C, 2 C, 0 C, 0 C, 0 C, 2 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 1 C, 
  1 C, 0 C, 0 C, 0 C, 0 C, 0 C, 2 C, 0 C, 0 C, 0 C, 2 C, 0 C, 0 C, 0 C, 0 C, 3 C, 0 C, 0 C, 0 C, 3 C, 0 C, 0 C, 0 C, 1 C, 
  1 C, 0 C, 0 C, 0 C, 0 C, 0 C, 2 C, 0 C, 0 C, 0 C, 2 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 1 C, 
  1 C, 0 C, 0 C, 0 C, 0 C, 0 C, 2 C, 2 C, 0 C, 2 C, 2 C, 0 C, 0 C, 0 C, 0 C, 3 C, 0 C, 3 C, 0 C, 3 C, 0 C, 0 C, 0 C, 1 C, 
  1 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 1 C, 
  1 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 1 C, 
  1 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 1 C, 
  1 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 1 C, 
  1 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 1 C, 
  1 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 1 C, 
  1 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 1 C, 
  1 C, 4 C, 4 C, 4 C, 4 C, 4 C, 4 C, 4 C, 4 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 1 C, 
  1 C, 4 C, 0 C, 4 C, 0 C, 0 C, 0 C, 0 C, 4 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 1 C, 
  1 C, 4 C, 0 C, 0 C, 0 C, 0 C, 5 C, 0 C, 4 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 1 C, 
  1 C, 4 C, 0 C, 4 C, 0 C, 0 C, 0 C, 0 C, 4 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 1 C, 
  1 C, 4 C, 0 C, 4 C, 4 C, 4 C, 4 C, 4 C, 4 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 1 C, 
  1 C, 4 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 1 C, 
  1 C, 4 C, 4 C, 4 C, 4 C, 4 C, 4 C, 4 C, 4 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 0 C, 1 C, 
  1 C, 1 C, 1 C, 1 C, 1 C, 1 C, 1 C, 1 C, 1 C, 1 C, 1 C, 1 C, 1 C, 1 C, 1 C, 1 C, 1 C, 1 C, 1 C, 1 C, 1 C, 1 C, 1 C, 1 C, 
constant worldMap

\ 8.8 fixed floating point

\ truncate to integer a 8.8
: >int ( 8.8 -- n )
    [ hex ] 0FF00 and
;

\ convert a byte to 8.8-float
: >float ( n -- 8.8 )
    flip >int
;

: f. ( 8.8 -- )
    dup >int flip 3 .R
    [char] . emit
    [ hex ] 0FF AND  [ decimal ] 1000 256 */  U.
;

screenWidth constant  w
2 >float    constant  2.00
1 >float    constant  1.00
w >float    constant  w.00

decimal

\ vars

\ x and y start position
variable posX   decimal   22 >float posX !
variable posY   decimal   12 >float posY !  

\ initial direction vector
variable dirX      -1 dirX !
variable dirY      0  dirY !  

\  0.66 the 2d raycaster version of camera plane
variable planeX    0  planeX !
variable planeY    1.00  2 3 */  planeY ! 

variable time      0  time !  \ time of current frame
variable oldTime   0  time !  \ time of previous frame


\ x-coordinate in camera space
variable cameraX    \ cameraX = 2 * x / double(w) - 1; //x-coordinate in camera space
variable rayDirX    \ rayDirX = dirX + planeX * cameraX
variable rayDirY    \ rayDirY = dirY + planeY * cameraX;

\ which box of the map we're in
variable mapX       \ mapX = int(posX);
variable mapY       \ mapY = int(posY);

\ length of ray from current position to next x or y-side
variable sideDistX
variable sideDistY

\ length of ray from one x or y-side to next x or y-side
variable deltaDistX     \ = (rayDirX == 0) ? 1e30 : std::abs(1 / rayDirX);
variable deltaDistY     \ = (rayDirY == 0) ? 1e30 : std::abs(1 / rayDirY);
variable perpWallDist

\ what direction to step in x or y-direction (either +1 or -1)
variable stepX
variable stepY

variable hit        \ = 0; //was there a wall hit?
variable side       \ ; //was a NS or a EW wall hit?

: vars
    cr
    \ x and y start position
    ." posX         " posX      @  f.  6 emitc
    ." posY         " posY      @  f.  cr

    \ initial direction vector
    ." dirX         " dirX      @  f.  6 emitc
    ." dirY         " dirY      @  f.  cr

    ." planeX       " planeX    @  f.  6 emitc
    ." planeY       " planeY    @  f.  cr

    ." cameraX      " cameraX   @  f.  6 emitc
    ." rayDirX      " rayDirX   @  f.  cr
    ." rayDirY      " rayDirY   @  f.  cr

\ which box of the map we're in
    ." mapX         " mapX      @  3 .r  6 emitc
    ." mapY         " mapY      @  3 .r cr

\ length of ray from current position to next x or y-side
    ." sideDistX    " sideDistX @  f.  6 emitc
    ." sideDistY    " sideDistY @  f.  cr

\ length of ray from one x or y-side to next x or y-side
    ." deltaDistX   " deltaDistX @  f.  6 emitc
    ." deltaDistY   " deltaDistY @  f.  cr

    ." perpWallDist " perpWallDist @  f.  cr

\ what direction to step in x or y-direction (either +1 or -1)
    ." stepX        " stepX     @  3 .r  6 emitc
    ." stepY        " stepY     @  3 .r  cr

    ." hit          " hit       @  3 .r  6 emitc
    ." side         " side      @  3 .r  cr
;


\ perform DDA
: perform-DDA ( -- )
    begin
        hit @  0= 
    while 
        \ jump to next map square, either in x-direction, or in y-direction
        sideDistX @  sideDistY @  <
        if
            deltaDistX @  sideDistX +! 
            stepX @  mapX +! 
            0 side !
        else
            deltaDistY @  sideDistY +!
            stepY @  mapY +!
            1 side !
        then
        \ Check if ray has hit a wall
        mapX @  mapWidth *  mapY @   +  worldMap +  C@
        0> if
            1 hit !
        then
    repeat
;


\ calculate ray position and direction
: ray-pos-direction ( -- )
    2.00   i  w.00   */  1.00  -  
    cameraX !  \ x-coordinate in camera space  
    cameraX @  planeX @  *  dirX @  +  rayDirX !
    cameraX @  planeY @  *  dirY @  +  rayDirY !

    \ which box of the map we're in
    posX @  >int  mapX !
    posY @  >int  mapY !

    \ length of ray from one x or y-side to next x or y-side
    1.00 rayDirX @  /  abs  deltaDistX !
    1.00 rayDirY @  /  abs  deltaDistY !

    \ what direction to step in x or y-direction (either +1 or -1)
    0 hit !     \ was there a wall hit?
    
    \ find sideDistX    
    rayDirX @  0< if
        -1 stepX !
        posX @  mapX @  -  deltaDistX @  *  sideDistX !
    else
        1 stepX !
        mapX @  1.00  +  posX @  -  deltaDistX @  *  sideDistX !
    then

    \ find sideDistY    
    rayDirY @ 0< if
        -1 stepY !
        posY @  mapY @  -  deltaDistY @  *  sideDistY !
    else
        1 stepY !
        mapY @  1.00  +  posY @  -  deltaDistY @  *  sideDistY !
    then
;


\ draw-frame
: draw-frame ( -- )
    w.00  0  do 

        ray-pos-direction
        perform-DDA

    1.00 +loop
;


\ main
: main ( -- )
\   layer10
    cls
    begin
        draw-frame 
        ?terminal
    until
\   layer12
    cls
; 

decimal
