;---------------------------------------------------
;
;	    STAT30 RSX PROGRAM, Ver. 1
;	     Written by David Krasner
;		and Martin Murray
;		   April 1984
;
;		System Solutions
;		P.O. Box 35972
;		Dallas, Texas 75235
;
;		(214) 351-6117
;
; Released to the Public Domain on 4/9/84
;---------------------------------------------------

;	--- BDOS Function Equates ---

curdsk	equ	25	;get default disk
getadd	equ	31	;get DPB address
getalo	equ	27	;get the Allocation Vector
getfre	equ	46	;get number of free sectors
scbf	equ	49	;get the SCB
sdmaf	equ	26	;set DMA

;---------------------------------------------------

;	--- RSX prefix ---

serial:	db	0,0,0,0,0,0	;cpm compatable

start:	jmp	test	;start of program

next:	db	jmp	;jump instruction to next
	dw	0	;  module in line (BDOS?)
prev:	dw	0	;previous module
remove:	db	0	;remove flag = remain
bank:	db	0	;bank flag = both types
rsxnm:	db	'STAT30  '	;rsx name (8 chars.)
loader:	db	0	;loader flag = normal rsx
	db	0,0	;reserved area

;---------------------------------------------------

;program test for interception
test:
	mov	a,c	;put function in C
	cpi	getalo	;is it function 27?
	jnz	next	;no--pass to next in line

;	--- Mainline ---

;save user's stack
	lxi	h,0	;save user's
	dad	sp	;  stack address
	shld	savstk	;  and set up
	lxi	sp,stak	;  RSX's stack

;save user's dma
	lxi	h,scbpb+1 ;point to SET in scbpb
	mvi	m,0	;set for get operation
	dcx	h	;point to OFFSET in scbpb
	mvi	m,3ch	;offset for current DMA
	xchg		;put scbpb addr. in DE
	mvi	c,scbf	;function 49
	call	next	;get current dma from BDOS
	shld	savdma	;save user's dma address
	lxi	d,dma	;RSX's dma set
	push	d	;save dma for later use
	mvi	c,sdmaf	;  via function 26
	call	next	;set RSX's dma (BDOS)

;get the required parameters from the DPB
	mvi	c,getadd	;function 31
	call	next	;get DPB address from BDOS
	inx	h	;point to BSH
	inx	h
	mov	a,m	;get BSH
	sta	bsh	;save it
	inx	h	;point to DSM
	inx	h
	inx	h
	mov	e,m	;move DSM into DE
	inx	h
	mov	d,m
	xchg		;now into HL
	shld	dsm	;save it

;get the number of free sectors
	mvi	c,curdsk ;get default drive
	call	next	;BDOS function 25
	mov	e,a	;put in E
	mvi	c,getfre ;get disk free space
	call	next	;BDOS function 46
	pop	h	;get back dma address
			; (dma contains the amount
			;  of free space in sectors)
;calculate free blocks
	mov	e,m	;get LSB into E
	inx	h
	mov	d,m	;get MSB into D
	inx	h
	mov	a,m	;get HSB into A
	push	psw	;  and save it
	xchg		;free sectors to HL
	call	blocker	;number of blocks
	xchg		;save block count in DE
	pop	psw	;get HSB back
	mov	b,a	;put it in B
loop:
	mov	a,b	;put HSB into A
	ora	a	;is it zero?
	jz	create	;yes--jump
	dcr	b	;decrement HSB
	lxi	h,8000h	;10000h records for every
			;  count here, so do it
	call	blocker	;  twice and make it blocks
	xchg
	dad	d	;add to previous block
	dad	d	;  count as true value
	xchg
	jmp	loop

create:
	lhld	dsm	;get DSM and increment
	inx	h	;  to a physical value
	lxi	b,alv	;point to ALV with BC
nxtbyt:
	push	b	;save ALV pointer
	mvi	c,8	;set bit counter
nxtbit:
	mov	b,a	;save A
	mov	a,e	;is the free block
	ora	d	;  count zero?
	stc		;set C flag
	jz	notfree	;jump--free block zero
	cmc		;reset C flag
	dcx	d	;decrement free block count
notfree:
	mov	a,b	;restore A
	ral		;rotate it with carry
	dcx	h	;decrement DSM count
	mov	b,a	;save ALV byte
	mov	a,l	;is the DSM
	ora	h	;  count zero?
	mov	a,b	;restore ALV byte
	jz	fill	;jump--DSM zero
	dcr	c	;decrement bit counter
	jnz	nxtbit	;continue bit making
	pop	b	;get ALV pointer
	stax	b	;save ALV byte
	inx	b	;increment ALV pointer
	jmp	nxtbyt	;continue byte making

fill:
	dcr	c	;decrement bit counter
	jz	exit	;finish creating A.L. table
	ral		;move the significant bits
	jmp	fill	;continue

;	--- Exit to User Program ---

exit:
	pop	b	;restore ALV pointer
	stax	b	;save ALV byte

	lhld	savdma	;get user's dma address
	xchg		;  back and restore it
	mvi	c,sdmaf	;  via function 26
	call	next

	lhld	savstk	;get user's stack address
	sphl		;  back and restore it

	lxi	h,alv	;point to ALV address
	ret

;	--- Support Routines ---

blocker:
	lda	bsh	;load bsh as counter
hlrotr:
	push	psw	;save counter
	sub	a	;clear C flag
	mov	a,h	;load MSB
	rar		;rotate it
	mov	h,a	;put it back
	mov	a,l	;load LSB
	rar		;rotate it with carry
	mov	l,a	;put it back
	pop	psw	;get counter back
	dcr	a	;decrement it
	rz		;return if done
	jmp	hlrotr	;  else continue

;	--- Data Area ---

bsh:	db	0	;block shift factor
dsm:	dw	0	;disk size maximum

savdma:	dw	0	;user's DMA address
savstk:	dw	0	;user's stack address
	ds	10	;5 level stack for RSX
stak:

;common data area for work and allocation block
scbpb:
dma:
alv:
	ds	256
