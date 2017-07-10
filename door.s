		ORG $900		

PLOT 	EQU $F800 		; vertical pos in acc, horiz in Y
SETCOL	EQU $F864 		; sets GR plot color
GR		EQU $C050 		; GR mode softswitch
CLRTOP	EQU $F836 		; clear screen
WAIT	EQU $FCA8		; delay
COLOR	EQU $EF			; current plot color
BYTE	EQU $FA			; current byte for display
VERT	EQU $FB			; current vertical position
XTMP	EQU $FC			; X tmp
HORIZ	EQU $FD			; current horiz position
OHORIZ	EQU $FE			; original horiz
OVERT	EQU $FF			; original vert

; .XXXX... 78
; X...X... 88
; X...X... 88
; X...X... 88
; .XXXX... 78
;
; .XXX.... 70
; X...X... 88
; X...X... 88
; X...X... 88
; .XXX.... 70
;
; .XXXX... 78
; X...X... 88
; .XXXX... 78
; X...X... 88
; X...X... 88

SETGR		LDA GR		; graphics mode
			JSR CLRTOP	; clear screen

			LDA #$FF	; long loop
			STA COLOR

SETCOLOR	LDA COLOR
			JSR SETCOL

SETPOSITION	LDA #$08
			STA VERT	; vertical from top
			STA OVERT	; vertical from top
			LDA #$05
			STA HORIZ	; horiz from left
			STA OHORIZ	; horiz from left

			JSR D
			JSR O
			JSR O
			JSR R
			
			DEC COLOR	; loop through to 0
			BNE SETCOLOR	; stop at 1
			
END			RTS 		; END

RESET		LDA #$07	; reset the horizontal starting point
			ADC HORIZ
			STA HORIZ
			LDA OVERT	; reset the vertical starting point
			STA VERT
			RTS

D			JSR DTOP
			JSR MIDDLE
			JSR TOP
			JSR RESET
			RTS
			
O			JSR OTOP
			JSR MIDDLE
			JSR MIDDLE
			JSR OTOP
			JSR RESET
			RTS

R			JSR DTOP
			JSR DTOP
			JSR RESET
			RTS

TOP			LDA #$78	
			JSR LOADBYTE
			RTS

DTOP		JSR TOP
			JSR MIDDLE
			RTS

OTOP		LDA #$70	
			JSR LOADBYTE
			RTS

MIDDLE		LDA #$88	
			JSR LOADBYTE
			LDA #$88	
			JSR LOADBYTE
			RTS

LOADBYTE	STA BYTE		; byte for display
			LDX #$05		; 8 bits, only first 5 needed
PLOTBYTE	ROL BYTE		; rotate out bit to carry
			BCC SKIPPLOT	; if no bit to plot, skip
PLOTBIT		STX XTMP		; horiz offset in X
			LDA HORIZ		; horiz position of letter
			ADC XTMP		; horizontal position of bit
			TAY				; horiz to Y
			LDA VERT		; vertical position to A
			JSR PLOT 		; 
SKIPPLOT	DEX				; x-=1
			BNE PLOTBYTE	; x>0, repeat	
			INC VERT		
			RTS