// Generated from the source DOCX by generate_model.py.
class vsuart_reg_block extends uvm_reg_block;
  `uvm_object_utils(vsuart_reg_block)
  rand vsuart_mode_reg    MODE;
  rand vsuart_cr_reg      CR;
  vsuart_sta_reg          STA;
  rand vsuart_prs_reg     PRS;
  rand vsuart_brg_reg     BRG;
  rand vsuart_ie_reg      IE;
  vsuart_ifs_reg          IFS;
  local bit built;

  function new(string name="vsuart_reg_block");
    super.new(name, UVM_NO_COVERAGE);
  endfunction
  
  function void build(uvm_reg_addr_t base_addr=0);
    if(built) `uvm_fatal("RAL_BUILD", "Register model already built")
  
    if(base_addr[1:0]!=0 || base_addr>'hffe4)
      `uvm_fatal("RAL_BASE", "Unaligned or out-of-range CSR base")
    
    built=1;
    default_map=create_map("default_map",base_addr,4,UVM_LITTLE_ENDIAN,1);
    
    MODE=vsuart_mode_reg::type_id::create("MODE");
    MODE.configure(this); 
    MODE.build();
    default_map.add_reg(MODE,'h00,"RW");
    
    CR=vsuart_cr_reg::type_id::create("CR");
    CR.configure(this); 
    CR.build();
    default_map.add_reg(CR,'h04,"RW");
    
    STA=vsuart_sta_reg::type_id::create("STA");
    STA.configure(this); 
    STA.build();
    default_map.add_reg(STA,'h08,"RO");
    
    PRS=vsuart_prs_reg::type_id::create("PRS");
    PRS.configure(this); 
    PRS.build();
    default_map.add_reg(PRS,'h0c,"RW");
    
    BRG=vsuart_brg_reg::type_id::create("BRG");
    BRG.configure(this); 
    BRG.build();
    default_map.add_reg(BRG,'h10,"RW");
    
    
    IE=vsuart_ie_reg::type_id::create("IE");
    IE.configure(this); 
    IE.build();
    default_map.add_reg(IE,'h14,"RW");
    
    IFS=vsuart_ifs_reg::type_id::create("IFS");
    IFS.configure(this); 
    IFS.build();
    default_map.add_reg(IFS,'h18,"RW");
    
    default_map.set_auto_predict(0);
    default_map.set_check_on_read(0);
    lock_model();
    reset("HARD");
  endfunction
endclass
