[ORG 0x7c00]
  jmp start

  %include "boot/print.inc"

start:
  ; DS=0
  xor ax, ax
  mov ds, ax

  ; setup stack
  mov ss, ax
  mov sp, 0x9c00 ; 200h past code start

  mov ax, 0xb800 ; text video memory
  mov es, ax

  ; setup keyhandler interrupt
  cli
  mov bx, 0x09
  shl bx, 2
  xor ax, ax
  mov gs, ax
  mov [gs:bx], word keyhandler
  mov [gs:bx+2], ds
  sti

  jmp $ ; loop forever

keyhandler:
  in al, 0x60 ; get key data
  mov bl, al
  mov byte [port60], al

  in al, 0x61
  mov ah, al
  or al, 0x80
  out 0x61, al
  xchg ah, al
  out 0x61, al

  mov al, 0x20
  out 0x20, al

  and bl, 0x80
  jnz done

  mov ax, [port60]
  mov word [reg16], ax
  call printreg16

done:
  iret

port60    dw 0

; fill to 512
times 510-($-$$) db 0
db 0x55
db 0xAA
