
    global main
    extern puts
    extern printf

default rel
    section .data
fmt: db "hello world %i \n", 0 ; 0 for null terminator
val: dd 50 ; 0 for null terminator
    section .text
main:
    mov rdi, fmt
    mov rsi, [val]
    xor eax, eax ; zero out return register
    call printf wrt ..plt ; with respect to procedure linkage table
    ret
