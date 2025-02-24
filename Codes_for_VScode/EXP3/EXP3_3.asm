DATA SEGMENT				
	NUM DB 58D,25D,45D,73D,64D,43D	   	;NUM指定的内存单元（字节型）赋初值
	SLENGTH EQU 6						;定义NUM长度为6
	SUM DW ?							;定义SUM
DATA ENDS					

CODE SEGMENT PARA                   ;定义代码段
ASSUME CS:CODE,DS:DATA              ;ASSUME伪指令定义各段寄存器的内容
START:  MOV AX,DATA                 ;NUM的偏移地址赋给SI
        MOV DS,AX                   ;DS初始化为数据段首地址的段值DATA

		MOV CX, SLENGTH			    ;CX定义为数据段长度
		LEA SI, NUM			    	;NUM的偏移地址赋给SI
		MOV AX, 0000			    ;AX清零
        MOV BX, 0000				;BX清零
AGAIN:  MOV BL, [SI]	            ;将SI所指向的内放到BL中
		ADD AX, BX              	;将BX里面的数加到AX中
		INC SI				     	;SI指向下一个数	
		LOOP AGAIN		     	;这里cx-=1，再判断cx？=0，决定跳过loop		
		MOV SUM, AX			 		;将和数存放在以SUM为符号的单元中

        MOV  AH,4CH                 ;功能号4CH
        INT 21H                     ;类型号21H，利用中断向量返回DOS
CODE ENDS                           ;代码段结束
END START                           ;整个程序汇编结束
