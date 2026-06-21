
.data
angulosAndar:       .word 0, 60, 120, 180
chamadas1:          .word 0, 0, 0, 0
andarAtual1:        .word 0
direcao1:           .word 0
anguloServo1:       .word 0
estado1:            .word 0
portaTimer1:        .word 0
servoTimer1:        .word 0
chamadas2:          .word 0, 0, 0, 0
andarAtual2:        .word 0
direcao2:           .word 0
anguloServo2:       .word 0
estado2:            .word 0
portaTimer2:        .word 0
servoTimer2:        .word 0
timestampGlobal:    .word 0
msg_inicio:         .asciiz "\n====== SISTEMA DE ELEVADORES DUPLOS ======\n"
msg_inicio2:        .asciiz "COMANDOS:\n"
msg_inicio3:        .asciiz "  [1-4] - Chamada corredor\n"
msg_inicio4:        .asciiz "  [Q,W,E,R] - Cabine 1 (Andares 1-4)\n"
msg_inicio5:        .asciiz "  [A,S,D,F] - Cabine 2 (Andares 1-4)\n"
msg_inicio6:        .asciiz "========================================\n\n"
msg_cabine1_porta:  .asciiz "[CABINE 1] Porta ABERTA no andar "
msg_cabine1_fecha:  .asciiz "[CABINE 1] Porta FECHADA\n"
msg_cabine1_sobe:   .asciiz "[CABINE 1] SUBINDO... (Andar "
msg_cabine1_desce:  .asciiz "[CABINE 1] DESCENDO... (Andar "
msg_cabine1_parou:  .asciiz "[CABINE 1] Parou no andar "
msg_cabine1_chamada:.asciiz "[CABINE 1] Chamada interna p/ andar "
msg_cabine1_atual:  .asciiz " | Andar atual: "
msg_cabine2_porta:  .asciiz "[CABINE 2] Porta ABERTA no andar "
msg_cabine2_fecha:  .asciiz "[CABINE 2] Porta FECHADA\n"
msg_cabine2_sobe:   .asciiz "[CABINE 2] SUBINDO... (Andar "
msg_cabine2_desce:  .asciiz "[CABINE 2] DESCENDO... (Andar "
msg_cabine2_parou:  .asciiz "[CABINE 2] Parou no andar "
msg_cabine2_chamada:.asciiz "[CABINE 2] Chamada interna p/ andar "
msg_cabine2_atual:  .asciiz " | Andar atual: "
msg_corredor_c1:    .asciiz "[CORREDOR] Chamada no andar "
msg_corredor_c1b:   .asciiz " enviada para CABINE 1 (mais perto)\n"
msg_corredor_c2:    .asciiz "[CORREDOR] Chamada no andar "
msg_corredor_c2b:   .asciiz " enviada para CABINE 2 (mais perto)\n"
msg_espaco:         .asciiz " "
msg_anda:           .asciiz "o andar)\n"
msg_newline:        .asciiz "\n"

.text
.globl main
# Função main: responsável pela inicialização do sistema e execução contínua do programa.
main:
    li $v0, 4
    la $a0, msg_inicio
    syscall
    la $a0, msg_inicio2
    syscall
    la $a0, msg_inicio3
    syscall
    la $a0, msg_inicio4
    syscall
    la $a0, msg_inicio5
    syscall
    la $a0, msg_inicio6
    syscall
    jal update_timestamp

loop_principal:
    jal update_timestamp
    jal ler_botoes
    jal processar_cabine1
    jal processar_cabine2
    li $v0, 32
    li $a0, 50
    syscall
    j loop_principal
# Função update_timestamp: atualiza o contador de tempo utilizado para controlar movimentação e abertura das portas.
update_timestamp:
    lw $t0, timestampGlobal
    addi $t0, $t0, 1
    sw $t0, timestampGlobal
    jr $ra
# Função abs_diferenca: calcula o valor absoluto da diferença entre dois ângulos.
abs_diferenca:
    sub $v0, $a0, $a1
    bgez $v0, abs_fim
    sub $v0, $zero, $v0
abs_fim:
    jr $ra
# Função ler_botoes: realiza a leitura dos comandos do usuário e encaminha cada solicitação para a cabine adequada.
ler_botoes:
    subi $sp, $sp, 4
    sw $ra, 0($sp)
    lui $t0, 0xffff
    lw $t1, 0($t0)
    andi $t1, $t1, 0x0001
    beqz $t1, fim_leitura
    lw $t2, 4($t0)
    li $t3, 49
    blt $t2, $t3, verificar_cabine1
    li $t3, 52
    bgt $t2, $t3, verificar_cabine1
    subi $a0, $t2, 49
    jal processar_chamada_corredor
    j fim_leitura
    
verificar_cabine1:
    beq $t2, 113, c1_andar0
    beq $t2, 119, c1_andar1
    beq $t2, 101, c1_andar2
    beq $t2, 114, c1_andar3
    j verificar_cabine2
    
c1_andar0:
    li $a0, 0
    jal processar_chamada_cabine1
    j fim_leitura
c1_andar1:
    li $a0, 1
    jal processar_chamada_cabine1
    j fim_leitura
c1_andar2:
    li $a0, 2
    jal processar_chamada_cabine1
    j fim_leitura
c1_andar3:
    li $a0, 3
    jal processar_chamada_cabine1
    j fim_leitura
    
verificar_cabine2:
    beq $t2, 97, c2_andar0
    beq $t2, 115, c2_andar1
    beq $t2, 100, c2_andar2
    beq $t2, 102, c2_andar3
    j fim_leitura
    
c2_andar0:
    li $a0, 0
    jal processar_chamada_cabine2
    j fim_leitura
c2_andar1:
    li $a0, 1
    jal processar_chamada_cabine2
    j fim_leitura
c2_andar2:
    li $a0, 2
    jal processar_chamada_cabine2
    j fim_leitura
c2_andar3:
    li $a0, 3
    jal processar_chamada_cabine2
    
fim_leitura:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
# Função processar_chamada_corredor: define qual cabine atenderá uma chamada externa com base na proximidade. 
processar_chamada_corredor:
    subi $sp, $sp, 12
    sw $ra, 0($sp)
    sw $a0, 4($sp)
    sll $t0, $a0, 2
    lw $t1, chamadas1($t0)
    lw $t2, chamadas2($t0)
    bnez $t1, fim_corredor
    bnez $t2, fim_corredor
    lw $t3, estado1
    li $t4, 2
    beq $t3, $t4, verifica_porta1
    
verifica_porta1_fim:
    lw $t3, estado2
    beq $t3, $t4, verifica_porta2
    j calcular_proximidade

verifica_porta1:
    lw $t5, andarAtual1
    beq $t5, $a0, fim_corredor
    j verifica_porta1_fim
    
verifica_porta2:
    lw $t5, andarAtual2
    beq $t5, $a0, fim_corredor

calcular_proximidade:
    sll $t0, $a0, 2
    lw $t1, angulosAndar($t0)
    lw $t2, anguloServo1
    move $a0, $t2
    move $a1, $t1
    jal abs_diferenca
    move $t3, $v0
    lw $t4, anguloServo2
    move $a0, $t4
    move $a1, $t1
    jal abs_diferenca
    move $t5, $v0
    blt $t3, $t5, enviar_cabine1_corredor
    blt $t5, $t3, enviar_cabine2_corredor
    lw $t6, direcao1
    beqz $t6, enviar_cabine1_corredor
    j enviar_cabine2_corredor

enviar_cabine1_corredor:
    lw $a0, 4($sp)
    sll $t0, $a0, 2
    li $t1, 1
    sw $t1, chamadas1($t0)
    li $v0, 4
    la $a0, msg_corredor_c1
    syscall
    li $v0, 1
    lw $a0, 4($sp)
    addi $a0, $a0, 1
    syscall
    li $v0, 4
    la $a0, msg_corredor_c1b
    syscall
    j fim_corredor

enviar_cabine2_corredor:
    lw $a0, 4($sp)
    sll $t0, $a0, 2
    li $t1, 1
    sw $t1, chamadas2($t0)
    li $v0, 4
    la $a0, msg_corredor_c2
    syscall
    li $v0, 1
    lw $a0, 4($sp)
    addi $a0, $a0, 1
    syscall
    li $v0, 4
    la $a0, msg_corredor_c2b
    syscall

fim_corredor:
    lw $ra, 0($sp)
    addi $sp, $sp, 12
    jr $ra
# Função processar_chamada_cabine1: registra chamadas internas da Cabine 1.
processar_chamada_cabine1:
    subi $sp, $sp, 8
    sw $ra, 0($sp)
    sw $a0, 4($sp)
    sll $t0, $a0, 2
    lw $t1, chamadas1($t0)
    bnez $t1, fim_chamada_c1
    li $t1, 1
    sw $t1, chamadas1($t0)
    li $v0, 4
    la $a0, msg_cabine1_chamada
    syscall
    li $v0, 1
    lw $a0, 4($sp)
    addi $a0, $a0, 1
    syscall
    li $v0, 4
    la $a0, msg_espaco
    syscall
    la $a0, msg_cabine1_atual
    syscall
    li $v0, 1
    lw $a0, andarAtual1
    addi $a0, $a0, 1
    syscall
    li $v0, 4
    la $a0, msg_newline
    syscall

fim_chamada_c1:
    lw $ra, 0($sp)
    addi $sp, $sp, 8
    jr $ra
# Função processar_chamada_cabine2: registra chamadas internas da Cabine 2.
processar_chamada_cabine2:
    subi $sp, $sp, 8
    sw $ra, 0($sp)
    sw $a0, 4($sp)
    sll $t0, $a0, 2
    lw $t1, chamadas2($t0)
    bnez $t1, fim_chamada_c2
    li $t1, 1
    sw $t1, chamadas2($t0)
    li $v0, 4
    la $a0, msg_cabine2_chamada
    syscall
    li $v0, 1
    lw $a0, 4($sp)
    addi $a0, $a0, 1
    syscall
    li $v0, 4
    la $a0, msg_espaco
    syscall
    la $a0, msg_cabine2_atual
    syscall
    li $v0, 1
    lw $a0, andarAtual2
    addi $a0, $a0, 1
    syscall
    li $v0, 4
    la $a0, msg_newline
    syscall

fim_chamada_c2:
    lw $ra, 0($sp)
    addi $sp, $sp, 8
    jr $ra
# Função processar_cabine1: controla todos os estados operacionais da Cabine 1.
processar_cabine1:
    subi $sp, $sp, 4
    sw $ra, 0($sp)
    lw $t0, estado1
    beq $t0, 0, c1_estado_parado
    beq $t0, 1, c1_estado_movimento
    beq $t0, 2, c1_estado_porta
    j fim_cabine1

c1_estado_parado:
    lw $t1, andarAtual1
    sll $t2, $t1, 2
    lw $t3, chamadas1($t2)
    beqz $t3, c1_verificar_chamadas
    li $t0, 2
    sw $t0, estado1
    lw $t4, timestampGlobal
    sw $t4, portaTimer1
    sw $zero, chamadas1($t2)
    li $v0, 4
    la $a0, msg_cabine1_porta
    syscall
    li $v0, 1
    addi $a0, $t1, 1
    syscall
    li $v0, 4
    la $a0, msg_newline
    syscall
    j fim_cabine1

c1_verificar_chamadas:
    jal tem_chamada_acima1
    beqz $v0, c1_verificar_abaixo
    li $t0, 1
    sw $t0, direcao1
    sw $t0, estado1
    lw $t4, timestampGlobal
    sw $t4, servoTimer1
    li $v0, 4
    la $a0, msg_cabine1_sobe
    syscall
    li $v0, 1
    lw $a0, andarAtual1
    addi $a0, $a0, 1
    syscall
    li $v0, 4
    la $a0, msg_anda
    syscall
    j fim_cabine1

c1_verificar_abaixo:
    jal tem_chamada_abaixo1
    beqz $v0, fim_cabine1
    li $t0, -1
    sw $t0, direcao1
    li $t0, 1
    sw $t0, estado1
    lw $t4, timestampGlobal
    sw $t4, servoTimer1
    li $v0, 4
    la $a0, msg_cabine1_desce
    syscall
    li $v0, 1
    lw $a0, andarAtual1
    addi $a0, $a0, 1
    syscall
    li $v0, 4
    la $a0, msg_anda
    syscall
    j fim_cabine1

c1_estado_movimento:
    lw $t0, servoTimer1
    lw $t1, timestampGlobal
    sub $t2, $t1, $t0
    li $t3, 1
    blt $t2, $t3, fim_cabine1
    sw $t1, servoTimer1
    lw $t4, andarAtual1
    lw $t5, direcao1
    add $t4, $t4, $t5
    sll $t4, $t4, 2
    lw $t6, angulosAndar($t4)
    lw $t7, anguloServo1
    blt $t7, $t6, c1_incrementa
    bgt $t7, $t6, c1_decrementa
    j c1_verifica_chegada

c1_incrementa:
    addi $t7, $t7, 1
    sw $t7, anguloServo1
    j c1_verifica_chegada

c1_decrementa:
    addi $t7, $t7, -1
    sw $t7, anguloServo1

c1_verifica_chegada:
    lw $t4, andarAtual1
    lw $t5, direcao1
    add $t4, $t4, $t5
    sll $t4, $t4, 2
    lw $t6, angulosAndar($t4)
    lw $t7, anguloServo1
    bne $t7, $t6, fim_cabine1
    lw $t8, andarAtual1
    add $t8, $t8, $t5
    sw $t8, andarAtual1
    sll $t9, $t8, 2
    lw $t0, chamadas1($t9)
    bnez $t0, c1_parar
    lw $t5, direcao1
    li $t0, 1
    beq $t5, $t0, c1_check_acima
    jal tem_chamada_abaixo1
    j c1_check_result

c1_check_acima:
    jal tem_chamada_acima1

c1_check_result:
    beqz $v0, c1_parar
    j fim_cabine1

c1_parar:
    li $t0, 2
    sw $t0, estado1
    lw $t1, timestampGlobal
    sw $t1, portaTimer1
    lw $t2, andarAtual1
    sll $t3, $t2, 2
    sw $zero, chamadas1($t3)
    li $v0, 4
    la $a0, msg_cabine1_parou
    syscall
    li $v0, 1
    addi $a0, $t2, 1
    syscall
    li $v0, 4
    la $a0, msg_newline
    syscall
    j fim_cabine1

c1_estado_porta:
    lw $t0, portaTimer1
    lw $t1, timestampGlobal
    sub $t2, $t1, $t0
    li $t3, 100
    blt $t2, $t3, fim_cabine1
    li $t0, 0
    sw $t0, estado1
    sw $t0, direcao1
    li $v0, 4
    la $a0, msg_cabine1_fecha
    syscall

fim_cabine1:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
# Função processar_cabine2: controla todos os estados operacionais da Cabine 2.
processar_cabine2:
    subi $sp, $sp, 4
    sw $ra, 0($sp)
    lw $t0, estado2
    beq $t0, 0, c2_estado_parado
    beq $t0, 1, c2_estado_movimento
    beq $t0, 2, c2_estado_porta
    j fim_cabine2

c2_estado_parado:
    lw $t1, andarAtual2
    sll $t2, $t1, 2
    lw $t3, chamadas2($t2)
    beqz $t3, c2_verificar_chamadas
    li $t0, 2
    sw $t0, estado2
    lw $t4, timestampGlobal
    sw $t4, portaTimer2
    sw $zero, chamadas2($t2)
    li $v0, 4
    la $a0, msg_cabine2_porta
    syscall
    li $v0, 1
    addi $a0, $t1, 1
    syscall
    li $v0, 4
    la $a0, msg_newline
    syscall
    j fim_cabine2

c2_verificar_chamadas:
    jal tem_chamada_acima2
    beqz $v0, c2_verificar_abaixo
    li $t0, 1
    sw $t0, direcao2
    sw $t0, estado2
    lw $t4, timestampGlobal
    sw $t4, servoTimer2
    li $v0, 4
    la $a0, msg_cabine2_sobe
    syscall
    li $v0, 1
    lw $a0, andarAtual2
    addi $a0, $a0, 1
    syscall
    li $v0, 4
    la $a0, msg_anda
    syscall
    j fim_cabine2

c2_verificar_abaixo:
    jal tem_chamada_abaixo2
    beqz $v0, fim_cabine2
    li $t0, -1
    sw $t0, direcao2
    li $t0, 1
    sw $t0, estado2
    lw $t4, timestampGlobal
    sw $t4, servoTimer2
    li $v0, 4
    la $a0, msg_cabine2_desce
    syscall
    li $v0, 1
    lw $a0, andarAtual2
    addi $a0, $a0, 1
    syscall
    li $v0, 4
    la $a0, msg_anda
    syscall
    j fim_cabine2

c2_estado_movimento:
    lw $t0, servoTimer2
    lw $t1, timestampGlobal
    sub $t2, $t1, $t0
    li $t3, 1
    blt $t2, $t3, fim_cabine2
    sw $t1, servoTimer2
    lw $t4, andarAtual2
    lw $t5, direcao2
    add $t4, $t4, $t5
    sll $t4, $t4, 2
    lw $t6, angulosAndar($t4)
    lw $t7, anguloServo2
    blt $t7, $t6, c2_incrementa
    bgt $t7, $t6, c2_decrementa
    j c2_verifica_chegada

c2_incrementa:
    addi $t7, $t7, 1
    sw $t7, anguloServo2
    j c2_verifica_chegada

c2_decrementa:
    addi $t7, $t7, -1
    sw $t7, anguloServo2

c2_verifica_chegada:
    lw $t4, andarAtual2
    lw $t5, direcao2
    add $t4, $t4, $t5
    sll $t4, $t4, 2
    lw $t6, angulosAndar($t4)
    lw $t7, anguloServo2
    bne $t7, $t6, fim_cabine2
    lw $t8, andarAtual2
    add $t8, $t8, $t5
    sw $t8, andarAtual2
    sll $t9, $t8, 2
    lw $t0, chamadas2($t9)
    bnez $t0, c2_parar
    lw $t5, direcao2
    li $t0, 1
    beq $t5, $t0, c2_check_acima
    jal tem_chamada_abaixo2
    j c2_check_result

c2_check_acima:
    jal tem_chamada_acima2

c2_check_result:
    beqz $v0, c2_parar
    j fim_cabine2

c2_parar:
    li $t0, 2
    sw $t0, estado2
    lw $t1, timestampGlobal
    sw $t1, portaTimer2
    lw $t2, andarAtual2
    sll $t3, $t2, 2
    sw $zero, chamadas2($t3)
    li $v0, 4
    la $a0, msg_cabine2_parou
    syscall
    li $v0, 1
    addi $a0, $t2, 1
    syscall
    li $v0, 4
    la $a0, msg_newline
    syscall
    j fim_cabine2

c2_estado_porta:
    lw $t0, portaTimer2
    lw $t1, timestampGlobal
    sub $t2, $t1, $t0
    li $t3, 100
    blt $t2, $t3, fim_cabine2
    li $t0, 0
    sw $t0, estado2
    sw $t0, direcao2
    li $v0, 4
    la $a0, msg_cabine2_fecha
    syscall

fim_cabine2:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
# Funções tem_chamada_acima e tem_chamada_abaixo verificam a existência de solicitações pendentes acima ou abaixo da posição atual das cabines.
tem_chamada_acima1:
    lw $t0, andarAtual1
    addi $t0, $t0, 1
    li $v0, 0
loop_acima1:
    bge $t0, 4, fim_acima1
    sll $t1, $t0, 2
    lw $t2, chamadas1($t1)
    bnez $t2, achou_acima1
    addi $t0, $t0, 1
    j loop_acima1
achou_acima1:
    li $v0, 1
fim_acima1:
    jr $ra

tem_chamada_abaixo1:
    li $t0, 0
    lw $t1, andarAtual1
    li $v0, 0
loop_abaixo1:
    bge $t0, $t1, fim_abaixo1
    sll $t2, $t0, 2
    lw $t3, chamadas1($t2)
    bnez $t3, achou_abaixo1
    addi $t0, $t0, 1
    j loop_abaixo1
achou_abaixo1:
    li $v0, 1
fim_abaixo1:
    jr $ra

tem_chamada_acima2:
    lw $t0, andarAtual2
    addi $t0, $t0, 1
    li $v0, 0
loop_acima2:
    bge $t0, 4, fim_acima2
    sll $t1, $t0, 2
    lw $t2, chamadas2($t1)
    bnez $t2, achou_acima2
    addi $t0, $t0, 1
    j loop_acima2
achou_acima2:
    li $v0, 1
fim_acima2:
    jr $ra

tem_chamada_abaixo2:
    li $t0, 0
    lw $t1, andarAtual2
    li $v0, 0
loop_abaixo2:
    bge $t0, $t1, fim_abaixo2
    sll $t2, $t0, 2
    lw $t3, chamadas2($t2)
    bnez $t3, achou_abaixo2
    addi $t0, $t0, 1
    j loop_abaixo2
achou_abaixo2:
    li $v0, 1
fim_abaixo2:
    jr $ra
