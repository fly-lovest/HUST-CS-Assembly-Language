#include <stdio.h>
struct GOODS {
	unsigned char  GOODSNAME[10];
	unsigned short	BUYPRICE;
	unsigned short	SELLPRICE;
	unsigned short	BUYNUM;
	unsigned short	SELLNUM;
	unsigned short	RATE;
};

extern unsigned char BNAME[20], BPASS[20];
extern unsigned char Note_END[10];
extern struct GOODS GA1[30];

int log_in_func() {
	unsigned char ANAME[20], APASS[20];
	int flat;
	printf("�������û�����");
	scanf("%s", ANAME);
	printf("���������룺");
	scanf("%s", APASS);
	flat = my_strcmp(ANAME,BNAME);
	if (flat == 1) {
		printf("�û����������������룡\n\n");
		return 0;
	}
	flat = my_strcmp(APASS, BPASS);
	if (flat == 1) {
		printf("����������������룡\n\n");
		return 0;
	}
	printf("\n�˵���1.������Ʒ��  2.������   3.������   4.���������ʣ�  5.�����ʵݼ������   6.�����Ʒ��   9.�˳���\n");
	return 1;
}

void add_goods(){
	int flat,i;
	for (i=0; i < 30; i++) {
		flat = my_strcmp(Note_END, GA1[i].GOODSNAME);
		if (flat == 0) {
			printf("�����Ʒ����");
			scanf("%s", GA1[i].GOODSNAME);
			printf("��ӽ����ۣ�");
			scanf("%d", &GA1[i].BUYPRICE);
			printf("������ۼۣ�");
			scanf("%d", &GA1[i].SELLPRICE);
			printf("��ӽ���������");
			scanf("%d", &GA1[i].BUYNUM);
			printf("�������������");
			scanf("%d", &GA1[i].SELLNUM);
			printf("�����Ʒ�ɹ���");
			return;
		}
	}
	printf("��Ʒ���������������Ʒʧ�ܣ�");
	return;
}
