class vsuart_reg_base extends uvm_reg;
  function new(string name="vsuart_reg_base");
    super.new(name,32,UVM_NO_COVERAGE);
  endfunction

  protected function uvm_reg_field make_vsuart_field(
      string name, int unsigned width, int unsigned lsb,
      string access, uvm_reg_data_t reset, bit volatile_field, bit random_field);
    
    uvm_reg_field field;
    
    field=uvm_reg_field::type_id::create(name);
    //has_reset = 1 and individually_accessible=0
    field.configure(this,width,lsb,access,volatile_field,reset,1,random_field,0);
    
    if(volatile_field) field.set_compare(UVM_NO_CHECK);
    
    return field;
  endfunction
endclass
