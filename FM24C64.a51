PUBLIC		START,STOP,WAITACK,SENDBYTE,RCVBYTE,WRITE_BYTE,READ_BYTE
CODE_I2C	SEGMENT		CODE
SCL			BIT		P1.0
SDA			BIT		P1.1
SLA			EQU		37H
SUBA		EQU		38H
MTD			EQU		39H
MRD			EQU		3AH
RSEG		CODE_I2C
;;;;;;;;;;;;;;;;;;;;;;;;;
START:				SETB	SDA		;按照时序操作
					SETB	SCL
					NOP
					CLR		SDA
					NOP
					NOP
					NOP
					NOP
					CLR		SCL
					RET
;;;;;;;;;;;;;;;;;;;;;;;;;
STOP:				CLR		SDA		   ;按照时序操作
					NOP
					SETB	SCL
					NOP
					NOP
					NOP
					NOP
					SETB	SDA
					NOP
					NOP
					CLR		SDA
					CLR		SCL
					RET
;;;;;;;;;;;;;;;;;;;;;;;;;
WAITACK:			CLR		SCL
					SETB	SDA
					NOP
					NOP
					SETB	SCL
					NOP
					NOP
					NOP
					MOV		C,SDA
					JC		WAITACK		 ;SDA为低电平退出循环
					CLR		SDA
					CLR		SCL
					RET
;;;;;;;;;;;;;;;;;;;;;;;;;
SENDBYTE:			MOV		R7,#8
S_BYTE:				RLC		A
					MOV		SDA,C
					SETB	SCL		  ;在时序内发送
					NOP
					NOP
					NOP
					NOP
					CLR		SCL
					DJNZ	R7,S_BYTE
					RET
;;;;;;;;;;;;;;;;;;;;;;;;;
RCVBYTE:			MOV		R7,#8
					CLR		A
					SETB	SDA
R_BYTE:				CLR		SCL
					NOP
					NOP
					NOP
					NOP
					SETB	SCL
					NOP
					NOP
					NOP
					NOP
					MOV		C,SDA
					RLC		A
					SETB	SDA
					DJNZ	R7,R_BYTE
					RET
;;;;;;;;;;;;;;;;;;;;;;;;;	 向指定地址写入1字节数据子程序（MTD为数据）
WRITE_BYTE:			ACALL	START
					MOV		A,SLA
					ACALL	SENDBYTE
					ACALL	WAITACK
					MOV		A,SUBA
					ACALL	SENDBYTE
					ACALL	WAITACK
					MOV		A,MTD
					ACALL	SENDBYTE
					ACALL	WAITACK
					ACALL	STOP
					RET
;;;;;;;;;;;;;;;;;;;;;;;;;
READ_BYTE:			ACALL	START
					MOV		A,SLA
					ACALL	SENDBYTE
					ACALL	WAITACK
					MOV		A,SUBA
					ACALL	SENDBYTE
					ACALL	WAITACK
					ACALL	START
					INC		SLA
					MOV		A,SLA
					ACALL	SENDBYTE
					ACALL	WAITACK
					ACALL	RCVBYTE
					ACALL	STOP
					MOV		MRD,A
					RET
;;;;;;;;;;;;;;;;;;;;;;;;;
	END		