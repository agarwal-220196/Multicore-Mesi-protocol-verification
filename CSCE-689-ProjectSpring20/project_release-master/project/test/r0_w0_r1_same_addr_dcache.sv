//=====================================================================
// Project: 4 core MESI cache design
// File Name: read_miss_icache.sv
// Description: Test for read-miss to I-cache
// Designers: Venky & Suru
//=====================================================================

class r0_w0_r1_same_addr_dcache extends base_test;

    //component macro
    `uvm_component_utils(r0_w0_r1_same_addr_dcache)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", r0_w0_r1_same_addr_dcache_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing r0_w0_r1_same_addr_dcache test" , UVM_LOW)
    endtask: run_phase

endclass : r0_w0_r1_same_addr_dcache


// Sequence for a read-miss on I-cache
class r0_w0_r1_same_addr_dcache_seq extends base_vseq;
    //object macro
    `uvm_object_utils(r0_w0_r1_same_addr_dcache_seq)

    cpu_transaction_c trans;

    //constructor
    function new (string name="r0_w0_r1_same_addr_dcache_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == 32'hAABB_CCDD;})
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == 32'hAABB_CCDD;data == 32'h40000004;})
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == 32'hAABB_CCDD;})
    endtask

endclass : r0_w0_r1_same_addr_dcache_seq
