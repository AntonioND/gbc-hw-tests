
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
	DB	"LCD TIMINGS.."
	DW	$0000
	DB  $00 ;GBC flag
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

	ld	a,$0A
	ld	[$0000],a ; enable SRAM
	
	; Clear SRAM
	ld	a,$00
.clearsram:
	push	af
	ld	[$4000],a
	ld	d,0
	ld	hl,$A000
	ld	bc,$2000
	call	memset
	pop	af
	inc	a
	cp	a,1 ; number of banks to clear
	jr	nz,.clearsram
	
	;--------------------
	
	di
	
	ld	a,IEF_LCDC
	ld	[rIE],a
	
	ld	a,STATF_LYC
	ld	[rSTAT],a
	ld	a,143
	ld	[rLYC],a
	
	ld	hl,$A000
	
	;--------------------

NCYCLES_READ : MACRO
	ld	b,142
	call	wait_ly
	
	xor	a,a
	ld	[rIF],a
	
	halt ; wait for ly 143
	
	REPT 104 + \1
	nop
	ENDR
	
	ld	a,[rSTAT]
	
	ld	[hl+],a
ENDM

NCYCLES_WRITE : MACRO
	ld	b,142
	call	wait_ly
	
	xor	a,a
	ld	[rIF],a
	
	halt ; wait for ly 143
	
	REPT 104 + \1
	nop
	ENDR
	
	ld	[rIF],a
	
	ld	a,[rIF]
	ld	[hl+],a
ENDM

	NCYCLES_READ 0
	NCYCLES_READ 1
	NCYCLES_READ 2
	NCYCLES_READ 3
	NCYCLES_READ 4
	NCYCLES_READ 5
	NCYCLES_READ 6
	NCYCLES_READ 7
	NCYCLES_READ 8
	NCYCLES_READ 9
	NCYCLES_READ 10
	NCYCLES_READ 11
	NCYCLES_READ 12
	NCYCLES_READ 13
	NCYCLES_READ 14
	NCYCLES_READ 15
	
	NCYCLES_WRITE 0
	NCYCLES_WRITE 1
	NCYCLES_WRITE 2
	NCYCLES_WRITE 3
	NCYCLES_WRITE 4
	NCYCLES_WRITE 5
	NCYCLES_WRITE 6
	NCYCLES_WRITE 7
	NCYCLES_WRITE 8
	NCYCLES_WRITE 9
	NCYCLES_WRITE 10
	NCYCLES_WRITE 11
	NCYCLES_WRITE 12
	NCYCLES_WRITE 13
	NCYCLES_WRITE 14
	NCYCLES_WRITE 15
	
	;--------------------
	
	ld	a,$00
	ld	[$0000],a ; disable SRAM
	
	;--------------------
	
	ld	a,$80
	ld	[rNR52],a
	ld	a,$FF
	ld	[rNR51],a
	ld	a,$77
	ld	[rNR50],a
	
	ld	a,$C0
	ld	[rNR11],a
	ld	a,$E0
	ld	[rNR12],a
	ld	a,$00
	ld	[rNR13],a
	ld	a,$87
	ld	[rNR14],a

.end:
	halt
	jr .end


;--------------------------------------------------------------------------



