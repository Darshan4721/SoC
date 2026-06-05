`timescale 1ns/1ps
module sys_ctrl_unit (
    input  logic ref_clk,  // External crystal oscillator (e.g., 50MHz)
    input  logic por_n,    // Physical Power-On-Reset button (Asynchronous, Active Low)

    output logic sys_clk,       // Global System Clock from PLL (e.g., 1GHz)
    
    // Staggered Power/Reset Domains
    output logic rst_n_mem,     // Memory Subsystem Reset
    output logic rst_n_noc,     // NoC Subsystem Reset
    output logic rst_n_periph,  // IO/Peripherals Reset
    output logic rst_n_accel,   // Accelerators Reset
    output logic rst_n_core,    // CPU Cores Reset (Released last)
    
    output logic system_ready   // Boot sequence complete
);

    // =========================================================================
    // INTERNAL SIGNALS
    // =========================================================================
    logic pll_locked;
    
    // 16-bit Boot Counter to stagger resets (prevents di/dt brown-out)
    logic [15:0] boot_counter;

    // Boot FSM States
    typedef enum logic [2:0] {
        BOOT_PLL_WAIT   = 3'b000,
        BOOT_MEM_INIT   = 3'b001,
        BOOT_NOC_INIT   = 3'b010,
        BOOT_PERIPH_INIT= 3'b011,
        BOOT_ACCEL_INIT = 3'b100,
        BOOT_CORE_WAKE  = 3'b101,
        SYSTEM_RUN      = 3'b110
    } boot_state_t;

    boot_state_t state, next_state;

    // =========================================================================
    // PLL INSTANTIATION (Primitive)
    // =========================================================================
    // In a physical ASIC, this wraps the Foundry's Hard Analog PLL macro.
    pll_clock_generator i_pll (
        .clk_ref(ref_clk),
        .rst_n(por_n),       // PLL is reset directly by the physical pin
        .mult(8'd10),
        .div(8'd1),
        .clk_out(sys_clk),   // The high-speed logic clock
        .locked(pll_locked)
    );

    // =========================================================================
    // SYNCHRONIZATION OF POR TO SYS_CLK
    // =========================================================================
    // Best practice: Asynchronously assert reset, synchronously de-assert to 
    // prevent recovery time violations on the FSM flip-flops.
    logic por_n_sync_1, por_n_sync;
    
    always_ff @(posedge sys_clk or negedge por_n) begin
        if (!por_n) begin
            por_n_sync_1 <= 1'b0;
            por_n_sync   <= 1'b0;
        end else begin
            por_n_sync_1 <= 1'b1;
            por_n_sync   <= por_n_sync_1;
        end
    end

    // =========================================================================
    // STATE MACHINE: RESET SEQUENCER
    // =========================================================================
    // Clocked by the fast sys_clk, but held in reset by the synchronized POR.
    always_ff @(posedge sys_clk or negedge por_n_sync) begin
        if (!por_n_sync) begin
            state <= BOOT_PLL_WAIT;
            boot_counter <= 16'd0;
        end else begin
            state <= next_state;
            
            // Counter management
            if (state != next_state) begin
                boot_counter <= 16'd0; // Reset counter on state transition
            end else if (state != SYSTEM_RUN && state != BOOT_PLL_WAIT) begin
                boot_counter <= boot_counter + 1'b1;
            end
        end
    end

    // FSM Next-State Logic
    always_comb begin
        next_state = state;
        
        case (state)
            BOOT_PLL_WAIT: begin
                if (pll_locked) next_state = BOOT_MEM_INIT;
            end
            
            BOOT_MEM_INIT: begin
                if (boot_counter >= 16'd256) next_state = BOOT_NOC_INIT;
            end
            
            BOOT_NOC_INIT: begin
                if (boot_counter >= 16'd256) next_state = BOOT_PERIPH_INIT;
            end
            
            BOOT_PERIPH_INIT: begin
                if (boot_counter >= 16'd256) next_state = BOOT_ACCEL_INIT;
            end
            
            BOOT_ACCEL_INIT: begin
                if (boot_counter >= 16'd256) next_state = BOOT_CORE_WAKE;
            end
            
            BOOT_CORE_WAKE: begin
                // Give cores 1024 cycles to stabilize before full run
                if (boot_counter >= 16'd1024) next_state = SYSTEM_RUN;
            end
            
            SYSTEM_RUN: begin
                next_state = SYSTEM_RUN;
            end
            
            default: next_state = BOOT_PLL_WAIT;
        endcase
    end

    // =========================================================================
    // GLITCH-FREE RESET OUTPUTS
    // =========================================================================
    // The resets are registered to prevent combinatorial glitches from destroying
    // the clock-trees of the sub-domains.
    always_ff @(posedge sys_clk or negedge por_n_sync) begin
        if (!por_n_sync) begin
            rst_n_mem    <= 1'b0;
            rst_n_noc    <= 1'b0;
            rst_n_periph <= 1'b0;
            rst_n_accel  <= 1'b0;
            rst_n_core   <= 1'b0;
            system_ready <= 1'b0;
        end else begin
            // Cumulative release: Once a domain is up, it stays up.
            rst_n_mem    <= (state >= BOOT_NOC_INIT);
            rst_n_noc    <= (state >= BOOT_PERIPH_INIT);
            rst_n_periph <= (state >= BOOT_ACCEL_INIT);
            rst_n_accel  <= (state >= BOOT_CORE_WAKE);
            rst_n_core   <= (state == SYSTEM_RUN);
            
            system_ready <= (state == SYSTEM_RUN);
        end
    end

endmodule
