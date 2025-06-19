.data 
saludo: .asciiz "Hola Mundo!" # Delcarams la etiqueta saludo

.text 
main:
	la $a0 saludo # Leer la direccion ddonde se encuentra el saludo
	li $v0 4 # Imprimir en pantalla
	syscall # Llamado al sistema
	
	li $v0 10 # codigo de terminado
	syscall 