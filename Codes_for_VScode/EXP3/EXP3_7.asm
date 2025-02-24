DATA SEGMENT   
    STR1 DB 'HelloWorld$' ; 第一个字符串
    STR2 DB 'HelloSEUer$' ; 第二个字符串
    RESULT1 DW ?          ; 用于存放比较结果的单元（地址或0）
    RESULT2 DB ?          ; 用于存放不同字节内容的单元
DATA ENDS

CODE SEGMENT                 ; 定义代码段
ASSUME CS:CODE,DS:DATA       ; ASSUME伪指令定义各段寄存器的内容
START:  MOV AX, DATA;
        MOV DS, AX           ; 给DS附上初值
    
        MOV SI, OFFSET STR1  ; 将字符串1的偏移地址加载到SI
        MOV DI, OFFSET STR2  ; 将字符串2的偏移地址加载到DI
        MOV CX, 10           ; 循环次数，字符串长度为10

COMPARE_LOOP:
        MOV AL, [SI]         ; 将SI指向的字符串1中的字符加载到AL
        CMP AL, [DI]         ; 将DI指向的字符串2中的字符与AL比较
        JNE NOT_EQUAL        ; 如果不相等，跳转到不相等处理部分
        INC SI               ; 指向下一个字符
        INC DI               ; 指向下一个字符
        LOOP COMPARE_LOOP    ; 继续比较直到循环结束
    
        ; 如果执行到这里，说明字符串完全相同
        MOV RESULT1, 0       ; 将结果设置为0
        JMP END_CODE         ; 跳转，结束程序

NOT_EQUAL:
        MOV RESULT1, SI      ; 将SI中的地址存入RESULT1，表示第一个不相等字节的地址
        MOV AL, [SI]         ; 将第一个不相等的字符加载到AL
        MOV RESULT2, AL      ; 将该字符存入RESULT2

END_CODE:
        MOV  AH,4CH         ;功能号4CH
        INT 21H             ;类型号21H，利用中断向量返回DOS
CODE ENDS                   ;代码段结束
END START                   ;整个程序汇编结束
