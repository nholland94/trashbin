global assign_pervasives_to_proc_hash
extern hashtable_set

; TODO: find a better way to hard code the pervasives

pervasive_count   equ  3

ssbl_swap_name    db   'swap'
ssbl_over_name    db   'over'
ssbl_exit_name    db   'exit'

pervasive_names:
  dd ssbl_swap_name
  dd ssbl_over_name
  dd ssbl_exit_name

pervasive_points:
  dd ssbl_swap
  dd ssbl_over
  dd ssbl_exit

; assigns pervasive functions to proc hashtable at ebp
assign_pervasives_to_proc_hash:
  mov ecx, 0
_assign_loop:
  mov eax, ecx
  mov ebx, 4
  mul ebx
  mov edx, [pervasive_names+eax]
  mov ebx, [pervasive_points+eax]
  call hashtable_set

  cmp ecx, pervasive_count
  jng  _assign_loop

  ret

;;;;;;;;;;;;
; PERVASIVES
;;;;;;;;;;;;
; all pervasives need to be mindful of the stack and not screw it up
;;;;;;;;;;;;

ssbl_swap:
  pop eax
  pop ebx
  push eax
  push ebx

  ret

ssbl_over:
  pop eax
  pop ebx
  pop ecx

  push ebx
  push eax
  push ecx

  ret

ssbl_exit:
  mov eax, 1
  pop ebx
  int 0x80

  ret
