.data
	SensorDatos: 		.word 0			# Se reserva el valor para el valor de temperatura
	SensorControl: 		.word 0			# Registro para el control
	SensorEstado: 		.word 0			# Registro de estado 
	msg: 			.asciiz "Valor de Temperatura: "
	msg2:			.asciiz "Estado: "
	msg3:			.asciiz "Error: "
	sl: 			.asciiz "\n"
.text

	main:				
	jal InicializarSensor				# Inicializa el sensor
	jal LeerTemperatura				# Lee la temperatura
	
	end: 
	li $v0, 10
	syscall
	
	InicializarSensor:				# Funcion inicializar sensor	
	li $t1, 0x2					# Se carga valor 0x2 en $t1
	sw $t1, SensorControl				# Se inicializa el registro de control 
	
	li $v0, 42					# Funciona mediante un numero random
	li $a1, 2					# Tiene un rango de 0 o 1
	syscall						# Dependiendo del valor el sensor se activa o no
	sw $a0, SensorEstado				# Guarda el valor en la memoria, dando el comando 
	jr $ra						# Devuelve el valor 
	
	LeerTemperatura:
	lw $t1, SensorEstado				# Carga el valor del estado en $t1
	beqz $t1, error					# Pregunta si el valor es igual a 0, si es igual a 0 entonces esta apagado
							# Sino continua
	li $v0, 42					# Codigo para numero random
	li $a1, 201					# Valor maximo 200
	syscall						# Genera numero aleatorio y coloca en $a0
	addi $t1, $a0, -100				# $a0 tendr� un valor entre -100 y 100 grados
	sw $t1, SensorDatos				# Se guarda el valor de la temperatura en el registro de memoria
	
	li $v0, 4					# Rutina de mostrar en pantalla los valores y mensajes
	la $a0, msg
	syscall
	move $a0, $t1
	li $v0, 1
	syscall
	li $v0, 4
	la $a0, sl
	syscall
	li $v0, 4
	la $a0, msg2
	syscall
	li $v0, 1
	li $a0, 0				# Imprime 0 porque leyo correctamente
	syscall
	
	jr $ra					# Sale de la funci�n
	
	error:					# Imprime mensaje de error
	li $v0,4
	la $a0, msg3
	syscall
	li $v0, 4
	la $a0, sl
	syscall
	li $v0,4
	la $a0, msg2
	syscall
	li $v0,1
	li $a0, -1
	syscall
	
	j end
	


