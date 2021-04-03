PUBLIC	HEX_BCD,READ_TEMP
CODE_DS18B20	SEGMENT 	CODE
TEMP_ZH		EQU			3BH			 ;ʵ���¶�ֵ��ŵ�Ԫ�������ͱ����¶�ֵ�Ƚ�
TEMPL		EQU			3CH			 ;�¶�ֵ��λ
TEMPH		EQU			3DH			 ;�¶�ֵ��λ
TEMP_TH		EQU			3EH			 ;���±���ֵ
TEMP_TL		EQU			3FH			 ;���±���ֵ
FLAG		BIT			20H.0		 ;DS18B20�Ƿ���ڱ��
DQ			BIT			P1.5		 ;DS18B20���ݽŶ���
TEMPHC		EQU			40H			 ;�¶�ת����8λ	
TEMPLC		EQU			41H			 ;�¶�ת����8λ
;;;;;;;;;;;;;;;;;;
RSEG	CODE_DS18B20
;;;;;;;;;;;;;;;
REST_DS18B20:		;��λ����
					SETB	DQ
					NOP
					NOP
					CLR		DQ
					MOV		R1,#3	  ;��ʱ500us��λ������
DLY:				MOV		R0,#107
					DJNZ	R0,$
					DJNZ	R1,DLY
					SETB	DQ
					NOP
					NOP
					NOP
					MOV		R0,#25H
RST2:				JNB		DQ,RST3		;�ȴ�DS18B20��Ӧ
					DJNZ	R0,RST2
					LJMP	RST4
RST3:				SETB	FLAG		;�ñ�־λ��֤��DS18B20����
					LJMP	RST5
RST4:				CLR		FLAG		;���־λ��֤��DS18B20������
					LJMP	RST7
RST5:				MOV		R0,#117
RST6:				DJNZ	R0,RST6
RST7:				SETB	DQ			;Ҫ����ʱһ��ʱ��
					RET
;;;;;;;;;;;;;;;
WRITE_DS18B20:		;дDS18B20����
					MOV		R2,#8
					CLR		C
WR1:				CLR		DQ			;���ߵ�λ��ʼд��
					MOV		R3,#6
					DJNZ	R3,$		;����16usʱ��
					RRC		A			;�����ݴ�A��һλһλ��д��
					MOV		DQ,C
					MOV		R3,#23
					DJNZ	R3,$
					SETB 	DQ
					NOP
					DJNZ	R2,WR1
					SETB	DQ
					RET
;;;;;;;;;;;;;;;		��DS18B20����
READ_DS18B20:		MOV		R4,#4		;��ȡ4B
					MOV		R1,#TEMPL	;����TEMPL.TEMPH,TEMP_TH,TEMP_TL
READ0:				MOV		R2,#8
READ1:				CLR		C
					SETB	DQ
					NOP
					NOP
					CLR		DQ			;��ǰ��������Ϊ��
					NOP
					NOP
					NOP
					SETB	DQ			;��ʼ�������ͷ�
					MOV		R3,#9
					DJNZ	R3,$		;�ȴ�18us
					MOV		C,DQ
					MOV		R3,#23
					DJNZ	R3,$		;�ȴ�50us
					RRC		A
					DJNZ	R2,READ1
					MOV		@R1,A
					INC		R1
					DJNZ	R4,READ0
					RET
;;;;;;;;;;;;;;;ƥ��ROM���������R7	  
MATCHROM:			MOV		A,#55H
					LCALL	WRITE_DS18B20;����ƥ��ROMָ��
					MOV		R6,#0;ѭ������ROMֵ
					CJNE	R7,#1,MATCH_K1;���͵�һ��DS18B20
					MOV		DPTR,#DS18B20_1
MATCH1:				MOV		A,R6
					MOVC	A,@A+DPTR
					LCALL	WRITE_DS18B20
					INC		R6
					CJNE	R6,#8,MATCH1
					AJMP	MATCHROM_END
					;;;;;;
MATCH_K1:			CJNE	R7,#2,MATCHROM_END;���͵ڶ���DS18B20
					MOV		DPTR,#DS18B20_2
MATCH2:				MOV		A,R6
					MOVC	A,@A+DPTR
					LCALL	WRITE_DS18B20
					INC		R6
					CJNE	R6,#8,MATCH2
					;;;;;;
MATCHROM_END:		RET		
;;;;;;;;;;;;;;;��ȡ�¶Ȳ�ת�������ĸ��¶ȼ���R7����
READ_TEMP:			SETB	DQ
					LCALL	REST_DS18B20
					LCALL	MATCHROM ;ƥ��ROM
					MOV		A,#44H
					LCALL  	WRITE_DS18B20
					;;;;;
					MOV		R5,#0E2H
LOPREA0:			MOV		R6,#0FFH
LOPREA1:			NOP
					DJNZ	R6,LOPREA1
					DJNZ	R5,LOPREA0	  
					;;;;;;��Ҫ����ʱ750ms,��ҪҲ���ԣ�����Ҫע��

					LCALL	REST_DS18B20
					LCALL	MATCHROM  ;ƥ��ROM
					MOV		A,#0BEH
					LCALL  	WRITE_DS18B20
					LCALL	READ_DS18B20
					;;;;;
					;�¶�ת�������
					;;;;;
					MOV		A,TEMPH		 	 ;�ж��¶��Ƿ�����
					ANL		A,#80H
					JZ		TC1				 ;��AΪ0���¶�Ϊ����
					CLR		C
					MOV		A,TEMPL
					CPL		A
					ADD		A,#1
					MOV		TEMPL,A
					MOV		A,TEMPH
					CPL		A
					ADDC	A,#0
					MOV		TEMPH,A
					MOV		TEMPHC,#0
					SJMP	TC2
TC1:				MOV		TEMPHC,#0AH		;����¶�Ϊ�������4λΪA
TC2:				MOV		A,TEMPHC
					SWAP	A
					MOV		TEMPHC,A
					MOV		A,TEMPL			 ;�¶�ֵ���ֽ���A
					ANL		A,#0FH
					MOV		DPTR,#DOTTAB
					MOVC	A,@A+DPTR		 ;���С��
					MOV		TEMPLC,A		 ;С��������TEMPLC
					MOV		A,TEMPL
					ANL		A,#0F0H
					SWAP	A
					MOV		TEMPL,A
					MOV		A,TEMPH
					ANL		A,#0FH
					SWAP	A
					ORL		A,TEMPL
					MOV		TEMP_ZH,A		;����Ϻ��ֵ��TEMP_ZH��ʵ���¶�ֵ��
					LCALL	HEX_BCD			;��ʮ������ת��BCD�����
					MOV		TEMPL,A			;
					ANL		A,#0F0H
					SWAP	A
					ORL		A,TEMPHC
					MOV		TEMPHC,A
					MOV		A,TEMPL
					ANL		A,#0FH
					SWAP	A
					ORL		A,TEMPLC
					MOV		TEMPLC,A
					MOV		A,R6
					JZ		TC3				;��AΪ0���˳�
					ANL		A,#0FH
					SWAP	A
					MOV		R6,A
					MOV		A,TEMPHC
					ANL		A,#0FH
					ORL		A,R6
					MOV		TEMPHC,A
;;;;;;;;��ʱTEMP_ZH��ʮλ�͸�λ�����
;;;;;;;;TEMPHCΪ��λʮλ������λû��ֵ���λΪA
;;;;;;;;TEMPLCΪ��λ��С��λ�����
TC3:				RET
;;;;;;;;;;;;;;;;;;;С���������
DOTTAB:	DB	00H,01H,01H,02H,03H,03H,04H,04H,05H,06H
		DB	06H,07H,08H,08H,09H,09H
;;;;;;;;;;;;;;;;;;;;ʮ������ת��BCD�����
HEX_BCD:			MOV		B,#100
					DIV		AB
					MOV		R6,A
					MOV		A,#10
					XCH		A,B
					DIV		AB
					SWAP	A
					ORL		A,B
					RET
;;;;;;;;;;;;;;;
DS18B20_1: DB	28H,30H,0C5H,0B8H,00H,00H,00H,8EH;ROM1(B8C530)
DS18B20_2: DB	28H,31H,0C5H,0B8H,00H,00H,00H,0B9H;ROM2(B8C531)
	END