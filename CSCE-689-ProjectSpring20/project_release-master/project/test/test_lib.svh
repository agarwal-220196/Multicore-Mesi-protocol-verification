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
`include "r0_w1_r1_same_addr_dcache.sv"
`include "w0_r1_w2_same_addr_dcache.sv"
