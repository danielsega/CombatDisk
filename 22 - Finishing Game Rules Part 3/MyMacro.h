
	MAC ANI_CHANGE_FRAME
.PLAYER_FPS		SET {1}
.ADDRESS_OUT	SET {2}
.COUNTER		SET {3}
.LOW_RANGE		SET {4}
.HIGH_RANGE		SET {5}

		lda .PLAYER_FPS
		cmp #8
		beq .inc_frame
		inc .PLAYER_FPS
		jmp .ADDRESS_OUT
		 
.inc_frame:
		ldx #0
		stx .PLAYER_FPS
			 
		inc .COUNTER
		
		lda .COUNTER
		
		;Check if p0_frame_counter is out of range
		cmp #.LOW_RANGE
		bcc .out_of_range
		cmp #.HIGH_RANGE+1
		bcs .out_of_range
		
		jmp .ADDRESS_OUT
.out_of_range:
		ldx #.LOW_RANGE
		stx .COUNTER
		 
		jmp .ADDRESS_OUT
	ENDM 
	
	MAC MOVECX_ADD_AND_CMP
.POSITION	SET {1}
.VELOCITY	SET {2}
.TARGET		SET {3}
	lda .POSITION
	clc
	adc .VELOCITY
	
	cmp #.TARGET
	bcs .stop_moving_up
	.byte $2c
.stop_moving_up:
	lda #.TARGET
	
	sta .POSITION	
	ENDM
	
	MAC MOVECX_SBC_AND_CMP
.POSITION	SET {1}
.VELOCITY	SET {2}
.TARGET		SET {3}

	lda .POSITION
	sec
	sbc .VELOCITY
	
	cmp #.TARGET
	bcc .p0_stop_moving_down
	.byte $2c
.p0_stop_moving_down:
	lda #.TARGET
	
	sta .POSITION	
	ENDM
	
	MAC SPRITE_FRAME_CHECKER
.PLAYER_FRAME_COUNTER	SET {1}	
.PLAYER_FPS				SET {2}
.LAST_FRAME				SET {3}
.ARRIVED				SET {4}
.JUMP_OUT				SET {5}
	;Check if it is in the last sprite
	lda .PLAYER_FRAME_COUNTER
	cmp #.LAST_FRAME
	beq .PLAYER_CHECK_FRAME
	jmp .JUMP_OUT
	;Check if it is in the last frame, prior to change into the new sprite
.PLAYER_CHECK_FRAME:
	lda .PLAYER_FPS
	cmp #8
	beq .ARRIVED
	jmp .JUMP_OUT
	
	ENDM 
	
	MAC COMPARE_CONT_JUMP
.CMP_VALUE			SET {1}	
.JMP_LOCATION		SET {2}	
	cmp #.CMP_VALUE
	bne .skip_cont_jump
	jmp .JMP_LOCATION
.skip_cont_jump:
	ENDM 
	
	MAC CONT_JUMP_MOVEMENT
.SUB_ROUT			SET {1}	
.FRAME_COUNTER		SET {2}
.PLAYER_FPS			SET {3}
.PLAYER_VEL			SET {4}
.LAST_FRAME			SET {5}
.JUMP_FRAME			SET {6}
.STILL_IMAGE		SET {7}
.DIR_STOP			SET {8}
.JUMP_DIR			SET {9}
.EXIT				SET {10}

	ldy #0
	
	;Move sprite
	jsr .SUB_ROUT
	
	;Compare value once it reaches it, slow player vel from 2 to 1
	lda .PLAYER_FPS	
	cmp #6
	bne .slow_down
	lda #1
	sta .PLAYER_VEL
.slow_down:	
	;Check if it is in the last sprite
	lda .FRAME_COUNTER
	cmp #.LAST_FRAME
	beq .PLAYER_CHECK_FRAME
	jmp .JUMP_FRAME
	;Check if it is in the last frame, prior to change into the new sprite
.PLAYER_CHECK_FRAME:
	lda .PLAYER_FPS
	cmp #8
	beq .finished
	jmp .JUMP_FRAME
.finished:
	;Set sprite still image
	lda #.STILL_IMAGE
	sta .FRAME_COUNTER
	
	;Skip the continue jump
	lda #.DIR_STOP
	sta .JUMP_DIR
	
	;Make sure player can't move for desired time
	sty .PLAYER_VEL		
	jmp .EXIT
	
	ENDM
	
	MAC PLAYER_WON_SET_DATA
.PLAYER_WON_SET		SET {1}	
.MERGER				SET {2}
	lda .PLAYER_WON_SET
	beq .no_change
	cmp #1
	beq .won_1_set
	
	lda #%00000101
	sta .MERGER	
	jmp .exit_set_won
.won_1_set:
	lda #%00000100
	sta .MERGER	
	jmp .exit_set_won
.no_change:
	lda #0
	sta .MERGER	
.exit_set_won:

	ENDM 
	
	MAC SFX_INDEX
.SFX_REPEAT			SET {1}
.SFX_COUNTER		SET {2}
.SFX_CV				SET {3}
.SFX_F				SET {4}
.SFX_SIZE			SET {5}
.SFX_AUDC			SET {6}
.SFX_AUDV			SET {7}
.SFX_AUDF			SET {8}
.SFX_RESET			SET {9}
.SFX_EXIT			SET {10}	
	lda .SFX_REPEAT
	bne .skip_reset
	jmp .SFX_RESET
.skip_reset:
	
	ldx .SFX_COUNTER
	bne .skip_counter
	jmp .SFX_RESET
.skip_counter:	
	
	;Control
	lda .SFX_CV,X
	and #%11110000
	sta .SFX_AUDC
	
	;Volume
	lda .SFX_CV,X
	and #%00001111
	sta .SFX_AUDV
	
	;Frenquency
	lda .SFX_F,X
	sta .SFX_AUDF
	
	;Check for sound counter if it reached the end to decement our repeat value
	dec .SFX_COUNTER
	lda .SFX_COUNTER
	bne .skip_sfx_counter
	
	;Check if sound repeat is done
	lda .SFX_REPEAT
	beq .skip_sfx_counter
	
	;Reset sound counter value and decement repeat
	lda #.SFX_SIZE
	sta .SFX_COUNTER
	dec .SFX_REPEAT
	
	;--Exit Ball Hit
.skip_sfx_counter:	
	jmp .SFX_EXIT	
	ENDM 
	
	MAC M_RANDOM
.rand		SET {1}	
	lda .rand
    beq .doEor_b1
    asl
    beq .noEor_b1
    bcc .noEor_b1
.doEor_b1:
    eor #$1d
.noEor_b1:
	sta .rand
    rts	
	ENDM 
	
	MAC M_SET_SFX
.index		SET {1}
.counter	SET {2}
.rep		SET {3}	
	sta .index
	stx .counter
	sty .rep
	rts	
	ENDM 
	
	MAC M_P0_GETS_BALL
.BALL_X			SET {1}
.BALL_Y			SET {2}
.BALL_VEL_X		SET {3}
.BALL_VEL_Y		SET {4}
.BALL_SIZE		SET {5}
.COURT_SIZE		SET {6}
	;Ball X Position
	lda #70
	sta .BALL_X
	;Ball Y Position
	lda #.COURT_SIZE + .BALL_SIZE
	sta .BALL_Y
	;Ball X and Y Velocity
	lda #$ff
	sta .BALL_VEL_X
	sta .BALL_VEL_Y
	rts	
	ENDM 
	
	MAC M_P1_GETS_BALL
.BALL_X			SET {1}
.BALL_Y			SET {2}
.BALL_VEL_X		SET {3}
.BALL_VEL_Y		SET {4}
.BALL_SIZE		SET {5}
.COURT_SIZE		SET {6}
	;Ball X Position
	lda #85
	sta .BALL_X
	;Ball Y Position
	lda #.COURT_SIZE + .BALL_SIZE
	sta .BALL_Y
	;Ball Velocity X Position
	lda #1
	sta .BALL_VEL_X
	;Ball Velocity Y Position
	lda #$ff
	sta .BALL_VEL_Y
	rts		
	ENDM 
