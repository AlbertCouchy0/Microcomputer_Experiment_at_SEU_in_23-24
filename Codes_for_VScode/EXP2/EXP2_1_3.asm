CODE	SEGMENT
		ASSUME CS:CODE
START:	
		MOV BL,25H
        MOV AL,04H
        MUL BL
		
	

CODE	ENDS
		END START

