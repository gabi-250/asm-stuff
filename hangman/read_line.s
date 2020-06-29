    .section .rodata
read_mode:    .asciz "r"
newline_char: .byte '\n'
    .text
    .global read_line
# Read a particular line from the specified file.
#
# Arguments:
#   RDI - the name of the file to read
#   RSI - the address where to store the line read
#   RDX - the maximum number of bytes to read for each line
#   RCX - the number of the line to read
read_line:
    push %rbp
    mov %rsp, %rbp
    sub $40, %rsp
    mov %rsi, -8(%rbp)
    mov %rdx, -16(%rbp)
    mov %rcx, -24(%rbp)
    # the filename is already in RDI
    lea read_mode(%rip), %rsi
    callq fopen
    # store the file descriptor
    mov %rax, -32(%rbp)
    # keep track of the current line
    movq $0, -40(%rbp)
    # the line to read
    mov -24(%rbp), %rax
    mov %rax, -24(%rbp)
.Lread_line:
    # line_idx += 1
    add $1, -40(%rbp)
    # the address of the line read
    mov -8(%rbp), %rdi
    # the maxium line length
    mov -16(%rbp), %rsi
    # the file descriptor
    mov -32(%rbp), %rdx
    callq fgets
    # check if fgets returned NULL
    test %rax, %rax
    je .Ldone
    # check if we've reached the target line
    mov -24(%rbp), %rax
    cmp -40(%rbp), %rax
    jne .Lread_line
.Ldone:
    # strip the newline
    mov -8(%rbp), %rdi
    mov newline_char(%rip), %rsi
    call strchr
    movb $0, (%rax)
    xor %rax, %rax
    leaveq
    ret
