#!/bin/bash
#add passing test cases here
declare arr=(
read_miss_icache r0_w1_r0_same_addr_dcache read_miss_icache w0_r1_w2_same_addr_dcache 
base_test R0_W1_R0_same_addr_dcache read_w0_r0_r0_dcache w0_w0_r0_same_addr_dcache 
LRU_check_test r0_w1_r1_same_addr_dcache W0_W0_R0_same_addr_dcache 
r0_r0_same_addr_dcache r0_w1_r2_same_addr_dcache w0_r0_w0_r0_same_addr_dcache W0_W0_R1_same_addr_dcache 
r0_r1_same_addr_dcache R0_W1_W0_same_addr_dcache W0_R0_W0_same_addr_dcache W0_W1_R0_same_addr_dcache 
r0_r1_w0_same_addr_dcache r0_w1_w1_same_addr_dcache W0_R0_W0_samedata_same_addr_dcache w0_w1_r1_same_addr_dcache 
R0_R1_W2_R1_same_addr_dcache R1_R0_R2_R3_W0_R1same_addr_dcache W0_R0_W1_same_addr_dcache W0_W1_R2_same_addr_dcache 
r0_w0_r1_same_addr_dcache W0_R1_W0_same_addr_dcache w1_w0_r0_same_addr_dcache 
r0_w0_w0_same_addr_dcache read_miss0_read_hit1_dcache W0_R1_W1_same_addr_dcache write_miss_dcache 
r0_w0_w1_same_addr_dcache read_miss_dcache W0_R1_W1same_addr_dcache write_miss_icache 
read_miss_icache r0_w1_r2_same_addr_dcache_random w0_r0_w0_r0_same_addr_dcache_random w0_w1_r1_same_addr_dcache_random w0_w0_r0_same_addr_dcache_random
w1_w0_r0_same_addr_dcache_random LRU_check_test_write_to_mem
)
#declare arr ={ r0_w1_r2_same_addr_dcache W0_R1_W1same_addr_dcache}
#number of times to run each test case
if [[ $# -eq 0 ]]; then
    LIMIT=1
else
    LIMIT=$1
fi


if [! -d logs]; then
    mkdir logs
fi
source ../../setup.bash
./CLEAR_LOGS
./CLEAR
irun -f cmd_line_comp_elab.f

for i in "${arr[@]}"
do
    for ((j=1; j<= LIMIT; j++))
    do
        irun -f cmd_line.f +UVM_TESTNAME=$i -covtest "$i"_"$j" -svseed random
        mv irun.log logs/"$i"_"$j".log
    done
done
./CLEAR
