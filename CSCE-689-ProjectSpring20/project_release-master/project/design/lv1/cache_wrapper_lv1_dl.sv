//=====================================================================
// Project : 4 core MESI cache design
// File Name : cache_wrapper_lv1_dl.sv
// Description : cache wrapper for level 1 data level
// Designer : Yuhao Yang
//=====================================================================
// Notable Change History:
// Date By   Version Change Description
// 2016/4/19  1.0     Initial Release
//=====================================================================

module cache_wrapper_lv1_dl #(
                                parameter ASSOC              = `ASSOC_LV1              ,
                                parameter ASSOC_WID          = `ASSOC_WID_LV1          ,
                                parameter DATA_WID           = `DATA_WID_LV1           ,
                                parameter ADDR_WID           = `ADDR_WID_LV1           ,
                                parameter INDEX_MSB          = `INDEX_MSB_LV1          ,
                                parameter INDEX_LSB          = `INDEX_LSB_LV1          ,
                                parameter TAG_MSB            = `TAG_MSB_LV1            ,
                                parameter TAG_LSB            = `TAG_LSB_LV1            ,
                                parameter OFFSET_MSB         = `OFFSET_MSB_LV1         ,
                                parameter OFFSET_LSB         = `OFFSET_LSB_LV1         ,
                                parameter CACHE_DATA_WID     = `CACHE_DATA_WID_LV1     ,
                                parameter CACHE_TAG_MSB      = `CACHE_TAG_MSB_LV1      ,
                                parameter CACHE_TAG_LSB      = `CACHE_TAG_LSB_LV1      ,
                                parameter CACHE_DEPTH        = `CACHE_DEPTH_LV1        ,
                                parameter CACHE_MESI_MSB     = `CACHE_MESI_MSB_LV1     ,
                                parameter CACHE_MESI_LSB     = `CACHE_MESI_LSB_LV1     ,
                                parameter CACHE_TAG_MESI_WID = `CACHE_TAG_MESI_WID_LV1 ,
                                parameter MESI_WID           = `MESI_WID_LV1           ,
                                parameter OFFSET_WID         = `OFFSET_WID_LV1         ,
                                parameter LRU_VAR_WID        = `LRU_VAR_WID_LV1        ,
                                parameter NUM_OF_SETS        = `NUM_OF_SETS_LV1        ,
                                parameter TAG_WID            = `TAG_WID_LV1
                             )(
                             input                           clk                     ,
                             input  [1                  : 0] core_id                 ,
                             inout  [DATA_WID - 1       : 0] data_bus_lv1_lv2        ,
                             inout  [ADDR_WID - 1       : 0] addr_bus_lv1_lv2        ,
                             inout  [DATA_WID - 1       : 0] data_bus_cpu_lv1        ,
                             input  [ADDR_WID - 1       : 0] addr_bus_cpu_lv1        ,
                             output                          lv2_rd                  ,
                             output                          lv2_wr                  ,
                             input                           lv2_wr_done             ,
                             input                           cpu_rd                  ,
                             input                           cpu_wr                  ,
                             output                          cpu_wr_done             ,
                             inout                           bus_rd                  ,
                             inout                           bus_rdx                 ,
                             input                           bus_lv1_lv2_gnt_proc    ,
                             output                          bus_lv1_lv2_req_proc_dl ,
                             input                           bus_lv1_lv2_gnt_snoop   ,
                             output                          bus_lv1_lv2_req_snoop   ,
                             output                          data_in_bus_cpu_lv1_dl  ,
                             inout                           data_in_bus_lv1_lv2     ,
                             inout                           invalidate              ,
                             input                           all_invalidation_done   ,
                             input                           shared                  ,
                             output                          shared_local            ,
                             output                          cp_in_cache             ,
                             output                          invalidation_done

                         );

    wire [ASSOC_WID - 1      : 0] lru_replacement_proc;
    wire [MESI_WID - 1       : 0] updated_mesi_proc;
    wire [MESI_WID - 1       : 0] updated_mesi_snoop;
    wire [ASSOC_WID - 1      : 0] blk_accessed_main;
    wire                          lru_update;
    wire [MESI_WID - 1       : 0] current_mesi_proc;
    wire [MESI_WID - 1       : 0] current_mesi_snoop;


    cache_controller_lv1_dl #(
                                .ASSOC_WID(ASSOC_WID),
                                .INDEX_MSB(INDEX_MSB),
                                .INDEX_LSB(INDEX_LSB),
                                .LRU_VAR_WID(LRU_VAR_WID),
                                .NUM_OF_SETS(NUM_OF_SETS),
                                .ADDR_WID(ADDR_WID),
                                .MESI_WID(MESI_WID),
                                .OFFSET_MSB(OFFSET_MSB),
                                .OFFSET_LSB(OFFSET_LSB),
                                .TAG_MSB(TAG_MSB),
                                .TAG_LSB(TAG_LSB)
                            )
                             inst_cache_controller_lv1_dl (
                                                            .blk_accessed_main(blk_accessed_main),
                                                            .lru_update(lru_update),
                                                            .lru_replacement_proc(lru_replacement_proc),
                                                            .cpu_rd(cpu_rd),
                                                            .cpu_wr(cpu_wr),
                                                            .bus_rd(bus_rd),
                                                            .bus_rdx(bus_rdx),
                                                            .invalidate(invalidate),
                                                            .shared(shared),
                                                            .current_mesi_proc(current_mesi_proc),
                                                            .current_mesi_snoop(current_mesi_snoop),
                                                            .updated_mesi_proc(updated_mesi_proc),
                                                            .updated_mesi_snoop(updated_mesi_snoop),
                                                            .addr_bus_cpu_lv1(addr_bus_cpu_lv1)
                                                        );

    cache_block_lv1_dl #(
                        .ASSOC(ASSOC),
                        .ASSOC_WID(ASSOC_WID),
                        .DATA_WID(DATA_WID),
                        .ADDR_WID(ADDR_WID),
                        .INDEX_MSB(INDEX_MSB),
                        .INDEX_LSB(INDEX_LSB),
                        .TAG_MSB(TAG_MSB),
                        .TAG_LSB(TAG_LSB),
                        .OFFSET_MSB(OFFSET_MSB),
                        .OFFSET_LSB(OFFSET_LSB),
                        .CACHE_DATA_WID(CACHE_DATA_WID),
                        .CACHE_TAG_MSB(CACHE_TAG_MSB),
                        .CACHE_TAG_LSB(CACHE_TAG_LSB),
                        .CACHE_DEPTH(CACHE_DEPTH),
                        .CACHE_MESI_MSB(CACHE_MESI_MSB),
                        .CACHE_MESI_LSB(CACHE_MESI_LSB),
                        .CACHE_TAG_MESI_WID(CACHE_TAG_MESI_WID),
                        .MESI_WID(MESI_WID),
                        .OFFSET_WID(OFFSET_WID),
                        .TAG_WID(TAG_WID)
                    )
                     inst_cache_block_lv1_dl (
                                                .clk(clk),
                                                .core_id(core_id),
                                                .data_bus_lv1_lv2(data_bus_lv1_lv2),
                                                .addr_bus_lv1_lv2(addr_bus_lv1_lv2),
                                                .data_bus_cpu_lv1(data_bus_cpu_lv1),
                                                .addr_bus_cpu_lv1(addr_bus_cpu_lv1),
                                                .lv2_rd(lv2_rd),
                                                .lv2_wr(lv2_wr),
                                                .lv2_wr_done(lv2_wr_done),
                                                .cpu_rd(cpu_rd),
                                                .cpu_wr(cpu_wr),
                                                .cpu_wr_done(cpu_wr_done),
                                                .bus_rd(bus_rd),
                                                .bus_rdx(bus_rdx),
                                                .bus_lv1_lv2_gnt_proc(bus_lv1_lv2_gnt_proc),
                                                .bus_lv1_lv2_req_proc_dl(bus_lv1_lv2_req_proc_dl),
                                                .bus_lv1_lv2_gnt_snoop(bus_lv1_lv2_gnt_snoop),
                                                .bus_lv1_lv2_req_snoop(bus_lv1_lv2_req_snoop),
                                                .lru_replacement_proc(lru_replacement_proc),
                                                .data_in_bus_cpu_lv1_dl(data_in_bus_cpu_lv1_dl),
                                                .data_in_bus_lv1_lv2(data_in_bus_lv1_lv2),
                                                .invalidate(invalidate),
                                                .all_invalidation_done(all_invalidation_done),
                                                .updated_mesi_proc(updated_mesi_proc),
                                                .updated_mesi_snoop(updated_mesi_snoop),
                                                .current_mesi_proc(current_mesi_proc),
                                                .current_mesi_snoop(current_mesi_snoop),
                                                .shared_local(shared_local),
                                                .cp_in_cache(cp_in_cache),
                                                .invalidation_done(invalidation_done),
                                                .blk_accessed_main(blk_accessed_main),
                                                .lru_update(lru_update)
                                            );

endmodule
