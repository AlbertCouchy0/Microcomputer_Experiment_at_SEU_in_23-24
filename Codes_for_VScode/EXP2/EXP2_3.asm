CODE	SEGMENT
		ASSUME CS:CODE
START:	
		MOV AL,15H
        SHL AL,1
        MOV BL,15H
        MUL BL

CODE	ENDS
		END START

