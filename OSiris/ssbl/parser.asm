; TODO replace linux kernel calls
global _start
extern allocate_memory, copy_string_null_term, hashtable_create, hashtable_set, hashtable_get

  token_space         equ    ' '
  token_new_line      equ    0x0A

section .data
  example_ssbl       incbin  "example.ssbl"

  teststr             db     'proc say-hello ("name" --)', 0
  anotherteststr      db     'proc a-proc (stuff -- other-stuff)', 0

  teststrname         db     'say-hello', 0

  keyword_proc        db  '  proc', 0


section .bss
  proc_list_base_p    resd   1
  proc_struct_p       resd   1

section .text

; compares strings pointed at by edi/esi until ' ' is hit on edi
; this can cause an overread of esi... need to get better at asm
compare_words:
  mov al, [edi]
  mov dl, [esi]
  cmp al, ' '
  je _compare_words_done
  cmp al, dl
  jne _compare_words_done
  inc edi
  inc esi
  jmp compare_words
_compare_words_done:
  ret ; zero flag is already set by comparison

count_word:
  mov esi, edi
  mov ecx, 0xffffffff
  mov al, token_space
  cld
  repne scasb
  not ecx
  lea eax, [ecx-1]

  ret

failure:
  mov eax, 1
  mov ebx, 1
  int 0x80

;---------------------------

_start:
  mov ecx, 128
  call hashtable_create

  push eax

  mov edi, teststr
  call parse_proc
  mov eax, ebp

  pop ebp

  mov edx, [eax]
  mov ebx, eax
  call hashtable_set

  push ebp

  mov edi, anotherteststr
  call parse_proc
  mov eax, ebp

  pop ebp

  mov edx, [eax]
  mov ebx, eax
  call hashtable_set

  mov edx, teststrname
  call hashtable_get

  mov eax, 1
  mov ebx, edx
  int 0x80

; parses a proc starting at edi
; points ebp to proc struct
; currently only parses the header
parse_proc:
  ;;;;;;;;;;;;;;;;;;;;;;
  ; allocate proc struct
  ;;;;;;;;;;;;;;;;;;;;;;

  push edi

  mov ecx, 0x60 ; 3x 32 bit pointers
  call allocate_memory
  mov [proc_struct_p], eax

  pop edi

  ;;;;;;;;;;;;;;;;;;;
  ; check proc keyword
  ;;;;;;;;;;;;;;;;;;;

  mov esi, keyword_proc
  call compare_words
  jne failure

  ;;;;;;;;;;;;;;;;
  ; read proc name
  ;;;;;;;;;;;;;;;;

  inc edi

  call count_word

  push esi
  push edi

  inc ecx ; 1 extra byte for null term
  call allocate_memory
  mov ebp, eax

  pop edi
  pop esi

  call copy_string_null_term

  ; put string pointer into proc struct
  mov edx, [proc_struct_p]
  mov [edx], ebp

  ;;;;;;;;;;;;;;;;;;;;;;;;
  ; parse stack descriptor
  ;;;;;;;;;;;;;;;;;;;;;;;;

  cmp byte [edi], '('
  jne failure

  push edi ; keep the beginning of the stack descriptor
  inc edi

  mov ecx, 0xffffffff
  mov al, ')'
  cld
  repne scasb

  ; set ecx to the number of bytes to read
  mov ecx, edi
  pop edi
  sub ecx, edi

  push edi

  mov edx, 0
  mov al, ' '
_count_sections:
  cld
  repe scasb

  cmp ecx, 0
  je _count_sections_done

  cld
  repne scasb

  inc edx

  cmp ecx, 0
  je _count_sections_done

  jmp _count_sections
_count_sections_done:

  ; allocate stack effect array
  mov eax, edx
  mov edx, 4
  mul edx ; 4 bytes to store each pointer
  mov ecx, eax

  push edi
  call allocate_memory
  pop edi

  pop esi ; pointer to beginning of stack
  mov ecx, edi
  sub ecx, esi

  push eax

  mov edx, 0 ; stack effect index counter
  mov edi, esi
  mov al, ' '
_copy_stack_descriptors:
  cld
  repe scasb

  cmp ecx, 0
  je _copy_stack_descriptors_done

  mov esi, edi
  mov ebx, ecx
  repne scasb

  push ecx

  xchg ebx, ecx
  sub ecx, ebx
  inc ecx        ; space for null term

  push edx
  push edi
  push esi

  call allocate_memory
  mov ebp, eax

  pop esi
  pop edi
  pop edx

  call copy_string_null_term

  pop ecx ; scanner counter

  pop ebx ; array base pointer

  mov [ebx+edx], eax

  push ebx

  cmp ecx, 0
  jne _copy_stack_descriptors_done

  inc edx
  jmp _copy_stack_descriptors

_copy_stack_descriptors_done:

  pop ebp ; array base pointer

  mov edx, [proc_struct_p]
  mov [edx+4], ebp

  mov ebp, edx

  ret
