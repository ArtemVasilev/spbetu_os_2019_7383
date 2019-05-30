CODE SEGMENT
	ASSUME CS:CODE, DS:DATA, SS:AStack

ROUT PROC
	jmp START 
	
	KEEP_AX		dw 0
	KEEP_SS		dw 0
	KEEP_SP		dw 0
	KEEP_PSP	dw 0
	INT9_VECT	dd 0
	SIGNATURE  	db 'rout'
	REQ_KEY 	db 3Dh
	ROUT_STACK 	dw 64 dup (?)			
	STACK_END:

START:
	mov KEEP_AX,ax
	mov KEEP_SS,ss
	mov KEEP_SP,sp
	mov ax,cs
	mov ss,ax
	mov sp,offset STACK_END

	push bx
	push cx
	in al,60h
	cmp al,REQ_KEY
	je DO_REQ
INT9:
	pop cx
	pop bx
	mov sp,KEEP_SP
	mov ss,KEEP_SS
	mov ax,KEEP_AX
	jmp cs:[INT9_VECT]
	jmp ROUT_END
	
DO_REQ:
	in al,61h
	mov ah,al
	or al,80h
	out 61h, al
	xchg ah,al
	out 61h,al
	mov al,20h
	out 20h,al
	mov CL,'O'
	call WriteToBuf
	mov cl,'S'
	call WriteToBuf
	mov cl,' '
	call WriteToBuf
	mov cl,'i'
	call WriteToBuf
	mov cl,'s'
	call WriteToBuf
	mov cl,' '
	call WriteToBuf
	mov cl,'e'
	call WriteToBuf
	mov cl,'v'
	call WriteToBuf
	mov cl,'i'
	call WriteToBuf
	mov cl,'l'
	call WriteToBuf
	mov cl,' '
	call WriteToBuf
ROUT_END:
	pop cx
	pop bx
	mov sp,KEEP_SP
	mov ss,KEEP_SS
	mov al,20h
	out 20h,al
	mov ax,KEEP_AX

	iret	
ROUT ENDP

WriteToBuf PROC
	push ax
	push cx
_START:
	mov ah,05h
	mov ch,00h
	int 16h
	or al,al
	jnz skip
	jmp _END
skip:
	push es
	mov ax,0040h
	mov es,ax
	mov ax,es:[1Ah]
	mov es:[1Ch],ax
	pop es
	jmp _START
_END:
	pop cx
	pop ax

	ret
WriteToBuf ENDP

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
	mov ax,3509h
	int 21h
	cld
	mov cx,4
	lea di,es:SIGNATURE
	lea si,ds:CHECK_SIGNATURE
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
	mov ax,3509h
	int 21h
	mov word ptr INT9_VECT,bx
	mov word ptr INT9_VECT + 2,es
	pop es
	mov dx,offset ROUT
	mov ax,seg ROUT
	mov ds,ax
	mov ax,2509h
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
	add dx,100h
	add dx,0Fh
	mov cl,04h
	shr dx,cl
	mov ax,3100h
	int 21h

	ret
SET_RESIDENT ENDP

UNLOAD_ROUT PROC near
	cli
	push ds
	mov ax,es:word ptr INT9_VECT + 2
	mov dx,es:word ptr INT9_VECT
	mov ds,ax
	mov ax,2509h
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
	mov ax,3509h
	int 21h
	cld
	mov cx,4
	lea di,es:SIGNATURE
	lea si,ds:CHECK_SIGNATURE
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
	CHECK_SIGNATURE 	db 'rout'
	CHECK_MESSAGE  		db 'Rout has already been loaded.',0Dh,0Ah,'$'
	LOAD_MESSAGE   		db 'Rout was successfully loaded.',0Dh,0Ah,'$'
	UNLOAD_MESSAGE 		db 'Rout was successfully unloaded.',0Dh,0Ah,'$'
	UNLOAD_ERROR	    db 'Rout is not loaded.',0Dh,0Ah,'$'
	UNLOAD_TAIL  		db ' /un'
	TAIL         		db '    '
DATA ENDS 
END MAIN