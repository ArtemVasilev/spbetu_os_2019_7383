CODE      SEGMENT
          ASSUME         CS:CODE, DS:NOTHING, SS:NOTHING, ES:NOTHING

OVERLAY PROC FAR
          push ax
          push di
          push ds
		  
          mov ax,cs
          mov ds,ax
          mov di,offset ADDRESS + 20
          call WORD_TO_HEX
          mov dx, offset ADDRESS
		  call WriteStr
         
		  pop ds
          pop di
          pop ax
          RETF   
OVERLAY ENDP

WriteStr PROC NEAR
          push ax
          mov ah,09h
          int 21h
          pop ax
          ret
WriteStr ENDP

TETR_TO_HEX PROC NEAR
          and AL,0Fh
          cmp AL,09
          JBE NEXT
          add AL,07
NEXT:     add AL,30h
          ret
TETR_TO_HEX  ENDP

BYTE_TO_HEX PROC NEAR
          push CX
          mov AH,AL
          call TETR_TO_HEX
          XCHG AL,AH
          mov CL,4
          shr AL,CL
          call TETR_TO_HEX     
          pop CX             
          ret
BYTE_TO_HEX ENDP

WORD_TO_HEX PROC NEAR
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
WORD_TO_HEX  ENDP

ADDRESS  db 'Overlay2 address:    H',0DH,0AH,'$'
CODE      ENDS
          END       OVERLAY
