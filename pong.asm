.model small
.stack 100h

.data
message db "hello world",0dh,0ah,'$'
ball_posx dw 0ah    ;ball position x
ball_posy dw 0ah    ;ball pos y
ball_dimension dw 05h    ; 5 x 5 pixels
ball_vx dw 01h  ;velocity of x pos
ball_vy dw 01h  ;velocity of y pos
ball_color db 0eh

;according to video specs
screenwidth dw 320
screenheight dw 200

;bat dimensions
bat_width dw 10
bat_height dw 50
bat_color db 0fh

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
        cmp counter , 60
        jg update
        inc counter
        ;rendering of the ball and bats should go below here.
        call renderball
        ;call renderbats
        call renderbatsleft
        jmp update_delay

    ;while(not quit)
    ;renderdraw();
    ;update();
    ;renderclear()
    ;check quit()
    update:
        mov counter , 0
        call moveball
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


renderbats proc ;render the bats

    mov dx , bat_posy_left  ;initialize ball position
    mov cx , bat_posx_left  ;iniitalize ball position

renderbat_y_left:
        sub ax,ax           ;clear register
        mov ax, bat_posy_left 
        add ax , bat_height
        cmp dx , ax            ;if (dx == bat_posy+bat_dimension) 
        je finishrenderbats       ;go ahead and render the other bat
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


;render the right hand side bat
    mov dx , bat_posy_right  ;initialize ball position
    mov cx , bat_posx_right  ;iniitalize ball position


finishrenderbats:
ret
renderbats endp


renderbatsleft proc

renderbat_y_right:
        sub ax,ax           ;clear register
        mov ax, bat_posy_right 
        add ax , bat_height
        cmp dx , ax            ;if (dx == bat_posy+bat_dimension) 
        je finishrenderbatsright       ;else loop is ,rendering completed for both bats
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

finishrenderbatsright:
ret
renderbatsleft endp

moveball proc
    mov ax,ball_vx  
    add ball_posx , ax  ;ballposx = ballposx + ball_vx
    mov ax,ball_vy      ;ballposx = ballposx + ball_vx
    add ball_posy,ax
    ret
moveball endp


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