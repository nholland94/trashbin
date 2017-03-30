extern print_string

global setup_syscall_interrupt

page_offset      equ  0x000186A0 ; leaves 100k bytes for kernel currently (I doubt I will ever fill that up)
num_sys_calls    equ  2

allocated_bytes  dd   0

syscalls:
  dd sys_allocate
  dd sys_print

; this is some really dumb memory management for now
; eax - return register for pointer
; ecx - amount of bytes to allocate
sys_allocate:
  push allocated_bytes
  add dword [allocated_bytes], ecx

  mov eax, [page_offset+eax]

  ret

; ebx - pointer to string
sys_print:
  push ebx
  push es

  mov es, ebx

  push ax
  push bx
  push dx
  push di

  call print_string

  pop di
  pop dx
  pop bx
  pop ax

  pop es
  pop ebx

; we keep every register the same except for eax
syscall_handler:
  cmp eax, num_sys_calls
  jle _syscall_not_found

  ; calculate syscall pointer index
  push ebx
  mov ebx, 4
  mul ebx
  pop ebx

  push ebp
  mov ebp, dword syscalls
  mov eax, [ebp+eax]
  pop ebp

  call eax
  jmp _syscall_done

_syscall_not_found:
  ; what do I do here?
  jmp _syscall_done

_syscall_done:
  iret

setup_syscall_interrupt:
  mov ax, 0xff
  mov bx, 4
  mul bx

  mov bx, ax
  xor ax, ax
  mov ds, ax
  mov gs, ax

  cli
  mov [gs:bx], dword syscall_handler
  mov [gs:bx+2], ds
  sti

  ret
