.386
.model   flat,stdcall
option   casemap:none
  ExitProcess proto stdcall:dword
  includelib libcmt.lib
  includelib legacy_stdio_definitions.lib
  my_strcmp proto :dword,:dword
  count_profits proto :dword
  my_sort proto :dword
WinMain  proto :DWORD,:DWORD,:DWORD,:DWORD
WndProc  proto :DWORD,:DWORD,:DWORD,:DWORD
Display  proto :DWORD
Computerate proto
putstr proto :DWORD,:DWORD
putdata proto :WORD,:DWORD

include      menuID.INC

include      windows.inc
include      user32.inc
include      kernel32.inc
include      gdi32.inc
include      shell32.inc

includelib   user32.lib
includelib   kernel32.lib
includelib   gdi32.lib
includelib   shell32.lib

    save_imul macro buf1,buf2,product
      push ebx
      push edx
      movzx ebx,buf1
      movzx edx,buf2
      imul ebx,edx
      mov product,ebx
      pop edx
      pop ebx
    endm

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
;my data
  Note_END DB 'TempValue',0
  N  EQU  30

  GA1 GOODS <'PEN',15,20,70,25,>  ;商品名 进货价，销售价，进货数量，已售数量，利润率
  GA2 GOODS <'PENCIL',2,3,100,50,>
  GA3 GOODS <'BOOK',30,40,25,5,>
  GA4 GOODS <'RULER',3,4,200,150,>
  GA5 GOODS <'WATER',2,4,150,140,>
  GAN GOODS N-5 DUP(<'TempValue',15,20,30,2,>)

 GOODSRATE GOODSID 30 DUP (<0,0>) 
;my data end

ClassName    db       'TryWinClass',0
AppName      db       'Oline Store System',0
MenuName     db       'MyMenu',0
DlgName	     db       'MyDialog',0
AboutMsg     db       'Name: Dong Chengcheng',0ah,0dh,'No.U201914984',0
AboutName    db       'ID Message',0
ComputeMsg   db       'Compute Rate Success!',0
ComputeName  db       'Compute Rate',0
hInstance    dd       0
CommandLine  dd       0

msg_name      db       'GoodsName',0
msg_buyprice  db       'BuyPrice',0
msg_sellprice db       'SellPrice',0
msg_buynum    db       'BuyNum',0
msg_sellnum   db       'SellNum',0
msg_rate      db       'Rate',0

goods_name      db  32,32,32,32,32,32,0
goods_buyprice  db  32,32,32,32,0
goods_sellprice db  32,32,32,32,0
goods_buynum    db  32,32,32,32,0
goods_sellnum   db  32,32,32,32,0
goods_rate      db  32,32,32,32,32,0


menuItem     db       0  ;当前菜单状态, 1=处于list, 0=Clear

.code
Start:	     invoke GetModuleHandle,NULL
	     mov    hInstance,eax
	     invoke GetCommandLine
	     mov    CommandLine,eax
	     invoke WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT
	     invoke ExitProcess,eax
	     ;;
WinMain  proc   hInst:DWORD,hPrevInst:DWORD,CmdLine:DWORD,CmdShow:DWORD
	     LOCAL  wc:WNDCLASSEX
	     LOCAL  msg:MSG
	     LOCAL  hWnd:HWND
         invoke RtlZeroMemory,addr wc,sizeof wc
	     mov    wc.cbSize,SIZEOF WNDCLASSEX
	     mov    wc.style, CS_HREDRAW or CS_VREDRAW
	     mov    wc.lpfnWndProc, offset WndProc
	     mov    wc.cbClsExtra,NULL
	     mov    wc.cbWndExtra,NULL
	     push   hInst
	     pop    wc.hInstance
	     mov    wc.hbrBackground,COLOR_WINDOW+1
	     mov    wc.lpszMenuName, offset MenuName
	     mov    wc.lpszClassName,offset ClassName
	     invoke LoadIcon,NULL,IDI_APPLICATION
	     mov    wc.hIcon,eax
	     mov    wc.hIconSm,0
	     invoke LoadCursor,NULL,IDC_ARROW
	     mov    wc.hCursor,eax
	     invoke RegisterClassEx, addr wc
	     INVOKE CreateWindowEx,NULL,addr ClassName,addr AppName,\
                    WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\
                    CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,NULL,NULL,\
                    hInst,NULL
	     mov    hWnd,eax
	     INVOKE ShowWindow,hWnd,SW_SHOWNORMAL
	     INVOKE UpdateWindow,hWnd
	     ;;
MsgLoop:     INVOKE GetMessage,addr msg,NULL,0,0
             cmp    EAX,0
             je     ExitLoop
             INVOKE TranslateMessage,addr msg
             INVOKE DispatchMessage,addr msg
	     jmp    MsgLoop 
ExitLoop:    mov    eax,msg.wParam
	     ret
WinMain      endp

WndProc      proc   hWnd:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
	     LOCAL  hdc:HDC
	     LOCAL  ps:PAINTSTRUCT
     .IF     uMsg == WM_DESTROY
	     invoke PostQuitMessage,NULL
     .ELSEIF uMsg == WM_KEYDOWN
	    .IF     wParam == VK_F1
             ;;your code
	    .ENDIF
     .ELSEIF uMsg == WM_COMMAND
	    .IF     wParam == IDM_FILE_EXIT
		    invoke SendMessage,hWnd,WM_CLOSE,0,0
	    .ELSEIF wParam == IDM_ACTION_COMPUTE
		    invoke Computerate
            invoke MessageBox,hWnd,addr ComputeMsg,addr ComputeName,0
	    .ELSEIF wParam == IDM_ACTION_LIST
		    mov menuItem, 1
		    invoke InvalidateRect,hWnd,0,1  ;擦除整个客户区
		    invoke UpdateWindow, hWnd

	    .ELSEIF wParam == IDM_HELP_ABOUT
		    invoke MessageBox,hWnd,addr AboutMsg,addr AboutName,0
	    .ENDIF
     .ELSEIF uMsg == WM_PAINT
             invoke BeginPaint,hWnd, addr ps
             mov hdc,eax
	     .IF menuItem == 1
		 invoke Display,hdc
	     .ENDIF
	     invoke EndPaint,hWnd,addr ps
     .ELSE
             invoke DefWindowProc,hWnd,uMsg,wParam,lParam
             ret
     .ENDIF
  	     xor    eax,eax
	     ret
WndProc      endp

Display      proc   hdc:HDC
             XX     equ  10
             YY     equ  10
	     XX_GAP equ  100
	     YY_GAP equ  30
             invoke TextOut,hdc,XX+0*XX_GAP,YY+0*YY_GAP,offset msg_name,9
             invoke TextOut,hdc,XX+1*XX_GAP,YY+0*YY_GAP,offset msg_buyprice,8
             invoke TextOut,hdc,XX+2*XX_GAP,YY+0*YY_GAP,offset msg_sellprice,9
             invoke TextOut,hdc,XX+3*XX_GAP,YY+0*YY_GAP,offset msg_buynum,6
             invoke TextOut,hdc,XX+4*XX_GAP,YY+0*YY_GAP,offset msg_sellnum,7
             invoke TextOut,hdc,XX+5*XX_GAP,YY+0*YY_GAP,offset msg_rate,4
             invoke my_sort,offset GOODSRATE
             MOV EBX,24
			 MOV EDI,YY+YY_GAP
       PRF:
             MOV EDX,offset GOODSRATE
             ADD EDX,EBX
             MOV ESI,[EDX].GOODSID.ID
             invoke putstr,ESI,offset goods_name
             invoke putdata,word ptr[ESI+10],offset goods_buyprice
             invoke putdata,word ptr[ESI+12],offset goods_sellprice
             invoke putdata,word ptr[ESI+14],offset goods_buynum
             invoke putdata,word ptr[ESI+16],offset goods_sellnum
             invoke putdata,word ptr[ESI+18],offset goods_rate
             mov goods_rate[4],'%'
			 invoke TextOut,hdc,XX+0*XX_GAP,edi,offset goods_name,6
             invoke TextOut,hdc,XX+1*XX_GAP,edi,offset goods_buyprice,4
             invoke TextOut,hdc,XX+2*XX_GAP,edi,offset goods_sellprice,4
             invoke TextOut,hdc,XX+3*XX_GAP,edi,offset goods_buynum,4
             invoke TextOut,hdc,XX+4*XX_GAP,edi,offset goods_sellnum,4
             invoke TextOut,hdc,XX+5*XX_GAP,edi,offset goods_rate,5
			 sub EBX,6
			 ADD EDI,30
             cmp EBX,0  ;对前5个数进行输出
             jge PRF
			 ret

Display      endp

Computerate  proc uses esi edi
  MOV ESI,offset GA1
  MOV EDI,offset GOODSRATE
Loop4:
  invoke my_strcmp,offset Note_END,ESI
  CMP EAX,0
  je next
  invoke count_profits,ESI
  MOV dword ptr [EDI],ESI
  MOV word ptr [EDI+4],AX
  ADD ESI,20
  ADD EDI,6
  jmp Loop4
next:
  ret
Computerate endp

;my_strcmp字符串比较函数
;buf1与buf2为待比较字符串存放的首地址
;局部变量count_num用于计数当前比较位数
;堆栈保护寄存器esi，edi
my_strcmp proc,buf1:dword,buf2:dword
 local count_num:dword
 push esi
 push edi
 mov count_num,0
 mov esi,buf1
 mov edi,buf2
str_loop1:
 mov al,[esi]
 cmp al,[edi]
 jne str_error
 cmp al,0
 je str_ok
 inc count_num
 inc esi
 inc edi
 jmp str_loop1
str_error:
  mov eax,1
  jmp str_exit
str_ok:
  mov eax,0
str_exit:
  pop edi
  pop esi
  ret
my_strcmp endp



;count_profits计算利润率函数
;GOODID为待计算商品的首地址；同时也存放处理后的首地址
;ESI存放首地址
count_profits proc uses ESI EBX,GOODID:dword
  MOV ESI,GOODID
  save_imul word ptr [ESI+12],word ptr [ESI+16],eax    ;eax存储销售额
  imul EAX,100
  save_imul word ptr [ESI+10],word ptr [ESI+14],ecx       ;ecx存储进货额
  MOV EBX,ECX
  imul EBX,100
  sub EAX,EBX     ;eax存储利润
  cdq
  idiv ECX
  MOV word ptr[ESI+18],AX
  ret
count_profits endp


;my_sort排序函数
;ORIID为待排序结构的首地址；同时也存放排序后的结构首地址
;eax用于外部循环的计数；esi用于直接内部循环的计数
my_sort proc stdcall uses ESI EDI EBX,ORIID:dword ;eax为外层循环，esi为内层循环
  mov EAX,6
Loop5:
  CMP EAX,24
  ja next5
  MOV EDI,ORIID
  ADD EDI,EAX
  SUB EAX,6
  MOV ESI,ORIID
  ADD ESI,EAX
  ADD eax,6
  MOV EDX,dword ptr [EDI]
  MOV CX,word ptr[EDI+4]
Loop6:
  CMP CX,word ptr [ESI+4]
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
  ADD ESI,6
  mov dword ptr[ESI],EDX
  mov word ptr [ESI+4],CX
  ADD eax,6
  jmp Loop5
next5:
  ret
my_sort endp

;A为原位置地址，B为赋值位置地址
putstr proc uses eax ecx esi edi A:DWORD,B:DWORD
mov ESI,A
mov EDI,B
mov eax,0
loopputstr:
cmp byte ptr[ESI+eax],0
je nextstr
mov cl,byte ptr[ESI+eax]
mov byte ptr[EDI+eax],cl
inc eax
jmp loopputstr
nextstr:
cmp byte ptr[EDI+eax],0
je endputstr
mov byte ptr[EDI+eax],32
inc eax
jmp nextstr
endputstr:
ret
putstr endp

putdata proc uses esi ebx, dgt:word, string1:dword
        mov esi, string1
        mov ax, dgt
        mov bx, 10
        mov cx,0
        cmp ax, 0
        jge JUM     ;该分支结构用于处理负数
        mov byte ptr[esi],'-'
        imul ax,-1
        inc esi
JUM:    mov dx,0
        div bx
        push dx
        inc cx
        cmp ax, 0
        jne JUM
FINISHED:
        pop ax
        add al,30H
        mov [esi],al
        inc esi
        dec cx
        jnz FINISHED
loopput32:
       cmp byte ptr[esi],0
       je finishend
       mov byte ptr[esi],32
       inc esi
       jmp loopput32
finishend:
        ret
putdata endp

end  Start
