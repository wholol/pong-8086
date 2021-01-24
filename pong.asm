.model small
.stack 100h

.data
ball_posx dw 0a0h    ;ball position x
ball_posy dw 0a0h    ;ball pos y
ball_resetposx dw 0a0h 
ball_resetposy dw 0a0h 
ball_dimension dw 05h    ; 5 x 5 pixels
ball_vx dw 01h  ;velocity of x pos
ball_vy dw 01h  ;velocity of y pos
ball_color db 0eh

;according to video specs (int 10h)
screenwidth dw 320
screenheight dw 200

;player scores
left_player_score dw 0
right_player_score dw 0 

;bat dimensions
bat_width dw 10
bat_height dw 50
bat_color db 0fh
bat_vy dw 05h

;left side bat
bat_posx_left dw 10  ;pos x = width for left handside
bat_posy_left dw 75    ;initialize bat to center of screen (screenheight - height) / 2

;right side bat
bat_posx_right dw 310  ;pos x = width for left handside = (screenwidth - bat_width)
bat_posy_right dw 75    ;initialize bat to center of screen (screenheight - height) / 2

counter dw 0            ;coutner fro game loop delay

.code 

main proc 
    sub ax,ax
    mov ax,@data
    mov ds,ax
   call clearscreen 

gameloop:
    update_delay:       ;prevent the ball from moving too fast
        cmp counter , 10
        jg update
        inc counter
        ;rendering of the ball and bats should go below here.
        call renderball     ;render ball
        call renderbatLHS   ;render lhs bat
        call renderbatRHS   ;render rhs bat
        call userLHSinput   
        call userRHSinput
        jmp update_delay

    ;while(not quit)
    ;renderdraw();
    ;update();
    ;renderclear()
    ;check quit()
    update:
        mov counter , 0
        call collisionbatRHS
           ;check colision agaisnt right bat
        call collisionbatLHS   ;check collision against left bat
        call wallcollisioncheck ;check collision against wall
        call moveball
        call resetball
        

        call clearscreen
        jmp gameloop
main endp



renderball proc
    mov dx , ball_posy  ;initialize ball position
    mov cx , ball_posx  ;iniitalize ball position
renderball_y:
        sub ax,ax           ;clear register
        mov ax, ball_posy  
        add ax , ball_dimension 
        cmp dx , ax            ;if (ball_posy == ballposy+balldimnesion) 
        je finishrenderball       ;else loop is done
        sub cx , cx            ;clear register
        mov cx , ball_posx      ;iniitalize ball position
        mov ah,0ch              ;read graphics pixels
        mov al, bat_color       ;set color of ball
        mov bh, 00h             
        inc dx      ;calls vales in register dx,cx and plots onto screen (do not )
        int 10h 
        
        renderball_x:
               mov ah,0ch  ;read graphics pixels
               mov al,ball_color  ;set color of ball
               mov bh,00h 
               int 10h
               inc cx 
               sub ax,ax     
               mov ax, ball_posx
               add ax , ball_dimension
               cmp cx , ax 
               jne renderball_x ;if (cx != bat_posx + ball_dimensions, repeat.)
               je renderball_y  ;else go back to render y
       
finishrenderball:
ret
renderball endp



renderbatLHS proc ;render the left hand side bat
    mov dx , bat_posy_left  ;initialize ball position
    mov cx , bat_posx_left  ;iniitalize ball position

renderbat_y_left:
        sub ax,ax           ;clear register
        mov ax, bat_posy_left 
        add ax , bat_height
        cmp dx , ax            ;if (dx == bat_posy+bat_dimension) 
        je finishrenderbatLHS       ;go ahead and render the other bat
        sub cx , cx                 ;clear register
        mov cx , bat_posx_left      ;reiniitalize position of xpos
        mov ah,0ch                  ;read graphics pixels
        mov al,bat_color       ;set color of ball
        mov bh, 00h             
        inc dx      
        int 10h 
        
        renderbat_x_left:
               mov ah,0ch  ;read graphics pixels
               mov al,bat_color  ;set color of ball
               mov bh,00h 
               int 10h
               dec cx   ;decrement, since position of bat starts from rhs
               sub ax,ax     
               mov ax, 0
               cmp cx , ax 
               jne renderbat_x_left ;if (cx != 0 (since bat pos is top right), repeat.)
               je renderbat_y_left  ;else go back to render y

finishrenderbatLHS:
ret
renderbatLHS endp



renderbatRHS proc  ;render the right hand side bat
    mov dx , bat_posy_right  ;initialize ball position
    mov cx , bat_posx_right  ;iniitalize ball position
renderbat_y_right:
        sub ax,ax           ;clear register
        mov ax, bat_posy_right 
        add ax , bat_height
        cmp dx , ax            ;if (dx == bat_posy+bat_dimension) 
        je finishrenderbatRHS ;else loop is ,rendering completed for both bats
        sub cx , cx            ;clear register
        mov cx , bat_posx_right      ;reiniitalize position of xpos
        mov ah,0ch              ;read graphics pixels
        mov al,bat_color        ;set color of bat
        mov bh, 00h             
        inc dx      
        int 10h 
        renderbat_x_right:
               mov ah,0ch  ;read graphics pixels
               mov al,bat_color  ;set color of ball
               mov bh,00h 
               int 10h
               inc cx 
               sub ax,ax     
               mov ax, screenwidth
               cmp cx , ax 
               jne renderbat_x_right ;if (cx != screenwidth , repeat.)
               je renderbat_y_right  ;else go back to render y

finishrenderbatRHS:
ret
renderbatRHS endp



moveball proc
    mov ax,ball_vx  
    add ball_posx , ax  ;ballposx = ballposx + ball_vx
    mov ax,ball_vy      ;ballposx = ballposx + ball_vx
    add ball_posy,ax
    ret
moveball endp



userLHSinput proc

    mov ah , 01h    ;check if any keys are pressed, prevents blocking
    int 16h
    jz exitLHSinput

    mov ah,00h
    int 16h ;poll for keyboard input, the ascii input is stored in al register
    cmp al, 077h    ;077h = ascii for 'w'
    je  movebatupLHS
    cmp al, 073h    ;073h ascii for 's'
    jne exitLHSinput
    je movebatdownLHS
    
exitLHSinput:
ret
userLHSinput endp



movebatupLHS proc   
    cmp bat_posy_left , 0   ;if (batpost == 0)
    je exitmovebatupLHS
    mov ax , bat_vy   
    sub bat_posy_left , ax  ;posy_up -= bat_vy (y coordinates are 0,0 top left)
    
exitmovebatupLHS:
    ret
movebatupLHS endp



movebatdownLHS proc
    mov ax , screenheight   
    sub ax,bat_height       ;screenheight - bat height
    cmp bat_posy_left , ax ;if (batposy >= screenheright - bat height)
    jge exitmovebatdownLHS
    mov ax , bat_vy    
    add bat_posy_left , ax  ;posy_down -= ball_vy (y coordinates are 0,0 top left)

exitmovebatdownLHS:
    ret
movebatdownLHS endp



userRHSinput proc
    cmp al, 06fh    ;077h = ascii for 'o'
    je  movebatupRHS
    cmp al, 06ch    ;073h ascii for 'l'
    jne exitRHSinput
    je movebatdownRHS
    
exitRHSinput:
ret
userRHSinput endp



movebatupRHS proc
    cmp bat_posy_right , 0  ;clamp position to zero
    je  exitmovebatupRHS
    mov ax , bat_vy  
    sub bat_posy_right , ax  ;posy_up -= bat_vy (y coordinates are 0,0 top left)

exitmovebatupRHS:
    ret
movebatupRHS endp



movebatdownRHS proc
    mov ax , screenheight   
    sub ax,bat_height       ;screenheight - bat height
    cmp bat_posy_right , ax ;if (batposy >= screenheright - bat height)
    jge exitmovebatdownRHS
    mov ax , bat_vy    
    add bat_posy_right , ax  ;posy_down -= ball_vy (y coordinates are 0,0 top left)
    
exitmovebatdownRHS:
    ret
movebatdownRHS endp



wallcollisioncheck proc
    ;prevent ball going below screen
    mov ax, screenheight
    sub ax , ball_dimension
    cmp ball_posy , ax  ;check if (ballposy < screenheight - ball_dimension)
    jl collidetop
    mov ax,ball_vy
    mov bx,-1   
    imul bx     ;flip the velocity,this gets stored in ax
    mov ball_vy,ax    ;realod back into ball posy

collidetop:
   ;;prevent ball going above screen
   mov ax , 0      
   cmp ball_posy, ax
   jg exitwallcollisioncheck
   mov ax, ball_vy
   mov bx, -1
   imul bx
   mov ball_vy,ax


exitwallcollisioncheck:
ret
wallcollisioncheck endp



collisionbatRHS proc
   ;first compare xpos
   mov ax, ball_posx
   add ax , ball_dimension
   inc ax
   cmp bat_posx_right,ax    ;if (batposx_right == ballposx + ball_dimension + 1)
   jne exithitright
   jmp checkupperboundright

checkupperboundright:            ;ballposy < bat_height + batposy for collision
    mov ax,bat_posy_right
    add ax , bat_height
    cmp ball_posy , ax   
    jl checklowerboundright
    jmp exithitright         ;if ballposy > bat_height + bat_width, no hit.

checklowerboundright:    ;ballposy + ball dimensions > bat pos y as well for collision
    mov ax , ball_posy      
    add ax , ball_dimension ;ballposy + ball dimensions
    cmp bat_posy_right , ax  
    jl hitrightbat           ;if its greater, it means the bat has hit it.
    jg exithitright

hitrightbat:
     mov ax,ball_vx
     mov bx,-1   
     imul bx            ;flip the velocity,this gets stored in ax
     mov ball_vx,ax    ;realod back into ball posy
     jmp exithitright

exithitright:
ret
collisionbatRHS endp



collisionbatLHS proc   ;check collsiino for left bat
   ;first compare xpos
   mov ax, ball_posx
   dec ax
   cmp bat_posx_left,ax    ;if (batposx_left == ballposx - 1)
   jne exithitleft
   jmp checkupperboundleft

checkupperboundleft:            ;ballposy < bat_height + batposy for collision
    mov ax,bat_posy_left
    add ax , bat_height
    cmp ball_posy , ax   
    jl checklowerboundleft
    jmp exithitleft         ;if ballposy > bat_height + bat_width, no hit.

checklowerboundleft:    ;ballposy + ball dimensions > batposy as well for collision
    mov ax , ball_posy      
    add ax , ball_dimension ;ballposy + ball dimensions
    cmp bat_posy_left , ax  
    jl hitleftbat           ;if its greater, it means the bat has hit it.
    jg exithitleft

hitleftbat:
     mov ax,ball_vx
     mov bx,-1   
     imul bx            ;flip the velocity,this gets stored in ax
     mov ball_vx,ax    ;realod back into ball posy
     jmp exithitleft

exithitleft:
ret
collisionbatLHS endp



resetball proc  ;resets if the users misses

call resetLHS

resetLHS:
    mov ax , bat_posx_left
    cmp ball_posx , ax   
    jl incrementscore_RHS        ;if ballposx < bat_posx_left, icnrement score of rght side palyer
    jmp resetRHS

incrementscore_RHS:
inc right_player_score
jmp resetballpos

resetRHS:
    mov ax , ball_posx
    add ax , ball_dimension
    cmp bat_posx_right , ax 
    jle incrementscore_LHS    ; if ballposx + balldimensions >= bat_posx_right icnrement score of rght side palyer
    jmp exitresetball

incrementscore_LHS:
inc left_player_score  
jmp resetballpos

resetballpos:       ;reset ball position
    mov ax , ball_resetposx
    mov ball_posx , ax
    mov ax , ball_resetposy
    mov ball_posy , ax

exitresetball:
ret
resetball endp



clearscreen proc ;clear screen
    mov ah,00h
    mov al,13h
    int 10h
    mov ah,0bh
    mov bh, 00h
    mov bl, 00h
    int 10h
    ret
clearscreen endp




end