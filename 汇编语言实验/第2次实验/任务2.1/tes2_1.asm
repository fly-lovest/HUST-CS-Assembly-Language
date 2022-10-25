.686P
.model flat,c
  ExitProcess proto stdcall:dword
  scanf proto :ptr sbyte,:vararg
  printf proto :ptr sbyte,:vararg
  strcmp proto :ptr sbyte,:vararg
  includelib libcmt.lib
  includelib legacy_stdio_definitions.lib
  include winTimer.asm
  function5 proto stdcall :dword

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
  Note_1 DB '请输入用户名：',0
  Note_2 DB '请输入密码：',0
  Note_3 DB '用户名错误，请重新输入！',0ah,0dh,0ah,0dh,0
  Note_4 DB '密码错误，请重新输入！',0ah,0dh,0ah,0dh,0
  Note_5 DB 0ah,0dh,'菜单：1.查找商品；  2.出货；   3.补货；   4.利润率；  5.利润率递减输出   9.退出；',0
  Note_6 DB 0ah,0dh,0ah,0dh,'输入操作：',0
  Note_7 DB '操作码输入错误！请重新输入！',0ah,0dh,0ah,0dh,0
  Note_8 DB '输入商品名：',0
  Note_9 DB '未查找到商品！',0
  Note_10 DB '请输入销售数量：',0
  Note_11 DB '数据输入错误！',0
  Note_12 DB '请输入进货数量：',0
  Note_13 DB '利润率计算成功！',0
  ANAME  DB 20 DUP(0)   ;储存输入名称
  APASS  DB 20 DUP(0)    ;存储输入密码
  GOOD   DB 20 DUP(0)   ;存储商品名称
  DATA   DW 0  
  BNAME  DB  'DONGCHENGCHENG',0  ;老板姓名（要求必须是自己名字的拼音）
  BPASS  DB  'U201914984',0  ;密码（必须是自己的学号）
  N  EQU  30

  GA1 GOODS <'PEN',15,20,70,25,>  ;商品名 进货价，销售价，进货数量，已售数量，利润率
  GA2 GOODS <'PENCIL',2,3,100,50,>
  GA3 GOODS <'BOOK',30,40,25,5,>
  GA4 GOODS <'RULER',3,4,200,150,>
  GA5 GOODS <'WATER',2,4,150,140,>
      GOODS N-6 DUP (<'OTHERS',15,20,30,2,>) ;修改了
  GAN GOODS <'TempValue',15,20,30,2,>  ;修改了

 GOODSRATE GOODSID 30 DUP (<0,0>) 
    

.stack 200
.code
main proc
start:
;  invoke printf,offset Note_1  ;输入名称
;  invoke scanf,offset lpfmt1,offset ANAME
;  invoke printf,offset Note_2  ;输入密码
;  invoke scanf,offset lpfmt1,offset APASS
;  invoke strcmp,offset ANAME,offset BNAME  ;比较用户名
;  cmp eax,0
;  jne errorname
;  invoke strcmp,offset APASS,offset BPASS  ;比较密码
;  cmp eax,0
;  jne errorpass
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
  invoke strcmp,offset GOOD,ESI
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
  invoke strcmp,offset GOOD,ESI
  ADD ESI,20
  ADD EBX,1
  cmp EBX,N
  jge errorgood
  cmp EAX,0
  jne Loop2
  sub ESI,20
  invoke printf,offset Note_10
  invoke scanf,offset lpfmt2,offset DATA
  MOV ax,word ptr[ESI+14]
  sub ax,word ptr[ESI+16]
  cmp DATA, ax
  ja errordata 
  MOV AX,DATA
  add word ptr[ESI+16],AX
  invoke printf,offset lpfmt4,ESI,word ptr[ESI+10],word ptr[ESI+12],word ptr[ESI+14],word ptr[ESI+16]
  jmp input

func3:  ;操作3，修改进货量
  invoke printf,offset Note_8
  invoke scanf,offset lpfmt1,offset GOOD
  MOV EBX,0
  MOV ESI,offset GA1
Loop3:
  invoke strcmp,offset GOOD,ESI
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
  MOV EBP,1
  INVOKE winTimer,0
Loop10000:  ;添加
  CMP EBP,1000000  ;添加
  ja Loop10000out  ;添加
  MOV ESI,offset GA1
  MOV EDI,offset GOODSRATE
Loop4:
  invoke strcmp,offset GAN,ESI
  CMP EAX,0
  je next
  MOVZX EAX,word ptr [ESI+12]
  MOVZX ECX,word ptr [ESI+16]
  imul EAX,ECX    ;eax存储销售额
  imul EAX,100
  MOVZX EBX,word ptr [ESI+10]
  MOVZX ECX,word ptr [ESI+14]
  imul ECX,EBX    ;ecx存储进货额
  MOV EBX,ECX
  imul EBX,100
  sub EAX,EBX     ;eax存储利润
  cdq
  idiv ECX
  MOV word ptr[ESI+18],AX
  MOV DWORD ptr [EDI],ESI
  MOV WORD ptr [EDI+4],AX
  ADD ESI,20
  ADD EDI,6
  jmp Loop4
next:
  jmp func5  ;添加
  invoke printf,offset Note_13
  jmp input


func5: ;对计算好的利润率进行排序

  invoke function5,offset GOODSRATE
  ADD EBP,1  ;添加
  jmp Loop10000  ;添加
Loop10000out:  ;添加
  invoke winTimer,1  ;添加
  MOV EBX,168
PRF:
  MOV EDI,offset GOODSRATE
  ADD EDI,EBX
  MOV ESI,[EDI].GOODSID.ID
  movsx eax,word ptr[ESI+18]
  invoke printf,offset lpfmt3,ESI,word ptr[ESI+10],word ptr[ESI+12],word ptr[ESI+14],word ptr[ESI+16],eax
  sub EBX,6
  cmp EBX,0  ;对前5个数进行输出
  jge PRF

  jmp input

exit:
  invoke ExitProcess,0
main endp



function5 proc stdcall uses ESI EDI EAX EBX ECX EDX,ORIID:dword ;eax为外层循环，esi为内层循环
  mov EAX,1
Loop5:
  CMP EAX,28
  ja next5
  MOV EDI,ORIID 
  mov ebx,eax
  imul ebx,6
  ADD EDI,EBX
  SUB EAX,1
  MOV ESI,ORIID
  mov ebx,eax
  imul ebx,6
  ADD ESI,EBX
  ADD eax,1
  MOV EDX,[EDI].GOODSID.ID
  MOV CX,[EDI].GOODSID.RATES
Loop6:
  mov BX,[ESI].GOODSID.RATES
  CMP CX,BX
  jge next6
  mov ebx,dword ptr[ESI]
  mov dword ptr[ESI+6],ebx
  mov bx,word ptr[ESI+4]
  mov word ptr [ESI+10],bx
  sub ESI,6
  CMP ESI,ORIID
  jb next6
  jmp Loop6
next6:
  ADD ax,1  ;修改
  ADD ESI,6
  mov dword ptr[ESI],EDX
  mov word ptr [ESI+4],CX

  jmp Loop5
next5:
  ret
function5 endp

end