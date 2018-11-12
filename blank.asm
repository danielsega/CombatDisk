	PROCESSOR 6502
    INCLUDE "vcs.h"
	INCLUDE "macro.h"

	SEG
	ORG $F000
            
Reset
	ldx #$40
	stx COLUBK
	
StartOfFrame
    ; Start of vertical blank processing
    lda #0
    sta VBLANK

    lda #2
    sta VSYNC
         
    ; 3 scanlines of VSYNCH signal...
	REPEAT 3
    	sta WSYNC
	REPEND

    lda #0
    sta VSYNC           

    ; 37 scanlines of vertical blank...
	REPEAT 37
    	sta WSYNC
	REPEND
                
    ; 192 scanlines of picture...
    ldy #0
    REPEAT 192; scanlines
    	sta WSYNC
    REPEND

    lda #%01000010
    sta VBLANK                     ; end of screen - enter blanking

    ; 30 scanlines of overscan...
	REPEAT 30
		sta WSYNC
	REPEND

	jmp StartOfFrame

	ORG $FFFA

    .word Reset          ; NMI
    .word Reset          ; RESET
    .word Reset          ; IRQ

   	END
    	