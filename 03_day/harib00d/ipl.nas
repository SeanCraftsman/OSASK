; hello-os
; TAB=4

CYLS 	EQU 	10				; 声明扇面数

		ORG		0x7c00			; 指明程序的装载地址

; 以下内容用于标准的FAT12格式的软盘

		JMP		entry
		DB		0x90
		DB		"HARIBOTE"		; 启动区的名称，可以是任意字符串(8字节)
		DW		512				; 每个扇区(sector)的大小(必须是512字节)
		DB		1				; 每个簇(cluster)的大小(必须是1个扇区)
		DW		1				; FAT的起始位置
		DB		2				; FAT的个数
		DW		224				; 根目录的大小
		DW		2880			; 该磁盘的大小
		DB		0xf0			; 该磁盘的种类
		DW		9				; FAT的长度
		DW		18				; 1个磁道(track)有几个扇区
		DW		2				; 磁头数
		DD		0				; 不使用分区
		DD		2880			; 重写一次磁盘大小
		DB		0,0,0x29		; 
		DD		0xffffffff		;  
		DB		"HELLO-OS   "	; 磁盘的名称(11字节) 
		DB		"FAT12   "		; 磁盘格式名称(8字节)
		RESB	18				; 先空出18字节

; 程序核心

entry:
		MOV		AX,0			; 初始化寄存器
		MOV		SS,AX
		MOV		SP,0x7c00
		MOV		DS,AX

; 读磁盘

		MOV		AX,0x0820
		MOV		ES,AX
		MOV		CH,0			; 柱面0
		MOV		DH,0			; 磁头0
		MOV		CL,2			; 扇区2
readloop:
		MOV		SI,0			; 记录失败次数的寄存器
retry:
		MOV		AH,0x02			; AH=0x02 : 读盘
		MOV		AL,1			; 1个扇区
		MOV		BX,0
		MOV		DL,0x00			; A驱动器
		INT		0x13			; 调用磁盘BIOS
		JNC		next			; 没出错跳到next
		ADD		SI,1			; SI+1
		CMP		SI,5			; SI>=5时跳转
		JAE		error			
		MOV		AH,0x00
		MOV		DL,0x00			; A驱动器
		INT		0x13			; 重置驱动器
		JC		retry

next:
		MOV		AX,ES			; 把内存地址后移0x200
		ADD		AX,0X0020
		MOV		ES,AX			; 因为没有ADD ES，0x020指令，这里绕个弯
		ADD		CL,1			; 往CL里加1
		CMP		CL,18			; 比较CL与18
		JBE		readloop		; 如果CL<=18 跳转至readloop
		MOV		CL,1
		ADD 	DH,1
		CMP		DH,2
		JB 		readloop		; 如果DH<2，跳转到readloop
		MOV		DH,0
		ADD 	CH,1
		CMP 	CH,CYLS			
		JB 		readloop		; 如果CH<CYLS，跳转到readloop
fin:
		HLT						; 让CPU停止，等待指令
		JMP		fin				; 无限循环

error:
		MOV		SI,msg
putloop:
		MOV		AL,[SI]
		ADD		SI,1			; 给SI加1
		CMP		AL,0
		JE		fin
		MOV		AH,0x0e			; 显示一个文字
		MOV		BX,15			; 指定的字符颜色
		INT		0x10			; 调用显卡BIOS
		JMP		putloop
msg:
		DB		0x0a, 0x0a		; 换行两次
		DB		"load error"
		DB		0x0a			; 换行
		DB		0

		RESB	0x7dfe-$		; 从该位置填写0x00直到0x7dfe

		DB		0x55, 0xaa
