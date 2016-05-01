/*告诉编译器，有一个函数在别的文件里*/
void io_hlt(void);
void write_mem8(int addr, int data);

void HariMain(void)
{
	int i;

	for(i = 0xa0000; i <= 0xaffff; i++){
		write_mem8(i, i & 0x0f);
	}

	for(;;){
		io_hlt();
	}
}
