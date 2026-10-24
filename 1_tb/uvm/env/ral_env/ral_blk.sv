//===========================================================================
//-- Author         : manhndd
//-- Name           : ral_blk (VSUART register block)
//-- History        : ver.1.00 (26/10/17) 1st release
//===========================================================================
// 7 registers + default_map (APB, 4-byte, little endian)
class ral_blk extends uvm_reg_block;
  `uvm_object_utils(ral_blk)

  rand ral_reg_mode MODE;         // +0x00
  rand ral_reg_cr   CR;           // +0x04
  ral_reg_sta       STA;          // +0x08
  rand ral_reg_prs  PRS;          // +0x0c
  rand ral_reg_brg  BRG;          // +0x10
  rand ral_reg_ie   IE;           // +0x14
  ral_reg_ifs       IFS;          // +0x18

  covergroup cg_addr with function sample(uvm_reg_addr_t offset, bit is_read);
    option.per_instance = 1;
    ADDR: coverpoint offset {
      bins MODE = {'h00};
      bins CR   = {'h04};
      bins STA  = {'h08};
      bins PRS  = {'h0c};
      bins BRG  = {'h10};
      bins IE   = {'h14};
      bins IFS  = {'h18};
    }
    DIR: coverpoint is_read { bins WRITE = {0}; bins READ = {1}; }
    ADDR_X_DIR: cross ADDR, DIR {
      ignore_bins sta_wr = binsof(ADDR.STA) && binsof(DIR.WRITE);  // STA is read only
    }
  endgroup

  function new(string name="ral_blk");
    super.new(name, build_coverage(UVM_CVR_ADDR_MAP));
    if (has_coverage(UVM_CVR_ADDR_MAP)) cg_addr = new();
  endfunction

  // called by the predictor for every observed access
  protected virtual function void sample(uvm_reg_addr_t offset, bit is_read, uvm_reg_map map);
    if (get_coverage(UVM_CVR_ADDR_MAP)) cg_addr.sample(offset, is_read);
  endfunction

  function void build(uvm_reg_addr_t base_addr=0);
    if(base_addr[1:0]!=0 || base_addr>'hff00)
      `uvm_fatal("RAL_BASE", "Unaligned or out-of-range CSR base")
      
    // map: name, base, 4-byte bus, little endian, byte addressing
    default_map=create_map("default_map",base_addr,4,UVM_LITTLE_ENDIAN,1);

    // per register: create -> configure (parent) -> build (fields) -> add to map
    MODE=ral_reg_mode::type_id::create("MODE");
    MODE.configure(this);
    MODE.build();
    default_map.add_reg(MODE,'h00,"RW");

    CR=ral_reg_cr::type_id::create("CR");
    CR.configure(this);
    CR.build();
    default_map.add_reg(CR,'h04,"RW");

    STA=ral_reg_sta::type_id::create("STA");
    STA.configure(this);
    STA.build();
    default_map.add_reg(STA,'h08,"RO");

    PRS=ral_reg_prs::type_id::create("PRS");
    PRS.configure(this);
    PRS.build();
    default_map.add_reg(PRS,'h0c,"RW");

    BRG=ral_reg_brg::type_id::create("BRG");
    BRG.configure(this);
    BRG.build();
    default_map.add_reg(BRG,'h10,"RW");

    IE=ral_reg_ie::type_id::create("IE");
    IE.configure(this);
    IE.build();
    default_map.add_reg(IE,'h14,"RW");

    IFS=ral_reg_ifs::type_id::create("IFS");
    IFS.configure(this);
    IFS.build();
    default_map.add_reg(IFS,'h18,"RW");

    // mirror updated only by the predictor (explicit prediction)
    default_map.set_auto_predict(0);
    // read() does not compare; must use mirror(UVM_CHECK)
    default_map.set_check_on_read(0);
    // freeze structure, compute address table
    lock_model();
    // mirror = reset values
    reset("HARD");
  endfunction
endclass
