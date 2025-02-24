DATA    SEGMENT                                     ;定义数据段
SHOW DB  0AH,0DH, 'SING OF FOUR SEASONS:$'          ;0AH,0DH为换行，回车
FREQ 	DW  660, 660, 588, 524, 588, 524, 494, 440, 440, 440 ;查表可得频率
        	DW  698, 698, 660, 588, 524, 588, 698, 660
        	DW  698, 698, 660, 588, 588, 698, 660, 660, 524, 440, 524
        	DW  494, 660, 588, 524, 494, 524, 440, 0

TIME	DW  100, 50, 50, 50, 50, 50, 50, 100, 100, 200       ;多少个10ms
        	DW  100, 50, 50, 50, 50, 50, 50, 400
        	DW  100, 50, 50, 100, 50, 50, 100, 50, 50, 100, 100
        	DW  100, 100, 50, 50, 50, 50, 400
DATA    ENDS

STACK   SEGMENT PARA STACK 'STACK'                  ;定义堆栈段
        DW  200 DUP(?)
STACK   ENDS

CODE    SEGMENT
	ASSUME  CS:CODE, DS:DATA,SS:STACK

START:
	MOV AX,DATA
	MOV DS,AX		        ;初始化数据段
	MOV AX,STACK		
	MOV SS,AX		        ;初始化堆栈段
	MOV DX,OFFSET SHOW
	MOV AH,09
	INT 21H 			    ;显示提示信息
	MOV SI,OFFSET FREQ	    ;将频率数据地址给SI
	MOV BP,OFFSET TIME	    ;将节拍时间数据的地址给DI
	CALL SING
	MOV AH,4CH
	INT 21H			        ;程序结束，返回DOS

SING PROC NEAR  
        	PUSH DI
        	PUSH SI
        	PUSH BP
        	PUSH BX
RETP:  	MOV DI,[SI]		    ;取频率
        	CMP DI,0        ;0意味着程序结束
        	JE END_SING		
	MOV BX,DS:[BP]		    ;取节拍
        	CALL SOUND      ;参数为DI和BX
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
       	PUSH BX             ;BX节拍时间数据
        	PUSH CX
       	PUSH DX
        	PUSH DI         ;入口参数DI给定频率数据
        	MOV AL,10110110B;8253初始化(通道2，方式3，产生方波信号)
        	OUT 43H,AL      ;43H端口是8253的命令寄存器

        	MOV DX,12H      ;计算时间常数
        	MOV AX,34DCH
        	DIV DI

        	OUT 42H,AL      ;给8253通道2设置计数初值
        	MOV AL,AH
        	OUT 42H,AL

        	IN AL,61H  		;读8255B口
        	MOV AH,AL
        	OR AL,3       	;8255 PB1PB0置1，开喇叭
        	OUT 61H,AL
DELAY:
  	MOV CX,15000     
DL10ms:  
	LOOP  DL10ms        	;延时10ms
	DEC BX			        ;BX—节拍时间对应10ms的倍数，如:BX=100,节拍时间=10ms*100=1s
        	JNZ DELAY
        	MOV AL,AH
        	OUT 61H,AL      ;8255 PB1PB0恢复为零，关喇叭
        	POP DI
        	POP DX
        	POP CX
        	POP BX
       	POP AX
        	RET
SOUND   ENDP

CODE ENDS
	END START 
