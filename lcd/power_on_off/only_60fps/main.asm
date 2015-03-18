
	INCLUDE	"hardware.inc"
	INCLUDE "header.inc"

	SECTION "MAIN", HOME
;--------------------------------------------------------------------------
;- Main()                                                                 -
;--------------------------------------------------------------------------

WRITE_NUMBER : MACRO
	ld	a,[\1]
	ld	b,a
	swap	a
	and	a,$0F
	ld	[_SCRN0+2*(\2)],a
	ld	a,b
	and	a,$0F
	ld	[_SCRN0+2*(\2)+1],a
ENDM


Main:
	
	call	screen_off
	
	ld	bc,16
	ld	de,0
	ld	hl,font_tiles
	call	vram_copy_tiles
	
	ld	hl,bg_palette
	ld	a,0
	call	bg_set_palette
	
	ld	a,$E4
	ld	[rBGP],a
	
	;--------------------------------------------------------------------------
	
	ld	a,0
	ld	[rTMA],a
	ld	[rTIMA],a
	ld	[rDIV],a
	
	ld	a,TACF_262KHZ|TACF_STOP
	ld	[rTAC],a
	
	ld	a,TACF_262KHZ|TACF_START
	ld	[rTAC],a
	
	ld	a,IEF_TIMER
	ld	[rIE],a
	
	ei
	
	;--------------------------------------------------------------------------
	ld	a,LCDCF_ON
	ld	[rLCDC],a
	
	
	ld	a,0 ; counter
	
.loop:
	
	push	af
	
	ld	b,$89
	call	wait_ly
	ld	b,$90
	call	wait_ly
	
	pop	af
	inc	a
	
	jr	nz,.loop
	
	;--------------------------------------------------------------------------
	
	call	screen_off
	
	WRITE_NUMBER	$C000,0
	WRITE_NUMBER	$C001,1
	
	ld	a,LCDCF_ON|LCDCF_BG8000|LCDCF_BG9800|LCDCF_BGON ; configuration
	ld	[rLCDC],a
	
.endloop:
	halt
	jr	.endloop
	

	SECTION "FONT",ROMX[$4000],BANK[1]
font_tiles: ; 16 tiles
DB $C3,$C3,$99,$99,$99,$99,$99,$99
DB $99,$99,$C3,$C3,$FF,$FF,$FF,$FF
DB $E7,$E7,$C7,$C7,$E7,$E7,$E7,$E7
DB $E7,$E7,$C3,$C3,$FF,$FF,$FF,$FF
DB $C3,$C3,$99,$99,$F9,$F9,$E3,$E3
DB $CF,$CF,$81,$81,$FF,$FF,$FF,$FF
DB $C3,$C3,$99,$99,$F3,$F3,$F9,$F9
DB $99,$99,$C3,$C3,$FF,$FF,$FF,$FF
DB $F3,$F3,$E3,$E3,$D3,$D3,$B3,$B3
DB $81,$81,$F3,$F3,$FF,$FF,$FF,$FF
DB $83,$83,$9F,$9F,$83,$83,$F9,$F9
DB $99,$99,$C3,$C3,$FF,$FF,$FF,$FF
DB $C3,$C3,$9F,$9F,$83,$83,$99,$99
DB $99,$99,$C3,$C3,$FF,$FF,$FF,$FF
DB $C1,$C1,$F9,$F9,$F3,$F3,$E7,$E7
DB $E7,$E7,$E7,$E7,$FF,$FF,$FF,$FF
DB $C3,$C3,$99,$99,$C3,$C3,$99,$99
DB $99,$99,$C3,$C3,$FF,$FF,$FF,$FF
DB $C3,$C3,$99,$99,$81,$81,$F9,$F9
DB $99,$99,$C3,$C3,$FF,$FF,$FF,$FF
DB $C3,$C3,$99,$99,$99,$99,$81,$81
DB $99,$99,$99,$99,$FF,$FF,$FF,$FF
DB $83,$83,$99,$99,$83,$83,$99,$99
DB $99,$99,$83,$83,$FF,$FF,$FF,$FF
DB $C3,$C3,$99,$99,$9F,$9F,$9F,$9F
DB $99,$99,$C3,$C3,$FF,$FF,$FF,$FF
DB $83,$83,$99,$99,$99,$99,$99,$99
DB $99,$99,$83,$83,$FF,$FF,$FF,$FF
DB $81,$81,$9F,$9F,$87,$87,$9F,$9F
DB $9F,$9F,$81,$81,$FF,$FF,$FF,$FF
DB $81,$81,$9F,$9F,$87,$87,$9F,$9F
DB $9F,$9F,$9F,$9F,$FF,$FF,$FF,$FF

bg_palette:
DW	32767,22197,12684,0


