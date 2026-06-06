`timescale 1ns/1ps

module core_pipeline_controller #(
    parameter PC_WIDTH = 64
) (
    input  logic clk,
    input  logic rst_n,

    // Interrupts (Asynchronous)
    input  logic timer_irq,
    input  logic ext_irq,
    input  logic soft_irq,

    // Commit Interface (Precise Exceptions & Branch Mispredicts)
    input  logic                  commit_valid,             // Valid instruction committing
    input  logic                  commit_exception,         // Exception flagged on commit
    input  logic [PC_WIDTH-1:0]   commit_exception_pc,      // PC of excepting instruction
    input  logic [63:0]           commit_exception_cause,   // Cause code
    input  logic                  commit_branch_mispredict, // Branch mispredict
    input  logic [PC_WIDTH-1:0]   commit_branch_target,     // Correct branch target
    input  logic                  commit_mret,              // Return from Machine mode

    // Pipeline Control Outputs (Stall & Flush vectors)
    output logic global_stall,
    output logic fetch_flush,
    output logic decode_flush,
    output logic execute_flush,
    output logic memory_flush,
    output logic fpu_flush,
    output logic vector_flush,

    // Trap Routing
    output logic                trap_valid,
    output logic [PC_WIDTH-1:0] trap_target_pc
);

    // =========================================================================
    // CSR State
    // =========================================================================
    logic [PC_WIDTH-1:0] mepc;
    logic [63:0]         mcause;
    logic [PC_WIDTH-1:0] mtvec;
    logic [63:0]         mstatus; // Simplified: [3] = MIE (Machine Interrupt Enable)
    
    // MIE bit
    logic mie;
    assign mie = mstatus[3];

    // =========================================================================
    // FSM State Definition
    // =========================================================================
    typedef enum logic [1:0] {
        STATE_NORMAL       = 2'b00,
        STATE_TRAP_TAKEN   = 2'b01,
        STATE_MRET_TAKEN   = 2'b10
    } ctrl_state_t;
    
    ctrl_state_t state, next_state;

    // Interrupt Pending Logic
    logic irq_pending;
    logic [63:0] irq_cause;
    
    always_comb begin
        irq_pending = 1'b0;
        irq_cause = '0;
        if (mie) begin
            if (ext_irq) begin
                irq_pending = 1'b1;
                irq_cause = 64'h800000000000000B; // Machine External Interrupt
            end else if (soft_irq) begin
                irq_pending = 1'b1;
                irq_cause = 64'h8000000000000003; // Machine Software Interrupt
            end else if (timer_irq) begin
                irq_pending = 1'b1;
                irq_cause = 64'h8000000000000007; // Machine Timer Interrupt
            end
        end
    end

    // =========================================================================
    // FSM Transition & Next State Logic
    // =========================================================================
    always_comb begin
        next_state = state;
        case (state)
            STATE_NORMAL: begin
                // Synchronous Exception or Asynchronous IRQ (taken at instruction boundary)
                if (commit_exception || (irq_pending && commit_valid)) begin
                    next_state = STATE_TRAP_TAKEN;
                end else if (commit_mret) begin
                    next_state = STATE_MRET_TAKEN;
                end
            end
            STATE_TRAP_TAKEN: begin
                next_state = STATE_NORMAL;
            end
            STATE_MRET_TAKEN: begin
                next_state = STATE_NORMAL;
            end
            default: next_state = STATE_NORMAL;
        endcase
    end

    // =========================================================================
    // FSM Outputs & State Registers
    // =========================================================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= STATE_NORMAL;
            mepc <= '0;
            mcause <= '0;
            mtvec <= 64'h8000_0100; // Default boot vector
            mstatus <= 64'h0000_0008; // MIE enabled by default
            
            global_stall <= 1'b0;
            fetch_flush <= 1'b0;
            decode_flush <= 1'b0;
            execute_flush <= 1'b0;
            memory_flush <= 1'b0;
            fpu_flush <= 1'b0;
            vector_flush <= 1'b0;
            
            trap_valid <= 1'b0;
            trap_target_pc <= '0;
        end else begin
            state <= next_state;
            
            // Default: no flush, no trap
            fetch_flush <= 1'b0;
            decode_flush <= 1'b0;
            execute_flush <= 1'b0;
            memory_flush <= 1'b0;
            fpu_flush <= 1'b0;
            vector_flush <= 1'b0;
            trap_valid <= 1'b0;
            global_stall <= 1'b0;
            
            if (state == STATE_NORMAL) begin
                if (commit_exception) begin
                    // Handle Synchronous Exception
                    mepc <= commit_exception_pc;
                    mcause <= commit_exception_cause;
                    mstatus[3] <= 1'b0; // Disable interrupts (MIE=0)
                    
                    fetch_flush <= 1'b1;
                    decode_flush <= 1'b1;
                    execute_flush <= 1'b1;
                    memory_flush <= 1'b1;
                    fpu_flush <= 1'b1;
                    vector_flush <= 1'b1;
                    trap_valid <= 1'b1;
                    trap_target_pc <= mtvec;
                end else if (irq_pending && commit_valid) begin
                    // Handle Asynchronous Interrupt precisely at instruction boundary
                    mepc <= commit_exception_pc + 4; // Return to NEXT instruction
                    mcause <= irq_cause;
                    mstatus[3] <= 1'b0; // Disable MIE
                    
                    fetch_flush <= 1'b1;
                    decode_flush <= 1'b1;
                    execute_flush <= 1'b1;
                    memory_flush <= 1'b1;
                    fpu_flush <= 1'b1;
                    vector_flush <= 1'b1;
                    trap_valid <= 1'b1;
                    trap_target_pc <= mtvec;
                end else if (commit_mret) begin
                    // Handle MRET
                    mstatus[3] <= 1'b1; // Re-enable MIE (simplified MRET behavior)
                    
                    fetch_flush <= 1'b1;
                    decode_flush <= 1'b1;
                    execute_flush <= 1'b1;
                    memory_flush <= 1'b1;
                    fpu_flush <= 1'b1;
                    vector_flush <= 1'b1;
                    trap_valid <= 1'b1;
                    trap_target_pc <= mepc;
                end else if (commit_branch_mispredict) begin
                    // Normal Branch Mispredict (Flush pipeline, but no CSR updates)
                    fetch_flush <= 1'b1;
                    decode_flush <= 1'b1;
                    execute_flush <= 1'b1; // Typically flush execute stage partially depending on architecture
                    memory_flush <= 1'b1;
                    fpu_flush <= 1'b1;
                    vector_flush <= 1'b1;
                    trap_valid <= 1'b1;
                    trap_target_pc <= commit_branch_target;
                end
            end
        end
    end

endmodule
