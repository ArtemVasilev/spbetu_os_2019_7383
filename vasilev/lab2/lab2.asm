TESTPC	SEGMENT
        ASSUME  CS:TESTPC, DS:TESTPC, ES:NOTHING, SS:NOTHING
        org 100H	; ¨á¯®«ì§®¢ âì á¬¥é¥­¨¥ 100h (256 ¡ ©â) ®â ­ ç « 
				; á¥£¬¥­â , ¢ ª®â®àë© § £àã¦¥­  ­ è  ¯à®£à ¬¬ 
START:  JMP BEGIN	; START - â®çª  ¢å®¤ 

; „€›…:
; ¤®¯®«­¨â¥«ì­ë¥ ¤ ­­ë¥
EOF	EQU '$'
_endl	db ' ',0DH,0AH,'$' ; ­®¢ ï áâà®ª 

_seg_inaccess	db '‘¥£¬¥­â­ë©  ¤à¥á ­¥¤®áâã¯­®© ¯ ¬ïâ¨:     ',0DH,0AH,EOF
_seg_env		db '‘¥£¬¥­â­ë©  ¤à¥á áà¥¤ë:    ',0DH,0AH,EOF
_tail		db '•¢®áâ ª®¬ ­¤­®© áâà®ª¨: ', EOF
_env 		db '‘®¤¥à¦¨¬®¥ ®¡« áâ¨ áà¥¤ë:',0DH,0AH,EOF
_dir	db 'ãâì § £àã¦ ¥¬®£® ¬®¤ã«ï:',0DH,0AH,EOF
_symb  db '­¥â á¨¬¢®«®¢',0DH,0AH,EOF

; Ž–…„“›:
TETR_TO_HEX PROC near
	and AL,0Fh
	cmp AL,09
	jbe NEXT
	add AL,07
NEXT:	add AL,30h
	ret
TETR_TO_HEX ENDP

;¡ ©â AL ¯¥à¥¢®¤¨âáï ¢ ¤¢  á¨¬¢®«  è¥áâ­. ç¨á«  ¢ AX
BYTE_TO_HEX PROC near
	push CX
	mov AH,AL
	call TETR_TO_HEX
	xchg AL,AH
	mov CL,4
	shr AL,CL
	call TETR_TO_HEX  ;¢ AL - áâ àè ï, ¢ AH - ¬« ¤è ï
	pop CX
	ret
BYTE_TO_HEX ENDP

;¯¥à¥¢®¤ ¢ 16 á/á 16-â¨ à §àï¤­®£® ç¨á« 
;¢ AX - ç¨á«®, DI -  ¤à¥á ¯®á«¥¤­¥£® á¨¬¢®« 
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

;¯¥à¥¢®¤ ¢ 10á/á, SI -  ¤à¥á ¯®«ï ¬« ¤è¥© æ¨äàë
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
end_l:	pop DX
	pop CX
	ret
BYTE_TO_DEC ENDP

; äã­ªæ¨ï ®¯à¥¤¥«¥­¨ï á¥£¬¥­â­®£®  ¤à¥á  ­¥¤®áâã¯­®© ¯ ¬ïâ¨
SEGMENT_INACCESS PROC NEAR
	push ax
	push di

	mov ax, ds:[02h] ; § £àã¦ ¥¬  ¤à¥á
	mov di, offset _seg_inaccess
	add di, 40 ; § £àã¦ ¥¬  ¤à¥á ¯®á«¥¤­¥£® á¨¬¢®«  _seg_inacces
	call WRD_TO_HEX ; ¯¥à¥¢®¤¨¬ ax ¢ 16‘‘

	pop di
	pop ax
	ret
SEGMENT_INACCESS ENDP

; äã­ªæ¨ï ®¯à¥¤¥«¥­¨ï á¥£¬¥­â­®£®  ¤à¥á  áà¥¤ë, ¯¥à¥¤ ¢ ¥¬®£® ¯à®£à ¬¬¥
SEGMENT_ENVIRONMENT PROC NEAR
	push ax
	push di

	mov ax, ds:[2Ch] ; § £àã¦ ¥¬  ¤à¥á
	mov di, offset _seg_env
	add di, 27 ; § £àã¦ ¥¬  ¤à¥á ¯®á«¥¤­¥£® á¨¬¢®«  _seg_env
	call WRD_TO_HEX

	pop di
	pop ax
	ret
SEGMENT_ENVIRONMENT ENDP

; äã­ªæ¨ï ®¯à¥¤¥«ï¥â å¢®áâ ¯à®£à ¬¬­®© áâà®ª¨ ¢ á¨¬¢®«ì­®¬ ¢¨¤¥
TAIL PROC NEAR
    push ax
    push bx
    push cx
    push dx
    push si
    push di
 
    mov ah, 02h
    mov cl, ds:[80h]
    cmp cl, 0
    je NoCmd
 
    mov bx, 0
PrintCmd:
    mov dl, ds:[81h+bx]
    int 21h
    inc bx
    loop PrintCmd
    jmp TailExit
 
NoCmd:
    mov dx, offset _symb
    call PRINT
 
TailExit:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
TAIL ENDP

; äã­ªæ¨ï ®¯à¥¤¥«ï¥â á®¤¥à¦¨¬®¥ ®¡« áâ¨ áà¥¤ë
CONTENT PROC NEAR
	push ax
	push dx
	push ds
	push es

	; ¢ë¢®¤ á®¤¥à¦¨¬®£® ®¡« áâ¨ áà¥¤ë
	mov dx, offset _env
	call PRINT

	mov ah, 02h ; ¡ã¤¥¬ ¢ë¢®¤¨âì ¯®á¨¬¢®«ì­® dl
	mov es, ds:[2Ch]
	xor si, si
WriteCont:
	mov dl, es:[si]
	int 21h			; ¢ë¢®¤
	cmp dl, 0h		; ¯à®¢¥àï¥¬ ­  ª®­¥æ áâà®ª¨
	je	EndOfLine
	inc si			; ¯¥à¥å®¤¨¬ ª à áá¬®âà¥­¨î á«¥¤. á¨¬¢®« 
	jmp WriteCont
EndOfLine:
	mov dx, offset _endl ; ¯àë¦®ª ­  ­®¢ãî áâà®çªã
	call PRINT
	inc si
	mov dl, es:[si]
	cmp dl, 0h		; ¯à®¢¥àï¥¬ ­  ª®­¥æ á®¤¥à¦¨¬®£® ®¡« áâ¨ áà¥¤ë (¥á«¨ ¤¢  ¯®¤àï¤ 0 ¡ ©â )
	jne WriteCont

	mov dx, offset _endl
	call PRINT

	pop es
	pop ds
	pop dx
	pop ax
	ret
CONTENT ENDP

; ¢ë¢®¤ ¯ãâ¨ § £àã¦ ¥¬®£® ¬®¤ã«ï
PATH PROC NEAR
	push ax
	push dx
	push ds
	push es
	mov dx, offset _dir
	call PRINT

	add si, 3h
	mov ah, 02h
	mov es, ds:[2Ch]
	WriteDir:
	mov dl, es:[si]
	cmp dl, 0h
	je EndOfDir
	int 21h
	inc si
	jmp WriteDir
	EndOfDir:

	pop es
	pop ds
	pop dx
	pop ax
	ret
PATH ENDP

; äã­ªæ¨ï ¢ë¢®¤  ­  íªà ­
PRINT PROC NEAR
	push ax
	mov ah, 09h
	int 21h
	pop ax
	ret
PRINT ENDP

; ŠŽ„
BEGIN:
	call SEGMENT_INACCESS
  mov dx, offset _seg_inaccess
	call PRINT
	call SEGMENT_ENVIRONMENT
  mov dx, offset _seg_env
	call PRINT
  mov dx, offset _tail
	call PRINT
	call TAIL
  mov dx, offset _endl
	call PRINT
	call CONTENT
	call PATH
	mov dx, offset _endl
	call PRINT

; ¢ëå®¤ ¢ DOS
	xor al, al
	mov ah, 4ch
	int 21h

TESTPC 	ENDS
		END START	; ª®­¥æ ¬®¤ã«ï
