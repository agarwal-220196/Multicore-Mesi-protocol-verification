//=====================================================================
// Project: 4 core MESI cache design
// File Name: read_write_randomized.sv
// Description: Test for read-miss to I-cache
// Designers: Venky & Suru
//=====================================================================

class read_write_randomized extends base_test;

    //component macro
    `uvm_component_utils(read_write_randomized)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", read_write_randomized_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing read_write_randomized test" , UVM_LOW)
    endtask: run_phase

endclass : read_write_randomized


// Sequence for a read-miss on I-cache
class read_write_randomized_seq extends base_vseq;
    //object macro
    `uvm_object_utils(read_write_randomized_seq)
     
    cpu_transaction_c trans;
    randc int mp1,mp2;
    constraint c1{
          mp1 != mp2;
          mp1 inside {['d0:'d3]};
          mp2 inside {['d0:'d3]};
          //mp1 dist{}
    }


    //constructor
    function new (string name="read_write_randomized_seq");
        super.new(name);
    endfunction : new

    virtual task body();
	repeat(100) begin

	        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp1], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC;})
   		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp2], {request_type == READ_REQ; access_cache_type == DCACHE_ACC;})

	end 

   endtask

endclass : read_write_randomized_seq
