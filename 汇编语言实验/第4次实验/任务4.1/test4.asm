.386
CODE SEGMENT USE16
   ASSUME CS:CODE,DS:CODE,SS:STACK
;新的INT 08H使用变量
  COUNT DB 18  ;计数器
  HOUR DB ?,?,':'  ;时的ASCII码
  MIN DB ?,?,':'  ;分的ASCII码
  SEC DB ?,?  ;秒的ASCII码
  BUF_LEN = $-HOUR  ;计算显示信息长度
  CURSOR DW ?       ;原光标位置
  OLD_INT DW ?,?    ;原INT 08H的中断矢量
  flag DW '#'

;新的INT 08H代码
NEW08H PROC FAR
   PUSHF     ;用来将标志寄存器入栈
   CALL DWORD PTR CS:OLD_INT   ;完成原功能，变量在汇编后使用的默认寄存器为DS，故需加段前缀CS
   DEC CS:COUNT
   JZ DISP    ;记满18次显示时钟
   IRET
DISP:
  MOV CS:COUNT,18   ;重置计数器
  STI   ;开中断
  PUSHA    ;寄存器的入栈顺序依次是：AX,CX,DX,BX,SP(初始值)，BP,SI,DI
  PUSH DS
  PUSH ES
  MOV AX,CS
  MOV DS,AX
  MOV ES,AX
  CALL GET_TIME
  MOV BH,0 ;获取0号显示页面当前光标位置
  MOV AH,3
  INT 10H  ;*****************读取原光标
  MOV CURSOR,DX   ;INT 10H的光标位置存在DX里，保存原光标位置
  MOV BP,OFFSET HOUR
  MOV BH,0
  MOV DH,0
  MOV DL,80-BUF_LEN
  MOV BL,07H    ;显示操作，BH表示页码号，BL表示白色，DH行，DL列
  MOV CX,BUF_LEN
  MOV AL,0
  MOV AH,13H
  INT 10H  ;***************显示
  MOV BH,0
  MOV DX,CURSOR
  MOV AH,2
  INT 10H  ;*************还原光标位置
  POP ES
  POP DS
  POPA
  IRET
NEW08H ENDP


;取时间子程序
GET_TIME PROC
    MOV AL,4
    OUT 70H,AL
    JMP $+2
    IN AL,71H  ;读“时”
    MOV AH,AL
    AND AL,0FH
    SHR AH,4
    ADD AX,3030H
    XCHG AH,AL
    MOV WORD PTR HOUR,AX  ;转化ASCII码并存入hour

    MOV AL,2
    OUT 70H,AL
    JMP $+2
    IN AL,71H  ;读“分”
    MOV AH,AL
    AND AL,0FH
    SHR AH,4
    ADD AX,3030H
    XCHG AH,AL
    MOV WORD PTR MIN,AX  ;转化ASCII码并存入min

    MOV AL,0
    OUT 70H,AL
    JMP $+2
    IN AL,71H  ;读“秒”
    MOV AH,AL
    AND AL,0FH
    SHR AH,4
    ADD AX,3030H
    XCHG AH,AL
    MOV WORD PTR SEC,AX  ;转化ASCII码并存入sec
    RET
GET_TIME ENDP

;初始化（中断处理程序的安装）及主程序
BEGIN:
    PUSH CS
    POP DS
    MOV AX,3508H   ;获取原08H的中断矢量
    INT 21H      ;功能调用AH，即35H；然后35H为取中断信息功能，取AL中断类型号，即08H，入口地址返回到ES:[BX]
    MOV OLD_INT,BX
    MOV OLD_INT+2,ES
    MOV SI,BX
    SUB SI,2
    CMP WORD PTR [SI],'#'
    JZ EXIT
    MOV DX,OFFSET NEW08H
    MOV AX,2508H
    INT 21H     ;25H为置中断矢量，AL为中断号类型，DS:[DX]为入口地址
    
    MOV AH,02H
    MOV DL,'T'
    INT 21H   ;判断是否重复安装

    MOV DX,OFFSET BEGIN+15
    MOV CL,4
    SHR DX,CL
    ADD DX,10H
    MOV AL,0
    MOV AH,31H
    INT 21H

EXIT:
    MOV AH,4CH
    INT 21H  ;退出
CODE ENDS
   
STACK SEGMENT USE16 STACK   ;主程序堆栈段
    DB 200 DUP(0)
STACK ENDS
END BEGIN


