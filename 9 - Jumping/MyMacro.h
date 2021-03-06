
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