//=====================================================================
// Project: 4 core MESI cache design
// File Name: test_lib.svh
// Description: Base test class and list of tests
// Designers: Venky & Suru
//=====================================================================
//TODO: add your testcase files in here
`include "base_test.sv"
`include "read_miss_icache.sv"
`include "read_miss_dcache.sv"

`include "write_miss_dcache.sv"
`include "write_miss_icache.sv"
`include "read_miss0_read_hit1_dcache.sv"
`include "read_w0_r0_r0_dcache.sv" 
`include "W0_R1_W1same_addr_dcache.sv"
`include "R0_W1_R0_same_addr_dcache.sv"
`include "R0_R1_W2_R1_same_addr_dcache.sv"
`include "R1_R0_R2_R3_W0_R1same_addr_dcache.sv"
`include "LRU_check_test.sv"
`include "W0_W0_R0_same_addr_dcache.sv"
`include "W0_W0_R1_same_addr_dcache.sv"
