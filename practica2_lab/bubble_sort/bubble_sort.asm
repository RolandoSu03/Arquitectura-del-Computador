.data
    arreglo: .word 52, 21, 8, 11, 99, 2   # Arreglo de ejemplo con 5 elementos
    tamano: .word 6               # Tamaño del arreglo
    
    # Mensajes para imprimir en pantalla
    msg_ordenado: .asciiz "Arreglo ordenado: \n" # Mensaje de arreglo ordenado con salto de línea inicial
    nueva_linea: .asciiz "\n"                    # Salto de línea para cada elemento

.text
.globl main

main:
    # Cargar la dirección base del arreglo
    la $t0, arreglo         
    # Cargar el tamaño del arreglo
    lw $t1, tamano         
    
    # Bucle externo (i)
    # $t2 = i
    li $t2, 0               # i = 0
    subi $t3, $t1, 1        # $t3 = tamaño - 1

bucle_externo:
    bge $t2, $t3, fin_bucle_externo  # Si i >= tamaño - 1, salir del bucle externo

    # Bucle interno (j)
    # $t4 = j
    li $t4, 0               # j = 0
    sub $t5, $t1, $t2       # $t5 = tamaño - i
    subi $t5, $t5, 1        # $t5 = tamaño - i - 1 (límite para el bucle interno)

bucle_interno:
    bge $t4, $t5, fin_bucle_interno  # Si j >= tamaño - i - 1, salir del bucle interno

    # Calcular la dirección de arreglo[j]
    mul $t6, $t4, 4         # j * 4 (porque cada palabra es de 4 bytes)
    add $t6, $t0, $t6       # Dirección de arreglo[j]

    # Cargar arreglo[j]
    lw $s0, ($t6)           # $s0 = arreglo[j]

    # Calcular la dirección de arreglo[j+1]
    addi $t7, $t6, 4        # Dirección de arreglo[j+1]

    # Cargar arreglo[j+1]
    lw $s1, ($t7)           # $s1 = arreglo[j+1]

    # Comparar arreglo[j] y arreglo[j+1]
    ble $s0, $s1, no_intercambiar  # Si arreglo[j] <= arreglo[j+1], no intercambiar

    # Intercambiar
    sw $s1, ($t6)           # arreglo[j] = $s1 (arreglo[j+1])
    sw $s0, ($t7)           # arreglo[j+1] = $s0 (arreglo[j])

no_intercambiar:
    addi $t4, $t4, 1        # j++
    j bucle_interno         # Volver al inicio del bucle interno

fin_bucle_interno:
    addi $t2, $t2, 1        # i++
    j bucle_externo         # Volver al inicio del bucle externo

fin_bucle_externo:
    # Imprimir el arreglo ordenado
    la $a0, msg_ordenado     # Cargar la dirección del mensaje "Arreglo ordenado: "
    li $v0, 4                # Servicio para imprimir string
    syscall                  # Llamar al sistema

    jal imprimir_arreglo     # Llamar a la función para imprimir el arreglo ordenado

    # Terminar el programa
    li $v0, 10               # Servicio para salir del programa
    syscall                  # Llamar al sistema

imprimir_arreglo:
    # Guardar registros que la función modificará
    addi $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s0, 4($sp)
    sw $s1, 0($sp)

    la $s0, arreglo          # $s0 = dirección base del arreglo
    lw $s1, tamano           # $s1 = tamaño del arreglo

    li $t0, 0                # $t0 = contador del bucle (índice i)

bucle_imprimir:
    bge $t0, $s1, fin_imprimir_bucle # Si i >= tamaño, salir del bucle de impresión

    # Calcular la dirección del elemento actual
    mul $t1, $t0, 4          # i * 4
    add $t1, $s0, $t1        # Dirección de arreglo[i]

    lw $a0, ($t1)            # Cargar el valor del elemento en $a0
    li $v0, 1                # Servicio para imprimir entero
    syscall               

    la $a0, nueva_linea      # Cargar nueva línea
    li $v0, 4                # Servicio para imprimir string
    syscall                  # Llamar al sistema

    addi $t0, $t0, 1         # i++
    j bucle_imprimir         # Volver al inicio del bucle de impresión

fin_imprimir_bucle:
    # Restaurar registros
    lw $ra, 8($sp)
    lw $s0, 4($sp)
    lw $s1, 0($sp)
    addi $sp, $sp, 12
    jr $ra                   # Volver al llamador
