//=====================================================================
// Project: 4 core MESI cache design
// File Name: R0_W1_W1_same_addr_dcache.sv
// Description: Test for read-miss to D-cache
// Designers: Venky & Suru
//=====================================================================

class R0_W1_W1_same_addr_dcache extends base_test;

    //component macro
    `uvm_component_utils(R0_W1_W1_same_addr_dcache)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", R0_W1_W1_same_addr_dcache_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing R0_W1_W1_same_addr_dcache test" , UVM_LOW)
    endtask: run_phase

endclass : R0_W1_W1_same_addr_dcache


// Sequence for a read-miss on D-cache
class R0_W1_W1_same_addr_dcache_seq extends base_vseq;
    //object macro
    `uvm_object_utils(R0_W1_W1_same_addr_dcache_seq)

    cpu_transaction_c trans;

    //constructor
    function new (string name="R0_W1_W1_same_addr_dcache_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], { request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == 32'h4321_432E;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], { request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == 32'h4321_432E; data==32'h0501_1959;})
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], { request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == 32'h4321_432E; data==32'h4201_1969;})
		
        
   endtask

endclass : R0_W1_W1_same_addr_dcache_seq
//writw 
