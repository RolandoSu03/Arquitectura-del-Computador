.data
    display: .space 8

    msg_verde_consola:    .asciiz "Semáforo en VERDE. Esperando 10 segundos...\n"
    msg_amarillo_consola: .asciiz "Semáforo en AMARILLO: en 10 segundos cambiará a ROJO.\n"
    msg_rojo_consola:     .asciiz "Semáforo en ROJO: en 30 segundos cambiará a VERDE.\n"

    estado_semaforo: .word 0
    timer_countdown: .word 0
    tick_duration: .word 1000

.text
.globl main

main:
    li $s0, 0                     # VERDE
    sw $s0, estado_semaforo
    li $t0, 10                    # 10 segundos para VERDE
    sw $t0, timer_countdown

    j display_current_state

semaforo_loop:
    lw $a0, tick_duration
    li $v0, 32
    syscall

    j handle_state_timer

handle_state_timer:
    lw $t0, estado_semaforo
    lw $t1, timer_countdown
    bne $t1, $zero, decrement_and_loop

    beq $t0, 0, transition_verde_amarillo
    beq $t0, 1, transition_amarillo_rojo
    beq $t0, 2, transition_rojo_verde

    j semaforo_loop

decrement_and_loop:
    addi $t1, $t1, -1
    sw $t1, timer_countdown
    j semaforo_loop

transition_verde_amarillo:
    li $s0, 1
    sw $s0, estado_semaforo
    li $t0, 10
    sw $t0, timer_countdown
    j display_current_state

transition_amarillo_rojo:
    li $s0, 2
    sw $s0, estado_semaforo
    li $t0, 30
    sw $t0, timer_countdown
    j display_current_state

transition_rojo_verde:
    li $s0, 0
    sw $s0, estado_semaforo
    li $t0, 10
    sw $t0, timer_countdown
    j display_current_state

display_current_state:
    li $v0, 4
    lw $t0, estado_semaforo
    beq $t0, 0, do_green_display
    beq $t0, 1, do_yellow_display
    beq $t0, 2, do_red_display
    j semaforo_loop

do_green_display:
    li $a0, 0x00FF00
    jal paint
    la $a0, msg_verde_consola
    li $v0, 4
    syscall
    j semaforo_loop

do_yellow_display:
    li $a0, 0xFFFF00
    jal paint
    la $a0, msg_amarillo_consola
    li $v0, 4
    syscall
    j semaforo_loop

do_red_display:
    li $a0, 0xFF0000
    jal paint
    la $a0, msg_rojo_consola
    li $v0, 4
    syscall
    j semaforo_loop

paint:
    la $t2, display
    move $t0, $a0
    li $t1, 2

paint_loop:
    beq $t1, $zero, exit_paint
    sw $t0, 0($t2)
    addi $t2, $t2, 4
    subi $t1, $t1, 1
    j paint_loop

exit_paint:
    jr $ra
