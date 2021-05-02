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
; div 
mov rax, r11
mov r9, 3
xor rdx, rdx
div r9
mov r8, rax
; Print 
push rdi
push rsi
mov rdi, int_print_fmt
mov rsi, r8
xor eax, eax
call printf wrt ..plt
pop rsi
pop rdi
ret