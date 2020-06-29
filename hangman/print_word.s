    .section .rodata
clear_screen: .asciz "\033[2J\033[H"
word_message: .asciz "The word is: \n"
format_char2: .asciz "%c "
newline_str:  .asciz "\n"
hidden_char:  .byte '_'
    .text
    .global print_word
# Print the specified string, replacing its 'hidden' letters with underscores.
#
# Arguments:
#   RDI - the string to print
#   RSI - the length of the string
#   RDX - a pointer to an array of bytes of the same length as the string.
#         Each byte corresponds to a letter (1 means visible, 0 means hidden)
# Returns:
#   RAX - 1, if there are any hidden letters left, and 0 otherwise
print_word:
    push %rbp
    mov %rsp, %rbp
    sub $32, %rsp
    mov %rdi, -8(%rbp)
    mov %rsi, -16(%rbp)
    mov %rdx, -24(%rbp)
    lea clear_screen(%rip), %rdi
    call puts
    xor %rax, %rax
    lea word_message(%rip), %rdi
    call printf
    # print each char
    mov -16(%rbp), %r12
    # print the word again, but hide the middle chars
    mov $0, %r13
    mov $0, %bl
1:
    cmp %r12, %r13
    jnl .Ldone
    mov -24(%rbp), %rax
    mov (%rax, %r13, 1), %rax
    test %al, %al
    je .Lprint_hidden
    jmp .Lprint_letter
.Lprint_hidden:
    mov $1, %bl
    xor %rax, %rax
    lea format_char2(%rip), %rdi
    mov hidden_char(%rip), %rsi
    call printf
    jmp 2f
.Lprint_letter:
    xor %rax, %rax
    lea format_char2(%rip), %rdi
    mov -8(%rbp, %r13, 1), %rsi
    call printf
2:
    add $1, %r13
    jmp 1b
.Ldone:
    lea newline_str(%rip), %rdi
    call printf
    xor %rax, %rax
    mov %bl, %al
    leaveq
    ret
