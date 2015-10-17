
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
    ;x
    .db 29, 55
    .db 33, 55
    .db 37, 55
    .db 41, 55
    .db 45, 55
    .db 49, 55
    .db 53, 55
    .db 57, 55
    .db 61, 55
    .db 65, 55
    
    .db 29, 51
    .db 33, 51
    .db 37, 51
    .db 41, 51
    .db 45, 51
    .db 49, 51
    .db 53, 51
    .db 57, 51
    .db 61, 51
    .db 65, 51
    
    .db 29, 47
    .db 33, 47
    .db 37, 47
    .db 41, 47
    .db 45, 47
    .db 49, 47
    .db 53, 47
    .db 57, 47
    .db 61, 47
    .db 65, 47
    
    .db 29, 43
    .db 33, 43
    .db 37, 43
    .db 41, 43
    .db 45, 43
    .db 49, 43
    .db 53, 43
    .db 57, 43
    .db 61, 43
    .db 65, 43
    
    .db 29, 39
    .db 33, 39
    .db 37, 39
    .db 41, 39
    .db 45, 39
    .db 49, 39
    .db 53, 39
    .db 57, 39
    .db 61, 39
    .db 65, 39
    
    .db 29, 35
    .db 33, 35
    .db 37, 35
    .db 41, 35
    .db 45, 35
    .db 49, 35
    .db 53, 35
    .db 57, 35
    .db 61, 35
    .db 65, 35
    
    .db 29, 31
    .db 33, 31
    .db 37, 31
    .db 41, 31
    .db 45, 31
    .db 49, 31
    .db 53, 31
    .db 57, 31
    .db 61, 31
    .db 65, 31
    
    .db 29, 27
    .db 33, 27
    .db 37, 27
    .db 41, 27
    .db 45, 27
    .db 49, 27
    .db 53, 27
    .db 57, 27
    .db 61, 27
    .db 65, 27
    
    .db 29, 23
    .db 33, 23
    .db 37, 23
    .db 41, 23
    .db 45, 23
    .db 49, 23
    .db 53, 23
    .db 57, 23
    .db 61, 23
    .db 65, 23

    .db 29, 19
    .db 33, 19
    .db 37, 19
    .db 41, 19
    .db 45, 19
    .db 49, 19
    .db 53, 19
    .db 57, 19
    .db 61, 19
    .db 65, 19
cursorPos_end:
    .db 0 
