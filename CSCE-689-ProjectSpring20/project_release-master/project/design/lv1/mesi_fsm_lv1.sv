//=====================================================================
// Project : 4 core MESI cache design
// File Name : mesi_fsm_lv1.sv
// Description : MESI protocol state machine lv1
// Designer : Yuhao Yang
//=====================================================================
// Notable Change History:
// Date By   Version Change Description
// 2016/4/14  1.0     Initial Release
//=====================================================================

module mesi_fsm_lv1 #(
                       parameter MESI_WID = `MESI_WID_LV1
                     )(
                       input                         cpu_rd             ,
                       input                         cpu_wr             ,
                       input                         bus_rd             ,
                       input                         bus_rdx            ,
                       input                         invalidate         ,
                       input                         shared             ,
                       input      [MESI_WID - 1 : 0] current_mesi_proc  ,
                       input      [MESI_WID - 1 : 0] current_mesi_snoop ,
                       output reg [MESI_WID - 1 : 0] updated_mesi_proc  ,
                       output reg [MESI_WID - 1 : 0] updated_mesi_snoop
                     );
    parameter INVALID   = 2'b00;
    parameter SHARED    = 2'b01;
    parameter EXCLUSIVE = 2'b10;
    parameter MODIFIED  = 2'b11;

    // proc side mesi logic
    always @* begin
        updated_mesi_proc = INVALID;
        case (current_mesi_proc)
            MODIFIED: begin
                updated_mesi_proc = MODIFIED;
            end
            EXCLUSIVE: begin
                if (cpu_rd)
                    updated_mesi_proc = EXCLUSIVE;
                else if (cpu_wr)
                    updated_mesi_proc = MODIFIED;
                else
                    updated_mesi_proc = EXCLUSIVE;
            end
            SHARED: begin
                if (cpu_rd)
                    updated_mesi_proc = SHARED;
                else if (cpu_wr)
                    updated_mesi_proc = MODIFIED;
                else
                    updated_mesi_proc = SHARED;
            end
            INVALID: begin
                if (cpu_rd && !shared)
                    updated_mesi_proc = EXCLUSIVE;
                else if (cpu_rd && shared)
                    updated_mesi_proc = SHARED;
                else if (cpu_wr)
                    updated_mesi_proc = MODIFIED;
                else
                    updated_mesi_proc = INVALID;
            end
            default:
                updated_mesi_proc = INVALID;
        endcase
    end

    // snoop side mesi logic

    always @* begin
        updated_mesi_snoop = INVALID;
        case(current_mesi_snoop)
            MODIFIED: begin
                if(bus_rd)
                    updated_mesi_snoop = SHARED;
                else if(bus_rdx)
                    updated_mesi_snoop = INVALID;
                else
                    updated_mesi_snoop = MODIFIED;
            end
            EXCLUSIVE: begin
                if(bus_rd)
                    updated_mesi_snoop = SHARED;
                else if(bus_rdx)
                    updated_mesi_snoop = INVALID;
                else
                    updated_mesi_snoop = EXCLUSIVE;
            end
            SHARED: begin
                if(bus_rdx || invalidate)
                    updated_mesi_snoop = INVALID;
                else
                    updated_mesi_snoop = SHARED;
            end
            INVALID: begin
                updated_mesi_snoop = INVALID;
            end
            default: updated_mesi_snoop = INVALID;
        endcase
    end


endmodule
