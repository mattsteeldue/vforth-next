\ 
\ raycast.x
\

\ porting to vForth of page  https:\ lodev.org/cgtutor/raycasting.html

needs graphics
needs flip

marker this \ you can run "this" to restore memory to this poing

 128  constant screenWidth 
  64  constant screenHeight 
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


\ fetch from map-array
: worldMap@ ( y x -- )
    mapWidth * +  
    worldMap +  C@
;


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
    dup 0< if
        [char] - emit 
        abs
    else
        [char] + emit
    then
    dup [ hex ] 0FF00 AND flip 0 <# # # # #> TYPE
    [char] . emit
    [ decimal ] 1000 256 */ 0 <# # # # #> TYPE SPACE 
;

decimal

: milli  ( n1 -- n2 )
    256 1000 */
;


screenWidth  constant  w
screenHeight constant  h

2 >float    constant  2.00
1 >float    constant  1.00
w >float    constant  w.00
h >float    constant  h.00

4           constant  4
6           constant  6

decimal

\ vars

\ x and y start position
variable posX   decimal   20 >float posX !
variable posY   decimal   12 >float posY !  

\ initial direction vector
variable dirX    -866 milli  dirX !
variable dirY    -500 milli  dirY !  

\  0.66 the 2d raycaster version of camera plane
variable planeX   -500 milli  planeX !
variable planeY    866 milli  planeY ! 

variable time      0  time !  \ time of current frame
variable oldTime   0  time !  \ time of previous frame


\ x-coordinate in camera space
variable cameraX    \ cameraX = 2 * x / double(w) - 1; \ x-coordinate in camera space
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

variable hit        \ = 0; \ was there a wall hit?
variable side       \ ; \ was a NS or a EW wall hit?

variable lineHeight \ = (int)(h / perpWallDist);
variable drawStart  \ = -lineHeight / 2 + h / 2;
variable drawEnd    \ = lineHeight / 2 + h / 2;


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

    ." rayDirX      " rayDirX   @  f.  6 emitc
    ." rayDirY      " rayDirY   @  f.  cr
    ." cameraX      " cameraX   @  f.  cr

\ which box of the map we're in
    ." mapX         " mapX      @  4 .r  6 emitc
    ." mapY         " mapY      @  4 .r cr

\ length of ray from current position to next x or y-side
    ." sideDistX    " sideDistX @  f.  6 emitc
    ." sideDistY    " sideDistY @  f.  cr

\ length of ray from one x or y-side to next x or y-side
    ." deltaDistX   " deltaDistX @  f.  6 emitc
    ." deltaDistY   " deltaDistY @  f.  cr

    ." lineHeight   " lineHeight @  4 .r  6 emitc \ = (int)(h / perpWallDist);
    ." perpWallDist " perpWallDist @  f.  cr

\ what direction to step in x or y-direction (either +1 or -1)
    ." stepX        " stepX     @  4 .r  6 emitc
    ." stepY        " stepY     @  4 .r  cr

    ." hit          " hit       @  4 .r  6 emitc
    ." side         " side      @  4 .r  cr

    ." drawStart    " drawStart  @  4 .r  6 emitc \ = -lineHeight / 2 + h / 2;
    ." drawEnd      " drawEnd    @  4 .r  cr      \ = lineHeight / 2 + h / 2;
;


\ calculate ray position and direction
: ray-pos-direction ( n -- )
    >float  2.00   w.00   */  1.00  -  
    cameraX !  \ double cameraX = 2 * x / (double)w - 1;  x-coordinate in camera space  
    cameraX @  planeX @  1.00 */  dirX @  +  rayDirX ! \ double rayDirX = dirX + planeX * cameraX;
    cameraX @  planeY @  1.00 */  dirY @  +  rayDirY ! \ double rayDirY = dirY + planeY * cameraX;

    \ which box of the map we're in
    posX @  >int  flip  mapX ! \ int mapX = int(posX);
    posY @  >int  flip  mapY ! \ int mapY = int(posY);

    \ length of ray from one x or y-side to next x or y-side
    \ these are derived as:
    \ deltaDistX = sqrt(1 + (rayDirY * rayDirY) / (rayDirX * rayDirX))
    \ deltaDistY = sqrt(1 + (rayDirX * rayDirX) / (rayDirY * rayDirY))
    \ which can be simplified to abs(|rayDir| / rayDirX) and abs(|rayDir| / rayDirY)
    \ where |rayDir| is the length of the vector (rayDirX, rayDirY). Its length,
    \ unlike (dirX, dirY) is not 1, however this does not matter, only the
    \ ratio between deltaDistX and deltaDistY matters, due to the way the DDA
    \ stepping further below works. So the values can be computed as below.
    \  Division through zero is prevented, even though technically that's not
    \  needed in C++ with IEEE 754 floating point values.
    1.00 1.00  rayDirX @  */  abs  deltaDistX ! \ double deltaDistX = (rayDirX == 0) ? 1e30 : std::abs(1 / rayDirX);
    1.00 1.00  rayDirY @  */  abs  deltaDistY ! \ double deltaDistY = (rayDirY == 0) ? 1e30 : std::abs(1 / rayDirY);

    \ what direction to step in x or y-direction (either +1 or -1)
    \ find sideDistX    
    rayDirX @  0< if
        -1 stepX !
        posX @  mapX @ >float  -  deltaDistX @  1.00  */  
        sideDistX ! \ sideDistX = (posX - mapX) * deltaDistX; 
    else
        1 stepX !
        mapX @ >float  1.00  +  posX @  -  deltaDistX @  1.00  */  
        sideDistX ! \ sideDistX = (mapX + 1.0 - posX) * deltaDistX;
    then

    \ find sideDistY    
    rayDirY @ 0< if
        -1 stepY !
        posY @  mapY @ >float  -  deltaDistY @  1.00  */  
        sideDistY ! \ sideDistY = (posY - mapY) * deltaDistY;
    else
        1 stepY !
        mapY @ >float  1.00  +  posY @  -  deltaDistY @  1.00  */  
        sideDistY ! \ sideDistY = (mapY + 1.0 - posY) * deltaDistY;
    then
;


\ perform DDA
: perform-DDA ( -- )
    0 hit !     \ was there a wall hit?
    begin
        \ jump to next map square, either in x-direction, or in y-direction
        sideDistX @  sideDistY @  <
        if
            deltaDistX @  sideDistX +!  \ sideDistX += deltaDistX;
            stepX @  mapX +!            \ mapX += stepX;
            0 side !                    \ side = 0;
        else
            deltaDistY @  sideDistY +!  \ sideDistY += deltaDistY;
            stepY @  mapY +!            \ mapY += stepY;
            1 side !                    \ 1 side !
        then
        \ Check if ray has hit a wall 
        mapX @   mapY @   worldMap@     \ if(worldMap[mapX][mapY] > 0) hit = 1;
        0> if
            1 hit !
        then
        \ 
        hit @  
    until
;


\ take-distance     
\ Calculate distance projected on camera direction. This is the shortest distance from the point where the wall is
\ hit to the camera plane. Euclidean to center camera point would give fisheye effect!
\ This can be computed as (mapX - posX + (1 - stepX) / 2) / rayDirX for side == 0, or same formula with Y
\ for size == 1, but can be simplified to the code below thanks to how sideDist and deltaDist are computed:
\ because they were left scaled to |rayDir|. sideDist is the entire length of the ray above after the multiple
\ steps, but we subtract deltaDist once because one step more into the wall was taken above.
: take-distance
    side @ if
        sideDistY @  deltaDistY @  -   perpWallDist !   \ if(side == 0) perpWallDist = (sideDistX - deltaDistX);
    else
        sideDistX @  deltaDistX @  -   perpWallDist !   \ else          perpWallDist = (sideDistY - deltaDistY);
    then
;


: calc-line
    \ Calculate height of line to draw on screen
    h.00  1.00  perpWallDist @  */  >int flip  lineHeight !  \ int lineHeight = (int)(h / perpWallDist);
    
    \ calculate lowest and highest pixel to fill in current stripe
    lineHeight @ negate  2/  h  +  2/       \ int drawStart = -lineHeight / 2 + h / 2;
    0 max drawStart !                       \  if(drawStart < 0) drawStart = 0;
    lineHeight @         2/  h  +  2/       \ if(drawEnd >= h) drawEnd = h - 1;
    h 1- min  drawEnd !                     \ if(drawEnd >= h) drawEnd = h - 1;
;


\ draw-frame
: draw-frame ( -- )
    w  w negate do 
        i  ray-pos-direction
        perform-DDA
        take-distance
        calc-line

        mapY @   mapX @   worldMap@   
        side @ 1 - if
             dup * 1+ \ if(side == 1) {color = color / 2;}
        then
        to ATTRIB
        drawStart @ i drawEnd @ i draw-line

    loop
;


\ main
: main ( -- )
    layer10
    cls
    begin
        draw-frame 
        ?terminal \ done
    until
    layer12
    cls
; 

decimal
