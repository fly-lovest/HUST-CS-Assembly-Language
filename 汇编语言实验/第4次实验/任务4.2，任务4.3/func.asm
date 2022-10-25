;��д�ߣ����ǳ�
;������Ʒϵͳ��֧����
;my_strcmp,sell_goods,count_profits,my_sort�ĺ�������

.686P
.model flat,c
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
extern Note_END:byte

.code
;my_strcmp�ַ����ȽϺ���
;buf1��buf2Ϊ���Ƚ��ַ�����ŵ��׵�ַ
;�ֲ�����count_num���ڼ�����ǰ�Ƚ�λ��
;��ջ�����Ĵ���esi��edi
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


;sell_goods������Ʒ����
;TARIDΪ��������Ʒ���׵�ַ,ͬʱҲ��Ŵ������׵�ַ;SellDataΪ��������
;ESI����׵�ַ
sell_goods proc uses ESI,TARID:dword,SellData:word
  MOV ESI,TARID
  MOV ax,word ptr[ESI+14]
  sub ax,word ptr[ESI+16]
  cmp SellData, ax
  ja sell_error
  MOV AX,SellData
  add word ptr[ESI+16],AX
  mov eax,1
  jmp exit
sell_error:
  mov eax,0
exit:
  ret
sell_goods endp


;count_profits���������ʺ���
;GOODIDΪ��������Ʒ���׵�ַ��ͬʱҲ��Ŵ������׵�ַ
;ESI����׵�ַ
count_profits proc uses ESI EDI EBX,GOODID:dword
  MOV ESI,GOODID
  save_imul word ptr [ESI+12],word ptr [ESI+16],eax    ;eax�洢���۶�
  imul EAX,100
  MOV DI,word ptr [ESI+10]
  SUB DI,10H
  save_imul DI,word ptr [ESI+14],ecx       ;ecx�洢������
  MOV EBX,ECX
  imul EBX,100
  sub EAX,EBX     ;eax�洢����
  cdq
  idiv ECX
  MOV word ptr[ESI+18],AX
  ret
count_profits endp


;my_sort������
;ORIIDΪ������ṹ���׵�ַ��ͬʱҲ��������Ľṹ�׵�ַ
;eax�����ⲿѭ���ļ�����esi����ֱ���ڲ�ѭ���ļ���
my_sort proc stdcall uses ESI EDI EBX,ORIID:dword ;ecxΪ���ѭ����esiΪ�ڲ�ѭ��
  mov ECX,6
Loop5:
  MOV EDI,ORIID
  ADD EDI,ECX
  invoke my_strcmp,offset Note_END,dword ptr [EDI]
  CMP EAX,0
  je next5
  SUB ECX,6
  MOV ESI,ORIID
  ADD ESI,ECX
  ADD ECX,6
  MOV EDX,dword ptr [EDI]
  MOV AX,word ptr[EDI+4]
Loop6:
  CMP AX,word ptr [ESI+4]
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
  mov word ptr [ESI+4],AX
  ADD ECX,6
  jmp Loop5
next5:
  MOV EAX,ECX
  sub EAX,6
  ret
my_sort endp


;������·
other_road proc
  pop ebx
p1:
  cmp byte ptr[ebx],0
  je exit
  inc ebx
  jmp p1
exit:
  inc ebx
  push ebx
  ret
other_road endp

end