;------------------------------------
;-  Generated Initialization File  --
;------------------------------------		 

$include   (c8051F310.inc) 

   		ORG 0000H
 		LJMP MAIN

		ORG 000BH
		LJMP T0I0

		ORG 001BH
		LJMP T1I1

		ORG 0200H
MAIN:	LCALL Init_Device
      
        CLR P2.6		    ;指示电源，常亮
		CLR P0.4		    ;驱动红外发光	  
        SETB P0.5 

        MOV ADC0CF,#0F8H    ;转换时钟保持默认，AD0LJST取1设置为左对齐
		MOV AMX0N,#1FH      ;负输入取为GND
		MOV AMX0P,#13H      ;正输入取为P3.3,即DC输入
				 
		MOV	R0,#40H         ;R0指向存交流信号的首地址 
		MOV R2,#64       	;采样次数标记位
		MOV R3,#2
		MOV R4,#6           ;右移标记位

		LCALL SMG1

		MOV 24H,#0FFH
		MOV 38H,#0
		MOV 39H,#0
		MOV 2AH,#0
		MOV 2BH,#64

	    MOV TMOD,#11H
		MOV TH0,#131
		MOV TL0,#99
		MOV TH1,#131
		MOV TL1,#99

		SETB ET0
		SETB ET1
		SETB EA
;-----------------按键S2控制开始采样-------------------------
WAIT:   JNB P2.7,WAIT         ;KEY2是否按下       
    	LCALL DEL10MS
		JB P2.7,WAIT
		CLR P2.5
		SETB AD0EN           ;AD使能
		SETB AD0BUSY         ;启动AD

AD1:	JNB AD0INT,AD1       ;AD转换是否完成
        MOV 21H,0BDH         ;红外光时直流分量存入21H单元
		CLR AD0INT

		CLR P0.5			 ;切换为红光
		SETB P0.4      

		LCALL DEL500MS       ;等待10ms（该时间需进一步论证）
		SETB AD0BUSY         ;启动AD

AD2:    JNB AD0INT,AD2
        MOV 22H,0BDH         ;红光时直流分量存入22H单元
		CLR AD0INT

		MOV AMX0P,#14H       ;正输入取为P3.4，即AC输入
		SETB TR0             ;开始定时

STOP1:  MOV A,R2
        JNZ STOP1
		CLR C
		MOV A,23H
		SUBB A,24H
		MOV 25H,A            ;算出红光的交流峰峰值，存入25H
		
		MOV 23H,#0
		MOV 24H,#0FFH
					
		CLR P0.4
		SETB P0.5            ;切换为红外光
		SETB TR0             ;开始定时
		MOV R2,#64

STOP2:  MOV A,R2
        JNZ STOP2
		CLR C
		MOV A,23H
		SUBB A,24H
		MOV 26H,A            ;算出红外光的交流峰峰值，存入26H
		MOV 23H,#0

CF1:    MOV A,22H
        MOV B,21H
        DIV AB
        JZ A1                ;A若等于零则第一式的个位为0；
        MOV 2FH,A            ;46H存第一式的个位。

A1:     MOV 2CH,B
        MOV A,#10
        MUL AB
        MOV 2DH,A            ;44H存低位
        MOV 2EH,B            ;45H存高位
		MOV A,2EH
		ADD A,#1
		MOV 2EH,A
		MOV A,2DH

A2:     SUBB A,21H
        JC A3                ;若C=1,则说明有借位，跳到A3，若C=0，则说明没有借位继续减
        INC R1               ;R1即为小数点后一位数字。
        SJMP A2

A3:     DJNZ 2EH,A2          ;每当向高位有借位时。高位减一，同时低位再次进行减法
        MOV 3AH,R1
        SJMP CF2

CF2:    MOV R1,#0
        MOV A,26H
        MOV B,25H
        DIV AB
        JZ B1                ;A若等于零则第一式的个位为0；
        MOV 3EH,A            ;51H存第一式的个位。

B1:     MOV 3BH,B
        MOV A,#10
        MUL AB
        MOV 3CH,A            ;49H存低位
        MOV 3DH,B            ;50H存高位
		MOV A,3DH;
		ADD A,#1;
		MOV 3DH,A
		MOV A,3CH;

B2:     SUBB A,25H
        JC B3                ;若C=1,则说明有借位，跳到A3，若C=0，则说明没有借位继续减
        INC R1               ;R1即为小数点后一位数字。
        SJMP B2

B3:     DJNZ 3DH,B2          ;每当向高位有借位时。高位减一，同时低位再次进行减法
        MOV 3FH,R1
        SJMP MULTI

MULTI:  MOV A,2FH
        MOV B,#10
        MUL AB
        ADD A,3AH
        MOV 23H,A
        MOV A,3EH
        MOV B,#10
        MUL AB
        ADD A,3FH             ;第二个值对应的数乘十
        MOV B,23H 
        MUL AB                ;由于实验的相关数据我们可以粗略计算得到乘积一定不会大于255
		MOV B,#3
		MUL AB
		MOV B,#10
		DIV AB                ;得到十位和个位，小数点后一位舍弃
		MOV B,#10
		DIV AB
		MOV 21H,A             ;十位存在21H
		MOV 22H,B             ;个位存在22H
	    MOV A,#96             ;定标算法
		SUBB A,21H            ;得到百位和十位数据
    	MOV 25H,A             ;存在25H
		MOV A,#9
		SUBB A,22H            ;得到个位数据
		MOV 37H,A             ;个位数据给37H
	    MOV B,#10
		MOV A,25H
		DIV AB
		MOV 35H,A             ;百位数据给35H
		MOV 36H,B             ;十位数据给36H
		SETB P2.4

		SETB TR1              ;开始定时

		CLR P2.4
        MOV R2,#64

STOP3:  MOV A,R2
        JNZ STOP3
		MOV R0,#40H
		MOV A,38H

C2:     CLR C
        RRC A
        DJNZ R4,C2
        MOV 38H,A
		MOV R4,#6
        MOV A,39H

C3:     RR A
        DJNZ R4,C3
        ADD A,38H
        MOV 2AH,#00
		SUBB A,2AH                   ;平均值减40
		MOV 2AH,A
        MOV R1,#0

		MOV R2,#64
PJ:     MOV A,@R0					  ;判决，如果A大于等于2AH，则判为1，否则判为0
        CJNE A,2AH,PJ1
		MOV @R0,#1
		INC R0
		DJNZ R2,PJ
		SJMP TB

PJ1:    JC PJ2
        MOV @R0,#1
		INC R0
		DJNZ R2,PJ
		SJMP TB

PJ2:    MOV @R0,#0
        INC R0
		DJNZ R2,PJ
		SJMP TB
		
TB:     MOV R2,#64
        MOV R0,#40H
		MOV R1,#40H
    	MOV A,@R0
		JNZ TB2				  ;第一个数为1，跳转到TB2
		INC R0
		DEC R2

TB1:	MOV A,@R0			  ;从0开始，遇到1时记下跳变时刻
		JNZ TB3
		INC R0
		DJNZ R2,TB1
		SJMP SJ

TB2:	INC R0
        DEC R2
		MOV A,@R0
		JNZ TB2
		SJMP TB1
		
TB3:    MOV A,R0			   ;第一个0到1跳变时刻存入R1指向位置
        MOV @R1,A
		INC R1
		INC R0

TB4:	MOV A,@R0
		JZ TB1
		INC R0
		DJNZ R2,TB4

SJ:     CLR C 
        MOV R1,#41H
		MOV R0,#50H
		MOV R2,#5
SJ1:	MOV A,@R1
		SUBB A,40H
		MOV @R0,A
		INC R0
		INC R1
		DJNZ R2,SJ1

		CLR C
		MOV R1,#42H
		MOV R2,#4
SJ2:	MOV A,@R1
        SUBB A,41H
		MOV @R0,A
		INC R0
		INC R1
		DJNZ R2,SJ2

		CLR C
		MOV R1,#43H
		MOV R2,#3
SJ3:	MOV A,@R1
        SUBB A,42H
		MOV @R0,A
		INC R0
		INC R1
		DJNZ R2,SJ3

		CLR C
		MOV R1,#44H
		MOV R2,#2
SJ4:	MOV A,@R1
        SUBB A,43H
		MOV @R0,A
		INC R0
		INC R1
		DJNZ R2,SJ4
		
		CLR C
		MOV R1,#45H
		MOV R2,#1
SJ5:	MOV A,@R1
        SUBB A,44H
		MOV @R0,A
		INC R0
		INC R1
		DJNZ R2,SJ5

SJ6:    MOV R0,#50H
        MOV R1,#40H
        MOV R2,#15
D1:		MOV A,@R0
		CJNE A,#8,D2
		MOV @R1,A
		INC R0
		INC R1
		DJNZ R2,D1
		SJMP SJA

D2:		JC D3
        CJNE A,#16,D4
		MOV @R1,A
		INC R0
		INC R1
		DJNZ R2,D1
		SJMP SJA
      
D3:     INC R0
        DJNZ R2,D1
		SJMP SJA

D4:     JC D5
        INC R0
		DJNZ R2,D1
		SJMP SJA

D5:     MOV @R1,A
        INC R0
		INC R1
		DJNZ R2,D1
		SJMP SJA
           		      		
SJA:   	MOV A,40H
        ADD A,41H
		ADD A,42H
		ADD A,43H

        MOV R5,#0FH
        MOV R4,#00H
		MOV R3,#00h
		MOV R2,A
        CLR A
        MOV R7,A
		MOV R6,A
		MOV B,#10H
DIVA:   CLR C
        MOV A,R4
		RLC A
		MOV R4,A
		MOV A,R5
		RLC A
		MOV R5,A
		MOV A,R6
		RLC A
		MOV R6,A
		XCH A,R7
		RLC A
		XCH A,R7
		SUBB A,R2
		MOV R1,A
		MOV A,R7
		SUBB A,R3
		JC DIVB
		INC R4
		MOV R7,A
		MOV A,R1
		MOV R6,A
DIVB:   DJNZ B,DIVA
        CLR OV

		MOV A,R4
		CJNE A,#55,SJB
SJB:    JC ALARM1
		MOV B,#100
		DIV AB
		MOV 32H,A
		MOV A,B
		MOV B,#10
		DIV AB
		MOV 33H,A
		MOV 34H,B

		LCALL SMG	

ALARM1: CLR P2.3
        MOV P1,#0FDH
		SETB P2.1
		MOV A,#79H
		CLR P2.1
		MOV P1,A
		SETB P2.0
		LCALL DEL
		CLR P2.0
	
		MOV P1,#0FBH
	    SETB P2.1
		MOV A,#31H
		CLR P2.1
		MOV P1,A
		SETB P2.0
		LCALL DEL
		CLR P2.0

		MOV P1,#0F7H
		SETB P2.1
		MOV A,#31H
		CLR P2.1
		MOV P1,A
		SETB P2.0
		LCALL DEL
		CLR P2.0
		SJMP ALARM1


T0I0:   SETB AD0BUSY                ;定时时间到，启动AD
AD3:    JNB AD0INT,AD3              ;AD转换是否完成													  
        MOV A,0BDH                  ;将采到的值存入A中	   
		CLR AD0INT
		CLR C
		CJNE A,23H,NEXT1	        ;找最大值
		MOV 23H,A
NEXT1:  JNC NEXT2
        SJMP CP2
NEXT2:  MOV 23H,A                   ;若当次采得的数大于当前的23H，替换之
CP2:    CLR C
        CJNE A,24H,NEXT3            ;找最小值
		MOV 24H,A
NEXT3:	JC NEXT4
        SJMP NEXT5
NEXT4:  MOV 24H,A                   ;若当次采得的数小于当前的24H，替换之
NEXT5:	DJNZ R2,AA
		CLR TR0
AA:     MOV TH0,#131
        MOV TL0,#99
        RETI
		     
T1I1:   DJNZ R3,BB
        SETB AD0BUSY                 ;定时时间到，启动AD
AD4:    JNB AD0INT,AD4               ;AD转换是否完成
        MOV @R0,0BDH                 ;将采到的值存入R0指向的地址中
		CLR AD0INT
		MOV A,38H
		ADD A,@R0
		MOV 38H,A
		JNC C1
		MOV A,39H
		INC A
		MOV 39H,A
		CLR C
C1:		INC R0
		MOV R3,#2
		DJNZ R2,BB
		CLR TR1
BB:     MOV TH1,#131
        MOV TL1,#99
		RETI 

DEL:	MOV 29H,#30	                  ;延时10ms
DEL1:   MOV 28H,#66
DEL2:   DJNZ 28H,DEL2
        DJNZ 29H,DEL1
        RET

DEL10MS:MOV 29H,#150	              ;延时10ms
DEL21:  MOV 28H,#66
DEL22:  DJNZ 28H,DEL22
        DJNZ 29H,DEL21
        RET

DEL500MS:MOV 29H,#255                 ;延时500ms
DEL31:   MOV 28H,#120
DEL32:   MOV 27H,#15
DEL33:   DJNZ 27H,DEL33
         DJNZ 28H,DEL32
         DJNZ 29H,DEL31
         RET

SMG:   	MOV DPTR,#TABLE				   ;给DPTR赋表项初始值
		MOV 60H,#0AH
		MOV 61H,#0BH

HERE:	CLR P2.0
        CLR P2.1

		MOV P1,#0FEH  					;选择数码管
        SETB P2.1

        MOV A,60H
        MOVC A,@A+DPTR					;查表程序入口
		CLR P2.1				   
	    MOV P1,A
		SETB P2.0					    ;将A中的值输出
		LCALL DEL
		CLR P2.0

		MOV P1,#0FDH
		SETB P2.1

		MOV A,35H
		MOVC A,@A+DPTR
	
		CLR P2.1
		MOV P1,A
		SETB P2.0
		LCALL DEL
		CLR P2.0
	
		MOV P1,#0FBH
	    SETB P2.1

		MOV A,36H
		MOVC A,@A+DPTR	 
		ADD A,#80H
		CLR P2.1
		MOV P1,A
		SETB P2.0
		LCALL DEL
		CLR P2.0

		MOV P1,#0F7H
		SETB P2.1

		MOV A,37H
		MOVC A,@A+DPTR
		CLR P2.1
		MOV P1,A
		SETB P2.0
		LCALL DEL
		CLR P2.0

        JB P2.7,HERE                       ;KEY2是否按下
        LCALL DEL10MS
		LCALL DEL10MS
		JB P2.7,H0
H0:     LCALL DEL10MS
        LCALL DEL10MS
        JNB P2.7,HERE
		
HERE1:  MOV P1,#0FEH  					   ;选择数码管
        SETB P2.1

        MOV A,61H
        MOVC A,@A+DPTR					   ;查表程序入口
		CLR P2.1				   
	    MOV P1,A
		SETB P2.0					       ;将A中的值输出
		LCALL DEL
		CLR P2.0
        
		MOV P1,#0FDH
		SETB P2.1

		MOV A,32H
		MOVC A,@A+DPTR
		CLR P2.1
		MOV P1,A
		SETB P2.0
		LCALL DEL
		CLR P2.0
	
		MOV P1,#0FBH
	    SETB P2.1

		MOV A,33H
		MOVC A,@A+DPTR 
		CLR P2.1
		MOV P1,A
		SETB P2.0
		LCALL DEL
		CLR P2.0

		MOV P1,#0F7H
		SETB P2.1

		MOV A,34H
		MOVC A,@A+DPTR
		CLR P2.1
		MOV P1,A
		SETB P2.0
		LCALL DEL
		CLR P2.0

        JB P2.7,HERE1                       ;KEY2是否按下
        LCALL DEL10MS
		LCALL DEL10MS
		JB P2.7,H1
H1:		LCALL DEL10MS
        LCALL DEL10MS
		JNB P2.7,HERE1

		LJMP HERE

SMG1:   MOV R7,#255
        MOV P1,#0F7H  					   ;选择数码管
        SETB P2.1
        MOV A,#76H        					   
		CLR P2.1				   
	    MOV P1,A
		SETB P2.0					       ;将A中的值输出
		LCALL DEL
		CLR P2.0 
		LCALL DEL500MS
		LCALL DEL500MS
		      
HERE2:	MOV P1,#0FBH
		SETB P2.1

		MOV A,#76H	
		CLR P2.1
		MOV P1,A
		SETB P2.0
		LCALL DEL
		CLR P2.0
	
		MOV P1,#0F7H
	    SETB P2.1
		MOV A,#79H 
		CLR P2.1
		MOV P1,A
		SETB P2.0
		LCALL DEL
		CLR P2.0
		DJNZ R7,HERE2
		MOV R7,#255

HERE3: 	MOV P1,#0FDH
		SETB P2.1
		MOV A,#76H
		CLR P2.1
		MOV P1,A
		SETB P2.0
		LCALL DEL
		CLR P2.0
	
		MOV P1,#0FBH
	    SETB P2.1
		MOV A,#79H
		CLR P2.1
		MOV P1,A
		SETB P2.0
		LCALL DEL
		CLR P2.0

		MOV P1,#0F7H
		SETB P2.1
		MOV A,#30H
		CLR P2.1
		MOV P1,A
		SETB P2.0
		LCALL DEL
		CLR P2.0
		DJNZ R7,HERE3
		MOV R7,#255

HERE4: 	MOV P1,#0FDH
		SETB P2.1
		MOV A,#76H
		CLR P2.1
		MOV P1,A
		SETB P2.0
		LCALL DEL
		CLR P2.0
	
		MOV P1,#0FBH
	    SETB P2.1
		MOV A,#79H
		CLR P2.1
		MOV P1,A
		SETB P2.0
		LCALL DEL
		CLR P2.0

		MOV P1,#0F7H
		SETB P2.1
		MOV A,#36H
		CLR P2.1
		MOV P1,A
		SETB P2.0
		LCALL DEL
		CLR P2.0
		DJNZ R7,HERE4
		MOV R7,#255
		MOV R6,#2

HERE5:	MOV P1,#0FEH  					;选择数码管
        SETB P2.1
        MOV A,#76H
		CLR P2.1				   
	    MOV P1,A
		SETB P2.0					    ;将A中的值输出
		LCALL DEL
		CLR P2.0

		MOV P1,#0FDH
		SETB P2.1
		MOV A,#79H
		CLR P2.1
		MOV P1,A
		SETB P2.0
		LCALL DEL
		CLR P2.0
	
		MOV P1,#0FBH
	    SETB P2.1
		MOV A,#36H
		CLR P2.1
		MOV P1,A
		SETB P2.0
		LCALL DEL
		CLR P2.0

		MOV P1,#0F7H
		SETB P2.1
		MOV A,#3FH
		CLR P2.1
		MOV P1,A
		SETB P2.0
		LCALL DEL
		CLR P2.0
		DJNZ R7,HERE5
		MOV R7,#255
		DJNZ R6,HERE5
		RET

TABLE:  DB 3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH		;字形代码表
		DB 6FH,77H,7CH,39H,5EH,79H,71H

				
PCA_Init:
    anl  PCA0MD,    #0BFh
    mov  PCA0MD,    #000h
    ret

Timer_Init:
    mov  TMOD,      #011h
    ret

Voltage_Reference_Init:
    mov  REF0CN,    #00Ah
    ret

Port_IO_Init:
    ; P0.0  -  Unassigned,  Open-Drain, Digital
    ; P0.1  -  Unassigned,  Open-Drain, Digital
    ; P0.2  -  Unassigned,  Open-Drain, Digital
    ; P0.3  -  Unassigned,  Open-Drain, Digital
    ; P0.4  -  Unassigned,  Push-Pull,  Digital
    ; P0.5  -  Unassigned,  Push-Pull,  Digital
    ; P0.6  -  Unassigned,  Open-Drain, Digital
    ; P0.7  -  Unassigned,  Open-Drain, Digital

    ; P1.0  -  Unassigned,  Push-Pull,  Digital
    ; P1.1  -  Unassigned,  Push-Pull,  Digital
    ; P1.2  -  Unassigned,  Push-Pull,  Digital
    ; P1.3  -  Unassigned,  Push-Pull,  Digital
    ; P1.4  -  Unassigned,  Push-Pull,  Digital
    ; P1.5  -  Unassigned,  Push-Pull,  Digital
    ; P1.6  -  Unassigned,  Push-Pull,  Digital
    ; P1.7  -  Unassigned,  Push-Pull,  Digital
    ; P2.0  -  Unassigned,  Push-Pull,  Digital
    ; P2.1  -  Unassigned,  Push-Pull,  Digital
    ; P2.2  -  Unassigned,  Open-Drain, Digital
    ; P2.3  -  Unassigned,  Push-Pull,  Digital

    mov  P3MDIN,    #0E7h
    mov  P0MDOUT,   #030h
    mov  P1MDOUT,   #0FFh
    mov  P2MDOUT,   #0FBh
    mov  XBR1,      #040h
    ret

Oscillator_Init:
    mov  OSCICN,    #082h
    ret

; Initialization function for device,
; Call Init_Device from your main program
Init_Device:
    lcall PCA_Init
    lcall Timer_Init
    lcall Voltage_Reference_Init
    lcall Port_IO_Init
    lcall Oscillator_Init
    ret

end