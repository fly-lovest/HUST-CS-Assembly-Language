;编写者：董城成
;包含商品系统主流程程序main
;包含函数my_strcmp,sell_goods,count_profits,my_sort的函数声明
;其定义函数位于func.asm子模块中

.686P
.model flat,c
  ExitProcess proto stdcall:dword
  scanf proto c :ptr sbyte,:vararg
  printf proto c :ptr sbyte,:vararg
  includelib libcmt.lib
  includelib legacy_stdio_definitions.lib
  my_strcmp proto :dword,:dword
  sell_goods proto :dword,:dword
  count_profits proto :dword
  my_sort proto stdcall :dword
  other_road proto
  VirtualProtect proto stdcall:dword,:dword,:dword,:dword
  include winTimer.asm
  public Note_END

GOODS  struct
  GOODSNAME  DB 10 DUP(0)
  BUYPRICE   DW  0
  SELLPRICE  DW  0
  BUYNUM     DW  0
  SELLNUM    DW  0
  RATE       DW  0
GOODS  ENDS

GOODSID struct
  ID DD 0
  RATES DW 0
GOODSID ENDS

.data
  lpfmt1 DB '%s',0
  lpfmt2 DB '%d',0
  lpfmt3 DB '商品名:%s，进货价:%d，销售价:%d，进货数量:%d，已售数量:%d，利润率:%d%%',0ah,0dh,0
  lpfmt4 DB '商品名:%s，进货价:%d，销售价:%d，进货数量:%d，已售数量:%d',0ah,0dh,0
  num    DB ?
  count_num DB 10
  Note_1 DB '请输入用户名：',0
  Note_2 DB '请输入密码：',0
  Note_3 DB '用户名错误，请重新输入！',0ah,0dh,0ah,0dh,0
  Note_4 DB '密码错误，请重新输入！',0ah,0dh,0ah,0dh,0
  Note_5 DB 0ah,0dh,'菜单：1.查找商品；  2.出货；   3.补货；   4.计算利润率；  5.利润率递减输出   9.退出；',0
  Note_6 DB 0ah,0dh,0ah,0dh,'输入操作：',0
  Note_7 DB '操作码输入错误！请重新输入！',0ah,0dh,0ah,0dh,0
  Note_8 DB '输入商品名：',0
  Note_9 DB '未查找到商品！',0
  Note_10 DB '请输入销售数量：',0
  Note_11 DB '数据输入错误！',0
  Note_12 DB '请输入进货数量：',0
  Note_13 DB '利润率计算成功！',0
  Note_END DB 'TempValue',0
  ANAME  DB 20 DUP(0)   ;储存输入名称
  APASS  DB 20 DUP(0)    ;存储输入密码
  GOOD   DB 20 DUP(0)   ;存储商品名称
  DATA   DW 0  
  BNAME  DB  'DONGCHENGCHENG',0  ;老板姓名（要求必须是自己名字的拼音）
  BPASS  DB  'U' xor 'A','2' xor 'B', '0' xor 'C','1914984',12H,32H,0      ;密码（必须是自己的学号）
  N  EQU  30

  GA1 GOODS <'PEN',15+10H ,20,70,25,>                  ;商品名 进货价，销售价，进货数量，已售数量，利润率
  GA2 GOODS <'PENCIL',2+10H,3,100,50,>
  GA3 GOODS <'BOOK',30+10H,40,25,5,>
  GAN GOODS N-3 DUP(<'TempValue',15,20,30,2,>)
  GAE GOODS <'TempValue',0,0,0,0,0>

 GOODSRATE GOODSID 30 DUP (<0,0>)

 P5 DD ?
 str_end DD ?
 P1 DD count_profits

 machine_code DB 0E8H,0A1H,94H,0FFH,0FFH  ;call my_strcmp的机器码
len = $ - machine_code
oldprotect DD ?

.stack 200
.code
main proc
start:
  invoke printf,offset Note_1  ;输入名称
  invoke scanf,offset lpfmt1,offset ANAME
  invoke printf,offset Note_2  ;输入密码
  invoke scanf,offset lpfmt1,offset APASS
  push offset BNAME
  push offset ANAME
  mov eax,len     ;动态修改代码
  mov ebx,40H
  lea ecx,Copy
  invoke VirtualProtect,ecx,eax,ebx,offset oldprotect
  mov ecx,len
  mov edi,offset Copy
  mov esi,offset machine_code
Copyloop:
  mov al,[esi]
  mov [edi],al
  inc esi
  inc edi
  loop Copyloop
Copy:
  DB len dup(0)  ;动态修改代码结束
  add esp,8
  cmp eax,0
  jne errorname
 push esi
 push edi
 push ebx
 INVOKE winTimer,0   ;计时开始
 mov ebx,0
 mov esi,offset APASS
 mov edi,offset BPASS
 xor APASS,'A'
 xor APASS[1],'B'
 xor APASS[2],'C'
 mov P5,str_loop1
 mov str_end,str_exit
str_loop1:
 mov al,[esi]
 cmp al,[edi]
 INVOKE winTimer,1  ;计时结束，时间差为eax
 cmp eax,55   ;当计时大于55ms时则转移到特定指令区
 ja errorpass
 jne str_exit
 inc ebx
 cmp ebx,10
 je str_ok
 inc esi
 inc edi
 jmp str_loop1
str_error:
  mov eax,1                ;间接转移方式
  mov ebx,offset P5
  mov edx,1
  jmp dword ptr[ebx+edx*4]
str_ok:
  inc esi
  cmp byte ptr[esi],0
  jne str_error
  mov eax,0
str_exit:
  pop ebx
  call other_road      ;在处理堆栈中途进行其他指令执行，干扰视线
  msg DB 'Hello,world',0   ;添加多余数据定义，干扰视线
  pop edi
  pop esi
  cmp eax,0
  jne errorpass
  invoke printf,offset Note_5
input:
  invoke printf,offset Note_6  ;输入操作数
  invoke scanf,offset lpfmt2,offset num
  cmp num,1
  je func1
  cmp num,2
  je func2
  cmp num,3
  je func3
  cmp num,4
  je func4
  cmp num,5
  je func5
  cmp num,9
  je exit
  
  invoke printf,offset Note_7 
  jmp input
errorname:  ;用户名错误
  invoke printf,offset Note_3
  jmp start

errorpass:  ;密码错误
  invoke printf,offset Note_4
  jmp start

errorgood:
  invoke printf,offset Note_9
  jmp input

errordata:
  invoke printf,offset Note_11
  jmp input

func1:  ;操作1：查找商品
  invoke printf,offset Note_8
  invoke scanf,offset lpfmt1,offset GOOD
  MOV EBX,0
  MOV ESI,offset GA1
Loop1:
  invoke my_strcmp,offset GOOD,ESI
  ADD ESI,20
  ADD EBX,1
  cmp EBX,N
  jge errorgood
  cmp EAX,0
  jne Loop1
  sub ESI,20
  movsx eax,word ptr[ESI+18]
  invoke printf,offset lpfmt3,ESI,word ptr[ESI+10],word ptr[ESI+12],word ptr[ESI+14],word ptr[ESI+16],eax
  jmp input

func2:  ;操作2：修改销售量
  invoke printf,offset Note_8
  invoke scanf,offset lpfmt1,offset GOOD
  MOV EBX,0
  MOV ESI,offset GA1
Loop2:
  invoke my_strcmp,offset GOOD,ESI
  ADD ESI,20
  ADD EBX,1
  cmp EBX,N
  jge errorgood
  cmp EAX,0
  jne Loop2
  sub ESI,20
  invoke printf,offset Note_10
  invoke scanf,offset lpfmt2,offset DATA
  invoke sell_goods,ESI,DATA
  cmp eax,0
  je errordata
  invoke printf,offset lpfmt4,ESI,word ptr[ESI+10],word ptr[ESI+12],word ptr[ESI+14],word ptr[ESI+16]
  jmp input

func3:  ;操作3，修改进货量
 invoke printf,offset Note_8
  invoke scanf,offset lpfmt1,offset GOOD
  MOV EBX,0
  MOV ESI,offset GA1
Loop3:
  invoke my_strcmp,offset GOOD,ESI
  ADD ESI,20
  ADD EBX,1
  cmp EBX,N
  jge errorgood
  cmp EAX,0
  jne Loop3
  sub ESI,20
  invoke printf,offset Note_12
  invoke scanf,offset lpfmt2,offset DATA
  MOV AX,DATA
  add word ptr[ESI+14],AX
  invoke printf,offset lpfmt4,ESI,word ptr[ESI+10],word ptr[ESI+12],word ptr[ESI+14],word ptr[ESI+16]
  jmp input


func4:   ;计算利润率 =（销售价*已售数量-进货价*进货数量）*100/（进货价*进货数量） 【有符号数】
  MOV ESI,offset GA1
  MOV EDI,offset GOODSRATE
Loop4:
  invoke my_strcmp,offset Note_END,ESI
  CMP EAX,0
  je next
  lea eax,P1   ;间接调用方式
  push ESI
  call dword ptr[eax]
  ADD ESP,4
  MOV dword ptr [EDI],ESI
  MOV word ptr [EDI+4],AX
  ADD esi,20
  ADD EDI,6
  jmp Loop4
next:
  mov dword ptr [EDI],offset GAE
  mov word ptr[EDI+4],0
  invoke printf,offset Note_13
  jmp input


func5: ;对计算好的利润率进行排序
  invoke my_sort,offset GOODSRATE
  MOV EBX,EAX
PRF:
  MOV EDI,offset GOODSRATE
  ADD EDI,EBX
  MOV ESI,[EDI].GOODSID.ID
  movsx eax,word ptr[ESI+18]
  invoke printf,offset lpfmt3,ESI,word ptr[ESI+10],word ptr[ESI+12],word ptr[ESI+14],word ptr[ESI+16],eax
  sub EBX,6
  cmp EBX,0  ;对有效数据进行输出
  jge PRF
  jmp input

exit:
  invoke ExitProcess,0
main endp
end