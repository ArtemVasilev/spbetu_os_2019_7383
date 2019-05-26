 TESTPC	SEGMENT
		ASSUME CS:TESTPC, DS:TESTPC, ES:NOTHING, SS:NOTHING
		ORG	100H
START: JMP BEGIN
; ������
OS 			db 'Type OS: $'
OS_VERSION 	db 'Version OS:   .  ',0DH,0AH,'$'
OS_OEM 		db 'OEM:    ',0DH,0AH,'$'
SER_NUMBER 	db 'Serial number: ','$'
STRING 		db '    $'
ENDSTR 		db 0DH,0AH,'$'

PC 			db 'PC',0DH,0AH,'$'
PCXT 		db 'PC/XT',0DH,0AH,'$'
_AT 		db 'AT',0DH,0AH,'$'
PS2_30 		db 'PS2 model 30',0DH,0AH,'$'
PS2_80 		db 'PS2 model 80',0DH,0AH,'$'
PCjr 		db 'PCjr',0DH,0AH,'$'
PC_Cnv 		db 'PC Convertible',0DH,0AH,'$'


OutOnDisplay PROC near
	mov AH,09h
	int 21h
	ret
OutOnDisplay ENDP
;---------------------------------------
TETR_TO_HEX PROC near
	and AL,0Fh
	cmp AL,09
	jbe NEXT
	add AL,07
NEXT: add AL,30h
	ret
TETR_TO_HEX ENDP

Type_of_system PROC near
	mov ax,0F000h
	mov es,ax
	mov ax,es:0FFFEh
	ret
Type_of_system ENDP

Write_type PROC near  ;����� ��������� � ���� �������
	mov dx, OFFSET OS
	call OutOnDisplay
	call Type_of_system

	; ���������� ��� ��
	cmp al,0FFh
	je PC_
	cmp al,0FEh
	je PCXT_
	cmp al,0FBh
	je PCXT_
	cmp al,0FCh
	je AT_
	cmp al,0FAh
	je PS2_30_
	cmp al,0F8h
	je PS2_80_
	cmp al,0FDh
	je PCjr_
	cmp al,0F9h
	je PC_Cnv_

	PC_:
		mov dx, OFFSET PC
		jmp OutMsg
	PCXT_:
		mov dx, OFFSET PCXT
		jmp OutMsg
	AT_:
		mov dx, OFFSET _AT
		jmp OutMsg
	PS2_30_:
		mov dx, OFFSET PS2_30
		jmp OutMsg
	PS2_80_:
		mov dx, OFFSET PS2_80
		jmp OutMsg
	PCjr_:
		mov dx, OFFSET PCjr
		jmp OutMsg
	PC_Cnv_:
		mov dx, OFFSET PC_Cnv
	;	jmp OutMsg

	OutMsg:
	call OutOnDisplay
	ret
Write_type ENDP

; �������� ������ �������
Write_os_version PROC near
	; ��������� ������
	mov ax,0
	mov ah,30h
	int 21h

	; ����� � ������ OS_VERS ����� �������� ������ ��
	mov si,offset OS_VERSION
	add si,12
	push ax
	call BYTE_TO_DEC

	; ����� ����������� ��
	pop ax
	mov al,ah
	add si,3
	call BYTE_TO_DEC

	; ����� ������ �� � �������
	mov dx,offset OS_VERSION
	call OutOnDisplay
	ret
Write_os_version ENDP

; ����� ���
Write_OEM PROC near
	mov ax,0
	mov ah,30h
	int 21h
	
	mov si,offset OS_OEM
	add si,7
	mov al,bh
	call BYTE_TO_DEC

	mov dx,offset OS_OEM
	call OutOnDisplay
	ret
Write_OEM ENDP

Serial_Number PROC near
	; ����� �������� ����� ������������
	mov dx,offset SER_NUMBER
	call OutOnDisplay
	mov  al,bl
	call BYTE_TO_HEX
	mov bx,ax
	mov dl,bl
	mov ah,02h
	int 21h
	mov dl,bh
	int 21h
	mov di,offset STRING
	add di,3
	mov ax,cx
	call WRD_TO_HEX
	mov dx,offset STRING
	call OutOnDisplay

	mov dx,offset ENDSTR
	call OutOnDisplay

	ret
Serial_Number ENDP
;---------------------------------------
BYTE_TO_HEX PROC near
;���� � AL ����������� � ��� ������� �����. ����� � AX 
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
;---------------------------------------
; ������� � 16�/� 16-�� ���������� �����
; � AX - �����, DI - ����� ���������� �������
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
;---------------------------------------
; ������� � 10�/�, SI - ����� ���� ������� �����
BYTE_TO_DEC PROC near
	push CX
	push DX
	xor AH,AH
	xor DX,DX
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
;---------------------------------------
BEGIN:
	call Write_type
	call Write_OEM
	call Write_os_version
	call Serial_Number
	xor AL,AL
	mov AH,4Ch
	int 21H
TESTPC ENDS
 END START