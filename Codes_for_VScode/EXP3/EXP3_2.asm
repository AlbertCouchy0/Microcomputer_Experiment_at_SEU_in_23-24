DATA SEGMENT                    ;定义数据段,DATA为段名
NUM  DW 22D,46D,32D,72D,84D,16D,156D    ;初始化内存，用十进制表达
MAXN2 DW ?                              ;设置MAXN2用于存放结果
DATA ENDS                       ;定义数据段结束

CODE SEGMENT PARA                   ;定义代码段
ASSUME CS:CODE,DS:DATA              ;ASSUME伪指令定义各段寄存器的内容
START:  MOV AX,DATA                 ;NUM的偏移地址赋给SI
        MOV DS,AX                   ;DS初始化为数据段首地址的段值DATA

        MOV CX,07                   ;CX定义为数据段长度
        LEA SI,NUM                  ;NUM的偏移地址赋给SI
        MOV AX,0000                 ;AX清零                
        MOV AX, [SI]	                    
AGAIN:  MOV BL,[SI]                 ;比较的第一步，数据移到BL上
        CMP AX,BX                   ;比较AX和BX
        JGE NEXT                    ;如果AL大于BL则跳转到NEXT
        MOV AX,BX                   ;如果相反，将BX的内容给AX 
NEXT:   INC SI                      ;SI指向下一个空间
        INC SI                      ;由于每单位为字，故需要操作两次
        LOOP AGAIN                  ;loop循环，准备比较下一个数
        MOV MAXN2,AX                ;循环完成后，把最大值给MAXN2
        
        MOV  AH,4CH                 ;功能号4CH
        INT 21H                     ;类型号21H，利用中断向量返回DOS
CODE ENDS                           ;代码段结束
END START                           ;整个程序汇编结束
