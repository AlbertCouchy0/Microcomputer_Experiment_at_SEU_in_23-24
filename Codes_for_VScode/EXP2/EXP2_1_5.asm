CODE	SEGMENT
		ASSUME CS:CODE
START:	
		MOV  AX,00
        DEC  AX
        ADC  AX,3FFFH
        ADD  AX,AX
        NOT  AX
        SUB  AX,3
        OR   AX,0FBFDH
        AND  AX,0AFCFH
        MOV CL,1
        SHL  AX,CL
        RCL  AX,1   


CODE	ENDS
		END START
