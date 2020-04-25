class RAW_replacement_dcache extends base_test;

    //component macro
    `uvm_component_utils(RAW_replacement_dcache)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", R0_R2_R1_R3_W0_R0_same_addr_dcache_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing RAW_replacement_dcache test" , UVM_LOW)
    endtask: run_phase

endclass : RAW_replacement_dcache


// Sequence for a read-miss on I-cache
class RAW_replacement_dcache_seq extends base_vseq;
    //object macro
    `uvm_object_utils(RAW_replacement_dcache_seq)

    cpu_transaction_c trans;

    //constructor
    function new (string name="RAW_replacement_dcache_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[3], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == 32'hAABB_CCD1; data==32'h40000004;})
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[3], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == 32'hAABB_CCD2;})
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[3], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == 32'hAABB_CCD3;})
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[3], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == 32'hAABB_CCD4;})
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[3], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == 32'hAABB_CCD5;})
		
    endtask

endclass : RAW_replacement_dcache_seq



//RAw
