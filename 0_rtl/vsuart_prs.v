//===========================================================================
//-- Author          : kido
//-- IP Name         : vsuart_prs (prescaler)
//-- History         : ver.1.00 (26/5/30) 1st release
//===========================================================================
module vsuart_prs (
    input               clk,
    input               rst_n,
    input               i_en,
    input   [3 : 0]     i_prs,
    output              u_clk
);
// LOCAL VARIABLE HERE ------------------------------------------------------
    reg     _clk;
    reg [4 : 0] r_cnt;
    wire sync_i_en;
//---------------------------------------------------------------------------
	cdc_unit ifs_errifs_cdc(.clk(clk), .rst_n(rst_n), .i_data(i_en), .o_data(sync_i_en));
//---------------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            _clk <= 0;
        end else if(sync_i_en) begin
            if(r_cnt == i_prs + 1) begin
                _clk <= ~_clk;
                r_cnt <= 0;
            end else begin
                r_cnt <= r_cnt + 1;
            end
        end else begin
            _clk <= 0;
            r_cnt <= 0;
        end    
    end
    // clk
    assign u_clk = _clk;
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
endmodule
//===========================================================================