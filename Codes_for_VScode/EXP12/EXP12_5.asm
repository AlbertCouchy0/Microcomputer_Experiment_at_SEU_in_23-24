DATA    SEGMENT                                   ;定义数据段
SHOW DB  0AH,0DH, 'ONE LAST KISS:$'               ;0AH,0DH为换行，回车
FREQ 	DW  002,392,440,440,440,001,440,330,294,001,330,294,294,294,001,001,002
        DW  392,440,440,440,001,440,330,330,294,001,330,294,001,001,262,001,002
        DW  382,440,440,440,001,440,330,330,294,001,330,294,001,002,262,001
        DW  440,440,440,001,440,330,294,001,330,294,001,001,294,001,002
        DW  392,440,440,440,001,440,330,330,294,001,330,294,001,002,262,262,001
        DW  392,440,440,440,001,440,001,330,294,001,330,294,001,001,262,001,002
        DW  392,440,440,440,001,440,330,330,294,001,330,294,001,001,001
        DW  330,294,262,262,001,001,002
        ;副歌
        DW  392,440,440,001,392,440,001
        DW  588,660,392,440,392,392,440,440,440
        DW  440,440,001,002,440,660,001
        DW  588,524,524,660,588,524,524,588,588
        DW  588,440,001,001,002,392,440,392
        DW  588,660,392,440,392,392,440,440,440
        DW  440,440,001,002,440,660,001
        DW  588,524,524,623,588,524,524,588,001,002
        ;oh,oh,oh
        DW  440,001,440,001,440,001,440,001,524,588,001
        DW  440,001,440,001,440,001,660,588,524,001
        DW  440,001,440,001,440,001,440,001,002,440,660,001
        DW  588,524,524,588,660,588,524,524,588,001,002
        DW  440,001,440,001,440,001,440,001,524,588,001
        DW  440,001,440,001,440,440,001,440,001,001
        DW  440,001,440,001,440,001,660,001,002,440,660,001
        DW  588,524,524,588,660,588,524,524,588,440,001,002,000
        ;查表可得频率,001为休止符

TIME	DW  002,025,025,025,025,005,025,050,025,005,025,075,005,025,025,005,002          
        DW  025,025,025,025,005,025,025,025,025,005,025,025,050,005,100,005,002                     
        DW  025,025,025,025,005,025,025,025,025,005,025,075,050,002,050,005
        DW  050,025,025,005,025,050,025,005,025,025,050,005,100,005,002
        DW  025,025,025,025,005,025,025,025,025,005,050,050,050,002,025,025,005
        DW  025,025,025,025,005,025,025,025,025,005,025,025,050,005,100,005,002
        DW  025,025,025,025,005,025,025,025,025,005,050,050,005,100,005
        DW  050,100,050,100,100,005,002
        ;副歌
        DW  050,150,050,050,050,050,005
        DW  050,050,050,050,050,050,050,050,005
        DW  100,100,100,002,050,050,005
        DW  050,050,050,050,050,050,025,075,005
        DW  050,050,100,100,002,050,050,005
        DW  050,050,050,050,050,050,050,050,005
        DW  100,100,100,002,050,050,005
        DW  050,050,050,050,050,050,025,075,005,002
        ;oh,oh,oh
        DW  050,025,025,050,050,025,025,050,050,050,005
        DW  050,025,025,050,050,025,075,050,050,005
        DW  050,025,025,050,050,025,025,050,002,050,050,005
        DW  050,050,050,025,025,050,050,025,075,005,002
        DW  050,025,025,050,050,025,025,050,050,050,005
        DW  050,025,025,050,050,050,050,050,050,005
        DW  050,025,025,050,050,025,025,050,002,050,050,005
        DW  050,050,050,025,025,050,050,025,075,100,100,002,000
        ;全音符100，二分音符50，四分音符25

LINE1    DB  0AH,0DH,'The first time I went to the Louvre'
SLEN1 EQU $-LINE1;
LINE2    DB  0AH,0DH,'It does not feel like anything special'
SLEN2 EQU $-LINE2;
LINE3    DB  0AH,0DH,'Because I had already met'
SLEN3 EQU $-LINE3;
LINE4    DB  0AH,0DH,'My own Mona Lisa'
SLEN4 EQU $-LINE4;
LINE5    DB  0AH,0DH,'The day I first met you'
SLEN5 EQU $-LINE5;
LINE6    DB  0AH,0DH,'The gear start revolving'
SLEN6 EQU $-LINE6;
LINE7    DB  0AH,0DH,'Can not stop the feeling of what you are about to lose'
SLEN7 EQU $-LINE7;
LINE8    DB  0AH,0DH,'I mean, it has been a lot of times'
SLEN8 EQU $-LINE8;
LINE9    DB  0AH,0DH,'Let us have another kiss'
SLEN9 EQU $-LINE9;
LINE10   DB  0AH,0DH,'Can you give me one last kiss?'
SLEN10 EQU $-LINE10;
LINE11   DB  0AH,0DH,'Things I do not want to forget'
SLEN11 EQU $-LINE11;
LINE12   DB  0AH,0DH,'Oh oh oh oh oh--'
SLEN12 EQU $-LINE12;
LINE13   DB  0AH,0DH,'Things I do not want to forget'
SLEN13 EQU $-LINE13;
LINE14   DB  0AH,0DH,'Oh oh oh oh oh--'     
SLEN14 EQU $-LINE14;
LINE15   DB  0AH,0DH,'I love you more than you will ever know'  
SLEN15 EQU $-LINE15;
LINE16   DB  0AH,0DH,'ONE LAST KISS END'  
SLEN16 EQU $-LINE16;
;0AH,0DH为换行，回车
Count DB 0;
DATA    ENDS


STACK   SEGMENT PARA STACK 'STACK'  ;定义堆栈段
        DW  400 DUP(?)
STACK   ENDS

CODE    SEGMENT
	ASSUME  CS:CODE, DS:DATA,SS:STACK

START:
;初始化数据段和堆栈段
	MOV AX,DATA
	MOV DS,AX
        MOV ES,AX		                
	MOV AX,STACK		
	MOV SS,AX		                
;显示提示信息
	MOV DX,OFFSET SHOW
	MOV AH,09
	INT 21H 			            
;地址传给寄存器
	MOV SI,OFFSET FREQ	        ;将"频率"数据地址给     SI
	MOV BP,OFFSET TIME	        ;将"节拍"时间数据地址给 BP
;调用SING主程序
	CALL SING
;程序结束，返回DOS
	MOV AH,4CH
	INT 21H		
;——————————————————SING子程序——————————————————    	                
SING PROC NEAR 
;保存寄存器状态 
    PUSH DI
    PUSH SI
    PUSH BP
    PUSH BX
RETP:  	
    MOV DI,DS:[SI]		        ;取频率给DI
    CMP DI,0        		        ;0意味着程序结束
    JE END_SING		
    MOV BX,DS:[BP]		        ;取节拍给BX
    CALL SOUND         		        ;参数为DI和BX
    ADD SI,2
    ADD BP,2
    JMP RETP
;恢复寄存器状态并返回   
END_SING:
    POP  BX
    POP  BP
    POP  SI
    POP  DI
    RET
SING ENDP
;——————————————————SOUND子程序——————————————————
;根据频率信息控制扬声器发声
SOUND PROC  NEAR
;保存寄存器状态
    PUSH AX
    PUSH BX          		        ;BX节拍时间数据
    PUSH CX
    PUSH DX
    PUSH DI           		        ;DI给定频率数据
;歌词显示的实现
    CMP DI,2                            ;判断是否为休止符（只延时，不发声）
    JNE SOUND_NEXT
    CALL DRAW;参数无，直接画即可
SOUND_NEXT:
;设置8253计数器 
    MOV AL,10110110B     	        ;8253初始化(通道2，方式3，产生方波信号)
    OUT 43H,AL      		        ;43H端口是8253的命令寄存器
;休止符的实现
    CMP DI,1                            ;判断是否为休止符（只延时，不发声）
    JE  DELAY
    CMP DI,2                            ;判断是否为休止符（只延时，不发声）
    JE  DELAY
;计算并设置计数初值
    MOV DX,12H      		        ;计算折算频率（时间常数）
    MOV AX,34DCH                        ;1234CDH除以给定频率
    DIV DI
    OUT 42H,AL      		        ;给8253通道2设置计数初值（先写低字节，再写高字节）
    MOV AL,AH
    OUT 42H,AL
;打开扬声器
    IN  AL,61H  		         ;读8255B口
    MOV AH,AL
    OR  AL,3       	 	         ;8255——PB1PB0置1，开喇叭
    OUT 61H,AL
;延时循环（调用了BX的信息）
DELAY:
    MOV CX,15000     
DL10ms:  
    LOOP  DL10ms        	        ;延时10ms
    DEC BX			        ;BX—节拍时间对应10ms的倍数，如:BX=100,节拍时间=10ms*100=1s
    JNZ DELAY
;关闭扬声器
    MOV AL,AH
    OUT 61H,AL       		        ;8255——PB1PB0恢复为零，关喇叭
;恢复寄存器状态并返回
    POP DI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
SOUND   ENDP
;——————————————————DRAW子程序——————————————————
;显示歌词
DRAW PROC  NEAR
;保存寄存器状态
    PUSH AX
    PUSH BX          		        ;BX取地址
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH BP                             ;DI给定频率数据
    PUSH DI                            ;DI给定频率数据
;计数器加1
   LEA SI, Count      
   MOV AL, DS:[SI]    
   INC AL             
   MOV DS:[SI], AL    
;清屏
    MOV AH,06H				; 调用功能号06H
    MOV AL,0
    MOV CH,0
    MOV CL,0
    MOV DH,24
    MOV DL,79
    MOV BH,01111000B		; 设置白底黑字不闪烁
    INT 10H
;输出
    MOV AH,13H			; 调用功能号13H
    MOV	DH,05H
    MOV DL,08H
    MOV AL,01H
    MOV BL,01111000B		; 设置黑底白字不闪烁
    MOV BH,00H
SHOW1:
    CMP BYTE PTR[SI],1;
    JNE SHOW2
    LEA BP,LINE1
    MOV CX,SLEN1
    JMP SHOW_END
SHOW2:
    CMP BYTE PTR[SI],2;
    JNE SHOW3
    LEA BP,LINE2
    MOV CX,SLEN2
    JMP SHOW_END
SHOW3:
    CMP BYTE PTR[SI],3;
    JNE SHOW4
    LEA BP,LINE3
    MOV CX,SLEN3
    JMP SHOW_END
SHOW4:
    CMP BYTE PTR[SI],4;
    JNE SHOW5
    LEA BP,LINE4
    MOV CX,SLEN4
    JMP SHOW_END
SHOW5:
    CMP BYTE PTR[SI],5;
    JNE SHOW6
    LEA BP,LINE5
    MOV CX,SLEN5
    JMP SHOW_END
SHOW6:
    CMP BYTE PTR[SI],6;
    JNE SHOW7
    LEA BP,LINE6
    MOV CX,SLEN6
    JMP SHOW_END
SHOW7:
    CMP BYTE PTR[SI],7;
    JNE SHOW8
    LEA BP,LINE7
    MOV CX,SLEN7
    JMP SHOW_END
SHOW8:
    CMP BYTE PTR[SI],8;
    JNE SHOW9
    LEA BP,LINE8
    MOV CX,SLEN8
    JMP SHOW_END
SHOW9:
    CMP BYTE PTR[SI],9;
    JNE SHOW10
    LEA BP,LINE9
    MOV CX,SLEN9
    JMP SHOW_END
SHOW10:
    CMP BYTE PTR[SI],10;
    JNE SHOW11
    LEA BP,LINE10
    MOV CX,SLEN10
    JMP SHOW_END
SHOW11:
    CMP BYTE PTR[SI],11;
    JNE SHOW12
    LEA BP,LINE11
    MOV CX,SLEN11
    JMP SHOW_END
SHOW12:
    CMP BYTE PTR[SI],12;
    JNE SHOW13
    LEA BP,LINE12
    MOV CX,SLEN12
    JMP SHOW_END
SHOW13:
    CMP BYTE PTR[SI],13;
    JNE SHOW14
    LEA BP,LINE13
    MOV CX,SLEN13
    JMP SHOW_END
SHOW14:
    CMP BYTE PTR[SI],14;
    JNE SHOW15
    LEA BP,LINE14
    MOV CX,SLEN14
    JMP SHOW_END
SHOW15:
    CMP BYTE PTR[SI],14;
    JNE SHOW16
    LEA BP,LINE15
    MOV CX,SLEN15
    JMP SHOW_END
SHOW16:
    CMP BYTE PTR[SI],15;
    JNE SHOW_END
    LEA BP,LINE16
    MOV CX,SLEN16
SHOW_END:
    INT	10H
;恢复寄存器状态并返回
    POP DI
    POP BP
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
DRAW   ENDP

CODE ENDS
END START 
