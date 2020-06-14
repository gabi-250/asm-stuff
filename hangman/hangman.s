    .rodata:
input_words:   .asciz "words.txt"
read_mode:     .asciz "r"
format_index:  .asciz "Index: "
format_letter: .asciz "Letter: "
word_message:  .asciz "Word is: \n"
format_int:    .asciz "%d"
format_char:   .asciz " %c"
format_char2:  .asciz "%c "
newline_str:   .asciz "\n"
newline_char:  .byte '\n'
hidden_char:   .byte '_'
    .globl main
    .text

main:
    push %rbp
    mov %rsp, %rbp
    sub $256, %rsp
    # read all the words from "words.txt"
    lea input_words(%rip), %rdi
    lea read_mode(%rip), %rsi
    callq fopen
    # store the file descriptor
    mov %rax, -8(%rbp)
    # keep track of the current line
    movq $0, -16(%rbp)
    # the target line
    movq $31, -24(%rbp)
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
    # print the randomly selected word
.Lprint_word:
    xor %rax, %rax
    lea word_message(%rip), %rdi
    call printf
    # print each char
    lea -152(%rbp), %rdi
    call strlen
    mov %rax, %r12
    mov $0, %r13
1:
    xor %rax, %rax
    mov -152(%rbp, %r13, 1), %rsi
    lea format_char2(%rip), %rdi
    call printf
    add $1, %r13
    cmp %r12, %r13
    jne 1b
    lea newline_str(%rip), %rdi
    call printf
    # print the word again, but hide the middle chars
    mov $2, %r13
    xor %rax, %rax
    mov -152(%rbp), %rsi
    lea format_char2(%rip), %rdi
    call printf
1:  add $1, %r13
    mov hidden_char(%rip), %rsi
    lea format_char2(%rip), %rdi
    call printf
    cmp %r12, %r13
    jne 1b
    sub $1, %r13
    # now print the last char:
    mov -152(%rbp, %r13, 1), %rsi
    lea format_char2(%rip), %rdi
    call printf

    lea newline_str(%rip), %rdi
    call printf
    jmp .Lread_choice
.Lread_choice:
    lea format_index(%rip), %rdi
    call printf
    lea format_int(%rip), %rdi
    lea -164(%rbp), %rsi
    xor %rax, %rax
    call scanf
    lea format_letter(%rip), %rdi
    call printf
    lea format_char(%rip), %rdi
    lea -166(%rbp), %rsi
    xor %rax, %rax
    callq scanf
    jmp .Lprint_word
