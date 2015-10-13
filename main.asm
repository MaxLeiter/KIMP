; KIMP: a KnightOS Image Editor
; Basically a frankenstein of KnightOS projects,
; thanks whoever made them (SirCmpwn, Willem3141, etc)

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
    kcall(newImage)
    cp kF3
    jr z, .main_menu

.main_menu:
	kld(hl, menu); menu descriptors
    ld c, 40 ;width in pixels of menu
    corelib(showMenu)
    kld(hl, menu_functions)
    add a, l \ ld l, a \ jr nc, $+3 \ inc h
    ld e, (hl) \ inc hl \ ld d, (hl)
    ex de, hl
    push hl
        pcall(getCurrentThreadId)
        pcall(getEntryPoint)
    pop bc
    add hl, bc
    kld((.menu_smc + 1), hl)
.menu_smc:
    jp 0
newImage: 
    pcall(clearBuffer)
    
    kld(hl, newImageTitle) ;TODO: be able to set this when creating a new image
    ld a, 0b00000100
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

loadImage: ;TODO: make this work
    rst 0x30
    ret

exit:
    pop hl
    ret

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
    line(24, 0, 64, 0)
    line(24, 4, 64, 4)
    line(24, 8, 64, 8)
    line(24, 12, 64, 12)
    line(24, 16, 64, 16)
    line(24, 20, 64, 20)
    line(24, 24, 64, 24)
    line(24, 28, 64, 28)
    line(24, 32, 64, 32)
    line(24, 36, 64, 36)
    line(24, 40, 64, 40)

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
     ;TODO loop this
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
size: ;Image size, will need to be configurable with new image screen at some point, currently unused
	.db 20
item:
    .db 0
caretIcon: ;Just a line atm, maybe go back to the 'default' cursor?
    .db 0b00000000
    .db 0b00000000
    .db 0b11111000
    .db 0b00000000
cursor_y:
    .db 0
cursor_x:
    .db 0
menu:
    .db 3
    .db "New", 0
    .db "Open", 0
    .db "Exit", 0
menu_functions:
	.dw newImage
	.dw loadImage
	.dw exit
