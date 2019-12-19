		.import         vset, popa, popax		; Import the functions we need to pull data from the stack.
        .include        "cx16.inc"				; This is a necessary include file, for some basic functionality we need.
        .include		"zeropage.inc"			; This gives us some nice functionality when it comes to zeropage addressing.

; Much of this code was stolen from Mick Clift and jdifelici from the Murray forums.  I did all the stuff linking to C
; and I reworked some bits here and there - including getting it to work with .34 version of the emulator.  Many of the
; function s have been drastically reworked, but enough of the original code is still here to give credit to the original
; authors.  Who, if they have any issues with me using their code here, they can let me know and I'll remove it and replace
; it with something else.
; If anyone wants to use this, feel free.  Just give credit where credit is due :D.

;***************************************************
;	VERA external address space

	VERA_BASE 		= $9F20
	VERA_ADDR_LO  	= VERA_BASE + 0
	VERA_ADDR_MID 	= VERA_BASE + 1
	VERA_ADDR_HI  	= VERA_BASE + 2
	VERA_DATA0		= VERA_BASE + 3
	VERA_DATA1		= VERA_BASE + 4
	VERA_CTRL 	 	= VERA_BASE + 5
	VERA_IEN 	 	= VERA_BASE + 6
	VERA_ISR 	 	= VERA_BASE + 7

;***************************************************
;	VERA internal registers


;	Display composer
	DC_VIDEO			= $F0000

;	Layer 0 Addresses
	L0_BASE 		= $F2000
	L0_CTRL0		= L0_BASE + 0
	L0_CTRL1		= L0_BASE + 1

;	Layer 1 Addresses
	L1_BASE 		= $F3000
	L1_CTRL0		= L1_BASE + 0
	L1_CTRL1		= L1_BASE + 1


	FONT_ASCII		= $1E800		; Font definition #1 : iso ascii font      --  These 4 definitions are here temporarily, until I
	FONT_UPETSCII	= $1F000		; Font definition #2 : PETSCII uppercase   --  fix the copy data function.
	FONT_LPETSCII	= $1F800		; Font definition #3 : PETSCII lowercase
	PALETTE			= $F1000


.macro VADDR ADDR 					; This macro will take an address passed to it, add the stride value, and send it to Vera.
	LDA 	#<(ADDR >> 16)			; The stride value is added to the first 4 bits of the 24 bit address.
	ORA		stride					; So, if you have a stride of 1, and the address is $F0000, what will be sent to Vera
	STA 	VERA_ADDR_HI			; will be $1F0000.
	LDA 	#<(ADDR >> 8)			; The stride must be added to all Vera addressing.
	STA 	VERA_ADDR_MID
	LDA 	#<(ADDR)
	STA 	VERA_ADDR_LO
.endmacro

.segment "ZEROPAGE"					; I use a global zero page address for the stride variable, since it must be available
	stride:							; to almost all Vera functions.
		.byte $00

.export _setDataPort				; This function I use to set up the Vera Dataport, and set the global stride variable.
									; I, currently, don't know of a reason why the stride would change after initialization.
.segment    "CODE"					; If I find one, I will change this system.
.proc    _setDataPort: near
.segment    "CODE"
;.byte $FF
    sta     VERA_CTRL				; Since we are using fastcall parameter passing from C, by default, the first parameter
    jsr popa  						; comes in A by default.  We, then, pop the next value off the stack, which is the stride.
    asl  							; I shift the stride value left 4 bits, which allows me to easily or it with the high byte
    asl 							; of the 24 bit Vera addresses we will be using in later functions.
    asl
    asl
    sta stride
    rts
.endproc

.export _setScreenScale				; This function sets the Vera screen scale.

.segment    "CODE"
.proc    _setScreenScale: near

.segment    "CODE"
;.byte $FF
	VADDR DC_VIDEO					; An example of passing a 24 bit address to Vera using VADDR.  This one is for video configurations.
	lda #%00000001  				; select vga mode, this may need to be parameterized (probably).
	sta VERA_DATA0
	jsr popa
	sta VERA_DATA0	
	jsr popa 						; Popping another parameter off the stack.
	sta VERA_DATA0
    rts
.endproc

.export _layer0Setup				; Layer0Setup for setting up the Layer 0 configuration options.

.segment    "CODE"
.proc    _layer0Setup: near

.segment    "DATA"
	hscroll: 						; More variables for Layer0Setup
		.byte $00, $00
	vscroll:
		.byte $00, $00
	font:
		.byte $00, $00
	map_base:
		.byte $00, $00
	map:
		.byte $00
	enable:
		.byte $00
	mode:
		.byte $00

	.segment	"CODE"
;.byte $FF
	sta vscroll
	stx vscroll + 1
	jsr popax				; popax lets me pop 2 bytes off the stack at once.  One goes in A, the other in X.  It helps speed things up.
	sta hscroll
	stx hscroll + 1
	jsr popax
	sta font
	stx font +1
	jsr popax
	sta map_base
	stx map_base + 1
	jsr popax
	sta map
	stx mode

	VADDR L0_CTRL0
	lda mode
	sta VERA_DATA0
	lda map
	sta VERA_DATA0
	lda map_base
	sta VERA_DATA0
	lda map_base + 1
	sta VERA_DATA0
	lda font
	sta VERA_DATA0
	lda font + 1
	sta VERA_DATA0
	lda hscroll
	sta VERA_DATA0
	lda hscroll + 1
	sta VERA_DATA0
	lda vscroll
	sta VERA_DATA0
	lda vscroll + 1
	sta VERA_DATA0
	rts
.endproc

.export _layer1Setup			;Layer1Setup.  Layer 1 configuration options.

.segment    "CODE"
.proc    _layer1Setup: near

.segment    "DATA"
	hscroll:
		.byte $00, $00
	vscroll:
		.byte $00, $00
	font:
		.byte $00, $00
	map_base:
		.byte $00, $00
	map:
		.byte $00
	enable:
		.byte $00
	mode:
		.byte $00

	.segment	"CODE"
;.byte $FF
	sta vscroll
	stx vscroll + 1
	jsr popax
	sta hscroll
	stx hscroll + 1
	jsr popax
	sta font
	stx font +1
	jsr popax
	sta map_base
	stx map_base + 1
	jsr popax
	sta map
	stx mode

	VADDR L1_CTRL0
	lda mode
	sta VERA_DATA0
	lda map
	sta VERA_DATA0
	lda map_base
	sta VERA_DATA0
	lda map_base + 1
	sta VERA_DATA0
	lda font
	sta VERA_DATA0
	lda font + 1
	sta VERA_DATA0
	lda hscroll
	sta VERA_DATA0
	lda hscroll + 1
	sta VERA_DATA0
	lda vscroll
	sta VERA_DATA0
	lda vscroll + 1
	sta VERA_DATA0
	rts
.endproc

.export _copyData				;This is copydata, it is currently a hack, and needs to be rewritten.

.segment    "CODE"
.proc    _copyData: near

.segment    "DATA"
	count:
		.word  $0000
.segment "ZEROPAGE"
	sourceaddr:
		.word $0000

.segment    "CODE"
;.byte $FF
	sta 	VERA_ADDR_LO				; By default, with fastcall, if the first variable is more than 16 bits, the high order bits
	stx 	VERA_ADDR_MID 				; in a 24 bit addresswill be in sreg.  This is a zeropage register, and is why we include 
	lda sreg 							; zeropage.inc.
	ORA stride 
	sta 	VERA_ADDR_HI
	jsr popax
    sta sourceaddr  
    stx sourceaddr +1
	jsr popax
    sta count
	stx count + 1
	lda count + 1
	ldx count
    beq loophi
looploinit:
	ldy #$00
looplo:
	lda (sourceaddr), y		; load A with source + y
	sta VERA_DATA0		; store in data0
	iny
	dex
	bne looplo						; continue if more bytes to xfer
	inc sourceaddr +1	; increment src(hi) by 1
loophi:
	lda count + 1
	beq fin
	dec count + 1
	bra looploinit
fin:
    rts
.endproc

;void cdecl fillWindow(uint32_t layerMap, uint8_t numCols, uint8_t startCol, uint8_t startRow, uint8_t width, uint8_t height, uint8_t char, uint8_t color);
.export _fillWindow   ; fillWindow for placing different sized rectangles on the screen.

.segment    "CODE"
.proc    _fillWindow: near

.segment    "DATA"
	numCols:
		.byte $00
	startCol:
		.byte $00
	startRow:
		.byte $00
	height:
		.byte $00
	width:
		.byte $00
	chr:
		.byte $00
	clr:
		.byte $00
	winc:
		.byte $00

.segment	"CODE"
;.byte $FF
	sta 	VERA_ADDR_LO				; By default, with fastcall, if the first variable is more than 16 bits, the high order bits
	stx 	VERA_ADDR_MID 				; in a 24 bit addresswill be in sreg.  This is a zeropage register, and is why we include 
	lda sreg 							; zeropage.inc.
	ORA stride 
	sta 	VERA_ADDR_HI
	jsr popax
	sta clr
	stx chr
	jsr popax
	sta height
	stx width
	jsr popax
	sta startRow
	stx startCol
	jsr popa
	sta numCols
	inc
	sbc width
	asl a
	sta winc
	lda numCols
	cmp #$20
	beq jump32
	cmp #$40
	beq jump64
	cmp #$80
	beq jump128
	jmp jump256
jump32:
	lda numCols
	sbc width
	asl a
	sta winc
	lda startRow
	ldx startCol
	jsr AddCwRowColToVAddr32
	jmp jumpc
jump64:
	lda startRow
	ldx startCol
	jsr AddCwRowColToVAddr64
	jmp jumpc
jump128:
	lda startRow
	ldx startCol
	jsr AddCwRowColToVAddr128
	jmp jumpc
jump256:
	lda startRow
	ldx startCol
	jsr AddCwRowColToVAddr256
jumpc:
		ldy height						; height counter
jumpd:
		ldx width						; width counter
jumpe:
		lda chr
		sta VERA_DATA0					; store char
		lda clr
		sta VERA_DATA0					; store color
		dex					; dec col count
		bne jumpe
		dey					; dec row count
		beq fin
;.byte $FF
		clc
		lda winc
		jsr Add_A_ToVAddr
		bra jumpd
fin:
		rts
.endproc

.export _fillChar   ; fillWindow for placing different sized rectangles on the screen.

.segment    "CODE"
.proc    _fillChar: near

.segment    "DATA"
	numCols:
		.byte $00
	startCol:
		.byte $00
	startRow:
		.byte $00
	chr:
		.byte $00
	clr:
		.byte $00

.segment	"CODE"
;.byte $FF
	sta 	VERA_ADDR_LO				; By default, with fastcall, if the first variable is more than 16 bits, the high order bits
	stx 	VERA_ADDR_MID 				; in a 24 bit addresswill be in sreg.  This is a zeropage register, and is why we include 
	lda sreg 							; zeropage.inc.
	ORA stride 
	sta 	VERA_ADDR_HI
	jsr popax
	sta clr
	stx chr
	jsr popax
	sta startRow
	stx startCol
	jsr popa
	cmp #$20
	beq jump32
	cmp #$40
	beq jump64
	cmp #$80
	beq jump128
	jmp jump256
jump32:
	lda startRow
	ldx startCol
	jsr AddCwRowColToVAddr32
	jmp jumpc
jump64:
	lda startRow
	ldx startCol
	jsr AddCwRowColToVAddr64
	jmp jumpc
jump128:
	lda startRow
	ldx startCol
	jsr AddCwRowColToVAddr128
	jmp jumpc
jump256:
	lda startRow
	ldx startCol
	jsr AddCwRowColToVAddr256
jumpc:
	lda chr
	sta VERA_DATA0					; store char
	lda clr
	sta VERA_DATA0					; store color
fin:
	rts
.endproc

.export Add_A_ToVAddr					; The rest of this is pretty much about finding the location in video memory
										; to place the characters in, and placing them.
.segment    "CODE"						; I will, probably, create other functions that use different methods to
.proc    Add_A_ToVAddr: near 			; display tiles and graphics information.  It's a bit messy, but it works.
		clc
		adc VERA_ADDR_LO
		sta VERA_ADDR_LO
		bcc fin
		lda VERA_ADDR_MID
		adc #0			; carry is already set
		sta VERA_ADDR_MID
		bcc fin
		inc VERA_ADDR_HI
fin:
		rts
.endproc

.export AddCwColToVAddr

.segment    "CODE"
.proc    AddCwColToVAddr: near
		;lda cw_col load cw_col in a before calling
		asl a
		clc
		adc VERA_ADDR_LO
		sta VERA_ADDR_LO
		bcc fin
		lda VERA_ADDR_MID
		adc #0			; carry is already set
		sta VERA_ADDR_MID
		bcc fin
		inc VERA_ADDR_HI
fin:
		rts
.endproc

.export AddCwRowColToVAddr32

.segment    "CODE"
.proc    AddCwRowColToVAddr32: near
.segment 	"DATA"
	startRow:
		.byte $00	
	startCol:
		.byte $00
.segment    "CODE"
;.byte $FF
		;lda cw_row call with startRow in a, startCol in x.
		sta startRow
		stx startCol
		asl a
		asl a
		asl a
		asl a
		asl a
		asl a
		clc
		adc VERA_ADDR_LO
		sta VERA_ADDR_LO
		bcc jump
		lda VERA_ADDR_MID
		adc #0
		sta VERA_ADDR_MID
		bcc jump
		lda VERA_ADDR_HI
		adc #0
		sta VERA_ADDR_HI
jump:
		lda startRow
		lsr a
		lsr a
		clc
		adc VERA_ADDR_MID
		sta VERA_ADDR_MID
		bcc fin
		inc VERA_ADDR_HI
fin:
		lda startCol
		jsr AddCwColToVAddr
		rts
.endproc

.export AddCwRowColToVAddr64

.segment    "CODE"
.proc    AddCwRowColToVAddr64: near
.segment 	"DATA"
	startRow:
		.byte $00	
	startCol:
		.byte $00
.segment    "CODE"
		sta startRow
		stx startCol
		lsr a
		bcc jump
		lda #$80
		clc
		adc VERA_ADDR_LO
		sta VERA_ADDR_LO
		bcc jump
		lda VERA_ADDR_MID
		adc #0
		sta VERA_ADDR_MID
		bcc jump
		lda VERA_ADDR_HI
		adc #0
		sta VERA_ADDR_HI
jump:
		lda startRow
		lsr a
		clc
		adc VERA_ADDR_MID
		sta VERA_ADDR_MID
		bcc fin
		inc VERA_ADDR_HI
fin:
		lda startCol
		jsr AddCwColToVAddr
		rts
.endproc

.export AddCwRowColToVAddr128

.segment    "CODE"
.proc    AddCwRowColToVAddr128: near
.segment 	"DATA"
	startRow:
		.byte $00	
	startCol:
		.byte $00
.segment    "CODE"
;.byte $FF
		sta startRow
		stx startCol
		clc
		adc VERA_ADDR_MID
		sta VERA_ADDR_MID
		bcc fin
		inc VERA_ADDR_HI
fin:
		lda startCol
		jsr AddCwColToVAddr
		rts
.endproc

.export AddCwRowColToVAddr256

.segment    "CODE"
.proc    AddCwRowColToVAddr256: near
.segment 	"DATA"
	startRow:
		.byte $00	
	startCol:
		.byte $00
.segment    "CODE"
;.byte $FF
		sta startRow
		stx startCol
		clc
		adc VERA_ADDR_MID
		sta VERA_ADDR_MID
		bcc loopa
		inc VERA_ADDR_HI
loopa:
		lda startRow
		clc
		adc VERA_ADDR_MID
		sta VERA_ADDR_MID
		bcc fin
		inc VERA_ADDR_HI
fin:
		lda startCol
		jsr AddCwColToVAddr
		rts
.endproc