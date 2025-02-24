DATA SEGMENT PARA			
NUM1 DB 03,09,00,06,05,00	;存放被乘数56093的非压缩BCD码
NUM2 DB 05				    ;存放乘数的非压缩BCD码
NUM3 DB 08,04,03,03,05,00   ;存放被乘数53348的非压缩BCD码
NUM4 DB 09                  ;存放乘数的非压缩BCD码
SUM1 DB 8 DUP(?)     		;定义一个未知长度的空间存放和的非压缩BCD码形式
SUM2 DB ?       			;定义一个未知长度的空间存放和的非压缩BCD码形式
DATA ENDS	

CODE SEGMENT					
ASSUME CS:CODE,DS:DATA	
START:  MOV AX,DATA			
		MOV DS,AX			;DS初始化为数据段首地址的段值DATA	      

		LEA  SI, NUM2		;将乘数的偏移地址给SI
		MOV BL,[SI]			;将乘数赋值给BL,BL=05
		LEA SI, NUM1		;将被乘数的偏移地址给SI
		MOV AL,[SI]			;将被乘数的非压缩BCD码最低位赋值给AL
		LEA DI,SUM1		    ;将结果偏移地址给DI,DI指向最终结果[000E]
		MOV CX,06			;循环6次
		MOV DL, 00			;将DL清零
AGAIN1:	MUL BL			    ;当前被乘数与乘数相乘
		AAM					;二化十指令，将乘法结果调整为非压缩BCD码表示
		ADD AL,DL			;将前一位的进位加上当前结果
		AAA					;加法结果调整为非压缩BCD码，将进位加到AH上
		MOV DL, AH			;将当前的进位存到DL
		MOV AH, 00H			;清零AH 
		MOV [DI],AL			;将当前位的值存到存储单元
		INC SI				;SI指向下一个单元
		INC DI				;DI指向下一个单元
		MOV AL,[SI]			;将被乘数下一位的非压缩BCD码赋值给AL
		LOOP AGAIN1			;在指定的循环次数内循环计算

        LEA  SI, NUM4		;将乘数的偏移地址给SI
		MOV BL,[SI]			;将乘数赋值给BL,BL=05
		LEA SI, NUM3		;将被乘数的偏移地址给SI
		MOV AL,[SI]			;将被乘数的非压缩BCD码最低位赋值给AL
		LEA DI,SUM2		    ;将结果偏移地址给DI,DI指向最终结果[0016]
		MOV CX,06			;循环6次
		MOV DL, 00			;将DL清零
AGAIN2:	MUL BL			    ;当前被乘数与乘数相乘
		AAM			        ;二化十指令，将乘法结果调整为非压缩BCD码表示
		ADD AL,DL			;！将前一位的进位加上当前结果
		AAA				    ;加法结果调整为非压缩BCD码，将进位加到AH上
		MOV DL, AH			;！将当前的进位存到DL
		MOV AH, 00H			;清零AH 
		MOV [DI],AL			;将当前位的值存到存储单元
		INC SI				;SI指向下一个单元
		INC DI				;DI指向下一个单元
		MOV AL,[SI]			;将被乘数下一位的非压缩BCD码赋值给AL
		LOOP AGAIN2			;在指定的循环次数内循环计算

        MOV  AH,4CH         ;功能号4CH
        INT 21H             ;类型号21H，利用中断向量返回DOS
CODE ENDS                   ;代码段结束
END START                   ;整个程序汇编结束
