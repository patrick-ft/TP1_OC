`timescale 1ns / 1ps

// ============================================================
// Memória de Instruções - Lê o ficheiro de texto binário
// ============================================================
module instr_mem (
    input  [31:0] addr,
    output [31:0] instruction
);
    reg [31:0] mem [0:63]; // Capacidade para 64 instruções

    initial begin
        // Carrega o ficheiro instrucoes.bin para a memória
        $readmemb("instrucoes.bin", mem);
    end

    // Converte endereço de byte para índice da memória (divisão por 4)
    assign instruction = mem[addr >> 2];
endmodule

// ============================================================
// Banco de Registadores - Inicializado com 0
// ============================================================
module reg_file (
    input        clk,
    input        reg_write,
    input  [4:0] rs1, rs2, rd,
    input  [31:0] write_data,
    output [31:0] read_data1,
    output [31:0] read_data2
);
    reg [31:0] regs [0:31];
    integer i;

    initial begin
        // Inicializa todos os 32 registradores com valor zero
        for (i = 0; i < 32; i = i + 1)
            regs[i] = 0;
    end

    // x0 é sempre zero conforme arquitetura RISC-V
    assign read_data1 = (rs1 == 0) ? 32'b0 : regs[rs1];
    assign read_data2 = (rs2 == 0) ? 32'b0 : regs[rs2];

    always @(posedge clk) begin
        if (reg_write && rd != 0)
            regs[rd] <= write_data;
    end
endmodule

// ============================================================
// Unidade de Controle e Gerador de Imediato
// ============================================================
module control (
    input  [6:0] opcode,
    output reg   reg_write, mem_read, mem_write, alu_src, mem_to_reg, branch,
    output reg [1:0] alu_op
);
    always @(*) begin
        case (opcode)
            7'b0000011: {reg_write, mem_read, mem_write, alu_src, mem_to_reg, branch, alu_op} = 8'b1_1_0_1_1_0_00; // lw
            7'b0100011: {reg_write, mem_read, mem_write, alu_src, mem_to_reg, branch, alu_op} = 8'b0_0_1_1_0_0_00; // sw
            7'b0110011: {reg_write, mem_read, mem_write, alu_src, mem_to_reg, branch, alu_op} = 8'b1_0_0_0_0_0_10; // R-type
            7'b0010011: {reg_write, mem_read, mem_write, alu_src, mem_to_reg, branch, alu_op} = 8'b1_0_0_1_0_0_11; // addi
            7'b1100011: {reg_write, mem_read, mem_write, alu_src, mem_to_reg, branch, alu_op} = 8'b0_0_0_0_0_1_01; // beq
            default:    {reg_write, mem_read, mem_write, alu_src, mem_to_reg, branch, alu_op} = 8'b0_0_0_0_0_0_00;
        endcase
    end
endmodule

module imm_gen (
    input  [31:0] instruction,
    output reg [31:0] imm_ext
);
    wire [6:0] opcode;
    assign opcode = instruction[6:0];

    always @(*) begin
        case (opcode)
            7'b0000011, 7'b0010011: imm_ext = {{20{instruction[31]}}, instruction[31:20]};
            7'b0100011: imm_ext = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            7'b1100011: imm_ext = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            default:    imm_ext = 32'b0;
        endcase
    end
endmodule