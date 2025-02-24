CODE	SEGMENT
		ASSUME CS:CODE
START:	
		;DS:[0000H]=23H，DS:[0001H]=43H，DS:[0010H]=61H，DS:[0011H]=25H。
        MOV   AL,DS:[0000H] 
        SUB   AL,DS:[0010H]     ;AL=?
        DAS	                  ;AL=?
        MOV   BYTE PTR DS:[0020H] ,AL
        MOV   AL, DS:[0001H] 
        SBB   AL, DS:[0011H]    ;AL=?
        DAS	  		        ;AL=?
        MOV  BYTE PTR DS:[0021H] ,AL 



CODE	ENDS
		END START

