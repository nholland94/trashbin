global process
extern type_proc, init_frames, push_frame, pop_frame, current_frame

; processes a symbol list at eax
; ebp should point to proc hash
; stack at this point should represent environment stack
process:
  mov edx, eax

  push eax
  push ebp

  call init_frames

  pop ebp
  pop eax

  jmp _process_start

_process_next:
  add eax, 5
_process_start:
  cmp byte [eax], 0
  je _done
  cmp byte [eax], type_proc
  je _run_proc
  push eax
  jmp _process_next

_run_proc:
  mov edx, eax
  call push_frame
  mov eax, dword [edx+1]

  call _process_start

  mov edx, dword [current_frame]
  call pop_frame

  mov eax, edx
  jmp _process_next

_done:
  ret
