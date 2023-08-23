.zeropage
_controller1_buttons:			.res 3 ; first 2 bytes are controller button state and 3rd byte is connection status
_controller2_buttons:			.res 3 ; first 2 bytes are controller button state and 3rd byte is connection status

.exportzp _controller1_buttons
.exportzp _controller2_buttons

.export _controller_init ; prepend labels with _ so C can see them
.export _controller_read
.export _delay

;
.include "rp6502.inc" 

bit_clock = $01 ; PA0 (GPIO pin 3): CLK   (both controllers)  
bit_latch = $02 ; PA1 (GPIO pin 5): LATCH (both controllers)  
bit_data1 = $04 ; PA2 (GPIO pin 7): DATA  (controller #1)  
bit_data2 = $08 ; PA3 (GPIO pin 79): DATA  (controller #2)  

.code
.proc _controller_init: near
    lda #$FF-bit_data2-bit_data1
    sta VIA_DDRA
    rts
.endproc

.proc _controller_read: near
    lda #00
    sta VIA_PA1

    ; pulse latch
    lda #bit_latch
    sta VIA_PA1
    lda #0
    sta VIA_PA1

    ; read 3x 8 bits
    ldx #0
loop2:
    ldy #8
loop1:
    lda VIA_PA1
    cmp #bit_data2
    rol _controller2_buttons,X
    and #bit_data1
    cmp #bit_data1
    rol _controller1_buttons,X
    lda #bit_clock
    sta VIA_PA1
    lda #0
    sta VIA_PA1
    dey
    bne loop1
    inx
    cpx #3
    bne loop2
    rts
.endproc

.proc _delay: near
    ldx #$FF ;2
    ldy #$FF ;2: 4 total
loop:
    dey ;2
    bne loop ;3, 2
    dex ;2
    bne loop ;3, 2
    rts ;6
.endproc
