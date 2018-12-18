	PROCESSOR 6502
    INCLUDE "vcs.h"
	INCLUDE "macro.h"

;==============================================================
;DEFINE CONSTANTS
;--------------------------------------------------------------
SCREEN_SIZE 	= 192
COURT_SIZE 		= 96  ; Size = Size X 2, TODO: to set it to 60
;==============================================================
;END OF CONSTANTS
;==============================================================

;==============================================================
;DEFINE VARIABLES: RAM $80 - $FF
;==============================================================
	SEG.U VARIABLES
	ORG $80

;Player0 Position	
p0_x 	ds 1
p0_y 	ds 1

;Player1 Position	
p1_x 	ds 1
p1_y 	ds 1
		
;Players Draws
p0_draw ds 1
p1_draw ds 1

;Players Pointers
p0_ptr 	ds.w 1 
p1_ptr 	ds.w 1
;==============================================================
;END OF VARIABLES
;==============================================================

;==============================================================
;Start of FILE
;--------------------------------------------------------------
;This is the location where our data is gonna be stored inside
;our CARTRIDGE
;==============================================================	
	SEG CODE
	ORG $F000
    
;=====================================================	
;Position Object:
;-----------------------------------------------------
;This will move our sprite to the desired location
;-----------------------------------------------------
;A = Destination
;X = Desired Sprite
;-----------------------------------------------------
PosObj:
	sec
	sta WSYNC
	
DivLoop:
	sbc #15
	bcs DivLoop
	
	eor #7
	asl
	asl
	asl
	asl
	
	sta.wx HMP0,X
	sta RESP0,X
	rts	
		
;=====================================================
;RESET
;-----------------------------------------------------
;When you push down the GAME RESET switch, it will
;cause an iterrrupt and set te PC (Pointer Counter)
;at this memory location 
;=====================================================
Reset
	ldy #1
	sty VDELP1
	
	ldx #$40
	stx COLUBK
;=====================================================
;END OF RESET
;=====================================================

;=====================================================
;MAIN FRAME LOOP
;-----------------------------------------------------
;This is where all our ur instructions and data is
;going to be processed and give us an output for our
;FRAME
;=====================================================	
StartOfFrame

    ; Start of vertical blank processing
    lda #0
    sta VBLANK

    lda #2
    sta VSYNC
    
	;---------------------------------------------;
	;VERTICAL SYNC:	3 scanlines of VSYNCH signal..;
	;---------------------------------------------;
	ldy #3
VerticalSync:	
	sta WSYNC
	dey
	bne VerticalSync

    lda #0
    sta VSYNC           

    ; 37 scanlines of vertical blank...
	ldy #32
VerticalBlank:	
    sta WSYNC
	dey
	bne VerticalBlank
    
    ;----------------------;
    ;--INPUT: Controllers--;
	;----------------------;
	;Player 0 INPUT
	lda #%10000000
	bit SWCHA
	beq RIGHT_p0

	lda #%01000000
	bit SWCHA
	beq LEFT_p0
	
	lda #%00100000
	bit SWCHA
	beq DOWN_p0
	
	lda #%00010000
	bit SWCHA
	beq UP_p0
	
	jmp P1_INPUT
	
RIGHT_p0:
	inc p0_x
    jmp P1_INPUT
LEFT_p0:
	dec p0_x
    jmp P1_INPUT
DOWN_p0:
	dec p0_y
    jmp P1_INPUT    
UP_p0:
	inc p0_y
    jmp P1_INPUT  
	
	;Player 1 INPUT
P1_INPUT:
	lda #%00001000
	bit SWCHA
	beq RIGHT_p1

	lda #%00000100
	bit SWCHA
	beq LEFT_p1
	
	lda #%00000010
	bit SWCHA
	beq DOWN_p1
	
	lda #%00000001
	bit SWCHA
	beq UP_p1
	
	jmp EXIT_INPUT
	
RIGHT_p1:
	inc p1_x
    jmp EXIT_INPUT
LEFT_p1:
	dec p1_x
    jmp EXIT_INPUT
DOWN_p1:
	dec p1_y
    jmp EXIT_INPUT    
UP_p1:
	inc p1_y
    jmp EXIT_INPUT  
    
EXIT_INPUT:	
	;Move Object on X coordinates
	;Move Player 0	
	lda p0_x
	ldx #0
	jsr PosObj
    
    ;Move Player 1
    lda p1_x
	ldx #1
	jsr PosObj
	
	;Set Wait Sync and set HMOVE to apply fine/precisse possition
	sta WSYNC
    sta HMOVE 
    
    ;----------------------;
    ;--2 Line Kernel data--;
	;----------------------;
	;Player 0 Draw Data
	lda #(COURT_SIZE + PLAYER_HEIGHT)
	sec
	sbc p0_y
	sta p0_draw
	;Player 0 Pointer
	lda #<(PLAYER_SPRITE + PLAYER_HEIGHT - 1)
	sec
	sbc p0_y
	sta p0_ptr
	lda #>(PLAYER_SPRITE + PLAYER_HEIGHT - 1)
	sbc #0
	sta p0_ptr+1
	;Player 1 Draw Data
	lda #(COURT_SIZE + PLAYER_HEIGHT)
	sec
	sbc p1_y
	sta p1_draw
	;Player 1 Pointer
	lda #<(PLAYER_SPRITE + PLAYER_HEIGHT - 1)
	sec
	sbc p1_y
	sta p1_ptr
	lda #>(PLAYER_SPRITE + PLAYER_HEIGHT - 1)
	sbc #0
	sta p1_ptr+1
    sta WSYNC
    ;------------------------;
	;--END OF VERTICAL SYNC--;
	;------------------------;
    
    ;------------------------------------------;
    ;--DISPLAY AREA: 192 scanlines of picture..;
	;------------------------------------------;
    ldy #COURT_SIZE
Court:
	lda #PLAYER_HEIGHT -1
	dcp p0_draw
	bcs DoDrawGRP0
	lda #0
	.byte $2c
	
DoDrawGRP0:
	lda (p0_ptr),Y
	sta WSYNC
	
	sta GRP0
	;TODO: ADD PlayField
	
	lda #PLAYER_HEIGHT -1
	dcp p1_draw
	bcs DoDrawGRP1
	lda #0
	.byte $2c
	
DoDrawGRP1:
	lda (p1_ptr),Y
	sta WSYNC
	
	sta GRP1
	;TODO: ADD Playerfield    
    dey    
    bne Court
	
    lda #%01000010
    sta VBLANK 	; end of screen - enter blanking	
	;-----------------------;
	;--END OF DISPLAY AREA--;
	;-----------------------;

	;---------------------------------------;
	;--OVERSCAN: 30 scanlines of overscan...;
	;---------------------------------------;
	ldy #30
Overscan:	
	sta WSYNC
	dey
	bne Overscan	
	;-------------------;
	;--END OF OVERSCAN--;
	;-------------------;

	jmp StartOfFrame

	;-----------------;
	;--DATA AREA------;
	;--TODO: ADD SEG--;
	;-----------------;

PLAYER_SPRITE:
	.byte %11111111
	.byte %11000011
	.byte %11000011
	.byte %11000011
	.byte %11111111
	
PLAYER_HEIGHT = * - PLAYER_SPRITE 	
	ORG $FFFA	
	;--------------------;
	;--END OF DATA AREA--;
	;--------------------;

	;--------------;
	;--INTERRUPTS--;
	;--------------;
    .word Reset          ; NMI
    .word Reset          ; RESET
    .word Reset          ; IRQ
	
	;---------------;
	;--END OF FILE--;
	;---------------;
   	END
    	