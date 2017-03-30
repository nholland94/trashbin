global hash_string, hashtable_create, hashtable_get, hashtable_set
extern allocate_memory, copy_string_null_term

fnv_prime          equ   16777619 ; 32 bit fnv prime (2^24 + 2^8 + 0x93)
fnv_offset_basis   equ   2166136261

; hashes null term string pointed to by edx
hash_string:
  mov eax, fnv_offset_basis
  mov ebx, fnv_prime
  mov ecx, 0
  mov edi, edx
  mov edx, 0
_hash_string_loop:
  mov dl, [edi+ecx]
  cmp dl, 0
  je _hash_string_done
  xor eax, edx
  mul ebx
  inc ecx
  jmp _hash_string_loop

_hash_string_done:
  ret

; hash size in cx
hashtable_create:
  push cx

  ; calculate required bytes for hashtable
  ; 4 (size) + 12 * size (array of linked lists of k/v pairs)
  mov eax, ecx
  mov ebx, 12
  mul ebx
  mov ecx, eax
  add ecx, 4

  call allocate_memory

  pop ecx
  mov [eax], ecx

  ret

hashtable_get_collision_table:
  push dword [ebp] ; push size of hash to stack

  call hash_string ; hash string to eax

  pop ebx          ; hash size
  mov edx, 0
  div ebx          ; calculate hash lookup index

  ; calculate collision table pointer and place in edx
  mov eax, edx
  mov bx, 8
  mul bx

  mov edx, ebp
  add edx, 4
  add edx, eax

; edx - point to key
; ebp - point to hashtable
; return: value in edx
hashtable_get:
  push edx
  call hashtable_get_collision_table

  pop esi
  mov edi, [edx]
  mov ecx, 0
_hashtable_get_str_compare_loop:
  mov al, [edi+ecx]
  mov bl, [esi+ecx]
  cmp al, bl
  jne _hashtable_get_str_compare_fail
  cmp al, 0
  je _hashtable_get_str_compare_success
  inc ecx
  jmp _hashtable_get_str_compare_loop

_hashtable_get_str_compare_fail:
  mov eax, [edx+8] ; load link list tail
  cmp eax, 0
  je _hashtable_get_fail

  mov edx, [eax]
  jmp _hashtable_get_str_compare_loop

_hashtable_get_str_compare_success:
  mov edx, [edx+4]
  jmp _hashtable_get_done

_hashtable_get_fail:
  mov edx, 0
_hashtable_get_done:
  ret

; ebx - value to save (stored in 32bits)
; edx - point to key
; ebp - point to hashtable
hashtable_set:
  push ebx

  push edx
  call hashtable_get_collision_table

  cmp byte [edx], 0
  je _hashtable_set_add_key_to_collision_table

  pop esi
  pop ebx
  mov edi, [edx]
  mov ecx, 0
_hashtable_set_str_compare_loop:
  mov al, [edi+ecx]
  mov bl, [esi+ecx]
  cmp al, bl
  jne _hashtable_get_str_compare_fail
  cmp al, 0
  je _hashtable_set_add_value_to_collision_table
  inc ecx
  jmp _hashtable_get_str_compare_loop

_hashtable_set_str_compare_fail:
  mov eax, [edx+8]
  cmp eax, 0
  je _hashtable_set_add_key_to_collision_table

  mov edx, [eax]
  jmp _hashtable_set_str_compare_loop

_hashtable_set_add_key_to_collision_table:
  mov edi, esi
  mov al, 0
  mov ecx, 0xffffffff
  cld
  repne scasb

  not ecx
  inc ecx

  push edx
  push ebx

  call allocate_memory

  mov ebp, eax
  call copy_string_null_term

  push ebp

  mov ecx, 12
  call allocate_memory

  pop ebp
  mov [eax], ebp

  pop ebx
  pop edx

  mov [edx+8], eax
  mov edx, [edx+8]
_hashtable_set_add_value_to_collision_table:
  mov [edx+4], ebx
_hashtable_set_done:
  ret
