`ifndef SOC_BASE_TEST_SV
`define SOC_BASE_TEST_SV

class soc_base_test extends uvm_test;
    `uvm_component_utils(soc_base_test)

    soc_env env;

    function new(string name = "soc_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = soc_env::type_id::create("env", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        
        `uvm_info("SOC_TEST", "Waiting for reset sequence to complete...", UVM_LOW)
        
        // Wait for system to come out of reset
        #200ns;
        
        `uvm_info("SOC_TEST", "System is out of reset. Executing sanity sequence...", UVM_LOW)
        
        // Let the simulation run for a bit to watch the Fetch Unit attempt a boot
        #5000ns;
        
        `uvm_info("SOC_TEST", "Sanity run complete. Dropping objection.", UVM_LOW)
        
        phase.drop_objection(this);
    endtask

endclass

`endif
