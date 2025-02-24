DATA   SEGMENT;         定义数据段
    TIME 	DB  9;
	        DB  ?;
            DB 9  DUP(?); 			
    ERROR1  DB 2 DUP(?); 
            DB 'Wrong Format';
    ERROR2  DB 2 DUP(?);
            DB 'Wrong Time';
DATA   ENDS 

STA  SEGMENT  STACK;
	DB  20  DUP(0);
STA  ENDS

CODE   SEGMENT ; 		定义代码段
ASSUME  CS: CODE, DS:DATA,SS:STA;
START:    MOV  AX, DATA 
	MOV  DS, AX;        给DS附上初值
	MOV  DL, ':';		给dl赋值，输出冒号
	MOV  AH, 2;	
	INT  21H;			在屏幕上输出冒号
	LEA  DX, TIME;		提供缓存区地址
	MOV  AH, 0AH;	
	INT  21H;			输入
	MOV  BX, OFFSET  TIME+2;	BX取到数组的首地址 
	CALL  INPUTerror;	判断输入格式是否错误		实现附加功能2
RIG:	
    CALL  ASCtoBCD;		把缓存区ASC码的转换成BCD码
	CALL  TIMEerror;	判断时间符合实际		实现附加功能2
    ;
    MOV  AH, 0BH                    
    MOV  BH, 0FH                                
    INT 10H
AGAIN:    
    CALL  MDELAY;	调用延迟函数
	CALL  TIMECHANGE;	调用时间加一秒函数
	CALL  SHOW;		    调用显示时间函数
	PUSH  DX;		    压栈保护DX
	MOV  AH, 06H;
	MOV  DL, 0FFH;
	INT  21H;			判断是否有按键输入
	POP  DX;			弹出DX
	JNZ  AAA;			有按键输入则跳转	
	JMP  AGAIN;		    没有按键输入，则继续计时
AAA:	
    MOV  AH, 4CH;		返回dos，主程序结束
	INT  21H;

;判断输入错误的子程序
INPUTerror  PROC	
	MOV  CL, 00H; 		开始CL置零

	MOV AL, [BX];		提取BX对应的值
	CALL  NUMerror;		判断是否是数字
	INC  BX;			判断下一字节

    MOV AL, [BX];		提取BX对应的值
	CALL  NUMerror;		判断是否是数字
	INC  BX;			判断下一字节

	MOV AL, [BX];       提取BX对应的值
	CALL  COLONerror;   判断是否是冒号		
	INC  BX;            判断下一字节

    MOV AL, [BX];		提取BX对应的值
	CALL  NUMerror;		判断是否是数字
	INC  BX;			判断下一字节

	MOV AL, [BX];		提取BX对应的值
	CALL  NUMerror;		判断是否是数字
	INC  BX;			判断下一字节

	MOV AL, [BX];       提取BX对应的值
	CALL  COLONerror;   判断是否是冒号		
	INC  BX;            判断下一字节

	MOV AL, [BX];		提取BX对应的值
	CALL  NUMerror;		判断是否是数字
	INC  BX;			判断下一字节

	MOV AL, [BX];		提取BX对应的值
	CALL  NUMerror;		判断是否是数字

	CMP CL, 00H; 		CL=0说明格式正确
	JE RIG ;			正确跳转
error:	
    MOV  DX,OFFSET  ERROR1
	MOV  BX, OFFSET  ERROR1
	MOV  AL, 0DH;	输出回车
	MOV  [BX], AL  
	INC  BX
	MOV  AL,0AH;	输出换行
	MOV  [BX],AL
    ADD  BX,13D;    指针跳转
    MOV  AL,0AH;    输出换行
    MOV  [BX],AL;
    INC  BX
    MOV  AX, '$';	输出结尾标志
	MOV  [BX], AL
	
	MOV  AH, 9
	INT  21H;		在屏幕显示ERROR1		 
	JMP  START;		跳回开头
	RET
INPUTerror  ENDP

    ;判断数字错误的子程序
    NUMerror PROC
	CMP AL, 39H;		
	JA  ERR1;
	CMP  AL, 30H;	
	JB  ERR1;		以上都是比较ASC码，30，39为数字在ASC码表中范围
	RET
    ERR1:	
    MOV CL, 01H;	其ASC码若不在数字范围，CL置1	
	RET
    NUMerror ENDP

    ;判断冒号错误的子程序
    COLONerror PROC
	CMP  AL, 3AH;	3AH是“：”的ASC码
	JNE ERR2;
	RET
    ERR2:	
    MOV CL, 01H;	ASC码若不是规定值，CL置1	
	RET
    COLONerror ENDP

;ASC变压缩BCD的子程序
ASCtoBCD  PROC
	MOV  BX, OFFSET  TIME+2;	指针指向数据区
	CALL  TRAN;		调用TRAN子程序
	MOV  CH, [BX];	把时针值给CH
	ADD  BX, 3;
	CALL  TRAN;
	MOV  DH, [BX];	把分针值给DH
	ADD  BX, 3;
	CALL  TRAN;
	MOV  DL, [BX];	把秒针值给DL
	RET
ASCtoBCD ENDP
;TRAN子程序,辅助ASCtoBCD
TRAN PROC
	MOV  AL, [BX+1];
	AND  AL, 0FH;	个位数字的ASC变BCD
	MOV  [BX+1], AL;
	MOV  AL, [BX];
	SHL  AL, 1;
	SHL  AL, 1;
	SHL  AL, 1;
	SHL  AL, 1;		十位数字的ASC变BCD		
	ADD  AL, [BX+1];变压缩BCD，用于后时间的加法计算		
	MOV  [BX], AL;
	RET
TRAN ENDP

;判断时间符合实际的子程序
TIMEerror  PROC
	MOV  CL, 00H;		
	CMP  CH, 24H;		将“时”和24比较
	JAE  DO;			和24等，或>24则跳转
	CMP  DH, 60H;		将“分”和60比较
	JAE  DO;			和60等，或>60则跳转
	CMP  DL, 60H;		将“秒”和60比较
	JAE  DO;			和60等，或>60则跳转
	JMP  AGAIN
DO:	MOV  DX,OFFSET  ERROR2
	MOV  BX, OFFSET  ERROR2
	MOV  AL, 0DH;	    输出回车
	MOV  [BX], AL  
	INC  BX
	MOV  AL,0AH;		输出换行
	MOV  [BX],AL
    ADD  BX,11D;        指针跳转
    MOV  AL,0AH;        输出换行
    MOV  [BX],AL;
    INC  BX
    MOV  AX, '$';	    输出结尾标志
	MOV  [BX], AL

	MOV  AH, 9
	INT  21H;		    在屏幕显示ERROR2		 
	JMP  START;		    跳回开头
	RET	
TIMEerror ENDP

;延迟函数的定义（附加功能3）
MDELAY  PROC
    ;压栈保护现场
	PUSH  AX;
	PUSH BX;
	PUSH CX;
	PUSH DX;

	MOV AH, 2CH         ; 使用系统调用 INT 21H, AH=2CH 获取当前系统时间
	INT 21H             ; 【CH小时,CL分,DH秒,DL百分之一秒】

	ADD DH, 1H          ; 将当前秒数加1
	CMP DH, 3CH			; 与60比较，如果不等于60，可以进行下一步
	JNE NOTEQU 		
	MOV DH, 00H			; 如果相等需要将DH置0	
NOTEQU: 
    MOV BL, DH		    ; 无论是否相等都会执行的程序写在跳转的语句中。
COMPARETIME: 
    MOV AH, 2CH
	INT 21H
	CMP BL, DH          ; 比较备份的秒数和当前秒数是否相等，相等则延时完成
	JNE COMPARETIME     ; 如果不相等，继续等待
    ;弹出恢复现场
	POP DX
	POP CX
	POP BX
	POP AX
	RET
MDELAY   ENDP

;时间加一子程序
TIMECHANGE  PROC
	MOV AL, DL;
	ADD  AL, 1;		秒针加一
	DAA;			压缩BCD码运算的重要流程
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

;SHOW子程序
SHOW  PROC
    MOV  BX, OFFSET  TIME   ; 将 TIME 的偏移地址加载到 BX 寄存器中
    ; 加载回车 '\r'
    MOV  AL, 0DH             
    MOV  [BX], AL           
    INC  BX      
    ; 加载冒号 '：'           
    MOV AL, 3AH            
    MOV [BX], AL            
    INC BX                  
    ; 加载时钟值
    MOV  AL, CH             ; 将时钟值加载到 AL 寄存器中
    CALL BCDtoASC           ; 调用 BCDtoASC 子程序将分钟值转换为 ASCII 码
    ADD  BX, 2              ; 将 BX 寄存器增加 2，指向 TIME 缓冲区的下一个位置
    ; 加载冒号 '：'
    MOV  AL, ':'            
    MOV  [BX], AL           
    INC  BX                 
    ; 加载分钟值
    MOV  AL, DH             ; 将分钟值加载到 AL 寄存器中
    CALL BCDtoASC           ; 调用 BCDtoASC 子程序将分钟值转换为 ASCII 码
    ADD  BX, 2              ; 将 BX 寄存器增加 2，指向 TIME 缓冲区的下一个位置
    ; 加载冒号 '：'
    MOV  AL, ':'            
    MOV  [BX], AL           
    INC  BX                 
    ; 加载秒钟值
    MOV  AL, DL             ; 将秒钟值加载到 AL 寄存器中
    CALL BCDtoASC           ; 调用 BCDtoASC 子程序将秒钟值转换为 ASCII 码
    ADD  BX, 2              ; 将 BX 寄存器增加 2，指向 TIME 缓冲区的下一个位置
    ;字符 '$'
    MOV  AX, '$'            
    MOV  [BX], AL          
    ;压栈保护现场
    PUSH  BX                
    PUSH  CX                
    PUSH  DX    
   
    ;在屏幕上显示
    MOV  DX,  OFFSET  TIME  
    MOV  AH, 9              
    INT  21H            
    ;弹出恢复现场    
    POP  DX                
    POP  CX                 
    POP  BX                
    RET                   
SHOW  ENDP

;BCDtoASC子程序定义
BCDtoASC  PROC
	MOV  CL, AL;		暂存AL
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
