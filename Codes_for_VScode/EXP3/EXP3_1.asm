DATA SEGMENT                    ;定义数据段,DATA为段名
        NUM  DB 22D,46D,32D,72D,84D,16D,156D    ;初始化内存，这用十进制表达
        MAXN1 DB ?                              ;设置MAXN用于存放结果
DATA ENDS                       ;定义数据段结束

MAIN SEGMENT PARA                  ;定义代码段
ASSUME CS:MAIN,DS:DATA          ;ASSUME伪指令定义各段寄存器的内容
START:  MOV AX,DATA                
        MOV DS,AX               ;DS初始化为数据段首地址的段值DATA
        MOV CX,07               ;CX定义为数据段长度
        LEA SI,NUM              ;NUM的偏移地址赋给SI
        MOV AL,[SI]             ;将数据段的第一个数据放到AL里
AGAIN:  MOV BL,[SI]             ; 比较的第一步，数据移到BL上
        CMP AL,BL               ;比较AL和BL
        JAE NEXT                ;如果AL大于BL则跳转到NEXT
        MOV AL,BL               ;如果相反，将BL的内容给AL 
NEXT:   INC SI                  ;SI指向下一个空间
        LOOP AGAIN              ; loop循环，准备比较下一个数
        MOV MAXN1,AL            ; 循环完成后，把最大值给MAXN
        
        MOV  AH,4CH             ;利用中断向量返回DOS
        INT 21H    
MAIN ENDS                       ;代码段结束
END START                       ;整个程序汇编结束
