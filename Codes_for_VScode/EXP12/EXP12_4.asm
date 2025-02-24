DATA    SEGMENT                                     ;定义数据段
SHOW DB  0AH,0DH, 'ICE CREAM AND TEA:$'             ;0AH,0DH为换行，回车
FREQ 	DW  660,784,1,784,880,784,660,524,1,524,588	;查表可得频率,1为休止符
        DW  660,1,660,588,524,588,1
        DW  660,784,1,784,880,784,660,524,1,524,588
        DW  660,1,660,588,1,588,524,0

TIME	DW  50,50,5,75,25,50,50,50,5,25,25          ;多少个10ms
        DW  50,5,50,50,50,200,5
        DW  50,50,5,75,25,50,50,50,5,25,25
        DW  50,5,50,50,5,50,200,0
DATA    ENDS


STACK   SEGMENT PARA STACK 'STACK'                   ;定义堆栈段
        DW  200 DUP(?)
STACK   ENDS

CODE    SEGMENT
	ASSUME  CS:CODE, DS:DATA,SS:STACK

START:
	MOV AX,DATA
	MOV DS,AX		                ;初始化数据段
	MOV AX,STACK		
	MOV SS,AX		                ;初始化堆栈段
	MOV DX,OFFSET SHOW
	MOV AH,09
	INT 21H 			            ;显示提示信息
	MOV SI,OFFSET FREQ	            ;将频率数据地址给SI
	MOV BP,OFFSET TIME	            ;将节拍时间数据的地址给BP
	CALL SING
	MOV AH,4CH
	INT 21H			                ;程序结束，返回DOS

SING PROC NEAR  
        PUSH DI
        PUSH SI
        PUSH BP
        PUSH BX
RETP:  	MOV DI,DS:[SI]		        ;取频率给DI
        CMP DI,0        		    ;0意味着程序结束
        JE END_SING		
	    MOV BX,DS:[BP]		        ;取节拍给BX
        CALL SOUND         		    ;参数为DI和BX
        ADD SI,2
        ADD BP,2
        JMP RETP
END_SING:
		POP  BX
        POP  BP
      	POP  SI
        POP  DI
        RET
SING ENDP

SOUND PROC  NEAR
        PUSH AX
       	PUSH BX          		    ;BX节拍时间数据
        PUSH CX
       	PUSH DX
        PUSH DI           		    ;DI给定频率数据
        MOV AL,10110110B     	    ;8253初始化(通道2，方式3，产生方波信号)
        OUT 43H,AL      		    ;43H端口是8253的命令寄存器

	    CMP DI,1                    ;判断是否为休止符
	    JE DELAY

        MOV DX,12H      		    ;计算折算频率（时间常数）
        MOV AX,34DCH                ;1234CDH除以给定频率
        DIV DI

        OUT 42H,AL      		    ;给8253通道2设置计数初值（先写低字节，再写高字节）
        MOV AL,AH
        OUT 42H,AL

        IN  AL,61H  		        ;读8255B口
        MOV AH,AL
        OR  AL,3       	 	        ;8255——PB1PB0置1，开喇叭
        OUT 61H,AL
DELAY:
  	CALL DELAYS  
	DEC BX			        ;BX—节拍时间对应10ms的倍数，如:BX=100,节拍时间=10ms*100=1s
        JNZ  DELAY
        
    MOV   AL,AH
    OUT   61H,AL       		        ;8255——PB1PB0恢复为零，关喇叭
    POP DI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
SOUND   ENDP

DELAYS	PROC	NEAR
        ;压栈
	    PUSH DX
	    PUSH CX
            PUSH BX
	    PUSH AX
        ;中断调用延时
	    MOV AH, 2CH
	    INT 21H	;DOS调用系统时间
	    MOV BL, DL	;存储当前1/100秒数
            MOV BH, DH
            INC BH
            INC BL
DELAY_BEGIN:
            MOV AH, 2CH
	    INT 21H	;调用系统时间
	    CMP BH, DH	;比较当前时间与上次调用的秒是否变化
	    JNE DELAY_NEXT	;若有变化，则完成延时，退出程序
            CMP BL, DL	;比较当前时间与上次调用的百分秒是否变化
	    JAE DELAY_NEXT	;若，则完成延时，退出程序
	    JMP DELAY_BEGIN	;若无变化，则继续调用系统时间
DELAY_NEXT:
        ;弹出
	    POP AX
            POP BX
	    POP CX
	    POP DX
	    RET
DELAYS	ENDP

CODE ENDS
END START 
