global create_variable
extern allocate_memory, print_null_term

; variables contain 1 byte identifier with 2 nibbles
; first nibble contains the id of the type
; second nibble is reserved for now (probably will be used for type metadata)

type_int         equ   0x0
type_string      equ   0x1
type_proc        equ   0x2

assertion_failed_msg         db  'Failed type assertion: ', 0
assertion_failed_msg_buffer  db  ' - ', 0

create_variable:
  push eax
  push ebx

  mov ecx, 5
  call allocate_memory

  pop ebx
  pop edx

  mov [eax], edx
  mov [eax+1], ebx

  ret

; variable in eax
; type in ebx
assert_type:
  cmp byte [eax], ebx
  je  _assert_failed
  ret
_assert_failed:
  push ebx
  push eax

  mov edi, assertion_failed_msg
  call print_null_term

  pop eax
  mov eax, byte [eax]
  call print_uint

  mov edi, assertion_failed_msg_buffer
  call print_null_term

  pop eax
  call print_uint

  mov eax, 1
  mov ebx, 1
  int 0x80

  ret ; we should probably never reach this
