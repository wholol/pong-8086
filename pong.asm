.model small
.stack 100h

.data
message db "hello world",0dh,0ah,'$'
ball_posx dw 0ah    ;ball position x
ball_posy dw 0ah    ;ball pos y
ball_dimension dw 05h    ; 5 x 5 pixels
ball_vx dw 01h  ;velocity of x pos
ball_vy dw 01h  ;velocity of y pos
ball_color dw 0eh

counter dw 0
.code 

main proc 
    sub ax,ax
    mov ax,@data
    mov ds,ax
   call clearscreen 

gameloop:
    update_delay:
        cmp counter , 100
        jg update
        inc counter
        ;rendering should go below here.
        call renderball
        jmp delay

    ;while(not quit)
    ;renderdraw();
    ;update();
    ;renderclear()
    ;check quit()
    update:
        mov i , 0
        call moveball
        call clearscreen
        jmp gameloop
main endp





renderball proc
    mov dx , ball_posy  ;initialize ball position
    mov cx , ball_posx  ;iniitalize ball position
render_y:
        sub ax,ax           ;clear register
        mov ax, ball_posy  
        add ax , ball_dimension 
        cmp dx , ax            ;if (ball_posy == ballposy+balldimnesion) 
        je finishrender       ;else loop is done
        sub cx , cx            ;clear register
        mov cx , ball_posx      ;iniitalize ball position
        mov ah,0ch              ;read graphics pixels
        mov al,ball_color       ;set color of ball
        mov bh, 00h             
        inc dx      ;calls vales in register dx,cx and plots onto screen (do not )
        int 10h 
        
        render_x:
               mov ah,0ch  ;read graphics pixels
               mov al,ball_color  ;set color of ball
               mov bh,00h 
               int 10h
               inc cx 
               sub ax,ax     
               mov ax, ball_posx  
               add ax , ball_dimension 
               cmp cx , ax 
               jne render_x ;if (cx != ballposx + balldimension, repeat.)
               je render_y  ;else go back to render y
       
finishrender:
ret
renderball endp


moveball proc
    mov ax,ball_vx
    add ball_posx , ax
    ;mov ax,ball_vy
    ;add ball_posy,ax
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