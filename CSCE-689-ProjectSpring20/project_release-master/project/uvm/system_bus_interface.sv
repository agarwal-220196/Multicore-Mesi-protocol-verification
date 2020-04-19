
  
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
	
	//property that checks that signal_1 is asserted before signal_2 and also before signal_3
    property prop_sig2_sig3_follows_sig1(signal_1,signal_2,signal_3);
    @(posedge clk)
	prop_sig1_sometime_before_sig2(signal_1,signal_2) and prop_sig1_sometime_before_sig2(signal_1,signal_3);
    endproperty

//----------------------------------------------INCLUDING ALL PREVIOUS ASSERTIONS FROM LABS----------------------
//ASSERTION1: lv2_wr_done should not be asserted without lv2_wr being asserted in previous cycle
    assert_lv2_wr_done: assert property (prop_sig1_before_sig2(lv2_wr,lv2_wr_done))
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion 1 assert_lv2_wr_done Failed: lv2_wr not asserted before lv2_wr_done goes high"))

//ASSERTION2: data_in_bus_lv1_lv2 should not be asserted without lv2_rd being asserted in previous cycle

assert_data_in_bus_cp_in_cache_lv2_rd: assert property (prop_sig1_sometime_before_sig2(lv2_rd,data_in_bus_lv1_lv2))
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion 2 assert_data_in_bus_lv1_lv2_and_cp_in_cache failed: lv2_rd not asserted before data_in_bus_lv1_lv2 and cp_in_cache are asserted"))

//ASSERTION3: bus_lv1_lv2_gnt_lv2 should not be asserted without bus_lv1_lv2_req_lv2 being asserted
    assert_bus_lv1_lv2_gnt_req: assert property (prop_sig1_sometime_before_sig2(bus_lv1_lv2_req_lv2,bus_lv1_lv2_gnt_lv2))
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion 3 assert_bus_lv1_lv2_gnt_req Failed: bus_lv1_lv2_req_lv2 not asserted before bus_lv1_lv2_gnt_lv2 is asserted"))
	
//ASSERTION4: bus_lv1_lv2_gnt_proc should not be asserted without bus_lv1_lv2_req_proc being asserted
    assert_bus_lv1_lv2_gnt_req_proc: assert property (prop_sig1_sometime_before_sig2(bus_lv1_lv2_req_proc,bus_lv1_lv2_gnt_proc))
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion 4 assert_bus_lv1_lv2_gnt_req_proc Failed: bus_lv1_lv2_req_proc not asserted before bus_lv1_lv2_gnt_proc is asserted"))
	
//ASSERTION5: bus_lv1_lv2_gnt_snoop should not be asserted without bus_lv1_lv2_req_snoop being asserted
    assert_bus_lv1_lv2_gnt_req_snoop: assert property (prop_sig1_sometime_before_sig2(bus_lv1_lv2_req_snoop,bus_lv1_lv2_gnt_snoop))
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion 5 assert_bus_lv1_lv2_gnt_req_snoop Failed: bus_lv1_lv2_req_snoop not asserted before bus_lv1_lv2_gnt_snoop  is asserted"))
	
//ASSERTION6: checking invalidate signa;
property prop2_sig1_before_sig2(signal_1,signal_2);
    @(posedge clk)
        signal_2 |-> ##[0:$] $past(signal_1);
    endproperty

	assert_invalidate_signal_check : assert property( prop2_sig1_before_sig2(invalidate, all_invalidation_done))
	 else
    `uvm_error("system_bus_interface",$sformatf("Assertion 6 assert_invalidate_signal_check Failed: all_invalidation_done raised high without any invalidate"))
	
//ASSERTION7 : grant and snoop signals must go low only after cpu_rd goes low!!!DOUBTFUL
	 property gnt_snoop_cpu_rd;
	 @(posedge clk)
		($fell(bus_lv1_lv2_gnt_snoop) && $fell(bus_lv1_lv2_req_snoop))|-> $past($fell(bus_rd));
	endproperty

	assert_grant_snoop_bus_cpu_rd :  assert property (gnt_snoop_cpu_rd)
	else
    `uvm_error("system_bus_interface",$sformatf("Assertion 7 assert_grant_snoop_bus_cpu_rd Failed: gnt and snoop behaviour to be checked"))
	
//ASSERTION 8: data_in_bus_lv1_lv2 goes 
	property read_data_checking;
	@(posedge clk)
		$fell(data_in_bus_lv1_lv2)|-> ##[0:$] $past($fell(bus_rd));
	endproperty
	
	assert_read_check :  assert property(read_data_checking)
	else
    `uvm_error("system_bus_interface",$sformatf("Assertion 8 assert_read_check Failed:Read failed"))
	



//----------------------------------------------PREVIOUS ASSERTIONS END-----------------------------------------
//TODO: Add assertions at this interface
//There are atleast 20 such assertions. Add as many as you can!!
//
//ASSERTION 9: cp_in_cache should not be asserted without lv2_rd in the previous cycle
    assert_lv2_rd_before_cp_in_cache: assert property (prop_sig1_before_sig2(lv2_rd,cp_in_cache))
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion 9 assert_lv2_rd_before_cp_in_cache Failed: lv2_rd not asserted before cp_in_cache goes high"))
//ASSERTION 10:  onehot bus_lv1_lv2_gnt_proc
	assert_onehot_bus_lv1_lv2_gnt_proc : assert property (@(posedge clk) $onehot0(bus_lv1_lv2_gnt_proc))
	else	
	`uvm_error("system_bus_interface",$sformatf("Assertion 10  assert_onehot_bus_lv1_lv2_gnt_proc Failed: bus_lv1_lv2_gnt_proc  not onehot0"))
	
//ASSERTION 11: ONEHOT bus_lv1_lv2_gnt_snoop 
	assert_onehot_bus_lv1_lv2_gnt_snoop : assert property (@(posedge clk) $onehot0(bus_lv1_lv2_gnt_snoop))
	else 
	`uvm_error("system_bus_interface",$sformatf("Assertion 11 assert_onehot_bus_lv1_lv2_gnt_snoop Failed: bus_lv1_lv2_gnt_snoop  not onehot0"))
	
//ASSERTION 12: onehot bus_lv1_lv2_gnt_lv2 also?----DOUBTFUL
/*	assert_onehot_bus_lv1_lv2_gnt_lv2 : assert property (@(posedge clk) $onehot0(bus_lv1_lv2_gnt_lv2))
	else 
	`uvm_error("system_bus_interface",$sformatf("Assertion 12 assert_onehot_bus_lv1_lv2_gnt_snoop Failed: bus_lv1_lv2_gnt_lv2  not onehot0"))*/
	
//DEFINING NEW PROPERTY FOR SIMULATENOUSLY HIGH GOING SIGNALS
	property prop_simult_signal1_and_signal2(signal_1,signal_2);
        @(posedge clk)
          not(signal_1 && signal_2);
    endproperty
//ASSERTION 13: data_in_bus_lv1_lv2 and lv2_wr cannot be occuring simultaneously?----DOUBTFUL!
	
	assert_simult_data_in_bus_lv1_lv2_and_lv2_wr: assert property (prop_simult_signal1_and_signal2(data_in_bus_lv1_lv2,lv2_wr))
    else
        `uvm_error("system_bus_interface",$sformatf("Assertion 13 assert_simult_data_in_bus_lv1_lv2_and_lv2_wr Failed: data_in_bus_lv1_lv2 and lv2_wr asserted simultaneously"))

//ASSERTION 14: grants asserted from bus_lv1_lv2_gnt_snoop side and bus_lv1_lv2_gnt_proc side for a single proc- need to write separately 4 times?
	
	assert_simult_bus_lv1_lv2_gnt_proc_and_bus_lv1_lv2_gnt_snoop: assert property (prop_simult_signal1_and_signal2(bus_lv1_lv2_gnt_proc,bus_lv1_lv2_gnt_snoop))
    else
        `uvm_error("system_bus_interface",$sformatf("Assertion 14 assert_simult_bus_lv1_lv2_gnt_proc_and_bus_lv1_lv2_gnt_snoop Failed: bus_lv1_lv2_gnt_proc and bus_lv1_lv2_gnt_snoop asserted simultaneously")) 


//ASSERTION 15: lv2_rd should go low 1 cycle after data_in_bus_lv1_lv2 goes low , posedge clk iff lv2_rd
	property checking_sequence_type_1;
		@(posedge clk )
		   lv2_rd |-> ##[0:$] $rose(data_in_bus_lv1_lv2) ;
	endproperty
	assert_chceking_lv2_rd_follow_data_in_bus_lv1_lv2: assert property(checking_sequence_type_1)
	else	
		`uvm_error("system_bus_interface",$sformatf("Assertion 15 assert_chceking_lv2_rd_follow_data_in_bus_lv1_lv2 Failed: lv2_rd did not get deasserted after data_in_bus_lv1_lv2 "))




//ASSERTION 16: lv2_wr should be followed by lv2_wr_done and both should be deasserted acc to HAS
	property checking_sequence_type_lv2_wr;
		@(posedge clk)
			lv2_wr |=> ##[0:$] lv2_wr_done ##1 !lv2_wr ##1 !lv2_wr_done ;
	endproperty
	assert_checking_sequence_type_lv2_wr: assert property(checking_sequence_type_lv2_wr)
	else	
		`uvm_error("system_bus_interface",$sformatf("Assertion 16 assert_checking_sequence_type_lv2_wr Failed: lv2_rd did not get deasserted after data_in_bus_lv1_lv2 "))

/*//ASSERTION 17: data_bus_lv1_lv2 and addr_bus_lv1_lv2 should not be invalid when data_in_bus_lv1_lv2 is high or rising?
	property address_data_validity_data_in_bus_lv1_lv2;
		@(posedge clk )
			(data_in_bus_lv1_lv2) |-> (addr_bus_lv1_lv2 !== 32'hz && data_bus_lv1_lv2!== 32'hx );
		endproperty
	assert_valid_address_data_validity_data_in_bus_lv1_lv2: assert property(address_data_validity_data_in_bus_lv1_lv2)
	else	
		`uvm_error("system_bus_interface",$sformatf("Assertion 17 address_data_validity_data_in_bus_lv1_lv2 Failed: Address not valid!"))*/

//ASSERTION 18: bus_lv1_lv2_gnt_proc and bus_lv1_lv2_req_proc go low together ----IF ASSERTION FAILS , TRY WITH !bus_lv1_lv2_req_proc|->!bus_lv1_lv2_gnt_proc
	property bus_lv1_lv2_req_proc_and_grant_low;
	@(posedge clk iff bus_lv1_lv2_gnt_proc)
		$fell(bus_lv1_lv2_req_proc)|->$fell(bus_lv1_lv2_gnt_proc);
	endproperty
	
	assert_bus_lv1_lv2_req_proc_and_grant_low :  assert property(bus_lv1_lv2_req_proc_and_grant_low)
	else
    `uvm_error("system_bus_interface",$sformatf("Assertion 18  bus_lv1_lv2_req_proc_and_grant_low Failed: gnt_proc and req_prc should go low together"))

//all signals/flags should be deasserted before the beginning of any process
//ASSERTION 19: bus_lv1_lv2_gnt_snoop and bus_lv1_lv2_req_snoop go low together 
	property bus_lv1_lv2_req_snoop_and_grant_low;
	@(posedge clk iff bus_lv1_lv2_gnt_snoop)
		$fell(bus_lv1_lv2_req_snoop)|->$fell(bus_lv1_lv2_gnt_snoop);
	endproperty
	
	assert_bus_lv1_lv2_req_snoop_and_grant_low :  assert property(bus_lv1_lv2_req_snoop_and_grant_low)
	else
    `uvm_error("system_bus_interface",$sformatf("Assertion 19 bus_lv1_lv2_req_snoop_and_grant_low Failed: gnt_snoop and req_snoop should go low together"))

//ASSERTION 20: bus_lv1_lv2_gnt_lv2 and bus_lv1_lv2_req_lv2 go low together 
	property bus_lv1_lv2_req_lv2_and_grant_low;
	@(posedge clk iff bus_lv1_lv2_gnt_lv2)
		$fell(bus_lv1_lv2_req_lv2)|->$fell(bus_lv1_lv2_gnt_lv2);
	endproperty
	
	assert_bus_lv1_lv2_req_lv2_and_grant_low :  assert property(bus_lv1_lv2_req_lv2_and_grant_low)
	else
    `uvm_error("system_bus_interface",$sformatf("Assertion 20  bus_lv1_lv2_req_snoop_and_grant_low Failed: gnt_lv2 and req_lv2 should go low together"))

//ASSERTION 21:  bus_rd sequence
	property valid_bus_rd_sequence;
	@(posedge clk)
		bus_rd |=> ##[0:$] (data_in_bus_lv1_lv2) ##1 !bus_rd ##1 !data_in_bus_lv1_lv2 ;
	endproperty
	
	assert_valid_bus_rd_sequence :  assert property(valid_bus_rd_sequence)
	else
    `uvm_error("system_bus_interface",$sformatf("Assertion 21 valid_bus_rd_sequence Failed: bus_rd sequence not executed properly!"))

//ASSERTION 22: bus_lv1_lv2_req_snoop,shared,should be deasserted after data_in_bus_lv1_lv2 goes low for bus_rd -----CHECK FOR CPU_WR
	property deassertions_bus_rd_sequence;
	@(posedge clk iff bus_rd)
		$fell(data_in_bus_lv1_lv2) |-> (!bus_lv1_lv2_req_snoop && !shared); //check this code
	endproperty
	
	assert_deassertions_bus_rd_sequence :  assert property(deassertions_bus_rd_sequence)
	else
    `uvm_error("system_bus_interface",$sformatf("Assertion 22 deassertions_bus_rd_sequence Failed: bus_lv1_lv2_req_snoop and shared should go low together"))

//ASSERTION 23: bus_lv1_lv2_gnt_snoop should be asserted for bus_rd when data_in_bus_lv1_lv2 is high
	property signal_assertions_bus_rd_sequence;
	@(posedge clk iff bus_rd)
		bus_lv1_lv2_gnt_snoop |-> (data_in_bus_lv1_lv2) ; //CHECK if we can check that lv2 not access then if data_in_bus_lv1_lv2 --> bus_lv1_lv2_gnt_snoop
	endproperty
	
	assert_signal_assertions_bus_rd_sequence :  assert property(signal_assertions_bus_rd_sequence)
	else
    `uvm_error("system_bus_interface",$sformatf("Assertion 23  signal_assertions_bus_rd_sequence Failed: bus_lv1_lv2_gnt_snoop not assertd before data_in_bus_lv1_lv2"))


//ASSERTION 24: for bus_rd when bus_lv1_lv2_gnt_snoop is asserted, then shared should become high after sometime
	property signal_shared_bus_rd_sequence;
	@(posedge clk iff bus_rd)
		(bus_lv1_lv2_gnt_snoop) |=>  $rose(shared); //check this code
	endproperty
	
	assert_signal_shared_bus_rd_sequence :  assert property(signal_shared_bus_rd_sequence)
	else
    `uvm_error("system_bus_interface",$sformatf("Assertion 24 signal_shared_bus_rd_sequence Failed: shared did not get asserted after bus_lv1_lv2_gnt_snoop for bus_rd transaction"))


//ASSERTION 25: for cpu_rd, once bus_lv1_lv2_gnt_proc is asserted |=> bus_rd and lv2_rd made high and addr_bus_lv1_lv2 gets valid address value
	property signal_bus_rd_bus_rd_addr_sequence;
	@(posedge clk)
		$rose(bus_rd) |-> ($rose(lv2_rd) && addr_bus_lv1_lv2!== 32'hz) ; 
	endproperty
	
	assert_signal_bus_rd_bus_rd_addr_sequence :  assert property(signal_bus_rd_bus_rd_addr_sequence)
	else
    `uvm_error("system_bus_interface",$sformatf("Assertion 25 signal_bus_rd_bus_rd_addr_sequence Failed: bus_rd not followed by lv2_rd and addr_bus_lv1_lv2 becoming valid"))

//ASSERTION 26: if cp_in_cache is asserted then bus_lv1_lv2_req_lv2 should be dropped
	property snoop_or_lv2_onehot;
	@(posedge clk)
		lv2_rd |-> !(cp_in_cache && bus_lv1_lv2_req_lv2); //check if deassertion of other signal of the 2 next cycle or same cycle
	endproperty
	
	assert_snoop_or_lv2_onehot :  assert property(snoop_or_lv2_onehot)
	else
    `uvm_error("system_bus_interface",$sformatf("Assertion 26 snoop_or_lv2_onehot Failed: cp_in_cache and bus_lv1_lv2_req_lv2 cannot be asserted at the same time"))


//ASSERTION 27: if cp_in_cache is asserted then bus_lv1_lv2_req_snoop is asserted (i.e. at $rose bus_lv1_lv2_req_snoop, cp_in_cache should be high)
	property cp_in_cache_and_bus_lv1_lv2_req_snoop;
	@(posedge clk)
		$rose(bus_lv1_lv2_req_snoop) |-> cp_in_cache; 
	endproperty
	
	assert_cp_in_cache_and_bus_lv1_lv2_req_snoop :  assert property(cp_in_cache_and_bus_lv1_lv2_req_snoop)
	else
    `uvm_error("system_bus_interface",$sformatf("Assertion 27 cp_in_cache_and_bus_lv1_lv2_req_snoop Failed: if bus_lv1_lv2_req_snoop asserted then cp_in_cache shoould be high"))




//ASSERTION 28: lv2_rd and lv2_wr cannot occur at the same times
	assert_simult_lv2_rd_and_lv2_wr: assert property (prop_simult_signal1_and_signal2(lv2_rd,lv2_wr))
    else
        `uvm_error("system_bus_interface",$sformatf("Assertion 28 assert_simult_lv2_rd_and_lv2_wr Failed: lv2_rd and lv2_wr asserted simultaneously"))


//ASSERTION 29: lv2_rd when asserted, address should be valid
	property lv2_rd_address_validity;
	@(posedge clk)
		lv2_rd |-> addr_bus_lv1_lv2 !== 32'hz; 
	endproperty
	
	assert_lv2_rd_address_validity :  assert property(lv2_rd_address_validity)
	else
    `uvm_error("system_bus_interface",$sformatf("Assertion 29 lv2_rd_address_validity Failed: lv2_rd when asserted - address invalid!"))

//ASSERTION 30: lv2_wr when asserted, addr_bus_lv1_lv2 and data_bus_lv1_lv2 should be valid
	property lv2_wr_address_validity;
	@(posedge clk)
		lv2_wr |-> (data_bus_lv1_lv2 !==32'hx && addr_bus_lv1_lv2 !== 32'hz); 
	endproperty
	
	assert_lv2_wr_address_validity :  assert property(lv2_wr_address_validity)
	else
    `uvm_error("system_bus_interface",$sformatf("Assertion 30 lv2_wr_address_validity Failed: lv2_wr when asserted -data and/or address invalid!"))


//ASSERTION 31: invalidate should be asserted only iff cpu_wr(i.e. !bus_rd)
	property invalidate_iff_processor_wr;
	@(posedge clk)
		invalidate |-> !(bus_rd); 
	endproperty
	
	assert_invalidate_iff_processor_wr :  assert property(invalidate_iff_processor_wr)
	else
    `uvm_error("system_bus_interface",$sformatf("Assertion 31 invalidate_iff_processor_wr Failed: invalid high even though processor write not taking place!"))

//ASSERTION 32: bus_rdx means that invalid asserted (copies will be invalidated) --------NOTE OPPOSITE IS NOT TRUE!
	property invalidate_if_bus_rdx;
	@(posedge clk iff ( shared ))
		bus_rdx |=> ##[0:$] invalidate; //------------------SHOULD THE BOUND ON NUMBER OF CYCLES BE DEFINED-------------------------
	endproperty
	
	assert_invalidate_if_bus_rdx :  assert property(invalidate_if_bus_rdx)
	else
    `uvm_error("system_bus_interface",$sformatf("Assertion 32 invalidate_if_bus_rdx Failed: if bus_rdx is asserted then in few cycles invalidate will become high!"))


//ASSERTION 33: invalidate -> all_invalidation_done goes high then invalidate & all_invalidation_done go low in same cycle iff cpu_wr
	property valid_invalidate_sequence;
	@(posedge clk)
		invalidate |=> all_invalidation_done ##1 !(all_invalidation_done) && (invalidate==1'bz) ;
	endproperty
	
	assert_valid_invalidate_sequence :  assert property(valid_invalidate_sequence)
	else
    `uvm_error("system_bus_interface",$sformatf("Assertion 33 valid_invalidate_sequence Failed: invalidation sequence!"))

//ASSERTION 34: for cpu_wr, once bus_lv1_lv2_gnt_proc is asserted |=> cpu_wr and bus_rdx made high - DOUBTFUL
	property bus_rdx_then_gnt_proc;
	@(posedge clk)
		bus_rdx |-> ##[0:$]$past( bus_lv1_lv2_gnt_proc) ;
	endproperty
	
	assert_bus_rdx_then_gnt_proc :  assert property(bus_rdx_then_gnt_proc)
	else
    `uvm_error("system_bus_interface",$sformatf("Assertion 34 bus_rdx_then_gnt_proc Failed: bus_lv1_lv2_gnt_proc to be high if bus_rdx asserted!"))

//ASSERTION 35: bus_rd and bus_rdx cannot be asserted simultaneously
	assert_simult_bus_rd_and_bus_rdx: assert property (prop_simult_signal1_and_signal2(bus_rd,bus_rdx))
    else
        `uvm_error("system_bus_interface",$sformatf("Assertion 35 assert_simult_bus_rd_and_bus_rdx Failed: bus_rd and bus_rdx asserted simultaneously"))
		
//ASSERTION 36: bus_lv1_lv2_gnt_lv2 should not be high without bus_lv1_lv2_gnt_proc
	property bus_lv1_lv2_gnt_lv2_then_bus_lv1_lv2_gnt_proc;
	@(posedge clk)
		bus_lv1_lv2_gnt_lv2 |-> ##[0:$] $past( bus_lv1_lv2_gnt_proc) ;
	endproperty
	
	assert_bus_lv1_lv2_gnt_lv2_then_bus_lv1_lv2_gnt_proc :  assert property(bus_lv1_lv2_gnt_lv2_then_bus_lv1_lv2_gnt_proc)
	else
    `uvm_error("system_bus_interface",$sformatf("Assertion 36 bus_lv1_lv2_gnt_lv2_then_bus_lv1_lv2_gnt_proc Failed: bus_lv1_lv2_gnt_proc to be high if bus_lv1_lv2_req_lv2 asserted!"))

//ASSERTION 37: bus_lv1_lv2_gnt_snoop should not be high without bus_lv1_lv2_gnt_proc
	property bus_lv1_lv2_gnt_snoop_then_bus_lv1_lv2_gnt_proc;
	@(posedge clk)
		bus_lv1_lv2_gnt_snoop |-> bus_lv1_lv2_gnt_proc ;
	endproperty
	
	assert_bus_lv1_lv2_gnt_snoop_then_bus_lv1_lv2_gnt_proc :  assert property(bus_lv1_lv2_gnt_snoop_then_bus_lv1_lv2_gnt_proc)
	else
    `uvm_error("system_bus_interface",$sformatf("Assertion 37 bus_lv1_lv2_gnt_snoop_then_bus_lv1_lv2_gnt_proc Failed: bus_lv1_lv2_gnt_proc to be high if bus_lv1_lv2_req_snoop asserted!"))

	
//ASSERTION 38: bus snoop should not go high without shared being high 
	property snoop_high_after_shared_only;
	@(posedge clk)
		bus_lv1_lv2_req_snoop |-> shared;
	endproperty

	assert_snoop_high_after_shared_only : assert property(snoop_high_after_shared_only)
	else 
	`uvm_error("system_bus_interface",$sformatf("Assertion 38 snoop_high_after_shared_only Failed: data not shared is being provided with some other cache "))  

//data_in_bus_lv1_lv2 goes low then bus_lv1_lv2_gnt_proc also goes low


//--------------------INCLUDE ALSO THE SIGNALS THAT SHOULD NOT BE ASSERTED !-----------------------ABSENCE OF BUGS
//WRITE MISS SCENARIOS TO BE INCLUDED - WHERE COPIES RESIDE IN LV2 ONLY
//for lv2 read scenario(detected by !cp_in_cache & lv2_rd ), bus_lv1_lv2_gnt_lv2 should be high 
//when lv2_wr_done is asserted then bus_lv1_lv2_gnt_lv2 should be high
//WHEN IS cp_in_cache deasserted ?
//: data_in_bus_lv1_lv2 goes from invalid to high, then lv2_rd should also be high
endinterface
