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
    pcall(putSpriteOR)

    pcall(fastCopy)
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
    jr nz, -_
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
	ld DE, 0x0020 ;x1

	ld HL, 0x3020 ;x2
	pcall(drawLine)
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
caretIcon:
    .db 0b00000000
    .db 0b00000000
    .db 0b11111000
    .db 0b00000000
