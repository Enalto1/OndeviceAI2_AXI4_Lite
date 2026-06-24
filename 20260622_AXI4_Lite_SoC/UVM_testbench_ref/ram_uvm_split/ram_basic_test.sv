class ram_basic_test extends ram_base_test;
    `uvm_component_utils(ram_basic_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        ram_wr_rd_seq seq;

        phase.raise_objection(this);

        seq = ram_wr_rd_seq::type_id::create("seq");
        if (!seq.randomize()) begin
            `uvm_error("TEST", "seq randomize fail!")
        end
        else begin
            seq.start(env.agt.sqr);
        end

        #100ns;
        phase.drop_objection(this);
    endtask
endclass
