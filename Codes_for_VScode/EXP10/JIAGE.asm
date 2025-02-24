STACK   SEGMENT
        STK  DW 200H DUP(?)
STACK   ENDS            ;堆栈段定义

DATA    SEGMENT
        KEY     DB 0    ;存储按下键盘的次数，初值为0
        MSG   DB "OK!"  ;存储按下键盘后的提示信息
DATA    ENDS

CODE    SEGMENT
        ASSUME CS:CODE, SS:STACK, DS:DATA
STAR: 
        MOV AX, STACK
        MOV SS, AX
        MOV AX, DATA
        MOV DS, AX
        ;保存原09H中断内容
        MOV AX, 0
        MOV ES, AX      ;ES用来存放中断向量表的段地址(物理地址：00000H)
        MOV AX, ES:[24H];获取09H中断偏移地址，[24H]即为00036D,是为09H在中断向量表的首地址
        PUSH AX
        MOV AX, ES:[26H];获取09H中断段地址
        PUSH AX 
        ;存入新中断内容KEYINT
        CLI             ;屏蔽外部中断，防止可能受到的干扰
        MOV AX, OFFSET KEYINT
        MOV ES:[24H], AX
        MOV AX, SEG KEYINT
        MOV ES:[26H], AX    
        STI             ;存完后打开外部中断屏蔽
AGAIN:  
        CALL FAR PTR SHOW1  ;显示一轮太阳图形
        CMP KEY, 10     ;判断按键是否按下10次
        JB AGAIN        ;键盘未按下十次，则继续下一轮显示太阳图形
        ;若按下了十次，进行处理
        CLI             ;屏蔽外部中断，准备将原有中断向量恢复到中断向量表中
        POP AX
        MOV ES:[26H], AX
        POP AX
        MOV ES:[24H], AX
        STI             ;打开外部中断

        MOV AH, 4CH
        INT 21H         ;返回DOS

KEYINT  PROC FAR
        PUSH AX
        PUSH SI
        STI
        IN AL, 60H
        MOV AH, AL  ;从8255A的PA口读入键盘扫描码，将其存入AH
        IN AL, 61H  ;读入PB口的当前值
        OR AL, 80H  ;PB7置1
        OUT 61H, AL
        AND AL, 7FH ;PB7置0，完成在PB7口的一次正脉冲输出
        OUT 61H, AL
        TEST AH, 80H    ;检测键盘扫描码的最高位是否为1
        JNZ GO  ;若最高位为1，说明此时键盘释放，跳转到子程序出口处
        STI
        INC KEY ;若最高位为0，说明此时键盘按下，给计数器加一
        CALL FAR PTR SHOW2  ;并显示提示信息
GO:
        MOV AL, 20H
        OUT 20H, AL ;给8259A的OCW1发出表示中断结束的EOI命令
        POP SI
        POP AX
        IRET
KEYINT  ENDP

DELAYS	PROC	;用于延时一秒
	PUSH DX
	PUSH CX
        PUSH BX
	PUSH AX
	MOV AH, 2CH
	INT 21H	;DOS调用系统时间
	MOV BH, DH	;存储当前秒数
BEGIN:
	INT 21H	;调用系统时间
	CMP BH, DH	;比较当前时间与上次调用的时间是否变化
	JNE ENDSECOND	;若有变化，则完成延时，退出程序
	JMP BEGIN	;若无变化，则继续调用系统时间
ENDSECOND:
	POP AX
        POP BX
	POP CX
	POP DX
	RET
DELAYS	ENDP

SHOW1   PROC FAR    ;显示太阳图形的子程序
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX

        MOV AH, 15  ;读取当前显示状态
        INT 10H
        MOV AH, 0
        INT 10H
        MOV CX, 1
        MOV DX, 0   ;设置光标起始位置为行号为0，列号为0
REPEAT:
        CMP KEY, 10
        JAE EXIT
        MOV AH, 2   ;设置光标位置
        INT 10H
        MOV AL, 0FH ;太阳图形的ASCII码
        MOV CX, 1
        MOV AH, 10  ;显示单个太阳图形
        INT 10H
        CALL DELAYS  ;延时一秒
        SUB AL, AL
        MOV AH, 6       ;上滚屏幕，清除原图形
        INT 10H
        INC DH  ;行号+1
        ADD DL, 2   ;列号+2
        CMP DH, 25
        JB REPEAT ;如果没到25行，则跳转到REPEAT更新光标位置；到了25行则退出子程序
EXIT:
        POP DX
        POP CX
        POP BX
        POP AX
        RET
SHOW1   ENDP

SHOW2   PROC FAR    ;用于显示提示信息的子程序
        PUSH SI
        PUSH DX
        PUSH CX
        PUSH BX
        PUSH AX
        LEA SI, MSG   ;将字符串MSG的首地址装入SI
        MOV AH, 3
        MOV BH, 0
        INT 10H ;读取当前光标位置
        INC DL  ;列号+1
        MOV AH, 2
        INT 10H ;将光标设在下一个位置，避免覆盖原字符
        MOV CX, 3   ;将字符串MSG的长度装入CX
NEXTC:
        LODSB
        MOV AH, 0EH
        MOV BX, 1
        INT 10H
        LOOP NEXTC
        POP AX
        POP BX
        POP CX
        POP DX
        POP SI
        RET
SHOW2   ENDP

CODE    ENDS
        END STAR
