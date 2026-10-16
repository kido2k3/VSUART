//===========================================================================
//-- Author          : kido
//-- IP Name         : vsuart_ifs (Interrupt Flag Signal gen)
//-- History         : ver.1.00 (26/10/17) 1st release
//--                 :
//===========================================================================
module vsuart_ifs (
    // interrupt enable
    input       i_ie_txte,
    input       i_ie_rxte,
    input       i_ie_errie,
    // interrupt flag
    input       i_ifs_txifs,
    input       i_ifs_rxifs,
    input       i_ifs_errifs,
    // interrupt output
    output      o_txifs,
    output      o_rxifs,
    output      o_errifs
);
//---------------------------------------------------------------------------
    // PARAMETER HERE
//---------------------------------------------------------------------------
    // VARIABLE
//---------------------------------------------------------------------------
    assign o_txifs = i_ie_txte & i_ifs_txifs;
    assign o_rxifs = i_ie_rxte & i_ifs_rxifs;
    assign o_errifs = i_ie_errie & i_ifs_errifs;
//---------------------------------------------------------------------------
endmodule