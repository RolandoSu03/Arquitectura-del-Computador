.data
	mensaje: .asciiz "Ingrese un numero: "

.text
main:
	li $v0, 4
	la $a0, mensaje
	syscall
	
	li $v0, 5
	syscall
	move $a0, $v0

	jal fib

	move $a0, $v0
	li $v0, 1
	syscall

	li $v0, 10
	syscall

fib:
	# Reservar espacio en la pila
	addi $sp, $sp, -12	
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	
	move $s0, $a0		# copiar $a0 en $s0
	li $t1, 1
	beq $s0, $zero, return0
	beq $s0, $t1, return1

	addi $a0, $s0, -1

	jal fib			# v0 = fib(n-1)

	move $s1, $v0		# $s1 = fib(n-1)
	addi $a0, $s0, -2

	jal fib			# v0 = fib(n-2)

	add $v0, $v0, $s1	# v0 = fib(n-2) + fib(n-1)
	
atras:
	# Restaurar la pila
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	addi $sp, $sp, 12
	jr $ra

return1:
 	li $v0, 1
 	j atras

return0:
	li $v0, 0
 	j atras
