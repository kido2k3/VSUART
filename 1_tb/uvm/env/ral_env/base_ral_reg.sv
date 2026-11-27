//===========================================================================
//-- Author         : manhndd
//-- Name           : base_ral_reg (base class of all VSUART registers)
//-- History        : ver.1.00 (26/10/17) 1st release
//===========================================================================
class base_ral_reg extends uvm_reg;

  // all VSUART registers are 32 bits and declare the coverage model;
  function new(string name="base_ral_reg");
    super.new(name, 32, build_coverage(UVM_CVR_FIELD_VALS));
  endfunction

  // create + configure one field of this register (has_reset = 1).
  // indv = 1: field.write() drives only the byte lanes of the field (PSTRB);
  // every VSUART field sits alone on its byte lane (only RO RSVD bits share it).
  protected function uvm_reg_field make_vsuart_field(
      string name, int unsigned width, int unsigned lsb,
      string access, uvm_reg_data_t reset, bit volatile_field, bit random_field,
      bit indv = 1);

    uvm_reg_field field;

    field = uvm_reg_field::type_id::create(name, null, get_full_name());
    field.configure(this, width, lsb, access, volatile_field, reset, 1, random_field, indv);

    return field;
  endfunction
endclass
