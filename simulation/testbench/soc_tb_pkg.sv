`timescale 1ns/1ps
package soc_tb_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // Forward declarations
    typedef class soc_env;
    typedef class soc_base_test;

    // Environment
    `include "soc_env.sv"
    
    // Tests
    `include "soc_base_test.sv"

endpackage
