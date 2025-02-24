DATA SEGMENT
STR1 DB 30H,31H,32H,33H,34H,35H,36H,37H,38H,39H,40H,41H,42H,43H,44H,45H
SLENGTH EQU $-STR1              ;直接获取元素个数
STR2 DB SLENGTH DUP(0)		;STR2为将要移动的目标地址
DATA ENDS		
			
CODE SEGMENT				
ASSUME DS: DATA, CS: CODE, ES: DATA
START:  MOV AX,DATA			
	MOV DS,AX               ;DS初始化为数据段首地址的段值DATA

	MOV ES, AX
	LEA SI, STR1		;取STR1地址
	LEA DI, STR2		;取STR2地址
	MOV CX, SLENGTH	        ;CX定义为要移动的字符串长度
	CLD			;设为指针向后移动,地址加
	REP MOVSB		;移动字符串

        MOV AH,4CH              ;功能号4CH
        INT 21H                 ;类型号21H，利用中断向量返回DOS
CODE ENDS                       ;代码段结束
END START                       ;整个程序汇编结束
