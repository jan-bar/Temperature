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
START:				SETB	SDA		;����ʱ�����
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
STOP:				CLR		SDA		   ;����ʱ�����
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
					JC		WAITACK		 ;SDAΪ�͵�ƽ�˳�ѭ��
					CLR		SDA
					CLR		SCL
					RET
;;;;;;;;;;;;;;;;;;;;;;;;;
SENDBYTE:			MOV		R7,#8
S_BYTE:				RLC		A
					MOV		SDA,C
					SETB	SCL		  ;��ʱ���ڷ���
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
;;;;;;;;;;;;;;;;;;;;;;;;;	 ��ָ����ַд��1�ֽ������ӳ���MTDΪ���ݣ�
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