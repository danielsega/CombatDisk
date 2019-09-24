	PROCESSOR 6502
    INCLUDE "vcs.h"
    INCLUDE "MyMacro.h"
	INCLUDE "macro.h"
	
;==============================================================
;DEFINE CONSTANTS
;==============================================================

;GAME VALUES
GAME_TIMER			= 40
SOUND_TIMER_BPS		= 5
MUSIC_TIMER_BPS		= 15
SCORE_WAIT			= 20
SET_OVER_WAIT		= 150
STOP_SUPER_ODDS		= %10000000

;SIZES
COURT_SIZE 			= 45 	;Size = Size X 2, Actuall size is 90
BALL_SIZE			= 2
SUPER_SIZE			= 2

;COLORS
P0_COLOR			= $40	;RED 
P1_COLOR			= $84	;BLUE
CLOUDS				= $0F	;CLOUDS
SKY					= $96	;SKY COLOR
CITY				= $22	;CITY COLOR
STAND_MAIN			= $80	;MAIN STAND COLOR
STAND_LIGHT			= $02	;LIGHT STAND COLOR
STAND_BG			= $80	;BACKGROUND STAND COLOR
;Standard Colors
BLACK				= $0
WHITE				= $0F
GRAY				= $4
YELLOW				= $1E

;DIRECTIONS VALUES
DIR_RIGHT			= 1
DIR_LEFT 			= 2
DIR_UP 				= 3
DIR_DOWN			= 4
DIR_SKIP			= 5

;SUPER
SUPER_TIME_LIMIT	= 2
SUPER_ODDS			= 20
SUPER_POWER_SPEED	= 4

;SOUND + MUSIC INDEX
SFX_NONE			= 0

;SOUND INDEX
SOUND_BALL_HIT_WALL	= 1
SOUND_PLAYER_CAUGHT	= 2
SOUND_PLAYER_JUMP	= 3
SOUND_PLAYER_THROW	= 4
SOUND_SUPER_THROW	= 5
SOUND_SCORE			= 6

;MUSIC INDEX
MUSIC_SUPER_ON		= 1
MUSIC_SET_OVER		= 2
MUSIC_GAME_OVER		= 3
MUSIC_TIMER_DOWN	= 4

;GAME INDEX
EVENT_START_SCREEN	= 0
EVENT_GAME_RUN		= 1
EVENT_SET_OVER		= 2
EVENT_GAME_OVER		= 3
EVENT_SCORED		= 4

;POSITIONS
Y_UP				= COURT_SIZE
Y_MIDDLE			= 27
Y_DOWN				= 9

P0_X_LEFT			= 15
P0_X_MIDDLE			= 42
P0_X_RIGHT			= 70

P1_X_LEFT			= 80
P1_X_MIDDLE			= 108
P1_X_RIGHT 			= 137

;AI
AI_ZONE_AREA		= 20 
AI_TIMER_HAS_BALL	= 20
AI_RANDOMIZE_POS	= %00001111

;==============================================================
;END OF CONSTANTS
;==============================================================

;==============================================================
;DEFINE VARIABLES: RAM $80 - $FF
;==============================================================
	SEG.U VARIABLES
	ORG $80
	
;Temp Value
temp					ds 1		;80 - Temporary value. Used on the scoreboard and 2 line kernel missle and ball 

;Random Value
rand 					ds 1		;81 - Random Seed Value

;Player0 Position	
p0_x 					ds 1		;82 - Player 0 X Position
p0_y 					ds 1		;83 - Player 0 Y Position

;Player1 Position	
p1_x 					ds 1		;84 - Player 1 X Position
p1_y 					ds 1		;85 - Player 1 Y Position

;Ball Position
ball_x					ds 1		;86 - Ball X Position
ball_y					ds 1		;87 - Ball Y Position

;Player 0 Velocity
p0_vel					ds 1		;88 - Player 0 Velocity, how fast player changes over time

;Player 1 Velocity
p1_vel					ds 1		;89 - Player 1 Velocity, how fast player changes over time

;Ball Velocity
ball_vel_x				ds 1		;8A - Ball X Velocity, how fast ball changes X direction over time
ball_vel_y				ds 1		;8B - Ball Y Velocity, how fast ball changes Y direction over time
		
;Sprites Draws
p0_draw 				ds 1		;8C - It is used to know where to draw PLayer 0 in the screen with the 2 Line Kernel
p1_draw 				ds 1		;8D - It is used to know where to draw PLayer 1 in the screen with the 2 Line Kernel
ball_draw				ds 1		;8E - It is used to know where to draw the ball in the screen with the 2 Line Kernel

;Players Pointers
p0_ptr 					ds.w 1 		;8F-90 - 2 bytes used to as a pointer to the player 0 graphics
p1_ptr 					ds.w 1 		;91-92 - 2 bytes used to as a pointer to the player 1 graphics

;Players Frame Counter
p0_frame_counter		ds 1		;93	- Counter used to change the frame(Graphic) of PLayer 0 to a new one once counter resets 
p1_frame_counter		ds 1		;94 - Counter used to change the frame(Graphic) of PLayer 1 to a new one once counter resets

;Frame per second for each player
p0_fps					ds 1		;95 - This contains the rate of change for PLayer 0 to change frame(Graphics)  
p1_fps					ds 1		;96 - This contains the rate of change for PLayer 0 to change frame(Graphics)

;Game Points
p0_points				ds 1		;97 -This contains the amounts of points PLayer 0 has
p1_points				ds 1		;98 -This contains the amounts of points PLayer 1 has

;Digit graphics for the scoreboard
p0_digit_gfx 			ds 1		;99 - This contains the graphics for the scoredbaord for Player 0
p1_digit_gfx 			ds 1		;9A - This contains the graphics for the scoredbaord for Player 1

;Digits from the scoreboard from players points
digit_ones				ds.w 1		;9B-9C - 1st byte is for Player 0, 2nd is for PLayer 1. It contains the Ones position -> X0 to X9 -> Where X is the Tens position and 0 to 9 is the Ones Position   
digit_tens				ds.w 1		;9D-9E - 1st byte is for Player 0, 2nd is for PLayer 1. It contains the Tens position -> 0X to 9X -> Where X is the Oness position and 0 to 9 is the Tens Position

;Check if players are throwing: 
is_p0_throwing			ds 1		;9F - Booleans that check if PLayer 0 is throwing. False - Is not Throwing/ True - is throwing
is_p1_throwing			ds 1		;A0 - Booleans that check if PLayer 1 is throwing. False - Is not Throwing/ True - is throwing

;Timer for when players have to throw
p0_has_to_throw			ds 1		;A1 - Timer that once it reaches 0 the PLayer 0 has to throw the ball
p1_has_to_throw			ds 1		;A2 - Timer that once it reaches 0 the PLayer 1 has to throw the ball

;Check the direction player jumped
p0_jump_dir				ds 1		;A3	- Used with Directions Constant values store where PLayer 0 will jump
p1_jump_dir				ds 1		;A4 - Used with Directions Constant values store where PLayer 1 will jump

;Timer that player doesn't move
p0_still_timer			ds 1		;A5 - Counter that is used right after the player either throws or jump so PLayer 0 is not always moving
p1_still_timer			ds 1		;A6 - Counter that is used right after the player either throws or jump so PLayer 1 is not always moving

;Game Timer
timer					ds 6		;A7-AC - The timer for our game, the purple bar in our game, once it reaches 0 the SET or the GAME is OVER

;Frame timer
current_frame_timer		ds 1		;AD	- This counter represent how long is our game SET

;Hold Player Sets wins
p0_won_set				ds 1		;AE	- This contains how many SETs Player 0 Won
p1_won_set				ds 1		;AF - This contains how many SETs Player 1 Won

;Game Current Set
game_set				ds 1		;B0 - This contains which game SET it is

;Save reflect value
p0_reflect				ds 1		;B1 - Used to save the reflect value from the game to be used after the scorebaord graphics section is done and update the previous Player 0 saved reflection 
p1_reflect				ds 1		;B2 - Used to save the reflect value from the game to be used after the scorebaord graphics section is done and update the previous Player 1 saved reflection

;Current Display game set
current_display_gs		ds 1		;B3 - Display Graphic for which SET it is

;Set Won values to merge with graphics
p0_merger				ds 1		;B4 - This will contain the Graphic for the set won display for PLayer 0 by merging multiple graphics into one
p1_merger				ds 1		;B5 - This will contain the Graphic for the set won display for PLayer 1 by merging multiple graphics into one

;SUPER variables
super_x					ds 1		;B6	- Super X location on the screen
super_y					ds 1		;B7 - Super Y location on the screen
super_draw				ds 1		;B8 - Contains the Graphics to draw in the screen
is_super_on_screen		ds 1		;B9 - This boolean tells if the super is on the screen. False: Not on Screen / True: Is on the screen
eof_super				ds 1		;BA - Every other Frame Super. Every other framer switch between drawing the super or the division line of the court
sp_check				ds 1		;BB - One more boolean used to check if the super is used. Used to preper the Odds for the super. False: Not On, True: On  
super_timer				ds 1		;BC - This counter sets how long the super will be in the screen for.
p0_super				ds 1		;BD - Check if Player 0 has caught the super and can use it
p1_super				ds 1		;BE - Check if Player 1 has caught the super and can use it

;SFX Sound (Left/0) & Music(Right/1)
sfx_sound_index			ds 1		;BF - Sound Index that tells which sound to player 
sfx_music_index			ds 1		;C0 - Music Index that tells which music to player
sfx_sound_counter		ds 1		;C1 - Sound Counter that tells where in the sound duration it is
sfx_music_counter		ds 1		;C2 - Music Counter that tells where in the music duration it is
sfx_sound_repeat		ds 1		;C3 - Check how many times will this sound will play once it is done playing
sfx_music_repeat		ds 1		;C4 - Check how many times will this music will play once it is done playing
is_sound_playing		ds 1		;C5 - Boolean to check if sound is playing. True: is PLaying/ False: It isn't 
is_music_playing		ds 1		;C6 - Boolean to check if music is playing. True: is PLaying/ False: It isn't
music_timer				ds 1		;C7	- This timer will keep track of bps for music
sound_timer				ds 1		;C8	- This timer will keep track of bps for sound
music_bps				ds 1		;C9 - This will change the beat per second 

;GAME INDEX
event_index				ds 1		;CA - Index that will tell which event it is
event_timer				ds 1		;CB - Counter used for our events to change them once timer is done
event_checker			ds 1		;CC - Boolean to check our event. It is used to start the game, False: Game doesn't start, True: Game starts

;Game Start Helper
start_ball_vel_x		ds 1		;CD - Checks which player will start with the ball and store initial ball velocity to tell where it is going.
who_won					ds 1		;CE - Case 0 : P0 Wins, Case 1: P1 Wins

;AI
is_ai_on				ds 1		;CF - Case Bool True: It's a single Player game, Case False: It's a two player game
ai_dir					ds 1		;D0 - This will those the direction that the AI is gonna take
ai_timer				ds 1		;D1 - This timer will dec itselft till reaches Zero
ai_position_x			ds 1		;D2 - This will tell the X position the ai is going
ai_position_y			ds 1		;D3 - This will tell the y position the ai is going
ai_throw_bool			ds 1		;D4 - This will tell the ai to throw the ball. False - Don't Throw, True - Throw
ai_error_margin			ds 1		;D5 - This will contain a small magin error to catch the ball
ai_jump_bool			ds 1		;D6 - This will tell the ai to jump. False - Don't Jump, True - Jump
;==============================================================
;END OF VARIABLES
;==============================================================

;==============================================================
;Start of FILE
;--------------------------------------------------------------
;This is the location where our data is gonna be stored inside
;our CARTRIDGE
;==============================================================	
	SEG 	CODE
	
	;--MACROS for BANK SWITCH
	
	; Macro that implements Bank Switching trampoline
	; X = bank number
	; A = hi byte of destination PC
	; Y = lo byte of destination PC
	MAC BANK_SWITCH_TRAMPOLINE
    pha
    tya
    pha
    lda $1FF8,X
    rts
	ENDM
	
	;Perfomes bank switch
	MAC PERFORME_BANK_SWITCH
.Bank	SET {1}
.Addr	SET {2}
	lda #>(.Addr-1)
    ldy #<(.Addr-1)
    ldx #.Bank
    jmp BankSwitch	
	ENDM
	
	;Always start game with bank 0
	MAC START_WITH_BANK_0
		lda #>(Reset-1)
		ldy #<(Reset-1)
		ldx #$ff
		txs
		inx
	ENDM 
	
	;Include Interrupts vectors to file
	MAC INTERRUPTS_VECTORS
		.word Start          ; NMI
    	.word Start          ; RESET
    	.word Start          ; IRQ 
	ENDM 
	
;==============================================================
;Start of BANK 0
;==============================================================
	ORG 	$1000
	RORG	$1000
	
;----The following code is the same on both banks----
Start:
	START_WITH_BANK_0
BankSwitch:
	BANK_SWITCH_TRAMPOLINE
;----End of bank-identical code----
	
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
;SFX Set Sound
;-----------------------------------------------------
;This will set values for the sound
;-----------------------------------------------------
;A = Index
;X = Counter
;Y = Duration 
;-----------------------------------------------------
sfx_set_sound:
	M_SET_SFX sfx_sound_index, sfx_sound_counter, sfx_sound_repeat
	
;=====================================================	
;SFX Set Music
;-----------------------------------------------------
;This will set values for the music
;-----------------------------------------------------
;A = Index
;X = Counter
;Y = Duration 
;-----------------------------------------------------
sfx_set_music:
	M_SET_SFX sfx_music_index, sfx_music_counter, sfx_music_repeat	
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

;Reposition players to the center of the screen	
reposition_players:
	;Reset Values back to zero
	lda #0
	sta p0_frame_counter
	sta p1_frame_counter
	sta p0_fps
	sta p1_fps
	sta is_p0_throwing
	sta is_p1_throwing
	sta p0_jump_dir
	sta p1_jump_dir
	sta is_super_on_screen
	sta ai_jump_bool
	
	;Reset Sound
	sta sfx_sound_index
	sta sfx_sound_counter
	sta sfx_sound_repeat
	sta AUDC0
	sta AUDV0
	sta AUDF0
	
	;Reset Music
	sta sfx_music_index
	sta sfx_music_counter
	sta sfx_music_repeat
	sta AUDC1
	sta AUDV1
	sta AUDF1
	
	;Reset Velocity to players
	lda #1
	sta p0_vel
	sta p1_vel
	
	;Set Position X for player to the middle of their court
	lda #P0_X_MIDDLE
	sta p0_x
	lda #P1_X_MIDDLE
	sta p1_x
	sta ai_position_x
	
	;Set players to middle of the screen
	lda #Y_MIDDLE
	sta p0_y
	sta p1_y
	sta ai_position_y	
	rts
		
;Get PNRG value	
get_random:
	M_RANDOM rand
	
;P0 start with ball in the start of the Set
p0_gets_ball
	M_P0_GETS_BALL ball_x, ball_y, ball_vel_x, ball_vel_y, BALL_SIZE, COURT_SIZE
	
;P1 start with ball in the start of the Set	
p1_gets_ball
	M_P1_GETS_BALL ball_x, ball_y, ball_vel_x, ball_vel_y, BALL_SIZE, COURT_SIZE	
;=====================================================
;RESET
;-----------------------------------------------------
;When you push down the GAME RESET switch, it will
;cause an iterrrupt and set te PC (Pointer Counter)
;at this memory location 
;=====================================================
Reset
	;Reset All values from 
	CLEAN_RESTART is_ai_on
	
	lda #0
	sta SWACNT
	
	ldy #1
	sty VDELP0
	sty p0_vel
	sty p1_vel
	sty game_set
	
	;Set Start of ball to top of court
	lda #(COURT_SIZE + BALL_SIZE)
	sta ball_y
	
	;Set TIMER value to full
	lda #$ff
	sta timer
	sta timer+1
	sta timer+2
	sta timer+3
	sta timer+4
	sta timer+5
	
	;Set Position X for player to the middle of their court
	lda #P0_X_MIDDLE
	sta p0_x
	lda #P1_X_MIDDLE
	sta p1_x
	
	;Set players to middle of the screen
	lda #Y_MIDDLE
	sta p0_y
	sta p1_y

	;Store value into our rand from initial clock value
	lda INTIM
	sta rand
	
	;Set Music BPS to default
	lda #MUSIC_TIMER_BPS
	sta music_bps
	
	;Set Super X and Y Position randomly
	jsr get_random
	sta super_x
	jsr get_random

	;Check which start with ball based on initial clock value
	bmi p0_starts_with_ball
	jsr p1_gets_ball
	lda #1
	sta start_ball_vel_x
	jmp StartOfFrame
p0_starts_with_ball:
	jsr p0_gets_ball
	lda #$ff
	sta start_ball_vel_x
	
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
	;----------;
	;--TIMERS--;
	;----------;
	ldy #0	; Used to Reset Counters
	
	;Current Timer
	inc current_frame_timer
	lda current_frame_timer
	cmp #GAME_TIMER
	bne skip_current_frame_timer
	
	sty current_frame_timer
skip_current_frame_timer:
	
	;SOUND Timer
	inc sound_timer
	lda sound_timer
	cmp #SOUND_TIMER_BPS
	bcc skip_reset_sound_timer
	
	sty sound_timer
skip_reset_sound_timer:
	
	;MUSIC Timer
	inc music_timer
	lda music_timer
	cmp music_bps
	bcc skip_reset_music_timer
	
	sty music_timer
skip_reset_music_timer:
	
	;AI Timer
	lda ai_timer
	bmi skip_ai_timer
	dec ai_timer
skip_ai_timer:
	
	
	;--------------------------------------;
    ;--Start of vertical blank processing--;
	;--------------------------------------;
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
    
    ;----------------
    ;GAME RESET PART
	;TODO: insert this code down to match frame
    lsr SWCHB
    bcs game_reset_not_pushed

	;Loop forever until we release the Reset lever
loop_till_reset_off:    
    lsr SWCHB
    bcc loop_till_reset_off	
    jmp Reset
    
game_reset_not_pushed:
    ;----------------
    ;GAME SELECT PART	
	lda #%00000010
	bit SWCHB
	bne game_select_not_pushed
	;Set Game Event to Run
	lda #EVENT_GAME_RUN
	sta event_index
	
	;Reset Player Positions in case Ai is on and P1 out of the windows
	jsr reposition_players
	 
game_select_not_pushed:

    ;=====================================================
	;GAME EVENTS
	;=====================================================
    ;EVENT: Check if it is on the start screen
    lda event_index
    bne skip_to_event_game_run
    
    ;Make sure player 1 is facing left
    lda #$ff
    sta p1_reflect
    
    ;Reset Ball and Super values
    lda #0
    sta is_super_on_screen
    sta ball_vel_x
    sta ball_vel_y
    
    ;Set event checker to true
	lda #1
	sta event_checker
	
	;AI is set, So put P1 out of the game window
	lda is_ai_on
	beq skip_ai_init_pos
	
	;Set Player out of window
	lda #0
	sta p1_x
	sta p1_y
skip_ai_init_pos:
	
    ;Still on start screen skip inputs all together
    jmp EXIT_INPUT
    
skip_to_event_game_run:

	lda event_checker
	beq skip_event_checker
	
	;Store saved vel to ball to move ball towards player
	lda start_ball_vel_x
	sta ball_vel_x
	
	;Reset event checker to false
	lda #0
	sta event_checker
skip_event_checker:
	
    ;--Check INDEX
	lda event_index
	
	;EVENT: check if the game is set to run
    cmp #EVENT_GAME_RUN
    beq P0_INPUT
    
    cmp #EVENT_SCORED
    beq check_event_scored
    
    cmp #EVENT_SET_OVER
    beq check_event_set_over
    
    cmp #EVENT_GAME_OVER
    beq check_event_game_over
    
check_event_set_over:
	
	;Check when timer is gonna be over
	lda event_timer
	cmp #1
	beq setup_new_set 
	
	lda #0
	sta ball_vel_x
	sta ball_vel_y
	jmp goto_reset_timer
setup_new_set:
	
	;Clear Colissions for ball
	sta CXCLR
	
	;Reposition PLayers
	jsr reposition_players
	
	;Always Draw the Court Lines
	lda #1
	sta eof_super
	
	;Checks who starts with the ball
	lda start_ball_vel_x
	bpl p0_gets_ball_new_set
	
	jsr p1_gets_ball
	lda #1
	sta start_ball_vel_x
	jmp goto_reset_timer
p0_gets_ball_new_set:
	lda #$ff
	sta start_ball_vel_x
	jsr p0_gets_ball
	
goto_reset_timer:	
	;Keep reseting time to full till we leave event set over
	lda #$ff
	sta timer+6   
check_event_scored:
	dec event_timer
	lda event_timer
	beq event_timer_is_over    
	jmp EXIT_INPUT

check_event_game_over:
	lda #0
	sta ball_vel_x
	sta ball_vel_y
	sta ball_y
	
	;Check who won the game
	lda who_won
	beq p0_won
	
	;P1 Won
	lda #0
	sta ball_x
	jmp LOST_FRAME_P0
p0_won:	
	;P0 Won
	lda #150
	sta ball_x
	jmp WON_FRAME_P0
	
event_timer_is_over:
	lda #EVENT_GAME_RUN
	sta event_index
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
	
	;Fix bug after jump
	lda #1
	sta p0_vel
	
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
	
	;Check if P0 has super
	lda p0_super
	bne skip_p0_super
	
	;Set Sound for when player throws the ball
	lda #SOUND_PLAYER_THROW
	ldx #sound_size_player_throw
	ldy #1
	jsr sfx_set_sound	
	ldx #$ff
	ldy #0
	
	lda p0_super
	beq P0_SKIP_TO_THROWING_FRAME
skip_p0_super:
	
	;Change Ball Velocity to max
	lda #(0 + SUPER_POWER_SPEED)
	sta ball_vel_x
	
	;Set Sound for when player throws the ball with super
	lda #SOUND_SUPER_THROW
	ldx #sound_size_super_throw
	ldy #1
	jsr sfx_set_sound	
	ldx #$ff
	ldy #0
	
	;Zero out super values
	sty is_super_on_screen
	sty sp_check
	sty p0_super
	sty super_timer
	
P0_SKIP_TO_THROWING_FRAME:	
	jmp THROWING_FRAME_P0

P0_JUMP:
	;-------------------;
	;--COMPARE SECTION--;
	;-------------------;

	;lda #SOUND_PLAYER_JUMP
	;sta sfx_sound_index
	;lda #1
	;sta sfx_sound_counter
	;lda #1
	;sta sfx_sound_repeat
	
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
WON_FRAME_P0:
	ANI_CHANGE_FRAME p0_fps, LOST_FRAME_P1, p0_frame_counter, 14, 16
LOST_FRAME_P0:
	ANI_CHANGE_FRAME p0_fps, WON_FRAME_P1, p0_frame_counter, 22, 24			
	;--------------;
	;Player 1 INPUT;
	;--------------;
	
P1_INPUT:
	ldx #$ff
	
	;Check if P1 has ball
	bit CXP1FB
	bvs P1_HAS_BALL
	
	;Check if play is still jumping
	lda p1_jump_dir
	beq skip_p1_jump_dir
	jmp P1_JUMP
skip_p1_jump_dir:
	
	;Check if AI is ON and performe ai jump if it is
	lda is_ai_on
	beq resume_jump	
	PERFORME_BANK_SWITCH 1, ai_jump
	jmp P1_JUMP
resume_jump:
  
  	;Reset values back after Bank Switch
	ldy #0
	ldx #$ff
	
	lda ai_jump_bool
	beq p1_didnt_jump
	jmp P1_JUMP
	
	;Check if playerjumped
	bit INPT5
	bmi p1_didnt_jump
	jmp P1_JUMP 
p1_didnt_jump:	

	jmp P1_CONTROLLER
	
P1_HAS_BALL:
	;AI: Set the wait timer
	lda #AI_TIMER_HAS_BALL
	sta ai_timer
	
	;Making sure player is facing right	
	stx p1_reflect
	
	;Fix bug after jump
	lda #1
	sta p1_vel
	
	;If player is in the throwing motion go to P0_Throw
	lda is_p1_throwing
	bne P1_THROW
	sty p1_frame_counter
	
	;Increment value to go above 0
	inc p1_has_to_throw
	
	;Check if AI is ON and performe ai throw if it is
	lda is_ai_on
	beq resume_throw	
	PERFORME_BANK_SWITCH 1, ai_throw
resume_throw:  
  	;Reset values back after Bank Switch
	ldy #0
	ldx #$ff
	
	lda ai_throw_bool
	beq skip_ai_throw
	jmp P1_THROW
skip_ai_throw:	
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
	stx CXCLR
	
	;Set jump dir back to 0
	sty p1_jump_dir
	
	;Offset ball to player distance to make the ball move
	sec
	lda ball_x
	sbc #(PLAYER_HEIGHT + BALL_SIZE)
	sta ball_x
	
	;Check if P1 has super
	lda p1_super
	bne skip_p1_super
	
	;Set Sound for when player throws the ball
	lda #SOUND_PLAYER_THROW
	ldx #sound_size_player_throw
	ldy #1
	jsr sfx_set_sound	
	ldx #$ff
	ldy #0
	
	lda p1_super
	beq P1_SKIP_TO_THROWING_FRAME
skip_p1_super:
	
	;Set Sound for when player throws the ball with super
	lda #SOUND_SUPER_THROW
	ldx #sound_size_super_throw
	ldy #1
	jsr sfx_set_sound	
	ldx #$ff
	ldy #0
	
	;Change Ball Velocity to max
	lda p1_super
	lda #(0 - SUPER_POWER_SPEED)
	sta ball_vel_x
	
	;Zero out super values
	sty is_super_on_screen
	sty sp_check
	sty p1_super
	sty super_timer	
	;Put AI Throw Back to False
	sty ai_throw_bool
	
P1_SKIP_TO_THROWING_FRAME:	
	jmp THROWING_FRAME_P1

P1_JUMP:
	;-------------------;
	;--COMPARE SECTION--;
	;-------------------;

	;lda #SOUND_PLAYER_JUMP
	;sta sfx_sound_index
	;lda #1
	;sta sfx_sound_counter
	;lda #1
	;sta sfx_sound_repeat
	
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
	sty ai_jump_bool 	;Reset AI bool Value
p1_skip_still:	
	jmp EXIT_INPUT
	
P1_CONTROLLER:
	
	
continue_controller_checker:	
	;Check if AI is ON and run it
	lda is_ai_on
	beq resume_controller
	
	lda ai_jump_bool
	bne resume_controller

	PERFORME_BANK_SWITCH 1, ai_move
resume_controller:
	
	;Reset values back after Bank Switch
	ldy #0
	ldx #$ff
	
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
WON_FRAME_P1:
	ANI_CHANGE_FRAME p1_fps, skip_ball_movement, p1_frame_counter, 14, 16
LOST_FRAME_P1:
	ANI_CHANGE_FRAME p1_fps, skip_ball_movement, p1_frame_counter, 22, 24		
	
EXIT_INPUT:	
	;Move Object on X coordinates

	;If We are towards the end of the match turn off super
	lda timer
	bpl skip_to_court_line 
	
	;Check Condition for every other frame
	lda current_frame_timer
	and #1
	bne check_super_cond
	jmp skip_to_court_line
	
check_super_cond:
	lda is_super_on_screen
	bne skip_to_super
	
skip_to_court_line:

	;--Court Lines
	;Set Court Line - Missile 0	
	lda #78
	ldx #2
	jsr PosObj	
	;Set Court Line - Missile 1	
	lda #80
	ldx #3
	jsr PosObj
	
	lda #0
	sta eof_super
	
	jmp exit_court_line_super
skip_to_super:	
	;--Super
	;Set Super X Position - Missile 0	
	lda super_x
	ldx #2
	jsr PosObj	
	;Not Used - Missile 1	
	lda #0
	ldx #3
	jsr PosObj
	
	lda #1
	sta eof_super
exit_court_line_super:	

	;Move Ball
	lda ball_x
	ldx #4
	jsr PosObj
	
skip_ball_movement:
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
    
    ;SUPER data
	lda #(COURT_SIZE + SUPER_SIZE)
    sec
    sbc super_y
    sta super_draw
    
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
	lda #34
	sta TIM64T	
	
	lda #0
	sta REFP0
	sta REFP1
	sta COLUBK	
	
	;Set Players Colors
	lda #P0_COLOR
	sta COLUP0
	lda #P1_COLOR
	sta COLUP1
	
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
	
	lda #$1f
	sta COLUP0
	lda #$a8
	sta COLUP1

	lda #$0f
	sta COLUPF
	ldy #0
	sty CTRLPF
	
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
	
	;Set PF off
	ldy #0
	sty PF0
	sty PF1
	sty PF2
	sty GRP0
	sty GRP1	
	;Set PF to normal
	sty CTRLPF
	
	;--Set Colors
	;Set PF timer color
	lda #$c8
	sta COLUPF
	;Set Players Colors
	lda #P0_COLOR
	sta COLUP0
	lda #P1_COLOR
	sta COLUP1
	
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
	
	PERFORME_BANK_SWITCH 1, display_top_background
resume_from_top_background:

	REPEAT 4
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
	ldx #$FF
	stx PF1
	stx PF2	
	
	;Enable Missile for Court Division
	lda eof_super
	beq fix_upper_missiles_display
	ldx #0
	lda #%00100000
	sta NUSIZ0
	sta NUSIZ1
fix_upper_missiles_display:	
	stx ENAM0
	stx ENAM1
	
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
	inx
	stx temp
	ldx #1							;2
	lda #SUPER_SIZE					;2
	dcp super_draw					;5
	bcs DoSuper						;2/3
	.byte $24						;2/3
	
DoSuper:	
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
	lda eof_super
	beq skip_missiles
	stx ENAM0
	lda #0
	sta ENAM1
skip_missiles:
	ldx temp
	stx ENABL						;3
	sta PF2							;3
	
    dey    							;2	
	;Fix bottom court mistiming
	cpy #1
	bne skip_fix_court_mistiming
	sta WSYNC
	ldx #0
	sta GRP0
	sta GRP1
skip_fix_court_mistiming:
		
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
	
	lda #STAND_LIGHT
	sta COLUPF
	ldx #$FF
	stx PF0
	stx PF1
	stx PF2
	
	
	;--START OF BOTTOM BACKGROUND
	PERFORME_BANK_SWITCH 1, display_bottom_background
resume_from_bottom_background:
	
	lda #%01000010
    sta VBLANK 	; end of screen - enter blanking	
	;-----------------------;
	;--END OF DISPLAY AREA--;
	;-----------------------;

	PERFORME_BANK_SWITCH 1, overscan_section	

	;-----------------;
	;--DATA AREA------;
	;-----------------;
	
	;--ANIMATION DATA
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
		.byte <(PLAYER_LOST_GAME0 + PLAYER_HEIGHT - 1)		;22
		.byte <(PLAYER_LOST_GAME1 + PLAYER_HEIGHT - 1)		;23
		.byte <(PLAYER_LOST_GAME2 + PLAYER_HEIGHT - 1)		;24
		
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
		.byte >(PLAYER_LOST_GAME0 + PLAYER_HEIGHT - 1)		;22
		.byte >(PLAYER_LOST_GAME1 + PLAYER_HEIGHT - 1)		;23
		.byte >(PLAYER_LOST_GAME2 + PLAYER_HEIGHT - 1)		;24

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

	;--Player Jumping Vertically & Winning Animation--;
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


	;PLayer Loses Animation
PLAYER_LOST_GAME0:
        .byte #%00000000;--
        .byte #%01100110;--
        .byte #%00100010;--
        .byte #%01111100;--
        .byte #%01100000;--
        .byte #%00000000;--
        .byte #%00000000;--
        .byte #%00000000;--
PLAYER_LOST_GAME1:
        .byte #%00000000;--
        .byte #%01100110;--
        .byte #%00100010;--
        .byte #%00011100;--
        .byte #%01101000;--
        .byte #%01111000;--
        .byte #%00000000;--
        .byte #%00000000;--
PLAYER_LOST_GAME2:
        .byte #%00000000;--
        .byte #%01100110;--
        .byte #%01100010;--
        .byte #%00011100;--
        .byte #%01100000;--
        .byte #%01100000;--
        .byte #%00000000;--
        .byte #%00000000;--

;---End Graphics Data---

	;--------------------;
	;--END OF ANIMATION--;
	;--------------------;
		
	echo "There is:", [$1FFA - *]d, "bytes left in Bank 0."
	
	ORG 	$1FFA
	RORG	$FFFA
	;--------------------;
	;--END OF DATA AREA--;
	;--------------------;

	;--INTERRUPTS
    INTERRUPTS_VECTORS
;==============================================================
;Start of BANK 1
;==============================================================	
	
	ORG		$2000
	RORG	$1000
	
	;----The following code is the same on both banks----
Start:
	START_WITH_BANK_0
BankSwitch:
	BANK_SWITCH_TRAMPOLINE
;----End of bank-identical code----

sfx_set_sound_b1:
	M_SET_SFX sfx_sound_index, sfx_sound_counter, sfx_sound_repeat
sfx_set_music_b1:
	M_SET_SFX sfx_music_index, sfx_music_counter, sfx_music_repeat
	
;New Game Set after timer is over	
new_gameset_reset:	
	lda #$ff
	sta timer
	sta timer+1
	sta timer+2
	sta timer+3
	sta timer+4
	sta timer+5
	
	;Reset Points back down to zero
	lda #0
	sta p0_points
	sta p1_points
	
	;Turn off players super, if they caught in the previous set
	sta p0_super
	sta p1_super
	
	rts

;Reposition players to the center of the screen	
reposition_players_b1:
	;Reset Values back to zero
	lda #0
	sta p0_frame_counter
	sta p1_frame_counter
	sta p0_fps
	sta p1_fps
	sta is_p0_throwing
	sta is_p1_throwing
	sta p0_jump_dir
	sta p1_jump_dir
	sta is_super_on_screen
	sta ai_jump_bool
	
	;Reset Sound
	sta sfx_sound_index
	sta sfx_sound_counter
	sta sfx_sound_repeat
	sta AUDC0
	sta AUDV0
	sta AUDF0
	
	;Reset Music
	sta sfx_music_index
	sta sfx_music_counter
	sta sfx_music_repeat
	sta AUDC1
	sta AUDV1
	sta AUDF1

	;Reset Velocity to players
	lda #1
	sta p0_vel
	sta p1_vel
	
	;Set Position X for player to the middle of their court
	lda #P0_X_MIDDLE
	sta p0_x
	lda #P1_X_MIDDLE
	sta p1_x
	sta ai_position_x
	
	;Set players to middle of the screen
	lda #Y_MIDDLE
	sta p0_y
	sta p1_y
	sta ai_position_y
	
	rts
		
;Get PNRG value	
get_random_b1:
	M_RANDOM rand

;P0 start with ball in the start of the Set
p0_gets_ball_b1
	M_P0_GETS_BALL ball_x, ball_y, ball_vel_x, ball_vel_y, BALL_SIZE, COURT_SIZE

;P1 start with ball in the start of the Set	
p1_gets_ball_b1
	M_P1_GETS_BALL ball_x, ball_y, ball_vel_x, ball_vel_y, BALL_SIZE, COURT_SIZE
	
	;--------------------------;	
	;--DISPLAY TOP BACKGROUND--;
	;--------------------------;
display_top_background:
	
	;--START OF TOP BACKGROUND	
	sta WSYNC
	
	lda #SKY
	sta COLUBK
	lda #WHITE
	sta COLUPF
	
	;Clouds Background
	ldx #PF_CLOUD_SIZE
put_clouds_on_screen:
	lda PFClouds0-1,X
	sta PF0
	lda PFClouds1-1,X
	sta PF1
	lda PFClouds2-1,X
	sta PF2
	dex
	sta WSYNC
	bne put_clouds_on_screen
	
	;City Background
	lda #CITY
	sta COLUPF
	lda #SKY
	sta COLUBK
	lda #0
	sta PF0
	sta PF1
	sta PF2
	sta WSYNC
	
	ldx #PF_CITY_SIZE
put_city_on_screen:
	lda PFCity0-1,X
	sta PF0
	lda PFCity1-1,X
	sta PF1
	lda PFCity2-1,X
	sta PF2
	dex
	sta WSYNC
	bne put_city_on_screen

	;--Top Stand Background
	lda #STAND_MAIN
	sta COLUPF
	lda #STAND_BG
	sta COLUBK
	lda #$ff
	sta PF0
	sta PF1
	sta PF2
	lda #%00000001
	sta CTRLPF
	sta WSYNC
	
	ldx #PF_STAND_TOP_SIZE
put_top_stand_on_screen:
	lda PFStandTop0-1,X
	sta PF0
	lda PFStandTop1-1,X
	sta PF1
	lda PFStandTop2-1,X
	sta PF2
	dex
	sta WSYNC
	bne put_top_stand_on_screen
	
	;RESET PF Back
	lda #STAND_LIGHT
	sta COLUBK
	lda #BLACK ;Black value is 0
	sta COLUPF
	sta CTRLPF
	sta PF0
	sta PF1
	sta PF2
	
	PERFORME_BANK_SWITCH 0, resume_from_top_background
	
	;-----------------------------;	
	;--DISPLAY BOTTOM BACKGROUND--;
	;-----------------------------;
display_bottom_background:
	;Set Light for the stand	

	lda #STAND_LIGHT
	sta COLUBK
	
	REPEAT 4
		sta WSYNC
	REPEND
	
	ldx #0
	lda #STAND_MAIN
	sta COLUPF
	lda #STAND_BG
	sta COLUBK
	lda #%00000001
	sta CTRLPF
	sta WSYNC
	
	ldx #PF_STAND_BOT_SIZE
put_bot_stand_on_screen:
	lda PFStandBot0-1,X
	sta PF0
	lda PFStandBot1-1,X
	sta PF1
	lda PFStandBot2-1,X
	sta PF2
	dex
	sta WSYNC
	bne put_bot_stand_on_screen
	

	;Reset Colors back for top GUI display
	lda #BLACK
	sta COLUBK
	stx PF0
	stx PF1
	stx PF2
	PERFORME_BANK_SWITCH 0, resume_from_bottom_background
	;PERFORME_BANK_SWITCH 0, resume_from_bottom_background
	;---------------;
	;--AI JUMPING---;
	;---------------;
ai_jump:
	
	sec
	lda p1_x
	sbc ball_x
	clc
	adc #PLAYER_HEIGHT
	bpl exit_ai_jump
	
	;Set it to the right position
	lda #%00001000
	sta SWACNT
	
	;Set Bool to false
	lda #$ff
	sta ai_jump_bool
	
exit_ai_jump:	
	PERFORME_BANK_SWITCH 0, resume_jump
	
	;----------------;
	;--AI THROWING...;
	;----------------;
ai_throw:
	lda #$ff
	sta ai_throw_bool
	
	jsr get_random_b1
	and #%00001111
	cmp #5
	bcc ai_throw_up_right
	cmp #11
	bcc ai_throw_down_right
	
	;THROW TO THE MIDDLE
	lda #%00000100
	sta SWACNT
	jmp exit_throw
	
ai_throw_up_right:
	lda #1
	sta SWACNT
	jmp exit_throw
	
ai_throw_down_right:
	lda #%00000010
	sta SWACNT
exit_throw:
	PERFORME_BANK_SWITCH 0, resume_throw
	;----------------;
	;--AI MOVEMENT...;
	;----------------;
ai_move:
	
	;If Jump was performer
	lda ai_jump_bool
	beq skip_ai_store
	jmp ai_store
skip_ai_store:
	
	;Clear SWACNT back to Zero
	lda #0
	sta SWACNT
	
	;AI TIMER
	lda ai_timer
	bmi continue_ai_move
	beq randomize_positions
	jmp exit_ai_move
	
randomize_positions:	
	lda get_random_b1
	and #%00001111		;0-16
	cmp #5
	bcc ai_go_left
	cmp #11
	bcs ai_go_right
	
	;GO to the Middle otherwise
	jsr get_random_b1
	and #AI_RANDOMIZE_POS
	clc
	adc #P1_X_MIDDLE
	sta ai_position_x
	jmp randomize_location_y
	
ai_go_left:
	jsr get_random_b1
	and #AI_RANDOMIZE_POS
	clc
	adc #(P1_X_LEFT + (P1_X_LEFT - P1_X_MIDDLE))
	sta ai_position_x
	jmp randomize_location_y

ai_go_right:
	jsr get_random_b1
	and #AI_RANDOMIZE_POS
	clc
	adc #(P1_X_LEFT + (P1_X_MIDDLE - P1_X_RIGHT))
	sta ai_position_x

randomize_location_y:	
	lda get_random_b1
	and #%00001111
	cmp #5
	bcc ai_go_up
	cmp #11
	bcs ai_go_down
	
	;GO to the Middle otherwise
	jsr get_random_b1
	and #%00000011
	clc
	adc #Y_MIDDLE
	sta ai_position_y
	jmp exit_ai_move
	
ai_go_up:
	jsr get_random_b1
	and #%00000011
	clc
	adc #(Y_DOWN + (Y_UP - Y_MIDDLE))
	sta ai_position_y
	jmp exit_ai_move

ai_go_down:
	jsr get_random_b1
	and #%00000011
	clc
	adc #(Y_DOWN + (Y_MIDDLE - Y_DOWN))
	sta ai_position_y
	jmp exit_ai_move
	
continue_ai_move:
	
	;Check whether to chase or go to the middle of their field
	lda ball_x
	cmp #80
	bcc skip_ball_chase	
	jmp ai_ball_chase	
skip_ball_chase:	
	;------------------------
	;--MOVE IN THE AI FIELD--
	;------------------------

	;Check if super is on
	lda is_super_on_screen
	bne contine_super_position
	jmp skip_go_to_super_x
	
contine_super_position:
	
	;Check if super is in P1 side of the court
	lda super_x
	cmp #80
	bcc skip_go_to_super_x
	
	;Set Location X of Super to as destination
	lda super_x
	sta ai_position_x
	
skip_go_to_super_x:
	;Check for X Movement
	sec
	lda p1_x
	sbc ai_position_x
	beq no_x_movement
	bpl ai_move_left
	bmi ai_move_right
	
	;X Movement
no_x_movement:
	lda #0
	sta ai_dir
	jmp ai_continue_move
ai_move_left:
	lda #%00000100
	sta ai_dir
	jmp ai_continue_move
ai_move_right:
	lda #%00001000
	sta ai_dir

ai_continue_move:
	
	;If Super is On change Ai_Position_Y to super location
	lda is_super_on_screen
	beq skip_go_to_super_y
	
	;Check if super is in P1 side of the court
	lda super_x
	cmp #80
	bcc skip_go_to_super_y
	
	;Set Location Y of Super to as destination
	lda super_y
	sta ai_position_y
	
skip_go_to_super_y:
	
	;Check for Y Movement
	sec
	lda p1_y
	sbc ai_position_y
	beq no_y_movement
	bpl ai_move_up
	bmi ai_move_down
	
	;Y Movement
no_y_movement:
	lda #0
	ora ai_dir
	sta ai_dir
	jmp ai_store
ai_move_up:
	lda #%00000010
	ora ai_dir
	sta ai_dir
	jmp ai_store
ai_move_down:
	lda #%00000001
	ora ai_dir
	sta ai_dir
	jmp ai_store
	
	
	;--AI CHASE BALL
ai_ball_chase:
	
	;If Ball is near enough player X position don't move
	sec
	lda ball_x
	sbc p1_x
	clc
	adc #PLAYER_HEIGHT
	bcs no_x_chase	
	
	;Check For X coord is within our ai zone
	sec
	lda ball_x
	sbc p1_x
	cmp #AI_ZONE_AREA
	bcc check_chase_y
	cmp #(0 - #AI_ZONE_AREA)
	bcs check_chase_y
	jmp ai_store
	
check_chase_y:
	;Check For Y coord is within our ai zone
	sec
	lda ball_y
	sbc p1_y
	cmp #AI_ZONE_AREA
	bcc chase_ball
	cmp #(0 - #AI_ZONE_AREA)
	bcs chase_ball
	jmp ai_store
	
	;--MOVE CHARACTER TOWARDS BALL
chase_ball:
	jsr get_random_b1
	and #%00000001
	sta ai_error_margin
	
	;Check for X Movement
	sec
	lda p1_x
	sbc ball_x
	clc
	adc ai_error_margin
	beq no_x_chase
	bpl ai_chase_left
	bmi ai_chase_right
	
	;X Chase
no_x_chase:
	lda #0
	sta ai_dir
	jmp ai_continue_chase
ai_chase_left:
	lda #%00000100
	sta ai_dir
	jmp ai_continue_chase
ai_chase_right:
	lda #%00001000
	sta ai_dir

ai_continue_chase:
	
	;If Ball is near enough player X position don't move
	sec
	lda ball_y
	sbc p1_y
	clc
	adc #PLAYER_HEIGHT
	bcs no_y_chase	
	
	;Check for Y Movement
	sec
	lda p1_y
	sbc ball_y
	clc
	adc ai_error_margin
	beq no_y_chase
	bpl ai_chase_up
	bmi ai_chase_down
	
	;Y Movement
no_y_chase:
	lda #0
	ora ai_dir
	sta ai_dir
	jmp ai_store
ai_chase_up:
	lda #%00000010
	ora ai_dir
	sta ai_dir
	jmp ai_store
ai_chase_down:
	lda #%00000001
	ora ai_dir
	sta ai_dir
	jmp ai_store
		
	;Store AI DIR to SWACNT and make AI move
ai_store:
	lda	ai_dir 
	sta SWACNT
		
exit_ai_move:
	PERFORME_BANK_SWITCH 0, resume_controller
	;---------------------------------------;
	;--OVERSCAN: 30 scanlines of overscan...;
	;---------------------------------------;
overscan_section:	
	lda #36
	sta TIM64T
	
	;--EVENTS
	lda event_index
	
	;Check Set Over
	cmp #EVENT_SET_OVER
	beq goto_exit_odds
	
	;Check Set Over
	cmp #EVENT_GAME_OVER
	beq goto_exit_odds
	
	;Check for start event
	cmp #EVENT_START_SCREEN
	bne skip_event_start_screen_overscan
	
goto_exit_odds:
	jmp exit_odds
	
skip_event_start_screen_overscan:	
	
	;--Change Ball Movement
	lda ball_x
	;Change the carry depending if it is positive or negative
	bpl change_carry_x
	sec
	adc ball_vel_x
	sta ball_x
change_carry_x:
	clc	
	adc ball_vel_x
	sta ball_x
	
	lda ball_y
	;Change the carry depending if it is positive or negative
	bpl change_carry_y
	sec
	adc ball_vel_y
	sta ball_y
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
	
	;--SET SOUND FOR WHEN BALL HITS THE WALL
	lda sfx_sound_index
	bne skip_ball_down
	lda #SOUND_BALL_HIT_WALL
	ldx #sound_size_ball_hit
	ldy #1
	jsr sfx_set_sound_b1
		
skip_ball_down:	
	;Change the ball velocity to positive
	lda ball_y
	cmp #3
	bcs skip_ball_up
	
	lda #1
	sta ball_vel_y
	
	;--SET SOUND FOR WHEN BALL HITS THE WALL
	lda sfx_sound_index
	bne skip_ball_up
	lda #SOUND_BALL_HIT_WALL
	ldx #sound_size_ball_hit
	ldy #1
	jsr sfx_set_sound_b1
	
skip_ball_up:	
	;Check if Player 1 scored
	lda ball_x
	cmp #$b
	bcs skip_p1_score
	sed
	clc
	lda p1_points
	adc #1
	sta p1_points
	cld
	
	;Check if there is a tie and check for golden goal
	lda game_set
	cmp #4
	bcc skip_to_event_scored_p1
	
	;Set Up Game Over
	lda #EVENT_GAME_OVER
	sta event_index	
	lda #1
	sta who_won
	
	;SET Scored Sound
	lda #EVENT_SCORED
	ldx #sound_size_player_scores
	ldy #1
	jsr sfx_set_sound_b1
	
	;Set Game Over Song
	lda #EVENT_GAME_OVER
	ldx #music_size_game_over
	ldy #3
	jsr sfx_set_music_b1
	
	jmp exit_odds
skip_to_event_scored_p1:
	;Set Event Index to Scored
	lda #EVENT_SCORED
	sta event_index
	lda #SCORE_WAIT
	sta event_timer
	
	;SET Scored Sound
	lda #SOUND_SCORE
	ldx #sound_size_player_scores
	ldy #1
	jsr sfx_set_sound_b1
	
	;Since P1 scores now P0 gets the ball
	jsr p0_gets_ball_b1
	jsr reposition_players_b1
skip_p1_score
	
	;Check if Player 0 scored
	lda ball_x
	cmp #$97
	bcc skip_p0_score
	sed
	clc
	lda p0_points
	adc #1
	sta p0_points
	cld
	
	;Check if there is a tie and check for golden goal
	lda game_set
	cmp #4
	bcc skip_to_event_scored_p0

	;Set Up Game Over
	lda #EVENT_GAME_OVER
	sta event_index	
	lda #0
	sta who_won
	;Set Game Over Song
	lda #EVENT_GAME_OVER
	ldx #music_size_game_over
	ldy #3
	jsr sfx_set_music_b1
	
	jmp exit_odds
skip_to_event_scored_p0:	
	;Set Event Index to Scored
	lda #EVENT_SCORED
	sta event_index
	lda #SCORE_WAIT
	sta event_timer
	
	;SET Scored Sound
	lda #SOUND_SCORE
	ldx #sound_size_player_scores
	ldy #1
	jsr sfx_set_sound_b1
	
	;Since P0 scores now P1 gets the ball
	jsr p1_gets_ball_b1
	jsr reposition_players_b1
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

	;Check Current Timer
	lda current_frame_timer
	beq tick_timer	
	jmp timer_exit
	
tick_timer:
	;Check if Timer is over and wait a second to end set
	lda timer
	and #%11110000
	beq timer_over
	
	;Shift Timer	
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
	
	;Check for the end of clock
	lda timer
	beq timer_over
	jmp timer_exit
	
timer_over:
	;It's a new Set, so increment current set 
	inc game_set	
	;Set event to Set Over
	lda #EVENT_SET_OVER
	sta event_index
	lda #SET_OVER_WAIT
	sta event_timer	
	
	lda #15
	sta music_bps
	lda #EVENT_SET_OVER
	ldx #music_size_set_over
	ldy #1
	jsr sfx_set_music_b1
	
	;--Check who won the set
	lda p0_points 
	cmp p1_points
	beq tie_set
	bcc p1_won_this_set
	inc p0_won_set
	jsr new_gameset_reset
	
	;Check if P0 won the set
	lda p0_won_set
	cmp #3
	bcs p0_won_the_game
	
	jmp timer_exit
tie_set:
	;In case of a time both won
	inc p0_won_set
	inc p1_won_set
	
	;Recheck values 
	lda p0_points 
	cmp p1_points
	bcc check_tie_p1
	
	lda p0_won_set
	cmp #3
	bcs p0_won_the_game
	jmp skip_tie_checker
	
check_tie_p1:	
	lda p1_won_set
	cmp #3
	bcs p1_won_the_game
	
skip_tie_checker:	
	jsr new_gameset_reset
	jmp timer_exit
	
p1_won_this_set:	
	inc p1_won_set
	jsr new_gameset_reset
	
	;Check if P1 won the set
	lda p1_won_set
	cmp #3
	bcs p1_won_the_game
	
	jmp timer_exit
p0_won_the_game:
	lda #EVENT_GAME_OVER
	sta event_index
	
	lda #0
	sta who_won
	
	;Set Game Over Song
	lda #EVENT_GAME_OVER
	ldx #music_size_game_over
	ldy #1
	jsr sfx_set_music_b1
	
	jmp exit_odds
p1_won_the_game:
	lda #EVENT_GAME_OVER
	sta event_index
	
	lda #1
	sta who_won
	
	;Set Game Over Song
	lda #MUSIC_GAME_OVER
	ldx #music_size_game_over
	ldy #3
	jsr sfx_set_music_b1
	
	jmp exit_odds	
timer_exit:	
	
	;--Check Super CX
	bit CXM0P
	bmi p1_super_cx
	bvs p0_super_cx
	jmp exit_super_cx

p1_super_cx:
	;Set Super on For P1
	lda #1
	sta p1_super
	;Take Super off the screen
	lda #0
	sta super_timer
	jmp exit_super_cx
p0_super_cx:
	;Set Super on For P0
	lda #1
	sta p0_super
	;Take Super off the screen
	lda #0
	sta super_timer
exit_super_cx:
	
	;--Check Odds for Super
	lda is_super_on_screen
	beq randomize_super_odds
	
	lda sp_check
	bne dec_super_timer
	
randomize_super_odds:
	
	lda current_frame_timer
	bne exit_odds
	
	;Check Spawn Super Randomly
	jsr get_random_b1
	cmp #SUPER_ODDS
	bcs exit_odds	
	
	;Randomize to see if it is going to be on P0 or P1 side of the court
	lda rand
	and #%00000001
	beq p0_side_super
	
	;P1 Super - TODO
	jsr get_random_b1
	and #%00111111 
	clc
	adc #P0_X_LEFT + P0_X_RIGHT
	cmp #P1_X_RIGHT
	bcc skip_to_super_x
	lda #P1_X_MIDDLE + SUPER_SIZE
	jmp skip_to_super_x
	
p0_side_super:	
	;P0 Super
	jsr get_random_b1
	and #%00111111 
	clc
	adc #P0_X_LEFT
	cmp #P0_X_RIGHT
	bcc skip_to_super_x
	lda #P0_X_MIDDLE + SUPER_SIZE
skip_to_super_x:
	sta super_x
	
	;Setup Random Value to Super Y
	jsr get_random_b1
	and #%00011111
	clc
	adc #14
	cmp #46
	bcc skip_to_super_y
	lda #20
skip_to_super_y:
	sta super_y

	;Enable Super Variables On
	lda #1
	sta sp_check
	sta is_super_on_screen
	
	;Set Music for Super is ON
	lda #14
	sta music_bps
	lda #MUSIC_SUPER_ON
	ldx #music_size_super_on
	ldy #1	
	jsr sfx_set_music_b1
	
	;Set super timer to max
	lda #SUPER_TIME_LIMIT
	sta super_timer
	
	jmp exit_odds
dec_super_timer:
	
	;If Super is Off by player getting it skip to turn off
	lda	super_timer
	beq set_super_off
	
	;Slow Down the Time that Super stays on the screen
	lda current_frame_timer
	bne exit_odds
	
	dec super_timer
	lda	super_timer
	bne exit_odds
	
set_super_off:	
	lda #0
	sta is_super_on_screen
	sta sp_check
	
exit_odds:

	;This section will play the time almost over song
	lda timer+1
	cmp #STOP_SUPER_ODDS
	bne skip_timer_over_song
	
	lda #8
	sta music_bps
	lda #MUSIC_TIMER_DOWN
	ldx #music_size_timer_down
	ldy #1
	jsr sfx_set_music_b1	
skip_timer_over_song:	

	;--------------------------;
	;--SOUND AND MUSIC (SFX)...;
	;--------------------------;
	
	lda sound_timer
	beq skip_sound_timer_area
	jmp music_area
skip_sound_timer_area:
	
	;--Sound
	lda sfx_sound_index
	bne skip_to_start_of_sound
	jmp music_area
	
skip_to_start_of_sound:	
	
	cmp #SOUND_BALL_HIT_WALL
	bne skip_sound_ball_hit_wall
	jmp sfx_ball_hit
skip_sound_ball_hit_wall:
	
	cmp #SOUND_PLAYER_CAUGHT
	bne skip_sound_player_caught
	jmp sfx_player_caught_ball
skip_sound_player_caught:
	
	cmp #SOUND_PLAYER_JUMP
	bne skip_sound_player_jump
	jmp sfx_player_jump
skip_sound_player_jump:
	
	cmp #SOUND_PLAYER_THROW
	bne skip_sound_player_throw
	jmp sfx_player_throw
skip_sound_player_throw:
	
	cmp #SOUND_SUPER_THROW
	bne skip_sound_super_throw
	jmp sfx_player_super_throw
skip_sound_super_throw:
	
	cmp #SOUND_SCORE
	bne skip_sound_score
	jmp sfx_player_score
skip_sound_score:
	
	;If nothing else go to music area
	jmp music_area
	
sfx_ball_hit:
	SFX_INDEX sfx_sound_repeat, sfx_sound_counter, sound_cv_ball_hit, sound_f_ball_hit, sound_size_ball_hit, AUDC0, AUDV0, AUDF0, sound_reset, sfx_exit
sfx_player_caught_ball:
	SFX_INDEX sfx_sound_repeat, sfx_sound_counter, sound_cv_player_caught, sound_f_player_caught, sound_size_player_caught, AUDC0, AUDV0, AUDF0, sound_reset, sfx_exit
sfx_player_jump:
	SFX_INDEX sfx_sound_repeat, sfx_sound_counter, sound_cv_player_jump, sound_f_player_jump, sound_size_player_jump, AUDC0, AUDV0, AUDF0, sound_reset, sfx_exit
sfx_player_throw:
	SFX_INDEX sfx_sound_repeat, sfx_sound_counter, sound_cv_player_throw, sound_f_player_throw, sound_size_player_throw, AUDC0, AUDV0, AUDF0, sound_reset, sfx_exit
sfx_player_super_throw:
	SFX_INDEX sfx_sound_repeat, sfx_sound_counter, sound_cv_super_throw, sound_f_super_throw, sound_size_super_throw, AUDC0, AUDV0, AUDF0, sound_reset, sfx_exit
sfx_player_score:
	SFX_INDEX sfx_sound_repeat, sfx_sound_counter, sound_cv_player_scores, sound_f_player_scores, sound_size_player_scores, AUDC0, AUDV0, AUDF0, sound_reset, sfx_exit
	
sound_reset:
	lda #0
	sta sfx_sound_index
	sta sfx_sound_counter
	sta sfx_sound_repeat
	sta AUDC0
	sta AUDV0
	sta AUDF0
	sta is_sound_playing
	
music_area:	
	;--Music

	;--Music Timer
	lda music_timer
	beq skip_music_timer_area
	jmp jmp_to_sfx_exit
skip_music_timer_area:

	;Check Music Index
	lda sfx_music_index
	bne skip_music_index_area
	jmp jmp_to_sfx_exit
skip_music_index_area:

	cmp #MUSIC_SUPER_ON
	bne skip_music_super_on
	jmp sfx_super_on
skip_music_super_on:	
	
	cmp #MUSIC_SET_OVER
	bne skip_music_set_over
	jmp sfx_set_over
skip_music_set_over:
	
	cmp #MUSIC_GAME_OVER
	bne skip_music_game_over
	jmp sfx_game_over
skip_music_game_over:

	cmp #MUSIC_TIMER_DOWN
	bne skip_music_timer_down
	jmp sfx_timer_down
skip_music_timer_down:
	
jmp_to_sfx_exit:
	jmp sfx_exit
	
sfx_super_on:
	SFX_INDEX sfx_music_repeat, sfx_music_counter, music_cv_super_on, music_f_super_on, music_size_super_on, AUDC1, AUDV1, AUDF1, music_reset, sfx_exit
sfx_set_over:
	SFX_INDEX sfx_music_repeat, sfx_music_counter, music_cv_set_over, music_f_set_over, music_size_set_over, AUDC1, AUDV1, AUDF1, music_reset, sfx_exit
sfx_game_over:
	SFX_INDEX sfx_music_repeat, sfx_music_counter, music_cv_game_over, music_f_game_over, music_size_game_over, AUDC1, AUDV1, AUDF1, music_reset, sfx_exit
sfx_timer_down:
	SFX_INDEX sfx_music_repeat, sfx_music_counter, music_cv_timer_down, music_f_timer_down, music_size_timer_down, AUDC1, AUDV1, AUDF1, music_reset, sfx_exit

music_reset:
	;Reset Values
	lda #0
	sta sfx_music_index
	sta sfx_music_counter
	sta sfx_music_repeat
	sta AUDC1
	sta AUDV1
	sta AUDF1
	sta is_music_playing
	
	;Set Music BPS to default
	lda #MUSIC_TIMER_BPS
	sta music_bps
	
sfx_exit:

Overscan:	
	lda INTIM
	sta WSYNC
	bne Overscan	
	;-------------------;
	;--END OF OVERSCAN--;
	;-------------------;
	PERFORME_BANK_SWITCH 0, StartOfFrame
	
	;------------;
	;--GRAPHICS--;
	;------------;

	;--PLAYFIELD GRAPHICS DATA

	;Clouds Background
PFClouds0:
        .byte #%11010000
        .byte #%00000000
        .byte #%11010000
        .byte #%01100000
        .byte #%00000000
        .byte #%11010000
        .byte #%01110000

PFClouds1:
        .byte #%00001111
        .byte #%01100110
        .byte #%00110000
        .byte #%00000000
        .byte #%01111111
        .byte #%00111110
        .byte #%00001100

PFClouds2:
        .byte #%11110000
        .byte #%01100000
        .byte #%00001110
        .byte #%00011100
        .byte #%00001000
        .byte #%11100000
        .byte #%11000110
PF_CLOUD_SIZE = * - PFClouds2
  
	;CITY background
PFCity0:
        .byte #%11110000
        .byte #%11100000
        .byte #%11100000
        .byte #%10100000
        .byte #%11100000
        .byte #%10100000
        .byte #%11100000
        .byte #%10100000
        .byte #%11100000

PFCity1:
        .byte #%11111111
        .byte #%00111111
        .byte #%00111111
        .byte #%00111111
        .byte #%00110011
        .byte #%00110011
        .byte #%00110011
        .byte #%00000011
        .byte #%00000000

PFCity2:
        .byte #%11111111
        .byte #%10110110
        .byte #%10110110
        .byte #%10010110
        .byte #%10000110
        .byte #%10000110
        .byte #%10000110
        .byte #%00000110
        .byte #%00000110
PF_CITY_SIZE = * - PFCity2

	;TOP Stands
PFStandTop0:
        .byte #%11110000
        .byte #%00010000
        .byte #%00010000
        .byte #%00010000
        .byte #%00010000
        .byte #%00010000
        .byte #%00010000
        .byte #%00010000
        .byte #%00010000
        .byte #%00010000
        .byte #%00010000
        .byte #%00010000
        .byte #%00010000
        .byte #%00010000

PFStandTop1:
        .byte #%11111111
        .byte #%00000000
        .byte #%11011011
        .byte #%11011011
        .byte #%00000000
        .byte #%11011011
        .byte #%11011011
        .byte #%00000000
        .byte #%11011011
        .byte #%11011011
        .byte #%00000000
        .byte #%11011011
        .byte #%11011011
        .byte #%00000000
        
PFStandTop2:
        .byte #%11111111
        .byte #%00000000
        .byte #%10110110
        .byte #%10110110
        .byte #%00000000
        .byte #%10110110
        .byte #%10110110
        .byte #%00000000
        .byte #%10110110
        .byte #%10110110
        .byte #%00000000
        .byte #%10110110
        .byte #%10110110
        .byte #%00000000
PF_STAND_TOP_SIZE = * - PFStandTop2
    
	;BOTTOM Stands
PFStandBot0:
        .byte #%11110000
        .byte #%00010000
        .byte #%00010000
        .byte #%00010000
        .byte #%00010000
        .byte #%00010000
        .byte #%00010000
        .byte #%00010000
        .byte #%00010000
        .byte #%00010000
        .byte #%00010000
        .byte #%00010000
        .byte #%00010000
        .byte #%00010000

PFStandBot1:
        .byte #%11111111
        .byte #%00000000
        .byte #%11011011
        .byte #%11011011
        .byte #%00000000
        .byte #%11011011
        .byte #%11011011
        .byte #%00000000
        .byte #%11011011
        .byte #%11011011
        .byte #%00000000
        .byte #%11011011
        .byte #%11011011
        .byte #%00000000
        
PFStandBot2:
        .byte #%11111111
        .byte #%00000000
        .byte #%10110110
        .byte #%10110110
        .byte #%00000000
        .byte #%10110110
        .byte #%10110110
        .byte #%00000000
        .byte #%10110110
        .byte #%10110110
        .byte #%00000000
        .byte #%10110110
        .byte #%10110110
        .byte #%00000000
PF_STAND_BOT_SIZE = * - PFStandBot2    
	;--end of gpx data
        
	;--------------;
	;--SOUND DATA--;
	;--------------;

	;--SOUNDS

	;BALL HITTING THE WALL SOUND
sound_cv_ball_hit:
	.byte $41,$42,$43
sound_f_ball_hit:
	.byte 8,  8,  8
sound_size_ball_hit = * - sound_f_ball_hit

	;PLAYER CAUGHTING THE BALL SOUND
sound_cv_player_caught:
	.byte $68,$68,$69
sound_f_player_caught:
	.byte 7,  7,  7
sound_size_player_caught = * - sound_f_player_caught

	;PLAYER JUMPING SOUND
sound_cv_player_jump:
	.byte $3F, $3F
sound_f_player_jump:
	.byte 20, 20
sound_size_player_jump = * - sound_f_player_jump

	;PLAYER THROWING THE BALL SOUND
sound_cv_player_throw:
	.byte $84,$84,$84
sound_f_player_throw:
	.byte 24, 23, 22
sound_size_player_throw = * - sound_f_player_throw

	;PLAYER GETS THE SUPER THEN THROWS THE BALL SOUND
sound_cv_super_throw:
	.byte $88,$88,$88,$88,$88
sound_f_super_throw:
	.byte 7, 8, 9, 10, 10
sound_size_super_throw = * - sound_f_super_throw

	;PLAYER SCORES SOUND
sound_cv_player_scores:
	.byte $8E,$8E,$8E
sound_f_player_scores:
	.byte 4,  4, 4
sound_size_player_scores = * - sound_f_player_scores


	;--MUSIC
	;The music was composed by Teksoda, if you like his work you can check him out in the link bellow:
	;https://www.fiverr.com/teksoda

	;SUPER IS ON THE SCREEN MUSIC
music_cv_super_on:
	.byte $c6, $c6, $c6, $c6
music_f_super_on:
	.byte 3, 16, 15, 14
music_size_super_on = * - music_f_super_on

	;THE CURRENT SET IS OVER MUSIC
music_cv_set_over:
	.byte $c6, $c6, $c6, $c6, $c6, $c6, $c6, $c6
music_f_set_over:
	.byte 17, 23, 15, 23, 16, 23, 14, 23
music_size_set_over = * - music_f_set_over

	;THE GAME IS OVER MUSIC
music_cv_game_over:
	.byte $c4, $c4, $c4, $c4, $c4, $c4, $c4, $64, $c4, $c4, $c4, $c4, $c4, $c4, $c4, $c4, $64, $c4, $c4, $c4, $c4, $c4, $c4, $c4, $c4, $64, $c4
music_f_game_over:
	.byte 13, 16, 18, 16, 18, 21, 22, 4, 18, 28, 22, 18, 21, 16, 18, 22, 4, 18, 22, 21, 18, 21, 16, 18, 22, 4, 18
music_size_game_over = * - music_f_game_over

	;THE TIMER IS ALMOST OVER AND TICKING DOWN MUSIC
music_cv_timer_down:
	.byte $c6, $c6, $c6, $c6, $66, $c6, $c6, $c6, $c6, $c6, $c6, $c6, $66, $c6, $c6, $c6, $c6, $c6, $c6, $c6, $c6, $c6, $c6, $c6
music_f_timer_down:
	.byte 13, 13, 26, 13, 4, 13, 22, 13, 22, 13, 21, 13, 3 , 13, 18, 13, 15, 13, 16, 13, 14, 13, 14, 13
music_size_timer_down = * - music_f_timer_down

	echo "There is:", [$2FFA - *]d, "bytes left in Bank 1."
	
	;END OF FILE
	ORG 	$2FFA
	RORG	$FFFA
	
	;--INTERRUPTS
    INTERRUPTS_VECTORS
	
	;---------------;
	;--END OF FILE--;
	;---------------;
   	END
    	