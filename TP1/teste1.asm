# Teste de Instruções Tipo R
add x9, x21, x10
sub x5, x6, x7
xor x1, x2, x3
srl x10, x11, x12

# Teste de Instrução Tipo I (Aritmética)
addi x2, x0, 1

# Teste de Instruções de Memória (I e S)
lw x9, 120(x10)
sw x9, 120(x10)

# Teste de Instrução de Desvio (SB)
beq x1, x2, 4