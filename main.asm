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
    pcall(clearBuffer)

    kld(de, corelibPath)
    pcall(loadLibrary)
    kcall(draw_ui)


    

new_image: 
    kcall(draw_ui)
    
    
main_loop:
    kcall(draw_ui)

    ; empty screen; lets make the grid
.key_loop: 
    pcall(fastCopy)
    pcall(flushKeys)
    corelib(appWaitKey) ; loads `a` with the pressed key
    
    cp kMODE
    ret z
    
    cp kF3
    kjp(z, .main_menu)
    
    cp kUp
    jr z, .up
    cp kDown
    jr z, .down
      
    jr .key_loop
.up:
    kld(a, (current))
    dec a
    jr z, main_loop
    kld((current), a)
    jr main_loop

.down:
    kld(a, (current))
    inc a
    cp (cursorPos_end - cursorPos) / 2 + 1
    jr z, main_loop
    kld((current), a)
    jr main_loop

.main_menu:
    kld(hl, menu); menu descriptors
    ld c, 40 ;width in pixels of menu
    corelib(showMenu)
    cp 0xFF
    kjp(z, draw_ui)
    kld(hl, menu_functions)
    add a, l \ ld l, a \ jr nc, $+3 \ inc h
    ld e, (hl) \ inc hl \ ld d, (hl)
    pop hl
    ex de, hl
    kld(bc, 0)
    add hl, bc
    jp (hl)
    ret

load_image: ;TODO: make this work
    ret

exit:
    pcall(killCurrentThread)

draw_ui:
    pcall(clearBuffer)
    xor a
    kld(hl, newImageTitle) 
    ld a, 0b00000100
    corelib(drawWindow)
    pcall(fastCopy)
    kcall(draw_grid)
    kjp(z, xor_selector)


xor_selector: ;credits to KnightOS/periodic
    push hl
        kld(a, (current)) \ dec a
        kld(hl, CursorPos)
        add a, a \ add a, l \ ld l, a
        jr nc, $+3 \ inc h
        ld b, (hl) \ inc hl \ ld c, (hl)
        ld a, b
        kld((.vertical_loop + 1), a) ; SMC
    pop hl
    kcall(.vertical_loop)
    dec c
    kcall(.vertical_loop)
    dec c
; Displays 4 pixels vertically
.vertical_loop:
    ld a, 0 ; SMC
    ld b, 29 ; cursors initial x
    ld a, 3 ;width of cursor
.loop:
    kcall(_IPoint)
    inc b
    dec a
    jr nz, .loop
    ret


_IPoint:
    ; Cannot destroy anything
    push af
    push hl
        ld l, c ; Y
        ld a, l 
        sub a, 33 
        neg 
        add a, 33 
        ld l, a
        
        ld a, b ; X
        
        pcall(invertPixel) ; input: A,L (X, Y)
    pop hl
    pop af
    ret
    
draw_grid: 

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
    line(28, 0, 68, 0)
    line(28, 4, 68, 4)
    line(28, 8, 68, 8)
    line(28, 12, 68, 12)
    line(28, 16, 68, 16)
    line(28, 20, 68, 20)
    line(28, 24, 68, 24)
    line(28, 28, 68, 28)
    line(28, 32, 68, 32)
    line(28, 36, 68, 36)
    line(28, 40, 68, 40)

    ;vertical
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
    line(68, 40, 68, 1)

     ;TODO loop this
    ret

;Following below code credits to SirCmpwn with KnightOS/bed
unload_current_file:
    kld(hl, (file_name))
    ld bc, 0
    pcall(cpHLBC)
    jr z, _
    push hl \ pop ix
    pcall(free)
_:  kld(hl, (file_buffer))
    pcall(cpHLBC)
    ret z
    push hl \ pop ix
    pcall(free)
    ret

load_new_file:
    kcall(unload_current_file)
    ld hl, 0
    kld((file_name), hl)
    kld((file_length), hl)
    kld((index), hl)
    ld bc, 0x100
    kld((file_buffer_length), bc)
    ld a, 1
    pcall(calloc)
    kld((file_buffer), ix)
    ret

load_existing_file:
    kld((file_name), de)
    pcall(openFileRead)
    pcall(getStreamInfo)
    kld((file_length), bc)
    ; TODO: Don't just edit files in memory
    inc bc
    kld((file_buffer_length), bc)
    pcall(malloc)
    pcall(streamReadToEnd)
    push ix
        add ix, bc
        ld (ix + -1), 0 ; Delimiter
    pop ix
    kld((file_buffer), ix)
    ld hl, 0
    kld((index), hl)
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
    .dw new_image
    .dw load_image
    .dw exit
file_buffer:
    .dw 0
file_buffer_length:
    .dw 0
file_name:
    .dw 0
file_length:
    .dw 0
index:
    .dw 0
current:
    .dw 1
cursorPos: ;Really shouldn't hardcode this...
    ;y
    .db 45, 55  ; H
    .db 45, 51  ; H
    .db 45, 47  ; H
    .db 45, 43  ; H
    .db 45, 39  ; H
    .db 45, 35  ; H
    .db 45, 31  ; H
    .db 45, 27  ; H
    .db 45, 23  ; H
    .db 45, 19  ; H

cursorPos_end:
    .db 0