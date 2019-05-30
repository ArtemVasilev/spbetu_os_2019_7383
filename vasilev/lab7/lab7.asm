CODE SEGMENT
	ASSUME CS:CODE, DS:DATA, SS:ASTACK, ES:NOTHING
START: JMP BEGIN

WriteStr PROC

	push ax
	mov AH,09h
	int 21h
	pop ax
	ret
	
WriteStr ENDP
		  
ERRORS PROC

	mov dx,offset er1
	cmp ax,1
	je pr
	
	mov dx,offset er2
	cmp ax,2
	je pr
	
	cmp ax,12h
	je pr

	mov dx,offset er3
	cmp ax,3
	je pr
	
	mov dx,offset er4
	cmp ax,4
	je pr
	
	mov dx,offset er5
	cmp ax,5
	je pr
	
	mov dx,offset er8
	cmp ax,8
	je pr
	
	mov dx,offset er10
	
	pr:
		call WriteStr
		ret
ERRORS ENDP

OVL_PATH PROC

	push es
	push bx
	push dx
	push di
	push si
	
	mov es,es:[2Ch] ; в es сегментный адрес среды
	mov bx,-1
	sreda_loop:
		add bx,1
		cmp word ptr es:[bx],0000h
		jne sreda_loop
		
	add bx,4
	mov di,offset PATH
	
	path_loop:
		mov dl,es:[bx]
        mov [di],dl
        add di, 1
        add bx, 1
        cmp dl,00h
		jnz path_loop
	
	path_loop2:
		dec di
		mov dl,[di]
		cmp dl,92
		jne path_loop2
		
		cmp ovl_num,2
		je ovl2_label
			mov si, offset ovl1
			mov ovl_num,2
			jmp path_loop3
		ovl2_label:
			mov si, offset ovl2
	
	path_loop3:
		add di,1
        mov dl,[si]
        mov [di],dl
        add si,1
        cmp dl,00h
        jnz path_loop3 
	
	pop si
	pop di
	pop dx
	pop bx
	pop es
	ret
	
OVL_PATH ENDP
  		  
MEM_FREE PROC

	mov bx,ABCD
	mov ax,es
	sub bx,ax

	mov ah,4Ah
	int 21h
    ret
	
MEM_FREE ENDP

READ_OVL PROC

	push bp
	push ax
	push bx
	push dx
	push cx
		  
    mov ah,1Ah
    mov dx,offset BUFFER
    int 21h
		  
    mov ah,4Eh
    mov dx,offset PATH
    mov cx,0
    int 21h
          
	jnc err_skip
		mov error_flag,1
		call ERRORS
		jmp end_read_ovl
					
	err_skip:

    mov bp,offset BUFFER
	mov bx,ds:[bp+1Ah]
	mov ax,ds:[bp+1Ch] 
	shr bx,4          
	shl ax,12         
	add bx,ax        
	inc bx             
	mov ax,ds:[bp+1Ch]
	and ax,0FFF0h

    mov AH,48h
    int 21h

	mov overlay_seg,AX
    mov overlay_seg1,AX    
    mov reloc,AX
		  
end_read_ovl:
	pop cx
    pop dx
    pop bx
    pop ax
    pop bp
	ret
	
READ_OVL ENDP

LOAD_OVL PROC
    
	push ax
    push bx
    push dx
    push es
    
	mov dx,offset PATH  
    push ds               
	pop es                
    mov bx,offset char_block    
    
	mov ax,4B03h            
    int 21h
    jnc err_skip_2
		mov error_flag,1
		call ERRORS
		jmp end_load_ovl
	err_skip_2:

	mov dx, offset LOAD_SUCCESS
    call WriteStr
    call DWORD PTR ov_address ;вызвать печать адреса оверлея

end_load_ovl: 
	pop es
    pop dx
    pop bx
    pop ax
	ret
	
LOAD_OVL ENDP

CLEAN_MEM  PROC      NEAR
    push ax
    push es
	
    mov ax,overlay_seg
    mov es,ax
    mov ah,49h
    int 21h
	
	mov dx, offset CLEAN_SUCCESS
	call WriteStr

clean_end:
	pop es
    pop ax
	ret
	
CLEAN_MEM  ENDP

BEGIN:
	mov ax,data
	mov ds,ax
    call MEM_FREE
    
	call OVL_PATH
	call READ_OVL  
	cmp error_flag, 0
	jne next_ovl
    
	call LOAD_OVL 
	cmp error_flag, 0
	jne next_ovl
    
	call CLEAN_MEM
		  
next_ovl:
	mov error_flag,0
	
	call OVL_PATH
	call READ_OVL
	cmp error_flag, 0
	jne end_begin
		  
    call LOAD_OVL
	cmp error_flag, 0
	jne end_begin
		  
    call CLEAN_MEM

end_begin:     
	xor al,al
	mov ah,4Ch
	int 21h
CODE ENDS

DATA SEGMENT          

	er1 db 'Error: invalid function',0dh,0ah,'$'
	er2 db 'Error: file not found',0dh,0ah,'$'
	er3 db 'Error: path not found',0dh,0ah,'$'
	er4 db 'Error: too much open files',0dh,0ah,'$'
	er5 db 'Error: no access',0dh,0ah,'$'
	er8 db 'Error: insufficient memory',0dh,0ah,'$'
	er10 db 'Error: invalid environment',0dh,0ah,'$'
	
	error_flag dw 0
	ovl_num dw 1
	
	LOAD_SUCCESS db 'Overlay loaded successfully',0dh,0ah,'$'
	CLEAN_SUCCESS db 'Cleaned successfully',0dh,0ah,'$'
	
    ovl1 db 'lab7_1.ovl',0
	ovl2 db 'lab7_2.ovl',0
    
	PATH db 128 DUP (0)
    BUFFER db   43 DUP (0)
   
    char_block equ $    
    
	overlay_seg dw ? 
    reloc dw ?    
    ov_address equ $ 
    ov_ofst dw 0   
    overlay_seg1 dw ? 

DATA ENDS

ASTACK SEGMENT STACK
	DW 100 DUP (0)
ASTACK ENDS

ABCD SEGMENT
ABCD ENDS

	END START
