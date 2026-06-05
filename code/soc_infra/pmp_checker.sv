`timescale 1ns/1ps

module pmp_checker (
    output logic [55:0] paddr,
    output logic [1:0] priv_mode,
    output logic is_write,
    output logic is_exec,
    output logic [63:0] [0:PMP_REGIONS/8 - 1] pmp_cfg,
    output logic [53:0] [0:PMP_REGIONS-1] pmp_addr,
    output logic access_fault
);

endmodule
