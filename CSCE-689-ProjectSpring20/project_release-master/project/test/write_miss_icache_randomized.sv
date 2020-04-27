//=====================================================================
// Project: 4 core MESI cache design
// File Name: write_miss_icache_randomized.sv
// Description: Test for read-miss to I-cache
// Designers: Venky & Suru
//=====================================================================
//comment 
class write_miss_icache_randomized extends base_test;

    //component macro
    `uvm_component_utils(write_miss_icache_randomized)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", write_miss_icache_randomized_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing write_miss_icache_randomized test" , UVM_LOW)
    endtask: run_phase

endclass : write_miss_icache_randomized


// Sequence for a read-miss on I-cache
class write_miss_icache_randomized_seq extends base_vseq;
    //object macro
    `uvm_object_utils(write_miss_icache_randomized_seq)

    cpu_transaction_c trans;

    //constructor
    function new (string name="write_miss_icache_randomized_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        repeat(100) begin
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == WRITE_REQ; access_cache_type == ICACHE_ACC;})
    	end
    endtask

endclass : write_miss_icache_randomized_seq
