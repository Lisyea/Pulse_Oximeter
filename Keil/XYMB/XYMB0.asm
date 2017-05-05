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
      
        CLR P2.6		    ;ָʾ��Դ������
		CLR P0.4		    ;�������ⷢ��	  
        SETB P0.5 

        MOV ADC0CF,#0F8H    ;ת��ʱ�ӱ���Ĭ�ϣ�AD0LJSTȡ1����Ϊ�����
		MOV AMX0N,#1FH      ;������ȡΪGND
		MOV AMX0P,#13H      ;������ȡΪP3.3,��DC����
				 
		MOV	R0,#40H         ;R0ָ��潻���źŵ��׵�ַ 
		MOV R2,#64       	;�����������λ
		MOV R3,#2
		MOV R4,#6           ;���Ʊ��λ

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
;-----------------����S2���ƿ�ʼ����-------------------------
WAIT:   JNB P2.7,WAIT         ;KEY2�Ƿ���       
    	LCALL DEL10MS
		JB P2.7,WAIT
		CLR P2.5
		SETB AD0EN           ;ADʹ��
		SETB AD0BUSY         ;����AD

AD1:	JNB AD0INT,AD1       ;ADת���Ƿ����
        MOV 21H,0BDH         ;�����ʱֱ����������21H��Ԫ
		CLR AD0INT

		CLR P0.5			 ;�л�Ϊ���
		SETB P0.4      

		LCALL DEL500MS       ;�ȴ�10ms����ʱ�����һ����֤��
		SETB AD0BUSY         ;����AD

AD2:    JNB AD0INT,AD2
        MOV 22H,0BDH         ;���ʱֱ����������22H��Ԫ
		CLR AD0INT

		MOV AMX0P,#14H       ;������ȡΪP3.4����AC����
		SETB TR0             ;��ʼ��ʱ

STOP1:  MOV A,R2
        JNZ STOP1
		CLR C
		MOV A,23H
		SUBB A,24H
		MOV 25H,A            ;������Ľ������ֵ������25H
		
		MOV 23H,#0
		MOV 24H,#0FFH
					
		CLR P0.4
		SETB P0.5            ;�л�Ϊ�����
		SETB TR0             ;��ʼ��ʱ
		MOV R2,#64

STOP2:  MOV A,R2
        JNZ STOP2
		CLR C
		MOV A,23H
		SUBB A,24H
		MOV 26H,A            ;��������Ľ������ֵ������26H
		MOV 23H,#0

CF1:    MOV A,22H
        MOV B,21H
        DIV AB
        JZ A1                ;A�����������һʽ�ĸ�λΪ0��
        MOV 2FH,A            ;46H���һʽ�ĸ�λ��

A1:     MOV 2CH,B
        MOV A,#10
        MUL AB
        MOV 2DH,A            ;44H���λ
        MOV 2EH,B            ;45H���λ
		MOV A,2EH
		ADD A,#1
		MOV 2EH,A
		MOV A,2DH

A2:     SUBB A,21H
        JC A3                ;��C=1,��˵���н�λ������A3����C=0����˵��û�н�λ������
        INC R1               ;R1��ΪС�����һλ���֡�
        SJMP A2

A3:     DJNZ 2EH,A2          ;ÿ�����λ�н�λʱ����λ��һ��ͬʱ��λ�ٴν��м���
        MOV 3AH,R1
        SJMP CF2

CF2:    MOV R1,#0
        MOV A,26H
        MOV B,25H
        DIV AB
        JZ B1                ;A�����������һʽ�ĸ�λΪ0��
        MOV 3EH,A            ;51H���һʽ�ĸ�λ��

B1:     MOV 3BH,B
        MOV A,#10
        MUL AB
        MOV 3CH,A            ;49H���λ
        MOV 3DH,B            ;50H���λ
		MOV A,3DH;
		ADD A,#1;
		MOV 3DH,A
		MOV A,3CH;

B2:     SUBB A,25H
        JC B3                ;��C=1,��˵���н�λ������A3����C=0����˵��û�н�λ������
        INC R1               ;R1��ΪС�����һλ���֡�
        SJMP B2

B3:     DJNZ 3DH,B2          ;ÿ�����λ�н�λʱ����λ��һ��ͬʱ��λ�ٴν��м���
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
        ADD A,3FH             ;�ڶ���ֵ��Ӧ������ʮ
        MOV B,23H 
        MUL AB                ;����ʵ�������������ǿ��Դ��Լ���õ��˻�һ���������255
		MOV B,#3
		MUL AB
		MOV B,#10
		DIV AB                ;�õ�ʮλ�͸�λ��С�����һλ����
		MOV B,#10
		DIV AB
		MOV 21H,A             ;ʮλ����21H
		MOV 22H,B             ;��λ����22H
	    MOV A,#96             ;�����㷨
		SUBB A,21H            ;�õ���λ��ʮλ����
    	MOV 25H,A             ;����25H
		MOV A,#9
		SUBB A,22H            ;�õ���λ����
		MOV 37H,A             ;��λ���ݸ�37H
	    MOV B,#10
		MOV A,25H
		DIV AB
		MOV 35H,A             ;��λ���ݸ�35H
		MOV 36H,B             ;ʮλ���ݸ�36H
		SETB P2.4

		SETB TR1              ;��ʼ��ʱ

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
		SUBB A,2AH                   ;ƽ��ֵ��40
		MOV 2AH,A
        MOV R1,#0

		MOV R2,#64
PJ:     MOV A,@R0					  ;�о������A���ڵ���2AH������Ϊ1��������Ϊ0
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
		JNZ TB2				  ;��һ����Ϊ1����ת��TB2
		INC R0
		DEC R2

TB1:	MOV A,@R0			  ;��0��ʼ������1ʱ��������ʱ��
		JNZ TB3
		INC R0
		DJNZ R2,TB1
		SJMP SJ

TB2:	INC R0
        DEC R2
		MOV A,@R0
		JNZ TB2
		SJMP TB1
		
TB3:    MOV A,R0			   ;��һ��0��1����ʱ�̴���R1ָ��λ��
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


T0I0:   SETB AD0BUSY                ;��ʱʱ�䵽������AD
AD3:    JNB AD0INT,AD3              ;ADת���Ƿ����													  
        MOV A,0BDH                  ;���ɵ���ֵ����A��	   
		CLR AD0INT
		CLR C
		CJNE A,23H,NEXT1	        ;�����ֵ
		MOV 23H,A
NEXT1:  JNC NEXT2
        SJMP CP2
NEXT2:  MOV 23H,A                   ;�����βɵõ������ڵ�ǰ��23H���滻֮
CP2:    CLR C
        CJNE A,24H,NEXT3            ;����Сֵ
		MOV 24H,A
NEXT3:	JC NEXT4
        SJMP NEXT5
NEXT4:  MOV 24H,A                   ;�����βɵõ���С�ڵ�ǰ��24H���滻֮
NEXT5:	DJNZ R2,AA
		CLR TR0
AA:     MOV TH0,#131
        MOV TL0,#99
        RETI
		     
T1I1:   DJNZ R3,BB
        SETB AD0BUSY                 ;��ʱʱ�䵽������AD
AD4:    JNB AD0INT,AD4               ;ADת���Ƿ����
        MOV @R0,0BDH                 ;���ɵ���ֵ����R0ָ��ĵ�ַ��
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

DEL:	MOV 29H,#30	                  ;��ʱ10ms
DEL1:   MOV 28H,#66
DEL2:   DJNZ 28H,DEL2
        DJNZ 29H,DEL1
        RET

DEL10MS:MOV 29H,#150	              ;��ʱ10ms
DEL21:  MOV 28H,#66
DEL22:  DJNZ 28H,DEL22
        DJNZ 29H,DEL21
        RET

DEL500MS:MOV 29H,#255                 ;��ʱ500ms
DEL31:   MOV 28H,#120
DEL32:   MOV 27H,#15
DEL33:   DJNZ 27H,DEL33
         DJNZ 28H,DEL32
         DJNZ 29H,DEL31
         RET

SMG:   	MOV DPTR,#TABLE				   ;��DPTR�������ʼֵ
		MOV 60H,#0AH
		MOV 61H,#0BH

HERE:	CLR P2.0
        CLR P2.1

		MOV P1,#0FEH  					;ѡ�������
        SETB P2.1

        MOV A,60H
        MOVC A,@A+DPTR					;���������
		CLR P2.1				   
	    MOV P1,A
		SETB P2.0					    ;��A�е�ֵ���
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

        JB P2.7,HERE                       ;KEY2�Ƿ���
        LCALL DEL10MS
		LCALL DEL10MS
		JB P2.7,H0
H0:     LCALL DEL10MS
        LCALL DEL10MS
        JNB P2.7,HERE
		
HERE1:  MOV P1,#0FEH  					   ;ѡ�������
        SETB P2.1

        MOV A,61H
        MOVC A,@A+DPTR					   ;���������
		CLR P2.1				   
	    MOV P1,A
		SETB P2.0					       ;��A�е�ֵ���
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

        JB P2.7,HERE1                       ;KEY2�Ƿ���
        LCALL DEL10MS
		LCALL DEL10MS
		JB P2.7,H1
H1:		LCALL DEL10MS
        LCALL DEL10MS
		JNB P2.7,HERE1

		LJMP HERE

SMG1:   MOV R7,#255
        MOV P1,#0F7H  					   ;ѡ�������
        SETB P2.1
        MOV A,#76H        					   
		CLR P2.1				   
	    MOV P1,A
		SETB P2.0					       ;��A�е�ֵ���
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

HERE5:	MOV P1,#0FEH  					;ѡ�������
        SETB P2.1
        MOV A,#76H
		CLR P2.1				   
	    MOV P1,A
		SETB P2.0					    ;��A�е�ֵ���
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

TABLE:  DB 3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH		;���δ����
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