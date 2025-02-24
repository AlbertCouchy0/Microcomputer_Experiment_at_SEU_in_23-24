DATA   SEGMENT;                   		定义数据段
TIME 	DB  9;
		DB  ?;
DB 9  DUP(?); 			初始化内存
DATA   ENDS 

STA  SEGMENT  STACK;
	DB  20  DUP(0);
STA  ENDS

CODE   SEGMENT ; 			定义代码段
ASSUME  CS: CODE, DS:DATA,SS:STA;
START:   MOV  AX, DATA 
	MOV  DS, AX;          	给DS附上初值
	MOV  DL, ':';			给dl赋值，输出冒号
	MOV  AH, 2;	
	INT  21H;				在屏幕上输出冒号
	LEA  DX, TIME;		提供缓存区地址
	MOV  AH, 0AH;	
	INT 21H;				输入
	MOV  BX, OFFSET  TIME+2;	BX取到数组的首地址 	
	CALL  ASCtoBCD;		把缓存区ASC码的转换成BCD码

AGAIN:    
	CALL  DELAY;		延迟
	CALL  TIMECHANGE;		时间加一秒
	CALL  SHOW;			显示时间
	PUSH  DX;				保护DX
	MOV  AH, 06H;
	MOV  DL, 0FFH;
	INT  21H;			判断是否有按键输入
	POP  DX;			弹出DX
	JNZ  AAA;			有按键输入则跳转	
	JMP  AGAIN;		没有按键输入，则继续计时
AAA:	
	MOV  AH, 4CH;		返回dos，主程序结束
	INT  21H;

ASCtoBCD  PROC;			ASC变压缩BCD的子程序
	MOV  BX, OFFSET  TIME+2;	指针指向数据区
	CALL  TRAN;			调用TRAN子程序
	MOV  CH, [BX];		把时针值给CH
	ADD  BX, 3;
	CALL  TRAN;
	MOV  DH, [BX];		把分针值给DH
	ADD  BX, 3;
	CALL  TRAN;
	MOV  DL, [BX];		把秒针值给DL
	RET
ASCtoBCD ENDP

TRAN  PROC;			TRAN子程序,辅助ASCtoBCD
	MOV  AL, [BX+1];
	AND   AL, 0FH;		个位数字的ASC变BCD
	MOV  [BX+1], AL;
	MOV  AL, [BX];
	SHL  AL, 1;
	SHL  AL, 1;
	SHL  AL, 1;
	SHL  AL, 1;			十位数字的ASC变BCD		
	ADD  AL, [BX+1];		变压缩BCD，用于后时间的加法计算		
	MOV  [BX], AL;
	RET
TRAN ENDP

DELAY  PROC;				延迟函数的定义
	PUSH CX
	PUSH AX
	MOV CX,0FFFFH                   ;当CX从0FFFFH减到0时，不再调用GOON
GOON2: 	MOV AX,016H
GOON1: 	DEC AX
	JNE GOON1
	DEC CX
	JNE GOON2
	POP AX
	POP CX
	RET
DELAY   ENDP


TIMECHANGE  PROC;		时间加一 子程序定义
	MOV AL, DL;
	ADD  AL, 1;		秒针加一
	DAA;				压缩BCD码运算的重要流程
	MOV  DL, AL;
	CMP  AL, 60H;		秒针和60比较，注！这里一定是60H，不是60
	JNE  DONE;		比60小，直接RET
	MOV  DL, 00H;		>60，进行进位调整
	MOV AL, DH;		
	ADD  AL, 1;
	DAA;
	MOV  DH, AL;
	CMP  AL, 60H;		分针和60比较
	JNE  DONE;		比60小，直接RET
	MOV  DH, 00H;		>60，进行进位调整
	MOV AL, CH;
	ADD  AL, 1;
	DAA;
	MOV  CH, AL;
	CMP  AL, 24H;		时针和24比较
	JNE  DONE;		比24小，直接RET
	MOV  CH, 00H;		>24，进行进位调整
DONE:	RET
TIMECHANGE   ENDP


SHOW  PROC;			show子程序定义
	MOV  BX, OFFSET  TIME
	MOV  AL, 0DH
	MOV  [BX], AL
	INC  BX
	MOV  AL, 0AH
	MOV  [BX], AL; 		以上为输出缓冲区做准备
	INC  BX
	MOV  AL, CH;			时针给到AL
	CALL BCDtoASC;		将时针压缩BCD展开成两个ASC码
	ADD  BX, 2;			指针位移
	MOV  AL, ':'
	MOV  [BX], AL;		准备输出“：”
	INC  BX
	MOV  AL, DH;			分针给到AL
	CALL BCDtoASC;		将分针压缩BCD展开成两个ASC码
	ADD  BX, 2
	MOV  AL, ':'
	MOV  [BX], AL
	INC  BX
	MOV  AL, DL;			秒针给到AL
	CALL BCDtoASC;		将秒针压缩BCD展开成两个ASC码
	ADD  BX, 2
	MOV  AX, '$';			输出结尾标志
	MOV  [BX], AL
	PUSH  BX
	PUSH  CX
	PUSH  DX;				压栈保护现场
	MOV  DX,  OFFSET  TIME
	MOV  AH, 9
	INT  21H;				在屏幕显示时间
	POP  DX
	POP  CX
	POP  BX;				恢复现场
	RET
SHOW  ENDP

BCDtoASC  PROC;		BCDtoASC子程序定义
	MOV CL, AL;		暂存AL
	SHR  AL, 1
	SHR  AL, 1
	SHR  AL, 1
	SHR  AL, 1
	OR    AL, 30H;		十位展开成ASC，恢复
	MOV  [BX], AL
	MOV  AL, CL
	AND  AL, 0FH
	OR    AL, 30H;		个位展开成ASC，恢复
	MOV  [BX+1], AL
	RET
BCDtoASC  ENDP
CODE    ENDS		
END   START
