class ram_base_seq extends uvm_sequence #(ram_seq_item);
    `uvm_object_utils(ram_base_seq)

    function new(string name = "ram_base_seq");
        super.new(name);
    endfunction

    task do_write(bit [7:0] addr, bit [7:0] data);
        ram_seq_item item;

        item = ram_seq_item::type_id::create("item");
        start_item(item);
        item.write = 1'b1;
        item.addr  = addr;
        item.wdata = data;
        finish_item(item);
    endtask

    task do_read(bit [7:0] addr);
        ram_seq_item item;

        item = ram_seq_item::type_id::create("item");
        start_item(item);
        item.write = 1'b0;
        item.addr  = addr;
        finish_item(item);
    endtask
endclass
