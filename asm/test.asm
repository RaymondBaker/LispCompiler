    global main
    extern puts
    extern printf

default rel
    section .data
int_print_fmt: db "%d", 10, 0 ; 10 is newline

    section .text
main:
; mul 
mov rax, 3
mov r8, 3
mul r8
mov r11, rax
; sub 
mov r8, 4
mov r9, 2
sub r8, r9
; add 
mov r9, 2
mov r10, 3
add r9, r10
; Print 
push rdi
push rsi
mov rdi, int_print_fmt
mov rsi, r11
xor eax, eax
call printf wrt ..plt
mov rdi, int_print_fmt
mov rsi, r8
xor eax, eax
call printf wrt ..plt
mov rdi, int_print_fmt
mov rsi, r9
xor eax, eax
call printf wrt ..plt
pop rsi
pop rdi
ret