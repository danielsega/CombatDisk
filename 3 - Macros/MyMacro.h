	MAC ANI_CHANGE_FRAME
.PLAYER_FPS		SET {1}
.ADDRESS_OUT	SET {2}
.COUNTER		SET {3}
.LOW_RANGE		SET {4}
.HIGH_RANGE		SET {5}

		lda .PLAYER_FPS
		cmp FPS
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