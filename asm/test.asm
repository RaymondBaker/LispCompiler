    global main
    extern puts
    extern printf

default rel
    section .data
int_print_fmt: db "%d \n", 0

    section .text
main:
; add 
push r9
mov r8, 1
mov r9, 3
add r8, r9
pop r9
; Print 
push rdi
push rsi
mov rdi, int_print_fmt
mov rsi, r8
call printf wrt ..plt
pop rsi
pop rdi