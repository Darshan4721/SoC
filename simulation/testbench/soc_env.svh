`ifndef SOC_ENV_SV
`define SOC_ENV_SV

class soc_env extends uvm_env;
    `uvm_component_utils(soc_env)

    // VIP Agents would go here (e.g. AXI VIP, PCIe VIP)
    // uvm_agent axi_vip_agent;
    
    function new(string name = "soc_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("SOC_ENV", "Building SoC Environment components...", UVM_LOW)
        // Build agents and scoreboards here
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        // Connect agent monitors to scoreboard
    endfunction
    
endclass

`endif
