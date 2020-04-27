//=====================================================================
// Project: 4 core MESI cache design
// File Name: read_miss_icache.sv
// Description: Test for read-miss to I-cache
// Designers: Venky & Suru
//=====================================================================

class w0_w0_r0_same_addr_dcache_random extends base_test;

    //component macro
    `uvm_component_utils(w0_w0_r0_same_addr_dcache_random)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", w0_w0_r0_same_addr_dcache_random_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing w0_w0_r0_same_addr_dcache_random test" , UVM_LOW)
    endtask: run_phase

endclass : w0_w0_r0_same_addr_dcache_random


// Sequence for a read-miss on I-cache
class w0_w0_r0_same_addr_dcache_random_seq extends base_vseq;
    //object macro
    `uvm_object_utils(w0_w0_r0_same_addr_dcache_random_seq)

    cpu_transaction_c trans;

    //constructor
    function new (string name="w0_w0_r0_same_addr_dcache_random_seq");
        super.new(name);
    endfunction : new

    virtual task body();
 	`uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == WRITE_REQ; })       
	`uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == WRITE_REQ; })
	
	`uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == READ_REQ;})       
    endtask

endclass : w0_w0_r0_same_addr_dcache_random_seq
