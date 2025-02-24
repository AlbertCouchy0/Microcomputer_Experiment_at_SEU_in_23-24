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
	MOV AX,0
	MOV ES,AX			
;保存原1CH中断向量
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
	CALL DELAY
 	MOV AL, 03   ;设置显示方式(80*25彩色文本)
    MOV AH, 0       
    INT 10H      ;清屏
    INC DH       ;行号+1
    ADD DL, 2    ;列号+2
    SUB BX,BX
;查看是否到了最大行数
    MOV SI, OFFSET  LINE;	BX取到数组的首地址 
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
;延时500ms子程序
DELAY	PROC	
        ;压栈
	    PUSH DX
	    PUSH CX
        PUSH BX
	    PUSH AX
        ;中断调用延时
	    MOV AH, 2CH
	    INT 21H	;DOS调用系统时间
	    MOV BL, DL	;存储当前秒数
		ADD BL, 50
		MOV BH, DH	;存储当前百分秒数
		ADD BH, 1
DL_BEGIN:
	    INT 21H	;调用系统时间
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
	    RET
DELAY	ENDP

;——————————————————TIMERINTS子程序————————————————————————————
;设置计时器中断服务子程序
TIMERINTS PROC FAR
	PUSH AX
	PUSH SI
	CLI
	INC COUNT
	CMP COUNT,18   ;定时1秒左右
	JNE GO1
	MOV COUNT,0;每到50次清零
	MOV SI,OFFSET MSG1
	INC LOS;计数10次停止
	CALL FAR PTR DISP2	
GO1:
	POP SI
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
