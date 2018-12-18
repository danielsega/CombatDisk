	PROCESSOR 6502
    INCLUDE "vcs.h"
	INCLUDE "macro.h"
;==============================================================
;DEFINE CONSTANTS
;--------------------------------------------------------------
SCREEN_SIZE 	= 192
COURT_SIZE 		= 96  ; Size = Size X 2, TODO: to set it to 60
FPS				= 8
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

;Players Frame Counter
p0_frame_counter	ds 1
p1_frame_counter	ds 1

;Frame per second for each player
p0_fps	ds 1
p1_fps	ds 1
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
	jmp MOVE_RIGHT_FRAME
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
    
MOVE_RIGHT_FRAME:
	lda p0_fps
	cmp FPS
	beq .inc_frame
	inc p0_fps
	jmp P1_INPUT
	 
.inc_frame:
	ldx #0
	stx p0_fps
		 
	inc p0_frame_counter
	
	lda p0_frame_counter
	
	;Check if p0_frame_counter is out of range
	cmp #1
	bcc .out_of_range
	cmp #3+1
	bcs .out_of_range
	
	jmp P1_INPUT
.out_of_range:
	ldx #1
	stx p0_frame_counter
	 
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
	ldx p0_frame_counter
	
	lda PLAYER_ANIMATION_LOW_PTR,X
	sec
	sbc p0_y
	sta p0_ptr
	lda PLAYER_ANIMATION_HIGH_PTR,X
	sbc #0
	sta p0_ptr+1
	;Player 1 Draw Data
	lda #(COURT_SIZE + PLAYER_HEIGHT)
	sec
	sbc p1_y
	sta p1_draw
	;Player 1 Pointer
	lda #<(PLAYER_IDLE + PLAYER_HEIGHT - 1)
	sec
	sbc p1_y
	sta p1_ptr
	lda #>(PLAYER_IDLE + PLAYER_HEIGHT - 1)
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

PLAYER_ANIMATION_LOW_PTR:
		.byte <(PLAYER_IDLE + PLAYER_HEIGHT - 1)		;0
		.byte <(PLAYER_MOVE_LF0 + PLAYER_HEIGHT - 1)	;1
		.byte <(PLAYER_MOVE_LF1 + PLAYER_HEIGHT - 1)	;2
		.byte <(PLAYER_MOVE_LF2 + PLAYER_HEIGHT - 1)	;3
		.byte <(PLAYER_MOVE_UD0 + PLAYER_HEIGHT - 1)	;4
		.byte <(PLAYER_MOVE_UD1 + PLAYER_HEIGHT - 1)	;5
		.byte <(PLAYER_MOVE_UD2 + PLAYER_HEIGHT - 1)	;6
		
PLAYER_ANIMATION_HIGH_PTR:
		.byte >(PLAYER_IDLE + PLAYER_HEIGHT - 1)		;0
		.byte >(PLAYER_MOVE_LF0 + PLAYER_HEIGHT - 1)	;1
		.byte >(PLAYER_MOVE_LF1 + PLAYER_HEIGHT - 1)	;2
		.byte >(PLAYER_MOVE_LF2 + PLAYER_HEIGHT - 1)	;3
		.byte >(PLAYER_MOVE_UD0 + PLAYER_HEIGHT - 1)	;4
		.byte >(PLAYER_MOVE_UD1 + PLAYER_HEIGHT - 1)	;5
		.byte >(PLAYER_MOVE_UD2 + PLAYER_HEIGHT - 1)	;6
	;-------------;
	;--ANIMATION--;
	;-------------;
PLAYER_IDLE:
PLAYER_MOVE_LF0:
        .byte #%00111100;--
        .byte #%00101000;--
        .byte #%00010000;--
        .byte #%01011100;--
        .byte #%00111000;--
        .byte #%00000000;--
        .byte #%00011000;--
        .byte #%00011000;--
PLAYER_HEIGHT = * - PLAYER_IDLE

	;--Player Movement for Left and Right--;
PLAYER_MOVE_LF1:
        .byte #%00110000;--
        .byte #%00101100;--
        .byte #%00111000;--
        .byte #%00111000;--
        .byte #%00111000;--
        .byte #%00000000;--
        .byte #%00011000;--
        .byte #%00011000;--
PLAYER_MOVE_LF2:
        .byte #%00001100;--
        .byte #%00111000;--
        .byte #%00101000;--
        .byte #%01011100;--
        .byte #%00111000;--
        .byte #%00000000;--
        .byte #%00011000;--
        .byte #%00011000;-
		
	;--Player Movement for Up and Down--;
PLAYER_MOVE_UD0:
		.byte #%00110000;--
        .byte #%00011100;--
        .byte #%00011000;--
        .byte #%00011010;--
        .byte #%00111100;--
        .byte #%01000000;--
        .byte #%00011000;--
        .byte #%00011000;--
PLAYER_MOVE_UD1:
		.byte #%01100110;--
        .byte #%00111100;--
        .byte #%00011000;--
        .byte #%00111100;--
        .byte #%00111100;--
        .byte #%00000000;--
        .byte #%00011000;--
        .byte #%00011000;--	
PLAYER_MOVE_UD2:
        .byte #%00001100;--
        .byte #%00111000;--
        .byte #%00011000;--
        .byte #%01011000;--
        .byte #%00111100;--
        .byte #%00000010;--
        .byte #%00011000;--
        .byte #%00011000;--

	;--Player Throwing Disc--;
PLAYER_THROWING0:
        .byte #%00110000;--
        .byte #%00101100;--
        .byte #%00011000;--
        .byte #%01011100;--
        .byte #%00111000;--
        .byte #%00000000;--
        .byte #%00011000;--
        .byte #%00011000;--
PLAYER_THROWING1:
        .byte #%00011100;--
        .byte #%00011000;--
        .byte #%00011000;--
        .byte #%00011100;--
        .byte #%01111100;--
        .byte #%00000000;--
        .byte #%00001100;--
        .byte #%00001100;--
PLAYER_THROWING2:
        .byte #%00101100;--
        .byte #%00111000;--
        .byte #%00011000;--
        .byte #%00111000;--
        .byte #%00011110;--
        .byte #%00000000;--
        .byte #%00011000;--
        .byte #%00011000;--
PLAYER_JUMP_LF0:
        .byte #%00000000;--
        .byte #%00001000;--
        .byte #%10010000;--
        .byte #%01101100;--
        .byte #%01101100;--
        .byte #%10010000;--
        .byte #%00001000;--
        .byte #%00000000;--
PLAYER_JUMP_LF1:
        .byte #%00000000;--
        .byte #%00000110;--
        .byte #%11001000;--
        .byte #%00110110;--
        .byte #%00110110;--
        .byte #%11001000;--
        .byte #%00000110;--
        .byte #%00000000;--
PLAYER_JUMP_LF2:
        .byte #%00000000;--
        .byte #%10001110;--
        .byte #%01010000;--
        .byte #%00110110;--
        .byte #%00110110;--
        .byte #%01010000;--
        .byte #%10001110;--
        .byte #%00000000;--
PLAYER_JUMP_LF_STILL:
        .byte #%00000010;--
        .byte #%10000101;--
        .byte #%01001000;--
        .byte #%00110110;--
        .byte #%00110110;--
        .byte #%01001000;--
        .byte #%10000101;--
        .byte #%00000010;--
PLAYER_JUMP_UD0:
        .byte #%00100100;--
        .byte #%00011000;--
        .byte #%00011000;--
        .byte #%00100100;--
        .byte #%01011010;--
        .byte #%00011000;--
        .byte #%00000000;--
        .byte #%00000000;--
PLAYER_JUMP_UD1:
        .byte #%00100100;--
        .byte #%00100100;--
        .byte #%00011000;--
        .byte #%00011000;--
        .byte #%00100100;--
        .byte #%01011010;--
        .byte #%00011000;--
        .byte #%00000000;--
PLAYER_JUMP_UD2:
        .byte #%00000000;--
        .byte #%00100100;--
        .byte #%00100100;--
        .byte #%00011000;--
        .byte #%00011000;--
        .byte #%00100100;--
        .byte #%01011010;--
        .byte #%01011010;--
PLAYER_JUMP_UD_STILL:
        .byte #%00100100;--
        .byte #%00100100;--
        .byte #%00011000;--
        .byte #%00011000;--
        .byte #%00100100;--
        .byte #%01011010;--
        .byte #%01011010;--
        .byte #%00100100;--
	;--------------------;
	;--END OF ANIMATION--;
	;--------------------;
	
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
    	