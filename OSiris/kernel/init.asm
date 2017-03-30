extern setup_syscall_interrupt

global _start

section .text
_start:
  call setup_syscall_interrupt

_loop:
  jmp _loop
