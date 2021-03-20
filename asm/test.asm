    global main
    extern puts
    extern printf

default rel
    section .data
int_print_fmt: db "%d", 10, 0 ; 10 is newline

    section .text
main:
; add 
mov r11, 234
mov r8, 3
add r11, r8
; add 
mov r8, 3
mov r9, 5
add r8, r9
mov r9, r11
add r8, r9
; add 
mov r9, 1
mov r10, 3
add r9, r10
mov r10, r8
add r9, r10
; Print 
push rdi
push rsi
mov rdi, int_print_fmt
mov rsi, r9
xor eax, eax
call printf wrt ..plt
pop rsi
pop rdi
ret