import sys

# ---------------------------------------------------
def to_bin(valor, bits):
    return format(int(valor) & (2**bits - 1), f'0{bits}b') #transformando em binário e colocando o número de bits de cada instrução

tabela = {
    #instruções normais
    "add": ("0000000", "000", "0110011"),
    "sub": ("0100000", "000", "0110011"),
    "xor": ("0000000", "100", "0110011"),
    "srl": ("0000000", "101", "0110011"),
    #-------------------------------------------
    #instruções imediatas
    "addi": ("ime",     "000", "0010011"),
    "lw":  ("ime",     "010", "0000011"),
    #-------------------------------------- 

    "sw":  ("ime",     "010", "0100011"), #Store 
    "beq": ("ime",     "000", "1100011")#Condicional
}
def TP1():
    if len(sys.argv) < 4 or sys.argv[2] != "-o":
            print("Uso correto: python3 Tp1Py.py <entrada.asm> -o <saida.txt>") #colocar o nome do arquivo de entrada e saida sem <> 
            return
    Arquivo_entrada = sys.argv[1]
    Arquivo_saida = sys.argv[3]

    try:

        with open(Arquivo_entrada, "r") as arq_in, open(Arquivo_saida, "w") as arq_out:
            for linha in arq_in:
                linha = linha.strip()
                if not linha or linha.startswith("#"):
                    continue

                partes = linha.replace(",", "").replace("(", " ").replace(")", "").split()
                op = partes[0]

                funct7, funct3, opcode = tabela[op] #desempacotamento de tupla
                #-----------------------------------------------------------------------------------
                #Operações
                if op in ["lw", "sw"]:
                    rd_num = int(partes[1][1:]) #separando colocando cada parte binaria na variavel certa e pulando o x com [1:]
                    imm_num = int(partes[2])
                    rs1_num = int(partes[3][1:])
                    
                    rd_bin = to_bin(rd_num, 5)
                    rs1_bin = to_bin(rs1_num, 5)
                    imm_bin = to_bin(imm_num, 12)
                    
                    if op == "lw": # Formato I
                        binario = imm_bin + rs1_bin + funct3 + rd_bin + opcode
                    else: # sw 
                        binario = imm_bin[:7] + rs1_bin + rd_bin + funct3 + imm_bin[7:] + opcode #transformando em um str só (EX: 110000101011110010)

                elif op == "addi":
                    rd_num = int(partes[1][1:])
                    rs1_num = int(partes[2][1:])
                    imm_num = int(partes[3])
                    
                    rd_bin = to_bin(rd_num, 5)
                    rs1_bin = to_bin(rs1_num, 5)
                    imm_bin = to_bin(imm_num, 12)

                    binario = imm_bin + rs1_bin + funct3 + rd_bin + opcode
                
                elif op == "beq":
                    rs1_num = int(partes[1][1:])
                    rs2_num = int(partes[2][1:])
                    imm_num = int(partes[3])
                    
                    rs1_bin = to_bin(rs1_num, 5)
                    rs2_bin = to_bin(rs2_num, 5)
                    imm_bin = to_bin(imm_num, 13) 
                    
                    # Montagem seguindo o padrão:
                    binario = (imm_bin[0] + imm_bin[2:8] + rs2_bin + rs1_bin + 
                            funct3 + imm_bin[8:12] + imm_bin[1] + opcode)

                else: # Tipo R (add, sub, xor, srl)
                    rd_num = int(partes[1][1:])
                    rs1_num = int(partes[2][1:])
                    rs2_num = int(partes[3][1:])
                    
                    rd_bin = to_bin(rd_num, 5)
                    rs1_bin = to_bin(rs1_num, 5)
                    rs2_bin = to_bin(rs2_num, 5)
                    
                    binario = funct7 + rs2_bin + rs1_bin + funct3 + rd_bin + opcode
                #-----------------------------------------------------------
                print(binario)
                arq_out.write(binario + "\n")

    except FileNotFoundError:
        print(f"Erro: O arquivo '{Arquivo_entrada}' não foi encontrado.")

if __name__ == "__main__":
    TP1()