.data
	mensaje_lectura: .asciiz "Realizando medicion de tension arterial...\n"
	mensaje_sistolica: .asciiz "Tension sistolica: "
	mensaje_diastolica: .asciiz "\nTension diastolica: "

	TensionControl:		.word 0
	TensionEstado:		.word 0
	TensionSistol:		.word 0
	TensionDiastol:		.word 0

.text
.globl main

# Función principal
main:
    
    li $t0, 1
    sw $t0, TensionControl	# Damos el valor de iniciado a TensionControl
    
    jal controlador_tension

    # Guardar los valores de tension en memoria
    sw $v0, TensionSistol   
    sw $v1, TensionDiastol  
    
    # Imprimir tension sistolica
    li $v0, 4                  
    la $a0, mensaje_sistolica  
    syscall                     # Llamar al sistema para imprimir

    li $v0, 1                
    lw $a0, TensionSistol   
    syscall                     # Llamar al sistema para imprimir

    # Imprimir tension diastolica
    li $v0, 4                 
    la $a0, mensaje_diastolica 
    syscall                     # Llamar al sistema para imprimir

    li $v0, 1                 
    lw $a0, TensionDiastol  	
    syscall                     # Llamar al sistema para imprimir

    # Terminar el programa
    li $v0, 10                
    syscall                     


controlador_tension:

	# Imprimir mensaje de inicio
    li $v0, 4                  
    la $a0, mensaje_lectura    
    syscall                     # Llamar al sistema para imprimir
    
    li $v0, 42                 # C�digo para generar un numero aleatorio
    li $a1, 2                # L�mite superior para el numero
    syscall 
    
    sw $a0, TensionEstado	# Guarda el estado de lectura
    
    beq $a0, $zero, controlador_tension	# Vuelve a leer mientras no sea 1
    
    li $v0, 42                 
    li $a1, 81                # L�mite superior para el numero
    syscall                     # Generar n�mero aleatorio en $a0
    addi $t0, $a0, 120           # Mover el valor a $t0 (tension sistolica)

    li $v0, 42                 
    li $a1, 61                
    syscall                     # Generar numero aleatorio en $a0
    addi $v1, $a0, 60             # Mover el valor a $v1 (tension diastolica)
    move $v0, $t0		# Mover el valor a $v0 (tension sistolica)

    jr $ra                      # Regresar de la funcion
