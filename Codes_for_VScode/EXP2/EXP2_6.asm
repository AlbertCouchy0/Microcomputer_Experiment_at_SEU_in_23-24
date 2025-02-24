CODE	SEGMENT
		ASSUME CS:CODE
START:	
		;[0000H]=18H ，[0001H]=34H，[0010H]=98H ，[0011H]=27H。
        MOV   AL,DS:[0000H] 
        ADD   AL,DS:[0010H]     
        DAA	                  
        MOV   BYTE PTR DS:[0020H] ,AL
        MOV   AL,DS:[0001H] 
        ADC   AL,DS:[0011H]   
        DAA	  		       
        MOV  BYTE PTR DS:[0021H],AL 


CODE	ENDS
		END START

