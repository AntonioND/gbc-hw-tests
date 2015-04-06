
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
	ld	a,143
	ld	[rLYC],a
	
	ld	hl,$A000
	
	;--------------------

NCYCLES_READ : MACRO
	ld	b,142
	call	wait_ly
	
	ld	a,STATF_LYC
	ld	[rSTAT],a
	
	xor	a,a
	ld	[rIF],a
	
	halt ; wait for ly 143
	
	ld	a,STATF_MODE01
	ld	[rSTAT],a
	xor	a
	ld	[rIF],a
	
	REPT 91 + \1
	nop
	ENDR
	
	ld	a,[rSTAT]
	
	ld	[hl+],a
ENDM

NCYCLES_WRITE_IF : MACRO
	ld	b,142
	call	wait_ly
	
	ld	a,STATF_LYC
	ld	[rSTAT],a
	
	xor	a,a
	ld	[rIF],a
	
	halt ; wait for ly 143
	
	ld	a,STATF_MODE01
	ld	[rSTAT],a
	xor	a
	ld	[rIF],a
	
	REPT 91 + \1
	nop
	ENDR
	
	ld	[rIF],a
	
	ld	a,[rIF]
	ld	[hl+],a
ENDM

NCYCLES_WRITE_STAT : MACRO
	ld	b,142
	call	wait_ly
	
	ld	a,STATF_LYC
	ld	[rSTAT],a
	xor	a
	
	xor	a,a
	ld	[rIF],a
	
	halt ; wait for ly 143
	
	ld	a,STATF_MODE01
	ld	[rSTAT],a
	xor	a
	ld	[rIF],a
	
	REPT 91 + \1
	nop
	ENDR
	
	ld	[rSTAT],a
	
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
	
	NCYCLES_WRITE_IF 0
	NCYCLES_WRITE_IF 1
	NCYCLES_WRITE_IF 2
	NCYCLES_WRITE_IF 3
	NCYCLES_WRITE_IF 4
	NCYCLES_WRITE_IF 5
	NCYCLES_WRITE_IF 6
	NCYCLES_WRITE_IF 7
	NCYCLES_WRITE_IF 8
	NCYCLES_WRITE_IF 9
	NCYCLES_WRITE_IF 10
	NCYCLES_WRITE_IF 11
	NCYCLES_WRITE_IF 12
	NCYCLES_WRITE_IF 13
	NCYCLES_WRITE_IF 14
	NCYCLES_WRITE_IF 15
	
	NCYCLES_WRITE_STAT 0
	NCYCLES_WRITE_STAT 1
	NCYCLES_WRITE_STAT 2
	NCYCLES_WRITE_STAT 3
	NCYCLES_WRITE_STAT 4
	NCYCLES_WRITE_STAT 5
	NCYCLES_WRITE_STAT 6
	NCYCLES_WRITE_STAT 7
	NCYCLES_WRITE_STAT 8
	NCYCLES_WRITE_STAT 9
	NCYCLES_WRITE_STAT 10
	NCYCLES_WRITE_STAT 11
	NCYCLES_WRITE_STAT 12
	NCYCLES_WRITE_STAT 13
	NCYCLES_WRITE_STAT 14
	NCYCLES_WRITE_STAT 15
	
	;--------------------
	
	;--------------------
	
	call	CPU_fast
	
	jp MAIN2
	
	;--------------------
	
	;--------------------

	SECTION	"MAIN2",ROMX,BANK[1]
MAIN2:
	NCYCLES_READ 116+0
	NCYCLES_READ 116+1
	NCYCLES_READ 116+2
	NCYCLES_READ 116+3
	NCYCLES_READ 116+4
	NCYCLES_READ 116+5
	NCYCLES_READ 116+6
	NCYCLES_READ 116+7
	NCYCLES_READ 116+8
	NCYCLES_READ 116+9
	NCYCLES_READ 116+10
	NCYCLES_READ 116+11
	NCYCLES_READ 116+12
	NCYCLES_READ 116+13
	NCYCLES_READ 116+14
	NCYCLES_READ 116+15
	
	NCYCLES_WRITE_IF 116+0
	NCYCLES_WRITE_IF 116+1
	NCYCLES_WRITE_IF 116+2
	NCYCLES_WRITE_IF 116+3
	NCYCLES_WRITE_IF 116+4
	NCYCLES_WRITE_IF 116+5
	NCYCLES_WRITE_IF 116+6
	NCYCLES_WRITE_IF 116+7
	NCYCLES_WRITE_IF 116+8
	NCYCLES_WRITE_IF 116+9
	NCYCLES_WRITE_IF 116+10
	NCYCLES_WRITE_IF 116+11
	NCYCLES_WRITE_IF 116+12
	NCYCLES_WRITE_IF 116+13
	NCYCLES_WRITE_IF 116+14
	NCYCLES_WRITE_IF 116+15
	
	NCYCLES_WRITE_STAT 116+0
	NCYCLES_WRITE_STAT 116+1
	NCYCLES_WRITE_STAT 116+2
	NCYCLES_WRITE_STAT 116+3
	NCYCLES_WRITE_STAT 116+4
	NCYCLES_WRITE_STAT 116+5
	NCYCLES_WRITE_STAT 116+6
	NCYCLES_WRITE_STAT 116+7
	NCYCLES_WRITE_STAT 116+8
	NCYCLES_WRITE_STAT 116+9
	NCYCLES_WRITE_STAT 116+10
	NCYCLES_WRITE_STAT 116+11
	NCYCLES_WRITE_STAT 116+12
	NCYCLES_WRITE_STAT 116+13
	NCYCLES_WRITE_STAT 116+14
	NCYCLES_WRITE_STAT 116+15
	
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



