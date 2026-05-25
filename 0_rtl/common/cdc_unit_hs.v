//===========================================================================
//-- File Version    : 1.00
//-- Date            : 26/5/23
//-- Author          : kido
//-- IP Name         : CDC unit handshake (synchronizer)
//-- History         : ver.1.00 (26/5/23) 1st release
//--                 :
//===========================================================================
module cdc_unit_hs #(
    parameter P_W       = 1,
    parameter P_FF_NUM  = 2
) (
    // WRITE SIDE
    input                   w_clk,
    input                   w_rst_n,
    input   [P_W - 1 : 0]   i_w_data,
    output                  o_w_ready,
    // READ SIDE
    input                   r_clk,
    input                   r_rst_n,
    output  [P_W - 1 : 0]   o_r_data
);
//---------------------------------------------------------------------------
    // PARAMETER HERE
//---------------------------------------------------------------------------
    // VARIABLE
    // synchronized FF _r (register)
    reg [P_W - 1 : 0]   r_data_r [P_FF_NUM];
    reg [P_W - 1 : 0]   w_data_r [P_FF_NUM];
//---------------------------------------------------------------------------
    // READ SIDE
    // first FF
    always @(posedge r_clk or negedge r_rst_n) begin
        if(!r_rst_n)
            r_data_r[0] <= 0;
        else
            r_data_r[0] <= i_w_data;
    end
    // other FF
    generate
        genvar id;
        for(id = 1; id < P_FF_NUM; id = id + 1) begin
            always @(posedge r_clk or negedge r_rst_n) begin
                if(!r_rst_n)
                    r_data_r[id] <= 0;
                else
                    r_data_r[id] <= r_data_r[id - 1];
            end
        end
    endgenerate
    // output
    assign o_data = r_data_r[P_FF_NUM - 1];
//---------------------------------------------------------------------------
    // WRITE SIDE
    always @(posedge w_clk or negedge w_rst_n) begin
        if(!w_rst_n)
            w_data_r[0] <= 0;
        else
            w_data_r[0] <= r_data_r[P_FF_NUM - 1];
    end
    // other FF
    generate
        genvar id;
        for(id = 1; id < P_FF_NUM; id = id + 1) begin
            always @(posedge w_clk or negedge w_rst_n) begin
                if(!w_rst_n)
                    w_data_r[id] <= 0;
                else
                    w_data_r[id] <= w_data_r[id - 1];
            end
        end
    endgenerate
    // output ready (handshake)
    assign o_w_ready = (w_data_r[P_FF_NUM - 1] == i_w_data);
//---------------------------------------------------------------------------
endmodule