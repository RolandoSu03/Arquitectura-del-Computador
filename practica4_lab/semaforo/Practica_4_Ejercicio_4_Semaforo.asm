.data
	display: .space 8  # Reservamos 8 bytes para la pantalla (2 píxeles de 32 bits cada uno)

	red:     	.word 0xFF0000    
	yellow: 	.word 0xFFFF00    
	green:    	.word 0x00FF00    

	t_red:     	.word 5        # Tiempo de 5 seg para rojo
	t_yellow: 	.word 2        # Tiempo de 5 seg para amarillo
	t_green:    	.word 5        # Tiempo de 2 seg para verde

.text
.globl main

main:
    j red_light  # Comienza el ciclo con la luz roja

	red_light:
   	li $t0, 0xFF0000       	# Color rojo
   	la $t3, display        	# Dirección base de la pantalla
    	lw $t1, t_red    	# Tiempo de espera para el color rojo
        jal paint     		# Pintar pantalla de rojo
	jal time_wait     	# Esperar el tiempo correspondiente para rojo
	j green_light    	# Cambiar al estado amarillo

	green_light:
    	li $t0, 0x00FF00       	# Color verde
    	la $t3, display        	# Dirección base de la pantalla
    	lw $t1, t_green   	# Tiempo de espera para el color verde
    	jal paint    		# Pintar pantalla de verde
    	jal time_wait    	# Esperar el tiempo correspondiente para verde
    	j yellow_light       	# Regresar al estado rojo
    
    	yellow_light:
    	li $t0, 0xFFFF00        # Color amarillo
    	la $t3, display         # Dirección base de la pantalla
    	lw $t1, t_yellow        # Tiempo de espera para el color amarillo
    	jal paint     		# Pintar pantalla de amarillo
    	jal time_wait     	# Esperar el tiempo correspondiente para amarillo
    	j red_light       	# Cambiar al estado verde

	paint:
    	li $t2, 4              # Número de píxeles a pintar (2 píxeles de 32 bits)
	paint_while:
    	beq $t2, $zero, exit_paint  # Si ya pintamos todos, salir
    	sw $t0, 0($t3)         # Guardar el color en la posición actual
    	addi $t3, $t3, 4       # Mover al siguiente píxel (4 bytes por píxel)
    	subi $t2, $t2, 1       # Reducir el contador
    	j paint_while          # Repetir el bucle

	exit_paint:
    	jr $ra                 # Regresar a la rutina principal

	time_wait:             # $t1 contiene el número de segundos a esperar
    	li $t2, 0              # Inicializar el contador de tiempo (en milisegundos)
    	li $t3, 1000           # 1000 milisegundos por segundo

	while:                 # Incrementar el contador de tiempo
    	addi $t2, $t2, 1       # Incrementar el contador
    	bge $t2, $t1, exit_while  # Si hemos esperado los segundos necesarios, salir
    	li $v0, 32             # Syscall 32 para esperar un segundo
    	li $a0, 1000           # 1000 milisegundos (1 segundo)
    	syscall                # Llamada al sistema para esperar 1 segundo
    	j while                # Repetir hasta cumplir el tiempo

	exit_while:
    	jr $ra                  # Regresar a la rutina principal
