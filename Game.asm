[org 0x0100]
jmp start
;used for collision
end_flag: dw 0
codes:dw 17,35,24,46
score:              dw 0
oldisr:             dd 0
current_lane_pos:   db 2

;used for random logic
lane1_cnt:     db 0
lane2_cnt:     db 0
lane3_cnt:     db 0

lane1_rows_cleared:  db 0
lane2_rows_cleared:  db 0
lane3_rows_cleared:  db 0

temp:db 0

;used by timer
r1:     dw 12345
ticks:         dw 0
tickcount:     dw 0
rand_lane:     db 0
scroll_counter:dw 0

;CAR GENERIC
stripe: dw 17,40,24
tyrel:dw 46,34,18,22
rhead: dw 42,44
lhead:dw 37,39
last: dw 47

;crystal tick count
crystal_ticks dw 0    ; Separate counter for crystals (54 ticks)

;PAUSING AND RESUMING
green : db 0
paused:db 0
screen_buffer: times 2000 dw 0

;paused screen 
score_msg   db "SCORE: ",0
esc_msg     db "PRESS ESC TO Exit Game",0
n_msg       db "PRESS R TO RESUME Game",0


;saving old isr
old_timer_isr   dd 0      ; IRQ0
old_kb_isr      dd 0      ; IRQ1

;START SCREEN DATA 
title_msg       db "Madni Shapatar", 0
semester_msg    db "SEMESTER: 3 ", 0
group_msg       db "GROUP MEMBERS", 0
member1_name    db "[Scarlett Witch]", 0
member1_roll    db "[24L-0786]", 0
member2_name    db "[Hawk Eye]", 0
member2_roll    db "[24L-3066]", 0
start_msg       db "PRESS ANY KEY TO START...", 0

;END SCREEN DATA 
gameover_msg    db "GAME OVER!", 0
final_score_msg db "YOUR SCORE: ", 0
thanks_msg      db "THANKS FOR PLAYING!", 0
exit_msg        db "PRESS ANY KEY TO EXIT...", 0

;if user wants to quit from pause page
exit_confirm_msg db "ARE YOU SURE YOU WANT TO EXIT?", 0
exit_confirm_len equ 31
yn_msg          db "PRESS Y FOR YES, N FOR NO", 0
yn_msg_len      equ 25

clrscr:
    push ax
    push es
    push di
    push cx
    mov ax,0xb800
    mov es,ax
    mov di,0
    mov ax,0x0720
    mov cx,2000
clr_Loop:
    mov word[es:di],ax
    add di,2
    loop clr_Loop
    pop cx
    pop di
    pop es
    pop ax
    ret

LeftGreenBelt:
    push ax
    push es
    push di
    push bx
    push si
    mov ax,0xb800
    mov es,ax
    mov di,0
    mov bx,0
    mov si,0
Left_Green_Belt_Loop:
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
    mov word[es:di],0x2020
    inc si
    cmp si,14
    jnz Left_Green_Belt_Loop
    inc bx
    mov si,0
    cmp bx,25
    jnz Left_Green_Belt_Loop
    pop si
    pop bx
    pop di
    pop es
    pop ax
    ret

RightGreenBelt:
    push ax
    push es
    push di
    push bx
    push si
    mov ax,0xb800
    mov es,ax
    mov di,0
    mov bx,0
    mov si,66
Right_Green_Belt_Loop:
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
    mov word[es:di],0x22db
    inc si
    cmp si,80
    jnz Right_Green_Belt_Loop
    inc bx
    mov si,66
    cmp bx,25
    jnz Right_Green_Belt_Loop
    pop si
    pop bx
    pop di
    pop es
    pop ax
    ret

LeftBeltBorder:
    push ax
    push es
    push si
    push bx
    push di
    mov ax,0xb800
    mov es,ax
    mov bx,0
    mov si,14
yellowbrick:
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
    mov word[es:di],0x0EDB
    inc si
    cmp si,16
    jnz yellowbrick
    mov si,14
    add bx,2
    cmp bx,26
    jnz yellowbrick
    pop di
    pop bx
    pop si
    pop es
    pop ax
    ret

RightBeltBorder:
    push ax
    push es
    push si
    push bx
    push di
    mov ax,0xb800
    mov es,ax
    mov bx,0
    mov si,64
rightyellowbrick:
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
    mov word[es:di],0x0EDB
    inc si
    cmp si,66
    jnz rightyellowbrick
    mov si,64
    add bx,2
    cmp bx,26
    jnz rightyellowbrick
    pop di
    pop bx
    pop si
    pop es
    pop ax
    ret

LaneMap:
    push ax
    push bx
    push si
    push di
    push es
    mov ax,0xb800
    mov es,ax
    mov bx,0
    mov si,16
Lane_Map:
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
    mov word[es:di],0x08B2
    inc bx
    cmp bx,25
    jnz Lane_Map
    mov bx,0
    inc si
    cmp si,64
    jnz Lane_Map
    pop es
    pop di
    pop si
    pop bx
    pop ax
    ret

LeftMiddleLaneBorder:
    push ax
    push bx
    push si
    push di
    push es
    mov ax,0xb800
    mov es,ax
    mov bx,0
    mov si,32
Left_Middle_Lane_Border:
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
    mov word[es:di],0x0fDB
    add bx,2
    cmp bx,26
    jnz Left_Middle_Lane_Border
    pop es
    pop di
    pop si
    pop bx
    pop ax
    ret

MiddleRightLaneBorder:
    push ax
    push bx
    push si
    push di
    push es
    mov ax,0xb800
    mov es,ax
    mov bx,0
    mov si,48
Middle_Right_Lane_Border:
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
    mov word[es:di],0x0fDB
    add bx,2
    cmp bx,26
    jnz Middle_Right_Lane_Border
    pop es
    pop di
    pop si
    pop bx
    pop ax
    ret

DrawTrees:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es
    mov ax,0xb800
    mov es,ax
    
    mov bx,2
    mov si,6
    
	
	
	;abovve GREEN Tree
	
    
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
    mov word[es:di],0x2ADB        
    
   
    mov bx,3
    mov si,5
row2:
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
    mov word[es:di],0x2ADB        
    inc si
    cmp si,8
    jnz row2
	
	
	mov bx,4
	mov si,4
row3:
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
    mov word[es:di],0x2ADB       
    inc si
    cmp si,9
    jnz row3
    
   
    mov bx,5
    mov si,6
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
	mov word[es:di],0x0720
    mov word[es:di],0x6620    
	
	
	
	; ROSES Tree
	mov bx,8
    mov si,3
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
    mov word[es:di],0x2ADB  
    
    
    mov bx,9
    mov si,2
roses:
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
    mov word[es:di],0x2ADB      
    inc si
    cmp si,5
    jnz roses
	
	
	mov bx,10
	mov si,1
roses2:
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
    mov word[es:di],0x2ADB 
    inc si
    cmp si,6
    jnz roses2
    
    
    mov bx,11
    mov si,3
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
	mov word[es:di],0x0720
    mov word[es:di],0x6620
	
	
	
	
	; Blossom Tree
	mov bx,13
    mov si,8
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
    mov word[es:di],0x2ADB 
    
    
    mov bx,14
    mov si,7
blossom:
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
    mov word[es:di],0x2ADB   
    inc si
    cmp si,10
    jnz blossom
	
	
	mov bx,15
	mov si,6
blossom2:
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
    mov word[es:di],0x2ADB       
    inc si
    cmp si,11
    jnz blossom2  
    
    
    mov bx,16
    mov si,8
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
	mov word[es:di],0x0720
    mov word[es:di],0x6620
	
    
	
	
	
	
	
	;below GREEN Tree
	mov bx,19
	mov si,6
    
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
    mov word[es:di],0x2ADB        
    
   
    mov bx,20
    mov si,5
row2b:
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
    mov word[es:di],0x2ADB        
    inc si
    cmp si,8
    jnz row2b
	
	
	mov bx,21
	mov si,4
row3b:
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
    mov word[es:di],0x2ADB       
    inc si
    cmp si,9
    jnz row3b
    
   
    mov bx,22
    mov si,6
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
	mov word[es:di],0x0720
    mov word[es:di],0x6620   





;now for right belt




         mov bx,2
    mov si,6
    add si,68
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
    mov word[es:di],0x2ADB        

    mov bx,3
    mov si,5
    add si,68
Rrow2:
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
    mov word[es:di],0x2ADB        
    inc si
    cmp si,8+68
    jnz Rrow2

    mov bx,4
    mov si,4
    add si,68
Rrow3:
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
    mov word[es:di],0x2ADB       
    inc si
    cmp si,9+68
    jnz Rrow3

    mov bx,5
    mov si,6
    add si,68
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
    mov word[es:di],0x0720
    mov word[es:di],0x6620    

    mov bx,8
    mov si,3
    add si,68
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
    mov word[es:di],0x2ADB  

    mov bx,9
    mov si,2
    add si,68
Rroses:
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
    mov word[es:di],0x2ADB      
    inc si
    cmp si,5+68
    jnz Rroses

    mov bx,10
    mov si,1
    add si,68
Rroses2:
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
    mov word[es:di],0x2ADB 
    inc si
    cmp si,6+68
    jnz Rroses2

    mov bx,11
    mov si,3
    add si,68
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
    mov word[es:di],0x0720
    mov word[es:di],0x6620

    mov bx,13
    mov si,8
    add si,68
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
    mov word[es:di],0x2ADB 

    mov bx,14
    mov si,7
    add si,68
Rblossom:
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
    mov word[es:di],0x2ADB   
    inc si
    cmp si,10+68
    jnz Rblossom

    mov bx,15
    mov si,6
    add si,68
Rblossom2:
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
    mov word[es:di],0x2ADB       
    inc si
    cmp si,11+68
    jnz Rblossom2  

    mov bx,16
    mov si,8
    add si,68
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
    mov word[es:di],0x0720
    mov word[es:di],0x6620

    mov bx,19
    mov si,6
    add si,68
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
    mov word[es:di],0x2ADB        

    mov bx,20
    mov si,5
    add si,68
Rrow2b:
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
    mov word[es:di],0x2ADB        
    inc si
    cmp si,8+68
    jnz Rrow2b

    mov bx,21
    mov si,4
    add si,68
Rrow3b:
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
    mov word[es:di],0x2ADB       
    inc si
    cmp si,9+68
    jnz Rrow3b

    mov bx,22
    mov si,6
    add si,68
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
    mov word[es:di],0x0720
    mov word[es:di],0x6620


	
    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

drawcar:
    push ax
    push bx
    push es
    push si
    push di
    mov ax,0xb800
    mov es,ax
    mov bx,[codes]
    mov si,[codes+2]
    
    
yellow_loop:
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
	
cmp word [es:di],0x0E24
je point
cmp byte [es:di+1],0x08
je no_collision
cmp word [es:di],0x08B2
jne head_collision
no_collision:

    mov word[es:di],0x06DB
    inc si
    cmp si,[codes+6]
    jnz yellow_loop
    mov si,[codes+2]
    inc bx
    cmp bx,[codes+4]
    jnz yellow_loop
mov si,[stripe+2]
mov bx,[stripe]
blue_vertical_strip_loop:
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
    mov word[es:di],0x01DB
    inc bx
    cmp bx,[stripe+4]
    jnz blue_vertical_strip_loop
mov bx,18
mov si,[tyrel]
right_tyre1:
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
    mov word[es:di],0x00DB
    inc bx
    cmp bx,19
    jnz right_tyre1
mov bx,18
mov si,[tyrel+2]
left_tyre1:
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
    mov word[es:di],0x00db
    inc bx
    cmp bx,19
    jnz left_tyre1
mov bx,22
mov si,[tyrel+2]
left_tyre2:
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
    mov word[es:di],0x00db
    inc bx
    cmp bx,23
    jnz left_tyre2
mov bx,22
mov si,[tyrel]
right_tyre2:
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
    mov word[es:di],0x00DB
    inc bx
    cmp bx,23
    jnz right_tyre2
mov bx,17
mov si,[lhead]
left_head:
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
    mov word[es:di],0x0edb
    inc si
    cmp si,[lhead+2]
    jnz left_head
    mov si,[lhead]
    inc bx
    cmp bx,18
    jnz left_head
mov bx,17
mov si,[rhead]
right_head:
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
    mov word[es:di],0x0edb
    inc si
    cmp si,[rhead+2]
    jnz right_head
    mov si,[rhead]
    inc bx
    cmp bx,18
    jnz right_head
mov bx,23
mov si,[lhead]
left_head2:
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
    mov word[es:di],0x04db
    inc si
    cmp si,[lhead+2]
    jnz left_head2
    mov si,[lhead]
    inc bx
    cmp bx,24
    jnz left_head2
mov bx,23
mov si,[rhead]
right_head2:
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
    mov word[es:di],0x04db
    inc si
    cmp si,[rhead+2]
    jnz right_head2
    mov si,[rhead]
    inc bx
    cmp bx,24
    jnz right_head2
mov bx,19
mov si,[rhead]
right_blue1:
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
    mov word[es:di],0x01db
    inc bx
    cmp bx,22
    jnz right_blue1
mov bx,19
mov si,[rhead+2]
right_blue2:
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
    mov word[es:di],0x01DB
    inc bx
    cmp bx,22
    jnz right_blue2
mov bx,19
mov si,[lhead+2]
sub si,1
left_blue1:
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
    mov word[es:di],0x01db
    inc bx
    cmp bx,22
    jnz left_blue1
mov bx,19
mov si,[lhead]
sub si,1
left_blue2:
    mov ax,80
    mul bx
    add ax,si
    add ax,ax
    mov di,ax
    mov word[es:di],0x01DB
    inc bx
    cmp bx,22
    jnz left_blue2
    jmp continue_car_exit
head_collision:
    mov word[end_flag],1
    continue_car_exit:
    pop di
    pop si
    pop es
    pop bx
    pop ax
    ret
eraseCar:
push ax
	push bx
	push es
	push si
	push di

	mov ax,0xb800
		mov es,ax;32-48
		mov bx,[codes];row row (17-24)rows remain same
		mov si,[tyrel+2];col (34-47)expanded col one from left side and one from right side bcz of tyres
		clr_loop:
			mov ax,80
			mul bx
			add ax,si
			add ax,ax
			mov di,ax
			mov word[es:di],0x08B2;CLEARS WITH ROAD COLOR
			inc si
			cmp si,[last]
			jnz clr_loop
			mov si,[tyrel+2]
			inc bx
			cmp bx,[codes+4]
			jnz clr_loop
			
	pop di
	pop si
	pop es
	pop bx
	pop ax
	
	ret

point:
    add word [score],10
	mov word[es:di],0x06DB
		inc si
		cmp si,[codes+6]
		jnz yellow_loop
		mov si,[codes+2]
		inc bx
		cmp bx,[codes+4]
		jnz yellow_loop



print_pause_screen:
    push ax
    push bx
    push cx
    push dx
    push si

    ; Print  score
    mov dh, 8
    mov dl, 36
    mov ah, 0x02
    mov bh, 0
    int 0x10

    mov si, score_msg
    mov bl, 0x0C
    mov cx, 7

score_loop:
    lodsb
    mov ah, 0x09
    mov bh, 0
    push cx
    mov cx, 1
    int 0x10
    pop cx

    inc dl
    mov ah, 0x02
    mov bh, 0
    int 0x10

    loop score_loop

  
    mov ax, [cs:score]
    call print_number_bios_pause

    ; Print PRESS ESC TO Exit Game
    mov dh, 10
    mov dl, 30
    mov ah, 0x02
    mov bh, 0
    int 0x10

    mov si, esc_msg
    mov bl, 0x0C
    mov cx, 23

esc_loop:
    lodsb
    mov ah, 0x09
    mov bh, 0
    push cx
    mov cx, 1
    int 0x10
    pop cx

    inc dl
    mov ah, 0x02
    mov bh, 0
    int 0x10

    loop esc_loop

    ; Print PRESS R TO RESUME Game
    mov dh, 12
    mov dl, 30
    mov ah, 0x02
    mov bh, 0
    int 0x10

    mov si, n_msg
    mov bl, 0x0C
    mov cx, 22

n_loop:
    lodsb
    mov ah, 0x09
    mov bh, 0
    push cx
    mov cx, 1
    int 0x10
    pop cx

    inc dl
    mov ah, 0x02
    mov bh, 0
    int 0x10

    loop n_loop

    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; Special version of print_number_bios for pause screen (uses 0x0C color)
print_number_bios_pause:
    push ax
    push bx
    push cx
    push dx
    push si

    ; Get current cursor position
    mov ah, 3
    mov bh, 0
    int 10h
    push dx

    mov ax, [cs:score]
    mov bx, 10
    xor cx, cx

    ; Handle zero case
    cmp ax, 0
    jne convert_digits_pause
    mov al, '0'
    mov si, 1
    jmp print_single_digit_pause

convert_digits_pause:
convert_loop_pause:
    xor dx, dx
    div bx
    add dl, '0'
    push dx
    inc cx
    test ax, ax
    jnz convert_loop_pause

    mov si, cx

print_digits_pause:
    pop dx
    mov al, dl

print_single_digit_pause:
    mov ah, 9
    mov bh, 0
    mov bl, 0x0C      ; Red color for pause screen
    mov cx, 1
    int 10h

    ; Get current position and move to next column
    mov ah, 3
    mov bh, 0
    int 10h
    inc dl
    mov ah, 2
    mov bh, 0
    int 10h

    dec si
    jnz print_digits_pause

    ; Restore original cursor position
    pop dx
    mov ah, 2
    mov bh, 0
    int 10h

    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret




scroll:
    push ax
    push cx
    push si
    push di
    push es
    push ds
    mov ax,0xb800
    mov es,ax
    mov ds,ax
    mov si,3840
    mov di,4000
    mov cx,80
    cld
    rep movsw
    mov si,3838
    mov di,3998
    std
    mov cx,1920
    rep movsw
    cld
    mov si,4000
    mov di,0
    mov cx,80
    rep movsw
    pop ds
    pop es
    pop di
    pop si
    pop cx
    pop ax
    ret

delay:
    push cx
    mov cx, 0xFFFF
delayloop1:
    Loop delayloop1
    mov cx, 0xFFFF
delayloop2:
    Loop delayloop2
    pop cx
    ret


timer:
    pushf
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    mov ax, cs
    mov ds, ax
    mov ax, 0xB800
    mov es, ax
    inc word [cs:tickcount]
	
	;check if game is paused
    cmp byte [cs:paused], 1
    je skip_game_logic
    
    
    inc word [cs:scroll_counter]
    cmp word [cs:scroll_counter], 2
    jne no_scroll
    
	
	;game main logic
    mov word [cs:scroll_counter], 0;resetting it 
    call eraseCar
    call clear_offscreen_enemies
    call scroll
	 call drawcar
	call print_score_on_car
    

no_scroll:
    
    inc word [cs:ticks]
    cmp word [cs:ticks], 44
    jb no_enemy_spawn
    mov word [cs:ticks], 0
    call spawn_enemy
	
	;we will be at no enemy spawn if either no enemy spawn or enemy hase spawned and we are here after call spawn_enemy
no_enemy_spawn:
    
    inc word [cs:crystal_ticks]
    cmp word [cs:crystal_ticks], 26
    jb no_crystal_spawn
    mov word [cs:crystal_ticks], 0
    call spawn_crystal
	
	;we will be at no crystal spawn if either no crystal spawn or crystal hase spawned and we are here after call spawn_crystal
no_crystal_spawn:
skip_game_logic:
    mov al, 0x20
    out 0x20, al
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    popf
    iret
	
random:
    push bx
    push dx
    mov ax, [cs:r1]
	mov bx,25173
    mul bx
    add ax, 13849
    mov [cs:r1], ax
    xor dx, dx
    mov bx, 3
    div bx
    mov al, dl          
    pop dx
    pop bx
    ret

spawn_enemy:
    push ax
    push bx
    push cx
    push si
    push di
    push es

    mov  ax, 0xB800
    mov  es, ax

    call random       
    inc  al                    
    mov  [cs:rand_lane], al

;Capacity Check
    cmp  al, 1
    je   check_l1
    cmp  al, 2
    je   check_l2
check_l3:
    cmp  byte [cs:lane3_cnt], 7
    jae  dones
    jmp  draw_l3
check_l1:
    cmp  byte [cs:lane1_cnt], 7
    jae  dones
    jmp  draw_l1
check_l2:
    cmp  byte [cs:lane2_cnt], 5
    jae  dones
    jmp  draw_l2

;DRAW 6by8 RED CAR AT ROW 0 
draw_l1:
    inc byte [cs:lane1_cnt]
    mov bx, 0
    mov si, 21
    jmp draw_block
draw_l2:
    inc byte [cs:lane2_cnt]
    mov bx, 0
    mov si, 37
    jmp draw_block
draw_l3:
    inc byte [cs:lane3_cnt]
    mov bx, 0
    mov si, 53
draw_block:
    mov cx, 6             
	mov [green],si;preserving col no so that we can use it to draw green stripes
row_loop2:
    push cx
    mov cx, 7            
col_loop2:
    mov ax, 80
    mul bx                
    add ax, si            
    shl ax, 1           
    mov di, ax
    mov word [es:di], 0x0ADB      
    inc si
    loop col_loop2
    sub si, 7            
    inc bx               
    pop cx
    loop row_loop2
	
	;stripes on car
	
	mov bx,1
	mov si,[green]
	inc si
	gsl:
	mov ax,80
	mul bx
	add ax,si
	add ax,ax
	mov di,ax
	mov word[es:di],0x0CDB
	inc bx
	cmp bx,5
	jnz gsl
	
	
	
	mov bx,1
	mov si,[green]
	add si,3
	gsl2:
	mov ax,80
	mul bx
	add ax,si
	add ax,ax
	mov di,ax
	mov word[es:di],0x0CDB
	inc bx
	cmp bx,5
	jnz gsl2
	
	
	mov bx,1
	mov si,[green]
	add si,5
	gsl3:
	mov ax,80
	mul bx
	add ax,si
	add ax,ax
	mov di,ax
	mov word[es:di],0x0CDB
	inc bx
	cmp bx,5
	jnz gsl3
	
	;fl tyre
	mov bx,1
	mov si,[green]
	dec si
	mov ax,80
	mul bx
	add ax,si
	add ax,ax
	mov di,ax
	mov word[es:di],0x00DB
	
	
	;Ll tyre
	mov bx,4
	mov si,[green]
	dec si
	mov ax,80
	mul bx
	add ax,si
	add ax,ax
	mov di,ax
	mov word[es:di],0x00DB
	
	
	;fR tyre
	mov bx,1
	mov si,[green]
	add si,7
	mov ax,80
	mul bx
	add ax,si
	add ax,ax
	mov di,ax
	mov word[es:di],0x00DB
	
	
	;lR tyre
	mov bx,4
	mov si,[green]
	add si,7
	mov ax,80
	mul bx
	add ax,si
	add ax,ax
	mov di,ax
	mov word[es:di],0x00DB
	
	
	
	
	
dones:
    pop es
    pop di
    pop si
    pop cx
    pop bx
    pop ax
    ret


	
	
clear_offscreen_enemies:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es

    mov ax, 0xb800
    mov es, ax

; -------- Lane 1 --------
    mov si, 16
    mov cx, 16
    mov ax, 0
    mov [temp], ax

lane1_loop:
    mov ax, 80
    mov bx, 24
    mul bx
    add ax, si
    shl ax, 1
    mov di, ax

    cmp word [es:di], 0x00DB       ; erase black pixels
    jne check_lane1_colors
    mov word [es:di], 0x08B2
    jmp l1_next

check_lane1_colors:
    cmp word [es:di], 0x0CDB
    je l1_pixel_match
    cmp word [es:di], 0x0ADB
    jne l1_next

l1_pixel_match:
    mov word [es:di], 0x08B2
    mov ax, 1
    add [temp], ax

l1_next:
    inc si
    loop lane1_loop

    cmp byte[temp], 7
    jne lane1_done
    inc byte [cs:lane1_rows_cleared]
    cmp byte [cs:lane1_rows_cleared], 6
    jne lane1_done
    dec byte [cs:lane1_cnt]
    mov byte [cs:lane1_rows_cleared], 0

lane1_done:

; -------- Lane 2 --------
    mov si, 33
    mov cx, 15
    mov ax, 0
    mov [temp], ax

lane2_loop:
    mov ax, 80
    mov bx, 24
    mul bx
    add ax, si
    shl ax, 1
    mov di, ax

    cmp word [es:di], 0x00DB      ; erase black pixels
    jne check_lane2_colors
    mov word [es:di], 0x08B2
    jmp l2_next

check_lane2_colors:
    cmp word [es:di], 0x0CDB
    je l2_pixel_match
    cmp word [es:di], 0x0ADB
    jne l2_next

l2_pixel_match:
    mov word [es:di], 0x08B2
    mov ax, 1
    add [temp], ax

l2_next:
    inc si
    loop lane2_loop

    cmp byte[temp], 7
    jne lane2_done
    inc byte [cs:lane2_rows_cleared]
    cmp byte [cs:lane2_rows_cleared], 6
    jne lane2_done
    dec byte [cs:lane2_cnt]
    mov byte [cs:lane2_rows_cleared], 0

lane2_done:

; -------- Lane 3 --------
    mov si, 49
    mov cx, 15
    mov ax, 0
    mov [temp], ax

lane3_loop:
    mov ax, 80
    mov bx, 24
    mul bx
    add ax, si
    shl ax, 1
    mov di, ax

    cmp word [es:di], 0x00DB      ;  erase black pixels
    jne check_lane3_colors
    mov word [es:di], 0x08B2
    jmp l3_next

check_lane3_colors:
    cmp word [es:di], 0x0CDB
    je l3_pixel_match
    cmp word [es:di], 0x0ADB
    jne l3_next

l3_pixel_match:
    mov word [es:di], 0x08B2
    mov ax, 1
    add [temp], ax

l3_next:
    inc si
    loop lane3_loop

    cmp byte[temp], 7
    jne lane3_done
    inc byte [cs:lane3_rows_cleared]
    cmp byte [cs:lane3_rows_cleared], 6
    jne lane3_done
    dec byte [cs:lane3_cnt]
    mov byte [cs:lane3_rows_cleared], 0

lane3_done:
    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret



;spawning bonus objects
spawn_crystal:
    push ax
    push bx
    push cx
    push si
    push di
    push es

    mov  ax, 0xB800
    mov  es, ax

    call random       
    inc  al                     
    mov  [cs:rand_lane], al

; Capacity Check 
    cmp  al, 1
    je   ccheck_l1
    cmp  al, 2
    je   ccheck_l2
ccheck_l3:
    jmp  cdraw_l3
ccheck_l1:
    jmp  cdraw_l1
ccheck_l2:
    jmp  cdraw_l2

;DRAW pink crystal at row 0
cdraw_l1:
    mov bx, 0
    mov si, 23
    jmp draw_crystal
cdraw_l2:
    mov bx, 0
    mov si, 40
    jmp draw_crystal
cdraw_l3:
    mov bx, 0
    mov si, 56
	
draw_crystal:
	
	mov ax,80
	mul bx
	add ax,si
	add ax,ax
	mov di,ax
	cmp word[es:di],0x0CDB
	je donecrystal;if there is a car then do not draw crystal
	cmp word[es:di],0x0ADB
	je donecrystal;if there is a car then do not draw crystal
	mov word[es:di],0x0E24;pink color crystal
	
donecrystal:
    pop es
    pop di
    pop si
    pop cx
    pop bx
    pop ax
    ret

kbisr:
    pushf
    push ax
    push bx
    push cx
    push si
    push di
    push ds
    push es

    in al, 0x60

    cmp al, 0x19          ; P key
    je handle_pause
    cmp al, 0x13          ; R key (Resume)
    je handle_resume
    cmp al, 0x01          ; ESC key (Exit from pause)
    je handle_exit_pause
    cmp al, 0x4D          ; Right arrow
    je try_right
    cmp al, 0x4B          ; Left arrow
    je try_left
    jmp kbisrdone

handle_pause:
    cmp byte [cs:paused], 1
    je kbisrdone
    call pause_game
    jmp kbisrdone

handle_resume:
    cmp byte [cs:paused], 0
    je kbisrdone
    call resume_game
    jmp kbisrdone

handle_exit_pause:
    cmp byte [cs:paused], 0
    je kbisrdone
    call show_exit_confirm
    jmp kbisrdone

try_right:
    cmp byte [cs:paused], 1
    je kbisrdone
    jmp right_movement

try_left:
    cmp byte [cs:paused], 1
    je kbisrdone
    jmp left_movement

right_movement:
    mov ax, 0xb800
    mov es, ax
    mov dx, [codes+6]
    add dx, 17
    cmp dx, 63
    ja kbisrdone

    mov bx, [codes]
    mov si, [codes+2]
    add si, 16


right_check_loop:
    mov ax, 80
    mul bx
    add ax, si
    shl ax, 1
    mov di, ax
    mov ax, [es:di]

    cmp ah, 0x08
    je skip_right_check
    
    cmp ah, 0x0C
    je collision_detected

    cmp ah, 0x0E
    je collect_crystal_right
	
	
skip_right_check:
    inc si
    mov dx, [codes+6]
    add dx, 16
    cmp si, dx
    jle right_check_loop

    mov si, [codes+2]
    add si, 16
    inc bx
    cmp bx, [codes+4]
    jle right_check_loop

    jmp do_right_move

collect_crystal_right:
    add word [cs:score], 10       ; Increment score by 1 (change to 10 for 10 points)
    mov word [es:di], 0x08B2     ; Clear crystal with road color
    
    ; Continue checking rest of the positions
    inc si
    mov dx, [codes+6]
    add dx, 16
    cmp si, dx
    jle right_check_loop

    mov si, [codes+2]
    add si, 16
    inc bx
    cmp bx, [codes+4]
    jle right_check_loop
    
    jmp do_right_move

left_movement:
    mov ax, 0xb800
    mov es, ax
    mov dx, [codes+6]
    sub dx, 16
    cmp dx, 19
    jna kbisrdone

    mov bx, [codes]
    mov si, [codes+2]
    sub si, 16

left_check_loop:
    mov ax, 80
    mul bx
    add ax, si
    shl ax, 1
    mov di, ax
    mov ax, [es:di]

    cmp ah, 0x08
    je skip_left_check

    cmp ah, 0x0C
    je collision_detected

    cmp ah, 0x0E
    je collect_crystal_left

skip_left_check:
    inc si
    mov dx, [codes+6]
    sub dx, 16
    cmp si, dx
    jle left_check_loop

    mov si, [codes+2]
    sub si, 16
    inc bx
    cmp bx, [codes+4]
    jle left_check_loop

    jmp do_left_move

collect_crystal_left:
    add word [cs:score], 10       ; Increment score by 1 (change to 10 for 10 points)
    mov word [es:di], 0x08B2     ; Clear crystal with road color
    
    ; Continue checking rest of the positions
    inc si
    mov dx, [codes+6]
    sub dx, 16
    cmp si, dx
    jle left_check_loop

    mov si, [codes+2]
    sub si, 16
    inc bx
    cmp bx, [codes+4]
    jle left_check_loop
    
    jmp do_left_move

do_right_move:
    ; Clear old car position
    mov bx, [codes]
    mov si, [tyrel+2]
right_clear:
    mov ax, 80
    mul bx
    add ax, si
    shl ax, 1
    mov di, ax
    mov word [es:di], 0x08B2
    inc si
    cmp si, [last]
    jnz right_clear
    mov si, [tyrel+2]
    inc bx
    cmp bx, [codes+4]
    jnz right_clear

    ; Update car position coordinates
    add word [codes+2], 16
    add word [codes+6], 16
    add word [stripe+2], 16
    add word [tyrel], 16
    add word [tyrel+2], 16
    add word [rhead], 16
    add word [lhead], 16
    add word [lhead+2], 16
    add word [rhead+2], 16
    add word [last], 16
    
    ; Redraw car at new position
    call drawcar
	call print_score_on_car
    jmp kbisrdone

do_left_move:
    ; Clear old car position
    mov bx, [codes]
    mov si, [tyrel+2]
left_clear:
    mov ax, 80
    mul bx
    add ax, si
    shl ax, 1
    mov di, ax
    mov word [es:di], 0x08B2
    inc si
    cmp si, [last]
    jnz left_clear
    mov si, [tyrel+2]
    inc bx
    cmp bx, [codes+4]
    jnz left_clear

    ; Update car position coordinates
    sub word [codes+2], 16
    sub word [codes+6], 16
    sub word [stripe+2], 16
    sub word [tyrel], 16
    sub word [tyrel+2], 16
    sub word [rhead], 16
    sub word [lhead], 16
    sub word [rhead+2], 16
    sub word [lhead+2], 16
    sub word [last], 16
    
    ; Redraw car at new position
    call drawcar
	call print_score_on_car
    jmp kbisrdone

collision_detected:

    mov word[end_flag],1

kbisrdone:
    mov al, 0x20
    out 0x20, al
    pop es
    pop ds
    pop di
    pop si
    pop cx
    pop bx
    pop ax
    popf
    iret

pause_game:
    push ds
    push es
    
    ; Save current screen to buffer
    mov ax, 0xb800
    mov ds, ax
    mov ax, cs
    mov es, ax
    cld
    xor si, si
    mov di, screen_buffer
    mov cx, 2000
    rep movsw
    
    ; Clear screen
    mov ax, 0xb800
    mov es, ax
    xor di, di
    mov cx, 2000
    mov ax, 0x0720
    rep stosw
    
    ; Set paused flag
    mov byte [cs:paused], 1
    
    pop es
    pop ds
    
    ; Display pause screen
    call print_pause_screen
    ret

resume_game:
    push ds
    push es
    
    ; Restore screen from buffer
    mov ax, cs
    mov ds, ax
    mov ax, 0xb800
    mov es, ax
    cld
    mov si, screen_buffer
    xor di, di
    mov cx, 2000
    rep movsw
    
    ; Clear paused flag
    mov byte [cs:paused], 0
    
    pop es
    pop ds
    ret


show_start_screen:
    push ax
    push bx
    push cx
    push dx
    push si

    mov ah, 0x00
    mov al, 0x03
    int 0x10

    call fill_red_background

    mov dh, 5
    mov dl,113
    mov si, title_msg
    mov bl, 0x4E
    call print_string_bios_centered

    mov dh, 8
    mov dl,115
    mov si, semester_msg
    mov bl, 0x4E
    call print_string_bios_centered

    mov dh, 10
    mov dl,113
    mov si, group_msg
    mov bl, 0x4E
    call print_string_bios_centered

    mov dh, 12
    mov dl,112
    mov si, member1_name
    mov bl, 0x4E
    call print_string_bios_centered

    mov dh, 13
    mov dl,115
    mov si, member1_roll
    mov bl, 0x4E
    call print_string_bios_centered

    mov dh, 15
    mov dl,115
    mov si, member2_name
    mov bl, 0x4E
    call print_string_bios_centered

    mov dh, 16
    mov dl,115
    mov si, member2_roll
    mov bl, 0x4E
    call print_string_bios_centered

    mov dh, 20
    mov dl,108
    mov si, start_msg
    mov bl, 0x4E
    call print_string_bios_centered

    mov ah, 0x00
    int 0x16

    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

	
show_end_screen:
    push ax
    push bx
    push cx
    push dx
    push si

    mov ah, 0
    mov al, 3
    int 10h

    call fill_red_background

    mov dh, 6
    mov dl, 115
    mov si, gameover_msg
    mov bl, 4Eh
    call print_string_bios_centered

    mov dh, 8
    mov dl, 114
    mov si, final_score_msg
    mov bl, 4Eh
    call print_string_bios_centered

    ; set cursor where the numeric score will start
    mov dh, 8
    mov dl, 125
    mov ah, 2
    mov bh, 0
    int 10h

    mov ax, [score]
    call print_number_bios

    mov dh, 10
    mov dl, 111
    mov si, thanks_msg
    mov bl, 4Eh
    call print_string_bios_centered

    mov dh, 12
    mov dl, 109
    mov si, exit_msg
    mov bl, 4Eh
    call print_string_bios_centered



    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret




print_number_bios:
    push ax
    push bx
    push cx
    push dx
    push si

    mov ah, 3
    mov bh, 0
    int 10h
    push dx

    mov ax, [cs:score]
    mov bx, 10
    xor cx, cx

    cmp ax, 0
    jne convert_digits
    mov al, '0'
    mov si, 1
    jmp print_single_digit

convert_digits:
convert_loop:
    xor dx, dx
    div bx
    add dl, '0'
    push dx
    inc cx
    test ax, ax
    jnz convert_loop

    mov si, cx

print_digits:
    pop dx
    mov al, dl

print_single_digit:
    mov ah, 9
    mov bh, 0
    mov bl, 4Eh      ; ← Match show_end_screen color
    mov cx, 1
    int 10h

    mov ah, 3
    mov bh, 0
    int 10h
    inc dl
    mov ah, 2
    mov bh, 0
    int 10h

    dec si
    jnz print_digits

    pop dx
    mov ah, 2
    mov bh, 0
    int 10h

    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret    





print_string_bios_centered:
    push ax
    push bx
    push cx
    push dx
    push si

    mov ah, 0x02
    mov bh, 0
    int 0x10

print_loop:
    lodsb
    cmp al, 0
    je done
    
    mov ah, 0x09
    mov bh, 0
    mov cx, 1
    int 0x10

    inc dl
    mov ah, 0x02
    mov bh, 0
    int 0x10

    jmp print_loop

done:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
center_column:
    push ax
    mov dl, 40
    shr al, 1
    sub dl, al
    pop ax
    ret
	
fill_red_background:
    push ax
    push bx
    push cx
    push dx

    mov cx, 25
    mov dh, 0

row_loop:
    push cx
    mov dl, 0
    mov cx, 80

col_loop:
    push cx

    mov ah, 0x02
    mov bh, 0
    int 0x10

    mov ah, 0x09
    mov al, ' '
    mov bh, 0
    mov bl, 0x40
    mov cx, 1
    int 0x10

    pop cx
    inc dl
    loop col_loop

    pop cx
    inc dh
    loop row_loop

    pop dx
    pop cx
    pop bx
    pop ax
    ret
	
	
	;pause Y/N
show_exit_confirm:
    push ax
    push bx
    push cx
    push dx
    push si

    mov ah, 0x00
    mov al, 0x03
    int 0x10

    call fill_red_background

    mov dh, 10
    mov al, exit_confirm_len
    call center_column
    mov si, exit_confirm_msg
    mov bl, 0x4E
    call print_string_bios_centered

    mov dh, 12
    mov al, yn_msg_len
    call center_column
    mov si, yn_msg
    mov bl, 0x4E
    call print_string_bios_centered

wait_response:
    in al, 0x60

    cmp al, 0x15
    je exit_yes

    cmp al, 0x31
    je exit_no

    jmp wait_response

exit_yes:
    mov word[end_flag],1
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret


exit_no:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax

    mov ax, 0xb800
    mov es, ax
    mov ax, cs
    mov ds, ax

    cld
    mov si, screen_buffer
    xor di, di
    mov cx, 2000
    rep movsw

    call print_pause_screen
    ret
	
	print_score_on_car:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es

    mov ax, [cs:score]
    mov bx, 10
    xor cx, cx

    cmp ax, 0
    jne convert_score_digits
    push '0'
    mov cx, 1
    jmp calculate_position

convert_score_digits:
    xor dx, dx
    div bx
    add dl, '0'
    push dx
    inc cx
    test ax, ax
    jnz convert_score_digits

calculate_position:
    mov si, cx
    mov ax, si
    shr ax, 1
    mov bx, [codes+2]
    add bx, 5
    sub bx, ax
    mov dl, bl

    mov dh, [codes]
    add dh, 3

    mov ax, 0xb800
    mov es, ax

print_score_digits:
    pop ax

    push ax
    push bx
    push dx
    mov ax, 80
    mul dh
    xor dh, dh
    add ax, dx
    shl ax, 1
    mov di, ax
    pop dx
    pop bx
    pop ax
    mov ah, 0x08
    mov word [es:di], ax

    inc dl

    dec si
    jnz print_score_digits

    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
start:

 ; Show start screen first
    call show_start_screen
	
    xor ax, ax
    mov es, ax
	
	cli
	
	
    mov ax, [es:8*4]          ; offset
    mov [old_timer_isr], ax
    mov ax, [es:8*4+2]        ; segment
    mov [old_timer_isr+2], ax
	
    mov ax, [es:9*4]
    mov [old_kb_isr], ax
    mov ax, [es:9*4+2]
    mov [old_kb_isr+2], ax
	
	
	mov word [es:9*4], kbisr
    mov word [es:9*4+2], cs
    mov word [es:8*4], timer
    mov word [es:8*4+2], cs
	
    sti
   
    call clrscr
    call LeftGreenBelt
    call RightGreenBelt
    call LeftBeltBorder
    call RightBeltBorder
    call LaneMap
    call LeftMiddleLaneBorder
    call MiddleRightLaneBorder
    call DrawTrees
   
    mov byte [cs:lane1_cnt], 0
    mov byte [cs:lane2_cnt], 0
    mov byte [cs:lane3_cnt], 0
    mov word [cs:ticks], 0
    mov word [cs:scroll_counter], 0
   
    call drawcar
   call print_score_on_car
wait_loop:
    cmp word[end_flag],1
    je exit_game
    call delay
    jmp wait_loop

exit_game:

    cli
    
    xor ax, ax
    mov es, ax
    ;STOPING TIMER FIRST OTHERWISE AFTER COLLISOON TIMER JWILL STILL GENERATE ENEMIES AND TRCRYSTASL
    mov ax, [old_timer_isr]
    mov [es:8*4], ax
    mov ax, [old_timer_isr+2]
    mov [es:8*4+2], ax
    
    mov ax, [old_kb_isr]
    mov [es:9*4], ax
    mov ax, [old_kb_isr+2]
    mov [es:9*4+2], ax
    sti
    call show_end_screen

    mov ah, 0
    int 16h
        
    mov ah, 0x4C
    int 0x21