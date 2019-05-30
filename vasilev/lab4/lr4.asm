CODE SEGMENT
	ASSUME CS:CODE, DS:DATA, SS:AStack

ROUT PROC
	jmp START
	KEEP_PSP		dw 0
	KEEP_SS			dw 0
	KEEP_SP			dw 0
	KEEP_CS 		dw 0
	KEEP_IP 		dw 0
	SIGNATURE  		db 'rout'
	COUNTER			dw 0
	COUNT_MESSAGE	db 'ROUT CALLED:      $'
	ROUT_STACK 		dw 64 dup (?)
	STACK_END:
	
START:
	mov KEEP_SS,ss
	mov KEEP_SP,sp
	mov ax,cs
	mov ss,ax
	mov sp,offset STACK_END

	push ax
	push bx
	push cx
	push dx

	call getCurs
	push dx
	mov dx,2200h
	call setCurs

	push ds
	mov ax,seg COUNTER
	mov ds,ax
	mov ax,COUNTER
	inc ax
	mov COUNTER,ax
	push di
	mov di,offset COUNT_MESSAGE
	add di,17
	call WRD_TO_HEX
	pop di
	pop ds
	push es
	push bp
	mov ax,seg COUNT_MESSAGE
	mov es,ax
	mov bp,offset COUNT_MESSAGE
	call outputBP
	pop bp
	pop es

	pop dx
	call setCurs

	pop dx
	pop cx
	pop bx
	pop ax
	mov sp,KEEP_SP
	mov ss,KEEP_SS
	mov al,20h
	out 20h,al
	iret	
ROUT ENDP

getCurs PROC
	push ax
	push bx
	push cx
	mov ah,03h
	mov bh,0
	int 10h
	pop cx
	pop bx
	pop ax
	ret
getCurs ENDP

setCurs PROC
	push ax
	push bx
	mov ah,02h
	mov bh,0
	int 10h
	pop bx
	pop ax
	ret
setCurs ENDP

outputBP PROC
	push ax
	push bx
	push cx
	push dx
	mov ah,13h
	mov al,1
	mov bh,0
	mov dh,0Ch
	mov dl,1Eh
	mov cx,12h
	int 10h
	pop dx
	pop cx
	pop bx
	pop ax
	ret
outputBP ENDP

TETR_TO_HEX PROC near
	and AL,0Fh
	cmp AL,09
	jbe NEXT
	add AL,07
NEXT: add AL,30h
	ret
TETR_TO_HEX ENDP

BYTE_TO_HEX PROC near
	push CX
	mov AH,AL
	call TETR_TO_HEX
	xchg AL,AH
	mov CL,4
	shr AL,CL
	call TETR_TO_HEX
	pop CX 
	ret
BYTE_TO_HEX ENDP

WRD_TO_HEX PROC near
	push BX
	mov BH,AH
	call BYTE_TO_HEX
	mov [DI],AH
	dec DI
	mov [DI],AL
	dec DI
	mov AL,BH
	call BYTE_TO_HEX
	mov [DI],AH
	dec DI
	mov [DI],AL
	pop BX
	ret
WRD_TO_HEX ENDP

RESIDENT_END:
	
WriteStr PROC near
	push ax
	mov ah,09h
	int 21h
	pop ax
	ret
WriteStr ENDP

IS_LOADED PROC near
	push ax
	push bx
	push cx
	push dx
	push di
	push si
	push es

	mov ax,351Ch
	int 21h
	cld
	mov cx,4
	lea di,es:SIGNATURE
	lea si,ds:SIGNATURE_CHECK
	repe cmpsb
	jne NOT_LOADED
	mov dx,offset CHECK_MESSAGE
	call WriteStr
	jmp END_PROC

NOT_LOADED:
	pop es
	pop si
	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	ret
IS_LOADED ENDP

SET_ROUT PROC near
	push ax
	push bx
	push dx
	push ds
	push es

	push es
	mov ax,351Ch
	int 21h
	mov KEEP_IP,bx
	mov KEEP_CS,es
	pop es
	mov dx,offset ROUT
	mov ax,seg ROUT
	mov ds,ax
	mov ax,251Ch
	int 21h
	
	pop es
	pop ds
	mov dx,offset LOAD_MESSAGE
	call WriteStr
	pop dx
	pop bx
	pop ax
	ret
SET_ROUT ENDP

SET_RESIDENT PROC near
	mov dx,offset RESIDENT_END
	mov cl,04h
	shr dx,cl
	add dx,100h
	mov ax,3100h
	int 21h
	ret
SET_RESIDENT ENDP

UNLOAD_ROUT PROC near
	cli
	push ds
	mov ax,es:KEEP_CS
	mov dx,es:KEEP_IP
	mov ds,ax
	mov ax,251Ch
	int 21h
	pop ds
	mov si,offset KEEP_PSP
	mov ax,es:[bx+si]
	mov es,ax
	mov ax,es:[2Ch]
	push es
	mov es,ax
	mov ah,49h
	int 21h
	pop es
	int 21h
	sti
	mov dx,offset UNLOAD_MESSAGE
	call WriteStr
	jmp END_PROC
	ret
UNLOAD_ROUT ENDP

CHECK_TAIL PROC near
	push ax
	push bx
	push cx
	push si
	push di
	mov cl,es:[80h]
	cmp cl,4
	jne WRONG
	mov bx,0
	mov si,offset TAIL
t_loop:
	mov al,es:[81h+bx]
	mov [si],al
	inc si
	inc bx
	loop t_loop

	push es
	cld
	mov cx,4
	mov ax,seg DATA
	mov es,ax
	lea di,ds:UNLOAD_TAIL
	lea si,ds:TAIL
	repe cmpsb
	pop es
	jne WRONG
	push es
	mov ax,351Ch
	int 21h
	cld
	mov cx,4
	lea di,es:SIGNATURE
	lea si,ds:SIGNATURE_CHECK
	repe cmpsb
	jne ERROR
	call UNLOAD_ROUT
ERROR:
	pop es
	mov dx,offset UNLOAD_ERROR
	call WriteStr
	jmp END_PROC
WRONG:
	pop di
	pop si
	pop cx
	pop bx
	pop ax
	ret
CHECK_TAIL ENDP

MAIN PROC near
	mov KEEP_PSP,es
	mov ax,seg DATA
	mov ds,ax

	call CHECK_TAIL
	call IS_LOADED
	call SET_ROUT
	call SET_RESIDENT
END_PROC:
	mov ax,4C00h
	int 21h
	ret
MAIN ENDP
CODE ENDS


AStack SEGMENT STACK
	dw 64 dup (?)
AStack ENDS


DATA SEGMENT
	SIGNATURE_CHECK 	db 'rout'
	CHECK_MESSAGE  		db 'Rout has already been loaded.',0Dh,0Ah,'$'
	LOAD_MESSAGE   		db 'Rout was successfully loaded.',0Dh,0Ah,'$'
	UNLOAD_MESSAGE 		db 'Rout was successfully unloaded.',0Dh,0Ah,'$'
	UNLOAD_ERROR	    db 'Rout is not loaded.',0Dh,0Ah,'$'
	UNLOAD_TAIL  		db ' /un'
	TAIL         		db '    '
DATA ENDS 

END MAIN