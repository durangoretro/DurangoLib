; CONIO module for DurangoLib, CMOS 65C02 version
; based on Durango-X firmware console 0.9.6b8 for minimOS
; 16-colour 16x16 text  _or_ b&w 32x32 text
; (c) 2021-2022 Carlos J. Santisteban
; last modified 20220913-2247

; ****************************************
; CONIO, simple console driver in firmware
; ****************************************
; template with temporary IO9 input support (no handshake!)
;	INPUT
; Y <-	char to be printed (1...255) => goes thru A in CC65
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
;		12	= clear screen
;		13	= newline (actually LF after CR, eg. set Y to anything but 1 so DEY clears Z and does LF)
;		14	= inverse video
;		15	= true video
;		16	= DLE, do not execute next control char
;		17	= cursor on
;		18	= set ink colour (MOD 16 for colour mode, hires will set it as well but will be ignored)*
;		19	= cursor off
;		20	= set paper colour (ditto)*
;		21	= home without clear
;		23	= set cursor position**
;		31	= back to text mode (simply IGNORED)
; commands marked * will take a second char as parameter
; command marked ** takes two subsequent bytes as parameters
; *** NOT YET supported (will show glyph like after DLE) ***
;		3	= TERM (?)
;		4	= end of screen
;		5	= end of line
;		22	= page down (?)
;		24	= backtab
;		25	= page up (?)
;		26	= switch focus (?)
;		27	= escape (?)
;		28...30	= Tektronix graphic commands
;	OUTPUT
; C ->	no available char (if Y was 0)
; Y -> input char (if Y was 0) => goes thru A in CC65

; *** zeropage variables *** reusing some DurangoLib
; cio_src.w (pointer to glyph definitions)
; cio_pt.w (screen pointer)

; *** other variables, perhaps in ZP ***
; _conio_cbyt (temporary glyph storage)
; _conio_chalf (remaining pages to write)

; *** firmware variables to be reset PRIOT TO FIRST USE ***
; _conio_cbin (binary or multibyte mode) *** MUST BE DONE BEFORE FIRST USE
; _conio_vbot (new, first VRAM page, allows screen switching upon FF) *** and MUST be set thru call upon framebuffer switching!
; _conio_vtop (new, first non-VRAM page, allows screen switching upon FF) *** and MUST be set thru call upon framebuffer switching!
; _conio_fnt.w (new, pointer to relocatable 2KB font file) *** should it be restored upon FF?
; _conio_mask (for inverse/emphasis mode) *** should it be restored upon FF?
; _conio_scur (cursor mode) *** should it be restored?

; *** firmware variables to be reset upon FF ***
; _conio_ccol.p (array 00.01.10.11 of two-pixel combos, will store ink & paper)
; * NEW* FF will reconstruct it from [1] (PAPER-INK)
; _conio_ciop.w (upper scan of cursor position)
; _conio_fnt.w (new, pointer to relocatable 2KB font file) *** should it be restored?
; _conio_mask (for inverse/emphasis mode) *** should it be restored?
; _conio_scur (cursor mode) *** should it be restored?

; *** new option, keyboard control by NES gamepad ***
; *** UP/DOWN    = +/- 32 to ASCII                ***
; *** LEFT/RIGHT = next/prev ASCII                ***
; *** A          = put char into buffer           ***
; *** B          = press BACKSPACE                ***
; *** START      = press RETURN                   ***
; *** SELECT     = press ESCAPE                   ***

.import cio_fnt
.importzp _screen_pointer
.importzp _data_pointer

.export _conio
.export _conio_ccol
.export _conio_cbin

.ZEROPAGE
; *** ZP from lib ***
cio_src	= _data_pointer		; (pointer to glyph definitions)
cio_pt	= _screen_pointer	; (screen pointer)


.BSS
; *** non-ZP memory usage, new on lib ***
; specific CONIO variables
_conio_cbin:	.byt	0				; integrated picoVDU/Durango-X specifics *** MUST be reset before first FF
_conio_fnt:		.word	0				; pointer to relocatable 2KB font file (inited by FF?)
_conio_mask:	.byt	0				; for inverse/emphasis mode
_conio_chalf:	.byt	0				; remaining pages to write
_conio_sind:	.res	3, $00
_conio_ccol:	.res	4, $00			; array of two-pixel combos, will store ink & paper, standard PPPPIIII at [1] (reconstructed by FF from [1])
_conio_ctmp:
_conio_cbyt:	.byt	0				; temporary glyph storage
_conio_io9:		.byt	0				; received keypress

.DATA
_conio_ciop:	.word	$6000			; cursor position (inited by FF)
_conio_vbot:	.byt	$60				; page start of screen at current hardware setting (updated upon FF)
_conio_vtop:	.byt	$80				; first non-VRAM page (updated upon FF)
_conio_scur:	.byt	$00				; cursor mode (bit 7 = ON)

.CODE

.proc _conio: near
; *******************
; *** definitions ***
; *******************
; *** Durango addresses ***
IO8attr	= $DF80				; compatible IO8lh for setting attributes (d7=HIRES, d6=INVERSE, now d5-d4 include screen block)
IO8blk	= $DF88				; video blanking signals
IO9di	= $DF9A				; data input (TBD)
IO9nes0	= $DF9C				; gamepad interface addresses
IO9nes1	= $DF9D
IOBeep	= $DFBF				; canonical buzzer address (d0)

; *** code constants ***
; first two modes are directly processed, note BM_DLE is the shifted X
BM_CMD	= 0
BM_DLE	= 32
; these modes are handled by indexed jump, note offset of 2
BM_INK	= 2
BM_PPR	= 4
BM_ATY	= 6
BM_ATX	= 8

; ******************
; *** CONIO code ***
; ******************
	.PSC02					; Enable 65C02 instructions set
;	TYA						; is going to be needed here anyway
	LDX _conio_cbin			; check whether in binary/multibyte mode
	BEQ cio_cmd				; if not, check whether command (including INPUT) or glyph
		CPX #BM_DLE			; just receiving what has to be printed?
			BEQ cio_gl		; print the glyph!
		JMP (cio_mbm-2, X)	; otherwise process following byte as expected, note offset *CMOS
cio_cmd:
	CMP #32					; printable anyway?
	BCS cio_prn				; go for it, flag known to be clear
		ASL					; if arrived here, it MUST be below 32! two times
		TAX					; use as index
		CLC					; will simplify most returns as DR_OK becomes just RTS
		JMP (cio_ctl, X)	; execute from table *CMOS
cio_gl:
	STZ _conio_cbin			; clear flag! *CMOS
cio_prn:
; ***********************************
; *** output character (now in A) ***
; ***********************************
	ASL						; times eight scanlines
	ROL cio_src+1			; M=???????7, A=6543210·
	ASL
	ROL cio_src+1			; M=??????76, A=543210··
	ASL
	ROL cio_src+1			; M=?????765, A=43210···
	CLC
	ADC _conio_fnt			; add font base
	STA cio_src
	LDA cio_src+1			; A=?????765
	AND #7					; A=·····765
	ADC _conio_fnt+1		; in case no glyphs for control codes, this must hold actual MSB-1
	STA cio_src+1			; pointer to glyph is ready
	LDY _conio_ciop			; get current address
	LDA _conio_ciop+1
	STY cio_pt				; set pointer
	STA cio_pt+1
	LDY #0					; reset screen offset (common)
; *** now check for mode and jump to specific code ***
	BIT IO8attr				; check mode, code is different, will only check d7
	BPL cpc_col				; skip to colour mode, hires is smaller
; hires version (17b for CMOS, usually 231t, plus jump to cursor-right)
cph_loop:
			LDA (cio_src)	; glyph pattern (5) *CMOS
			EOR _conio_mask	; eeeeeeeeeek (4)
			STA (cio_pt), Y	; put it on screen (5)
			INC cio_src		; advance to next glyph byte (5)
			BNE cph_nw		; (usually 3, rarely 7)
				INC cio_src+1
cph_nw:
			TYA				; advance to next screen raster (2+2)
			CLC
			ADC #32			; 32 bytes/raster EEEEEEEEK (2)
			TAY				; offset ready (2)
			BNE cph_loop	; offset will just wrap at the end EEEEEEEK (3)
		BEQ cur_r			; advance to next position! no need for BRA (3)
; colour version, 85b, typically 975t (77b, 924t in ZP)
; new FAST version, but no longer with sparse array
cpc_col:
	LDX #2
	STX _conio_chalf		; two pages must be written (2+4*)
cpc_do:						; outside loop (done 8 times) is 8x(45+inner)+113=969, 8x(42+inner)+111=919 in ZP  (was ~1497/1407)
		LDA (cio_src)		; glyph pattern (5) *CMOS
		EOR _conio_mask		; in case inverse mode is set, much better here (4)
; *** *** glyph pattern is loaded and masked, let's try an even faster alternative, store all 4 positions premasked as sparse indexes
		TAX					; keep safe (2)
		AND #%00000011		; rightmost pixels (2)
		STA _conio_sind		; fourth and last sparse index (4*, note inverted order)
		TXA					; quickly get the rest (2)
		AND #%00001100		; pixels 4-5 (2)
		LSR
		LSR			; no longer sparse (2+2)
		STA _conio_sind+1	; third sparse index (4*)
		TXA
		AND #%00110000		; pixels 2-3 (2+2)
		LSR
		LSR
		LSR
		LSR			; no longer sparse, C is clear (2+2+2+2)
		STA _conio_sind+2	; second sparse index (4*)
		TXA
		AND #%11000000		; two leftmost pixels (will be processed first) (2+2)
		ROL
		ROL
		ROL		; no longer sparse, faster this way and ready to use as index (2+2+2)
		INC cio_src			; advance to next glyph byte (5+usually 3)
		BNE cpc_loop
			INC cio_src+1
cpc_loop:					; (all loop was 122/115t, now unrolled is 62/59t)
			TAX				; A was sparse index (2)
			LDA _conio_ccol, X	; get proper colour pair (4)
			STA (cio_pt), Y	; put it on screen (6 eeek)
			INY				; next screen byte for this glyph byte (2)
; here comes the time critical part, let's try to unroll
			LDX _conio_sind+2	; get next sparse index (4*)
			LDA _conio_ccol, X	; get proper colour pair (4)
			STA (cio_pt), Y	; put it on screen (6 eeek)
			INY				; next screen byte for this glyph byte (2)
			LDX _conio_sind+1	; get next sparse index (4*)
			LDA _conio_ccol, X	; get proper colour pair (4)
			STA (cio_pt), Y	; put it on screen (6 eeek)
			INY				; next screen byte for this glyph byte (2)
			LDX _conio_sind		; get next sparse index (4*)
			LDA _conio_ccol, X	; get proper colour pair (4)
			STA (cio_pt), Y	; put it on screen (6 eeek)
			INY				; next screen byte for this glyph byte (2)
; ...etc
cpc_rend:					; end segment has not changed, takes 6x11 + 2x24 - 1, 113t (66+46-1=111t in ZP)
		TYA					; advance to next screen raster, but take into account the 4-byte offset (2+2+2)
		CLC
		ADC #60
		TAY					; offset ready (2)
		BNE cpc_do			; unfortunately will wrap twice! (mostly 3)
			INC cio_pt+1	; next page for the last 4 raster (5)
			DEC _conio_chalf	; only one half done? go for next and last (*6+3)
		BNE cpc_do
; advance screen pointer before exit, no need for jump if cursor-right is just here!

; **********************
; *** cursor advance *** placed here for convenience of printing routine
; **********************
cur_r:
	BIT _conio_scur			; if cursor is on... [NEW]
	BPL do_cur_r
		JSR draw_cur		; ...must delete previous one
do_cur_r:
	LDA #1					; base character width (in bytes) for hires mode
	BIT IO8attr				; check mode
	BMI rcu_hr				; already OK if hires
		LDA #4				; ...or use value for colour mode
rcu_hr:
	CLC
	ADC _conio_ciop			; advance pointer
	STA _conio_ciop			; EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEK
	BCC rcu_nw				; check possible carry
		INC _conio_ciop+1
rcu_nw:						; will return, no need for jump if routine is placed below

; ************************
; *** support routines ***
; ************************
ck_wrap:
; check for line wrap
; address format is 011yyyys-ssxxxxpp (colour), 011yyyyy-sssxxxxx (hires)
; thus appropriate masks are %11100000 for hires and %11000000 in colour... but it's safer to check MSB's d0 too!
	LDY #%11100000			; hires mask
	BIT IO8attr				; check mode
	BMI wr_hr				; OK if we're in hires
; * SAFE option *
		LDA _conio_ciop+1	; check MSB
		LSR					; just check d0, should clear C
			BCS cn_begin	; strange scanline, thus time for the NEWLINE (Y>1)
; * *
		LDY #%11000000		; in any case, get proper mask for colour mode
wr_hr:
	TYA						; prepare mask and guarantee Y>1 for auto LF
	AND _conio_ciop			; are scanline bits clear?
		BNE do_cr			; nope, do NEWLINE
	BIT _conio_scur			; if cursor is on... [NEW]
	BPL do_ckw
		JSR draw_cur		; ...must draw new one
do_ckw:
	RTS					; continue normally otherwise (better clear C)

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
	BIT _conio_scur				; if cursor is on... [NEW]
	BPL do_cur_l
		JSR draw_cur		; ...must delete previous one
do_cur_l:
	LDA #1					; hires decrement (these 9 bytes are the same as cur_r)
	BIT IO8attr
	BMI cl_hr				; right mode for the decrement EEEEEK
		LDA #4				; otherwise use colour value
cl_hr:
	STA cio_src				; EEEEEEEEEEEK
	SEC
	LDA _conio_ciop
	SBC cio_src				; subtract to pointer, but...
	BMI cl_end				; ...ignore operation if went negative
		STA _conio_ciop		; update pointer
cl_end:
	BIT _conio_scur			; if cursor is on... [NEW]
	BPL do_cle
		JSR draw_cur		; ...must draw new one
do_cle:
	RTS					; C known to be set, though

cn_newl:
; CR, but will do LF afterwards by setting Y appropriately
		TAY					; Y=26>1, thus allows full newline
cn_begin:
; do CR... but keep Y
	BIT _conio_scur			; if cursor is on... [NEW]
	BPL do_cr
		PHY					; CMOS only eeeeeek
		JSR draw_cur		; ...must delete previous one
		PLY
do_cr:
; note address format is 011yyyys-ssxxxxpp (colour), 011yyyyy-sssxxxxx (hires)
; actually is a good idea to clear scanline bits, just in case
	STZ _conio_ciop			; all must clear! helps in case of tab wrapping too (eeeeeeeeek...) *CMOS
; in colour mode, the highest scanline bit is in MSB, usually (TABs, wrap) not worth clearing
; ...but might help with unexpected mode change
; * SAFE option
	BIT IO8attr			; was it in hires mode?
	BMI cn_lmok
; NMOS version
;		LDA _conio_ciop+1	; clear MSB lowest bit (8b/10t)
;		AND #254
;		STA _conio_ciop+1
		LDA #1				; bit to be cleared (5b/7t)
		TRB _conio_ciop+1		; nice...
cn_lmok:
; * *
; check whether LF is to be done
	DEY						; LF needed?
	BEQ cn_ok				; not if Y was 1 (use BMI if Y was zeroed for LF)
; *** will do LF if Y was >1 ONLY ***
cn_lf:
; do LF, adds 1 (hires) or 2 (colour) to MSB
; even simpler, INCrement MSB once... or two if in colour mode
; hopefully highest scan bit is intact!!!
	BIT _conio_scur			; if cursor is on... [NEW]
	BPL do_lf
		JSR draw_cur		; ...must delete previous one
do_lf:
	INC _conio_ciop+1		; increment MSB accordingly, this is OK for hires
	BIT IO8attr				; was it in hires mode?
	BMI cn_hmok
		INC _conio_ciop+1	; once again if in colour mode... 
cn_hmok:
; must check for possible scrolling!!! simply check sign ;-) ...or compare against dynamic limit
	LDA _conio_ciop+1		; EEEEEK
	CMP _conio_vtop
	BNE cn_ok				; below limit means no scroll
; ** scroll routine **
; rows are 256 bytes apart in hires mode, but 512 in colour mode
	LDY #$00				; LSB *must* be zero, anyway
; MSB is actually OK for destination, but take from current value
	LDX _conio_vbot
	STY cio_pt				; set both LSBs
	STY cio_src
	STX cio_pt+1			; destination is set
	INX						; note trick for NMOS-savvyness
	BIT IO8attr				; check mode anyway
	BMI sc_hr				; +256 is OK for hires
		INX					; make it +512 for colour
sc_hr:
	STX cio_src+1			; we're set, worth keep incrementing this
;	LDY #0					; in case pvdu is not page-aligned!
sc_loop:
		LDA (cio_src), Y	; move screen data ASAP
		STA (cio_pt), Y
		INY					; do a whole page
		BNE sc_loop
	INC cio_pt+1			; both MSBs are incremented at once...
	INX
	STX cio_src+1			; ...but only source will enter high-32K at the end
	CPX _conio_vtop			; ...or whatever the current limit is
		BNE sc_loop

; data has been transferred, now should clear the last line
	JSR cio_clear			; cannot be inlined! Y is 0
; important, cursor pointer must get back one row up! that means subtracting one (or two) from MSB
	LDA IO8attr				; eeeeeek
	ASL						; now C is set for hires
	LDA _conio_ciop+1		; cursor MSB
	SBC #1					; with C set (hires) this subtracts 1, but 2 if C is clear! (colour)
	STA _conio_ciop+1
cn_ok:
	BIT _conio_scur			; if cursor is on... [NEW]
	BPL do_cnok
		JSR draw_cur		; ...must draw new one
do_cnok:
	RTS					; note that some code might set C

cn_tab:
; advance column to the next 8x position (all modes)
; this means adding 8 to LSB in hires mode, or 32 in colour mode
; remember format is 011yyyys-ssxxxxpp (colour), 011yyyyy-sssxxxxx (hires)
	BIT _conio_scur			; if cursor is on... [NEW]
	BPL do_tab
		JSR draw_cur		; ...must delete previous one
do_tab:
	LDA #%11111000			; hires mask first
	STA _conio_ctmp			; store temporarily
	LDA #8					; lesser value in hires mode
	BIT IO8attr				; check mode
	BMI hr_tab				; if in hires, A is already correct
		ASL _conio_ctmp
		ASL _conio_ctmp		; shift mask too, will set C
		ASL
		ASL					; but this will clear C in any case
hr_tab:
	ADC _conio_ciop			; this is LSB, contains old X...
	AND _conio_ctmp			; ...but round down position from the mask!
	STA _conio_ciop
; not so fast, must check for possible line wrap... and even scrolling!
	JMP ck_wrap				; will return in any case

cio_bel:
; BEL, make a beep!
; 40ms @ 1 kHz is 40 cycles
; the 500µs halfperiod is about 325t
	PHP
	SEI						; let's make things the right way
	LDX #79					; 80 half-cycles, will end with d0 clear
cbp_pul:
		STX IOBeep			; pulse output bit (4)
		LDY #63				; should make around 500µs halfcycle (2)
cbp_del:
			DEY
			BNE cbp_del		; each iteration is (2+3)
		DEX					; go for next semicycle
		BPL cbp_pul			; must do zero too, to clear output bit
	PLP						; eeeeek
	RTS

cio_bs:
; BACKSPACE, go back one char and clear cursor position
	JSR cur_l				; back one char, if possible, then clear cursor position
	BIT _conio_scur			; if cursor is on... [NEW]
	BPL do_bs
		JSR draw_cur		; ...must delete previous one
do_bs:
	LDY _conio_ciop
	LDA _conio_ciop+1		; get current cursor position...
	STY cio_pt
	STA cio_pt+1			; ...into zp pointer
	LDX #8					; number of scanlines...
	STX _conio_ctmp			; ...as temporary variable (seldom used)
; load appropriate A value (clear for hires, paper index repeated for colour)
	LDX #0					; last index offset should be 0 for hires!
	TXA						; hires takes no account of paper colour
	LDY #31					; this is what must be added to Y each scanline, in hires
	BIT IO8attr				; check mode
	BMI bs_hr
		LDA _conio_ccol		; this is two pixels of paper colour
		LDX #3				; last index offset per scan (colour)
		LDY #60				; this is what must be added to Y each scanline, in colour
bs_hr:
	STX cio_src				; another temporary variable
	STY cio_src+1			; this is most used, thus must reside in ZP
	LDY #0					; eeeeeeeeek *** must be revised for picoVDU
bs_scan:
			STA (cio_pt), Y	; clear screen byte
			INY				; advance, just in case
			DEX				; one less in a row
			BPL bs_scan
		LDX cio_src			; reload this counter
		PHA					; save screen value!
		TYA
		CLC
		ADC cio_src+1		; advance offset to next scanline
		TAY
		BCC bs_scw
			INC cio_pt+1	; colour mode will cross page
bs_scw:
		PLA					; retrieved value, is there a better way?
		DEC _conio_ctmp		; one scanline less to go
		BNE bs_scan
	BIT _conio_scur			; if cursor is on... [NEW]
	BPL end_bs
		JSR draw_cur		; ...must delete previous one
end_bs:
	RTS						; should be done

cio_up:
; cursor up, no big deal, will stop at top row (NMOS savvy, always 23b and 39t)
	BIT _conio_scur			; if cursor is on... [NEW]
	BPL do_cup
		JSR draw_cur		; ...must delete previous one
do_cup:
	LDA IO8attr				; check mode
	ROL						; now C is set in hires!
	PHP						; keep for later?
	LDA #%00001111			; incomplete mask, just for the offset, independent of screen-block
	ROL						; but now is perfect! C is clear
	PLP						; hires mode will set C again but do it always! eeeeeeeeeeek
	AND _conio_ciop+1		; current row is now 000rrrrR, R for hires only
	BEQ cu_end				; if at top of screen, ignore cursor
		SBC #1				; this will subtract 1 if C is set, and 2 if clear! YEAH!!!
;		AND #%00011111		; may be safer with alternative screens
		ORA _conio_vbot		; EEEEEEK must complete pointer address (5b, 6t)
		STA _conio_ciop+1
cu_end:
	BIT _conio_scur			; if cursor is on... [NEW]
	BPL do_cu_end
		JSR draw_cur		; ...must draw new one
do_cu_end:
	RTS						; ending this with C set is a minor nitpick, must reset anyway

; FF, clear screen AND intialise values!
cio_ff:
; note that firmware must set IO8attr hardware register appropriately at boot!
; we don't want a single CLS to switch modes, although a font reset is acceptable, set it again afterwards if needed
; * things to be initialised... *
; _conio_ccol, note it's an array now (restore from PAPER-INK previous setting)
; _conio_fnt (new, pointer to relocatable 2KB font file)
; _conio_mask (for inverse/emphasis mode)
; _conio_cbin (binary or multibyte mode, but must be reset BEFORE first FF)

	STZ _conio_mask			; true video *CMOS
;	STZ _conio_cbin			; standard character mode *** not much sense anyway
	JSR rs_col				; restore array from whatever is at _conio_ccol[1] (will restore _conio_cbin)
	LDY #<cio_fnt			; supplied font address
	LDA #>cio_fnt
	STY _conio_fnt			; set firmware pointer (will need that again after FF)
	STA _conio_fnt+1
; standard CLS, reset cursor and clear screen
	JSR cio_home			; reset cursor and load appropriate address in A/Y
	JSR cio_swsc			; recompute screen address for framebuffer [NEW]
	STY cio_pt				; set pointer (LSB=0)...
	STA cio_pt+1
;	LDY #0					; usually not needed as screen is page-aligned! ...and clear whole screen, will return to caller
cio_clear:
; ** generic screen clear-to-end routine, just set cio_pt with initial address and Y to zero **
; this works because all character rows are page-aligned
; otherwise would be best keeping pointer LSB @ 0 and setting initial offset in Y, plus LDA #0
; anyway, it is intended to clear whole rows
	TYA						; A should be zero in hires, and Y is known to have that
	BIT IO8attr
	BMI sc_clr				; eeeeeeeeek
		LDA _conio_ccol		; EEEEEEEEK, this gets paper colour byte
sc_clr:
		STA (cio_pt), Y		; clear all remaining bytes
		INY
		BNE sc_clr
	INC cio_pt+1			; next page
	LDX cio_pt+1			; but must check variable limits!
	CPX _conio_vtop
		BNE sc_clr
	BIT _conio_scur			; if cursor is on... [NEW]
	BPL do_ff
		JSR draw_cur		; ...must draw new one, as the one from home was cleared
do_ff:
	RTS

; SO, set inverse mode
cn_so:
	LDA #$FF				; OK for all modes?
	STA _conio_mask			; set value to be EORed
	RTS

; SI, set normal mode
cn_si:
	STZ _conio_mask			; clear value to be EORed *CMOS
	RTS

md_dle:
; DLE, set binary mode
;	LDX #BM_DLE				; X already set if 32
	STX _conio_cbin			; set binary mode and we are done
ignore:
	RTS						; *** note generic exit ***

cio_cur:
; XON, we now have cursor! [NEW]
	LDA #128				; flag for cursor on
	TSB _conio_scur			; check previous flag (and set it now) *** CMOS only ***
	BNE ignore				; if was set, shouldn't draw cursor again
		JMP draw_cur		; go and return

cio_curoff:
; XOFF, disable cursor [NEW]
	LDA #128				; flag for cursor on
	TRB _conio_scur			; check previous flag (and clear it now)
	BNE ignore				; if was set, shouldn't draw cursor again
		JMP draw_cur		; go and return

md_ink:
; just set binary mode for receiving ink! *** could use some tricks to unify with paper mode setting
	LDX #BM_INK				; next byte will set ink
	STX _conio_cbin			; set multibyte mode and we are done
	RTS

md_ppr:
; just set binary mode for receiving paper! *** check above for simpler alternative
	LDX #BM_PPR				; next byte will set ink
	STX _conio_cbin			; set multibyte mode and we are done
	RTS

cio_home:
; just reset cursor pointer, to be done after (or before!) CLS
	BIT _conio_scur			; if cursor is on... [NEW]
	BPL do_home
		JSR draw_cur		; ...must draw new one
do_home:
	LDY #$00				; base address for all modes, actually 0
	LDA _conio_vbot			; current screen setting!
	STY _conio_ciop			; just set pointer
	STA _conio_ciop+1
	RTS						; C is clear, right?

md_atyx:
; prepare for setting y first
	LDX #BM_ATY				; next byte will set Y and then expect X for the next one
	STX _conio_cbin			; set new mode, called routine will set back to normal
	RTS

draw_cur:
; draw (XOR) cursor [NEW]
	LDX _conio_ciop+1		; get cursor position
	CPX _conio_vtop			; outside bounds?
		BCS no_cur			; do not attempt to write!
	LDY _conio_ciop
	STY cio_pt				; set pointer LSB (common)
	STX cio_pt+1			; set pointer MSB
	BIT IO8attr				; check screen mode
	BPL dc_col				; skip if in colour mode
		LDY #224			; seven rasters down
		LDX #1				; single byte cursor
		BNE dc_loop			; no need for BRA
dc_col:
	INC cio_pt+1			; this goes into next page (4 rasters down)
	LDY #192				; 3 rasters further down
	LDX #4					; bytes per char raster
dc_loop:
		LDA (cio_pt), Y		; get screen data...
		EOR #$FF			; ...invert it...
		STA (cio_pt), Y		; ...and update it
		INY					; next byte in raster
		DEX
		BNE dc_loop
no_cur:
	RTS						; should I clear C?

cio_swsc:
; recompute MSB in A according to hardware [NEW, to be called upon framebuffer switch!]
; must respect Y and modify A accordingly
	LDA IO8attr				; *** direct calls omit this ***
	AND #%00110000
;switch_sc:
	ASL
	TAX						; keep bottom of VRAM
	ADC #$20				; C was clear b/c ASL
	STA _conio_vtop			; eeeeek
	TXA
; * SAFE option *
	BNE ff_ok
		LDA #%00010000		; base address for 8K systems is 4K
ff_ok:
; * *
	STA _conio_vbot			; store new variable
	LDA _conio_ciop+1
	AND #%00011111			; keep high address of cursor position
	ORA _conio_vbot			; ...but into new framebuffer
	STA _conio_ciop+1		; must correct this one too *** maybe for regular use just be previously reset
	RTS

; *******************************
; *** some multibyte routines ***
; *******************************
; set INK, 19b + common 55b, old version was 44b
cn_ink:
	AND #15					; 2= ink to be set
	STA _conio_cbyt			; temporary INK storage			(0I)
	LDA _conio_ccol+1		; get combined storage
	AND #$F0				; only old PAPER at high nibble	(p0)
	ORA _conio_cbyt			; combine result				(pI)
	STA _conio_ccol+1
	JMP set_col				; and complete array

; set PAPER, 18b + common 55b, old version was 42b
cn_ppr:						; 4= paper to be set
;	AND #15					; shifting will delete MSN
	ASL
	ASL
	ASL
	ASL						; PAPER in high nibble			(P0)
	STA _conio_cbyt			; temporary storage
	LDA _conio_ccol+1		; previous combined storage
	AND #$0F				; only old INK at low nibble	(0i)
	ORA _conio_cbyt			; combine result with PAPER...	(Pi)
	STA _conio_ccol+1		; ...and fall to complete the array
;	JMP set_col
; reconstruct array from PAPER-INK index
; * surely can be shrinked by use of lost _conio_ccnt, but who cares...
rs_col:						; restore colour aray from [1] (PAPER-INK)
	LDA _conio_ccol+1		; get all				xx PI xx xx
set_col:
	AND #$0F				; ink only
	STA _conio_cbyt			; temporary ink storage	(0I)
	ASL
	ASL
	ASL
	ASL						; ink in high nibble	(I0)
	ORA _conio_cbyt			; all ink...			(II)
	STA _conio_ccol+3		; ... at [3]			xx PI xx II
	AND #$F0				; high nibble only...	(I0)
	STA _conio_cbyt			; ...temporary
	LDA _conio_ccol+1		; both colours again	(PI)
	LSR
	LSR
	LSR
	LSR						; PAPER at low nibble	(0P)
	ORA _conio_cbyt			; this is INK-PAPER...	(IP)
	STA _conio_ccol+2		; ...at [2]				xx PI IP II
	AND #$0F				; paper only			(0P)
	STA _conio_cbyt
	ASL
	ASL
	ASL
	ASL						; at high nibble		(P0)
	ORA _conio_cbyt			; all paper...			(PP)
	STA _conio_ccol			; ...at [0]				PP PI IP II
md_std:
	STZ _conio_cbin			; back to standard mode *CMOS
	RTS

cn_sety:					; 6= Y to be set, advance mode to 8
	JSR coord_ok			; common coordinate check as is a square screen
; * SAFE option *
	LDX _conio_vbot
	CPX #$10				; is base address $1000? (8K system)
	BNE y_noth
		AND #15				; max lines for hires mode in 8K RAM
		BIT IO8attr			; check mode again
		BPL y_noth
			AND #7			; even further filtering in colour!
y_noth:
; * *
	STA _conio_ciop+1		; *** note temporary use of MSB as Y coordinate ***
	LDX #BM_ATX
	STX _conio_cbin			; go into X-expecting mode EEEEEEK
	RTS

coord_ok:
; * SAFE option *
	CMP #32					; check for not-yet-supported pixel coordinates
		BCC not_px			; must be at least 32, remember stack balance!
; * *
	AND #31					; filter coordinates, note +32 offset is deleted as well
	BIT IO8attr				; if in colour mode, further filtering
	BMI do_set
		AND #15				; max colour coordinate
do_set:
	RTS						; if both coordinates setting is combined, could be inlined

; * SAFE option *
not_px:
; must ignore pixel coordinates, just rounding up to character position
	PLA
	PLA						; discard coordinate checking return address!
	RTS						; that's all, as C known clear
; * *

cn_atyx:					; 8= X to be set and return to normal
	JSR coord_ok
	BIT IO8attr				; if in colour mode, each X is 4 bytes ahead ***
	BMI do_atx
		ASL
		ASL
		ASL _conio_ciop+1	; THIS IS BAD *** KLUDGE but seems to work (had one extra)
do_atx:
	STA _conio_ciop			; THIS IS BAD *** KLUDGE but seems to work
	LDA _conio_ciop+1		; add to recomputed offset the VRAM base address, this was temporarily Y offset
	CLC						; not necessarily clear in hires?
	ADC _conio_vbot
	STA _conio_ciop+1
	BRA md_std				; *CMOS

; **********************
; **********************
; *** keyboard input *** TEMPORARY for PASK interface at $DF9A
; **********************
; **********************
; IO9 port is read, normally 0
; any non-zero value is stored and returned the first time, otherwise returns 0 (EMPTY)
; any repeated characters must have a zero inbetween, 10 ms would suffice (perhaps as low as 5 ms)
cn_in:
	LDA IO9di				; get current data at port *** must set lower address nibble
; *** should this properly address a matrix keyboard?
	BEQ cn_empty			; no transfer is in the making
cn_chk:
	CMP _conio_io9		; otherwise compare with last received
	BEQ cn_ack				; same as last, keep trying
		STA _conio_io9		; this is received and different
		RTS				; send received
cn_empty:
	STA _conio_io9			; keep clear
cn_ack:
; *************************************************
; *** optional module for key-by-NESpad control ***
	JSR nes_pad				; check gamepad
; d7-d0 = AtBeULDR format
		LSR					; check right
		BCC no_r
			INC fw_knes		; ASCII+1
			JMP nes_upd		; show new character... and return
no_r:
		LSR					; check down
		BCC no_d
			LDA fw_knes
			SEC
			SBC #32			; ASCII-32
			STA fw_knes
			JMP nes_upd		; show new character... and return
no_d:
		LSR					; check left
		BCC no_l
			DEC fw_knes		; ASCII-1
			JMP nes_upd		; show new character... and return
no_l:
		LSR					; check up
		BCC no_u
			LDA fw_knes
			CLC
			ADC #32			; ASCII+32
			STA fw_knes
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
			LDY fw_knes		; get selected keycode
			JMP cn_chk		; ...and process as if pressed
; *** extra routines for KBBYPAD module ***
nes_pad:					; *** read pad value in A ***
	STA IO9nes0				; latch pad status
	LDX #8					; number of bits to read
nes_loop:
		STA IO9nes1			; send clock pulse
		DEX
		BNE nes_loop		; all bits read @ IO9nes0
	LDA IO9nes0				; get bits
	EOR #$FF				; *** *** temporary fix for new negative logic *** ***
	RTS

nes_upd:					; *** show current character ***
	LDA fw_knes				; temporary ASCII
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
		BNE nes_wait
;	BEQ nes_none			; standard exit, just in case
; *** end of routines ***
nes_none:
; *** end of optional KBBYPAD module ***
; **************************************
	LDA #0				; EMPTY value
	RTS					; *** must indicate error somehow ***

; **************************************************

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
