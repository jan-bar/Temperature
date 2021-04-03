PUBLIC DS1302_INIT,SET1302,GET1302,WRITE1302,READ1302
;;;;;;;;;;;;;;;;;;;;;;;;;
CODE_DS1302 SEGMENT CODE
T_CLK 		BIT P1.3
T_IO		BIT P1.4
T_RST		BIT P1.2
SECOND		EQU 30H
MINUTE		EQU 31H
HOUR		EQU 32H
DAY			EQU 33H
MONTH		EQU 34H
WEEK		EQU 35H
YEAR		EQU 36H
;;;;;;;;;;;;;;;
RSEG CODE_DS1302
;;;;;;;;;;;;;;
DS1302_INIT:		CLR		T_CLK
					CLR		T_RST
					NOP
					NOP
					SETB 	T_RST		   ;复位操作
					MOV 	R1,#80H		   ;写秒寄存器
					MOV 	R0,#00H		   ;启动振荡器
					LCALL 	WRITE1302
					MOV 	R1,#90H		   ;写充电寄存器
					MOV 	R0,#0ABH	   ;使TCS为1010，DS为10，RS为11
					LCALL 	WRITE1302 
					RET
;;;;;;;;;;;;;;
GET1302:			MOV 	R1,#81H
					LCALL	READ1302
					MOV		SECOND,R0
					;;;;;;;;;;;
					MOV 	R1,#83H
					LCALL	READ1302
					MOV		MINUTE,R0
					;;;;;;;;;;;
					MOV 	R1,#85H
					LCALL	READ1302
					MOV		HOUR,R0
					;;;;;;;;;;;
					MOV 	R1,#87H
					LCALL	READ1302
					MOV		DAY,R0
					;;;;;;;;;;;
					MOV 	R1,#89H
					LCALL	READ1302
					MOV		MONTH,R0
					;;;;;;;;;;;
					MOV 	R1,#8BH
					LCALL	READ1302
					MOV		WEEK,R0
					;;;;;;;;;;;
					MOV 	R1,#8DH
					LCALL	READ1302
					MOV		YEAR,R0
					;;;;;;;;;;;
					RET
;;;;;;;;;;;;;;
SET1302:			MOV 	R1,#80H	 
					MOV		R0,SECOND
					LCALL	WRITE1302					
					;;;;;;;;;;;
					MOV 	R1,#82H	
					MOV		R0,MINUTE
					LCALL	WRITE1302					
					;;;;;;;;;;;
					MOV 	R1,#84H	
					MOV		R0,HOUR
					LCALL	WRITE1302					
					;;;;;;;;;;;
					MOV 	R1,#86H	   
					MOV		R0,DAY
					LCALL	WRITE1302			
					;;;;;;;;;;;
					MOV 	R1,#88H		
					MOV		R0,MONTH
					LCALL	WRITE1302	
					;;;;;;;;;;;
					MOV 	R1,#8AH	 
					MOV		R0,WEEK
					LCALL	WRITE1302
					;;;;;;;;;;;
					MOV 	R1,#8CH	  
					MOV		R0,YEAR
					LCALL	WRITE1302	
					;;;;;;;;;;;
					RET
;;;;;;;;;;;;;;以下为写地址和寄存器，R1内容为地址，R0为寄存器内容
WRITE1302:			CLR		T_CLK
					NOP
					NOP
					SETB 	T_RST
					NOP
					MOV 	A,R1
					MOV 	R2,#8
WRI_0:				RRC		A		;使一位一位的进入进位位C
					NOP
					NOP
					CLR 	T_CLK
					NOP
					NOP
					MOV 	T_IO,C
					NOP
					NOP
					SETB	T_CLK
					NOP
					NOP
					DJNZ	R2,WRI_0
					CLR		T_CLK
					NOP
					NOP
					MOV 	A,R0
					MOV 	R2,#8
WRI_1:				RRC		A
					NOP
					NOP
					CLR 	T_CLK
					NOP
					NOP
					MOV		T_IO,C
					NOP
					NOP
					SETB 	T_CLK
					NOP
					NOP
					DJNZ	R2,WRI_1
					CLR		T_CLK
					NOP
					NOP
					CLR		T_RST
					NOP
					NOP
					RET
;;;;;;;;;;;;;;
READ1302:			CLR		T_CLK
					NOP
					NOP
					SETB 	T_RST
					NOP
					NOP
					MOV 	A,R1	;写地址
					MOV 	R2,#8
REA_0:				RRC		A		;使一位一位的进入进位位C
					NOP
					NOP
					CLR 	T_CLK
					NOP
					NOP
					MOV 	T_IO,C
					NOP
					NOP
					SETB	T_CLK
					NOP
					NOP
					DJNZ	R2,REA_0
					NOP
					NOP
					SETB 	T_IO
					CLR		A		;清寄存器
					CLR		C
					MOV 	R2,#8
REA_1:				CLR 	T_CLK
					NOP
					NOP
					MOV		C,T_IO
					NOP
					NOP
					RRC		A		 ;读内容
					NOP
					NOP
					SETB 	T_CLK
					NOP
					NOP
					DJNZ	R2,REA_1
					MOV		R0,A
					CLR		T_RST
					NOP
					NOP
					RET
;;;;;;;;;;;;;;;
	END
