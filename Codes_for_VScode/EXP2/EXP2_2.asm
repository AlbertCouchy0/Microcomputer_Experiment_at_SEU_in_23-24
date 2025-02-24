CODE	SEGMENT
		ASSUME CS:CODE
START:	
		MOV BX,0010H
        MOV Byte PTR [BX],10H
        MOV Byte PTR [BX+1],04H
        MOV Byte PTR [BX+2],30H

        MOV AL,[BX]	
        ADD AL,[BX+1]			
        ADD AL,[BX+2]		
        MOV [BX+3],AL

        MOV AL,[BX]
        MOV CL,[BX+1]
        MUL CX
        MOV CX,0000H
        MOV CL,[BX+2]
        MUL CX
        MOV [BX+4],AX
        MOV [BX+6],DX

CODE	ENDS
		END START

