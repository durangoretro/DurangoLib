; ---------------------------------------------------------------------------
; DURANGO SDK. CC65 SUPPORT
; Durango conio lib
; @author: Emilio Lopez Berenguer emilio@emiliollbb.net
; @author: Carlos Santisteban Salinas zuiko21@gmail.com
; @author: Victor Suárez García zerasul@gmail.com
; ---------------------------------------------------------------------------


.include "durango_hw.inc"
.include "crt0.inc"
.PC02


.importzp  sp
.import incsp4
.import DEFAULT_FONT

.export _conioInit
.export _setFont
.export _printstr

.segment "LIB"

.proc  conio: near
;	INPUT
; A <-	char to be printed (1...255)
; A <-  0  for input mode
;	supported control codes in this version
;		0	= ask for one character (non-locking)
;		1	= start of line (CR withput LF, eg. set Y to one so DEY sets Z and skips LF routine)
;		2	= cursor left
;		6	= cursor right
;		7	= beep
;		8	= backspace
;		9	= TAB (x+8 MOD 8 in any case)
;		10	= line feed (cursor down, direct jump needs no Y set)
;		11	= cursor up
;		12	= clear screen AND initialise device
;		13	= newline (actually LF after CR, eg. set Y to anything but 1 so DEY clears Z and does LF)
;		14	= inverse video
;		15	= true video
;		16	= DLE, do not execute next control char
;		17	= cursor on
;		18	= set ink colour (+32 MOD 16 for colour mode, hires will set it as well but will be ignored)*
;		19	= cursor off
;		20	= set paper colour (same as INK colour)*
;		21	= home without clear
;		23	= set cursor position**
;		31	= back to text mode (simply IGNORED)
; commands marked * will take a second char as parameter
; command marked ** takes two subsequent bytes as parameters
;	OUTPUT
; A = 0 ->	no available char
; A -> input char (if A was 0 on entry)

; *** zeropage variables ***
; DATA_POINTER (pointer to glyph definitions)
; VMEM_POINTER (screen pointer)
; CONIO_TEMP (temporary glyph storage, remaining pages to write)
; CONIO_TCOL (array 00.01.10.11 of two-pixel combos, will store ink & paper)
;	FF will reconstruct it from [1] (PAPER-INK)
; CONIO_POSI (upper scan of cursor position)
; CONIO_SCUR ([NEW] flag D7=cursor ON)

; * other variables *
; CONIO_FONT (pointer to relocatable 2KB font file)
; CONIO_MASK (for inverse/emphasis mode)
; CONIO_MODE (binary or multibyte mode, must be reset prior to first use)

; *** new option, keyboard control by NES gamepad *** KBBYPAD
; *** UP/DOWN    = +/- 32 to ASCII                ***
; *** LEFT/RIGHT = next/prev ASCII                ***
; *** A          = put char into buffer           ***
; *** B          = press BACKSPACE                ***
; *** START      = press RETURN                   ***
; *** SELECT     = press ESCAPE                   ***

; *** special constants ***
; first two modes are directly processed, note BM_DLE is the shifted X
BM_CMD = 0
BM_DLE = 32
; these modes are handled by indexed jump, note offset of 2
BM_INK = 2
BM_PPR = 4
BM_ATY = 6
BM_ATX = 8

	TYA						; is going to be needed here anyway
	LDX CONIO_MODE			; check whether in binary/multibyte mode
	BEQ cio_cmd				; if not, check whether command (including INPUT) or glyph
		CPX #BM_DLE			; just receiving what has to be printed?
			BEQ cio_gl		; print the glyph!
		JMP (cio_mbm-2, X)	; otherwise process following byte as expected, note offset
cio_cmd:
	CMP #32					; printable anyway?
	BCS cio_prn				; go for it, flag known to be clear
		ASL					; if arrived here, it MUST be below 32! two times
		TAX					; use as index
		JMP (cio_ctl, X)	; execute from table
cio_gl:
    STZ CONIO_MODE			; clear flag!
cio_prn:
; ***********************************
; *** output character (now in A) ***
; ***********************************
	ASL						; times eight scanlines
	ROL DATA_POINTER+1		; M=???????7, A=6543210·
	ASL
	ROL DATA_POINTER+1		; M=??????76, A=543210··
	ASL
	ROL DATA_POINTER+1		; M=?????765, A=43210···
	CLC
	ADC CONIO_FONT			; add font base
	STA DATA_POINTER
	LDA DATA_POINTER+1		; A=?????765
	AND #7					; A=·····765
	ADC CONIO_FONT+1		; in case no glyphs for control codes, this must hold actual MSB-1
	STA DATA_POINTER+1		; pointer to glyph is ready
	LDY CONIO_POSI			; get current address
	LDA CONIO_POSI+1
	STY VMEM_POINTER		; set pointer
	STA VMEM_POINTER+1
	LDY #0					; reset screen offset (common)
; *** now check for mode and jump to specific code ***
	BIT VIDEO_MODE				; check mode, code is different, will only check d7
	BPL cpc_col				; skip to colour mode, hires is smaller
; hires version (17b for CMOS, usually 231t, plus jump to cursor-right)
cph_loop:
			LDA (DATA_POINTER)	; glyph pattern (5)
			EOR CONIO_MASK		; in case inverse mode is set, much better here (4)
			STA (VMEM_POINTER), Y	; put it on screen (5)
			INC DATA_POINTER		; advance to next glyph byte (5)
			BNE cph_nw		    ; (usually 3, rarely 7)
				INC DATA_POINTER+1
cph_nw:
			TYA				; advance to next screen raster (2+2)
			CLC
			ADC #32			; 32 bytes/raster EEEEEEEEK (2)
			TAY				; offset ready (2)
			BNE cph_loop	; offset will just wrap at the end EEEEEEEK (3)
; ...but should NOT delete (XOR) previous cursor, as has disappeared while printing
		BEQ do_cur_r		; advance cursor without clearing previous
; colour version, 85b, typically 975t (77b, 924t in ZP)
; new FAST version, but no longer with sparse array
cpc_col:
	LDX #2
	STX CONIO_TEMP			; two pages must be written (2+4*)
cpc_do:						; outside loop (done 8 times) is 8x(45+inner)+113=969, 8x(42+inner)+111=919 in ZP  (was ~1497/1407)
		LDA (DATA_POINTER)	; glyph pattern (5)
		EOR CONIO_MASK			; in case inverse mode is set, much better here (4)
; *** *** glyph pattern is loaded and masked, let's try an even faster alternative, store all 4 positions premasked as sparse indexes
		TAX					; keep safe (2)
		AND #%00000011		; rightmost pixels (2)
		STA TEMP1			; fourth and last sparse index (4*, note inverted order)
		TXA					; quickly get the rest (2)
		AND #%00001100		; pixels 4-5 (2)
		LSR
        LSR		        	; no longer sparse (2+2)
		STA TEMP2		    ; third sparse index (4*)
		TXA
		AND #%00110000		; pixels 2-3 (2+2)
		LSR
        LSR
		LSR
        LSR     			; no longer sparse, C is clear (2+2+2+2)
		STA TEMP3	    	; second sparse index (4*)
		TXA
		AND #%11000000		; two leftmost pixels (will be processed first) (2+2)
		ROL
        ROL
        ROL         		; no longer sparse, faster this way and ready to use as index (2+2+2)
		INC DATA_POINTER	; advance to next glyph byte (5+usually 3)
		BNE cpc_loop
			INC DATA_POINTER+1
cpc_loop:					; (all loop was 122/115t, now unrolled is 62/59t)
			TAX				        ; A was sparse index (2)
			LDA CONIO_TCOL, X	    ; get proper colour pair (4)
			STA (VMEM_POINTER), Y	; put it on screen (6 eeek)
			INY				        ; next screen byte for this glyph byte (2)
; here comes the time critical part, let's try to unroll
			LDX TEMP3	            ; get next sparse index (4*)
			LDA CONIO_TCOL, X	    ; get proper colour pair (4)
			STA (VMEM_POINTER), Y	; put it on screen (6 eeek)
			INY				        ; next screen byte for this glyph byte (2)
			LDX TEMP2	            ; get next sparse index (4*)
			LDA CONIO_TCOL, X	    ; get proper colour pair (4)
			STA (VMEM_POINTER), Y	; put it on screen (6 eeek)
			INY				        ; next screen byte for this glyph byte (2)
			LDX TEMP1   	        ; get next sparse index (4*)
			LDA CONIO_TCOL, X	    ; get proper colour pair (4)
			STA (VMEM_POINTER), Y	; put it on screen (6 eeek)
			INY				        ; next screen byte for this glyph byte (2)
; ...etc
cpc_rend:					        ; end segment has not changed, takes 6x11 + 2x24 - 1, 113t (66+46-1=111t in ZP)
		TYA					        ; advance to next screen raster, but take into account the 4-byte offset (2+2+2)
		CLC
		ADC #60
		TAY					        ; offset ready (2)
		BNE cpc_do			        ; unfortunately will wrap twice! (mostly 3)
			INC VMEM_POINTER+1	    ; next page for the last 4 raster (5)
			DEC CONIO_TEMP	        ; only one half done? go for next and last (*6+3)
		BNE cpc_do
; advance screen pointer before exit, no need for jump if cursor-right is just here...
; ...but should NOT delete (XOR) previous cursor, as has disappeared while printing
	BEQ do_cur_r			; advance cursor without clearing previous

; **********************
; *** cursor advance *** placed here for convenience of printing routine
; **********************
cur_r:
	BIT CONIO_SCUR			; if cursor is on... [NEW]
	BPL do_cur_r
		JSR draw_cur		; ...must delete previous one
do_cur_r:
	LDA #1					; base character width (in bytes) for hires mode
	BIT VIDEO_MODE				; check mode
	BMI rcu_hr				; already OK if hires
		LDA #4				; ...or use value for colour mode
rcu_hr:
	CLC
	ADC CONIO_POSI			; advance pointer
	STA CONIO_POSI			; EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEK
	BCC rcu_nw				; check possible carry
		INC CONIO_POSI+1
rcu_nw:						; will return, no need for jump if routine is placed below

; ************************
; *** support routines ***
; ************************
ck_wrap:
; check for line wrap
; address format is 011yyyys-ssxxxxpp (colour), 011yyyyy-sssxxxxx (hires)
; thus appropriate masks are %11100000 for hires and %11000000 in colour... but it's safer to check MSB's d0 too!
	LDY #%11100000			; hires mask
	BIT VIDEO_MODE				; check mode
	BMI wr_hr				; OK if we're in hires
; let's be safe...
        LDA CONIO_POSI+1	; check MSB
		LSR					; just check d0, should clear C
			BCS do_cr       ; was cn_begin?	; strange scanline, thus time for the NEWLINE (Y>1)
		LDY #%11000000		; in any case, get proper mask for colour mode
wr_hr:
	TYA						; prepare mask and guarantee Y>1 for auto LF
	AND CONIO_POSI			; are scanline bits clear?
		BNE do_cr           ; was cn_begin?	; nope, do NEWLINE
	BIT CONIO_SCUR			; if cursor is on... [NEW]
	BPL do_ckw
		JSR draw_cur		; ...must draw new one
do_ckw:
	RTS 					; continue normally otherwise

; ************************
; *** control routines ***
; ************************
cn_cr:
; this is the CR without LF
	LDY #1					; will skip LF routine
	BNE cn_begin

cur_l:
; cursor left, no big deal, but do not wrap if at leftmost column
; colour mode subtracts 4, but only 1 if in hires
; only if LSB is not zero, assuming non-corrupted scanline bits
; could use N flag after subtraction, as clear scanline bits guarantee its value
	BIT CONIO_SCUR			; if cursor is on... [NEW]
	BPL do_cur_l
		JSR draw_cur		; ...must delete previous one
do_cur_l:
	LDA #1					; hires decrement (these 9 bytes are the same as cur_r)
	BIT VIDEO_MODE
	BMI cl_hr				; right mode for the decrement EEEEEK
		LDA #4				; otherwise use colour value
cl_hr:
	STA DATA_POINTER		; EEEEEEEEEEEK
	SEC
	LDA CONIO_POSI
	SBC DATA_POINTER		; subtract to pointer, but...
	BMI cl_end				; ...ignore operation if went negative
		STA CONIO_POSI		; update pointer
cl_end:
	BIT CONIO_SCUR			; if cursor is on... [NEW]
	BPL do_cle
		JSR draw_cur		; ...must draw new one
do_cle:
	CLC
	RTS					; C known to be set, though

cn_newl:
; CR, but will do LF afterwards by setting Y appropriately
		TAY					; Y=26>1, thus allows full newline
cn_begin:
; do CR... but keep Y
	BIT CONIO_SCUR			; if cursor is on... [NEW]
	BPL do_cr
		PHY					; CMOS only eeeeeek
		JSR draw_cur		; ...must delete previous one
		PLY
do_cr:
; note address format is 011yyyys-ssxxxxpp (colour), 011yyyyy-sssxxxxx (hires)
; actually is a good idea to clear scanline bits, just in case
	STZ CONIO_POSI			; all must clear! helps in case of tab wrapping too (eeeeeeeeek...)
; in colour mode, the highest scanline bit is in MSB, usually (TABs, wrap) not worth clearing
; ...but might help with unexpected mode change
; let's be safe...
	BIT VIDEO_MODE			; was it in hires mode?
	BMI cn_lmok
		LDA #1				; bit to be cleared (5b/7t)
		TRB CONIO_POSI+1	; nice...
cn_lmok:
; check whether LF is to be done
	DEY						; LF needed?
	BEQ cn_ok				; not if Y was 1 (use BMI if Y was zeroed for LF)
; *** will do LF if Y was >1 ONLY ***
	BNE do_lf				; [NEW]
cn_lf:
; do LF, adds 1 (hires) or 2 (colour) to MSB
; even simpler, INCrement MSB once... or two if in colour mode
; hopefully highest scan bit is intact!!!
	BIT CONIO_SCUR			; if cursor is on... [NEW]
	BPL do_lf
		JSR draw_cur		; ...must delete previous one
do_lf:
	INC CONIO_POSI+1		; increment MSB accordingly, this is OK for hires
	BIT VIDEO_MODE			; was it in hires mode?
	BMI cn_hmok
		INC CONIO_POSI+1	; once again if in colour mode... 
cn_hmok:
; must check for possible scrolling!!! simply check sign ;-) ...or compare against dynamic limit
	BPL cn_ok               ; was LDA CONIO_POSI+1;CMP fw_vtop;BNE cn_ok
; *** *** TO DO *** *** should not scroll wight now, but wait for next char to be printed
; ** scroll routine **
; rows are 256 bytes apart in hires mode, but 512 in colour mode
	LDY #0					; LSB *must* be zero, anyway, as is SCREEN_3
; MSB is actually OK for destination, but take from current value
	LDX #$60                ; was fw_vbot
	STY VMEM_POINTER		; set both LSBs
	STY DATA_POINTER
	STX VMEM_POINTER+1		; destination is set
	INX						; note trick for NMOS-savvyness
	BIT VIDEO_MODE			; check mode anyway
	BMI sc_hr				; +256 is OK for hires
		INX					; make it +512 for colour
sc_hr:
	STX DATA_POINTER+1		; we're set, worth keep incrementing this
sc_loop:
		LDA (DATA_POINTER), Y	; move screen data ASAP
		STA (VMEM_POINTER), Y
		INY					    ; do a whole page
		BNE sc_loop
	INC VMEM_POINTER+1		; both MSBs are incremented at once...
	INX
	STX DATA_POINTER+1		; ...but only source will enter high-32K at the end
        BPL sc_loop         ; was CPX fw_vtop;BNE sc_loop

; data has been transferred, now should clear the last line
	JSR cio_clear			; cannot be inlined! Y is 0
; important, cursor pointer must get back one row up! that means subtracting one (or two) from MSB
	LDA VIDEO_MODE			; eeeeeek
	ASL						; now C is set for hires
	LDA CONIO_POSI+1		; cursor MSB
	SBC #1					; with C set (hires) this subtracts 1, but 2 if C is clear! (colour)
	STA CONIO_POSI+1
cn_ok:
	BIT CONIO_SCUR			; if cursor is on... [NEW]
	BPL do_cnok
		JSR draw_cur		; ...must draw new one
do_cnok:
	RTS

cn_tab:
; advance column to the next 8x position (all modes)
; this means adding 8 to LSB in hires mode, or 32 in colour mode
; remember format is 011yyyys-ssxxxxpp (colour), 011yyyyy-sssxxxxx (hires)
	BIT CONIO_SCUR			; if cursor is on... [NEW]
	BPL do_tab
		JSR draw_cur		; ...must delete previous one
do_tab:
	LDA #%11111000			; hires mask first
	STA CONIO_TEMP			; store temporarily *** check tmp ***
	LDA #8					; lesser value in hires mode
	BIT VIDEO_MODE			; check mode
	BMI hr_tab				; if in hires, A is already correct
		ASL CONIO_TEMP
		ASL CONIO_TEMP		; shift mask too, will set C
		ASL
		ASL					; but this will clear C in any case
hr_tab:
	ADC CONIO_POSI			; this is LSB, contains old X...
	AND CONIO_TEMP			; ...but round down position from the mask!
	STA CONIO_POSI
; not so fast, must check for possible line wrap... and even scrolling!
	JMP ck_wrap				; will return in any case

cio_bel:
; BEL, make a beep!
; 40ms @ 1 kHz is 40 cycles
; the 500µs halfperiod is about 325t
	PHP 					; let's make things the right way
    SEI
	LDX #79					; 80 half-cycles, will end with d0 clear
cbp_pul:
		STX AUDIO_OUT		; pulse output bit (4)
		LDY #63				; should make around 500µs halfcycle (2)
cbp_del:
			DEY
			BNE cbp_del		; each iteration is (2+3)
		DEX					; go for next semicycle
		BPL cbp_pul			; must do zero too, to clear output bit
	PLP     				; eeeeek
	RTS

cio_bs:
; BACKSPACE, go back one char and clear cursor position
	JSR cur_l				; back one char, if possible, then clear cursor position
	BIT CONIO_SCUR			; if cursor is on... [NEW]
	BPL do_bs
		JSR draw_cur		; ...must delete previous one
do_bs:
	LDY CONIO_POSI
	LDA CONIO_POSI+1		; get current cursor position...
	STY VMEM_POINTER
	STA VMEM_POINTER+1		; ...into zp pointer
	LDX #8					; number of scanlines...
	STX CONIO_TEMP			; ...as temporary variable *** check
; load appropriate A value (clear for hires, paper index repeated for colour)
	LDX #0					; last index offset should be 0 for hires!
	TXA						; hires takes no account of paper colour
	LDY #31					; this is what must be added to Y each scanline, in hires
	BIT VIDEO_MODE			; check mode
	BMI bs_hr
		LDA CONIO_TCOL		; this is two pixels of paper colour
		LDX #3				; last index offset per scan (colour)
		LDY #60				; this is what must be added to Y each scanline, in colour
bs_hr:
	STX DATA_POINTER		; another temporary variable
	STY DATA_POINTER+1		; this is most used, thus must reside in ZP
	LDY #0					; eeeeeeeeek
bs_scan:
			STA (VMEM_POINTER), Y	; clear screen byte
			INY				        ; advance, just in case
			DEX				        ; one less in a row
			BPL bs_scan
		LDX DATA_POINTER	; reload this counter
		PHA					; save screen value!
		TYA
		CLC
		ADC DATA_POINTER+1	; advance offset to next scanline
		TAY
		BCC bs_scw
			INC VMEM_POINTER+1	    ; colour mode will cross page
bs_scw:
		PLA					; retrieved value, is there a better way?
		DEC CONIO_TEMP		; one scanline less to go
		BNE bs_scan
	BIT CONIO_SCUR			; if cursor is on... [NEW]
	BPL end_bs
		JSR draw_cur		; ...must delete previous one
end_bs:
	RTS 					; should be done

cio_up:
; cursor up, no big deal, will stop at top row (NMOS savvy, always 23b and 39t)
	BIT CONIO_SCUR			; if cursor is on... [NEW]
	BPL do_cup
		JSR draw_cur		; ...must delete previous one
do_cup:
	LDA VIDEO_MODE			; check mode
	ROL						; now C is set in hires!
	PHP						; keep for later?
	LDA #%00001111			; incomplete mask, just for the offset, independent of screen-block
	ROL						; but now is perfect! C is clear
	PLP						; hires mode will set C again but do it always! eeeeeeeeeeek
	AND CONIO_POSI+1		; current row is now 000rrrrR, R for hires only
	BEQ cu_end				; if at top of screen, ignore cursor
		SBC #1				; this will subtract 1 if C is set, and 2 if clear! YEAH!!!
;		AND #%00011111		; may be safer with alternative screens
		ORA #$60            ; was fw_vbot			; EEEEEEK must complete pointer address (5b, 6t)
		STA CONIO_POSI+1
cu_end:
	BIT CONIO_SCUR			; if cursor is on... [NEW]
	BPL do_cu_end
		JSR draw_cur		; ...must draw new one
do_cu_end:
	RTS

; FF, clear screen
cio_ff:
; * things to be initialised... *
; CONIO_TCOL, note it's an array now (restore from PAPER-INK previous setting)
; CONIO_MASK (for inverse/emphasis mode)
; CONIO_MODE (binary or multibyte mode, but must be reset BEFORE first FF)

	STZ CONIO_MASK			; true video *** no real need to reset this
	JSR rs_col				; restore array from whatever is at CONIO_TCOL[1] (will restore CONIO_MODE)
; font is no longer initialised!
; standard CLS, reset cursor and clear screen
	JSR cio_home			; reset cursor and load appropriate address
; recompute MSB in A according to hardware NO MORE
	STY VMEM_POINTER		; set pointer (LSB=0)...
	STA VMEM_POINTER+1
; ...and clear whole screen, will return to caller
cio_clear:
; ** generic screen clear-to-end routine, just set VMEM_POINTER with initial address and Y to zero **
; this works because all character rows are page-aligned
; otherwise would be best keeping pointer LSB @ 0 and setting initial offset in Y, plus LDA #0
; anyway, it is intended to clear whole rows
	TYA						    ; A should be zero in hires, and Y is known to have that
	BIT VIDEO_MODE
	BMI sc_clr				    ; eeeeeeeeek
		LDA CONIO_TCOL		    ; EEEEEEEEK, this gets paper colour byte
sc_clr:
		STA (VMEM_POINTER), Y	; clear all remaining bytes
		INY
		BNE sc_clr
	INC VMEM_POINTER+1			; next page
        BPL sc_clr              ; was LDX VMEM_POINTER+1;CPX fw_vtop;BNE sc_clr
	BIT CONIO_SCUR				; if cursor is on... [NEW]
	BPL do_ff
		JSR draw_cur		    ;   ...must draw new one, as the one from home was cleared
do_ff:
	RTS

; SO, set inverse mode
cn_so:
	LDA #$FF				; OK for all modes?
	STA CONIO_MASK			; set value to be EORed
	RTS

; SI, set normal mode
cn_si:
	STZ CONIO_MASK			; clear value to be EORed
	RTS

md_dle:
; DLE, set binary mode
;	LDX #BM_DLE				; X already set if 32
	STX CONIO_MODE			; set binary mode and we are done
ignore:
	RTS						; *** note generic exit ***

cio_cur:
; XON, we now have cursor! [NEW]
	LDA #128				; flag for cursor on
	TSB CONIO_SCUR			; check previous flag (and set it now)
	BNE ignore				; if was set, shouldn't draw cursor again
		JMP draw_cur		; go and return

cio_curoff:
; XOFF, disable cursor [NEW]
	LDA #128				; flag for cursor on
	TRB CONIO_SCUR			; check previous flag (and clear it now)
	BNE ignore				; if was set, shouldn't draw cursor again
		JMP draw_cur		; go and return

md_ink:
; just set binary mode for receiving ink! *** could use some tricks to unify with paper mode setting
	LDX #BM_INK				; next byte will set ink
	STX CONIO_MODE			; set multibyte mode and we are done
	RTS

md_ppr:
; just set binary mode for receiving paper! *** check above for simpler alternative
	LDX #BM_PPR				; next byte will set ink
	STX CONIO_MODE			; set multibyte mode and we are done
	RTS

cio_home:
; just reset cursor pointer, to be done after (or before!) CLS
	BIT CONIO_SCUR			; if cursor is on... [NEW]
	BPL do_home
		JSR draw_cur		; ...must draw new one
do_home:
	LDY #0					; base address for all modes, actually 0 EEEEEK
	LDA #$60                ; was fw_vbot				; current screen setting!
	STY CONIO_POSI			; just set pointer
	STA CONIO_POSI+1
	RTS						; C is clear, right?

md_atyx:
; prepare for setting y first
	LDX #BM_ATY				; next byte will set Y and then expect X for the next one
	STX CONIO_MODE			; set new mode, called routine will set back to normal
	RTS

draw_cur:
; draw (XOR) cursor [NEW]
	LDX CONIO_POSI+1		; get cursor position
        BMI no_cur          ; outside bounds? do not attempt to write! was CPX fw_vtop;BCS no_cur
	LDY CONIO_POSI
	STY VMEM_POINTER		; set pointer LSB (common)
	STX VMEM_POINTER+1		; set pointer MSB
	BIT VIDEO_MODE			; check screen mode
	BPL dc_col				; skip if in colour mode
		LDY #224			; seven rasters down
		LDX #1				; single byte cursor
		BNE dc_loop			; no need for BRA
dc_col:
	INC VMEM_POINTER+1		; this goes into next page (4 rasters down)
	LDY #192				; 3 rasters further down
	LDX #4					; bytes per char raster
dc_loop:
		LDA (VMEM_POINTER), Y	; get screen data...
		EOR #$FF			    ; ...invert it...
		STA (VMEM_POINTER), Y	; ...and update it
		INY					    ; next byte in raster
		DEX
		BNE dc_loop
no_cur:
	RTS

; *******************************
; *** some multibyte routines ***
; *******************************
; set INK, 19b + common 55b, old version was 44b
cn_ink:
	AND #15					; 2= ink to be set
	STA CONIO_TEMP			; temporary INK storage			(0I)
	LDA CONIO_TCOL+1		; get combined storage
	AND #$F0				; only old PAPER at high nibble	(p0)
	ORA CONIO_TEMP			; combine result				(pI)
	STA CONIO_TCOL+1
	JMP set_col				; and complete array

; set PAPER, 18b + common 55b, old version was 42b
cn_ppr:						; 4= paper to be set
;	AND #15					; shifting will delete MSN
	ASL
	ASL
	ASL
	ASL						; PAPER in high nibble			(P0)
	STA CONIO_TEMP			; temporary storage
	LDA CONIO_TCOL+1		; previous combined storage
	AND #$0F				; only old INK at low nibble	(0i)
	ORA CONIO_TEMP			; combine result with PAPER...	(Pi)
	STA CONIO_TCOL+1		; ...and fall to complete the array
;	JMP set_col
; reconstruct array from PAPER-INK index
; * surely can be shrinked by use of lost fw_ccnt, but who cares...
rs_col:						; restore colour aray from [1] (PAPER-INK)
	LDA CONIO_TCOL+1		; get all				xx PI xx xx
set_col:
	AND #$0F				; ink only
	STA CONIO_TEMP			; temporary ink storage	(0I)
	ASL
	ASL
	ASL
	ASL						; ink in high nibble	(I0)
	ORA CONIO_TEMP			; all ink...			(II)
	STA CONIO_TCOL+3		; ... at [3]			xx PI xx II
	AND #$F0				; high nibble only...	(I0)
	STA CONIO_TEMP			; ...temporary
	LDA CONIO_TCOL+1		; both colours again	(PI)
	LSR
	LSR
	LSR
	LSR						; PAPER at low nibble	(0P)
	ORA CONIO_TEMP			; this is INK-PAPER...	(IP)
	STA CONIO_TCOL+2		; ...at [2]				xx PI IP II
	AND #$0F				; paper only			(0P)
	STA CONIO_TEMP
	ASL
	ASL
	ASL
	ASL						; at high nibble		(P0)
	ORA CONIO_TEMP			; all paper...			(PP)
	STA CONIO_TCOL			; ...at [0]				PP PI IP II
md_std:
	STZ CONIO_MODE		; back to standard mode
	RTS

cn_sety:					; 6= Y to be set, advance mode to 8
	PHA						; eeeeeek [NEW]
	BIT CONIO_SCUR			; if cursor is on... [NEW]
	BPL do_sety
		JSR draw_cur		; ...must delete previous one
do_sety:
	PLA						; [NEW]
	JSR coord_ok			; common coordinate check as is a square screen
; let's play safe...
	LDX #$60                ; was fw_vbot
	CPX #$10				; is base address $1000? (8K system)
	BNE y_noth
		AND #15				; max lines for hires mode in 8K RAM
		BIT VIDEO_MODE		; check mode again
		BPL y_noth
			AND #7			; even further filtering in colour!
y_noth:

    STA CONIO_POSI+1		; *** note temporary use of MSB as Y coordinate ***
	LDX #BM_ATX
	STX CONIO_MODE			; go into X-expecting mode EEEEEEK
	RTS

coord_ok:
; safer, but coordinates must be +32
	CMP #32					; check for not-yet-supported pixel coordinates
		BCC not_px			; must be at least 32, remember stack balance!

    AND #31					; filter coordinates, note +32 offset is deleted as well
	BIT VIDEO_MODE			; if in colour mode, further filtering
	BMI do_set
		AND #15				; max colour coordinate
do_set:
	RTS						; if both coordinates setting is combined, could be inlined

; play safe again
not_px:
; must ignore pixel coordinates, just rounding up to character position
	PLA
	PLA						; discard coordinate checking return address!
	RTS						; that's all, as C known clear

cn_atyx:					; 8= X to be set and return to normal
	JSR coord_ok
	BIT VIDEO_MODE			; if in colour mode, each X is 4 bytes ahead ***
	BMI do_atx
		ASL
		ASL
		ASL CONIO_POSI+1	; THIS IS BAD *** KLUDGE but seems to work (had one extra)
do_atx:
	STA CONIO_POSI			; THIS IS BAD *** KLUDGE but seems to work
	LDA CONIO_POSI+1		; add to recomputed offset the VRAM base address, this was temporarily Y offset
	CLC						; not necessarily clear in hires?
	ADC #$60                ; was fw_vbot
	STA CONIO_POSI+1
	BIT CONIO_SCUR			; if cursor is on... [NEW]
	BPL do_atyx
		JSR draw_cur		; ...must draw new one
do_atyx:
	BRA md_std

; **********************
; *** keyboard input *** may be moved elsewhere
; **********************
; IO9 port (or suitable driver!) is read, normally 0
; any non-zero value is stored and returned the first time, otherwise returns empty (A = 0)
; any repeated characters must have a zero inbetween, 10 ms would suffice (perhaps as low as 5 ms)
cn_in:
	LDA $020A				; ** standard address for generated ASCII code (interrupt-driven) **
	BEQ cn_empty			; no transfer is in the making
cn_chk:
		CMP CONIO_LAST		; otherwise compare with last received
	BEQ cn_ack				; same as last, keep trying
		STA CONIO_LAST		; this is received and different
		RTS 				; send received
cn_empty:
	STA CONIO_LAST			; keep clear
cn_ack:
; *************************************************
; *** optional module for key-by-NESpad control ***
	JSR nes_pad				; check gamepad
; d7-d0 = AtBeULDR format
;	BEQ nes_none			; skip if no buttons
		LSR					; check right
		BCC no_r
			INC CONIO_KBDPAD	; ASCII+1
			JMP nes_upd		; show new character... and return
no_r:
		LSR					; check down
		BCC no_d
			LDA CONIO_KBDPAD
			SEC
			SBC #32			; ASCII-32
			STA CONIO_KBDPAD
			JMP nes_upd		; show new character... and return
no_d:
		LSR					; check left
		BCC no_l
			DEC CONIO_KBDPAD	; ASCII-1
			JMP nes_upd		; show new character... and return
no_l:
		LSR					; check up
		BCC no_u
			LDA CONIO_KBDPAD
			CLC
			ADC #32			; ASCII+32
			STA CONIO_KBDPAD
			JMP nes_upd		; show new character... and return
no_u:
		LSR					; check select (=ESCAPE)
		BCC no_sel
			JSR nes_del		; delete current and wait
			LDY #27			; insert ESC...
			JMP cn_chk		; ...and process as if pressed
no_sel:
		LSR					; check B (=BACKSPACE)
		BCC no_b
			JSR nes_del		; delete current and wait
			LDY #8			; insert BS...
			JMP cn_chk		; ...and process as if pressed
no_b:
		LSR					; check start (=RETURN)
		BCC no_st
			JSR nes_del		; wait, at least
			LDY #13			; insert CR...
			JMP cn_chk		; ...and process as if pressed
no_st:
		LSR					; check A (Confirm character)
		BCC nes_none
			JSR nes_wait	; wait for button up
			LDA #7			; BEL
			JSR cio_cmd
			LDA CONIO_KBDPAD	; get selected keycode
			JMP cn_chk		    ; ...and process as if pressed
; *****************************************
; *** extra routines for KBBYPAD module ***
nes_pad:					; *** read pad value in A ***
	STA GAMEPAD_VALUE1		; latch pad status
	LDX #8					; number of bits to read
nes_loop:
		STA GAMEPAD_VALUE2	; send clock pulse
		DEX
		BNE nes_loop		; all bits read @ GAMEPAD_VALUE1
	LDA GAMEPAD_VALUE1		; get bits
	EOR GAMEPAD_MASK1		; device-independent format!
	RTS

nes_upd:					; *** show current character ***
	LDA CONIO_KBDPAD		; temporary ASCII
	JSR cio_prn				; direct print
	LDA #2					; LEFT cursor
	JSR cio_cmd				; return cursor
	BRA nes_wait			; and wait for button release!

nes_del:					; *** delete temporary char ***
	LDA #' '				; print a space
	JSR cio_prn				; direct print
	LDA #2					; LEFT cursor
	JSR cio_cmd				; return cursor...
nes_wait:
		JSR nes_pad			; ...but wait until button is released
		BNE nes_wait        ; if not take, will arrive to standard CONIO exit
; *** end of routines ***
; ***********************
nes_none:
; *** end of optional KBBYPAD module ***
; **************************************
	LDA #0
    RTS                     ; DurangoLib exit instead of _DR_ERR(EMPTY)

; **************************************************
; *** table of pointers to control char routines ***
; **************************************************
cio_ctl:
	.word	cn_in			; 0, INPUT mode
	.word	cn_cr			; 1, CR
	.word	cur_l			; 2, cursor left
	.word	ignore			; 3 ***
	.word	ignore			; 4 ***
	.word	ignore			; 5 ***
	.word	cur_r			; 6, cursor right
	.word	cio_bel			; 7, beep
	.word	cio_bs			; 8, backspace
	.word	cn_tab			; 9, tab
	.word	cn_lf			; 10, LF
	.word	cio_up			; 11, cursor up
	.word	cio_ff			; 12, FF clears screen and resets modes
	.word	cn_newl			; 13, newline
	.word	cn_so			; 14, inverse
	.word	cn_si			; 15, true video
	.word	md_dle			; 16, DLE, set flag
	.word	cio_cur			; 17, show cursor
	.word	md_ink			; 18, set ink from next char
	.word	cio_curoff		; 19, hide cursor
	.word	md_ppr			; 20, set paper from next char
	.word	cio_home		; 21, home (what is done after CLS)
	.word	ignore			; 22 ***
	.word	md_atyx			; 23, ATYX will set cursor position
	.word	ignore			; 24 ***
	.word	ignore			; 25 ***
	.word	ignore			; 26 ***
	.word	ignore			; 27 ***
	.word	ignore			; 28 ***
	.word	ignore			; 29 ***
	.word	ignore			; 30 ***
	.word	ignore			; 31, IGNORE back to text mode

; *** table of pointers to multi-byte routines *** order must check BM_ definitions!
cio_mbm:
	.word	cn_ink			; 2= ink to be set
	.word	cn_ppr			; 4= paper to be set
	.word	cn_sety			; 6= Y to be set, advance mode to 8
	.word	cn_atyx			; 8= X to be set and return to normal
.endproc

.proc _setFont: near
    ; Font pointer
    STA CONIO_FONT
    STX CONIO_FONT+1
      
    RTS
.endproc


; Print constant string
.proc _printstr: near
    ; Get data pointer from procedure args
    STA RESOURCE_POINTER
    STX RESOURCE_POINTER+1
    
    ; Iterator
    LDY #$00
    loop:
    LDA (RESOURCE_POINTER),Y
    BEQ end
    ; Current char in A
    PHY
    JSR conio
    PLY
    INY
    BNE loop
    end:
    
    RTS
.endproc

.proc _conioInit: near
    STZ CONIO_MODE
    STZ CONIO_MASK
    STZ CONIO_LAST
    LDY #<DEFAULT_FONT  ; *** to be set somewhere ***
    LDX #>DEFAULT_FONT
    STY CONIO_FONT
    STX CONIO_FONT+1
    LDA #$87            ; default colours, yellow on blue
    STA CONIO_TCOL+1    ; set PI index
;   LDA #$80            ; bit 7 high = cursor enabled
    STA CONIO_SCUR
    LDA #12             ; form feed = clear screen and initialise stuff
    JMP conio
;   RTS
.endproc
