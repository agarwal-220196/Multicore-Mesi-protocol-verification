/*

MESI LRU INTERFACE || TEAM 1 




*/

interface cpu_mesi_lru_interface(input clk);

	import uvm_pkg::*;
    	`include "uvm_macros.svh"

	// MESI
    	parameter	MESI_WID	=	`MESI_WID_LV1;

// LRU
    parameter	ASSOC_WID   =	`ASSOC_WID_LV1;
    parameter	INDEX_MSB   =	`INDEX_MSB_LV1;
    parameter	INDEX_LSB   =	`INDEX_LSB_LV1;
	parameter	TAG_MSB		=	`TAG_MSB_LV1; 
	parameter	TAG_LSB		=	`TAG_LSB_LV1;
    parameter	LRU_VAR_WID =	`LRU_VAR_WID_LV1;
    parameter	NUM_OF_SETS =	`NUM_OF_SETS_LV1;
	parameter	ADDR_WID	=	`ADDR_WID_LV1;

// MESI
    logic	cpu_rd;
    logic   cpu_wr;
    logic 	bus_rd;
    logic	bus_rdx;
    logic 	invalidate;
    logic 	shared;
    logic	[MESI_WID - 1 : 0]	current_mesi_proc       ;
    logic	[MESI_WID - 1 : 0]	current_mesi_snoop      ;
    logic	[MESI_WID - 1 : 0]	updated_mesi_proc       ;
    logic	[MESI_WID - 1 : 0]	updated_mesi_snoop      ;

   // LRU
    logic [INDEX_MSB : INDEX_LSB ] index_proc		   ;
	logic [TAG_MSB   : TAG_LSB ]	tag_proc		   ;
    logic [ASSOC_WID - 1 : 0]	   blk_accessed_main	   ;
    logic [ASSOC_WID - 1 : 0]	   lru_replacement_proc    ;
	wire				blk_hit_proc;

logic [ADDR_WID - 1       : 0]	addr_bus_lv1_lv2;
	
	assign addr_bus_lv1_lv2 = {tag_proc, index_proc, 2'b00};

	parameter INVALID   = 2'b00;
    parameter SHARED    = 2'b01;
    parameter EXCLUSIVE = 2'b10;
    parameter MODIFIED  = 2'b11;

    // MESI Covergroup
    covergroup cover_mesi @(posedge clk);
	option.per_instance=1;
	option.name = "cover_mesi";
        
cov_proc_cur: coverpoint current_mesi_proc iff (cpu_rd || cpu_wr) {
            bins BIN_INVALID   = INVALID;
            bins BIN_SHARED    = SHARED;
            bins BIN_EXCLUSIVE = EXCLUSIVE;
            bins BIN_MODIFIED  = MODIFIED;            
        }

cov_proc_upd: coverpoint updated_mesi_proc iff (cpu_rd || cpu_wr) {
            bins BIN_INVALID   = INVALID;
            bins BIN_SHARED    = SHARED;
            bins BIN_EXCLUSIVE = EXCLUSIVE;
            bins BIN_MODIFIED  = MODIFIED;            
        }

cov_snoop_cur: coverpoint current_mesi_snoop iff (bus_rd || bus_rdx || invalidate) {
            bins BIN_INVALID   = INVALID;
            bins BIN_SHARED    = SHARED;
            bins BIN_EXCLUSIVE = EXCLUSIVE;
            bins BIN_MODIFIED  = MODIFIED;            
        }
cov_snoop_upd: coverpoint updated_mesi_snoop iff (bus_rd || bus_rdx || invalidate) {
            bins BIN_INVALID   = INVALID;
            bins BIN_SHARED    = SHARED;
            bins BIN_EXCLUSIVE = EXCLUSIVE;
            bins BIN_MODIFIED  = MODIFIED;            
        }
  endgroup

    // LRU Covergroup
   covergroup cover_lru @(posedge clk);

	option.per_instance = 1;
	option.name = "cover_lru";
    
	cov_index_proc: coverpoint index_proc{
	    option.auto_bin_max = 10;
	}
	cov_tag_proc : coverpoint tag_proc{
		option.auto_bin_max=10;
		}
	cov_blk_accessed_main: coverpoint blk_accessed_main;
	cov_lru_replacement_proc: coverpoint lru_replacement_proc;
endgroup

cover_lru COVER_LRU=new;
cover_mesi COVER_MESI=new;
/*
forever
begin
COVER_MESI.sample();
COVER_LRU.sample();

end */
endinterface





















