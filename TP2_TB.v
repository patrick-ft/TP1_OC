`timescale 1ns / 1ps

module cpu_tb;
    reg clk, reset;
    wire [31:0] pc, instr, r1, r2, imm, alu_res, m_data;
    wire [3:0] a_ctrl;
    wire [1:0] a_op;
    wire rw, mr, mw, as, m2r, br, z;

    reg [31:0] pc_reg;
    assign pc = pc_reg;

    // Lógica do PC
    always @(posedge clk or posedge reset) begin
        if (reset) pc_reg <= 0;
        else pc_reg <= (br && z) ? pc_reg + imm : pc_reg + 4;
    end

    // Instanciação dos Componentes
    instr_mem imem (.addr(pc), .instruction(instr));
    control   ctrl (.opcode(instr[6:0]), .reg_write(rw), .mem_read(mr), .mem_write(mw), .alu_src(as), .mem_to_reg(m2r), .branch(br), .alu_op(a_op));
    reg_file  rf   (.clk(clk), .reg_write(rw), .rs1(instr[19:15]), .rs2(instr[24:20]), .rd(instr[11:7]), .write_data(m2r ? m_data : alu_res), .read_data1(r1), .read_data2(r2));
    imm_gen   igen (.instruction(instr), .imm_ext(imm));
    
    // Unidade ALU simplificada para o TB
    assign alu_res = as ? r1 + imm : r1 + r2;
    assign z = (alu_res == 0);

    // Clock
    initial clk = 0;
    always #5 clk = ~clk;

    // Simulação
    initial begin
        reset = 1; #15 reset = 0;
        
        $display("Iniciando Simulação...");
        // Tempo suficiente para processar o ficheiro binário
        #200; 

        show_final_state;
        $finish;
    end

    // --- TASK DE IMPRESSÃO (IGUAL À IMAGEM) ---
    task show_final_state;
        integer i;
        begin
            for (i = 0; i < 32; i = i + 1) begin
                // Formatação: Register [ i]: valor
                $display("Register [%2d]: %15d", i, rf.regs[i]);
            end
        end
    endtask

endmodule