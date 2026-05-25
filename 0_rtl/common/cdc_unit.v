//===========================================================================
//-- File Version    : 1.00
//-- Date            : 26/5/23
//-- Author          : kido
//-- IP Name         : CDC unit (synchronizer)
//-- History         : ver.1.00 (26/5/23) 1st release
//--                 :
//===========================================================================
module cdc_unit #(
    parameter P_W       = 1,
    parameter P_FF_NUM  = 2
) (
    input                   clk,
    input                   rst_n,
    input   [P_W - 1 : 0]   i_data,
    output  [P_W - 1 : 0]   o_data
);
//---------------------------------------------------------------------------
    // PARAMETER HERE
//---------------------------------------------------------------------------
    // VARIABLE
    reg [P_W - 1 : 0]   data_r [P_FF_NUM];
//---------------------------------------------------------------------------
    // first FF
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            data_r[0] <= 0;
        else
            data_r[0] <= i_data;
    end
    // other FF
    generate
        genvar id;
        for(id = 1; id < P_FF_NUM; id = id + 1) begin
            always @(posedge clk or negedge rst_n) begin
                if(!rst_n)
                    data_r[id] <= 0;
                else
                    data_r[id] <= data_r[id - 1];
            end
        end
    endgenerate
    // output
    assign o_data = data_r[P_FF_NUM - 1];
endmodule