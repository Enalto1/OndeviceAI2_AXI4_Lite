class ram_wr_rd_seq extends ram_base_seq;
    `uvm_object_utils(ram_wr_rd_seq)

    rand int num;
    constraint c_num { num inside {[10:30]}; }

    function new(string name = "ram_wr_rd_seq");
        super.new(name);
    endfunction

    task body();
        bit [7:0] addr_q[$];
        bit [7:0] addr;

        `uvm_info(get_type_name(), $sformatf("wr_rd 시나리오 시작 (%0d 반복)", num), UVM_LOW)

        repeat (num) begin
            addr = $urandom_range(0, 255);
            do_write(addr, $urandom_range(0, 255));
            addr_q.push_back(addr);
        end

        foreach (addr_q[i]) begin
            do_read(addr_q[i]);
        end

        `uvm_info(get_type_name(), "wr_rd 시나리오 종료.", UVM_LOW)
    endtask
endclass
