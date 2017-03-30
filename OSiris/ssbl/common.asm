global allocate_memory, copy_string_null_term, print_null_term

; reserved byte for uint printing
char_swap resb 1

; allocates ecx bytes in memory using mmap2
allocate_memory:
  mov eax, 192   ; mmap2
  xor ebx, ebx   ; don't set address
  mov edx, 0x07  ; PROT_READ|PROT_WRITE|PROT_EXEC
  mov esi, 0x22  ; MAP_PRIVATE|MAP_ANONYMOUS
  mov edi, -1    ; file descriptor
  xor ebp, ebp   ; no offset
  int 0x80

  ret

; copies string between esi and edi into memory starting at ebp
copy_string_null_term:
  mov ecx, 0
_copy_string_null_term_loop:
  mov [ebp+ecx], esi
  add ecx, 1
  add esi, 1
  cmp esi, edi
  jne _copy_string_null_term_loop

  ret

; prints a null terminated string pointed to edi
; this is more work right now, but the OSiris kernel syscall will print null term
print_null_term:
  push edi

  mov al, 0
  mov ecx, 0xffffffff
  repne scasb
  not ecx

  mov edx, ecx
  pop ecx
  mov ebx, 1
  mov eax, 4
  int 0x80

  ret

; prints uint stored in eax
print_uint:
  mov ecx, eax
  mov ebx, 10
  mov edx, 0

_print_uint_loop:
  div ebx
  add edx, 48 ; ascii digit offset
  mov [char_swap], edx

  push ebx
  push eax

  mov edx, 1
  mov ecx, char_swap
  mov ebx, 1
  mov eax, 4
  int 0x80

  pop eax
  pop ebx

  cmp eax, 0
  jne _print_uint_loop

  ret
