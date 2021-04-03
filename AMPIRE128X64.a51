PUBLIC		SET_LINE,DISPLAY_BMP,DISPLAY_LCD,CLEAR_SCREEN,CLR_LCD,INIT_LCD,SELECT_SCREEN
CODE_LCD	SEGMENT		CODE
LCD_RS		BIT			P2.2
LCD_RW		BIT			P2.1
LCD_E		BIT			P2.0
LCD_CS1		BIT			P2.4	;�͵�ƽ��Ч�������
LCD_CS2		BIT			P2.3	;�͵�ƽ��Ч���Ұ���
;;;;;;;;;;;;;;;;;;;;;;;;;
RSEG		CODE_LCD
;;;;;;;;;;;;;;;;;;;;;;;;;���æ�ȴ�
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
					MOV		P0,A	;P0��Ϊ���ݿ�
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
;;;;;;;;;;;;;;;;;;;;;;;;;����"ҳ"LCD12864��8ҳ��һҳ��8�е����
SET_PAGE:			ORL		A,#0B8H	;ҳ���׵�ַΪ0xB8
					LCALL	WRITE_IR
					RET
;;;;;;;;;;;;;;;;;;;;;;;;;������ʾ����ʼ��
SET_LINE:			ORL		A,#0C0H ;��ʼ�е�ַΪ0xC0
					LCALL	WRITE_IR;���ô����п�ʼ����0--63;һ���0 �п�ʼ��ʾ
					RET
;;;;;;;;;;;;;;;;;;;;;;;;;������ʾ����
SET_COLUMN:			ANL		A,#3FH  ;�е����ֵΪ64
					ORL		A,#40H  ;�е��׵�ַΪ0x40
					LCALL	WRITE_IR;�涨��ʾ���е�λ��
					RET
;;;;;;;;;;;;;;;;;;;;;;;;;��ʾ���غ�����0x3E�ǹ���ʾ��0x3F�ǿ���ʾ
SET_ON_OFF:			ORL		A,#3EH  ;0011 111x,onoffֻ��Ϊ0����1
					LCALL	WRITE_IR
					RET
;;;;;;;;;;;;;;;;;;;;;;;;;ѡ����Ļ
SELECT_SCREEN:		CJNE	A,#0,SELECTN0
					;0ȫ��
					CLR		LCD_CS1
					CLR		LCD_CS2
					AJMP 	SELECT_END
SELECTN0:			CJNE	A,#1,SELECTN1
					;1�����
					CLR		LCD_CS1
					SETB	LCD_CS2
					AJMP 	SELECT_END
SELECTN1:			CJNE	A,#2,SELECTN2
					;2�Ұ���
					CLR		LCD_CS2
					SETB	LCD_CS1
SELECTN2:
SELECT_END:			RET
;;;;;;;;;;;;;;;;;;;;;;;;;��������
CLEAR_SCREEN:		LCALL	SELECT_SCREEN;0--ȫ����1---�������2---�Ұ���
					MOV		R7,#0   ;����ҳ��0-7����8ҳ
CLR_K1:				MOV		A,R7
					LCALL	SET_PAGE
					MOV		A,#0
					LCALL	SET_COLUMN
					MOV		R6,#0	;��������0-63����64��
					CLR		A	;0
CLR_K0:				LCALL	WRITE_DR;д��0����ַָ���Լ�1
					INC		R6
					CJNE	R6,#64,CLR_K0
					INC		R7
					CJNE	R7,#8,CLR_K1
					RET
;;;;;;;;;;;;;;;;;;;;;;;;;LCD�ĳ�ʼ��
INIT_LCD:			LCALL	CHEC_BUSY
					CLR		A;ѡ��ȫ��
					LCALL	SELECT_SCREEN
					CLR		A;�ر���ʾ
					LCALL	SET_ON_OFF
					CLR		A;ѡ��ȫ��
					LCALL	SELECT_SCREEN
					MOV		A,#01H;������ʾ
					LCALL	SET_ON_OFF
					CLR		A;ѡ��ȫ��
					LCALL	SELECT_SCREEN
					CLR		A;����
					LCALL	CLEAR_SCREEN
					CLR		A;��ʼ��0
					LCALL	SET_LINE	
					RET
;;;;;;;;;;;;;;;;;;;;;;;;;��ʾ�����ӳ���
DISPLAY_LCD:;R5�������ǰ���,R6����ҳ,R7�����У�DPTR������ģ��
					MOV		A,R5
					LCALL	SELECT_SCREEN;ѡ����Ļ
					MOV		A,R6
					LCALL	SET_PAGE;ѡ�ϰ�ҳ
					MOV		A,R7
					LCALL	SET_COLUMN;������
					MOV		R5,#0  ;����16�е��������
DISP_K0:			MOV		A,R5
					MOVC	A,@A+DPTR
					LCALL	WRITE_DR;ѡ��������ģ
					INC		R5
					CJNE	R5,#12,DISP_K0

					MOV		A,R6
					INC		A
					LCALL	SET_PAGE;ѡ�°�ҳ
					MOV		A,R7
					LCALL	SET_COLUMN;������
					MOV		R5,#0  ;����16�е��������
DISP_K1:			MOV		A,R5
					ADD		A,#12
					MOVC	A,@A+DPTR
					LCALL	WRITE_DR;ѡ��������ģ
					INC		R5
					CJNE	R5,#12,DISP_K1
					RET
;;;;;;;;;;;;;;;;;;;;;;;;;��ʾBMPͼƬ
DISPLAY_BMP:;DPTRΪͼƬȡģ����ַ
					MOV		R7,#0
DISP_BMP_K2:		MOV		A,#1
					LCALL	SELECT_SCREEN;ѡ�������
					MOV		A,R7
					LCALL	SET_PAGE;ѡ��ҳ
					CLR		A
					LCALL	SET_COLUMN;ѡ���0��
					MOV		R6,#0
DISP_BMP_K0:		CLR		A;
					MOVC	A,@A+DPTR
					LCALL	WRITE_DR;ÿ��һ��ȡһ�������е�����
					INC		R6
					INC		DPTR
					CJNE	R6,#64,DISP_BMP_K0
					MOV		A,#2
					LCALL	SELECT_SCREEN;ѡ���Ұ���
					MOV		A,R7
					LCALL	SET_PAGE;ѡ��ҳ
					CLR		A
					LCALL	SET_COLUMN;ѡ���0��
					MOV		R6,#0
DISP_BMP_K1:		CLR		A;
					MOVC	A,@A+DPTR
					LCALL	WRITE_DR;ÿ��һ��ȡһ�������е�����
					INC		R6
					INC		DPTR
					CJNE	R6,#64,DISP_BMP_K1
					INC		R7
					CJNE	R7,#8,DISP_BMP_K2
					RET
;;;;;;;;;;;;;;;;;;;;;;;;;
	END