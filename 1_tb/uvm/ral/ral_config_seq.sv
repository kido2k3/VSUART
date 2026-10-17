//===========================================================================
//-- Author         : manhndd
//-- Name           : ral_config_seq (UART configuration through ral)
//-- History        : ver.1.00 (26/10/17) 1st release
//--                : wait idle -> disable -> PRS/BRG/MODE/CR/IE -> enable
//===========================================================================
class ral_config_seq extends uvm_sequence #(_apb_item);
    `uvm_object_utils(ral_config_seq)

    vsuart_reg_block ral;
    rand bit [3:0]  prs = 0;
    rand bit [15:0] brg = 1;
    rand bit        bsel = 0;
    rand bit [1:0]  pdsel = 1;
    rand bit        spsel = 0;
    rand bit [1:0]  txisel = 0, rxisel = 0;
    rand bit        txte = 0, rxte = 0, errie = 0;
    rand bit [2:0]  uen = 0;
    int unsigned idle_poll_limit = 100;

    constraint legal_brg_c { brg inside {[1:65535]}; }

    function new(string name = "ral_config_seq");
        super.new(name);
    endfunction

    protected function void check(uvm_status_e status, string name);
        if (status != UVM_IS_OK) `uvm_fatal("RAL_CONFIG", {"Failed access: ", name})
    endfunction

    virtual task body();
        ral_enable_seq enable_seq;
        uvm_status_e status;
        uvm_reg_data_t data;
        bit idle;
        if (ral == null || brg == 0 || idle_poll_limit == 0)
            `uvm_fatal("RAL_CONFIG", "Missing model or illegal configuration")
        // STA reads have read-clear side effects. Caller drains FIFO traffic first
        for (int n = 0; n < idle_poll_limit; n++) begin
            ral.STA.read(status, data, UVM_FRONTDOOR, ral.default_map, this);
            check(status, "STA");
            if ((data & 'h24) == 'h24) begin idle = 1; break; end
        end
        if (!idle) `uvm_fatal("RAL_IDLE", "Timed out waiting for TX/RX idle")

        enable_seq = ral_enable_seq::type_id::create("disable");
        enable_seq.ral = ral;
        enable_seq.uen = 0;
        enable_seq.start(m_sequencer, this);

        ral.PRS.write(status, prs, UVM_FRONTDOOR, ral.default_map, this); check(status, "PRS");
        ral.BRG.write(status, brg, UVM_FRONTDOOR, ral.default_map, this); check(status, "BRG");
        data = (uvm_reg_data_t'(spsel) << 24) | (uvm_reg_data_t'(pdsel) << 16) | (uvm_reg_data_t'(bsel) << 8);
        ral.MODE.write(status, data, UVM_FRONTDOOR, ral.default_map, this); check(status, "MODE");
        data = (uvm_reg_data_t'(rxisel) << 8) | txisel;
        ral.CR.write(status, data, UVM_FRONTDOOR, ral.default_map, this); check(status, "CR");
        data = (uvm_reg_data_t'(errie) << 16) | (uvm_reg_data_t'(rxte) << 8) | txte;
        ral.IE.write(status, data, UVM_FRONTDOOR, ral.default_map, this); check(status, "IE");

        enable_seq.uen = uen;
        enable_seq.start(m_sequencer, this);
    endtask
endclass
