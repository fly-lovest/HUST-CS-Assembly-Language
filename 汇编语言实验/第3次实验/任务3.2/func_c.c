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
	printf("请输入用户名：");
	scanf("%s", ANAME);
	printf("请输入密码：");
	scanf("%s", APASS);
	flat = my_strcmp(ANAME,BNAME);
	if (flat == 1) {
		printf("用户名错误，请重新输入！\n\n");
		return 0;
	}
	flat = my_strcmp(APASS, BPASS);
	if (flat == 1) {
		printf("密码错误，请重新输入！\n\n");
		return 0;
	}
	printf("\n菜单：1.查找商品；  2.出货；   3.补货；   4.计算利润率；  5.利润率递减输出；   6.添加商品；   9.退出；\n");
	return 1;
}

void add_goods(){
	int flat,i;
	for (i=0; i < 30; i++) {
		flat = my_strcmp(Note_END, GA1[i].GOODSNAME);
		if (flat == 0) {
			printf("添加商品名：");
			scanf("%s", GA1[i].GOODSNAME);
			printf("添加进货价：");
			scanf("%d", &GA1[i].BUYPRICE);
			printf("添加销售价：");
			scanf("%d", &GA1[i].SELLPRICE);
			printf("添加进货数量：");
			scanf("%d", &GA1[i].BUYNUM);
			printf("添加已售数量：");
			scanf("%d", &GA1[i].SELLNUM);
			printf("添加商品成功！");
			return;
		}
	}
	printf("商品容量已满，添加商品失败！");
	return;
}
