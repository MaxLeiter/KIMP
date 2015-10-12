#include "kernel.inc"
#include "corelib.inc"
    .db "KEXC"
    .db KEXC_ENTRY_POINT
    .dw start
    .db KEXC_STACK_SIZE
    .dw 20
    .db KEXC_KERNEL_VER
    .db 0, 6
    .db KEXC_NAME
    .dw name
    .db KEXC_HEADER_END
name:
    .db "KIMP", 0

start:
    pcall(getLcdLock)
    pcall(getKeypadLock)

    pcall(allocScreenBuffer)
    
    kld(de, corelibPath)
    pcall(loadLibrary)
    
redraw:
    kld(hl, windowTitle)
    corelib(drawWindow)
    
    ld de, 0x2015 ; First items location
    kld(hl, newImageStr)
    ld b, 32 ; Amount to push other items
    pcall(drawStr)
    
    kld(hl, loadImageStr)
    pcall(drawStr)
    
    kld(hl, quitStr)
    pcall(drawStr)
    
    pcall(newline)
_:
    kld(hl, (item))
    add hl, hl
    ld b, h
    ld c, l
    add hl, hl
    add hl, bc
    ld de, 0x1915
    add hl, de
    ld e, l
    kld(hl, caretIcon)
    ld b, 3 ;caretIcon height
    pcall(putSpriteOR) ;turn pixels on for caret

    pcall(fastCopy) ;load screen buffer
    pcall(flushKeys)
    corelib(appWaitKey)
    jr nz, -_
    cp kUp
    kcall(z, navUp)
    cp kDown
    kcall(z, navDown)
    cp k2nd
    kcall(z, doSelect)
    cp kEnter
    kcall(z, doSelect)
    cp kMode
    ret z
    jr -_
    ; Credits to SirCmpwn for basically the entire thing so far 
navUp:
    kld(hl, item)
    ld a, (hl)
    or a
    ret z
    dec a
    ld (hl), a
    kld(hl, caretIcon)
    pcall(putSpriteXOR)
    xor a
    ret
#define NB_ITEM 3
navDown:
    kld(hl, item)
    ld a, (hl)
    inc a
    cp NB_ITEM
    ret nc
    ld (hl), a
    kld(hl, caretIcon)
    pcall(putSpriteXOR)
    xor a
    ret
doSelect:
    kld(hl, (item))
    ld h, 0
    kld(de, itemTable)
    add hl, hl
    add hl, de
    ld e, (hl)
    inc hl
    ld d, (hl)
    pcall(getCurrentThreadID)
    pcall(getEntryPoint)
    add hl, de
    pop de \ kld(de, redraw) \ push de
    jp (hl)
    
itemTable:
    .dw newImage, loadImage, exit

newImage: 
    pcall(clearBuffer)
    
    kld(hl, newImageTitle) ;TODO: be able to set this when creating a new image
    xor a
    corelib(drawWindow)
    
    ld de, 0x0208
    ld b, 2

    ; empty screen; lets make the grid
    kcall(draw_table)

.draw: ; currently unused; will be loop function for generating grid
    ld b, 2
    inc d \ inc d \ inc d
    pcall(free)
    _:  pcall(fastCopy)
    pcall(flushKeys)
    corelib(appWaitKey)
    ret
loadImage:
    rst 0x30
    ret
    
exit:
    pop hl
    ret
    
item:
    .db 0

draw_table:
.equ lower_x 0 
.equ lower_y -1 
.equ upper_x 0
.equ upper_y 10
.macro line(x1, y1, x2, y2)
    ld hl, (x1 + upper_x) * 256 + (y1 + upper_y)
    ld de, (x2 + upper_x) * 256 + (y2 + upper_y)
    pcall(drawLine)
.endmacro
	;10x10
    ;horizontal
    line(0, 0, 95, 0)
    line(0, 4, 95, 4)
    line(0, 8, 95, 8)
    line(0, 12, 95, 12)
    line(0, 16, 95, 16)
    line(0, 20, 95, 20)
    line(0, 24, 95, 24)
    line(0, 28, 95, 28)
    line(0, 32, 95, 32)
    line(0, 36, 95, 36)
    line(0, 40, 95, 40)

    ;vertical
    line(24, 40, 24, 1)
    line(28, 40, 28, 1)
    line(32, 40, 32, 1)
    line(28, 40, 28, 1)
    line(32, 40, 32, 1)
    line(36, 40, 36, 1)
    line(40, 40, 40, 1)
    line(44, 40, 44, 1)
    line(48, 40, 48, 1)
    line(52, 40, 52, 1)
    line(56, 40, 56, 1)
    line(60, 40, 60, 1)
    line(64, 40, 64, 1)


     ;TODO loop this; vertical
	;ld DE, 0x0000 x1,y1
	;ld HL, 0x0010 x2,y2
	;pcall(drawLine)
	;figure out how to make a for loop to draw table
    ret


corelibPath:
    .db "/lib/core", 0
windowTitle:
    .db "KIMP: Welcome", 0
newImageTitle:
	.db "KIMP: New Image", 0
newImageStr:
    .db "New Image\n", 0
loadImageStr:
    .db "Load Image\n", 0
backStr:
    .db "Back", 0
quitStr:
	.db "Exit", 0
size: ;Image size, will need to be configurable with new image screen at some point
	.db 20
caretIcon: ;Just a line atm, maybe go back to the 'default' cursor?
    .db 0b00000000
    .db 0b00000000
    .db 0b11111000
    .db 0b00000000
currrent:
	.db 0
	.db 1