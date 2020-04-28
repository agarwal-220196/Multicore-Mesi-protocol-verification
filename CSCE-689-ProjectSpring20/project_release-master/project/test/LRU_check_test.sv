//=====================================================================
// Project: 4 core MESI cache design
// File Name: LRU_check_test.sv
// Description: Test for read-miss to D-cache
// Designers: Venky & Suru
//=====================================================================

class LRU_check_test extends base_test;

    //component macro
    `uvm_component_utils(LRU_check_test)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", LRU_check_test_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing LRU_check_test test" , UVM_LOW)
    endtask: run_phase

endclass : LRU_check_test


// Sequence for a read-miss on D-cache
class LRU_check_test_seq extends base_vseq;
    //object macro
    `uvm_object_utils(LRU_check_test_seq)

    cpu_transaction_c trans;

    //constructor
    function new (string name="LRU_check_test_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], { request_type == WRITE_REQ; access_cache_type == DCACHE_ACC;   address == 32'h4321_0000; data==32'h1603_1996; })
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], { request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == 32'h4444_0000;data==32'h1111_1111;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], { request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == 32'h5555_0000; data==32'h0501_1959;})
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], { request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == 32'h6666_0000;data==32'h2222_2222;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], { request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == 32'h7777_0000;})
        //`uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], { request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == 32'h4321_0000;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], { request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == 32'h7000_0000;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], { request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == 32'h5555_0000;})
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], { request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == 32'h6666_0000;})

        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], { request_type == WRITE_REQ; access_cache_type == DCACHE_ACC;   address == 32'h4321_1111; data==32'h1603_1996; })
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], { request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == 32'h4444_1111;data==32'h1111_1111;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], { request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == 32'h5555_1111; data==32'h0501_1959;})
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], { request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == 32'h6666_1111;data==32'h2222_2222;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], { request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == 32'h7777_1111;})
        //`uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], { request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == 32'h4321_0000;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], { request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == 32'h7000_1111;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], { request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == 32'h5555_1111;})
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], { request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == 32'h6666_1111;})
		
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[2], { request_type == WRITE_REQ; access_cache_type == DCACHE_ACC;   address == 32'h4321_2222; data==32'h1603_1996; })
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[2], { request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == 32'h4444_2222;data==32'h1111_1111;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[2], { request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == 32'h5555_2222; data==32'h0501_1959;})
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[2], { request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == 32'h6666_2222;data==32'h2222_2222;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[2], { request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == 32'h7777_2222;})
        //`uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], { request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == 32'h4321_0000;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[2], { request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == 32'h7000_2222;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[2], { request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == 32'h5555_2222;})
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[2], { request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == 32'h6666_2222;})
			
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[3], { request_type == WRITE_REQ; access_cache_type == DCACHE_ACC;   address == 32'h4321_3333; data==32'h1603_1996; })
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[3], { request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == 32'h4444_3333;data==32'h1111_1111;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[3], { request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == 32'h5555_3333; data==32'h0501_1959;})
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[3], { request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == 32'h6666_3333;data==32'h2222_2222;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[3], { request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == 32'h7777_3333;})
        //`uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], { request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == 32'h4321_0000;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[3], { request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == 32'h7000_3333;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[3], { request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == 32'h5555_3333;})
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[3], { request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == 32'h6666_3333;})
			

   endtask

endclass : LRU_check_test_seq
