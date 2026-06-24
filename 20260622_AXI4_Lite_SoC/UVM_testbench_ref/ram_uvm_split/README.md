# RAM UVM Testbench Split Files

## 구성

각 class를 별도 파일로 분리했습니다.

- `ram_seq_item.sv`
- `ram_base_seq.sv`
- `ram_wr_rd_seq.sv`
- `ram_driver.sv`
- `ram_monitor.sv`
- `ram_agent.sv`
- `ram_scoreboard.sv`
- `ram_coverage.sv`
- `ram_env.sv`
- `ram_base_test.sv`
- `ram_basic_test.sv`

추가로 package/interface/top 파일도 포함했습니다.

- `ram_pkg.sv`
- `ram_if.sv`
- `tb_top.sv`

## 주요 수정 사항

1. `ram_agent`: `uvm_driver::type_id::create`, `uvm_monitor::type_id::create`를 각각 `ram_driver::type_id::create`, `ram_monitor::type_id::create`로 수정했습니다.
2. `ram_if`: interface port로 이미 선언된 `clk`를 내부에서 다시 `logic clk;`로 선언하던 중복 선언을 제거했습니다.
3. `ram_driver`: `` `uvm_info(get_type_name, ...)``를 `` `uvm_info(get_type_name(), ...)``로 수정했습니다.
4. `ram_monitor`: pending read 출력 시 `tr.convert2string()` 대신 실제 read transaction인 `pending_rd.convert2string()`을 사용하도록 수정했습니다.
5. `ram_scoreboard`: `0x02h`를 `0x%02h`로 수정하고, `report_phase`의 깨진 문자열/`$sformats` 오타를 `$sformatf`로 수정했습니다.
6. `tb_top`: `run_test("ram_test")`를 실제 등록된 test class 이름인 `run_test("ram_basic_test")`로 수정했습니다.
7. `ram_sequence.sv`에 있던 두 sequence class를 `ram_base_seq.sv`, `ram_wr_rd_seq.sv`로 분리했습니다.
8. `ram_test.sv`에 있던 두 test class를 `ram_base_test.sv`, `ram_basic_test.sv`로 분리했습니다.
9. FSDB dump system task는 simulator 환경에 따라 미지원일 수 있어 `FSDB_DUMP` define으로 감쌌습니다.

## 컴파일 순서 참고

`ram` DUT module은 원본에 포함되어 있지 않아 이 ZIP에는 넣지 않았습니다. DUT 소스까지 포함해서 아래 순서로 컴파일하세요.

1. `ram_if.sv`
2. `ram_pkg.sv`
3. DUT 파일, 예: `ram.sv`
4. `tb_top.sv`

FSDB dump를 사용하려면 compile/elab 옵션에 `+define+FSDB_DUMP`를 추가하세요.
