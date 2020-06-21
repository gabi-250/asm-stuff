    .section .rodata
input_words:   .asciz "words.txt"
read_mode:     .asciz "r"
format_letter: .asciz "Letter: "
word_message:  .asciz "The word is: \n"
win_message:   .asciz "You win.\n"
format_int:    .asciz "%d"
format_char:   .asciz " %c"
format_char2:  .asciz "%c "
newline_str:   .asciz "\n"
clear_screen:  .asciz "\033[2J\033[H"
newline_char:  .byte '\n'
hidden_char:   .byte '_'
    .global main
    .text
main:
    push %rbp
    mov %rsp, %rbp
    sub $320, %rsp
    # read all the words from "words.txt"
    lea input_words(%rip), %rdi
    lea read_mode(%rip), %rsi
    callq fopen
    # store the file descriptor
    mov %rax, -8(%rbp)
    # keep track of the current line
    movq $0, -16(%rbp)
    # the target line (XXX pick a random line)
    movq $33, -24(%rbp)
    jmp .Lread_line
    leaveq
    ret
.Lread_line:
    # line_idx += 1
    add $1, -16(%rbp)
    # the address of the line read
    lea -152(%rbp), %rdi
    # the maxium line length
    mov $128, %rsi
    # the file descriptor
    mov -8(%rbp), %rdx
    callq fgets
    # check if fgets returned NULL
    test %rax, %rax
    je 1f
    # check if we've reached the target line
    mov -24(%rbp), %rax
    cmp -16(%rbp), %rax
    jne .Lread_line
1:
    # strip the newline
    lea -152(%rbp), %rdi
    mov newline_char(%rip), %rsi
    call strchr
    movb $0, (%rax)
    # keep track of the visible letters
    lea -152(%rbp), %rdi
    call strlen
    mov %rax, -174(%rbp)
    mov -174(%rbp), %rdi
    movl $1, %esi
    call calloc
    movq %rax, -182(%rbp)
    # make the first and last letter visible
    movb $1, (%rax)
    mov -174(%rbp), %rcx
    sub $1, %rcx
    movb $1, (%rax, %rcx, 1)
    # print the randomly selected word
.Lprint_word:
    lea clear_screen(%rip), %rdi
    call puts
    xor %rax, %rax
    lea word_message(%rip), %rdi
    call printf
    # print each char
    mov -174(%rbp), %r12
    # print the word again, but hide the middle chars
    mov $0, %r13
    mov $0, %r14b
1:
    cmp %r12, %r13
    jnl .Ldone
    mov -182(%rbp), %rax
    mov (%rax, %r13, 1), %rax
    test %al, %al
    je .Lprint_hidden
    jmp .Lprint_letter
.Lprint_hidden:
    mov $1, %r14b
    xor %rax, %rax
    lea format_char2(%rip), %rdi
    mov hidden_char(%rip), %rsi
    call printf
    jmp 2f
.Lprint_letter:
    xor %rax, %rax
    lea format_char2(%rip), %rdi
    mov -152(%rbp, %r13, 1), %rsi
    call printf
    jmp 2f
2:
    add $1, %r13
    jmp 1b
.Ldone:
    lea newline_str(%rip), %rdi
    call printf
    test %r14b, %r14b
    je .Lwin
    jmp .Lread_choice
.Lread_choice:
    # XXX free 8-byte integer
    lea -164(%rbp), %rsi
    lea format_letter(%rip), %rdi
    call printf
    lea format_char(%rip), %rdi
    lea -166(%rbp), %rsi
    xor %rax, %rax
    callq scanf
    mov -166(%rbp), %rbx
    # compare the choice with the actual char
    mov -174(%rbp), %r12
    mov $0, %r13
1:
    cmp %r12, %r13
    jnl 3f
    mov -152(%rbp, %r13, 1), %rax
    cmpb %al, %bl
    jne 2f
    mov -182(%rbp), %rax
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
