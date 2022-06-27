.arch armv8-a
    MATRIX_ELEMENT_SIZE = 8
    MATRIX_ELEMENT_SIZE_SHIFT = 3

.data
calc_formula_message:
    .string "A^3 + B^3 - (A^2 - A*B + B^2) = \n"
msg_incor_inp:
    .string "Incorrect file format\n"
msg_file_error:
    .string "Unable to open file\n"
param_err_message:
    .string "No input filename specified\n\n"

fr_opt: 
    .string "r"
inp_ptrn_integer: 
    .string "%i"
inp_ptrn_double: 
    .string "%lf"
outp_ptrn_double: 
    .string "%f "
outp_ptrn_nl: 
    .string "\n"

.align 2
MATRIX_SIZE: 
    .word   0

.align 3
file_ptr: 
    .quad   0
A:  
    .fill   20 * 20 * MATRIX_ELEMENT_SIZE
B:  
    .fill   20 * 20 * MATRIX_ELEMENT_SIZE
C:  
    .fill   20 * 20 * MATRIX_ELEMENT_SIZE

.text
.align 2

.type open_file, %function
open_file:
    stp     x29, x30, [sp, #-16]!
    adr     x1, fr_opt
    bl      fopen
    cbnz    x0, 0f
    adr     x0, msg_file_error
    bl      printf
    ldp     x29, x30, [sp], #16
    b       exit
0:
    adr     x1, file_ptr
    str     x0, [x1]

    ldp     x29, x30, [sp], #16
    ret
.size   open_file, . - open_file

.type get_double, %function
get_double:
    stp     x29, x30, [sp, #-16]!
    mov     x2, x0
    b       1f
0:
    adr     x0, msg_incor_inp
    bl      printf

    ldp     x29, x30, [sp], #16
    b       exit
1:
    adr     x1, inp_ptrn_double 
    adr     x5, file_ptr
    ldr     x0, [x5]
    bl      fscanf

    cbz     x0, 0b

    ldp     x29, x30, [sp], #16
    ret
    .size get_double, . - get_double

.type get_int, %function
get_int:
    stp     x29, x30, [sp, #-16]!

    mov     x2, x0
    b       1f
0:
    adr     x0, msg_incor_inp
    bl      printf
    ldp     x29, x30, [sp], #16
    b       exit
1:
    adr     x1, inp_ptrn_integer
    adr     x5, file_ptr
    ldr     x0, [x5]
    bl      fscanf

    cbz     x0, 0b

    ldp     x29, x30, [sp], #16
    ret
    .size get_int, . - get_int

.type get_matrix, %function
get_matrix: 
    // x0 - адрес матрицы
    // x1 - размер матрицы
    stp     x30, x22, [sp, #-16]!   // x22 - размер матрицы
    stp     x20, x21, [sp, #-16]!   // x20, x21 - счётчики
    stp     x23, x24, [sp, #-16]!   // x23 - адрес матрицы, x24 - размер элементов матрицы

    mov     x22, #0
    mov     w22, w1
    mov     x23, x0
    mov     x24, MATRIX_ELEMENT_SIZE_SHIFT

    mov     x20, #0
0:
    cmp     x20, x22
    bge     9f
    mov     x21, #0
1:
    cmp     x21, x22
    bge     8f

    mul     x0, x20, x22
    add     x0, x0, x21
    lsl     x0, x0, x24
    add     x0, x0, x23
    bl      get_double

    add     x21, x21, #1
    b       1b
8:
    add     x20, x20, #1
    b       0b
9:

    ldp     x23, x24, [sp], #16
    ldp     x20, x21, [sp], #16
    ldp     x30, x22, [sp], #16
    ret
.size get_matrix, . - get_matrix

.type print_matrix, %function
print_matrix:   
    // x0 - указатель на место сохранения матрицы
    // w1 - размерность матрицы 
    stp     x30, x22, [sp, #-16]!   // x22 - размерность матрицы
    stp     x20, x21, [sp, #-16]!   // x20, x21 будут счётчики циклов
    stp     x23, xzr, [sp, #-16]!   // x23 - указатель на начало матрицы

    mov     x22, #0

    mov     w22, w1
    mov     x23, x0

    mov     x20, #0
0:
    cmp     x20, x22
    bge     9f  // while x20 < x22
    mov     x21, #0
1:
    cmp     x21, x22
    bge     8f  // while x21 < x22
    /*--- ВНУТРЕННЯЯ ЧАСТЬ ДВОЙНОГО ЦИКЛА ---*/

    adr     x0, outp_ptrn_double
    mul     x1, x20, x22
    add     x1, x1, x21
    ldr     d0, [x23, x1, lsl MATRIX_ELEMENT_SIZE_SHIFT]
    bl      printf

    /*--- ВНУТРЕННЯЯ ЧАСТЬ ДВОЙНОГО ЦИКЛА ---*/ 
    add     x21, x21, #1
    b       1b
8:
    adr     x0, outp_ptrn_nl
    bl      printf
    
    add     x20, x20, #1
    b       0b
9:

    ldp     x23, xzr, [sp], #16
    ldp     x20, x21, [sp], #16
    ldp     x30, x22, [sp], #16
    ret
.size print_matrix, . - print_matrix

.type add_matrix, %function
add_matrix: 
    // x0 - указатель на первую матрицу
    // x1 - указатель на вторую матрицу
    // x2 - указатель место заиси результата
    // x3 - размерность матриц
    stp     x30, xzr, [sp, #-16]!
    
    mov     x4, #0
    add     w4, w4, w3
    mov     x3, x4
    
    mov     x12, #0
    
    mov     x10, #0
0:
    cmp     x10, x3
    bge     9f  // while w10 < w3
    mov     x11, #0
1:
    cmp     x11, x3
    bge     8f  // while w11 < w3   
    /*--- ВНУТРЕННЯЯ ЧАСТЬ ДВОЙНОГО ЦИКЛА ---*/
    mul     x12, x10, x3
    add     x12, x12, x11
    ldr     d0, [x0, x12, lsl MATRIX_ELEMENT_SIZE_SHIFT]
    ldr     d1, [x1, x12, lsl MATRIX_ELEMENT_SIZE_SHIFT]
    
    fadd    d2, d0, d1
    
    str     d2, [x2, x12, lsl MATRIX_ELEMENT_SIZE_SHIFT]
    

    /*--- ВНУТРЕННЯЯ ЧАСТЬ ДВОЙНОГО ЦИКЛА ---*/ 
    add     w11, w11, #1
    b       1b
8:  
    add     w10, w10, #1
    b       0b
9:
    
    ldp     x30, xzr, [sp], #16
    ret
.size   add_matrix, . - add_matrix

.type sub_matrix, %function
sub_matrix: 
    // x0 - указатель на первую матрицу
    // x1 - указатель на вторую матрицу
    // x2 - указатель место заиси результата
    // w3 - размерность матриц
    stp     x30, xzr, [sp, #-16]!
    
    mov     x4, #0
    add     w4, w4, w3
    mov     x3, x4
    
    mov     x12, #0
    
    mov     x10, #0
0:
    cmp     x10, x3
    bge     9f  // while w10 < w3
    mov     x11, #0
1:
    cmp     x11, x3
    bge     8f  // while w11 < w3   
    /*--- ВНУТРЕННЯЯ ЧАСТЬ ДВОЙНОГО ЦИКЛА ---*/
    mul     x12, x10, x3
    add     x12, x12, x11
    ldr     d0, [x0, x12, lsl MATRIX_ELEMENT_SIZE_SHIFT]
    ldr     d1, [x1, x12, lsl MATRIX_ELEMENT_SIZE_SHIFT]
    
    fsub    d2, d0, d1
    
    str     d2, [x2, x12, lsl MATRIX_ELEMENT_SIZE_SHIFT]
    

    /*--- ВНУТРЕННЯЯ ЧАСТЬ ДВОЙНОГО ЦИКЛА ---*/ 
    add     w11, w11, #1
    b       1b
8:  
    add     w10, w10, #1
    b       0b
9:
    
    ldp     x30, xzr, [sp], #16
    ret
.size   sub_matrix, . - sub_matrix

.type mul_matrix, %function
mul_matrix: 
    // x0 - указатель на первую матрицу
    // x1 - указатель на вторую матрицу
    // x2 - указатель место заиси результата
    // w3 - размерность матриц
    stp     x30, xzr, [sp, #-16]!
    
    mov     x4, #0
    add     w4, w4, w3
    mov     x3, x4
    
    mov     x12, #0
    
    mov     x10, #0
0:
    cmp     x10, x3
    bge     9f  // while w10 < w3
    mov     x11, #0
1:
    cmp     x11, x3
    bge     8f  // while w11 < w3   
    /*--- ВНУТРЕННЯЯ ЧАСТЬ ДВОЙНОГО ЦИКЛА ---*/
    mov     x12, #0
    fmov    d2, xzr
2:
    cmp     x12, x3
    bge     7f
    /*--- ВНУТРЕННЯЯ ЧАСТЬ ТРОЙНОГО ЦИКЛА ---*/
    mul     x13, x10, x3
    add     x13, x13, x12
    
    mul     x14, x12, x3
    add     x14, x14, x11
    
    ldr     d0, [x0, x13, lsl MATRIX_ELEMENT_SIZE_SHIFT]
    ldr     d1, [x1, x14, lsl MATRIX_ELEMENT_SIZE_SHIFT]
    
    fmul    d3, d0, d1
    fadd    d2, d2, d3
    
    /*--- ВНУТРЕННЯЯ ЧАСТЬ ТРОЙНОГО ЦИКЛА ---*/
    add     x12, x12, #1
    b       2b
7:

    mul     x12, x10, x3
    add     x12, x12, x11
    
    str     d2, [x2, x12, lsl MATRIX_ELEMENT_SIZE_SHIFT]
    
    /*--- ВНУТРЕННЯЯ ЧАСТЬ ДВОЙНОГО ЦИКЛА ---*/ 
    add     w11, w11, #1
    b       1b
8:  
    add     w10, w10, #1
    b       0b
9:
    
    ldp     x30, xzr, [sp], #16
    ret
.size   mul_matrix, . - mul_matrix

.type calc_formula, %function
calc_formula:    
    // x0 - указатель на матрицу A
    // x1 - указатель на матрицу B
    // x2 - указатель для результурующей матрицы
    // w3 - размерность
    stp     x30, x29, [sp, #-16]!
    stp     x20, x21, [sp, #-16]!
    stp     x22, x23, [sp, #-16]!
    stp     x24, x25, [sp, #-16]!
    stp     x26, xzr, [sp, #-16]!
    
    mov     x29, sp
    // хранение промежуточных результатов будет производится на стеке. Стек всегда выравнен на 3, так что следить за этим не придётся.
    mov     x4, #0
    add     w4, w4, w3
    mov     w3, w4  
    
    mov     x20, x0
    mov     x21, x1
    mov     x22, x2
    mov     x23, x3
    
    mov     x4, MATRIX_ELEMENT_SIZE
    mul     x24, x3, x3
    mul     x24, x24, x4    //  в x24 лежит размер одной матрицы (в байтах). Для удобства навигации по стеку
    
    mov     x5, #4
    mul     x5, x5, x24
    sub     sp, sp, x5  // в процессе работы будут созданы 4 матриц. Выделяю под них место на стеке
    
    mov     x26, x29
    
    // A^3 + B^3 - (A^2 - A*B + B^2) = A^3 + B^3 - (A-B)^2 - B*A

    // [sp-mt] = A^2
    sub     x26, x26, x24
    mov     x0, x20
    mov     x1, x20
    mov     x2, x26
    mov     w3, w23
    bl      mul_matrix
    
    // [sp-2*mt] = A^3
    mov     x0, x20
    mov     x1, x26
    sub     x26, x26, x24
    mov     x2, x26
    mov     w3, w23
    bl      mul_matrix
    
    // [sp-3*mt] = B^2
    sub     x26, x26, x24
    mov     x0, x21
    mov     x1, x21
    mov     x2, x26
    mov     w3, w23
    bl      mul_matrix
    
    // [sp-mt] = B^3 (A^2 не нужен, можем его затереть)
    mov     x0, x21
    mov     x1, x26
    sub     x2, x29, x24
    mov     w3, w23
    bl      mul_matrix

    mov     x25, x26 // сейчас sp указывает на B^2
    
    // [sp-4*mt] = A-B
    sub     x26, x26, x24
    mov     x0, x20
    mov     x1, x21
    mov     x2, x26
    mov     w3, w23
    bl      sub_matrix
    
    mov     x26, x25
    
    // [sp-3*mt] = (A-B)^2
    sub     x0, x26, x24
    mov     x1, x0
    mov     x2, x26
    mov     w3, w23
    bl      mul_matrix
    
    // [sp-4*mt] = B*A
    mov     x0, x21
    mov     x1, x20
    sub     x2, x26, x24
    mov     w3, w23
    bl      mul_matrix
    
    mov     x26, x29
    
    // C = A^3 + B^3
    sub     x26, x26, x24
    mov     x1, x26
    sub     x26, x26, x24
    mov     x0, x26
    mov     x2, x22
    mov     w3, w23
    bl      add_matrix
    
    // C = C - (A-B)^2
    sub     x26, x26, x24
    mov     x0, x22
    mov     x1, x26
    mov     x2, x22
    mov     w3, w23
    bl sub_matrix

    // C = C - A*B
    sub     x26, x26, x24
    mov     x0, x22
    mov     x1, x26
    mov     x2, x22
    mov     w3, w23
    bl sub_matrix

    mov     sp, x29
    ldp     x26, xzr, [sp], #16
    ldp     x24, x25, [sp], #16
    ldp     x22, x23, [sp], #16
    ldp     x20, x21, [sp], #16
    ldp     x30, x29, [sp], #16
    ret
.size calc_formula, . - calc_formula

.global main
.type   main, %function
main:
    stp     x30, x29, [sp, #-16]!
    stp     x20, xzr, [sp, #-16]!
    mov     x29, sp

    cmp     w0, #2
    beq     0f
    adr     x0, param_err_message
    bl      printf
    b       exit

0:
    ldr     x0, [x1, #8]
    bl      open_file
    
    adr     x0, MATRIX_SIZE
    bl      get_int

    adr     x0, MATRIX_SIZE
    mov     x1, #0
    ldrb    w1, [x0]

    cmp     w1, wzr
    bgt     2f
1:
    adr     x0, msg_incor_inp
    bl      printf
    b       exit
2:
    cmp     w1, #20
    bgt     1b
    mov     x20, x1

    adr     x0, A
    mov     w1, w20
    bl      get_matrix

    adr     x0, B
    mov     w1, w20
    bl      get_matrix

    adr     x0, A
    adr     x1, B
    adr     x2, C
    mov     w3, w20
    bl      calc_formula

    adr     x0, calc_formula_message
    bl      printf

    adr     x0, C
    mov     w1, w20
    bl      print_matrix

exit:
    mov     sp, x29
    mov     x0, #0
    ldp     x20, xzr, [sp], #16
    ldp     x30, x29, [sp], #16
    ret
.size   main, . - main
