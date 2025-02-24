STACK   SEGMENT         ;堆栈段定义
        STK  DW 200H DUP(?)
STACK   ENDS            

DATA    SEGMENT
        KEY     DB 0                                ;存储按下键盘的次数，初值为0
;2）改变按键后屏幕显示的字符串内容和返回DOS之前的按键次数.
        MSG     DB ?,?,"-KUAI DIAN FANG JIA(QAQ)"   ;存储按下键盘后的提示信息
        SLENGTH EQU $-MSG                           ;提示字符长度
        COUNT   EQU 12                              ;最大按键次数
        LINE    DB 20                               ;最大显示行数
        INLINE 	DB  3;
	            DB  ?;
                DB 3  DUP(?);                       ;缓冲区
        TXT1    DB "Please input the number of line(<25):$"  ;文本提示1
        ERROR1  DB 0DH,0AH,'Wrong Input Format!',0AH,'$'     ;错误提示1
        ERROR2  DB 0DH,0AH,'The Input is too big!',0AH,'$'   ;错误提示2            
DATA    ENDS

CODE    SEGMENT
        ASSUME CS:CODE, SS:STACK, DS:DATA
START: 
        MOV AX, STACK
        MOV SS, AX
        MOV AX, DATA
        MOV DS, AX
        ;输出TXT1文本
        LEA SI,TXT1         ;取TXT1地址
        MOV DX,SI           ;赋值地址给DX
        MOV AH,09	    ;功能号09H
        INT 21H    	    ;类型号21H，显示DS：DX指向的以$结尾的字符串
        ;键盘输入行数到缓冲区
        LEA SI,INLINE;
        MOV DX,SI           ;赋值地址给DX
        MOV  AH, 0AH	
	    INT  21H            ;输入

	    MOV  BX, OFFSET  INLINE+2   ;BX取到数组的首地址 
        CALL  INPUTerror    ;判断输入格式是否错误
RIG:	
        CALL  ASCtoNUM      ;把缓存区ASC码的转换成NUM码
	    CALL  VALUEerror    ;判断时间符合实际
NEXT1:  ;保存原09H中断内容    
;1）通过DOS系统功能调用的25H功能实现中断向量的设置和读取.
        MOV AH,35H
	    MOV AL,09H		    ;使用DOS系统功能获取中断向量
	    INT 21H
	    PUSH BX
	    PUSH ES
	    CLI		            ;关中断，设置中断向量

	    PUSH DS         
	    MOV AX,SEG KEYINTS
	    MOV DS,AX
	    MOV DX,OFFSET KEYINTS
	    MOV AH,25H
	    MOV AL,09H              ;位置是09H
	    INT 21H
	    POP DS          
	    STI		            ;开中断
AGAIN:  
        CALL FAR PTR SHOW1  ;显示一轮太阳图形
        CMP KEY, COUNT      ;判断按键是否按下COUNT次
        JB  AGAIN           ;键盘未按下十次，则继续下一轮显示太阳图形
        ;若按下了十次，进行处理
        CLI                 ;屏蔽外部中断，准备将原有中断向量恢复到中断向量表中
        POP DS		
	    POP DX
	    MOV AH,25H
	    MOV AL,09H
	    INT 21H
        STI                 ;打开外部中断
        ;返回DOS
        MOV AH, 4CH
        INT 21H         
;________________________________________________________________
;判断输入格式是否合规的子程序
INPUTerror  PROC
    MOV  BX, OFFSET  INLINE+2;BX取到数组的首地址 
	MOV  CL, 00H            ;开始CL置零

	MOV AL, [BX]            ;提取BX对应的值
	CALL  NUMerror          ;判断是否是数字
	INC  BX                 ;判断下一字节

    MOV AL, [BX]            ;提取BX对应的值
	CALL  NUMerror          ;判断是否是数字

	CMP CL, 00H             ;CL=0说明格式正确
	JE  RIG                 ;正确跳转
error:	
    MOV  DX, OFFSET  ERROR1
	MOV  AH, 9
	INT  21H                ;在屏幕显示ERROR1	
        	 
	JMP  START              ;跳回开头
	RET
INPUTerror  ENDP
;判断数字错误的子程序
NUMerror PROC
	CMP AL, 39H		        ;判断是否大于‘9’
	JA  ERR1
	CMP  AL, 30H	        ;判断是否小于‘0’
	JB  ERR1                
	RET
ERR1:	
    MOV CL, 01H             ;其ASC码若不在数字范围，CL置1	
	RET
NUMerror ENDP

;ASC变压缩NUM的子程序
ASCtoNUM  PROC
    PUSH SI
	MOV  BX, OFFSET  INLINE+2   ;指针指向数据区
    MOV  SI,OFFSET LINE
	SUB  CX,CX
    ;转换个位
	MOV  CL, [BX+1]
	SUB  CL, 30H 
    ;转换十位
    MOV  AL, [BX]
    SUB  AL,30H
    MOV  DL,10
    MUL  DL                 
    ADD  AX,CX              ;整合相加
    MOV  [SI], AL           ;储存,不考虑输入行数高于255的可能
    SUB  CX,CX
    MOV  CL, [SI]           ;行数传递给CL
    POP SI
	RET
ASCtoNUM ENDP

;判断时间符合实际的子程序
VALUEerror  PROC
	CMP  CL, 25D            ;将行数和25比较
	JA   DO                 ;>25则跳转
	JMP  NEXT1
DO:	MOV  DX, OFFSET  ERROR2
	MOV  AH, 9
	INT  21H                ;在屏幕显示ERROR2		 
	JMP  START              ;跳回开头
	RET	
VALUEerror ENDP
;________________________________________________________________
;键盘中断子程序
KEYINTS  PROC FAR
        PUSH AX
        PUSH SI
        STI                 ;在子程序内打开外部中断
        IN  AL, 60H         ;通过8255A的PA口(PA口地址为60H)读取键盘扫描码
        MOV AH, AL          ;从8255A的PA口读入键盘扫描码，将其存入AH
        IN  AL, 61H         ;读入PB口的当前值
        ;完成在PB（7）口的一次正脉冲输出，以通知键盘控制器已经处理了中断。
        OR  AL, 80H         ;PB（7）置1
        OUT 61H, AL
        AND AL, 7FH         ;PB（7）置0，
        OUT 61H, AL

        TEST AH, 80H        ;检测键盘扫描码的最高位是否为1,【弹起码-按下码=80H】
        JNZ GO              ;若最高位为1，说明此时键盘释放，跳转到子程序出口处
        STI
        INC KEY             ;若最高位为0，说明此时键盘按下，给计数器加一
        CALL FAR PTR SHOW2  ;并显示提示信息
GO:
        MOV AL, 20H
        OUT 20H, AL         ;给8259A的OCW1发出表示中断结束的EOI命令
        POP SI
        POP AX
        IRET
KEYINTS  ENDP

;延时1s子程序
DELAYS	PROC	
        ;压栈
	    PUSH DX
	    PUSH CX
            PUSH BX
	    PUSH AX
        ;中断调用延时
	    MOV AH, 2CH
	    INT 21H	            ;DOS调用系统时间
	    MOV BH, DH	        ;存储当前秒数
BEGIN:
	    INT 21H	            ;调用系统时间
	    CMP BH, DH	        ;比较当前时间与上次调用的时间是否变化
	    JNE NEXT	        ;若有变化，则完成延时，退出程序
	    JMP BEGIN	        ;若无变化，则继续调用系统时间
NEXT:
        ;弹出
	    POP AX
        POP BX
	    POP CX
	    POP DX
	    RET
DELAYS	ENDP

;显示太阳图形的子程序
SHOW1   PROC FAR   
        ;压栈 
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        ;每轮显示太阳        
        MOV AH, 15  
        INT 10H             ;读取当前显示状态
        MOV AH, 0
        INT 10H             ;设置显示方式
        MOV CX, 1           ;要显示的字符数
        MOV DX, 0           ;设置光标起始位置为行号为0，列号为0
REPEAT:
;4）按键次数达到后(比如9次)，不等25行太阳图标显示完，立即返回DOS；
        CMP KEY, COUNT 
        JAE EXIT            ;若KEY达到COUNT，转至EXIT
        ;KEY小于COUNT的情况
        MOV AH, 2    
        INT 10H             ;设置光标位置
        MOV AL, 0FH         ;太阳图形的ASCII码
        MOV CX, 1           ;要显示的字符数
        MOV AH, 10   
        INT 10H             ;显示单个太阳图形
        CALL DELAYS         ;延时一秒
        MOV AL, 03          ;设置显示方式(80*25彩色文本)
        MOV AH, 0       
        INT 10H             ;清屏
        INC DH              ;行号+1
        ADD DL, 2           ;列号+2
        
        SUB BX,BX
        MOV SI, OFFSET  LINE;BX取到数组的首地址 
        CMP DH, [SI]    
        JB REPEAT           ;如果没到LINE行，则跳转到REPEAT更新光标位置；到了LINE行则退出子程序
EXIT:
        ;弹出
        POP DX
        POP CX
        POP BX
        POP AX
        RET
SHOW1   ENDP

;显示提示信息的子程序
SHOW2   PROC FAR    
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
        INC DL              
        MOV AH, 2
        INT 10H             ;将光标设在下一个位置（相当于加空格），避免覆盖原字符
        LEA SI, MSG         ;将字符串MSG的首地址装入SI
        MOV BYTE PTR[SI],30H
        MOV BL,KEY          ;将KEY值给BL
;3）在按键后显示的字符串前面加上按键次数，在字符串后面加个空格
        CMP KEY,10
	JB  LESSthan
MOREthan:  
        MOV BYTE PTR[SI],31H
        SUB BL,10
LESSthan:    
        MOV AL,BL
	OR  AL,30H
	MOV BYTE PTR[SI+1],AL    
        MOV CX, SLENGTH     ;将字符串MSG的长度装入CX
NEXTC:
;5）修改显示字符的属性
	MOV BL,01111000B       ;白底黑字
	MOV AH,09H
	INT 10H
        ;循环显示提示信息的字符
        LODSB               ;从内存中的SI指向的位置读取一个字节，并将其存入AL寄存器，同时SI寄存器递增。
        MOV AH, 0EH         ;设置 AH 寄存器为 0EH，表示显示字符和属性。 
        MOV BX, 1
        INT 10H
        LOOP NEXTC
        ;弹出 
        POP AX
        POP BX
        POP CX
        POP DX
        POP SI
        RET
SHOW2   ENDP

CODE    ENDS
        END START
