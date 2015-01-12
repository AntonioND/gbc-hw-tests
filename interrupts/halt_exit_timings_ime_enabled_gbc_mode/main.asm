
	INCLUDE	"hardware.inc"
	INCLUDE "header.inc"

	
	SECTION	"var",BSS
	
repeat_loop:	DS 1

	SECTION	"Main",HOME

;--------------------------------------------------------------------------
;- Main()                                                                 -
;--------------------------------------------------------------------------

Main:
	
	ld	hl,$A000
	
	ld	a,[Init_Reg_A]
	cp	a,$11
	jr	nz,.skipchange1
	ld	a,0
	ld	[repeat_loop],a
	call	CPU_slow
.skipchange1:

.repeat_all:
	
	; -------------------------------------------------------
	
	ld	a,$0A
	ld	[$0000],a ; enable ram

	; -------------------------------------------------------
	
	di
	
	ld	a,$80
	ld	[rTMA],a
	
	; -------------------------------------------------------

PERFORM_TEST : MACRO
	
	ld	a,TACF_STOP|TACF_65KHZ
	ld	[rTAC],a
	ld	a,TACF_START|TACF_65KHZ
	ld	[rTAC],a
	
	ld	[rDIV],a
	ld	a,$F8
	ld	[rTIMA],a
	ld	[rDIV],a

	ld	a,IEF_TIMER
	ld	[rIE],a
	xor	a,a
	ld	[rIF],a
	ei
	halt
	REPT \1
	NOP
	ENDR
	ld	a,[rTIMA]
	ld	[hl+],a
	di
ENDM

REPETITIONS SET 0
	REPT 64
	PERFORM_TEST REPETITIONS
REPETITIONS SET REPETITIONS+1
	ENDR
	
	; -------------------------------------------------------
	

	push	hl ; magic number
	ld	[hl],$12
	inc hl
	ld	[hl],$34
	inc hl
	ld	[hl],$56
	inc hl
	ld	[hl],$78
	pop	hl
	
	ld	a,$00
	ld	[$0000],a ; disable ram
	
	; -------------------------------------------------------
	
	ld	a,[Init_Reg_A]
	cp	a,$11
	jr	nz,.skipchange2
	ld	a,[repeat_loop]
	and	a,a
	jr	nz,.endloop
	; -------------------------------------------------------

	call	CPU_fast
	ld	a,1
	ld	[repeat_loop],a
	jp	.repeat_all
.skipchange2:
	
.endloop:
	halt
	jr	.endloop
