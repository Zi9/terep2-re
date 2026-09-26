
%include "macros.asm"
%include "../common/macros.asm"

%define _DATA2 0


section .data
_base_mem:
base_mem:

incbin "../memdumps/data.bin"

%include "../common/newvars_defs.asm"

nova_linha:
    db "GAMBIARRA FOREVER 32!", 0

ptr_seg_DeS: dd 0
ptr_seg_EeS: dd 0
ptr_seg_FeS: dd 0
ptr_seg_GeS: dd 0

align 8
_all_segments:
all_segments:
    times 256 dd 0


;this call portal exists so we can comunicate with the C side without caring about calling conventions
align 4
_call_portal:
call_portal:
    .axr: dw 0
    .bxr: dw 0
    .cxr: dw 0
    .dxr: dw 0
    .ok: dw 0
    dw 0 ; alignment
    .caller: dd 0

;TODO guard value

%ifdef WIN32
    global _call_portal
    global _all_segments
    global _base_mem
%else
    global call_portal
    global all_segments
    global base_mem
%endif

section .text

extern _mydoscall
extern _adlib_callback

%ifdef WIN32
    global _asm_f_init
    global _asm_render
    global _asm_physics
    global _asm_keys
%else
    global asm_f_init
    global asm_render
    global asm_physics
    global asm_keys
%endif

%include "maincode32.asm"
%include "elfunction.asm"


DOS3Call:
    PUSH dword [ESP]
    POP  dword [call_portal.caller]

    MOV [call_portal.axr], AX
    MOV [call_portal.bxr], BX
    MOV [call_portal.cxr], CX
    MOV [call_portal.dxr], DX

    PUSHAD

    MOV EBP, ESP
    ;align the stack
    AND ESP, -4

    call _mydoscall
    MOV ESP, EBP

    POPAD

    MOV AX, [call_portal.axr]
    MOV BX, [call_portal.bxr]
    MOV CX, [call_portal.cxr]
    MOV DX, [call_portal.dxr]
    CMP word [call_portal.ok], 0
    JE .deu_ruim
    CLC
    ret

    .deu_ruim:
    STC
    ret

sound_thing:
    MOV [call_portal.axr], AX
    PUSHAD

    MOV EBP, ESP
    ;align the stack
    AND ESP, -4

    call _adlib_callback
    MOV ESP, EBP

    POPAD
    ret    


asm_f_init:
_asm_f_init:
    airlock_prologue

    mov dword [all_segments], base_mem
    mov dword [ptr_seg_DeS], base_mem

    call f_init

    MOV word [call_portal.axr],  AX

    airlock_epilogue
    ret

asm_render:
_asm_render:
    airlock_prologue

    call FUN_main_render

    airlock_epilogue
    ret


asm_physics:
_asm_physics:
    airlock_prologue

    call FUN_timer_5680

    airlock_epilogue
    ret

asm_keys:
_asm_keys:
    airlock_prologue

    MOV AX, [call_portal.axr]
    call FUN_keyboard_56df

    airlock_epilogue
    ret