DATA SEGMENT                    ;定义数据段,DATA为段名
DATA ENDS                       ;定义数据段结束

MAIN SEGMENT PARA                  ;定义代码段
ASSUME CS:MAIN,DS:DATA          ;ASSUME伪指令定义各段寄存器的内容
START: 
    SUB BX,BX ;
    MOV AX,0FFFH ;
    MOV SI,0AH ;
    MOV CX,0404H ;
A:  SUB DX,DX ;
    DIV SI ;
    OR BX,DX ;
    ROR BX,CL ;
    DEC CH ;
    JNZ A ;
    HLT ;
MAIN ENDS                       ;代码段结束
END START                       ;整个程序汇编结束
