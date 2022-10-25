.686P
.model flat,c
  ExitProcess proto stdcall:dword
  scanf proto :ptr sbyte,:vararg
  printf proto :ptr sbyte,:vararg
  strcmp proto :ptr sbyte,:vararg
  includelib libcmt.lib
  includelib legacy_stdio_definitions.lib

.data
  lpfmt1 DB '%s',0
  lpfmt2 DB '%d',0
  lpfmt3 DB '��Ʒ��:%s��������:%d�����ۼ�:%d����������:%d����������:%d��������:%d%%',0ah,0dh,0
  lpfmt4 DB '��Ʒ��:%s��������:%d�����ۼ�:%d����������:%d����������:%d',0ah,0dh,0
  num    DB ?
  Note_1 DB '�������û�����',0
  Note_2 DB '���������룺',0
  Note_3 DB '�û����������������룡',0ah,0dh,0ah,0dh,0
  Note_4 DB '����������������룡',0ah,0dh,0ah,0dh,0
  Note_5 DB 0ah,0dh,'�˵���1.������Ʒ��  2.������   3.������   4.�����ʣ�    9.�˳���',0
  Note_6 DB 0ah,0dh,0ah,0dh,'���������',0
  Note_7 DB '����������������������룡',0ah,0dh,0ah,0dh,0
  Note_8 DB '������Ʒ����',0
  Note_9 DB 'δ���ҵ���Ʒ��',0
  Note_10 DB '����������������',0
  Note_11 DB '�����������',0
  Note_12 DB '���������������',0
  Note_13 DB '�����ʼ���ɹ���',0
  ANAME  DB 20 DUP(0)   ;������������
  APASS  DB 20 DUP(0)    ;�洢��������
  GOOD   DB 20 DUP(0)   ;�洢��Ʒ����
  DATA   DW 0  
  BNAME  DB  'DONGCHENGCHENG',0  ;�ϰ�������Ҫ��������Լ����ֵ�ƴ����
  BPASS  DB  'U201914984',0  ;���루�������Լ���ѧ�ţ�
  N  EQU  30
  GA1   DB   'PEN', 7 DUP(0)  ;��Ʒ1 ����
        DW   15,20,70,25,?  ;�����ۡ����ۼۡ��������������������������ʣ���δ���㣩
  GA2   DB   'PENCIL', 4 DUP(0) ;��Ʒ2 ����
        DW   2,3,100,50,?
  GA3   DB   'BOOK', 6 DUP(0) ;��Ʒ3 ����
        DW   30,40,25,5,?
  GA4   DB   'RULER',5 DUP(0)  ;��Ʒ4 ����
        DW   3,4,200,150,?
  GA5   DB   'WATER',5 DUP(0)  ;��Ʒ5 ����
        DW   2,4,150,140,?
  GAN   DB N-5 DUP( 'TempValue' ,0,15,0,20,0,30,0,2,0,?,?)  ;����4���Ѿ����嶨���˵���Ʒ��Ϣ���⣬������Ʒ��Ϣ��ʱ�ٶ�Ϊһ����

.stack 200
.code
main proc
start:
  invoke printf,offset Note_1  ;��������
  invoke scanf,offset lpfmt1,offset ANAME
  invoke printf,offset Note_2  ;��������
  invoke scanf,offset lpfmt1,offset APASS
  invoke strcmp,offset ANAME,offset BNAME  ;�Ƚ��û���
  cmp eax,0
  jne errorname
  invoke strcmp,offset APASS,offset BPASS  ;�Ƚ�����
  cmp eax,0
  jne errorpass
  invoke printf,offset Note_5
input:
  invoke printf,offset Note_6  ;���������
  invoke scanf,offset lpfmt2,offset num
  cmp num,1
  je func1
  cmp num,2
  je func2
  cmp num,3
  je func3
  cmp num,4
  je func4
  cmp num,9
  je exit
  
  invoke printf,offset Note_7 
  jmp input
errorname:  ;�û�������
  invoke printf,offset Note_3
  jmp start

errorpass:  ;�������
  invoke printf,offset Note_4
  jmp start

errorgood:
  invoke printf,offset Note_9
  jmp input

errordata:
  invoke printf,offset Note_11
  jmp input

func1:  ;����1��������Ʒ
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

func2:
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

func3:
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

func4:   ;���������� =�����ۼ�*��������-������*����������*100/��������*���������� ���з�������
  MOV ESI,offset GA1
Loop4:
  invoke strcmp,offset GAN,ESI
  CMP EAX,0
  je next  
  MOVZX EAX,word ptr [ESI+12]
  MOVZX ECX,word ptr [ESI+16]
  imul EAX,ECX    ;eax�洢���۶�
  imul EAX,100
  MOVZX EBX,word ptr [ESI+10]
  MOVZX ECX,word ptr [ESI+14]
  imul ECX,EBX    ;ecx�洢������
  MOV EBX,ECX
  imul EBX,100
  sub EAX,EBX     ;eax�洢����
  cdq
  idiv ECX
  MOV word ptr[ESI+18],AX
  ADD ESI,20
  jmp Loop4
next:
  invoke printf,offset Note_13
  jmp input

exit:
  invoke ExitProcess,0
main endp
end