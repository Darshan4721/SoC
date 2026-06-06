`timescale 1ns/1ps

module sys_ctrl_unit (
    // Physical Boundary Inputs
    input  logic       ref_clk,
    input  logic       por_n,        // Power-On Reset (Active Low)
    
    // System Clock Generation
    output logic       sys_clk,
    
    // Staggered Reset Fanouts (Active Low)
    output logic       rst_n_noc,
    output logic       rst_n_mem,
    output logic       rst_n_periph,
    output logic       rst_n_accel,
    output logic       rst_n_core,
    
    // System Status
    output logic       system_ready,
    
    // PLIC Stub (Interrupt Routing)
    input  logic [7:0] ext_io_irq,   // External IO interrupts (UART, SPI, etc.)
    output logic [3:0] meip          // Machine External Interrupt pins to 4 Cores
);

    // =========================================================================
    // 1. Mock PLL (Clock Management)
    // =========================================================================
    // In a real ASIC, this wraps an analog PLL macro. 
    // For RTL, we pass through the clock and simulate a lock delay.
    assign sys_clk = ref_clk;
    
    logic [7:0] pll_lock_timer;
    logic       pll_locked;
    
    always_ff @(posedge sys_clk or negedge por_n) begin
        if (!por_n) begin
            pll_lock_timer <= 8'd0;
            pll_locked <= 1'b0;
        end else begin
            if (pll_lock_timer < 8'hFF) begin
                pll_lock_timer <= pll_lock_timer + 1'b1;
            end else begin
                pll_locked <= 1'b1;
            end
        end
    end

    // =========================================================================
    // 2. Boot Sequencing FSM (Staggered Wake-Up)
    // =========================================================================
    typedef enum logic [2:0] {
        BOOT_INIT       = 3'd0,
        BOOT_WAIT_PLL   = 3'd1,
        BOOT_WAKE_NOC   = 3'd2,
        BOOT_WAKE_MEM   = 3'd3,
        BOOT_WAKE_PERIPH= 3'd4,
        BOOT_WAKE_ACCEL = 3'd5,
        BOOT_WAKE_CORE  = 3'd6,
        BOOT_DONE       = 3'd7
    } boot_state_t;
    
    boot_state_t state, next_state;

    always_ff @(posedge sys_clk or negedge por_n) begin
        if (!por_n) begin
            state <= BOOT_INIT;
            rst_n_noc    <= 1'b0;
            rst_n_mem    <= 1'b0;
            rst_n_periph <= 1'b0;
            rst_n_accel  <= 1'b0;
            rst_n_core   <= 1'b0;
            system_ready <= 1'b0;
        end else begin
            state <= next_state;
            
            // Progressive lock-in of reset releases to prevent di/dt surges
            if (state >= BOOT_WAKE_NOC)    rst_n_noc    <= 1'b1;
            if (state >= BOOT_WAKE_MEM)    rst_n_mem    <= 1'b1;
            if (state >= BOOT_WAKE_PERIPH) rst_n_periph <= 1'b1;
            if (state >= BOOT_WAKE_ACCEL)  rst_n_accel  <= 1'b1;
            if (state >= BOOT_WAKE_CORE)   rst_n_core   <= 1'b1;
            
            if (state == BOOT_DONE)        system_ready <= 1'b1;
        end
    end

    always_comb begin
        next_state = state;
        case (state)
            BOOT_INIT: begin
                next_state = BOOT_WAIT_PLL;
            end
            BOOT_WAIT_PLL: begin
                if (pll_locked) next_state = BOOT_WAKE_NOC;
            end
            BOOT_WAKE_NOC: begin
                // NoC router wakes up to establish the backbone
                next_state = BOOT_WAKE_MEM;
            end
            BOOT_WAKE_MEM: begin
                // Memory subsystem wakes up to initialize DDR training
                next_state = BOOT_WAKE_PERIPH;
            end
            BOOT_WAKE_PERIPH: begin
                // IO subsystem wakes up to establish off-chip communications
                next_state = BOOT_WAKE_ACCEL;
            end
            BOOT_WAKE_ACCEL: begin
                // Heavy accelerators wake up (GPU/NPU)
                next_state = BOOT_WAKE_CORE;
            end
            BOOT_WAKE_CORE: begin
                // Finally, the 4 CPUs wake up and begin fetching from memory
                next_state = BOOT_DONE;
            end
            BOOT_DONE: begin
                next_state = BOOT_DONE;
            end
            default: next_state = BOOT_INIT;
        endcase
    end

    // =========================================================================
    // 3. Platform-Level Interrupt Controller (PLIC) Stub
    // =========================================================================
    // In a full implementation, this uses memory-mapped registers to route and prioritize.
    // For this stub, we logically OR the interrupts and broadcast to all 4 cores.
    logic any_io_irq;
    assign any_io_irq = |ext_io_irq;
    
    always_ff @(posedge sys_clk or negedge por_n) begin
        if (!por_n) begin
            meip <= 4'b0000;
        end else begin
            // Broadcast interrupt to all 4 CPU cores simultaneously
            meip[0] <= any_io_irq;
            meip[1] <= any_io_irq;
            meip[2] <= any_io_irq;
            meip[3] <= any_io_irq;
        end
    end

endmodule
