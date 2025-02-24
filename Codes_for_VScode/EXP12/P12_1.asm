DATA    SEGMENT                                         ;定义数据段
SHOWM 	DB  0AH,0DH, 'Please play the virtual piano.$'  
SHOW1 	DB  0AH,0DH, 'Low_pitch   :Q,W,E,R,T,Y,U.$'  
SHOW2 	DB  0AH,0DH, 'Middle_pitch:A,S,D,F,G,H,J.$'  
SHOW3 	DB  0AH,0DH, 'High_pitch  :Z,X,C,V,B,N,M.$'  	;0AH,0DH为换行，回车
SHOWN	DB  0AH,0DH,'Please press key O to end the piano.$'
FREQ 	DW  131,147,165,175,196,220,247	                ;查表可得频率
        DW  262,294,330,349,392,440,494
        DW  524,588,660,698,784,880,988
ISPLAY 	DB 1
ISBREAK	DB 0
DATA    ENDS
STACK   SEGMENT PARA STACK 'STACK'                      ;定义堆栈段
        DW  200 DUP(?)
STACK   ENDS

CODE    SEGMENT
	ASSUME  CS:CODE, DS:DATA,SS:STACK

START:
	MOV AX,DATA
	MOV DS,AX
	MOV AX,STACK
	MOV SS,AX

	MOV DX,OFFSET SHOWM
	MOV AH,09H			    ;显示文字
	INT 21H
	MOV DX,OFFSET SHOW1		;显示文字
	INT 21H
	MOV DX,OFFSET SHOW2		;显示文字
	INT 21H
	MOV DX,OFFSET SHOW3		;显示文字
	INT 21H
	MOV DX,OFFSET SHOWN		;显示文字
	INT 21H
    
	MOV  AL,9               ; 指定要读取的中断向量号，这里是9号中断，即键盘中断。
	MOV  AH,35H		        ; 35H 功能号，读取中断向量
	INT  21H
	MOV  AX,BX              ; 保存原来的中断向量偏移地址
	PUSH AX
	MOV  AX,ES              ; 保存原来的中断向量段地址
	PUSH AX
	CLI
	MOV DX,OFFSET KEYINT    ; 将新的键盘中断处理程序的偏移地址加载到DX寄存器
    MOV AX,SEG KEYINT       ; 将新的键盘中断处理程序的段地址加载到AX寄存器
    MOV BX,DS               ; 保存当前数据段地址
    MOV DS,AX               ; 设置数据段为新的键盘中断处理程序段地址
    MOV AL,9
    MOV AH,25H              ; 25H 功能号，设置中断向量
    INT 21H
    MOV DS,BX               ; 恢复原来的数据段地址
    STI

	LEA	BX,FREQ
AGAIN:	
	CMP ISBREAK,0
	JE	AGAIN               ; 检查是否退出(若如果ISBREAK为0，跳转回AGAIN，继续循环)
	CLI

	POP 	AX              ; 从堆栈中弹出先前保存的原中断向量偏移地址。
	MOV 	BX,DS
	MOV 	DS,AX
	POP 	AX              ; 从堆栈中弹出先前保存的原中断向量段地址。
	MOV 	DX,AX
	MOV 	AL,9
	MOV 	AH,25H		
	INT 	21H             ; 调用DOS中断，设置9号中断向量为原中断处理程序的地址。
	MOV 	DS,BX
	STI

	MOV 	AH,4CH		    ; 结束程序返回DOS
	INT 	21H

;——————————————————KEYINT子程序——————————————————
;根据按键产生对应的音调，并控制扬声器的发声
KEYINT PROC			
;开启中断和保存寄存器状态
	STI			            ;开中断
	PUSH 	AX		        ;保护入栈
	PUSH 	BX
	PUSH	SI
;读取按键扫描码
	IN 	AL,60H
;检测是否为按键释放
	CMP	AL,80H		        ;如果是释放按键，高位为1，不发声
	JAE	GO
;检测是否按下结束键（18H）
	CMP AL,18H		        ;如果按到字母O，电子琴程序结束
	JE 	BREAK
;判断按键是否在有效范围内并处理音调
;;低音区（10H~16H）
	CMP  AL,10H		        ;判断是否按在可以发声的按键
	JB 	 GO			        ;低于10H则不在有效范围内
	CMP  AL,17H
	JAE  JUDGE1		        ;高于或等于17H则在中音区
	MOV  AH,0               ;清空AH，准备计算频率表的索引。
	SUB  AL,10H             ;将扫描码减去10H，计算出在低音区的索引。
	ADD  AL,AL              ;索引乘以2，得到频率表的实际索引(由于频率表占用1字，扫描码占用1字节)。
	MOV  SI,AX              ;将索引存入SI
	MOV  ISPLAY,1		    ;设置发声标志位。
	CALL SOUND              ;调用SOUND子程序发声。
	JMP  GO2                ;跳转到GO2，进行中断结束处理。
;;中音区（1EH~24H）
JUDGE1:
	CMP  AL,1EH		        ;判断是否在中音区
	JB 	 GO		            ;低于1EH则不在有效范围内
	CMP  AL,25H		
	JAE  JUDGE2		        ;高于或等于25H则在高音区
	MOV  AH,0
	SUB  AL,17H		
	ADD  AL,AL		
	MOV  SI,AX		
	MOV	 ISPLAY,1
	CALL SOUND
	JMP  GO2                ;其他处理类似低音区
;;高音区（2CH~33H）
JUDGE2:
	CMP  AL,2CH		        ;判断是否在高音区
	JB 	 GO		            ;低于2CH则不在有效范围内
	CMP  AL,33H		
	JAE  GO                 ;高于或等于33H则同样不在范围内
	MOV  AH,0
	SUB  AL,1EH
	ADD  AL,AL		
	MOV  SI,AX		
	MOV  ISPLAY,1
	CALL SOUND
	JMP  GO2                ;其他处理类似低音区
;设置结束标志位 
BREAK:
	MOV 	ISBREAK,1
	JMP 	GO2             ;设置结束标志位，通知主程序结束。
;处理未在有效范围内的按键
GO:	
	MOV	ISPLAY,0
	CALL	SOUND
;结束处理
GO2:	
	IN	AL,61H
	OR	AL,80H		        ;将PB7置为1
	OUT	61H,AL
	AND AL,7FH		        ;将PB7清0
	OUT	61H,AL
	MOV AL,20H
	OUT 20H,AL		        ;中断结束，复位

	POP SI
	POP	BX
	POP AX	
	IRET
KEYINT	ENDP
;——————————————————SOUND子程序——————————————————
;根据键盘中断处理程序传递的频率信息控制扬声器发声
SOUND	PROC NEAR
;保存寄存器状态
	PUSH	AX
	PUSH	BX
	PUSH	DX
	PUSH	DI		        ;入口参数DI给定频率数据
;加载频率值
	MOV	DI,[BX+SI]          ;BX存放频率表的基址，SI存放索引值
;设置8253计数器 
	MOV	AL,0B6H		        ;8253初始化（控制字：通道2，方式3，产生方波信号）
	OUT	43H,AL		        ;43H端口是8253的命令寄存器
;计算并设置计数初值
	MOV	DX,12H		        
	MOV AX,34DCH            ;用于计算频率的时间常数
	DIV DI                  ;计算公式：1234DCH÷(给定频率)，得到计数初值
	OUT	42H,AL		        ;给8253通道2设置计数初值，先写低八位
	MOV	AL,AH
	OUT	42H,AL              ;后写高八位
;控制扬声器
	AND	AL,0FCH		        ;8255PB1PB0置0，关喇叭
	OUT	61H,AL
;检查是否需要发声
	CMP	ISPLAY,0
	JE	NOO
;开启扬声器
	OR	AL,3
	OUT	61H,AL
;恢复寄存器状态并返回
NOO:	
    POP	DI
	POP	DX
	POP	BX
	POP	AX
	RET
SOUND	ENDP
CODE	ENDS
	END START

