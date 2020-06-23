    .code16
    .text
    .global _boot
_boot:
    # Set video mode
    mov $0x0, %ah
    # 80x25
    mov $0x02, %al
    int $0x10
    # Write the char 'A'
    mov $0x0e, %ah
    mov $65, %al
    int $0x10
    # Set the background colour
    mov $0xb, %ah
    mov $0, %bh
    # 2 = green
    mov $2, %bl
    int $0x10
    # Print the message:
    mov $0x13, %ah
    mov $0x01, %al
    # The video page.
    xor %bh, %bh
    # The colour: 0x14 (1 = blue background, 4 = red text)
    mov $0x14, %bl
    # The message length
    mov msg_len, %cx
    # The row:
    mov $0x10, %dh
    # The column:
    mov $0x10, %dl
    # The address of the message is in ES:BP
    mov $msg, %bp
    int $0x10
    # Pause for 2s (0x1e8480 = 2 * 10^6 microseconds)
    mov $0x1e, %cx
    mov $0x8480, %dx
    mov $0x86, %ah
    int $0x15
    # Set video mode
    mov $0x4f02, %ax
    mov $0x0, %ah
    mov $0x13, %al
    int $0x10
    # Write a blue pixel
    mov $0xc, %ah
    mov $0, %bl
    # 1 = blue
    mov $1, %al
    # x-coordinate
    mov $0, %cx
    # y-coordinate
    mov $0, %dx
    int $0x10
    # Loop forever
loop:
    jmp .
msg:     .ascii "hello"
msg_len: .word (. - msg)
    # Pad the file with zeroes to make sure its size up to this point is 510b.
    .fill 510 - (. - _boot), 1, 0
    # The last word is the magic word.
    .byte 0x55, 0xAA
