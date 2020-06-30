    .section .rodata
input_words:   .asciz "words.txt"
format_letter: .asciz "Letter: "
win_message:   .asciz "You win.\n"
format_int:    .asciz "%d"
format_char:   .asciz " %c"
    .global main
    .text
main:
    push %rbp
    mov %rsp, %rbp
    # XXX the stack size is actually 144, but we subtract 160 to keep it
    # 16-byte aligned
    sub $160, %rsp
    # read a line from "words.txt"
    lea input_words(%rip), %rdi
    # a pointer to where to store the line
    lea -128(%rbp), %rsi
    # the maximum line length
    mov $128, %rdx
    call read_rand_line
    # keep track of the visible letters
    lea -128(%rbp), %rdi
    call strlen
    mov %rax, -136(%rbp)
    mov -136(%rbp), %rdi
    movl $1, %esi
    call calloc
    movq %rax, -144(%rbp)
    # make the first and last letter visible
    movb $1, (%rax)
    mov -136(%rbp), %rcx
    sub $1, %rcx
    movb $1, (%rax, %rcx, 1)
    # print the randomly selected word
.Lprint_word:
    # the word to print
    lea -128(%rbp), %rdi
    # the word length
    mov -136(%rbp), %rsi
    # the visible letters
    mov -144(%rbp), %rdx
    call print_word
    test %al, %al
    je .Lwin
    jmp .Lread_choice
.Lread_choice:
    lea format_letter(%rip), %rdi
    call printf
    lea format_char(%rip), %rdi
    lea -145(%rbp), %rsi
    xor %rax, %rax
    callq scanf
    mov -145(%rbp), %rbx
    mov -136(%rbp), %r12
    mov $0, %r13
1:
    cmp %r12, %r13
    jnl 3f
    mov -128(%rbp, %r13, 1), %rax
    cmpb %al, %bl
    jne 2f
    mov -144(%rbp), %rax
    movb $1, (%rax, %r13, 1)
2:
    add $1, %r13
    jmp 1b
3:
    jmp .Lprint_word
.Lwin:
    lea win_message(%rip), %rdi
    call printf
    leaveq
    mov $0, %rax
    ret
