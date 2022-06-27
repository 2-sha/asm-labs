//                  a        d^2
// res = b * c + ------- - ------- + a * e
//                d + e     b * e

    .arch armv8-a
    .data
    .align  1
a:
    .short  8
b:
    .short  2
d:
    .short  2
    .align  2
c:
    .word   5
e:
    .word   2
    .align  3
res:
    .quad   0

    .text
    .align  2
    .global _start
    .type   _start, %function
_start:
    adr     x0, a
    ldrh   w1, [x0]
    adr     x0, b
    ldrh   w2, [x0]
    adr     x0, c
    ldr   x3, [x0]
    adr     x0, d
    ldrh   w4, [x0]
    adr     x0, e
    ldr   x5, [x0]

    cbz     w2, _error
    cbz     w5, _error

    umull   x6, w2, w3
    add     x7, x4, x5
    mul     w8, w4, w4
    umull   x9, w5, w2
    umull   x10, w1, w5

    cbz     x7, _error

    udiv    x11, x1, x7
    udiv    x12, x8, x9
    add     x13, x6, x11
    sub     x13, x13, x12
    add     x13, x13, x10

    adr     x0, res
    str     x14, [x0]

    mov     x0, #0
    b       _quit

_error:
    mov     x0, #22 // Invalid argument
_quit:
    mov     x8, #93
    svc     #0
    .size   _start, .-_start
