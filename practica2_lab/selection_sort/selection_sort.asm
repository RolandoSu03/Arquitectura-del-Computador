.data
array:      .word 64, 25, 12, 22, 111, 34   # Arreglo de ejemplo
size:       .word 6                    # Tama�o del arreglo
newline:    .asciiz "\n"

.text
.globl main

main:
    # Cargar tama�o del arreglo en $a0
    la $t0, size
    lw $a0, 0($t0)

    # Llamar a selection_sort
    jal selection_sort

    # Imprimir arreglo ordenado
    la $s0, array
    lw $t1, size         # t1 = tama�o
    li $t2, 0            # i = 0

print:                   # Imprimir el arreglo ordenado al final del proceso
    move $a0, $s0
    bge $t2, $t1, end_print

    sll $t3, $t2, 2      # $t3 = i * 4
    add $t4, $a0, $t3    # direcci�n de array[i]
    lw $a1, 0($t4)       # cargar valor de array[i] en $a1

    li $v0, 1            # syscall: print_int
    move $a0, $a1
    syscall

    li $v0, 4            # syscall: print_string
    la $a0, newline
    syscall

    addi $t2, $t2, 1     # i++
    j print

end_print:
    li $v0, 10           # syscall: exit
    syscall

selection_sort:
    li $t0, 0              # i = 0

outer_loop:		   # Busca el elemento menor y lo coloca al principio del arreglo
    bge $t0, $a0, end_sort
    move $t1, $t0          # min_idx = i
    addi $t2, $t0, 1       # j = i + 1

inner_loop:
    bge $t2, $a0, swap

    la $t7, array
    sll $t4, $t2, 2	  # $t4 = j * 4
    add $t4, $t4, $t7
    lw $t3, 0($t4)         # array[j]

    sll $t6, $t1, 2
    add $t6, $t6, $t7
    lw $t5, 0($t6)         # array[min_idx]

    bge $t3, $t5, skip_min
    move $t1, $t2          # min_idx = j

skip_min:
    addi $t2, $t2, 1
    j inner_loop

swap:
    beq $t1, $t0, skip_swap

    la $t7, array
    sll $t4, $t0, 2	   # $t4 = i * 4
    add $t4, $t4, $t7
    lw $t3, 0($t4)         # array[i]

    sll $t6, $t1, 2       # $t6 = min_idx * 4
    add $t6, $t6, $t7
    lw $t5, 0($t6)         # array[min_idx]

    sw $t5, 0($t4)         # array[i] = array[min_idx]
    sw $t3, 0($t6)         # array[min_idx] = array[i]

skip_swap:
    addi $t0, $t0, 1
    j outer_loop

end_sort:
    jr $ra
