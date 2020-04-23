//=====================================================================
// Project: 4 core MESI cache design
// File Name: cpu_lv1_interface.sv
// Description: Basic CPU-LV1 interface with assertions
// Designers: Venky & Suru
//=====================================================================


interface cpu_lv1_interface(input clk);

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    parameter DATA_WID_LV1           = `DATA_WID_LV1       ;
    parameter ADDR_WID_LV1           = `ADDR_WID_LV1       ;

    reg   [DATA_WID_LV1 - 1   : 0] data_bus_cpu_lv1_reg    ;

    wire  [DATA_WID_LV1 - 1   : 0] data_bus_cpu_lv1        ;
    logic [ADDR_WID_LV1 - 1   : 0] addr_bus_cpu_lv1        ;
    logic                          cpu_rd                  ;
    logic                          cpu_wr                  ;
    logic                          cpu_wr_done             ;
    logic                          data_in_bus_cpu_lv1     ;

    assign data_bus_cpu_lv1 = data_bus_cpu_lv1_reg ;

//Assertions
//ASSERTION1: cpu_wr and cpu_rd should not be asserted at the same clock cycle
    property prop_simult_cpu_wr_rd;
        @(posedge clk)
          not(cpu_rd && cpu_wr);
    endproperty

    assert_simult_cpu_wr_rd: assert property (prop_simult_cpu_wr_rd)
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion 1 assert_simult_cpu_wr_rd Failed: cpu_wr and cpu_rd asserted simultaneously"))

//TODO: Add assertions at this interface
//----------------------------------ADDING ALL THE PREVIOUS ASSERTIONS FROM LABS----------------------


//LAB5 : TO DO: Add 4 assertions at this interface

// Assertion2 - MODIFIED: Data_in_bus_cpu_lv1 is high only after data_bus_cpu_lv1 goes high in same cycle
 property prop_simult_data;
        @(posedge clk iff cpu_rd)
			(data_in_bus_cpu_lv1) |-> (data_bus_cpu_lv1 !== 32'hz);
    endproperty
	
	assert_simult_data :  assert property (prop_simult_data)
	else 	
		`uvm_error("cpu_lv1_interface",$sformatf("Assertion 2 assert_simult_data Failed: Data_in_bus_cpu_lv1 raised before data is available"))
		
		
//Assertion3: cpu_wr_done before cpu_wr occurs 
 property prop_write_check;
        @(posedge clk)
			cpu_wr_done |-> ($past (cpu_wr) == 1);
    endproperty

	assert_write_check : assert property (prop_write_check)
	else 
		`uvm_error("cpu_lv1_interface",$sformatf("Assertion 3 assert_write_check Failed: write done is made high without cpu_write being high") )


	
// ASSERTION 4: Valid address (greater than or equal to 32'h4000_0000) should be provided by a processor for write operation, since any address below that refers to instruction cache, which cannot be written to
	property prop_cache_valid_address;
		@(posedge clk)
		$rose(cpu_wr) |->  (addr_bus_cpu_lv1 >= 32'h40000000);
	endproperty
	assert_cache_valid_address: assert property (prop_cache_valid_address)
	else
	`uvm_error("cpu_lv1_interface",$sformatf("Assertion 4 assert_cache_valid_address failed: Write to icache is invalid"))
	
	//ASSERTION 5 (modified - REMOVED $PAST): data_in_bus_cpu_lv1 signal should be high following a cpu_rd request
	property data_in_bus_following_rd_wr;
		@(posedge clk)
		$rose(data_in_bus_cpu_lv1) |-> $past(cpu_rd);
	endproperty
	assert_data_in_bus_following_rd_wr: assert property (data_in_bus_following_rd_wr)
	else
	`uvm_error("cpu_lv1_interface",$sformatf("Assertion 5 assert_data_in_bus_following_rd_wr failed: data_in_bus_cpu_lv1 asserted without cpu_rd or cpu_wr signal"))
	
	//ASSERTION 6: if a signal occurs, then following sequence should also take place
	
	property checking_sequence_type_1;
		@(posedge clk iff cpu_rd)
			$rose(data_in_bus_cpu_lv1)|=> $fell(cpu_rd) |=> $fell (data_in_bus_cpu_lv1);
	endproperty
	assert_checking_data_in_cpu_rd_seq: assert property (checking_sequence_type_1)
	else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion 6 checking_sequence_type_1 Failed: data_in_bus_cpu_lv1 and cpu_rd sequence"))


//ASSERTION 7: cpu_wr_done should follow cpu_wr

	property checking_sequence_type_3;
		@(posedge clk)
		$rose(cpu_wr)|=>##[0:$] $rose(cpu_wr_done)|=> $fell(cpu_wr)|=>$fell(cpu_wr_done);
	endproperty
	assert_chceking_cpu_wr_follow_cpu_wr_done: assert property(checking_sequence_type_3)
	else	
		`uvm_error("cpu_lv1_interface",$sformatf("Assertion 7 checking_sequence_type_3 Failed: cpu_wr and cpu_wr_done don't follow each other "))
		
//ASSERTION 8: checking validity of address while reading.
	property address_validity_cpu_rd;
		@(posedge clk)
			cpu_rd |-> (addr_bus_cpu_lv1 !== 32'hz);
		endproperty
	assert_valid_address_cpu_rd: assert property(address_validity_cpu_rd)
	else	
		`uvm_error("cpu_lv1_interface",$sformatf("Assertion 8 address_validity_cpu_rd Failed: Address not validity"))
	
	
//ASSETION 9: checking validity of data and address
	property address_data_validity_cpu_wr;
		@(posedge clk )
			(cpu_wr) |-> (addr_bus_cpu_lv1 !== 32'hz && data_bus_cpu_lv1!== 32'hx );
		endproperty
	assert_valid_address_data_cpu_wr: assert property(address_data_validity_cpu_wr)
	else	
		`uvm_error("cpu_lv1_interface",$sformatf("Assertion 9 address_validity_cpu_rd Failed: Address not validity"))
	
endinterface
