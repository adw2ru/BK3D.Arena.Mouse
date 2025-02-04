	;
	; UNROLLED DRAW	CODE PREPARE
PREP0:	MOV #UR0,R5
	MOV #64.,R4
	MOV #16128.+VSCR,R3
1$:	MOV #10063,(R5)+	; MOV R0,X(R3)
	MOV R3,(R5)+
	MOV R3,R1
	ADD #128.,R1
	MOV #10163,(R5)+	; MOV R1,X(R3)
	MOV R1,(R5)+
	SUB #256.,R3
	SOB R4,1$
	MOV #207,(R5)		; RET
	MOV #DD0,R5
	MOV #64.,R4
	MOV #UR0+504.,R3
2$:	MOV R3,(R5)+
	SUB #8.,R3
	SOB R4,2$
	RET
	;
	; CEILING&FLOOR	PRECOMPUTE
PREPCF:	MOV #MTRL+8.,R5	; +8.
	MOV #MTRL+64.,R4
	MOV #32.,R3
	MOV CXOR,R1
1$:	MOV CMASK,R2
	MOV (R5),R0
	INC R5
	XOR R1,R0
	BIC R0,R2
	MOV R2,(R4)+
	SOB R3,1$
	MOV #MTRL+8.,R5	; +10.
	MOV #MTRL+64.+64.+64.,R4
	MOV #32.,R3
	MOV FXOR,R1
2$:	MOV FMASK,R2
	MOV (R5),R0
	INC R5
	XOR R1,R0
	BIC R0,R2
	MOV R2,-(R4)
	SOB R3,2$
	RET
	;
	; PREPARE DRAW 1ST FRAME
PREPR:	MOV #FRBF1,R0
	MOV #33.,R2
	MOV R2,R1
1$:	MOV #504.,(R0)+
	SOB R1,1$
	MOV R2,R1
2$:	CLR (R0)+
	SOB R1,2$
	DEC R2
	MOV R2,R1
3$:	MOV #63.,(R0)+
	SOB R1,3$
	MOV R2,R1
4$:	MOV #2.,(R0)+
	SOB R1,4$
	MOV R2,R1
5$:	MOV #504.,(R0)+
	SOB R1,5$
	MOV R2,R1
6$:	MOV #63.,(R0)+
	SOB R1,6$
	RET
	;
	; PREPARE DRAW
DRPREP:	MOV #FRBF1,R5
	MOV #FRBF5,R3
	MOV #32.,R4
	;
3$:	CLR R0		; DELTA
	MOV #177777,R1	; COUNT
	;
4$:	MOV (R5),R2	; H1
	;
	CMP 66.(R5),68.(R5)
	BNE 2$
	INC R1
	BNE 1$
	MOV 2.(R5),R0	; H2
	SUB R2,R0	; H2-H1
	ASR R0
	ASR R0		; DELTA=(H2-H1)/4
1$:	ADD R0,R2	; HX=H1+DELTA
	MOV R2,(R3)+
	SUB R0,(R5)+
	SOB R4,4$
	BR 5$
	;
2$:	ADD R0,R2
	MOV R2,(R3)+
	SUB R0,(R5)+
	SOB R4,3$
	; --------------------------------
5$:	MOV #63.,R1
	MOV #32.,R4
	;
8$:	MOV -(R5),R0
	BGE 6A$
	CLR R0 ; CLIP NEGATIVE (RARE CASES)
	BR 6$
6A$:	ASR R0
	ASR R0
	ASR R0
	CMP R0,R1
	BLOS 6$
	MOV R1,R0
6$:	MOV R0,(R5)
	;
11$:	MOV -(R3),R0
	BGE 7A$
	CLR R0 ; CLIP NEGATIVE (RARE CASES)
	BR 7$
7A$:	ASR R0
	ASR R0
	ASR R0
	CMP R0,R1
	BLOS 7$
	MOV R1,R0
7$:	MOV R0,(R3)
	;
	SOB R4,8$
	RET
	;
	; DRAW DIFFERENCE OF 2 FRAMES
	; 1ST PART
DRDIFF:	CLR R5
1$:	CALL @SNDPR		; 1ST PART
	MOV FRBF1(R5),R2
	MOV FRBF3(R5),R1
	CMP R1,R2
	BEQ 3$
	BLO 4$
	MOV R2,FRBF3(R5)	; BHI
	CALL IDRF
3$:	MOV FRBF2(R5),R0
	BIC #177741,R0
	MOV MTRLHV(R0),R0
	BIC MTRL-1(R2),R0	; R2=1..64
	CMP R0,FRBF4(R5)
	BEQ 5$
2$:	MOV R0,FRBF4(R5)
	;
	CMP R2,FRBF5(R5)	; 2ND PART BEGIN
	BLO 55$
	BEQ 56$
	MOV FRBF5(R5),R1
	CALL IDRW		; FILL GAPS
	MOV FRBF4(R5),R0
	MOV FRBF5(R5),R2
	CALL DRWW		; DRAW BY WORDS
	BR 57$
55$:	MOV R2,R1
	MOV FRBF5(R5),R2
	SWAB R0	; ***
	INC R5
	CALL IDRW		; FILL GAPS
	DEC R5
	MOV FRBF4(R5),R0
	MOV FRBF1(R5),R2
56$:	CALL DRWW		; DRAW BY WORDS
	;
57$:	MOV FRBF5(R5),R2	; CONTINUE 2ND PART
	MOV FRBF6(R5),R1
	CMP R1,R2
	BEQ 58$	; ***
	BLO 6$
	INC R5
	CALL IDRF
	DEC R5
6$:	MOV R2,FRBF6(R5)	; END 2ND PART
	BR 58$ ; ***
	;
4$:	MOV R2,FRBF3(R5)
	MOV FRBF2(R5),R0
	BIC #177741,R0
	MOV MTRLHV(R0),R0
	BIC MTRL-1(R2),R0	; R2=1..64
	CMP R0,FRBF4(R5)
	BNE 2$
	CALL IDRW
	; ------------------------------------
5$:	MOV FRBF5(R5),R2	; 2ND PART
	MOV FRBF6(R5),R1
	CMP R1,R2
	BEQ 58$	; ***
	BLO 8$
	MOV R2,FRBF6(R5)
	INC R5
	CALL IDRF
	DEC R5
	BR 58$ ; ***
8$:	MOV R2,FRBF6(R5)
	MOV FRBF4(R5),R0
	SWAB R0	; ***
	INC R5
	CALL IDRW
	DEC R5			; END 2ND PART
58$:	ADD #2,R5
	CMP R5,#64.
	BLO 1$
	RET
	;
	; DRAW WALL
DRWW:	MOV #63.,R3
	SUB R2,R3
	SWAB R3
	ASR R3			; *128
	ADD R5,R3
	MOV R0,R1
	BEQ 1$			; DO NOT SWAP 0
	SWAB R1
	TSTB R3
	BPL 1$
	SWAB R0
	SWAB R1
1$:	ASL R2
	JMP @DD0(R2)
	;
	; DRAW CEILING&FLOOR
	; INPUTS: R5(COL),R2(H1),R1(H2)
IDRF:	MOV R2,R4		; PRESERVE R2
	MOV #63.,R3
	SUB R1,R3
	MOV R3,R0
	ADD #MTRL+64.,R0
	SWAB R3
	ASR R3
	ADD R5,R3
	ADD #VSCR,R3
	SUB R4,R1		; H2-H1
	ASL R4			; H1*2
	ADD R1,R4		; H2-H1+H1*2
	MOV R4,ID5+2
	DEC ID5+2 ; ***
	INC R4 ; ***
	SWAB R4
	ASR R4
	MOV R4,ID5+4
	MOV #128.,R4
ID5A:	MOVB (R0)+,(R3)
	ADD R4,R3
ID5:	MOVB 0(R0),0(R3)
	SOB R1,ID5A
	RET
	;
	; DRAW COLUMNS
	; INPUTS: R5(COL),R1(H1),R2(H2),R0(M1),R4(M2)
IDRW:	MOV #63.,R3
	SUB R2,R3
	SWAB R3
	ASR R3
	ADD R5,R3
	ADD #VSCR,R3
	SUB R1,R2
	ASL R1
	ADD R2,R1
	INC R1 ; ***
	SWAB R1
	ASR R1
	MOV R1,ID4+2
	MOV R0,R4
	BEQ ID2			; DO NOT SWAP 0
	TSTB R3
	BPL ID1
	SWAB R0
	SWAB R4
ID1:	TSTB R1
	BMI ID2	; BPL
	SWAB R4
ID2:	MOV #128.,R1
ID3:	MOVB R0,(R3)
	ADD R1,R3
ID4:	MOVB R4,0(R3)
	SWAB R0
	SWAB R4
	SOB R2,ID3
	RET
	;
	; LIGHT	LEVEL TABLE
MTRL:	.WORD 177777,177777
	.WORD 176077,176077,176077
	.WORD 176063,176063
	.WORD 146063,146063,146063
	.WORD 140063,140063,140063
	.WORD 140003,140003,140003
	.WORD 140000,140000,140000,140000,140000
	.WORD 0,0,0,0,0,0,0,0,0,0,0
	;
	; MATERIALS FOR	CEILING&FLOOR
	; (WILL	BE PRECOMPUTED)
	.BLKW 32.
	.BLKW 32.
	;
	; INTERNAL RAY TRACE ROUTINE
	; IN:
	; R3=DA
	; R4=DB
	; OUT:
	; R0=RAW TYPE
	; R2=RAW HEIGHT
CORE:	CALL @SNDPR
	MOV R3,-(SP)		; DA
	MOV R4,-(SP)		; DB
	MOV R5,-(SP)
	MOV #64.,-(SP)		; CONST
	TST R3			; R3=A1=DA
	BLE S1
	MOV #5201,DDII		; MOV #1.,DDI,INC R1
	MOV (SP),R1
	SUB DU0,R1		; MAKE 64..1
	BR S2
S1:	MOV #5301,DDII		; MOV #-1.,DDI,DEC R1
	MOV DU0,R1
	INC R1			; MAKE 1..64
	NEG R3			; -A1
S2:	MOV R4,R0		; R0=B1=DB
	BLE S3
	MOV #62701,DDJI		; MOV #16.,DDJ,ADD #16,R1
	MOV (SP),R4
	SUB DV0,R4		; MAKE 64..1
	BR S4
S3:	MOV #162701,DDJI	; MOV #-16.,DDJ,SUB #16,R1
	MOV DV0,R4
	INC R4			; MAKE 1..64
	NEG R0			; -B1
S4:	MOV R1,DDX		; DDX=R1
	MOV R4,DDY		; DDY=R4
	MOV R0,R5		; R1=U,R4=V,R5=R0=B1
	CALL SPMUL
	MOV R3,R0		; A1
	MOV R4,R1
	MOV R2,R4		; R4 U*=B1
	CALL SPMUL		; R2 V*=A1
	MOV DIJ0,R1		; I0,J0
	; WHILE	LOOP
S5:	MOVB FRCNTR,256.(R1)
	CMP R4,R2		; U>=V
	BLT S6
	; U-V>=0
	ADD (SP),DDY
	SUB R2,R4		; U-=V
	MOV R3,R2		; V=V1
DDJI:	ADD #16.,R1		; J+=DJ	INS.TO CHANGE
	MOVB (R1),R0
	BEQ S5
	MOV R5,R2		; R2=B1
	MOV DDY,R4
	BR RFIN
	; ELSE
S6:	ADD (SP),DDX
	SUB R4,R2		; V-=U
	MOV R5,R4		; U=U1
DDII:	INC R1			; I+=DI	INS.TO CHANGE
	MOVB (R1),R0
	BEQ S5
	BIS #20,R0		; HOR&VER TYPE
	MOV R3,R2		; R2=A1
	MOV DDX,R4
RFIN:	SUB (SP)+,R4
	CALL SPDIV
	MOV (SP)+,R5
	MOV (SP)+,R4
	MOV (SP)+,R3
	RET
	;
	; WALLS	RENDER
RENDR:	MOV #DU0,R5		; POINTER TO ALL RENDER	VARS
	MOV PLX,R0
	MOV R0,(R5)		; DU0
	BIC #177700,(R5)+
	MOV PLY,R1
	MOV R1,(R5)		; DV0
	BIC #177700,(R5)+
	BIC #77,R1
	ASR R0
	ASR R0
	ASR R0
	ASR R0
	ADD R1,R0
	ASR R0
	ASR R0
	ADD #MAP,R0
	MOV R0,(R5)+		; DIJ0
	MOV PLA,R0
	CALL GCOS
	MOV R1,-(SP)		; DA
	MOV R1,R2
	NEG R2
	MOV PLA,R0
	CALL GSIN
	SUB R1,(SP)		; DA=DA-R1
	MOV R1,-(SP)		; DB
	SUB R2,(SP)		; DB=DB-R2
	; I0,J0,U0,V0,DA,DB ARE	SET NOW
	; LET SREEN_WIDTH=32
;	ASR R1
	ASR R1
	ASR R1
	MOV R1,(R5)+		; DDA
	ASR R1
	MOV R1,(R5)+		; DDA/2
	ASR R1
	MOV R1,(R5)+		; DDA/4
;	ASR R2
	ASR R2
	ASR R2
	MOV R2,(R5)+		; DDB
	ASR R2
	MOV R2,(R5)+		; DDB/2
	ASR R2
	MOV R2,(R5)+		; DDB/4
	; DA,DB,A,B ARE	SET NOW
	; RENDER LOOP
	MOV (SP)+,R4		; DB
	MOV (SP)+,R3		; DA
	MOV #64.-8.,R5		; ALL BUFS LEN=+2
	; 1ST RAY
	CALL CORE
	MOV R2,FRBF1+8.(R5)
	MOV R0,FRBF2+8.(R5)
	; NEXT RAYS
RLP:	ADD DDA,R3
	ADD DDB,R4
	CALL CORE
	CMP R0,FRBF2+8.(R5)	; SAME OR NOT?
	BNE NSM
	; SAME - INTERPOLATE
	ADD #FRBF2,R5
	MOV R0,(R5)+		; FILL MATERIAL
	MOV R0,(R5)+
	MOV R0,(R5)+
	MOV R0,(R5)+
	SUB #66.,R5		; SWITCH TO FRBF1
	MOV (R5),R1		; TAKE PREV.SCALE
	MOV R1,R0		; INTERPOLATE
	ADD R2,R1
	ASR R1
	ADD R1,R0
	ASR R0
	MOV R0,-(R5)
	MOV R1,-(R5)
	ADD R2,R1
	ASR R1
	MOV R1,-(R5)
	MOV R2,-(R5)
	SUB #FRBF1+8.,R5
	BGE RLP
	RET
NSM:	; NOT SAME - TRACE ADD.	RAY
	MOV R3,-(SP)
	MOV R4,-(SP)
	MOV R2,FRBF1(R5)	; PUT
	MOV R0,FRBF2(R5)	; PUT
	SUB DDA2,R3
	SUB DDB2,R4
	CALL CORE
	MOV R2,FRBF1+4(R5)	; PUT
	MOV R0,FRBF2+4(R5)	; PUT
	CMP R0,FRBF2+8.(R5)
	BNE NT1
	MOV FRBF1+8.(R5),R1
	ADD R2,R1
	ASR R1
	MOV R1,FRBF1+4+2(R5)	; PUT
	MOV R0,FRBF2+4+2(R5)	; PUT
	BR NT2
NT1:	SUB DDA4,R3
	SUB DDB4,R4
	CALL CORE
	MOV R2,FRBF1+6(R5)	; PUT
	MOV R0,FRBF2+6(R5)	; PUT
	MOV FRBF1+4(R5),R2	; RESTORE
	MOV FRBF2+4(R5),R0	; RESTORE
NT2:	CMP R0,FRBF2(R5)
	BNE NT3
	MOV R2,R1
	ADD FRBF1(R5),R1
	ASR R1
	MOV R1,FRBF1+2(R5)	; PUT
	MOV R0,FRBF2+2(R5)	; PUT
	BR NT4
NT3:	MOV (SP),R4
	MOV 2(SP),R3
	SUB DDA4,R3
	SUB DDB4,R4
	CALL CORE
	MOV R2,FRBF1+2(R5)	; PUT
	MOV R0,FRBF2+2(R5)	; PUT
NT4:	MOV (SP)+,R4
	MOV (SP)+,R3
	SUB #8.,R5
	BGE RLP
	RET
	;
	; RENDER VARS (DO NOT CHANGE ORDER!)
DU0:	.WORD 0
DV0:	.WORD 0
DIJ0:	.WORD 0
DDA:	.WORD 0
DDA2:	.WORD 0			; DDA/2
DDA4:	.WORD 0			; DDA/4
DDB:	.WORD 0
DDB2:	.WORD 0			; DDB/2
DDB4:	.WORD 0			; DDB/4
DDX:	.WORD 0
DDY:	.WORD 0
	;
	.END
