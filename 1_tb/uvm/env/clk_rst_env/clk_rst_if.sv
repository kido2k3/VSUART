//===========================================================================
//-- Author         : kido
//-- Name           : clk_rst_if (clk reset interface)
//-- History        : ver.1.00 (26/10/15) 1st release
//--                :
//===========================================================================
interface clk_rst_if;
    logic sys_clk;
    logic apb_clk;
    logic uart_clk;
    logic rst_n;
    
    initial begin
        sys_clk = 0;
        apb_clk = 0;
        uart_clk = 0;
        rst_n = 1;
    end
endinterface;
