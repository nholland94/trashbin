global init_frames, push_frame, pop_frame, current_frame
extern allocate_memory

; frames contain 3 dwords
; first points to frame value
; second points to prev frame
; third points to next frame (0 if no frame)

frame_base    resd 1
frame_count   resw 1
current_frame resd 1

; edx should point to main
init_frames:
  push edx

  mov ecx, 12
  call allocate_memory

  pop edx
  mov [eax], edx
  mov [eax+4], 0x00000000 ; probably not necessary
  mov [eax+8], 0x00000000
  mov ebx, [frame_base]
  mov [ebx], eax
  mov ebx, [current_frame]
  mov [ebx], eax

  ret

; edx should point to new frame
push_frame:
  mov ebx, [current_frame]
  cmp [ebx+8], 0
  jne _skip_allocation

  push ebx
  push edx

  mov ecx, 12
  call allocate_memory

  pop edx
  pop ebx

  mov [ebx+8], eax

_skip_allocation:
  lea eax, [ebx+8] ; operation unnecessary if allocation was performed, but code is neater this way

  mov [eax], edx
  mov [eax+4], ebx
  mov [eax+8], 0x00000000

  ret

pop_frame:
  mov ebx, [current_frame]

  mov eax, [ebx+4]

  mov [ebx], 0x00000000
  mov [ebx+4], 0x00000000
  mov [ebx+8], 0x00000000

  mov [current_frame], eax
  mov [eax+8], 0x00000000

  ret
