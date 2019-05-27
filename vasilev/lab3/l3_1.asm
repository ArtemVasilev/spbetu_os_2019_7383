TESTPC SEGMENT
 ASSUME CS:TESTPC, DS:TESTPC, ES:NOTHING, SS:NOTHING
 ORG 100H
START: JMP BEGIN

AV_MEM_STR db 'Available memory:        B',0DH,0AH,'$'
EX_MEM_STR db 'Extended memory:       KB',0DH,0AH,'$'
MCB_HEAD db 'Address Owner   Size   Name',0DH,0AH,'$'
MCB_MEM_STR db '                      $'
ENDL db 0DH,0AH,'$'

WriteStr PROC near
	push ax
	mov ah,09h
	int 21h
	pop ax
	ret
WriteStr ENDP

AV_MEM PROC
	
	sub ax, ax
	mov ah,4Ah
	mov bx,0FFFFh 
	int 21h
	mov ax,bx 
	mov bx,16
	mul bx 
	mov si,offset AV_MEM_STR + 23
	call BYTE_TO_DEC
	ret
AV_MEM ENDP

EX_MEM PROC
	
	mov  AL,30h
    out 70h,AL
    in AL,71h
    mov BL,AL
    mov AL,31h
    out 70h,AL
    in AL,71h
	mov bh,al
	
	mov ax,bx
	mov dx,0
	mov si,offset EX_MEM_STR + 21
	call BYTE_TO_DEC
	ret
EX_MEM ENDP

;
MCB PROC

		push es
	mov ah,52h
	int 21h
	mov bx,es:[bx-2]
	mov es,bx
	
	print_MCB:
		
		mov ax,es
		mov di,offset MCB_MEM_STR+6
		call WRD_TO_HEX
		
		mov ax,es:[01h]
		mov di,offset MCB_MEM_STR+12
		call WRD_TO_HEX
		
		mov ax,es:[03h]
		mov si,offset MCB_MEM_STR+19
		
		mov dx, 0
		mov bx, 10h
		mul bx
		call BYTE_TO_DEC
		
		mov dx,offset MCB_MEM_STR
		call WriteStr
		
		mov cx,8
		mov bx,8
		mov ah,02h
		
		print_:
			mov dl,es:[bx]
			add bx,1
			int 21h
		loop print_
		
		mov dx,offset ENDL
		call WriteStr
		
		mov ax,es
		add ax,1
		add ax,es:[03h]
		mov bl,es:[00h]
		mov es,ax
		
		cmp bl,4Dh
		je print_MCB
	
	pop es	
	ret
MCB ENDP

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

BYTE_TO_DEC PROC near
	push CX
	push DX
	mov CX,10
loop_bd: div CX
	or DL,30h
	mov [SI],DL
	dec SI
	xor DX,DX
	cmp AX,10
	jae loop_bd
	cmp AL,00h
	je end_l
	or AL,30h
	mov [SI],AL
end_l: pop DX
	pop CX
	ret
BYTE_TO_DEC ENDP


BEGIN:
	
	call AV_MEM
	mov dx,offset AV_MEM_STR
	call WriteStr
	
	call EX_MEM
	mov dx,offset EX_MEM_STR
	call WriteStr
	
	mov dx, offset MCB_HEAD
	call WriteStr
	call MCB
	
	xor AL,AL
	mov AH,4Ch
	int 21H
	
	END_OF_PROGR:
TESTPC ENDS
 END START 
