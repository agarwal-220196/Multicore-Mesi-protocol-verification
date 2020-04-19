//=====================================================================
// Project: 4 core MESI cache design
// File Name: read_w0_r0_r0_dcache.sv
// Description: Test for read-miss to D-cache
// Designers: Venky & Suru
//=====================================================================

class read_w0_r0_r0_dcache extends base_test;

    //component macro
    `uvm_component_utils(read_w0_r0_r0_dcache)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", read_w0_r0_r0_dcache_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing read_w0_r0_r0_dcache test" , UVM_LOW)
    endtask: run_phase

endclass : read_w0_r0_r0_dcache


// Sequence for a read-miss on D-cache
class read_w0_r0_r0_dcache_seq extends base_vseq;
    //object macro
    `uvm_object_utils(read_w0_r0_r0_dcache_seq)

    cpu_transaction_c trans;

    //constructor
    function new (string name="read_w0_r0_r0_dcache_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[3], { request_type == WRITE_REQ; access_cache_type == DCACHE_ACC;   address == 32'h4321_4321; data == 32'h2828_2828; })
        
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], { request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == 32'h4321_4321;})
   
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[3], { request_type == WRITE_REQ; access_cache_type == DCACHE_ACC;   address == 33'h4321_4321; data == 32'h2929_2929; })
        
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], { request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == 32'h4321_4321;})
   
 endtask

endclass : read_w0_r0_r0_dcache_seq
