	.rodata:
input_words:   .asciz "words.txt"
read_mode:     .asciz "r"
format_index:  .asciz "Index: "
format_letter: .asciz "Letter: "
format_int:    .asciz "%d"
format_char:   .asciz " %c"
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
	jmp .Lread_line
	leaveq
	ret

.Lread_line:
	# the address where to put the line read
	lea -136(%rbp), %rdi
	# the maxium line length
	mov $128, %rsi
	# the file descriptor
	mov -8(%rbp), %rdx
	callq fgets
	mov %rax, -144(%rbp)
	lea -136(%rbp), %rdi
	call puts
	mov -144(%rbp), %rax
	# check if fgets returned NULL
	test %rax, %rax
	jne .Lread_line
	jmp .Lread_choice

.Lread_choice:
	lea format_index(%rip), %rdi
	call printf
	lea format_int(%rip), %rdi
	lea -148(%rbp), %rsi
	xor %rax, %rax
	call scanf
	lea format_letter(%rip), %rdi
	call printf
	lea format_char(%rip), %rdi
	lea -149(%rbp), %rsi
	xor %rax, %rax
	callq scanf
	jmp .Lread_choice
