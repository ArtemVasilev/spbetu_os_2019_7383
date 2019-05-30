 CODE SEGMENT
 ASSUME CS:CODE, DS:DATA, ES:DATA, SS:ASTACK
START: JMP BEGIN


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

WriteStr PROC
	push ax
	mov AH,09h
	int 21h
	pop ax
	ret
WriteStr ENDP

PREPARATION PROC
	mov ax,ASTACK
	sub ax,CODE
	add ax,100h
	mov bx,ax
	mov ah,4ah
	int 21h
	
	jnc err_skip
		call ERRORS	
	err_skip:
	
	; подготовка блока параметров
	mov ax, es:[2ch]
	mov ARGUMENTS, ax
	mov ARGUMENTS+2,es 
	mov ARGUMENTS+4,80h
	;определение пути до программы
	
	push es
	push bx
	push si
	push ax
	
	mov es,es:[2ch] ; в es сегментный адрес среды
	mov bx,-1
	sreda_loop:
		add bx,1
		cmp word ptr es:[bx],0000h
		jne sreda_loop
		
	add bx,4
	mov si,-1
	
	path_loop:
		add si,1
		mov al,es:[bx+si]
		mov PROGRAMM[si],al
		cmp byte ptr es:[bx+si],00h
		jne path_loop
	
	add si,1
	path_loop2:
		mov PROGRAMM[si],0
		sub si,1
		cmp byte ptr es:[bx+si],'\'
		jne path_loop2
		
	add si,1
	mov PROGRAMM[si],'l'
	add si,1
	mov PROGRAMM[si],'a'
	add si,1
	mov PROGRAMM[si],'b'
	add si,1
	mov PROGRAMM[si],'2'
	add si,1
	mov PROGRAMM[si],'.'
	add si,1
	mov PROGRAMM[si],'e'
	add si,1
	mov PROGRAMM[si],'x'
	add si,1
	mov PROGRAMM[si],'e'
	
	pop ax
	pop si
	pop bx
	pop es	

	mov ax,ds
	mov es,ax
	
	mov bx,offset ARGUMENTS
	mov dx,offset PROGRAMM
	
	mov KEEP_SS, SS
	mov KEEP_SP, SP
	
	ret
PREPARATION ENDP

LOADING_PROGR PROC
	
	mov ax,4B00h
	int 21h
	
	push ax
	mov ax,DATA
	mov ds,ax
	pop ax
	mov SS,KEEP_SS
	mov SP,KEEP_SP
	
	jnc st_skip
		call ERRORS
		jmp st_end
	
	st_skip:
		; в al код завершения, в ah - причинa:
		mov al,00h
		mov ah,4dh
		int 21h
		
	continue_label:

		cmp ah, 0
		je pr_end_enter0
		
		mov dx,offset end1
		cmp ah,1
		je pr_end_enter

		mov dx,offset end2
		cmp ah,2
		je pr_end_enter
		
		mov dx,offset end3
		cmp ah,3
		je pr_end_enter
		
		pr_end_enter0:
			
			mov ah,02h
			mov dl,al
			int 21h
			
			mov dx,offset ENDL
			call WriteStr
			mov dx, offset end0
			call WriteStr
			mov dx,offset ENDL
			call WriteStr
			mov dx, offset end_code
			
			mov ah, 0
		
		pr_end_enter:
			call WriteStr

		cmp ah,0
		jne st_end

		call BYTE_TO_HEX
		push ax
		mov ah,02h
		mov dl,al
		int 21h
		pop ax
		mov dl,ah
		mov ah,02h
		int 21h
	
	st_end:
		ret
LOADING_PROGR ENDP


ERRORS PROC

	mov dx,offset er1
	cmp ax,1
	je pr
	
	mov dx,offset er2
	cmp ax,2
	je pr

	mov dx,offset er7
	cmp ax,7
	je pr
	
	mov dx,offset er8
	cmp ax,8
	je pr
	
	mov dx,offset er9
	cmp ax,9
	je pr
	
	mov dx,offset er10
	cmp ax,10
	je pr
	
	mov dx,offset er11
	
	pr:
		call WriteStr
		ret
ERRORS ENDP

BEGIN:
	mov ax,data
	mov ds,ax
	call PREPARATION
	call LOADING_PROGR
	
	xor AL,AL
	mov AH,4Ch
	int 21H
CODE ENDS

DATA SEGMENT	

	er1 db 'Error: invalid function number$'
	er2 db 'Error: file not found$'
	er7 db 'Error: destroyed control memory block$'
	er8 db 'Error: insufficient memory$'
	er9 db 'Error: invalid memory address$'
	er10 db 'Error: invalid environment string$'
	er11 db 'Error: invalid format$'
	
	; причины завершения
	end0 db 'Completion of the program is normal$'
	end1 db 'Completion of the program: Ctrl-C$'
	end2 db 'Completion of the program: device error'
	end3 db 'Completion of the program: 31h$'
	end_code db 'Code: $'
		
	ENDL db 0DH,0AH,'$'
	
	ARGUMENTS 	dw 0 
				dd 0 
				dd 0 
				dd 0 
		
	PROGRAMM db 40h dup (0)

	KEEP_SS dw 0
	KEEP_SP dw 0
DATA ENDS

ASTACK SEGMENT STACK
	dw 100h dup (?)
ASTACK ENDS
 END START
 