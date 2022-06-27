	.arch armv8-a
    .data
n:
    .byte   6
m:
    .byte   7 // rows num
matrix:
    .byte   3, 2, 1, 1, 1, 2
    .byte   0, 1, 2, 0, 0, 2
    .byte   3, 2, 0, 0, 1, 3
    .byte   1, 1, 1, 1, 1, 6
    .byte   0, 0, 2, 0, 0, 5
    .byte   9, 8, 7, 6, 5, 4
    .byte   -1, -1, -1, -1, -1, -1
sums:
    .skip   7
tmp_matrix:
    .skip   42
m_ptrs:
    .skip   7

    .text
    .align  2
    .global _start
    .type	_start, %function
_start:
    adr     x1, matrix
    adr     x2, sums
    adr     x0, n
    ldrb    w3, [x0]
    adr     x0, m
    ldrb    w4, [x0]
    adr     x20, m_ptrs
    adr     x21, tmp_matrix

    // Calc rows sums
    mov     w5, #0
rows_loop:
    cmp     w5, w4
    bge     end_rows_loop
    str     w5, [x20, x5]
    mov     w6, #0
    mov     w7, #0 // sum var
    madd    x8, x5, x3, x1 // matrix row addr
    madd    x9, x5, x3, x21 // tmp_matrix row addr
columns_loop:
    cmp     w6, w3
    bge     end_columns_loop
    ldrsb   w0, [x8, x6]
    strb    w0, [x9, x6] // fill tmp matrix
    add     w6, w6, #1
    add     w7, w7, w0
    b       columns_loop
end_columns_loop:
    strb    w7, [x2, x5]
    add     w5, w5, #1
    b       rows_loop
end_rows_loop:

    // Sort rows
    mov     w5, #1
sort_loop:
    cmp     w5, w4
    bge     end_sort_loop
    ldrsb   w6, [x2, x5]
    mov     w7, #0
    mov     w8, w5
bin_search_loop:
    cmp     w7, w8
    bge     end_bin_search_loop
    add     w9, w7, w8
    mov     x0, #2
    udiv    w9, w9, w0
    ldrsb   w10, [x2, x9]
    cmp     w6, w10
.ifdef reverse
    bge     mov_h_bound
.else
    ble     mov_h_bound
.endif
    add     w7, w9, #1
    b       bin_search_loop
mov_h_bound:
    mov     w8, w9
    b       bin_search_loop
end_bin_search_loop:
    sub     w8, w5, #1
move_loop:
    cmp     w8, w7
     blt     end_move_loop
    // Moving max array
    ldrsb   w9, [x2, x8]
    add     x0, x8, #1
    ldrsb   w10, [x2, x0]
    strb    w9, [x2, x0]
    strb    w10, [x2, x8]
    // Moving matrix ptrs
    ldrb    w9, [x20, x8]
    ldrb    w10, [x20, x0]
    strb    w9, [x20, x0]
    strb    w10, [x20, x8]
    mov     w9, #0
m_rows_loop:
    cmp     w9, w3
    bge     end_m_rows_loop
    add     w9, w9, #1
end_m_rows_loop:
    sub     w8, w8, #1
    b       move_loop
end_move_loop:
    add     w5, w5, #1
    b       sort_loop
end_sort_loop:

    mov     w5, #0
aplly_changes_loop:
    cmp     w5, w4
    bge     end_apply_changes_loop
    ldrb    w6, [x20, x5]
    mov     w7, #0
apply_row_loop:
    cmp     w7, w3
    bge     end_apply_row_loop
    madd    w8, w6, w3, w7
    madd    w9, w5, w3, w7
    ldrsb   w0, [x21, x8]
    strb    w0, [x1, x9]
    add     w7, w7, #1
    b       apply_row_loop
end_apply_row_loop:
    add     w5, w5, #1
    b aplly_changes_loop
end_apply_changes_loop:

    mov     x0, #0
    mov     x8, #93
    svc     #0
    .size   _start, .-_start
