;;;;;;;
; STACK
;;;;;;;

; later, the stack will be dynamically allocated
point_stack_size equ 0xff
data_stack_size  equ 0xffffff

stack_position   db  0

point_stack:
  times point_stack_size db 0

data_stack:
  times data_stack_size db 0

; eax is first byte to copy
; ecx is length of data
push_stack:
  cmp [stack_position], point_stack_size
  je  err_stack_exceeded
  mov ebx, [stack_position]
  mov ebx, [point_stack+ebx]
  add ebx, data_stack
  mov edx, 0
_copy_data_loop:
  mov [ebx+edx], [eax+edx]
  inc edx
  cmp edx, ecx
  jne _copy_data_loop

  mov edx, [stack_position]
  inc edx

  sub ebx, data_stack
  mov [edx+point_Stack], ebx

  mov [stack_position], edx

  ret

; eax gets set to pointer to data
; ebx gets set to length of data
pop_stack:
  cmp [stack_position], 0
  je  err_stack_empty
  mov eax, [stack_position]
  mov ebx, [stack_position-1]
  sub ebx, eax
  sub [stack_position], 1

  ret

drop_stack:
  cmp [stack_position], 0
  je  err_stack_empty
  sub [stack_position], 1

  ret

swap_stack:
  mov [stack_position]

;;;;;;;;;;;;
; OPERATIONS
;;;;;;;;;;;;

noop:
  ret

push:
  ret

drop:
  call drop_stack
  ret

swap:
  call swap_stack
  ret

frame_jump:
  ret
  
frame_complete:
  ret

crash:
  mov eax, 1
  mov ebx, 1
  int 0x80

  ret ; shouldn't technically be required

array_concat:

invalid_op_byte:
  ret

op_byte_defs:
  dw noop
  dw push
  dw frame_jump
  dw frame_complete
  dw crash
  times 250 dw invalid_op_byte
  ; times 255-$$ dw invalid_op_byte
