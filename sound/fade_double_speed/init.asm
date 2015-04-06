
	INCLUDE	"hardware.inc"
	
	SECTION	"Helper Functions",HOME

;--------------------------------------------------------------------------
;- wait_ly()    b = ly to wait for                                        -
;--------------------------------------------------------------------------
	
wait_ly::
	ld	c,rLY & $FF
.no_same_ly:
	ld	a,[$FF00+c]
	cp	a,b
	jr	nz,.no_same_ly
	
	ret

;--------------------------------------------------------------------------
;- memset()    d = value    hl = start address    bc = size               -
;--------------------------------------------------------------------------

memset::
	ld	a,d
	ld	[hl+],a
	dec	bc
	ld	a,b
	or	a,c
	jr	nz,memset
	ret

;--------------------------------------------------------------------------
;- CPU_fast()                                                             -
;- CPU_slow()                                                             -
;--------------------------------------------------------------------------
	
CPU_fast::

	ld	a,[rKEY1]
	bit	7,a
	jr	z,__CPU_switch
	ret
	
CPU_slow::

	ld	a,[rKEY1]
	bit	7,a
	jr	nz,__CPU_switch
	ret

__CPU_switch:
	
	ld	a,[rIE]
	ld	b,a ; save IE
	xor	a,a
	ld	[rIE],a
	ld	a,$30
	ld	[rP1],a
	ld	a,$01
	ld	[rKEY1],a
	
	stop
	
	ld	a,b
	ld	[rIE],a ; restore IE
	
	ret

;--------------------------------------------------------------------------
;-                             CARTRIDGE HEADER                           -
;--------------------------------------------------------------------------
	
	SECTION	"Cartridge Header",HOME[$0100]
	
	nop
	nop
	jr	Main
	NINTENDO_LOGO
	;    0123456789ABC
	DB	"SOUND THING.."
	DW	$0000
	DB  $C0 ;GBC flag
	DB	0,0,0	;SuperGameboy
	DB	$1B	;CARTTYPE (MBC5+RAM+BATTERY)
	DB	0	;ROMSIZE
	DB	4	;RAMSIZE (16*8KB)
	DB	$01,$00 ;Destination (0 = Japan, 1 = Non Japan) | Manufacturer
	DB	0,0,0,0 ;Version | Complement check | Checksum

;--------------------------------------------------------------------------
;- Main()                                                                 -
;--------------------------------------------------------------------------

Main:

	di
	
	;--------------------
	
	ld	a,$80
	ld	[rNR52],a
	ld	a,$77
	ld	[rNR50],a
	
	;--
	
	ld	a,$C0
	ld	[rNR21],a
	ld	a,$F7
	ld	[rNR22],a
	ld	a,$00
	ld	[rNR23],a
	ld	a,$84
	ld	[rNR24],a

	;--------------------
	
	ld	a,255
.loop:
	push	af
	
	ld	b,90
	call	wait_ly
	ld	b,0
	call	wait_ly
	
	pop	af
	dec	a
	jr	nz,.loop
	
	;--------------------
	
	call	CPU_fast
	
	;--------------------
	
	ld	a,$C0
	ld	[rNR21],a
	ld	a,$F7
	ld	[rNR22],a
	ld	a,$00
	ld	[rNR23],a
	ld	a,$84
	ld	[rNR24],a
	
	;--------------------
	
.end:
	halt
	jr .end

;--------------------------------------------------------------------------
