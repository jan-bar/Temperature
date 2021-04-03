PUBLIC		SET_LINE,DISPLAY_BMP,DISPLAY_LCD,CLEAR_SCREEN,CLR_LCD,INIT_LCD,SELECT_SCREEN
CODE_LCD	SEGMENT		CODE
LCD_RS		BIT			P2.2
LCD_RW		BIT			P2.1
LCD_E		BIT			P2.0
LCD_CS1		BIT			P2.4	;低电平有效，左半屏
LCD_CS2		BIT			P2.3	;低电平有效，右半屏
;;;;;;;;;;;;;;;;;;;;;;;;;
RSEG		CODE_LCD
;;;;;;;;;;;;;;;;;;;;;;;;;检查忙等待
CHEC_BUSY:			MOV		P0,#00H
					CLR		LCD_RS
					SETB	LCD_RW
					SETB	LCD_E
					JB		P0.7,$
					CLR		LCD_E
					RET
;;;;;;;;;;;;;;;;;;;;;;;;;
CLR_LCD:
					RET
;;;;;;;;;;;;;;;;;;;;;;;;;
WRITE_IR:			LCALL	CHEC_BUSY
					CLR		LCD_RS
					CLR		LCD_RW
					MOV		P0,A	;P0作为数据口
					SETB	LCD_E
					NOP
					NOP
					CLR		LCD_E	
					RET
;;;;;;;;;;;;;;;;;;;;;;;;;
WRITE_DR:			LCALL	CHEC_BUSY
					SETB	LCD_RS
					CLR		LCD_RW
					MOV		P0,A
					SETB	LCD_E
					NOP
					NOP
					CLR		LCD_E
					RET
;;;;;;;;;;;;;;;;;;;;;;;;;设置"页"LCD12864共8页，一页是8行点阵点
SET_PAGE:			ORL		A,#0B8H	;页的首地址为0xB8
					LCALL	WRITE_IR
					RET
;;;;;;;;;;;;;;;;;;;;;;;;;设置显示的起始行
SET_LINE:			ORL		A,#0C0H ;起始行地址为0xC0
					LCALL	WRITE_IR;设置从哪行开始：共0--63;一般从0 行开始显示
					RET
;;;;;;;;;;;;;;;;;;;;;;;;;设置显示的列
SET_COLUMN:			ANL		A,#3FH  ;列的最大值为64
					ORL		A,#40H  ;列的首地址为0x40
					LCALL	WRITE_IR;规定显示的列的位置
					RET
;;;;;;;;;;;;;;;;;;;;;;;;;显示开关函数：0x3E是关显示，0x3F是开显示
SET_ON_OFF:			ORL		A,#3EH  ;0011 111x,onoff只能为0或者1
					LCALL	WRITE_IR
					RET
;;;;;;;;;;;;;;;;;;;;;;;;;选择屏幕
SELECT_SCREEN:		CJNE	A,#0,SELECTN0
					;0全屏
					CLR		LCD_CS1
					CLR		LCD_CS2
					AJMP 	SELECT_END
SELECTN0:			CJNE	A,#1,SELECTN1
					;1左半屏
					CLR		LCD_CS1
					SETB	LCD_CS2
					AJMP 	SELECT_END
SELECTN1:			CJNE	A,#2,SELECTN2
					;2右半屏
					CLR		LCD_CS2
					SETB	LCD_CS1
SELECTN2:
SELECT_END:			RET
;;;;;;;;;;;;;;;;;;;;;;;;;清屏函数
CLEAR_SCREEN:		LCALL	SELECT_SCREEN;0--全屏；1---左半屏；2---右半屏
					MOV		R7,#0   ;控制页数0-7，共8页
CLR_K1:				MOV		A,R7
					LCALL	SET_PAGE
					MOV		A,#0
					LCALL	SET_COLUMN
					MOV		R6,#0	;控制列数0-63，共64列
					CLR		A	;0
CLR_K0:				LCALL	WRITE_DR;写入0，地址指针自加1
					INC		R6
					CJNE	R6,#64,CLR_K0
					INC		R7
					CJNE	R7,#8,CLR_K1
					RET
;;;;;;;;;;;;;;;;;;;;;;;;;LCD的初始化
INIT_LCD:			LCALL	CHEC_BUSY
					CLR		A;选择全屏
					LCALL	SELECT_SCREEN
					CLR		A;关闭显示
					LCALL	SET_ON_OFF
					CLR		A;选择全屏
					LCALL	SELECT_SCREEN
					MOV		A,#01H;开启显示
					LCALL	SET_ON_OFF
					CLR		A;选择全屏
					LCALL	SELECT_SCREEN
					CLR		A;清屏
					LCALL	CLEAR_SCREEN
					CLR		A;开始行0
					LCALL	SET_LINE	
					RET
;;;;;;;;;;;;;;;;;;;;;;;;;显示汉字子程序
DISPLAY_LCD:;R5传入清那半屏,R6传入页,R7传入列，DPTR传入字模表
					MOV		A,R5
					LCALL	SELECT_SCREEN;选择屏幕
					MOV		A,R6
					LCALL	SET_PAGE;选上半页
					MOV		A,R7
					LCALL	SET_COLUMN;控制列
					MOV		R5,#0  ;控制16列的数据输出
DISP_K0:			MOV		A,R5
					MOVC	A,@A+DPTR
					LCALL	WRITE_DR;选择查出的字模
					INC		R5
					CJNE	R5,#12,DISP_K0

					MOV		A,R6
					INC		A
					LCALL	SET_PAGE;选下半页
					MOV		A,R7
					LCALL	SET_COLUMN;控制列
					MOV		R5,#0  ;控制16列的数据输出
DISP_K1:			MOV		A,R5
					ADD		A,#12
					MOVC	A,@A+DPTR
					LCALL	WRITE_DR;选择查出的字模
					INC		R5
					CJNE	R5,#12,DISP_K1
					RET
;;;;;;;;;;;;;;;;;;;;;;;;;显示BMP图片
DISPLAY_BMP:;DPTR为图片取模表首址
					MOV		R7,#0
DISP_BMP_K2:		MOV		A,#1
					LCALL	SELECT_SCREEN;选择左半屏
					MOV		A,R7
					LCALL	SET_PAGE;选择页
					CLR		A
					LCALL	SET_COLUMN;选择第0列
					MOV		R6,#0
DISP_BMP_K0:		CLR		A;
					MOVC	A,@A+DPTR
					LCALL	WRITE_DR;每隔一行取一次数组中的数据
					INC		R6
					INC		DPTR
					CJNE	R6,#64,DISP_BMP_K0
					MOV		A,#2
					LCALL	SELECT_SCREEN;选择右半屏
					MOV		A,R7
					LCALL	SET_PAGE;选择页
					CLR		A
					LCALL	SET_COLUMN;选择第0列
					MOV		R6,#0
DISP_BMP_K1:		CLR		A;
					MOVC	A,@A+DPTR
					LCALL	WRITE_DR;每隔一行取一次数组中的数据
					INC		R6
					INC		DPTR
					CJNE	R6,#64,DISP_BMP_K1
					INC		R7
					CJNE	R7,#8,DISP_BMP_K2
					RET
;;;;;;;;;;;;;;;;;;;;;;;;;
	END