DATA SEGMENT
	;提示消息
	MSG1     DB 	?,?,'-MAKA BAKA'
	SLENGTH1 EQU 	$-MSG1
	MSG2     DB 	?,?,'-WUXI DIXI'
	SLENGTH2 EQU	$-MSG2
	;计数器
	COUNT   DB ?        ;计数次数
	LOS     DB ?	
	KEYN    DB ?
	;计数上限
	LIM1 	EQU 12D		;键盘中断计数上限
	LIM2 	EQU 12D		;定时中断计数上限
	LINE    DB 25       ;最大显示行数
    ;输入时间并判断
    TIME 	DB  3;
	        DB  ?;
            DB 3  DUP(?);
	TTIME 	DB  3;
	        DB  ?;
            DB 3  DUP(?);		
    T       DW 10;
	TT		DB 20;
    TXT1    DB "Please input TIME1 in units of 0.1s(5<=TIME1<=50):$"  ;文本提示1
	TXT2    DB "Please input TIME2 in units of 0.1s(5<=TIME2<=50):$"  ;文本提示1
	GAP 	DB 0AH,'$'
    ERROR0  DB 0DH,0AH,'Wrong Input Format!',0AH,'$'                ;错误提示0
    ERROR1  DB 0DH,0AH,'The Input is too small!',0AH,'$'              ;错误提示1       
    ERROR2  DB 0DH,0AH,'The Input is too big!',0AH,'$'              ;错误提示2       


DATA ENDS

STACK SEGMENT STACK
	DW 200H DUP(?)
STACK ENDS

CODE SEGMENT
	ASSUME CS:CODE,SS:STACK,DS:DATA
;显示太阳的子程序
START:
;给段寄存器赋值

	MOV AX,STACK
	MOV SS,AX
	MOV AX,DATA
	MOV DS,AX
    ;输出TXT1文本

    LEA SI,TXT1         ;取TXT1地址
    MOV DX,SI           ;赋值地址给DX
    MOV AH,09			;功能号09H
    INT 21H    			;类型号21H，显示DS：DX指向的以$结尾的字符串
	;输入TIME1并检验
    LEA SI,TIME;
    MOV DX,SI           ;赋值地址给DX
    MOV  AH, 0AH;	
	INT  21H;			输入
	MOV  BX, OFFSET  TIME+2;	BX取到数组的首地址 
    CALL  INPUTerror;	判断输入格式是否错误
    CALL  ASCtoNUM1;		把缓存区ASC码转换成NUM
	CALL  VALUEerror;	判断时间符合实际	
	;换行
	MOV  DX, OFFSET  GAP
	MOV  AH, 9
	INT  21H;	
	;清零	
	SUB AX,AX
	SUB BX,BX
	SUB CX,CX
    SUB DX,DX
START2:
	;输出TXT2文本
	MOV BP,1 
    LEA SI,TXT2         ;取TXT2地址
    MOV DX,SI           ;赋值地址给DX
    MOV AH,09			;功能号09H
    INT 21H    			;类型号21H，显示DS：DX指向的以$结尾的字符串
	;输入TIME2并检验
    LEA SI,TTIME;
    MOV DX,SI           ;赋值地址给DX
    MOV  AH, 0AH;	
	INT  21H;			输入
	MOV  BX, OFFSET  TTIME+2;	BX取到数组的首地址 
    CALL  INPUTerror;	判断输入格式是否错误
    CALL  ASCtoNUM2;		把缓存区ASC码转换成NUM
	CALL  VALUEerror;	判断时间符合实际	
	
;保存原1CH中断向量
	MOV AX,0
	MOV ES,AX	

	MOV AX,ES:[1CH*4]
	PUSH AX
	MOV AX,ES:[1CH*4+2]
	PUSH AX
;置1CH中断向量
	CLI
	MOV AX,OFFSET TIMERINTS
	MOV ES:[70H],AX
	MOV AX,SEG TIMERINTS
	MOV ES:[72H],AX
	STI
;保存原09H的中断
	MOV AX,ES:[09H*4]
	PUSH AX
	MOV AX,ES:[09H*4+2]
	PUSH AX
	PUSH DS
;置09H中断向量
	CLI
	MOV	AX, SEG KEYINT
	MOV	DS, AX
	MOV	DX, OFFSET KEYINT
	MOV	AL, 09H				
	MOV	AH, 25H
	INT	21H
	STI
	POP DS;
;计数值置0
	;MOV MSG2,0
	MOV LOS,0
	MOV COUNT,0
	MOV KEYN,0
;调用DISP1显示太阳
AGAIN:
	CALL FAR PTR DISP1
	CMP KEYN,LIM1;与12比较
	JAE NEXT1
	CMP LOS,LIM2;与12比较
	JAE NEXT2
	JMP AGAIN
;恢复09H中断
NEXT1:	
	CLI
	POP ES:[09H*4+2]
	POP ES:[09H*4]
	STI
;恢复1CH向量
NEXT2:	
	CLI
	POP ES:[72H]
	POP ES:[70H]
	STI
EXIT:
	MOV AH,4CH
	INT 21H

;——————————————————INPUTerror子程序————————————————————————————   
;判断输入格式是否合规的子程序
INPUTerror  PROC
	MOV  CL, 00H; 		开始CL置零

	MOV AL, [BX];		提取BX对应的值
	CALL  NUMerror;		判断是否是数字
	INC  BX;		判断下一字节

    MOV AL, [BX];		提取BX对应的值
	CALL  NUMerror;		判断是否是数字

	CMP CL, 00H; 		CL=0说明格式正确
	JE  RIGHT ;		正确跳转

ERR0:	
    MOV  DX, OFFSET  ERROR0
	MOV  AH, 9
	INT  21H;		在屏幕显示ERROR0	
ERR1:    
    MOV  DX, OFFSET  ERROR1
RIGHT:
	RET
INPUTerror  ENDP

;——————————————————NUMerror子程序————————————————————————————
;判断数字错误的子程序
NUMerror PROC
	CMP AL, 39H;		
	JA  ERR_num;
	CMP  AL, 30H;	
	JB  ERR_num;		以上都是比较ASC码，30，39为数字在ASC码表中范围
	RET
ERR_num:	
    MOV CL, 01H;	其ASC码若不在数字范围，CL置1	
	RET
NUMerror ENDP

;——————————————————ASCtoNUM1子程序————————————————————————————
;ASC变压缩NUM的子程序
ASCtoNUM1  PROC
    PUSH SI;
    PUSH BX;
;转换个位
	MOV  BX, OFFSET  TIME+2;	指针指向数据区
    MOV  SI, OFFSET  T;
	SUB  CX,CX;
	MOV  CL, [BX+1];
	SUB  CL, 30H
;转换十位
	SUB  AX,AX;
    MOV  AL, [BX];
    SUB  AL,30H
;整合相加
    MOV  DL,10;
    MUL  DL;转换十位
    ADD  AX,CX;整合相加
    MOV [SI],AX;储存
    MOV  CL, AL;储存在CL，以便VALUEerror子程序的判断
        
    POP BX;
    POP SI;
	RET
ASCtoNUM1 ENDP

;——————————————————ASCtoNUM2子程序————————————————————————————
;ASC变压缩NUM的子程序
ASCtoNUM2  PROC
    PUSH SI;
    PUSH BX;
;转换个位
	MOV  BX, OFFSET  TTIME+2;	指针指向数据区
    MOV  SI, OFFSET  TT;
	SUB  CX,CX;
	MOV  CL, [BX+1];
	SUB  CL, 30H
;转换十位
	SUB  AX,AX;
    MOV  AL, [BX];
    SUB  AL,30H
;整合相加
    MOV  DL,10;
    MUL  DL;转换十位
    ADD  AX,CX;整合相加
    MOV [SI],AX;储存
    MOV  CL, AL;储存在CL，以便VALUEerror子程序的判断
        
    POP BX;
    POP SI;
	RET
ASCtoNUM2 ENDP

;——————————————————VALUEerror子程序————————————————————————————
;判断时间符合实际的子程序
VALUEerror  PROC
	CMP  CL, 5D;		将行数和25比较
	JB   tooSMALL;			>25则跳转
    CMP  CL, 50D;		将行数和25比较
	JA   tooBIG;			>25则跳转
	JMP  GONEXT;
tooSMALL:	
    MOV  DX, OFFSET  ERROR1
	MOV  AH, 9
	INT  21H;		在屏幕显示ERROR1		 
	JMP  START;		    跳回开头
tooBIG:
    MOV  DX, OFFSET  ERROR2
	MOV  AH, 9
	INT  21H;		在屏幕显示ERROR2		 
	JMP  START;		    跳回开头
GONEXT:
	RET	
VALUEerror ENDP

;——————————————————DISP1子程序————————————————————————————
DISP1 PROC FAR
	PUSH SI
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
;BIOS中断调用，屏幕显示
;读当前显示状态
	MOV AH,15 
	INT 10H
;设置显示模式40*25黑白
	MOV AH,0
	INT 10H
	MOV CX,SLENGTH1     ;显示的字符个数为1
	MOV DX,0 ;行号为0，列号为0
REPT:
;附加任务，12次显示SUN后立即停止返回DOS
	CMP LOS,LIM2;与12比较
	JB 	K1
	JMP D_EXIT1
;附加任务，12次键盘后立即停止返回DOS
K1:	
	CMP KEYN,LIM1;与12比较
	JB 	K2
	JMP D_EXIT1
K2:	
;设置光标位置
	MOV AH,2
	INT 10H
;写字符及属性到当前光标位置处
	MOV AL,0FH
	MOV CX,1
    MOV BL,01001111B	;红底白字
	MOV AH,9
	INT 10H
;延时
    LEA SI,T
    MOV CX,[SI]
DELAYS:
	CALL DELAY
    LOOP DELAYS
;清屏，调整光标   
 	MOV AL, 03   ;设置显示方式(80*25彩色文本)
    MOV AH, 0       
    INT 10H      ;清屏
    INC DH       ;行号+1
    ADD DL, 2    ;列号+2
    SUB BX,BX
;查看是否到了最大行数
    LEA SI,  LINE;	BX取到数组的首地址 
    CMP DH, [SI] 
    JB REPT    ;如果没到LINE行，则跳转到REPEAT更新光标位置；到了LINE行则退出子程序
D_EXIT1:	
	POP DX
	POP CX
	POP BX
	POP AX
	POP SI
	RET
DISP1 ENDP
;——————————————————DISP2子程序————————————————————————————
;显示字符串MSG1的子程序
DISP2  PROC   FAR
	PUSH SI
    PUSH DX
    PUSH CX
    PUSH BX
    PUSH AX
;读取当前光标位置
    MOV AH, 3
    MOV BH, 0
    INT 10H       

    INC DL          ;列号+1
    MOV AH, 2
    INT 10H         ;将光标设在下一个位置，避免覆盖原字符
    
    LEA SI, MSG1        ;将字符串MSG1的首地址装入SI
    MOV BYTE PTR[SI],30H
    MOV BL,LOS
    CMP LOS,10
	JB XIAOYU1
DAYU1:   
	MOV BYTE PTR[SI],31H
    SUB BL,10
XIAOYU1:    
    MOV AL,BL
	OR  AL,30H
	MOV BYTE PTR[SI+1],AL    
    MOV CX, SLENGTH1  ;将字符串MSG1的长度装入CX
NEXTC1:
	MOV BL,01111000B	;白底黑字
	MOV AH,09H
	INT 10H

    LODSB           ;从内存中的SI指向的位置读取一个字节，并将其存入AL寄存器，同时SI寄存器递增。
    MOV AH, 0EH     ;设置 AH 寄存器为 0EH，表示显示字符和属性。 
    MOV BX, 1
    INT 10H
    LOOP NEXTC1
;弹出 
    POP AX
    POP BX
    POP CX
    POP DX
    POP SI
	RET
DISP2    ENDP

;——————————————————DISP3子程序————————————————————————————
;附加任务：显示字符串MSG2的子程序
DISP3  PROC   FAR
;压栈 
    PUSH SI
    PUSH DX
    PUSH CX
    PUSH BX
    PUSH AX
;读取当前光标位置
    MOV AH, 3
    MOV BH, 0
    INT 10H       

    INC DL          ;列号+1
    MOV AH, 2
    INT 10H         ;将光标设在下一个位置，避免覆盖原字符
    
    LEA SI, MSG2         ;将字符串MSG的首地址装入SI
    MOV BYTE PTR[SI],30H
    MOV BL,KEYN

    ;附加功能：加入按键次数KEY
    CMP KEYN,10
	JB XIAOYU2
DAYU2:   
	MOV BYTE PTR[SI],31H
    SUB BL,10
XIAOYU2:    
    MOV AL,BL
	OR  AL,30H
	MOV BYTE PTR[SI+1],AL    
    MOV CX, SLENGTH2  ;将字符串MSG2的长度装入CX
NEXTC2:
	MOV BL,00011110B	;蓝底黄字
	MOV AH,09H
	INT 10H

    LODSB           ;从内存中的SI指向的位置读取一个字节，并将其存入AL寄存器，同时SI寄存器递增。
    MOV AH, 0EH     ;设置 AH 寄存器为 0EH，表示显示字符和属性。 
    MOV BX, 1
    INT 10H
    LOOP NEXTC2
;弹出 
    POP AX
    POP BX
    POP CX
    POP DX
    POP SI
	RET
DISP3    ENDP

;——————————————————DELAY子程序————————————————————————————
;延时100ms子程序
DELAY	PROC	
    ;压栈
	PUSH DX
	PUSH CX
    PUSH BX
	PUSH AX
    MOV BH, DH	;存储当前秒数
	ADD BH, 1
	MOV BL, DL	;存储当前百分秒数
	ADD BL, 10
DL_BEGIN:
    MOV AH, 2CH
	INT 21H	;调用系统时间
    SUB AX,AX;

	CMP DH, BH	;比较当前秒数与BH
	JAE DL_END	;若大于BH，则完成延时，退出程序
	CMP DL, BL	;比较当前百分秒数与BL
	JAE DL_END	;若大于BL，则完成延时，退出程序

	JMP DL_BEGIN	;反之，则继续调用系统时间
DL_END:
    ;弹出
	POP AX
    POP BX
	POP CX
	POP DX
    POP DI
    POP SI
	RET
DELAY	ENDP

;——————————————————TIMERINTS子程序————————————————————————————
;设置计时器中断服务子程序
TIMERINTS PROC FAR
	PUSH AX
	PUSH BX
	PUSH SI
	PUSH DI
	CLI
	LEA DI,TT
	MOV AL,[DI];
	MOV BL,100
	MUL BL;
	MOV BL,55
	DIV BL;
	INC COUNT		;计数器加1
	CMP COUNT,AL   	;定时
	JNE GO1
	MOV COUNT,0		;清零
	MOV SI,OFFSET MSG1
	INC LOS			;计数器加1
	CALL FAR PTR DISP2	
GO1:
	POP DI
	POP SI
	POP BX
	POP AX
	STI
	IRET
TIMERINTS ENDP

;——————————————————KEYINT子程序———————————————————————————————
;设置键盘中断服务程序
KEYINT PROC FAR
;保护现场
	PUSH AX
	PUSH SI
	PUSH DX
	PUSH BX
;关中断
	CLI
;读取键盘扫描码
	IN AL,60H
	MOV AH,AL
;输出一个正脉冲
	IN AL,61H
	OR AL,80H
	OUT 61H,AL
	AND AL,7FH
	OUT 61H,AL
;判断：无键按下则执行退出键盘中断
	TEST AH,80H
	JNE GO2
;有键按下则显示MSG2，KEYN同时计数
	MOV SI,OFFSET MSG2
	INC KEYN
	CALL FAR PTR DISP3
GO2:
;EOI命令
	MOV AL,20H
	OUT 20H,AL
	POP BX
	POP DX
	POP SI
	POP AX
	STI
	IRET
KEYINT ENDP

CODE ENDS
	END START
