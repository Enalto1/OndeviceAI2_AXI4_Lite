class ram_coverage extends uvm_subscriber #(ram_seq_item);
    `uvm_component_utils(ram_coverage)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void write(ram_seq_item t);
        `uvm_info(get_type_name(), t.convert2string(), UVM_HIGH)
    endfunction
endclass
