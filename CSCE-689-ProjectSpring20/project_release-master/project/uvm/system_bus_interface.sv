//=====================================================================
// Project: 4 core MESI cache design
// File Name: system_bus_interface.sv
// Description: Basic system bus interface including arbiter
// Designers: Venky & Suru
//=====================================================================

interface system_bus_interface(input clk);

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    parameter DATA_WID_LV1        = `DATA_WID_LV1       ;
    parameter ADDR_WID_LV1        = `ADDR_WID_LV1       ;
    parameter NO_OF_CORE            = 4;

    wire [DATA_WID_LV1 - 1 : 0] data_bus_lv1_lv2     ;
    wire [ADDR_WID_LV1 - 1 : 0] addr_bus_lv1_lv2     ;
    wire                        bus_rd               ;
    wire                        bus_rdx              ;
    wire                        lv2_rd               ;
    wire                        lv2_wr               ;
    wire                        lv2_wr_done          ;
    wire                        cp_in_cache          ;
    wire                        data_in_bus_lv1_lv2  ;

    wire                        shared               ;
    wire                        all_invalidation_done;
    wire                        invalidate           ;

    logic [NO_OF_CORE - 1  : 0]   bus_lv1_lv2_gnt_proc ;
    logic [NO_OF_CORE - 1  : 0]   bus_lv1_lv2_req_proc ;
    logic [NO_OF_CORE - 1  : 0]   bus_lv1_lv2_gnt_snoop;
    logic [NO_OF_CORE - 1  : 0]   bus_lv1_lv2_req_snoop;
    logic                       bus_lv1_lv2_gnt_lv2  ;
    logic                       bus_lv1_lv2_req_lv2  ;

//Assertions
//property that checks that signal_1 is asserted in the previous cycle of signal_2 assertion
    property prop_sig1_before_sig2(signal_1,signal_2);
    @(posedge clk)
        signal_2 |-> $past(signal_1);
    endproperty
	
	//property that checks that signal_1 is asserted sometime before signal_2 assertion
	property prop_sig1_sometime_before_sig2(signal_1,signal_2);
		@(posedge clk)
		$rose(signal_2) |-> ##[0:$] $past(signal_1);
	endproperty

//ASSERTION1: lv2_wr_done should not be asserted without lv2_wr being asserted in previous cycle
    assert_lv2_wr_done: assert property (prop_sig1_before_sig2(lv2_wr,lv2_wr_done))
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion assert_lv2_wr_done Failed: lv2_wr not asserted before lv2_wr_done goes high"))

//ASSERTION2: data_in_bus_lv1_lv2 and cp_in_cache should not be asserted without lv2_rd being asserted in previous cycle

//ASSERTION2: data_in_bus_lv1_lv2 should not be asserted without lv2_rd being asserted in previous cycle

assert_data_in_bus_cp_in_cache_lv2_rd: assert property (prop_sig1_sometime_before_sig2(lv2_rd,data_in_bus_lv1_lv2))
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion assert_data_in_bus_lv1_lv2_and_cp_in_cache failed: lv2_rd not asserted before data_in_bus_lv1_lv2 and cp_in_cache are asserted"))

//ASSERTION3: bus_lv1_lv2_gnt_lv2 should not be asserted without bus_lv1_lv2_req_lv2 being asserted
    assert_bus_lv1_lv2_gnt_req: assert property (prop_sig1_sometime_before_sig2(bus_lv1_lv2_req_lv2,bus_lv1_lv2_gnt_lv2))
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion assert_bus_lv1_lv2_gnt_req Failed: bus_lv1_lv2_req_lv2 not asserted before bus_lv1_lv2_gnt_lv2 is asserted"))
	
//ASSERTION4: bus_lv1_lv2_gnt_proc should not be asserted without bus_lv1_lv2_req_proc being asserted
    assert_bus_lv1_lv2_gnt_req_proc: assert property (prop_sig1_sometime_before_sig2(bus_lv1_lv2_req_proc,bus_lv1_lv2_gnt_proc))
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion assert_bus_lv1_lv2_gnt_req_proc Failed: bus_lv1_lv2_req_proc not asserted before bus_lv1_lv2_gnt_proc is asserted"))
	
//ASSERTION5: bus_lv1_lv2_gnt_snoop should not be asserted without bus_lv1_lv2_req_snoop being asserted
    assert_bus_lv1_lv2_gnt_req_snoop: assert property (prop_sig1_sometime_before_sig2(bus_lv1_lv2_req_snoop,bus_lv1_lv2_gnt_snoop))
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion assert_bus_lv1_lv2_gnt_req_snoop Failed: bus_lv1_lv2_req_snoop not asserted before bus_lv1_lv2_gnt_snoop  is asserted"))
	
//ASSERTION6: checking invalidate signa;
property prop2_sig1_before_sig2(signal_1,signal_2);
    @(posedge clk)
        signal_2 |-> ##[0:$] $past(signal_1);
    endproperty

	assert_invalidate_signal_check : assert property( prop2_sig1_before_sig2(invalidate, all_invalidation_done))
	 else
    `uvm_error("system_bus_interface",$sformatf("Assertion assert_invalidate_signal_check Failed: all_invalidation_done raised high without any invalidate"))
	
//ASSERTION7 : grant and snoop signals must go low only after cpu_rd goes low!!!DOUBTFUL
	 property gnt_snoop_cpu_rd;
	 @(posedge clk)
		($fell(bus_lv1_lv2_gnt_snoop[0]) && $fell(bus_lv1_lv2_req_snoop[0]))|-> $past($fell(bus_rd));
	endproperty

	assert_grant_snoop_bus_cpu_rd :  assert property (gnt_snoop_cpu_rd)
	else
    `uvm_error("system_bus_interface",$sformatf("Assertion assert_grant_snoop_bus_cpu_rd Failed: gnt and snoop behaviour to be checked"))
	
//ASSERTION 8: data_in_bus_lv1_lv2 goes 
	property read_data_checking;
	@(posedge clk)
		$fell(data_in_bus_lv1_lv2)|-> ##[0:$] $past($fell(bus_rd));
	endproperty
	
	assert_read_check :  assert property(read_data_checking)
	else
    `uvm_error("system_bus_interface",$sformatf("Assertion assert_read_check Failed:Read failed"))
	



//TODO: Add assertions at this interface
//There are atleast 20 such assertions. Add as many as you can!!



endinterface
