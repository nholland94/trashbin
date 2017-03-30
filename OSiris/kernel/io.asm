global print_string

text_video_memory_offset  equ  0xb800

xpos                      db   0
ypos                      db   0

; si - point to string start
print_string:
  mov ax, text_video_memory_offset
  mov es, ax

_print_string_loop:
  lodsb
  je _print_string_done

  movzx ax, byte [ypos]
  mov dx, 160           ; 2 bytes * 80 columns
  mul dx
  movzx bx, byte [xpos]
  shl bx, 1             ; shift to skip attrib

  mov di, 0
  add di, ax
  add di, bx

  mov ax, 0x000F         ; white on black
  stosw
  add byte [xpos], 1

  call _print_string_loop

_print_string_done:
  add byte [ypos], 1
  mov byte [xpos], 0
  ret
