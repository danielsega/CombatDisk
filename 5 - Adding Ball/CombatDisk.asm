	PROCESSOR 6502
    INCLUDE "vcs.h"
    INCLUDE "MyMacro.h"
	INCLUDE "macro.h"
;==============================================================
;DEFINE CONSTANTS
;--------------------------------------------------------------
;Sizes
COURT_SIZE 		= 45  ; Size = Size X 2, Actuall size is 90
BALL_SIZE		= 2

;COLORS
P0_COLOR		= $40
P1_COLOR		= $80
;==============================================================
;END OF CONSTANTS
;==============================================================

;==============================================================
;DEFINE VARIABLES: RAM $80 - $FF
;==============================================================
	SEG.U VARIABLES
	ORG $80
;Temp Value
temp	ds 1				;80

;Random Value
rand 	ds 1				;81

;Player0 Position	
p0_x 	ds 1				;82
p0_y 	ds 1				;83

;Player1 Position	
p1_x 	ds 1				;84
p1_y 	ds 1				;85

;Ball Position
ball_x	ds 1				;86
ball_y	ds 1				;87
		
;Sprites Draws
p0_draw 	ds 1			;88
p1_draw 	ds 1			;89
ball_draw	ds 1			;8A

;Players Pointers
p0_ptr 	ds.w 1 				;8B-8C
p1_ptr 	ds.w 1 				;8D-8E

;Players Frame Counter
p0_frame_counter	ds 1	;8F
p1_frame_counter	ds 1	;90

;Frame per second for each player
p0_fps	ds 1				;91
p1_fps	ds 1				;92

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
	CLEAN_START
	
	ldy #1
	sty VDELP0
	
	ldx #$E8
	stx COLUBK
	
	ldx #P0_COLOR
	stx COLUP0
	
	ldx #P1_COLOR
	stx COLUP1
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
	
;============================================================
;START OF VERTICAL BLANK : 37 scanlines of vertical blank...
;============================================================

	ldy #44
	sty TIM64T
    
	;=====================================================
	;INPUT: Controllers
	;-----------------------------------------------------
	;The game was made in made with playing with the 
	;default joystick that comes with the Atari 2600
	;=====================================================	

	;--------------;
	;Player 0 INPUT;
	;--------------;

	;Up and Right Movement
	lda #%10010000
	bit SWCHA
	beq UP_RIGHT_p0		
	
	;Up and Left Movement
	lda #%01010000
	bit SWCHA
	beq UP_LEFT_p0
	
	;Down and Right Movement
	lda #%10100000
	bit SWCHA
	beq DOWN_RIGHT_p0
	
	;Down and Left Movement
	lda #%01100000
	bit SWCHA
	beq DOWN_LEFT_p0
	
	;Right Movement
	lda #%10000000
	bit SWCHA
	beq RIGHT_p0
	
	;Left Movement
	lda #%01000000
	bit SWCHA
	beq LEFT_p0
	
	;Down Movement
	lda #%00100000
	bit SWCHA
	beq DOWN_p0
	
	;Up Movement
	lda #%00010000
	bit SWCHA
	beq UP_p0
	
	;If nothing was pressed
	lda #0
	sta REFP0				;Set it to always face right
	sta p0_frame_counter	;IDLE frame
	
	jmp P1_INPUT

UP_RIGHT_p0:
	inc p0_x
	inc p0_y
	
	lda #0
	sta REFP0
	
	jmp MOVE_HORIZONTAL_FRAME_P0
	jmp P1_INPUT
	
UP_LEFT_p0:
	dec p0_x
	inc p0_y
	
	lda #$FF
	sta REFP0
	
	jmp MOVE_HORIZONTAL_FRAME_P0
	jmp P1_INPUT
	
DOWN_RIGHT_p0:
	inc p0_x
	dec p0_y
	
	lda #0
	sta REFP0
	
	jmp MOVE_HORIZONTAL_FRAME_P0
	jmp P1_INPUT
	
DOWN_LEFT_p0:
	dec p0_x
	dec p0_y
	
	lda #$FF
	sta REFP0
	
	jmp MOVE_HORIZONTAL_FRAME_P0
	jmp P1_INPUT	
						
RIGHT_p0:
	inc p0_x
	
	lda #0
	sta REFP0
	
	jmp MOVE_HORIZONTAL_FRAME_P0
    jmp P1_INPUT
    
LEFT_p0:
	dec p0_x
	
	lda #$FF
	sta REFP0
	
	jmp MOVE_HORIZONTAL_FRAME_P0
    jmp P1_INPUT
    
DOWN_p0:
	dec p0_y
	
	jmp MOVE_VERTICAL_FRAME_P0
    jmp P1_INPUT 
       
UP_p0:
	inc p0_y
	
	jmp MOVE_VERTICAL_FRAME_P0
    jmp P1_INPUT  
    
    ;MACROS
MOVE_HORIZONTAL_FRAME_P0:
	ANI_CHANGE_FRAME p0_fps, P1_INPUT, p0_frame_counter, 1, 3
MOVE_VERTICAL_FRAME_P0:
	ANI_CHANGE_FRAME p0_fps, P1_INPUT, p0_frame_counter, 4, 6
	
	;--------------;
	;Player 1 INPUT;
	;--------------;
P1_INPUT:
	;Up and Right Movement
	lda #%00001001
	bit SWCHA
	beq UP_RIGHT_p1
	
	;Up and Left Movement
	lda #%00000101
	bit SWCHA
	beq UP_LEFT_p1
	
	;Down and Right Movement
	lda #%00001010
	bit SWCHA
	beq DOWN_RIGHT_p1
	
	;Down and Left Movement
	lda #%00000110
	bit SWCHA
	beq DOWN_LEFT_p1
	
	;Right Movement
	lda #%00001000
	bit SWCHA
	beq RIGHT_p1

	;Left Movement
	lda #%00000100
	bit SWCHA
	beq LEFT_p1
	
	;Down Movement
	lda #%00000010
	bit SWCHA
	beq DOWN_p1
	
	;Up Movement
	lda #%00000001
	bit SWCHA
	beq UP_p1
	
	;If nothing was pressed
	lda #$FF
	sta REFP1 				;Set it to alwasy face left	
	lda #0
	sta p1_frame_counter	;IDLE Animation
	
	jmp EXIT_INPUT

UP_RIGHT_p1:
	inc p1_x
	inc p1_y
	
	lda #0
	sta REFP1
	
	jmp MOVE_HORIZONTAL_FRAME_P1	
	jmp EXIT_INPUT
	
UP_LEFT_p1:
	dec p1_x
	inc p1_y
	
	lda #$FF
	sta REFP1
	
	jmp MOVE_HORIZONTAL_FRAME_P1
	jmp EXIT_INPUT
	
DOWN_RIGHT_p1:
	inc p1_x
	dec p1_y
	
	lda #0
	sta REFP1
	
	jmp MOVE_HORIZONTAL_FRAME_P1
	jmp EXIT_INPUT
	
DOWN_LEFT_p1:
	dec p1_x
	dec p1_y
	
	lda #$FF
	sta REFP1
	
	jmp MOVE_HORIZONTAL_FRAME_P1
	jmp EXIT_INPUT
	
RIGHT_p1:
	inc p1_x
	
	lda #0
	sta REFP1
	
	jmp MOVE_HORIZONTAL_FRAME_P1
    jmp EXIT_INPUT
    
LEFT_p1:
	dec p1_x
	
	lda #$FF
	sta REFP1
	
	jmp MOVE_HORIZONTAL_FRAME_P1
    jmp EXIT_INPUT
    
DOWN_p1:
	dec p1_y
	
	jmp MOVE_VERTICAL_FRAME_P1
    jmp EXIT_INPUT
    
UP_p1:
	inc p1_y
	
	jmp MOVE_VERTICAL_FRAME_P1
    jmp EXIT_INPUT
      
	
	;--Macros
MOVE_HORIZONTAL_FRAME_P1:
	ANI_CHANGE_FRAME p1_fps, EXIT_INPUT, p1_frame_counter, 1, 3
MOVE_VERTICAL_FRAME_P1:
	ANI_CHANGE_FRAME p1_fps, EXIT_INPUT, p1_frame_counter, 4, 6
	    
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
	
	;Move Ball
	inc ball_x
	inc ball_y
	
	lda ball_x
	ldx #4
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
	ldx p1_frame_counter
	
	lda PLAYER_ANIMATION_LOW_PTR,X	
	sec
	sbc p1_y
	sta p1_ptr
	lda PLAYER_ANIMATION_HIGH_PTR,X
	sbc #0
	sta p1_ptr+1
    sta WSYNC
    
    ;Ball Data
    lda #(COURT_SIZE + BALL_SIZE)
    sec
    sbc ball_y
    sta ball_draw
    
VerticalBlank:
	lda INTIM
	sta WSYNC
	bne VerticalBlank
    ;-------------------------;
	;--END OF VERTICAL BLANK--;
	;-------------------------;
    
    ;------------------------------------------;
    ;--DISPLAY AREA: 192 scanlines of picture..;
	;------------------------------------------;
	
	;--START OF SCOREBOARD
	lda #0
	sta COLUBK
	
	REPEAT 30
		sta WSYNC
	REPEND
	
	;--START OF TOP BACKGROUND
	lda #4
	sta COLUBK
	
	REPEAT 37
		sta WSYNC
	REPEND
	
	lda #$F8
	sta COLUBK
	;--START OF COURT
	
	;Space for top of the court
	REPEAT 2
		sta WSYNC
	REPEND
	;Setup playfield
	ldx #%00100001
	stx CTRLPF
	
	lda #%10000000
	sta PF0
	lda #$FF
	sta PF1
	sta PF2
	
	;TOP part of the COURT
	REPEAT 4
		sta WSYNC
	REPEND	
	
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
	
	ldx #1
	lda #BALL_SIZE
	dcp ball_draw
	bcs DoBall
	lda #0
	.byte $24

DoBall:
	inx
		
	lda #PLAYER_HEIGHT-1
	dcp p1_draw
	bcs DoDrawGRP1
	lda #0
	.byte $2c
	
DoDrawGRP1:
	lda (p1_ptr),Y
	sta WSYNC
	
	sta GRP1
	
	;PLAYFIELD
	lda #0
	sta PF1
	
	stx ENABL
	
	lda #%10000000
	sta PF2
	
    dey    
    bne Court	

	lda #$FF
	sta PF1
	sta PF2
	
	;BOTTOM part of the COURT
	REPEAT 6
		sta WSYNC
	REPEND
	
	lda #0
	sta PF0
	sta PF1
	sta PF2
	
	;Space for between the court and the background playfield
	REPEAT 2
		sta WSYNC
	REPEND
	
	;--START OF BOTTOM BACKGROUND
	lda #4
	sta COLUBK
	
	REPEAT 20
		sta WSYNC
	REPEND
	
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
    	