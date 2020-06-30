    .section .rodata
read_mode:    .asciz "r"
newline_char: .byte '\n'
    .text
    .global read_rand_line

# Read a particular line from the specified file.
#
# Arguments:
#   RDI - the name of the file to read
#   RSI - the address where to store the line read
#   RDX - the maximum number of bytes to read for each line
read_rand_line:
    push %rbp
    mov %rsp, %rbp
    sub $8, %rsp
    # save the registers we're going to clobber
    push %r15
    push %r14
    push %r13
    push %r12
    push %rbx
    mov %rsi, %r12
    mov %rdx, %r13
    # the filename is already in RDI
    lea read_mode(%rip), %rsi
    call fopen
    # store the file descriptor
    mov %rax, %r15
    # first, count the lines in the file
    mov %rax, %rdi
    call rand_line
    mov %rax, %r14
    #call count_lines
    #mov %rax, -8(%rbp)
    mov %r15, %rdi
    call rewind
    # keep track of the current line
    movq $0, %rbx
    # the line to read
    mov %r14, %rax
    mov %rax, %r14
.Lread_line:
    # line_idx += 1
    add $1, %rbx
    # the address of the line read
    mov %r12, %rdi
    # the maxium line length
    mov %r13, %rsi
    # the file descriptor
    mov %r15, %rdx
    call fgets
    # check if fgets returned NULL
    test %rax, %rax
    je .Ldone
    # check if we've reached the target line
    mov %r14, %rax
    cmp %rbx, %rax
    jne .Lread_line
.Ldone:
    # strip the newline
    mov %r12, %rdi
    mov newline_char(%rip), %rsi
    call strchr
    movb $0, (%rax)
    xor %rax, %rax
    mov %r15, %rdi
    call fclose
    # restore the registers
    pop %rbx
    pop %r12
    pop %r13
    pop %r14
    pop %r15
    leave
    ret

# Count the number of lines in a file.
#
# Arguments:
#   RDI - the file descriptor
# Returns:
#   RAX - the number of lines in the file
count_lines:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    mov %rdi, %r12
    mov $0, %rbx
1:
   mov %r12, %rdi
   call fgetc
   mov $-1, %rcx
   cmpb %al, %cl
   je 2f
   cmpb %al, newline_char(%rip)
   jne 1b
   add $1, %rbx
   jmp 1b
2:
    mov %rbx, %rax
    pop %r12
    pop %rbx
    leave
    ret

# Returns a random line number from the specified file.
#
# Arguments:
#   RDI - the file descriptor
# Returns:
#   RAX - a valid line number in the file
rand_line:
    push %rbp
    mov %rsp, %rbp
    push %r12
    call count_lines
    # R12 stores the number of lines in the file
    mov %rax, %r12
    mov $0, %rdi
    call time
    mov %rax, %rdi
    call srand
    call rand
    mov $0, %rdx
    mov %r12, %rbx
    div %rbx
    mov %rdx, %rax
    pop %r12
    leave
    ret
