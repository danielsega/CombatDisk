	PROCESSOR 6502
    INCLUDE "vcs.h"
    INCLUDE "MyMacro.h"
	INCLUDE "macro.h"
;==============================================================
;DEFINE CONSTANTS
;--------------------------------------------------------------
;Sizes
COURT_SIZE 		= 45 	;Size = Size X 2, Actuall size is 90
BALL_SIZE		= 2
SUPER_SIZE		= 4

;COLORS
P0_COLOR		= $40	;RED
P1_COLOR		= $84	;BLUE

;DIRECTIONS VALUES
DIR_RIGHT		= 1
DIR_LEFT 		= 2
DIR_UP 			= 3
DIR_DOWN		= 4
DIR_SKIP		= 5
;==============================================================
;END OF CONSTANTS
;==============================================================

;==============================================================
;DEFINE VARIABLES: RAM $80 - $FF
;==============================================================
	SEG.U VARIABLES
	ORG $80
	
;Temp Value
temp				ds 1		;80

;Random Value
rand 				ds 1		;81

;Player0 Position	
p0_x 				ds 1		;82
p0_y 				ds 1		;83

;Player1 Position	
p1_x 				ds 1		;84
p1_y 				ds 1		;85

;Ball Position
ball_x				ds 1		;86
ball_y				ds 1		;87

;Player 0 Velocity
p0_vel				ds 1		;88

;Player 1 Velocity
p1_vel				ds 1		;89

;Ball Velocity
ball_vel_x			ds 1		;8A
ball_vel_y			ds 1		;8B
		
;Sprites Draws
p0_draw 			ds 1		;8C
p1_draw 			ds 1		;8D
ball_draw			ds 1		;8E

;Players Pointers
p0_ptr 				ds.w 1 		;8F-90
p1_ptr 				ds.w 1 		;91-92

;Players Frame Counter
p0_frame_counter	ds 1		;93
p1_frame_counter	ds 1		;94

;Frame per second for each player
p0_fps				ds 1		;95
p1_fps				ds 1		;96

;Game Points
p0_points			ds 1		;97
p1_points			ds 1		;98

;Digit graphics for the scoreboard
p0_digit_gfx 		ds 1		;99
p1_digit_gfx 		ds 1		;9A

;Digits from the scoreboard from players points
digit_ones			ds.w 1		;9B-9C
digit_tens			ds.w 1		;9D-9E

;Check if players are throwing: 
is_p0_throwing		ds 1		;9F
is_p1_throwing		ds 1		;A0

;Timer for when players have to throw
p0_has_to_throw		ds 1		;A1
p1_has_to_throw		ds 1		;A2

;Check the direction player jumped
p0_jump_dir			ds 1		;A3
p1_jump_dir			ds 1		;A4

;Timer that player doesn't move
p0_still_timer		ds 1		;A5
p1_still_timer		ds 1		;A6

;Game Timer
timer				ds 6		;A7-AC

;Frame timer
current_frame_timer			ds 1		;AD

;Hold Player Sets wins
p0_won_set			ds 1		;AE
p1_won_set			ds 1		;AF

;Game Current Set
game_set			ds 1		;B0

;Save reflect value
p0_reflect			ds 1		;B1
p1_reflect			ds 1		;B2

;Current Display game set
current_display_gs	ds 1		;B3

;Set Won values to merge with graphics
p0_merger			ds 1		;B4
p1_merger			ds 1		;B5
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

;SUBROUTINES
    
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
;Move Objects and Check Collision
;=====================================================

;--PLAYER 0 Movement
p0_move_up:
	MOVECX_ADD_AND_CMP p0_y, p0_vel, #COURT_SIZE	
	rts
p0_move_down:
	MOVECX_SBC_AND_CMP p0_y, p0_vel, #9	
	rts
p0_move_left:
	MOVECX_SBC_AND_CMP p0_x, p0_vel, #$f
	rts
p0_move_right:
	MOVECX_ADD_AND_CMP p0_x, p0_vel, #$46
	rts
	
;--PLAYER 1 Movement
p1_move_up:
	MOVECX_ADD_AND_CMP p1_y, p1_vel, #COURT_SIZE	
	rts
p1_move_down:
	MOVECX_SBC_AND_CMP p1_y, p1_vel, #9	  
	rts
p1_move_left:
	MOVECX_SBC_AND_CMP p1_x, p1_vel, #$50
	rts
p1_move_right:
	MOVECX_ADD_AND_CMP p1_x, p1_vel, #$89
	rts
	
;New Game Set after timer is over	
new_gameset_reset:	
	lda #$ff
	sta timer
	sta timer+1
	sta timer+2
	sta timer+3
	sta timer+4
	sta timer+5

	;Set Position X for player to the middle of their court
	lda #42
	sta p0_x
	lda #108
	sta p1_x
	
	;Set players to middle of the screen
	lda #27
	sta p0_y
	sta p1_y
	
	rts
	
;Get PNRG value	
get_random:
	lda rand
    beq doEor
    asl
    beq noEor
    bcc noEor
doEor:
    eor #$1d
noEor:
	sta rand
    rts

;P0 start with ball in the start of the Set
p0_gets_ball
	;Ball X Position
	lda #70
	sta ball_x
	;Ball Y Position
	lda #COURT_SIZE
	sta ball_y
	;Ball X and Y Velocity
	lda #$ff
	sta ball_vel_x
	sta ball_vel_y
	rts	

;P1 start with ball in the start of the Set	
p1_gets_ball
	;Ball X Position
	lda #85
	sta ball_x
	;Ball Y Position
	lda #COURT_SIZE
	sta ball_y
	;Ball Velocity X Position
	lda #1
	sta ball_vel_x
	;Ball Velocity Y Position
	lda #$ff
	sta ball_vel_y
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
	sty p0_vel
	sty p1_vel
	sty ball_vel_x
	sty ball_vel_y
	sty game_set
	
	;Set TIMER value to full
	lda #$ff
	sta timer
	sta timer+1
	sta timer+2
	sta timer+3
	sta timer+4
	sta timer+5

	;Set Position X for player to the middle of their court
	lda #42
	sta p0_x
	lda #108
	sta p1_x
	
	;Set players to middle of the screen
	lda #27
	sta p0_y
	sta p1_y
	
	;Store value into our rand from initial clock value
	lda INTIM
	sta rand
	
	;Check which start with ball based on initial clock value
	bmi p0_starts_with_ball
	jsr p1_gets_ball
	.byte $2c
p0_starts_with_ball:
	jsr p0_gets_ball
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

	inc current_frame_timer

	jsr get_random
	
    ; Start of vertical blank processing
    ldy #0
    sty VBLANK

    lda #2
    sta VSYNC
    
	;---------------------------------------------;
	;VERTICAL SYNC:	3 scanlines of VSYNCH signal..;
	;---------------------------------------------;
	ldx #3
VerticalSync:	
	sta WSYNC
	dex
	bne VerticalSync

    sty VSYNC           
	
;============================================================
;START OF VERTICAL BLANK : 37 scanlines of vertical blank...
;============================================================

	ldx #44
	stx TIM64T
    
	;=====================================================
	;INPUT: Controllers
	;-----------------------------------------------------
	;The game was made in made with playing with the 
	;default joystick that comes with the Atari 2600
	;=====================================================	

	;--------------;
	;Player 0 INPUT;
	;--------------;

P0_INPUT:
	
	;Check if P0 has ball
	bit CXP0FB
	bvs P0_HAS_BALL
	
	;Check if play is still jumping
	lda p0_jump_dir
	beq skip_p0_jump_dir
	jmp P0_JUMP
skip_p0_jump_dir:
	
	;Check if playerjumped
	bit INPT4
	bmi p0_didnt_jump
	jmp P0_JUMP 
p0_didnt_jump:	

	jmp P0_CONTROLLER
	
P0_HAS_BALL:
	;Making sure player is facing right	
	sty p0_reflect
	
	;If player is in the throwing motion go to P0_Throw
	lda is_p0_throwing
	bne P0_THROW
	sty p0_frame_counter
	
	;Increment value to go above 0
	inc p0_has_to_throw
	
	;Check if player press main action button
	bit INPT4
	bpl P0_THROW	
	
	;If player 0 has the ball for too long throw it anyway but slower
	lda p0_has_to_throw
	cmp #240
	bcs THROW_SLOW_p0
	
	jmp P1_INPUT
	
P0_THROW:
	;If p0 is in throwing motion skip to check sprite	
	lda is_p0_throwing
	bne P0_CHECK_SPRITE_FRAME
	
	;Up and Right
	lda #%10010000
	bit SWCHA
	beq THROW_UP_RIGHT_p0		
	
	;Up and Left
	lda #%01010000
	bit SWCHA
	beq THROW_UP_RIGHT_p0
	
	;Down and Right
	lda #%10100000
	bit SWCHA
	beq THROW_DOWN_RIGHT_p0
	
	;Down and Left
	lda #%01100000
	bit SWCHA
	beq THROW_DOWN_RIGHT_p0
	
	;Right
	lda #%1000000
	bit SWCHA
	beq THROW_RIGHT_p0
	
	;Left
	lda #%01000000
	bit SWCHA
	beq THROW_RIGHT_p0
	
	;Down
	lda #%00100000
	bit SWCHA
	beq THROW_DOWN_RIGHT_p0
	
	;Up
	lda #%00010000
	bit SWCHA
	beq THROW_UP_RIGHT_p0
	
THROW_RIGHT_p0:
	;Change value to be other than 0
	inc is_p0_throwing
	
	sty p0_has_to_throw
	sty ball_vel_y
		
	lda #2
	sta ball_vel_x
	jmp P0_CHECK_SPRITE_FRAME
	
THROW_DOWN_RIGHT_p0:
	;Change value to be other than 0
	inc is_p0_throwing
	
	lda #$FF
	sta ball_vel_y
		
	lda #1
	sta ball_vel_x
	jmp P0_CHECK_SPRITE_FRAME
	
THROW_UP_RIGHT_p0:	
	;Change value to be other than 0
	inc is_p0_throwing
	
	lda #1
	sta ball_vel_y
		
	lda #1
	sta ball_vel_x
	jmp P0_CHECK_SPRITE_FRAME
	
THROW_SLOW_p0:
	;Change value to be other than 0
	inc is_p0_throwing
	
	sty p0_has_to_throw
	sty ball_vel_y
		
	lda #1
	sta ball_vel_x	
	
	;Check if it is in the last throwing sprite
P0_CHECK_SPRITE_FRAME:	
	SPRITE_FRAME_CHECKER p0_frame_counter, p0_fps, 9, P0_THROW_BALL, P0_SKIP_TO_THROWING_FRAME
	
P0_THROW_BALL:
	;Reset value to 0
	sty is_p0_throwing
	sta CXCLR
	
	;Set jump dir back to 0
	sty p0_jump_dir
		
	lda ball_x
	adc #9
	sta ball_x
	
P0_SKIP_TO_THROWING_FRAME:	
	jmp THROWING_FRAME_P0

P0_JUMP:
	;-------------------;
	;--COMPARE SECTION--;
	;-------------------;
	lda p0_jump_dir
	
	;Compare to Continue Jump Right
	COMPARE_CONT_JUMP DIR_RIGHT, p0_cont_jump_right
	
	;Compare to Continue Jump Left
	COMPARE_CONT_JUMP DIR_LEFT, p0_cont_jump_left
	
	;Compare to Continue Jump Up
	COMPARE_CONT_JUMP DIR_UP, p0_cont_jump_up
	
	;Compare to Continue Jump Down
	COMPARE_CONT_JUMP DIR_DOWN, p0_cont_jump_down
	
	;Compare to Stop Jumping
	COMPARE_CONT_JUMP DIR_SKIP, p0_stop_jump
	
	;-------------------------------;
	;--CONTROLLER FOR JUMP SECTION--;
	;-------------------------------;

	;Right Jump
	lda #%10000000
	bit SWCHA
	beq JUMP_RIGHT_p0
	
	;Left Jump
	lda #%01000000
	bit SWCHA
	beq JUMP_LEFT_p0
	
	;Down Jump
	lda #%00100000
	bit SWCHA
	beq JUMP_DOWN_p0
	
	;Up Jump
	lda #%00010000
	bit SWCHA
	beq JUMP_UP_p0
	
JUMP_RIGHT_p0:
	;Set the Movement Direction  
	lda #DIR_RIGHT
	sta p0_jump_dir	
	
	;Set Player Velocity to 2 to increase jump speed
	lda #2
	sta p0_vel
	
	;Make it zero for still_timer always have the same input
	sty p0_fps
	
	;Make player face right
	sty p0_reflect
	
	jmp P1_INPUT
	
JUMP_LEFT_p0:
	;Set the Movement Direction  
	lda #DIR_LEFT
	sta p0_jump_dir	
	
	;Set Player Velocity to 2 to increase jump speed
	lda #2
	sta p0_vel
	
	;Make it zero for still_timer always have the same input
	sty p0_fps
	
	;Make player face left
	lda #$ff
	sta p0_reflect
	
	jmp P1_INPUT
	
JUMP_UP_p0:
	;Set the Movement Direction  
	lda #DIR_UP
	sta p0_jump_dir	
	
	;Set Player Velocity to 2 to increase jump speed
	lda #2
	sta p0_vel
	
	;Make it zero for still_timer always have the same input
	sty p0_fps
	
	jmp P1_INPUT
JUMP_DOWN_p0:
	;Set the Movement Direction  
	lda #DIR_DOWN
	sta p0_jump_dir	
	
	;Set Player Velocity to 2 to increase jump speed
	lda #2
	sta p0_vel
	
	;Make it zero for still_timer always have the same input
	sty p0_fps
	
	jmp P1_INPUT
	;--------------------;
	;--CONTINUE SECTION--;
	;--------------------;
	
p0_cont_jump_right: 
	CONT_JUMP_MOVEMENT p0_move_right, p0_frame_counter, p0_fps, p0_vel, 12, JUMP_HORIZONTAL_FRAME_P0, 13, DIR_SKIP, p0_jump_dir, P1_INPUT   
p0_cont_jump_left:
	CONT_JUMP_MOVEMENT p0_move_left, p0_frame_counter, p0_fps, p0_vel, 12, JUMP_HORIZONTAL_FRAME_P0, 13, DIR_SKIP, p0_jump_dir, P1_INPUT
p0_cont_jump_up:
	CONT_JUMP_MOVEMENT p0_move_up, p0_frame_counter, p0_fps, p0_vel, 16, JUMP_VERTICAL_UP_FRAME_P0, 17, DIR_SKIP, p0_jump_dir, P1_INPUT
p0_cont_jump_down:
	CONT_JUMP_MOVEMENT p0_move_down, p0_frame_counter, p0_fps, p0_vel, 20, JUMP_VERTICAL_DOWN_FRAME_P0, 21, DIR_SKIP, p0_jump_dir, P1_INPUT

p0_stop_jump:
	inc p0_still_timer
	
	lda p0_still_timer
	cmp #45
	bcc p0_skip_still
	lda #1
	sta p0_vel
	sty p0_still_timer
	sty p0_jump_dir
p0_skip_still:	
	jmp P1_INPUT

P0_CONTROLLER:
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
	sty p0_reflect				;Set it to always face right
	sty p0_frame_counter	;IDLE frame
	
	jmp P1_INPUT

UP_RIGHT_p0:
	jsr p0_move_up
	jsr p0_move_right
	
	sty p0_reflect
	
	jmp MOVE_HORIZONTAL_FRAME_P0
	
UP_LEFT_p0:
	jsr p0_move_up
	jsr p0_move_left
	
	lda #$FF
	sta p0_reflect
	
	jmp MOVE_HORIZONTAL_FRAME_P0
	
DOWN_RIGHT_p0:
	jsr p0_move_down
	jsr p0_move_right
	
	sty p0_reflect
	
	jmp MOVE_HORIZONTAL_FRAME_P0
	
DOWN_LEFT_p0:
	jsr p0_move_down
	jsr p0_move_left
	
	lda #$FF
	sta p0_reflect
	
	jmp MOVE_HORIZONTAL_FRAME_P0
						
RIGHT_p0:
	jsr p0_move_right
	
	sty p0_reflect
	
	jmp MOVE_HORIZONTAL_FRAME_P0
    
LEFT_p0:
	jsr p0_move_left
	
	lda #$FF
	sta p0_reflect
	
	jmp MOVE_HORIZONTAL_FRAME_P0
    
DOWN_p0:
	jsr p0_move_down
	
	jmp MOVE_VERTICAL_FRAME_P0
       
UP_p0:
	jsr p0_move_up
	
	jmp MOVE_VERTICAL_FRAME_P0
    
    ;MACROS
MOVE_HORIZONTAL_FRAME_P0:
	ANI_CHANGE_FRAME p0_fps, P1_INPUT, p0_frame_counter, 1, 3
MOVE_VERTICAL_FRAME_P0:
	ANI_CHANGE_FRAME p0_fps, P1_INPUT, p0_frame_counter, 4, 6
THROWING_FRAME_P0:
	ANI_CHANGE_FRAME p0_fps, P1_INPUT, p0_frame_counter, 7, 9
JUMP_HORIZONTAL_FRAME_P0:
	ANI_CHANGE_FRAME p0_fps, P1_INPUT, p0_frame_counter, 10, 12
JUMP_VERTICAL_UP_FRAME_P0:
	ANI_CHANGE_FRAME p0_fps, P1_INPUT, p0_frame_counter, 14, 16
JUMP_VERTICAL_DOWN_FRAME_P0:
	ANI_CHANGE_FRAME p0_fps, P1_INPUT, p0_frame_counter, 18, 20		
	;--------------;
	;Player 1 INPUT;
	;--------------;
	
P1_INPUT:
	ldx #$ff
	
	;Check if P0 has ball
	bit CXP1FB
	bvs P1_HAS_BALL
	
	;Check if play is still jumping
	lda p1_jump_dir
	beq skip_p1_jump_dir
	jmp P1_JUMP
skip_p1_jump_dir:
	
	;Check if playerjumped
	bit INPT5
	bmi p1_didnt_jump
	jmp P1_JUMP 
p1_didnt_jump:	

	jmp P1_CONTROLLER
	
P1_HAS_BALL:
	;Making sure player is facing right	
	stx p1_reflect
	
	;If player is in the throwing motion go to P0_Throw
	lda is_p1_throwing
	bne P1_THROW
	sty p1_frame_counter
	
	;Increment value to go above 0
	inc p1_has_to_throw
	
	;Check if player press main action button
	bit INPT5
	bpl P1_THROW	
	
	;If player 0 has the ball for too long throw it anyway but slower
	lda p1_has_to_throw
	cmp #240
	bcs THROW_SLOW_p1
	
	jmp EXIT_INPUT
	
P1_THROW:
	;If p0 is in throwing motion skip to check sprite	
	lda is_p1_throwing
	bne P1_CHECK_SPRITE_FRAME
	
	;Up and Right
	lda #%00001001
	bit SWCHA
	beq THROW_UP_LEFT_p1		
	
	;Up and Left
	lda #%00000101
	bit SWCHA
	beq THROW_UP_LEFT_p1
	
	;Down and Right
	lda #%00001010
	bit SWCHA
	beq THROW_DOWN_LEFT_p1
	
	;Down and Left
	lda #%00000110
	bit SWCHA
	beq THROW_DOWN_LEFT_p1
	
	;Right
	lda #%00001000
	bit SWCHA
	beq THROW_LEFT_p1
	
	;Left
	lda #%00000100
	bit SWCHA
	beq THROW_LEFT_p1
	
	;Down
	lda #%00000010
	bit SWCHA
	beq THROW_DOWN_LEFT_p1
	
	;Up
	lda #%00000001
	bit SWCHA
	beq THROW_UP_LEFT_p1
	
THROW_LEFT_p1:
	;Change value to be other than 0
	inc is_p1_throwing
	
	sty p1_has_to_throw
	sty ball_vel_y
		
	lda #$fe
	sta ball_vel_x
	jmp P1_CHECK_SPRITE_FRAME
	
THROW_DOWN_LEFT_p1:
	;Change value to be other than 0
	inc is_p1_throwing
	
	stx ball_vel_y		
	stx ball_vel_x
	
	jmp P1_CHECK_SPRITE_FRAME
	
THROW_UP_LEFT_p1:	
	;Change value to be other than 0
	inc is_p1_throwing
	
	lda #1
	sta ball_vel_y		
	stx ball_vel_x
	
	jmp P1_CHECK_SPRITE_FRAME
	
THROW_SLOW_p1:	
	;Reset value to 0 
	inc is_p1_throwing
	
	sty p1_has_to_throw
	sty ball_vel_y
		
	stx ball_vel_x	
	
	;Check if it is in the last throwing sprite
P1_CHECK_SPRITE_FRAME:	
	SPRITE_FRAME_CHECKER p1_frame_counter, p1_fps, 9, P1_THROW_BALL, P1_SKIP_TO_THROWING_FRAME
	
P1_THROW_BALL:
	sty is_p1_throwing
	sta CXCLR
	
	;Set jump dir back to 0
	sty p1_jump_dir
	
	sec
	lda ball_x
	sbc #9
	sta ball_x
	
P1_SKIP_TO_THROWING_FRAME:	
	jmp THROWING_FRAME_P1

P1_JUMP:
	;-------------------;
	;--COMPARE SECTION--;
	;-------------------;
	lda p1_jump_dir
	
	;Compare to Continue Jump Right
	COMPARE_CONT_JUMP DIR_RIGHT, p1_cont_jump_right
	
	;Compare to Continue Jump Left
	COMPARE_CONT_JUMP DIR_LEFT, p1_cont_jump_left
	
	;Compare to Continue Jump Up
	COMPARE_CONT_JUMP DIR_UP, p1_cont_jump_up
	
	;Compare to Continue Jump Down
	COMPARE_CONT_JUMP DIR_DOWN, p1_cont_jump_down
	
	;Compare to Stop Jumping
	COMPARE_CONT_JUMP DIR_SKIP, p1_stop_jump
	
	;-------------------------------;
	;--CONTROLLER FOR JUMP SECTION--;
	;-------------------------------;

	;Right Jump
	lda #%00001000
	bit SWCHA
	beq JUMP_RIGHT_p1

	;Left Jump
	lda #%00000100
	bit SWCHA
	beq JUMP_LEFT_p1
	
	;Down Jump
	lda #%00000010
	bit SWCHA
	beq JUMP_DOWN_p1
	
	;Up Jump
	lda #%00000001
	bit SWCHA
	beq JUMP_UP_p1
	
JUMP_RIGHT_p1:
	;Set the Movement Direction  
	lda #DIR_RIGHT
	sta p1_jump_dir	
	
	;Set Player Velocity to 2 to increase jump speed
	lda #2
	sta p1_vel
	
	;Make it zero for still_timer always have the same input
	sty p1_fps
	
	;Make player face left
	sty p1_reflect
	
	jmp EXIT_INPUT
	
JUMP_LEFT_p1:
	;Set the Movement Direction  
	lda #DIR_LEFT
	sta p1_jump_dir	
	
	;Set Player Velocity to 2 to increase jump speed
	lda #2
	sta p1_vel
	
	;Make it zero for still_timer always have the same input
	sty p1_fps
	
	;Make player face right
	stx p1_reflect
	
	jmp EXIT_INPUT
	
JUMP_UP_p1:
	;Set the Movement Direction  
	lda #DIR_UP
	sta p1_jump_dir	
	
	;Set Player Velocity to 2 to increase jump speed
	lda #2
	sta p1_vel
	
	;Make it zero for still_timer always have the same input
	sty p1_fps
	
	jmp EXIT_INPUT
	
JUMP_DOWN_p1:
	;Set the Movement Direction  
	lda #DIR_DOWN
	sta p1_jump_dir	
	
	;Set Player Velocity to 2 to increase jump speed
	lda #2
	sta p1_vel
	
	;Make it zero for still_timer always have the same input
	sty p1_fps
	
	jmp EXIT_INPUT
	;--------------------;
	;--CONTINUE SECTION--;
	;--------------------;
	
p1_cont_jump_right: 
	CONT_JUMP_MOVEMENT p1_move_right, p1_frame_counter, p1_fps, p1_vel, 12, JUMP_HORIZONTAL_FRAME_P1, 13, DIR_SKIP, p1_jump_dir, EXIT_INPUT   
p1_cont_jump_left:
	CONT_JUMP_MOVEMENT p1_move_left, p1_frame_counter, p1_fps, p1_vel, 12, JUMP_HORIZONTAL_FRAME_P1, 13, DIR_SKIP, p1_jump_dir, EXIT_INPUT
p1_cont_jump_up:
	CONT_JUMP_MOVEMENT p1_move_up, p1_frame_counter, p1_fps, p1_vel, 16, JUMP_VERTICAL_UP_FRAME_P1, 17, DIR_SKIP, p1_jump_dir, EXIT_INPUT
p1_cont_jump_down:
	CONT_JUMP_MOVEMENT p1_move_down, p1_frame_counter, p1_fps, p1_vel, 20, JUMP_VERTICAL_DOWN_FRAME_P1, 21, DIR_SKIP, p1_jump_dir, EXIT_INPUT

p1_stop_jump:
	inc p1_still_timer
	
	lda p1_still_timer
	cmp #45
	bcc p1_skip_still
	lda #1
	sta p1_vel
	sty p1_still_timer
	sty p1_jump_dir
p1_skip_still:	
	jmp EXIT_INPUT
	
P1_CONTROLLER:
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
	stx p1_reflect 				;Set it to alwasy face left	
	sty p1_frame_counter	;IDLE Animation
	
	jmp EXIT_INPUT

UP_RIGHT_p1:
	jsr p1_move_up
	jsr p1_move_right
	
	sty p1_reflect
	
	jmp MOVE_HORIZONTAL_FRAME_P1	
	
UP_LEFT_p1:
	jsr p1_move_up
	jsr p1_move_left

	stx p1_reflect
	
	jmp MOVE_HORIZONTAL_FRAME_P1
	
DOWN_RIGHT_p1:
	jsr p1_move_down
	jsr p1_move_right
	
	sty p1_reflect
	
	jmp MOVE_HORIZONTAL_FRAME_P1
	
DOWN_LEFT_p1:
	jsr p1_move_down
	jsr p1_move_left
	
	stx p1_reflect
	
	jmp MOVE_HORIZONTAL_FRAME_P1
	
RIGHT_p1:
	jsr p1_move_right
	
	sty p1_reflect
	
	jmp MOVE_HORIZONTAL_FRAME_P1
    
LEFT_p1:
	jsr p1_move_left
	
	stx p1_reflect
	
	jmp MOVE_HORIZONTAL_FRAME_P1
    
DOWN_p1:
	jsr p1_move_down
	
	jmp MOVE_VERTICAL_FRAME_P1
    
UP_p1:
	jsr p1_move_up
	
	jmp MOVE_VERTICAL_FRAME_P1      
	
	;--Macros
MOVE_HORIZONTAL_FRAME_P1:
	ANI_CHANGE_FRAME p1_fps, EXIT_INPUT, p1_frame_counter, 1, 3
MOVE_VERTICAL_FRAME_P1:
	ANI_CHANGE_FRAME p1_fps, EXIT_INPUT, p1_frame_counter, 4, 6
THROWING_FRAME_P1:
	ANI_CHANGE_FRAME p1_fps, EXIT_INPUT, p1_frame_counter, 7, 9
JUMP_HORIZONTAL_FRAME_P1:
	ANI_CHANGE_FRAME p1_fps, EXIT_INPUT, p1_frame_counter, 10, 12
JUMP_VERTICAL_UP_FRAME_P1:
	ANI_CHANGE_FRAME p1_fps, EXIT_INPUT, p1_frame_counter, 14, 16
JUMP_VERTICAL_DOWN_FRAME_P1:
	ANI_CHANGE_FRAME p1_fps, EXIT_INPUT, p1_frame_counter, 18, 20		
	
EXIT_INPUT:	
	;Move Object on X coordinates

	;Move Missile 0	
	lda #78
	ldx #2
	jsr PosObj
	
	;Move Missile 1	
	lda #80
	ldx #3
	jsr PosObj	
	
	;Move Ball
	lda ball_x
	ldx #4
	jsr PosObj
	 
	;Set Set Won Display 0 to position	
	lda #5
	ldx #0
	jsr PosObj
    
    ;Move Player 1
    lda #147
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
    
    ;--Prep data for scoreboard
	ldx #1
sc_data:
	;Ones Digit
	lda p0_points,X
	and #$0f
	sta temp
	asl
	asl
	adc temp
	sta digit_ones,X
	;Tens Digit
	lda p0_points,X
	and #$f0
	lsr
	lsr
	sta temp
	lsr
	lsr	
	adc temp
	sta digit_tens,X
	dex
	bpl sc_data
	
	;--Game Set Data
	lda game_set
	cmp #1
	beq data_game_set_1 
	cmp #2
	beq data_game_set_2 
	cmp #3
	beq data_game_set_3
	cmp #4
	bcs	data_game_set_ot	
data_game_set_1:
	lda #%01000000
	sta current_display_gs
	jmp exit_data_game_set
data_game_set_2:
	lda #%01010000
	sta current_display_gs
	jmp exit_data_game_set
data_game_set_3:
	lda #%01010100
	sta current_display_gs
	jmp exit_data_game_set
data_game_set_ot:
	lda #%01010101
	sta current_display_gs
exit_data_game_set	

	;--Player Won Set Data
	PLAYER_WON_SET_DATA p0_won_set, p0_merger
	PLAYER_WON_SET_DATA p1_won_set, p1_merger
	
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
	
	;--START OF GUI
	lda #33
	sta TIM64T
	
	lda #0
	sta REFP0
	sta REFP1
	sta COLUBK
	sta WSYNC
	
	ldx #4
set_won_display:
	lda PLAYER_SET_WON_DISPLAY,X
	ora p0_merger
	sta GRP0
	lda PLAYER_SET_WON_DISPLAY,X
	ora p1_merger
	sta GRP1
	dex
	sta WSYNC
	bpl set_won_display
	
	lda #0
	sta GRP0
	sta GRP1
	
	ldy #%00000010
	sty CTRLPF
	
	;lda #$0f
	;sta COLUP0
	;sta COLUP1
	
	sta WSYNC
	SLEEP 41
	sta RESP0
	sta RESP1
	sta WSYNC
	
	;--START OF SCOREBOARD
	ldx #4
sc_loop:
	ldy digit_tens
	lda SB_Digit_Gfx,Y
	and #$f0
	sta p0_digit_gfx
	ldy digit_ones
	lda SB_Digit_Gfx,Y
	and #$0f
	ora p0_digit_gfx
	sta p0_digit_gfx
	sta WSYNC
	
	tay
	lda SET_DISPLAY,X
	sta GRP0
	tya
	sta PF1
	ldy digit_tens+1
	lda SB_Digit_Gfx,Y
	and #$f0
	sta p1_digit_gfx
	ldy digit_ones+1
	lda SB_Digit_Gfx,Y
	and #$0f
	ora p1_digit_gfx
	sta p1_digit_gfx

	sta PF1
	tay
	lda current_display_gs
	sta GRP1
	tya
	ldy p0_digit_gfx
	sta WSYNC
	
	sty PF1
	inc digit_tens
	inc digit_tens+1
	inc digit_ones
	inc digit_ones+1
	SLEEP 12
	dex
	sta PF1
	bpl sc_loop
	sta WSYNC
	
	;Set PF timer color
	lda #$0f
	sta COLUPF
	
	;Set PF off
	ldy #0
	sty PF0
	sty PF1
	sty PF2
	sty GRP0
	sty GRP1
	
	;Set PF to normal
	lda #$0
	sta CTRLPF
	
	;2 line separation from Digits Score to timer
	sta WSYNC
	
	;Set amount of lines for timer
	ldx #2
pf_timer:
	sta WSYNC
	lda timer
	sta PF0
	lda timer+1
	sta PF1
	lda timer+2
	sta PF2
	SLEEP 20
	lda timer+3
	sta PF0
	lda timer+4
	sta PF1
	lda timer+5
	sta PF2
	dex
	bpl pf_timer
	sta WSYNC
	
	;Set PF off and set PF color to black for the court
	sty PF0
	sty PF1
	sty PF2
	sty COLUPF
	
	sta HMCLR
	
	;Set value to REFP registers
	lda p0_reflect
	sta REFP0
	lda p1_reflect
	sta REFP1
	
	;Move Player 0	
	lda p0_x
	ldx #0
	jsr PosObj
    
    ;Move Player 1
    lda p1_x
	ldx #1
	jsr PosObj
	
	sta WSYNC
	sta HMOVE
	
end_of_gui:
	lda INTIM
	sta WSYNC
	bne end_of_gui
	
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
	ldx #%00100101
	stx CTRLPF
	
	;Change size for Missiles
	lda #%00010000
	sta NUSIZ0
	sta NUSIZ1
	
	lda #%10000000
	sta PF0
	lda #$FF
	sta PF1
	sta PF2	
	;Enable Missile for Court Division
	sta ENAM0
	sta ENAM1
	
	;TOP part of the COURT
	REPEAT 4
		sta WSYNC
	REPEND	
									;CPU Clock Time
    ldy #COURT_SIZE					;2
Court:
	lda #PLAYER_HEIGHT -1			;2
	dcp p0_draw						;5
	bcs DoDrawGRP0					;2/3
	lda #0							;2
	.byte $2c						;4/5
	
DoDrawGRP0:
	lda (p0_ptr),Y					;5
	sta WSYNC						;3
	
	sta GRP0						;3
	
	ldx #1							;2
	lda #BALL_SIZE					;2
	dcp ball_draw					;5
	bcs DoBall						;2/3
	lda #0							;2
	.byte $24						;2/3

DoBall:
	inx								;2
		
	lda #PLAYER_HEIGHT-1			;2
	dcp p1_draw						;5
	bcs DoDrawGRP1					;2/3
	lda #0							;2
	.byte $2c						;4/5
	
DoDrawGRP1:
	lda (p1_ptr),Y					;5
	sta WSYNC						;3
	
	sta GRP1						;3
	
	;PLAYFIELD
	lda #0							;2
	sta PF1							;3
	stx ENABL						;3
	sta PF2							;3
	
    dey    							;2
    bne Court						;2/3

	lda #$FF
	sta PF1
	sta PF2
	
	;Added this code to remove tearing
	ldx #0
	stx ENABL
	
	;BOTTOM part of the COURT
	REPEAT 6
		sta WSYNC
	REPEND
	
	lda #0
	sta PF0
	sta PF1
	sta PF2
	;Disenable Missile for Court Division
	sta ENAM0
	sta ENAM1
	
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
	lda #36
	sta TIM64T
	
	;--Change Ball Movement
	lda ball_x
	;Change the carry depending if it is positive or negative
	bpl change_carry_x
	sec
	.byte $24
change_carry_x:
	clc	
	adc ball_vel_x
	sta ball_x
	
	lda ball_y
	;Change the carry depending if it is positive or negative
	bpl change_carry_y
	sec
	.byte $24
change_carry_y:
	clc	
	adc ball_vel_y
	sta ball_y
	
	;Change the ball velocity to negative
	lda ball_y
	cmp #COURT_SIZE
	bcc skip_ball_down
	
	lda #$ff
	sta ball_vel_y	
skip_ball_down:	
	;Change the ball velocity to positive
	lda ball_y
	cmp #3
	bcs skip_ball_up
	
	lda #1
	sta ball_vel_y
skip_ball_up:	
	;Check if Player 1 scored
	lda ball_x
	cmp #$d	
	bcc skip_p1_score
	cmp #$e
	bcs skip_p1_score
	sed
	clc
	lda p1_points
	adc #1
	sta p1_points
	cld

skip_p1_score
	
	;Check if Player 0 scored
	lda ball_x
	cmp #$93
	bcs skip_p0_score
	cmp #$91
	bcc skip_p0_score
	sed
	clc
	lda p0_points
	adc #1
	sta p0_points
	cld
skip_p0_score

	;Check if ball cx Player 0
	lda #%01000000
	bit CXP0FB
	bvc skip_p0_ball
	
	;Ball Collided with PLayer 0
	sec
	lda p0_x
	sbc #2
	sta ball_x	
	lda p0_y
	sbc #5
	sta ball_y
skip_p0_ball:	
	
	;Check if ball cx Player 1
	lda #%01000000
	bit CXP1FB
	bvc skip_p1_ball
	
	;Ball Collided with PLayer 1	
	lda p1_x
	clc
	adc #8
	sta ball_x
	lda p1_y
	sec
	sbc #5
	sta ball_y
skip_p1_ball:	
	
	lda frame_timer
	cmp #15
	beq tick_timer
	
	;Check if timer is over
	and #%00001111
	beq timer_over
	
	jmp timer_exit
	
tick_timer:	
	lsr timer+5
	rol timer+4
	ror timer+3
	lda timer+3
	lsr
	lsr
	lsr
	lsr
	ror timer+2
	rol timer+1
	ror timer
	
	lda #0
	sta frame_timer
	
	;Check for the end of clock
	lda timer
	and #%00001111
	beq timer_over
	jmp timer_exit
	
timer_over:
	inc game_set
	
	lda p0_points
	cmp p1_points
	beq tie_set
	bcc p1_won_this_set
	inc p0_won_set
	jsr new_gameset_reset
	jmp timer_exit
tie_set:
	inc p0_won_set
	inc p1_won_set
	jsr new_gameset_reset
	jmp timer_exit
p1_won_this_set:	
	inc p1_won_set
	jsr new_gameset_reset	
timer_exit:	

Overscan:	
	lda INTIM
	sta WSYNC
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
		.byte <(PLAYER_IDLE + PLAYER_HEIGHT - 1)			;0
		.byte <(PLAYER_MOVE_LF0 + PLAYER_HEIGHT - 1)		;1
		.byte <(PLAYER_MOVE_LF1 + PLAYER_HEIGHT - 1)		;2
		.byte <(PLAYER_MOVE_LF2 + PLAYER_HEIGHT - 1)		;3
		.byte <(PLAYER_MOVE_UD0 + PLAYER_HEIGHT - 1)		;4
		.byte <(PLAYER_MOVE_UD1 + PLAYER_HEIGHT - 1)		;5
		.byte <(PLAYER_MOVE_UD2 + PLAYER_HEIGHT - 1)		;6
		.byte <(PLAYER_THROWING0 + PLAYER_HEIGHT - 1)		;7
		.byte <(PLAYER_THROWING1 + PLAYER_HEIGHT - 1)		;8
		.byte <(PLAYER_THROWING2 + PLAYER_HEIGHT - 1)		;9
		.byte <(PLAYER_JUMP_LF0 + PLAYER_HEIGHT - 1)		;10
		.byte <(PLAYER_JUMP_LF1 + PLAYER_HEIGHT - 1)		;11
		.byte <(PLAYER_JUMP_LF2 + PLAYER_HEIGHT - 1)		;12
		.byte <(PLAYER_JUMP_LF_STILL + PLAYER_HEIGHT - 1)	;13
		.byte <(PLAYER_JUMP_UP0 + PLAYER_HEIGHT - 1)		;14
		.byte <(PLAYER_JUMP_UP1 + PLAYER_HEIGHT - 1)		;15
		.byte <(PLAYER_JUMP_UP2 + PLAYER_HEIGHT - 1)		;16
		.byte <(PLAYER_JUMP_UP_STILL + PLAYER_HEIGHT - 1)	;17
		.byte <(PLAYER_JUMP_DOWN0 + PLAYER_HEIGHT - 1)		;18
		.byte <(PLAYER_JUMP_DOWN1 + PLAYER_HEIGHT - 1)		;19
		.byte <(PLAYER_JUMP_DOWN2 + PLAYER_HEIGHT - 1)		;20
		.byte <(PLAYER_JUMP_DOWN_STILL + PLAYER_HEIGHT - 1)	;21
		
PLAYER_ANIMATION_HIGH_PTR:
		.byte >(PLAYER_IDLE + PLAYER_HEIGHT - 1)			;0
		.byte >(PLAYER_MOVE_LF0 + PLAYER_HEIGHT - 1)		;1
		.byte >(PLAYER_MOVE_LF1 + PLAYER_HEIGHT - 1)		;2
		.byte >(PLAYER_MOVE_LF2 + PLAYER_HEIGHT - 1)		;3
		.byte >(PLAYER_MOVE_UD0 + PLAYER_HEIGHT - 1)		;4
		.byte >(PLAYER_MOVE_UD1 + PLAYER_HEIGHT - 1)		;5
		.byte >(PLAYER_MOVE_UD2 + PLAYER_HEIGHT - 1)		;6
		.byte >(PLAYER_THROWING0 + PLAYER_HEIGHT - 1)		;7
		.byte >(PLAYER_THROWING1 + PLAYER_HEIGHT - 1)		;8
		.byte >(PLAYER_THROWING2 + PLAYER_HEIGHT - 1)		;9
		.byte >(PLAYER_JUMP_LF0 + PLAYER_HEIGHT - 1)		;10
		.byte >(PLAYER_JUMP_LF1 + PLAYER_HEIGHT - 1)		;11
		.byte >(PLAYER_JUMP_LF2 + PLAYER_HEIGHT - 1)		;12
		.byte >(PLAYER_JUMP_LF_STILL + PLAYER_HEIGHT - 1)	;13
		.byte >(PLAYER_JUMP_UP0 + PLAYER_HEIGHT - 1)		;14
		.byte >(PLAYER_JUMP_UP1 + PLAYER_HEIGHT - 1)		;15
		.byte >(PLAYER_JUMP_UP2 + PLAYER_HEIGHT - 1)		;16
		.byte >(PLAYER_JUMP_UP_STILL + PLAYER_HEIGHT - 1)	;17
		.byte >(PLAYER_JUMP_DOWN0 + PLAYER_HEIGHT - 1)		;18
		.byte >(PLAYER_JUMP_DOWN1 + PLAYER_HEIGHT - 1)		;19
		.byte >(PLAYER_JUMP_DOWN2 + PLAYER_HEIGHT - 1)		;20
		.byte >(PLAYER_JUMP_DOWN_STILL + PLAYER_HEIGHT - 1)	;21

	;--------------;
	;--SCOREBOARD--;
	;--------------;
		align 256
		
	;--DIGITS SCORES	
SB_Digit_Gfx:
        .byte %01110111
        .byte %01010101
        .byte %01010101
        .byte %01010101
        .byte %01110111
        
        .byte %00010001
        .byte %00010001
        .byte %00010001
        .byte %00010001        
        .byte %00010001
        
        .byte %01110111
        .byte %00010001
        .byte %01110111
        .byte %01000100
        .byte %01110111
        
        .byte %01110111
        .byte %00010001
        .byte %00110011
        .byte %00010001
        .byte %01110111
        
        .byte %01010101
        .byte %01010101
        .byte %01110111
        .byte %00010001
        .byte %00010001
        
        .byte %01110111
        .byte %01000100
        .byte %01110111
        .byte %00010001
        .byte %01110111
           
        .byte %01110111
        .byte %01000100
        .byte %01110111
        .byte %01010101
        .byte %01110111
        
        .byte %01110111
        .byte %00010001
        .byte %00010001
        .byte %00010001
        .byte %00010001
        
        .byte %01110111
        .byte %01010101
        .byte %01110111
        .byte %01010101
        .byte %01110111
        
        .byte %01110111
        .byte %01010101
        .byte %01110111
        .byte %00010001
        .byte %01110111
	
	;--PLAYER SET WON SIDE DISPLAY
PLAYER_SET_WON_DISPLAY:
        .byte #%11000000;--
        .byte #%01010000;--
        .byte #%11000000;--
        .byte #%10010000;--
        .byte #%11000000;--

	;--CURRENT SET MIDDLE SCREEN DISPLAY
SET_DISPLAY:
        .byte #%11011010;--
        .byte #%01010010;--
        .byte #%11011010;--
        .byte #%10010010;--
        .byte #%11111111;--
	;-------------;
	;--ANIMATION--;
	;-------------;
PLAYER_IDLE:
        .byte #%01100110;--
        .byte #%00100100;--
        .byte #%00011000;--
        .byte #%01011010;--
        .byte #%00111100;--
        .byte #%00000000;--
        .byte #%00001100;--
        .byte #%00001100;--
PLAYER_HEIGHT = * - PLAYER_IDLE

;--Player Movement for Left and Right--;
PLAYER_MOVE_LF0:
        .byte #%00000110;--
        .byte #%01000100;--
        .byte #%01101000;--
        .byte #%00011100;--
        .byte #%00100010;--
        .byte #%00001100;--
        .byte #%00001100;--
        .byte #%00000000;--
PLAYER_MOVE_LF1:        
		.byte #%00001100;--
        .byte #%00001000;--
        .byte #%00011000;--
        .byte #%00101100;--
        .byte #%00011100;--
        .byte #%00000000;--
        .byte #%00001100;--
        .byte #%00001100;----
PLAYER_MOVE_LF2:        
		.byte #%01100000;--
        .byte #%01000110;--
        .byte #%00011100;--
        .byte #%00111000;--
        .byte #%00000010;--
        .byte #%00001100;--
        .byte #%00001100;--
        .byte #%00000000;----
		
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
        .byte #%00000000;--
        .byte #%00011000;--
        .byte #%00011000;--
        .byte #%00000000;--
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
		
	;--Player Jumping Horizontally--;
PLAYER_JUMP_LF0:
        .byte #%00000000;--
        .byte #%00000100;--
        .byte #%01001000;--
        .byte #%00110110;--
        .byte #%00110110;--
        .byte #%01001000;--
        .byte #%00000100;--
        .byte #%00000000;--
PLAYER_JUMP_LF1:
        .byte #%00000000;--
        .byte #%00001100;--
        .byte #%01010000;--
        .byte #%00101100;--
        .byte #%00101100;--
        .byte #%01010000;--
        .byte #%00001100;--
        .byte #%00000000;--
PLAYER_JUMP_LF2:
        .byte #%00000000;--
        .byte #%01000110;--
        .byte #%00101000;--
        .byte #%00010110;--
        .byte #%00010110;--
        .byte #%00101000;--
        .byte #%01000110;--
        .byte #%00000000;--
PLAYER_JUMP_LF_STILL:
        .byte #%00000000;--
        .byte #%00000110;--
        .byte #%01101000;--
        .byte #%00010110;--
        .byte #%00010110;--
        .byte #%01101000;--
        .byte #%00000110;--
        .byte #%00000000;--

	;--Player Jumping Vertically--;
PLAYER_JUMP_UP0:
        .byte #%00100100;--
        .byte #%00011000;--
        .byte #%00011000;--
        .byte #%00100100;--
        .byte #%01011010;--
        .byte #%00011000;--
        .byte #%00000000;--
        .byte #%00000000;--
PLAYER_JUMP_UP1:
        .byte #%00100100;--
        .byte #%00100100;--
        .byte #%00011000;--
        .byte #%00011000;--
        .byte #%00100100;--
        .byte #%01011010;--
        .byte #%00011000;--
        .byte #%00000000;--
PLAYER_JUMP_UP2:
        .byte #%00000000;--
        .byte #%00100100;--
        .byte #%00100100;--
        .byte #%00011000;--
        .byte #%00011000;--
        .byte #%00100100;--
        .byte #%01011010;--
        .byte #%01011010;--
PLAYER_JUMP_UP_STILL:
        .byte #%00100100;--
        .byte #%00100100;--
        .byte #%00011000;--
        .byte #%00011000;--
        .byte #%00100100;--
        .byte #%01011010;--
        .byte #%01011010;--
        .byte #%00100100;--

PLAYER_JUMP_DOWN0:
        .byte #%00000000;--
        .byte #%00000000;--
        .byte #%00011000;--
        .byte #%01011010;--
        .byte #%00100100;--
        .byte #%00011000;--
        .byte #%00011000;--
        .byte #%00100100;--
PLAYER_JUMP_DOWN1:
        .byte #%00000000;--
        .byte #%00011000;--
        .byte #%01011010;--
        .byte #%00100100;--
        .byte #%00011000;--
        .byte #%00011000;--
        .byte #%00100100;--
        .byte #%00100100;--
PLAYER_JUMP_DOWN2:
        .byte #%01011010;--
        .byte #%01011010;--
        .byte #%00100100;--
        .byte #%00011000;--
        .byte #%00011000;--
        .byte #%00100100;--
        .byte #%00100100;--
        .byte #%00000000;--
PLAYER_JUMP_DOWN_STILL:
        .byte #%00100100;--
        .byte #%01011010;--
        .byte #%01011010;--
        .byte #%00100100;--
        .byte #%00011000;--
        .byte #%00011000;--
        .byte #%00100100;--
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
