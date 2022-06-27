    .arch armv8-a
    .data
buffer:
    .skip   128
space_ch:
    .string " "
l_break_ch:
    .string "\n"
no_file_message:
    .string "No filename specified\n"
buffer_overflow_message:
    .string "Buffer size exceeded\n"

    .text
    .align  2
    .global _start
    .type   _start, %function
_start:
    // x16 - buffer size
    // x17 - buffer address
    // x18 - file descriptor
    // x19 - word moved from prev buffer size
    mov     x16, #6
    adr     x17, buffer
    mov     w19, #0

    ldrb    w0, [sp]
    cmp     x0, #2
    blt     no_file_error
    ldr     x1, [sp, #16]

    mov     x0, #-100
    mov     x2, #577
    mov     x3, #0600
    mov     x8, #56
    svc     #0
    mov     x18, x0
    // str     x0, [x18]
    // TODO: handle file errors

enter_loop:
    // x29 - readed chars num

    // Correct buffer offset and len according to x19 
    add     x21, x17, x19
    sub     x22, x16, x19

    mov     x0, #0 // written bytes len
    mov     x1, x21 // buffer to write
    mov     x2, x22 // buffer len
    mov     x8, #63 // read from std::in
    svc     #0
    mov     x29, x0
    add     x29, x29, x19

    cbz     x29, end_enter_loop

    mov     w23, #0
    mov     x21, #0
buffer_iteration:
    // x11 - is_word_ended
    // x21 - counter (i)
    // x22 - current letter
    // x23 - last space index
    // x13 - last space num (for moving to the next buffer)
    cmp     x21, x29
    bge     end_buffer_iteration

    mov     w11, #0
    ldrb    w22, [x17, x21]
    cmp     w22, #32 // space
    beq     process_word
    cmp     w22, #9 // \t
    beq     process_word
    cmp     w22, #10 // \n
    beq     process_word
    b       end_process_word

process_word:
    // x24 - counter (j)
    // x25 - (space + i) // 2
    mov     w11, #1
    mov     w24, #0 // j
    sub     w25, w21, w23
    mov     w26, #2
    udiv    w25, w25, w26
change_letters:
    cmp     w24, w25
    bge     change_letters_end
    add     w26, w24, w23 // space + j
    sub     w27, w21, w24
    sub     w27, w27, #1 // i - j - 1
    ldrb    w28, [x17, x26] // s[space + j]
    ldrb    w10, [x17, x27] // s[i - j - 1]
    strb    w28, [x17, x27]
    strb    w10, [x17, x26]
    add     w24, w24, #1
    b       change_letters
change_letters_end:
    
    // write word
    mov     x0, x18
    add     x1, x17, x23
    sub     x2, x21, x23
    cbz     x2, 0f
    add     x2, x2, #1
    mov     x8, #64
    svc     #0
0:

    mov     w13, w21 // save for write_word_buf_loop
    add     w23, w21, #1
end_process_word:

    add     x21, x21, #1
    b       buffer_iteration
end_buffer_iteration:

    mov     x19, #0
    cbnz    w11, word_ended // if word doesn't go beyond buffer
    sub     w19, w16, w23
    // If there are no spaces in buffer and eaded chars exceed buffer size - it's overflow
    cmp     w19, w16
    beq     no_spaces
no_spaces_ok:
    mov     w12, #0
write_word_buf_loop:
    // x12 - counter
    // x19 - remained word len
    cmp     w12, w19
    bge     end_write_word_buf_loop
    add     w14, w13, w12
    add     w14, w14, #1
    ldrb    w14, [x17, x14]
    strb    w14, [x17, x12]
    add     w12, w12, #1
    b       write_word_buf_loop
no_spaces:
    // If readed chars exceed buffer size - it's overflow
    // Otherwise - user pressed ctrl+d
    cmp     w19, w29
    beq     buffer_overflow_error
    b       no_spaces_ok
word_ended:
    
end_write_word_buf_loop:

    b       enter_loop
end_enter_loop:

    mov     x0, #0
    b       exit

no_file_error:
    adr     x1, no_file_message
    mov     x2, #24
    b       error_message

buffer_overflow_error:
    adr     x1, buffer_overflow_message
    mov     x2, #23
    b       error_message

error_message:
    mov     x0, #1
    mov     x8, #64
    svc     #0

exit:
    // close 
    mov     x0, x18
    mov     x8, #57
    svc     #0

    mov     x8, #93
    svc     #0
    .size   _start, .-_start
