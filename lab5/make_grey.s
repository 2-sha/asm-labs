    .arch armv8-a
    .align  2

    .global _make_grey
    .type   _make_grey, %function
_make_grey:
    // x0 - указатель на пиксели
    // x1 - кол-во пикселей
    // x2 - color block height
    // x3 - row width
    stp     x29, x30, [sp, #-16]!
    stp     x27, x28, [sp, #-16]!

    // x10 - width * 3
    mov     x10, #3
    mul     x10, x3, x10

    mov     x11, #0
    mov     x12, #0
    mov     x13, #0
    // x11 - текущий цвет блока
    // x12 - счётчик строк в блоке
    // x13 - счётчик цикла по строкам
rows_loop:
    cmp     x13, x1
    bge     rows_loop_end

    // x14 - счётчик цикла по строке
    mov     x14, #0
columns_loop:
    cmp     x14, x10
    bge     columns_loop_end

    // x15 - адрес первого пикселя
    // x16 - синий
    // x17 - зелёный
    // x18 - красный
    add     x15, x0, x13
    add     x15, x15, x14
    ldrb    w16, [x15]
    ldrb    w17, [x15, #1]
    ldrb    w18, [x15, #2]

    // Считаем минимальный элемент
    // x8 - минимальный элемент
    mov     w8, #255
    cmp     w16, w8
    bgt     0f
    mov     w8, w16
0:
    cmp     w17, w8
    bgt     0f
    mov     w8, w17
0:
    cmp     w18, w8
    bgt     0f
    mov     w8, w18
0:

    strb    wzr, [x15]
    strb    wzr, [x15, #1]
    strb    wzr, [x15, #2]
    strb    w8, [x15, x11]    

    add     x14, x14, #3
    b       columns_loop
columns_loop_end:

    add     x12, x12, #1
    cmp     x12, x2
    ble     0f

    mov     x12, #0
    add     x11, x11, #1
    cmp     x11, #2
    ble     0f
    mov     x11, #0
0:

    add     x13, x13, x10
    b       rows_loop
rows_loop_end:

    ldp     x27, x28, [sp], #16
    ldp     x29, x30, [sp], #16
    ret
    .size   _make_grey, .-_make_grey
