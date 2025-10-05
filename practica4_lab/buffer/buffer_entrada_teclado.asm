.data
buffer: .space 256          # Buffer circular de 256 caracteres
msg: .asciiz "\nContenido del buffer:\n"

.text
.globl main

main:
    li $t0, 0               # Índice del buffer
    li $t1, 20              # Temporizador de 20 segundos (convertido a ciclos)
    li $t2, 0               # Contador de ciclos

input_loop:
    li $v0, 32              # Leer carácter sin mostrarlo
    syscall
    sb $a0, buffer($t0)     # Guardar carácter en buffer
    addi $t0, $t0, 1        # Mover al siguiente índice
    li $v0, 32              # Delay simulado
    syscall
    addi $t2, $t2, 1        # Incrementar contador de tiempo

    bge $t2, $t1, print_buffer
    j input_loop

print_buffer:
    li $v0, 4
    la $a0, msg
    syscall

    li $t0, 0               # Reiniciar índice
loop_print:
    lb $a0, buffer($t0)
    beqz $a0, reset         # Salta si el byte es nulo
    li $v0, 11              # Imprimir carácter
    syscall
    addi $t0, $t0, 1
    blt $t0, 256, loop_print

reset:
    li $t2, 0               # Reiniciar contador
    j main
