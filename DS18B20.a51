PUBLIC	HEX_BCD,READ_TEMP
CODE_DS18B20	SEGMENT 	CODE
TEMP_ZH		EQU			3BH			 ;实际温度值存放单元，用来和报警温度值比较
TEMPL		EQU			3CH			 ;温度值低位
TEMPH		EQU			3DH			 ;温度值高位
TEMP_TH		EQU			3EH			 ;高温报警值
TEMP_TL		EQU			3FH			 ;低温报警值
FLAG		BIT			20H.0		 ;DS18B20是否存在标记
DQ			BIT			P1.5		 ;DS18B20数据脚定义
TEMPHC		EQU			40H			 ;温度转换低8位	
TEMPLC		EQU			41H			 ;温度转换高8位
;;;;;;;;;;;;;;;;;;
RSEG	CODE_DS18B20
;;;;;;;;;;;;;;;
REST_DS18B20:		;复位程序
					SETB	DQ
					NOP
					NOP
					CLR		DQ
					MOV		R1,#3	  ;延时500us复位低脉冲
DLY:				MOV		R0,#107
					DJNZ	R0,$
					DJNZ	R1,DLY
					SETB	DQ
					NOP
					NOP
					NOP
					MOV		R0,#25H
RST2:				JNB		DQ,RST3		;等待DS18B20回应
					DJNZ	R0,RST2
					LJMP	RST4
RST3:				SETB	FLAG		;置标志位。证明DS18B20存在
					LJMP	RST5
RST4:				CLR		FLAG		;清标志位，证明DS18B20不存在
					LJMP	RST7
RST5:				MOV		R0,#117
RST6:				DJNZ	R0,RST6
RST7:				SETB	DQ			;要求延时一段时间
					RET
;;;;;;;;;;;;;;;
WRITE_DS18B20:		;写DS18B20程序
					MOV		R2,#8
					CLR		C
WR1:				CLR		DQ			;总线低位开始写入
					MOV		R3,#6
					DJNZ	R3,$		;保持16us时间
					RRC		A			;把数据从A中一位一位的写入
					MOV		DQ,C
					MOV		R3,#23
					DJNZ	R3,$
					SETB 	DQ
					NOP
					DJNZ	R2,WR1
					SETB	DQ
					RET
;;;;;;;;;;;;;;;		读DS18B20数据
READ_DS18B20:		MOV		R4,#4		;读取4B
					MOV		R1,#TEMPL	;存入TEMPL.TEMPH,TEMP_TH,TEMP_TL
READ0:				MOV		R2,#8
READ1:				CLR		C
					SETB	DQ
					NOP
					NOP
					CLR		DQ			;读前保持总线为低
					NOP
					NOP
					NOP
					SETB	DQ			;开始读总线释放
					MOV		R3,#9
					DJNZ	R3,$		;等待18us
					MOV		C,DQ
					MOV		R3,#23
					DJNZ	R3,$		;等待50us
					RRC		A
					DJNZ	R2,READ1
					MOV		@R1,A
					INC		R1
					DJNZ	R4,READ0
					RET
;;;;;;;;;;;;;;;匹配ROM，传入参数R7	  
MATCHROM:			MOV		A,#55H
					LCALL	WRITE_DS18B20;发送匹配ROM指令
					MOV		R6,#0;循环送入ROM值
					CJNE	R7,#1,MATCH_K1;发送第一个DS18B20
					MOV		DPTR,#DS18B20_1
MATCH1:				MOV		A,R6
					MOVC	A,@A+DPTR
					LCALL	WRITE_DS18B20
					INC		R6
					CJNE	R6,#8,MATCH1
					AJMP	MATCHROM_END
					;;;;;;
MATCH_K1:			CJNE	R7,#2,MATCHROM_END;发送第二个DS18B20
					MOV		DPTR,#DS18B20_2
MATCH2:				MOV		A,R6
					MOVC	A,@A+DPTR
					LCALL	WRITE_DS18B20
					INC		R6
					CJNE	R6,#8,MATCH2
					;;;;;;
MATCHROM_END:		RET		
;;;;;;;;;;;;;;;读取温度并转换，读哪个温度计由R7决定
READ_TEMP:			SETB	DQ
					LCALL	REST_DS18B20
					LCALL	MATCHROM ;匹配ROM
					MOV		A,#44H
					LCALL  	WRITE_DS18B20
					;;;;;
					MOV		R5,#0E2H
LOPREA0:			MOV		R6,#0FFH
LOPREA1:			NOP
					DJNZ	R6,LOPREA1
					DJNZ	R5,LOPREA0	  
					;;;;;;重要的延时750ms,不要也可以，但是要注意

					LCALL	REST_DS18B20
					LCALL	MATCHROM  ;匹配ROM
					MOV		A,#0BEH
					LCALL  	WRITE_DS18B20
					LCALL	READ_DS18B20
					;;;;;
					;温度转换程序段
					;;;;;
					MOV		A,TEMPH		 	 ;判断温度是否零下
					ANL		A,#80H
					JZ		TC1				 ;若A为0则温度为零上
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
TC1:				MOV		TEMPHC,#0AH		;如果温度为正数则高4位为A
TC2:				MOV		A,TEMPHC
					SWAP	A
					MOV		TEMPHC,A
					MOV		A,TEMPL			 ;温度值低字节送A
					ANL		A,#0FH
					MOV		DPTR,#DOTTAB
					MOVC	A,@A+DPTR		 ;查出小数
					MOV		TEMPLC,A		 ;小数部分送TEMPLC
					MOV		A,TEMPL
					ANL		A,#0F0H
					SWAP	A
					MOV		TEMPL,A
					MOV		A,TEMPH
					ANL		A,#0FH
					SWAP	A
					ORL		A,TEMPL
					MOV		TEMP_ZH,A		;将组合后的值送TEMP_ZH（实际温度值）
					LCALL	HEX_BCD			;调十六进制转换BCD码程序
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
					JZ		TC3				;若A为0则退出
					ANL		A,#0FH
					SWAP	A
					MOV		R6,A
					MOV		A,TEMPHC
					ANL		A,#0FH
					ORL		A,R6
					MOV		TEMPHC,A
;;;;;;;;此时TEMP_ZH是十位和个位的组合
;;;;;;;;TEMPHC为百位十位，若百位没有值则百位为A
;;;;;;;;TEMPLC为个位和小数位的组合
TC3:				RET
;;;;;;;;;;;;;;;;;;;小数部分码表
DOTTAB:	DB	00H,01H,01H,02H,03H,03H,04H,04H,05H,06H
		DB	06H,07H,08H,08H,09H,09H
;;;;;;;;;;;;;;;;;;;;十六进制转换BCD码程序
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