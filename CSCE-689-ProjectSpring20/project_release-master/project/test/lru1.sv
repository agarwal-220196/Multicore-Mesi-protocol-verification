//=====================================================================
// Project: 4 core MESI cache design
// File Name: read_miss0_read_hit1_dcache.sv
// Description: Test for read-miss to D-cache
// Designers: Venky & Suru
//=====================================================================
//----------------------LRU - LINE4 REPLACEMENT----------------------//

class lru1 extends base_test;

    //component macro
    `uvm_component_utils(lru1)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", lru1_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing lru1 test" , UVM_LOW)
    endtask: run_phase

endclass : lru1


// Sequence for a read-miss on D-cache
class lru1_seq extends base_vseq;
    //object macro
    `uvm_object_utils(lru1_seq)

    cpu_transaction_c trans;

    //constructor
    function new (string name="lru1_seq");
        super.new(name);
    endfunction : new

    virtual task body();
	
	`uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], { request_type == WRITE_REQ; address == 32'h4000_0000;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], { request_type == WRITE_REQ; address == 32'h4001_0000;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], { request_type == WRITE_REQ; address == 32'h4010_0000;})
	`uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], { request_type == WRITE_REQ; address == 32'h4011_0000;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], { request_type == READ_REQ; address == 32'h4100_0000;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], { request_type == READ_REQ; address == 32'h4101_0000;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], { request_type == READ_REQ; address == 32'h4110_0000;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], { request_type == READ_REQ; address == 32'h4111_0000;})
	
   endtask

endclass : lru1_seq
