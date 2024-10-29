onerror {resume}
quietly virtual signal -install /tb_cpu/dut/pipeline_inst/ctrl_inst { (context /tb_cpu/dut/pipeline_inst/ctrl_inst )(flush_fetch & flush_dec & flush_exec & flush_mem & flush_wb )} flush_signals
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider submission
add wave -noupdate -expand -group submission -radix hexadecimal /tb_cpu/dut/pipeline_inst/fetch_inst/pc
add wave -noupdate -expand -group submission -radix hexadecimal /tb_cpu/dut/pipeline_inst/fetch_inst/instr
add wave -noupdate -expand -group submission -radix decimal /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(3)
add wave -noupdate -expand -group submission -radix decimal /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(2)
add wave -noupdate -expand -group submission -radix decimal /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(1)
add wave -noupdate -expand -group submission -radix decimal /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/wraddr
add wave -noupdate -expand -group submission -radix decimal /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/wrdata
add wave -noupdate -expand -group submission /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/regwrite
add wave -noupdate -divider CPU
add wave -noupdate -expand -group CPU -divider -height 40 pipeline
add wave -noupdate -expand -group CPU -group pipeline /tb_cpu/dut/pipeline_inst/clk
add wave -noupdate -expand -group CPU -group pipeline /tb_cpu/dut/pipeline_inst/res_n
add wave -noupdate -expand -group CPU -group pipeline -group instruction_interface /tb_cpu/dut/pipeline_inst/mem_i_out
add wave -noupdate -expand -group CPU -group pipeline -group instruction_interface /tb_cpu/dut/pipeline_inst/mem_i_in
add wave -noupdate -expand -group CPU -group pipeline -group data_interface /tb_cpu/dut/pipeline_inst/mem_d_out
add wave -noupdate -expand -group CPU -group pipeline -group data_interface /tb_cpu/dut/pipeline_inst/mem_d_in
add wave -noupdate -expand -group CPU -group pipeline -group internals -divider stall_signals
add wave -noupdate -expand -group CPU -group pipeline -group internals /tb_cpu/dut/pipeline_inst/memory_busy_stall
add wave -noupdate -expand -group CPU -group pipeline -group internals /tb_cpu/dut/pipeline_inst/stall_f
add wave -noupdate -expand -group CPU -group pipeline -group internals /tb_cpu/dut/pipeline_inst/stall_d
add wave -noupdate -expand -group CPU -group pipeline -group internals /tb_cpu/dut/pipeline_inst/stall_e
add wave -noupdate -expand -group CPU -group pipeline -group internals /tb_cpu/dut/pipeline_inst/stall_m
add wave -noupdate -expand -group CPU -group pipeline -group internals /tb_cpu/dut/pipeline_inst/stall_w
add wave -noupdate -expand -group CPU -group pipeline -group internals -divider flush_signals
add wave -noupdate -expand -group CPU -group pipeline -group internals /tb_cpu/dut/pipeline_inst/flush_f
add wave -noupdate -expand -group CPU -group pipeline -group internals /tb_cpu/dut/pipeline_inst/flush_d
add wave -noupdate -expand -group CPU -group pipeline -group internals /tb_cpu/dut/pipeline_inst/flush_e
add wave -noupdate -expand -group CPU -group pipeline -group internals /tb_cpu/dut/pipeline_inst/flush_m
add wave -noupdate -expand -group CPU -group pipeline -group internals /tb_cpu/dut/pipeline_inst/flush_w
add wave -noupdate -expand -group CPU -group pipeline -group internals -divider fetch_stage_signals
add wave -noupdate -expand -group CPU -group pipeline -group internals /tb_cpu/dut/pipeline_inst/mem_busy_f
add wave -noupdate -expand -group CPU -group pipeline -group internals /tb_cpu/dut/pipeline_inst/pc_out_f
add wave -noupdate -expand -group CPU -group pipeline -group internals /tb_cpu/dut/pipeline_inst/instr_f
add wave -noupdate -expand -group CPU -group pipeline -group internals -divider decode_stage_signals
add wave -noupdate -expand -group CPU -group pipeline -group internals /tb_cpu/dut/pipeline_inst/pc_out_d
add wave -noupdate -expand -group CPU -group pipeline -group internals /tb_cpu/dut/pipeline_inst/exec_op_d
add wave -noupdate -expand -group CPU -group pipeline -group internals /tb_cpu/dut/pipeline_inst/mem_op_d
add wave -noupdate -expand -group CPU -group pipeline -group internals /tb_cpu/dut/pipeline_inst/wb_op_d
add wave -noupdate -expand -group CPU -group pipeline -group internals /tb_cpu/dut/pipeline_inst/exc_dec_d
add wave -noupdate -expand -group CPU -group pipeline -group internals -divider execute_stage_signals
add wave -noupdate -expand -group CPU -group pipeline -group internals /tb_cpu/dut/pipeline_inst/pc_old_out_e
add wave -noupdate -expand -group CPU -group pipeline -group internals /tb_cpu/dut/pipeline_inst/pc_new_out_e
add wave -noupdate -expand -group CPU -group pipeline -group internals -radix decimal /tb_cpu/dut/pipeline_inst/aluresult_e
add wave -noupdate -expand -group CPU -group pipeline -group internals -radix decimal /tb_cpu/dut/pipeline_inst/wrdata_e
add wave -noupdate -expand -group CPU -group pipeline -group internals /tb_cpu/dut/pipeline_inst/zero_e
add wave -noupdate -expand -group CPU -group pipeline -group internals /tb_cpu/dut/pipeline_inst/memop_out_e
add wave -noupdate -expand -group CPU -group pipeline -group internals /tb_cpu/dut/pipeline_inst/wbop_out_e
add wave -noupdate -expand -group CPU -group pipeline -group internals /tb_cpu/dut/pipeline_inst/exec_op_e
add wave -noupdate -expand -group CPU -group pipeline -group internals -divider memory_stage_signals
add wave -noupdate -expand -group CPU -group pipeline -group internals /tb_cpu/dut/pipeline_inst/mem_busy_m
add wave -noupdate -expand -group CPU -group pipeline -group internals /tb_cpu/dut/pipeline_inst/reg_write_m
add wave -noupdate -expand -group CPU -group pipeline -group internals /tb_cpu/dut/pipeline_inst/pc_new_out_m
add wave -noupdate -expand -group CPU -group pipeline -group internals /tb_cpu/dut/pipeline_inst/pcsrc_m
add wave -noupdate -expand -group CPU -group pipeline -group internals /tb_cpu/dut/pipeline_inst/wbop_out_m
add wave -noupdate -expand -group CPU -group pipeline -group internals /tb_cpu/dut/pipeline_inst/pc_old_out_m
add wave -noupdate -expand -group CPU -group pipeline -group internals -radix decimal /tb_cpu/dut/pipeline_inst/aluresult_out_m
add wave -noupdate -expand -group CPU -group pipeline -group internals -radix decimal /tb_cpu/dut/pipeline_inst/memresult_m
add wave -noupdate -expand -group CPU -group pipeline -group internals /tb_cpu/dut/pipeline_inst/exc_load_m
add wave -noupdate -expand -group CPU -group pipeline -group internals /tb_cpu/dut/pipeline_inst/exc_store_m
add wave -noupdate -expand -group CPU -group pipeline -group internals -divider wb_stage_signals
add wave -noupdate -expand -group CPU -group pipeline -group internals -childformat {{/tb_cpu/dut/pipeline_inst/reg_write_w.reg -radix decimal} {/tb_cpu/dut/pipeline_inst/reg_write_w.data -radix decimal}} -expand -subitemconfig {/tb_cpu/dut/pipeline_inst/reg_write_w.reg {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/reg_write_w.data {-height 16 -radix decimal}} /tb_cpu/dut/pipeline_inst/reg_write_w
add wave -noupdate -expand -group CPU -group pipeline -group internals -divider ctrl_signals
add wave -noupdate -expand -group CPU -group pipeline -group internals /tb_cpu/dut/pipeline_inst/pcsrc_ctrl
add wave -noupdate -expand -group CPU -divider -height 40 control
add wave -noupdate -expand -group CPU -group ctrl /tb_cpu/dut/pipeline_inst/ctrl_inst/clk
add wave -noupdate -expand -group CPU -group ctrl /tb_cpu/dut/pipeline_inst/ctrl_inst/res_n
add wave -noupdate -expand -group CPU -group ctrl -divider stall_signals
add wave -noupdate -expand -group CPU -group ctrl /tb_cpu/dut/pipeline_inst/ctrl_inst/stall
add wave -noupdate -expand -group CPU -group ctrl /tb_cpu/dut/pipeline_inst/ctrl_inst/stall_fetch
add wave -noupdate -expand -group CPU -group ctrl /tb_cpu/dut/pipeline_inst/ctrl_inst/stall_dec
add wave -noupdate -expand -group CPU -group ctrl /tb_cpu/dut/pipeline_inst/ctrl_inst/stall_exec
add wave -noupdate -expand -group CPU -group ctrl /tb_cpu/dut/pipeline_inst/ctrl_inst/stall_mem
add wave -noupdate -expand -group CPU -group ctrl /tb_cpu/dut/pipeline_inst/ctrl_inst/stall_wb
add wave -noupdate -expand -group CPU -group ctrl -divider flush_signals
add wave -noupdate -expand -group CPU -group ctrl /tb_cpu/dut/pipeline_inst/ctrl_inst/flush_fetch
add wave -noupdate -expand -group CPU -group ctrl /tb_cpu/dut/pipeline_inst/ctrl_inst/flush_dec
add wave -noupdate -expand -group CPU -group ctrl /tb_cpu/dut/pipeline_inst/ctrl_inst/flush_exec
add wave -noupdate -expand -group CPU -group ctrl /tb_cpu/dut/pipeline_inst/ctrl_inst/flush_mem
add wave -noupdate -expand -group CPU -group ctrl /tb_cpu/dut/pipeline_inst/ctrl_inst/flush_wb
add wave -noupdate -expand -group CPU -group ctrl -divider calculation_signals
add wave -noupdate -expand -group CPU -group ctrl -childformat {{/tb_cpu/dut/pipeline_inst/ctrl_inst/wb_op_exec.rd -radix decimal}} -expand -subitemconfig {/tb_cpu/dut/pipeline_inst/ctrl_inst/wb_op_exec.rd {-height 16 -radix decimal}} /tb_cpu/dut/pipeline_inst/ctrl_inst/wb_op_exec
add wave -noupdate -expand -group CPU -group ctrl -childformat {{/tb_cpu/dut/pipeline_inst/ctrl_inst/exec_op_dec.rs1 -radix decimal} {/tb_cpu/dut/pipeline_inst/ctrl_inst/exec_op_dec.rs2 -radix decimal} {/tb_cpu/dut/pipeline_inst/ctrl_inst/exec_op_dec.readdata1 -radix decimal} {/tb_cpu/dut/pipeline_inst/ctrl_inst/exec_op_dec.readdata2 -radix decimal} {/tb_cpu/dut/pipeline_inst/ctrl_inst/exec_op_dec.imm -radix decimal}} -expand -subitemconfig {/tb_cpu/dut/pipeline_inst/ctrl_inst/exec_op_dec.rs1 {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/ctrl_inst/exec_op_dec.rs2 {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/ctrl_inst/exec_op_dec.readdata1 {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/ctrl_inst/exec_op_dec.readdata2 {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/ctrl_inst/exec_op_dec.imm {-height 16 -radix decimal}} /tb_cpu/dut/pipeline_inst/ctrl_inst/exec_op_dec
add wave -noupdate -expand -group CPU -group ctrl /tb_cpu/dut/pipeline_inst/ctrl_inst/pcsrc_in
add wave -noupdate -expand -group CPU -group ctrl /tb_cpu/dut/pipeline_inst/ctrl_inst/pcsrc_out
add wave -noupdate -expand -group CPU -divider -height 40 fetch
add wave -noupdate -expand -group CPU -group fetch -expand -group entity /tb_cpu/dut/pipeline_inst/fetch_inst/stall
add wave -noupdate -expand -group CPU -group fetch -expand -group entity /tb_cpu/dut/pipeline_inst/fetch_inst/flush
add wave -noupdate -expand -group CPU -group fetch -expand -group entity -divider {input from memory}
add wave -noupdate -expand -group CPU -group fetch -expand -group entity -radix decimal -childformat {{/tb_cpu/dut/pipeline_inst/fetch_inst/pc_in(15) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/pc_in(14) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/pc_in(13) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/pc_in(12) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/pc_in(11) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/pc_in(10) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/pc_in(9) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/pc_in(8) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/pc_in(7) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/pc_in(6) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/pc_in(5) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/pc_in(4) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/pc_in(3) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/pc_in(2) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/pc_in(1) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/pc_in(0) -radix hexadecimal}} -subitemconfig {/tb_cpu/dut/pipeline_inst/fetch_inst/pc_in(15) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/pc_in(14) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/pc_in(13) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/pc_in(12) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/pc_in(11) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/pc_in(10) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/pc_in(9) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/pc_in(8) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/pc_in(7) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/pc_in(6) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/pc_in(5) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/pc_in(4) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/pc_in(3) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/pc_in(2) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/pc_in(1) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/pc_in(0) {-height 16 -radix hexadecimal}} /tb_cpu/dut/pipeline_inst/fetch_inst/pc_in
add wave -noupdate -expand -group CPU -group fetch -expand -group entity /tb_cpu/dut/pipeline_inst/fetch_inst/pcsrc
add wave -noupdate -expand -group CPU -group fetch -expand -group entity -divider {output to decode}
add wave -noupdate -expand -group CPU -group fetch -expand -group entity -radix hexadecimal -childformat {{/tb_cpu/dut/pipeline_inst/fetch_inst/instr(31) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/instr(30) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/instr(29) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/instr(28) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/instr(27) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/instr(26) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/instr(25) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/instr(24) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/instr(23) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/instr(22) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/instr(21) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/instr(20) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/instr(19) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/instr(18) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/instr(17) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/instr(16) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/instr(15) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/instr(14) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/instr(13) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/instr(12) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/instr(11) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/instr(10) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/instr(9) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/instr(8) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/instr(7) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/instr(6) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/instr(5) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/instr(4) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/instr(3) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/instr(2) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/instr(1) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/instr(0) -radix hexadecimal}} -subitemconfig {/tb_cpu/dut/pipeline_inst/fetch_inst/instr(31) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/instr(30) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/instr(29) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/instr(28) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/instr(27) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/instr(26) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/instr(25) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/instr(24) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/instr(23) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/instr(22) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/instr(21) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/instr(20) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/instr(19) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/instr(18) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/instr(17) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/instr(16) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/instr(15) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/instr(14) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/instr(13) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/instr(12) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/instr(11) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/instr(10) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/instr(9) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/instr(8) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/instr(7) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/instr(6) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/instr(5) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/instr(4) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/instr(3) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/instr(2) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/instr(1) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/instr(0) {-height 16 -radix hexadecimal}} /tb_cpu/dut/pipeline_inst/fetch_inst/instr
add wave -noupdate -expand -group CPU -group fetch -expand -group entity /tb_cpu/dut/pipeline_inst/fetch_inst/mem_busy
add wave -noupdate -expand -group CPU -group fetch -expand -group entity -radix decimal -childformat {{/tb_cpu/dut/pipeline_inst/fetch_inst/pc_out(15) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/pc_out(14) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/pc_out(13) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/pc_out(12) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/pc_out(11) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/pc_out(10) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/pc_out(9) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/pc_out(8) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/pc_out(7) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/pc_out(6) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/pc_out(5) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/pc_out(4) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/pc_out(3) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/pc_out(2) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/pc_out(1) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/pc_out(0) -radix hexadecimal}} -subitemconfig {/tb_cpu/dut/pipeline_inst/fetch_inst/pc_out(15) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/pc_out(14) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/pc_out(13) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/pc_out(12) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/pc_out(11) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/pc_out(10) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/pc_out(9) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/pc_out(8) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/pc_out(7) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/pc_out(6) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/pc_out(5) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/pc_out(4) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/pc_out(3) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/pc_out(2) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/pc_out(1) {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/pc_out(0) {-height 16 -radix hexadecimal}} /tb_cpu/dut/pipeline_inst/fetch_inst/pc_out
add wave -noupdate -expand -group CPU -group fetch -expand -group entity -divider -height 16 {memory controller interface}
add wave -noupdate -expand -group CPU -group fetch -expand -group entity -expand /tb_cpu/dut/pipeline_inst/fetch_inst/mem_in
add wave -noupdate -expand -group CPU -group fetch -expand -group entity /tb_cpu/dut/pipeline_inst/fetch_inst/mem_out
add wave -noupdate -expand -group CPU -divider -height 40 decode
add wave -noupdate -expand -group CPU -group decode -expand -group entity /tb_cpu/dut/pipeline_inst/decode_inst/stall
add wave -noupdate -expand -group CPU -group decode -expand -group entity /tb_cpu/dut/pipeline_inst/decode_inst/flush
add wave -noupdate -expand -group CPU -group decode -expand -group entity -divider {input from fetch}
add wave -noupdate -expand -group CPU -group decode -expand -group entity -radix hexadecimal /tb_cpu/dut/pipeline_inst/decode_inst/instr
add wave -noupdate -expand -group CPU -group decode -expand -group entity -radix decimal /tb_cpu/dut/pipeline_inst/decode_inst/pc_in
add wave -noupdate -expand -group CPU -group decode -expand -group entity -divider {input from wb}
add wave -noupdate -expand -group CPU -group decode -expand -group entity -childformat {{/tb_cpu/dut/pipeline_inst/decode_inst/reg_write.reg -radix decimal} {/tb_cpu/dut/pipeline_inst/decode_inst/reg_write.data -radix decimal}} -subitemconfig {/tb_cpu/dut/pipeline_inst/decode_inst/reg_write.reg {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/decode_inst/reg_write.data {-height 16 -radix decimal}} /tb_cpu/dut/pipeline_inst/decode_inst/reg_write
add wave -noupdate -expand -group CPU -group decode -expand -group entity -divider {output towards next stage}
add wave -noupdate -expand -group CPU -group decode -expand -group entity -childformat {{/tb_cpu/dut/pipeline_inst/decode_inst/exec_op.rs1 -radix decimal} {/tb_cpu/dut/pipeline_inst/decode_inst/exec_op.rs2 -radix decimal} {/tb_cpu/dut/pipeline_inst/decode_inst/exec_op.readdata1 -radix decimal} {/tb_cpu/dut/pipeline_inst/decode_inst/exec_op.readdata2 -radix decimal} {/tb_cpu/dut/pipeline_inst/decode_inst/exec_op.imm -radix decimal}} -subitemconfig {/tb_cpu/dut/pipeline_inst/decode_inst/exec_op.rs1 {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/decode_inst/exec_op.rs2 {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/decode_inst/exec_op.readdata1 {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/decode_inst/exec_op.readdata2 {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/decode_inst/exec_op.imm {-height 16 -radix decimal}} /tb_cpu/dut/pipeline_inst/decode_inst/exec_op
add wave -noupdate -expand -group CPU -group decode -expand -group entity /tb_cpu/dut/pipeline_inst/decode_inst/mem_op
add wave -noupdate -expand -group CPU -group decode -expand -group entity -childformat {{/tb_cpu/dut/pipeline_inst/decode_inst/wb_op.rd -radix decimal}} -expand -subitemconfig {/tb_cpu/dut/pipeline_inst/decode_inst/wb_op.rd {-height 16 -radix decimal}} /tb_cpu/dut/pipeline_inst/decode_inst/wb_op
add wave -noupdate -expand -group CPU -group decode -expand -group entity -radix decimal /tb_cpu/dut/pipeline_inst/decode_inst/pc_out
add wave -noupdate -expand -group CPU -group decode -expand -group entity -divider {exception output}
add wave -noupdate -expand -group CPU -group decode -expand -group entity /tb_cpu/dut/pipeline_inst/decode_inst/exc_dec
add wave -noupdate -expand -group CPU -group decode -group regfile_inst /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/stall
add wave -noupdate -expand -group CPU -group decode -group regfile_inst -radix decimal /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/rdaddr1
add wave -noupdate -expand -group CPU -group decode -group regfile_inst -radix decimal /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/rdaddr2
add wave -noupdate -expand -group CPU -group decode -group regfile_inst -radix decimal /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/rddata1
add wave -noupdate -expand -group CPU -group decode -group regfile_inst -radix decimal /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/rddata2
add wave -noupdate -expand -group CPU -group decode -group regfile_inst -radix decimal /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/wraddr
add wave -noupdate -expand -group CPU -group decode -group regfile_inst -radix decimal /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/wrdata
add wave -noupdate -expand -group CPU -group decode -group regfile_inst /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/regwrite
add wave -noupdate -expand -group CPU -group decode -group regfile_inst -radix decimal -childformat {{/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(31) -radix decimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(30) -radix decimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(29) -radix decimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(28) -radix decimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(27) -radix decimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(26) -radix decimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(25) -radix decimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(24) -radix decimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(23) -radix decimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(22) -radix decimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(21) -radix decimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(20) -radix decimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(19) -radix decimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(18) -radix decimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(17) -radix decimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(16) -radix decimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(15) -radix decimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(14) -radix decimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(13) -radix decimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(12) -radix decimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(11) -radix decimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(10) -radix decimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(9) -radix decimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(8) -radix decimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(7) -radix decimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(6) -radix decimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(5) -radix decimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(4) -radix decimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(3) -radix decimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(2) -radix decimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(1) -radix decimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(0) -radix decimal}} -expand -subitemconfig {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(31) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(30) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(29) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(28) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(27) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(26) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(25) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(24) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(23) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(22) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(21) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(20) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(19) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(18) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(17) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(16) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(15) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(14) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(13) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(12) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(11) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(10) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(9) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(8) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(7) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(6) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(5) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(4) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(3) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(2) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(1) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg(0) {-height 16 -radix decimal}} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg
add wave -noupdate -expand -group CPU -group decode -group regfile_inst /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/rdaddr1_sig
add wave -noupdate -expand -group CPU -group decode -group regfile_inst /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/rdaddr2_sig
add wave -noupdate -expand -group CPU -divider -height 40 exec
add wave -noupdate -expand -group CPU -group exec -expand -group entity /tb_cpu/dut/pipeline_inst/execute_inst/stall
add wave -noupdate -expand -group CPU -group exec -expand -group entity /tb_cpu/dut/pipeline_inst/execute_inst/flush
add wave -noupdate -expand -group CPU -group exec -expand -group entity -divider -height 16 {input from decode}
add wave -noupdate -expand -group CPU -group exec -expand -group entity -childformat {{/tb_cpu/dut/pipeline_inst/execute_inst/op.rs1 -radix decimal} {/tb_cpu/dut/pipeline_inst/execute_inst/op.rs2 -radix decimal} {/tb_cpu/dut/pipeline_inst/execute_inst/op.readdata1 -radix decimal} {/tb_cpu/dut/pipeline_inst/execute_inst/op.readdata2 -radix decimal} {/tb_cpu/dut/pipeline_inst/execute_inst/op.imm -radix decimal}} -expand -subitemconfig {/tb_cpu/dut/pipeline_inst/execute_inst/op.rs1 {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/execute_inst/op.rs2 {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/execute_inst/op.readdata1 {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/execute_inst/op.readdata2 {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/execute_inst/op.imm {-height 16 -radix decimal}} /tb_cpu/dut/pipeline_inst/execute_inst/op
add wave -noupdate -expand -group CPU -group exec -expand -group entity -radix decimal /tb_cpu/dut/pipeline_inst/execute_inst/pc_in
add wave -noupdate -expand -group CPU -group exec -expand -group entity -divider {output to memory}
add wave -noupdate -expand -group CPU -group exec -expand -group entity -radix decimal /tb_cpu/dut/pipeline_inst/execute_inst/pc_old_out
add wave -noupdate -expand -group CPU -group exec -expand -group entity -radix decimal /tb_cpu/dut/pipeline_inst/execute_inst/pc_new_out
add wave -noupdate -expand -group CPU -group exec -expand -group entity -radix decimal /tb_cpu/dut/pipeline_inst/execute_inst/aluresult
add wave -noupdate -expand -group CPU -group exec -expand -group entity -radix decimal /tb_cpu/dut/pipeline_inst/execute_inst/wrdata
add wave -noupdate -expand -group CPU -group exec -expand -group entity /tb_cpu/dut/pipeline_inst/execute_inst/zero
add wave -noupdate -expand -group CPU -group exec -expand -group entity /tb_cpu/dut/pipeline_inst/execute_inst/memop_in
add wave -noupdate -expand -group CPU -group exec -expand -group entity /tb_cpu/dut/pipeline_inst/execute_inst/memop_out
add wave -noupdate -expand -group CPU -group exec -expand -group entity /tb_cpu/dut/pipeline_inst/execute_inst/wbop_in
add wave -noupdate -expand -group CPU -group exec -expand -group entity /tb_cpu/dut/pipeline_inst/execute_inst/wbop_out
add wave -noupdate -expand -group CPU -group exec -expand -group entity -divider {forwarding - ex4}
add wave -noupdate -expand -group CPU -group exec -expand -group entity -childformat {{/tb_cpu/dut/pipeline_inst/execute_inst/exec_op.rs1 -radix decimal} {/tb_cpu/dut/pipeline_inst/execute_inst/exec_op.rs2 -radix decimal} {/tb_cpu/dut/pipeline_inst/execute_inst/exec_op.readdata1 -radix decimal} {/tb_cpu/dut/pipeline_inst/execute_inst/exec_op.readdata2 -radix decimal} {/tb_cpu/dut/pipeline_inst/execute_inst/exec_op.imm -radix decimal}} -subitemconfig {/tb_cpu/dut/pipeline_inst/execute_inst/exec_op.rs1 {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/execute_inst/exec_op.rs2 {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/execute_inst/exec_op.readdata1 {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/execute_inst/exec_op.readdata2 {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/execute_inst/exec_op.imm {-height 16 -radix decimal}} /tb_cpu/dut/pipeline_inst/execute_inst/exec_op
add wave -noupdate -expand -group CPU -group exec -expand -group entity /tb_cpu/dut/pipeline_inst/execute_inst/reg_write_mem
add wave -noupdate -expand -group CPU -group exec -expand -group entity /tb_cpu/dut/pipeline_inst/execute_inst/reg_write_wr
add wave -noupdate -expand -group CPU -group exec -expand -group {internal signals} /tb_cpu/dut/pipeline_inst/execute_inst/alu_op
add wave -noupdate -expand -group CPU -group exec -expand -group {internal signals} -radix decimal /tb_cpu/dut/pipeline_inst/execute_inst/alu_a
add wave -noupdate -expand -group CPU -group exec -expand -group {internal signals} -radix decimal /tb_cpu/dut/pipeline_inst/execute_inst/alu_b
add wave -noupdate -expand -group CPU -group exec -expand -group {internal signals} -radix decimal /tb_cpu/dut/pipeline_inst/execute_inst/alu_res
add wave -noupdate -expand -group CPU -group exec -expand -group {internal signals} -radix decimal /tb_cpu/dut/pipeline_inst/execute_inst/alu_z
add wave -noupdate -expand -group CPU -group exec -expand -group {internal signals} -radix decimal /tb_cpu/dut/pipeline_inst/execute_inst/pc_in_exec
add wave -noupdate -expand -group CPU -group exec -expand -group {internal signals} /tb_cpu/dut/pipeline_inst/execute_inst/memop_in_next
add wave -noupdate -expand -group CPU -group exec -expand -group {internal signals} /tb_cpu/dut/pipeline_inst/execute_inst/wbop_in_next
add wave -noupdate -expand -group CPU -group exec -expand -group alu_inst /tb_cpu/dut/pipeline_inst/execute_inst/alu_inst/op
add wave -noupdate -expand -group CPU -group exec -expand -group alu_inst -radix decimal /tb_cpu/dut/pipeline_inst/execute_inst/alu_inst/A
add wave -noupdate -expand -group CPU -group exec -expand -group alu_inst -radix decimal /tb_cpu/dut/pipeline_inst/execute_inst/alu_inst/B
add wave -noupdate -expand -group CPU -group exec -expand -group alu_inst -radix decimal /tb_cpu/dut/pipeline_inst/execute_inst/alu_inst/R
add wave -noupdate -expand -group CPU -group exec -expand -group alu_inst /tb_cpu/dut/pipeline_inst/execute_inst/alu_inst/Z
add wave -noupdate -expand -group CPU -group exec -expand -group fwd_inst_rs1 -childformat {{/tb_cpu/dut/pipeline_inst/execute_inst/fwd_inst_rs1/reg_write_mem.write -radix decimal} {/tb_cpu/dut/pipeline_inst/execute_inst/fwd_inst_rs1/reg_write_mem.reg -radix decimal} {/tb_cpu/dut/pipeline_inst/execute_inst/fwd_inst_rs1/reg_write_mem.data -radix decimal}} -expand -subitemconfig {/tb_cpu/dut/pipeline_inst/execute_inst/fwd_inst_rs1/reg_write_mem.write {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/execute_inst/fwd_inst_rs1/reg_write_mem.reg {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/execute_inst/fwd_inst_rs1/reg_write_mem.data {-height 16 -radix decimal}} /tb_cpu/dut/pipeline_inst/execute_inst/fwd_inst_rs1/reg_write_mem
add wave -noupdate -expand -group CPU -group exec -expand -group fwd_inst_rs1 -childformat {{/tb_cpu/dut/pipeline_inst/execute_inst/fwd_inst_rs1/reg_write_wb.reg -radix decimal} {/tb_cpu/dut/pipeline_inst/execute_inst/fwd_inst_rs1/reg_write_wb.data -radix decimal}} -expand -subitemconfig {/tb_cpu/dut/pipeline_inst/execute_inst/fwd_inst_rs1/reg_write_wb.reg {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/execute_inst/fwd_inst_rs1/reg_write_wb.data {-height 16 -radix decimal}} /tb_cpu/dut/pipeline_inst/execute_inst/fwd_inst_rs1/reg_write_wb
add wave -noupdate -expand -group CPU -group exec -expand -group fwd_inst_rs1 -radix decimal /tb_cpu/dut/pipeline_inst/execute_inst/fwd_inst_rs1/reg
add wave -noupdate -expand -group CPU -group exec -expand -group fwd_inst_rs1 -radix decimal /tb_cpu/dut/pipeline_inst/execute_inst/fwd_inst_rs1/val
add wave -noupdate -expand -group CPU -group exec -expand -group fwd_inst_rs1 /tb_cpu/dut/pipeline_inst/execute_inst/fwd_inst_rs1/do_fwd
add wave -noupdate -expand -group CPU -group exec -expand -group fwd_inst_rs2 -childformat {{/tb_cpu/dut/pipeline_inst/execute_inst/fwd_inst_rs2/reg_write_mem.reg -radix decimal} {/tb_cpu/dut/pipeline_inst/execute_inst/fwd_inst_rs2/reg_write_mem.data -radix decimal}} -expand -subitemconfig {/tb_cpu/dut/pipeline_inst/execute_inst/fwd_inst_rs2/reg_write_mem.reg {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/execute_inst/fwd_inst_rs2/reg_write_mem.data {-height 16 -radix decimal}} /tb_cpu/dut/pipeline_inst/execute_inst/fwd_inst_rs2/reg_write_mem
add wave -noupdate -expand -group CPU -group exec -expand -group fwd_inst_rs2 -childformat {{/tb_cpu/dut/pipeline_inst/execute_inst/fwd_inst_rs2/reg_write_wb.reg -radix decimal} {/tb_cpu/dut/pipeline_inst/execute_inst/fwd_inst_rs2/reg_write_wb.data -radix decimal}} -expand -subitemconfig {/tb_cpu/dut/pipeline_inst/execute_inst/fwd_inst_rs2/reg_write_wb.reg {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/execute_inst/fwd_inst_rs2/reg_write_wb.data {-height 16 -radix decimal}} /tb_cpu/dut/pipeline_inst/execute_inst/fwd_inst_rs2/reg_write_wb
add wave -noupdate -expand -group CPU -group exec -expand -group fwd_inst_rs2 -radix decimal /tb_cpu/dut/pipeline_inst/execute_inst/fwd_inst_rs2/reg
add wave -noupdate -expand -group CPU -group exec -expand -group fwd_inst_rs2 -radix decimal /tb_cpu/dut/pipeline_inst/execute_inst/fwd_inst_rs2/val
add wave -noupdate -expand -group CPU -group exec -expand -group fwd_inst_rs2 /tb_cpu/dut/pipeline_inst/execute_inst/fwd_inst_rs2/do_fwd
add wave -noupdate -expand -group CPU -divider -height 40 mem
add wave -noupdate -expand -group CPU -group mem -expand -group entity /tb_cpu/dut/pipeline_inst/memory_inst/stall
add wave -noupdate -expand -group CPU -group mem -expand -group entity /tb_cpu/dut/pipeline_inst/memory_inst/flush
add wave -noupdate -expand -group CPU -group mem -expand -group entity /tb_cpu/dut/pipeline_inst/memory_inst/mem_busy
add wave -noupdate -expand -group CPU -group mem -expand -group entity -divider {input from exec}
add wave -noupdate -expand -group CPU -group mem -expand -group entity /tb_cpu/dut/pipeline_inst/memory_inst/mem_op
add wave -noupdate -expand -group CPU -group mem -expand -group entity -childformat {{/tb_cpu/dut/pipeline_inst/memory_inst/wbop_in.rd -radix decimal}} -subitemconfig {/tb_cpu/dut/pipeline_inst/memory_inst/wbop_in.rd {-height 16 -radix decimal}} /tb_cpu/dut/pipeline_inst/memory_inst/wbop_in
add wave -noupdate -expand -group CPU -group mem -expand -group entity -radix decimal /tb_cpu/dut/pipeline_inst/memory_inst/pc_new_in
add wave -noupdate -expand -group CPU -group mem -expand -group entity -radix decimal /tb_cpu/dut/pipeline_inst/memory_inst/pc_old_in
add wave -noupdate -expand -group CPU -group mem -expand -group entity -radix decimal /tb_cpu/dut/pipeline_inst/memory_inst/aluresult_in
add wave -noupdate -expand -group CPU -group mem -expand -group entity -radix decimal -childformat {{/tb_cpu/dut/pipeline_inst/memory_inst/wrdata(31) -radix decimal} {/tb_cpu/dut/pipeline_inst/memory_inst/wrdata(30) -radix decimal} {/tb_cpu/dut/pipeline_inst/memory_inst/wrdata(29) -radix decimal} {/tb_cpu/dut/pipeline_inst/memory_inst/wrdata(28) -radix decimal} {/tb_cpu/dut/pipeline_inst/memory_inst/wrdata(27) -radix decimal} {/tb_cpu/dut/pipeline_inst/memory_inst/wrdata(26) -radix decimal} {/tb_cpu/dut/pipeline_inst/memory_inst/wrdata(25) -radix decimal} {/tb_cpu/dut/pipeline_inst/memory_inst/wrdata(24) -radix decimal} {/tb_cpu/dut/pipeline_inst/memory_inst/wrdata(23) -radix decimal} {/tb_cpu/dut/pipeline_inst/memory_inst/wrdata(22) -radix decimal} {/tb_cpu/dut/pipeline_inst/memory_inst/wrdata(21) -radix decimal} {/tb_cpu/dut/pipeline_inst/memory_inst/wrdata(20) -radix decimal} {/tb_cpu/dut/pipeline_inst/memory_inst/wrdata(19) -radix decimal} {/tb_cpu/dut/pipeline_inst/memory_inst/wrdata(18) -radix decimal} {/tb_cpu/dut/pipeline_inst/memory_inst/wrdata(17) -radix decimal} {/tb_cpu/dut/pipeline_inst/memory_inst/wrdata(16) -radix decimal} {/tb_cpu/dut/pipeline_inst/memory_inst/wrdata(15) -radix decimal} {/tb_cpu/dut/pipeline_inst/memory_inst/wrdata(14) -radix decimal} {/tb_cpu/dut/pipeline_inst/memory_inst/wrdata(13) -radix decimal} {/tb_cpu/dut/pipeline_inst/memory_inst/wrdata(12) -radix decimal} {/tb_cpu/dut/pipeline_inst/memory_inst/wrdata(11) -radix decimal} {/tb_cpu/dut/pipeline_inst/memory_inst/wrdata(10) -radix decimal} {/tb_cpu/dut/pipeline_inst/memory_inst/wrdata(9) -radix decimal} {/tb_cpu/dut/pipeline_inst/memory_inst/wrdata(8) -radix decimal} {/tb_cpu/dut/pipeline_inst/memory_inst/wrdata(7) -radix decimal} {/tb_cpu/dut/pipeline_inst/memory_inst/wrdata(6) -radix decimal} {/tb_cpu/dut/pipeline_inst/memory_inst/wrdata(5) -radix decimal} {/tb_cpu/dut/pipeline_inst/memory_inst/wrdata(4) -radix decimal} {/tb_cpu/dut/pipeline_inst/memory_inst/wrdata(3) -radix decimal} {/tb_cpu/dut/pipeline_inst/memory_inst/wrdata(2) -radix decimal} {/tb_cpu/dut/pipeline_inst/memory_inst/wrdata(1) -radix decimal} {/tb_cpu/dut/pipeline_inst/memory_inst/wrdata(0) -radix decimal}} -subitemconfig {/tb_cpu/dut/pipeline_inst/memory_inst/wrdata(31) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/memory_inst/wrdata(30) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/memory_inst/wrdata(29) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/memory_inst/wrdata(28) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/memory_inst/wrdata(27) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/memory_inst/wrdata(26) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/memory_inst/wrdata(25) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/memory_inst/wrdata(24) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/memory_inst/wrdata(23) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/memory_inst/wrdata(22) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/memory_inst/wrdata(21) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/memory_inst/wrdata(20) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/memory_inst/wrdata(19) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/memory_inst/wrdata(18) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/memory_inst/wrdata(17) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/memory_inst/wrdata(16) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/memory_inst/wrdata(15) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/memory_inst/wrdata(14) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/memory_inst/wrdata(13) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/memory_inst/wrdata(12) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/memory_inst/wrdata(11) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/memory_inst/wrdata(10) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/memory_inst/wrdata(9) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/memory_inst/wrdata(8) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/memory_inst/wrdata(7) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/memory_inst/wrdata(6) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/memory_inst/wrdata(5) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/memory_inst/wrdata(4) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/memory_inst/wrdata(3) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/memory_inst/wrdata(2) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/memory_inst/wrdata(1) {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/memory_inst/wrdata(0) {-height 16 -radix decimal}} /tb_cpu/dut/pipeline_inst/memory_inst/wrdata
add wave -noupdate -expand -group CPU -group mem -expand -group entity /tb_cpu/dut/pipeline_inst/memory_inst/zero
add wave -noupdate -expand -group CPU -group mem -expand -group entity -divider {output to exec}
add wave -noupdate -expand -group CPU -group mem -expand -group entity -childformat {{/tb_cpu/dut/pipeline_inst/memory_inst/reg_write.reg -radix decimal} {/tb_cpu/dut/pipeline_inst/memory_inst/reg_write.data -radix decimal}} -subitemconfig {/tb_cpu/dut/pipeline_inst/memory_inst/reg_write.reg {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/memory_inst/reg_write.data {-height 16 -radix decimal}} /tb_cpu/dut/pipeline_inst/memory_inst/reg_write
add wave -noupdate -expand -group CPU -group mem -expand -group entity -divider {output to fetch}
add wave -noupdate -expand -group CPU -group mem -expand -group entity -radix decimal /tb_cpu/dut/pipeline_inst/memory_inst/pc_new_out
add wave -noupdate -expand -group CPU -group mem -expand -group entity /tb_cpu/dut/pipeline_inst/memory_inst/pcsrc
add wave -noupdate -expand -group CPU -group mem -expand -group entity -divider {output to wb and forward}
add wave -noupdate -expand -group CPU -group mem -expand -group entity -childformat {{/tb_cpu/dut/pipeline_inst/memory_inst/wbop_out.rd -radix decimal}} -subitemconfig {/tb_cpu/dut/pipeline_inst/memory_inst/wbop_out.rd {-height 16 -radix decimal}} /tb_cpu/dut/pipeline_inst/memory_inst/wbop_out
add wave -noupdate -expand -group CPU -group mem -expand -group entity -radix decimal /tb_cpu/dut/pipeline_inst/memory_inst/pc_old_out
add wave -noupdate -expand -group CPU -group mem -expand -group entity -radix decimal /tb_cpu/dut/pipeline_inst/memory_inst/aluresult_out
add wave -noupdate -expand -group CPU -group mem -expand -group entity -radix decimal /tb_cpu/dut/pipeline_inst/memory_inst/memresult
add wave -noupdate -expand -group CPU -group mem -expand -group entity -divider {memory controller interface}
add wave -noupdate -expand -group CPU -group mem -expand -group entity -childformat {{/tb_cpu/dut/pipeline_inst/memory_inst/mem_out.address -radix decimal} {/tb_cpu/dut/pipeline_inst/memory_inst/mem_out.rd -radix decimal} {/tb_cpu/dut/pipeline_inst/memory_inst/mem_out.wr -radix decimal} {/tb_cpu/dut/pipeline_inst/memory_inst/mem_out.wrdata -radix decimal}} -subitemconfig {/tb_cpu/dut/pipeline_inst/memory_inst/mem_out.address {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/memory_inst/mem_out.rd {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/memory_inst/mem_out.wr {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/memory_inst/mem_out.wrdata {-height 16 -radix decimal}} /tb_cpu/dut/pipeline_inst/memory_inst/mem_out
add wave -noupdate -expand -group CPU -group mem -expand -group entity -childformat {{/tb_cpu/dut/pipeline_inst/memory_inst/mem_in.busy -radix decimal}} -subitemconfig {/tb_cpu/dut/pipeline_inst/memory_inst/mem_in.busy {-height 16 -radix decimal}} /tb_cpu/dut/pipeline_inst/memory_inst/mem_in
add wave -noupdate -expand -group CPU -group mem -expand -group entity -divider exceptions
add wave -noupdate -expand -group CPU -group mem -expand -group entity /tb_cpu/dut/pipeline_inst/memory_inst/exc_load
add wave -noupdate -expand -group CPU -group mem -expand -group entity /tb_cpu/dut/pipeline_inst/memory_inst/exc_store
add wave -noupdate -expand -group CPU -group mem -group {internal signals} /tb_cpu/dut/pipeline_inst/memory_inst/mem_op_reg
add wave -noupdate -expand -group CPU -group mem -group {internal signals} -radix decimal /tb_cpu/dut/pipeline_inst/memory_inst/aluresult_in_reg
add wave -noupdate -expand -group CPU -group mem -group {internal signals} -radix decimal /tb_cpu/dut/pipeline_inst/memory_inst/aluresult_in_reg
add wave -noupdate -expand -group CPU -group mem -group {internal signals} -radix decimal /tb_cpu/dut/pipeline_inst/memory_inst/wrdata_reg
add wave -noupdate -expand -group CPU -group mem -group {internal signals} /tb_cpu/dut/pipeline_inst/memory_inst/zero_reg
add wave -noupdate -expand -group CPU -group mem -group {internal signals} -radix decimal /tb_cpu/dut/pipeline_inst/writeback_inst/memresult_reg
add wave -noupdate -expand -group CPU -group mem -expand -group memu_inst -expand /tb_cpu/dut/pipeline_inst/memory_inst/MEMU_INST/op
add wave -noupdate -expand -group CPU -group mem -expand -group memu_inst -radix decimal /tb_cpu/dut/pipeline_inst/memory_inst/MEMU_INST/A
add wave -noupdate -expand -group CPU -group mem -expand -group memu_inst -radix decimal /tb_cpu/dut/pipeline_inst/memory_inst/MEMU_INST/W
add wave -noupdate -expand -group CPU -group mem -expand -group memu_inst -radix decimal /tb_cpu/dut/pipeline_inst/memory_inst/MEMU_INST/R
add wave -noupdate -expand -group CPU -group mem -expand -group memu_inst /tb_cpu/dut/pipeline_inst/memory_inst/MEMU_INST/B
add wave -noupdate -expand -group CPU -group mem -expand -group memu_inst /tb_cpu/dut/pipeline_inst/memory_inst/MEMU_INST/XL
add wave -noupdate -expand -group CPU -group mem -expand -group memu_inst /tb_cpu/dut/pipeline_inst/memory_inst/MEMU_INST/XS
add wave -noupdate -expand -group CPU -group mem -expand -group memu_inst -expand /tb_cpu/dut/pipeline_inst/memory_inst/MEMU_INST/D
add wave -noupdate -expand -group CPU -group mem -expand -group memu_inst /tb_cpu/dut/pipeline_inst/memory_inst/MEMU_INST/M
add wave -noupdate -expand -group CPU -divider -height 40 wb
add wave -noupdate -expand -group CPU -group wb -expand -group entity /tb_cpu/dut/pipeline_inst/writeback_inst/stall
add wave -noupdate -expand -group CPU -group wb -expand -group entity /tb_cpu/dut/pipeline_inst/writeback_inst/flush
add wave -noupdate -expand -group CPU -group wb -expand -group entity -divider -height 16 {input from memory}
add wave -noupdate -expand -group CPU -group wb -expand -group entity -childformat {{/tb_cpu/dut/pipeline_inst/writeback_inst/op.rd -radix decimal}} -expand -subitemconfig {/tb_cpu/dut/pipeline_inst/writeback_inst/op.rd {-height 16 -radix decimal}} /tb_cpu/dut/pipeline_inst/writeback_inst/op
add wave -noupdate -expand -group CPU -group wb -expand -group entity -radix decimal /tb_cpu/dut/pipeline_inst/writeback_inst/aluresult
add wave -noupdate -expand -group CPU -group wb -expand -group entity -radix decimal /tb_cpu/dut/pipeline_inst/writeback_inst/memresult
add wave -noupdate -expand -group CPU -group wb -expand -group entity -radix decimal /tb_cpu/dut/pipeline_inst/writeback_inst/pc_old_in
add wave -noupdate -expand -group CPU -group wb -expand -group entity -divider {output to forward and decode}
add wave -noupdate -expand -group CPU -group wb -expand -group entity -radix decimal -childformat {{/tb_cpu/dut/pipeline_inst/writeback_inst/reg_write.write -radix decimal} {/tb_cpu/dut/pipeline_inst/writeback_inst/reg_write.reg -radix decimal} {/tb_cpu/dut/pipeline_inst/writeback_inst/reg_write.data -radix decimal}} -expand -subitemconfig {/tb_cpu/dut/pipeline_inst/writeback_inst/reg_write.write {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/writeback_inst/reg_write.reg {-height 16 -radix decimal} /tb_cpu/dut/pipeline_inst/writeback_inst/reg_write.data {-height 16 -radix decimal}} /tb_cpu/dut/pipeline_inst/writeback_inst/reg_write
add wave -noupdate -expand -group CPU -group wb -expand -group internals /tb_cpu/dut/pipeline_inst/writeback_inst/op_reg
add wave -noupdate -expand -group CPU -group wb -expand -group internals -radix decimal /tb_cpu/dut/pipeline_inst/writeback_inst/aluresult_reg
add wave -noupdate -expand -group CPU -group wb -expand -group internals -radix decimal /tb_cpu/dut/pipeline_inst/writeback_inst/pc_old_in_reg
add wave -noupdate -expand -group CPU -group wb -expand -group internals -radix decimal /tb_cpu/dut/pipeline_inst/writeback_inst/memresult_reg
add wave -noupdate -divider CACHE
add wave -noupdate -expand -group CACHE -label memu_busy /tb_cpu/dut/pipeline_inst/memory_inst/MEMU_INST/B
add wave -noupdate -expand -group CACHE -divider inputs
add wave -noupdate -expand -group CACHE /tb_cpu/dut/cache_inst/clk
add wave -noupdate -expand -group CACHE /tb_cpu/dut/cache_inst/res_n
add wave -noupdate -expand -group CACHE -expand /tb_cpu/dut/cache_inst/cpu_output
add wave -noupdate -expand -group CACHE /tb_cpu/dut/cache_inst/mem_output
add wave -noupdate -expand -group CACHE -divider outputs
add wave -noupdate -expand -group CACHE /tb_cpu/dut/cache_inst/mem_input
add wave -noupdate -expand -group CACHE /tb_cpu/dut/cache_inst/cpu_input
add wave -noupdate -expand -group CACHE -divider internals
add wave -noupdate -expand -group CACHE -expand -group state /tb_cpu/dut/cache_inst/state
add wave -noupdate -expand -group CACHE -expand -group state /tb_cpu/dut/cache_inst/state_next
add wave -noupdate -expand -group CACHE -expand -group busy /tb_cpu/dut/cache_inst/busy
add wave -noupdate -expand -group CACHE -expand -group busy /tb_cpu/dut/cache_inst/busy_next
add wave -noupdate -expand -group CACHE -expand -group cache_signals /tb_cpu/dut/cache_inst/set_index
add wave -noupdate -expand -group CACHE -expand -group cache_signals /tb_cpu/dut/cache_inst/set_index_next
add wave -noupdate -expand -group CACHE -expand -group cache_signals /tb_cpu/dut/cache_inst/tag
add wave -noupdate -expand -group CACHE -expand -group cache_signals /tb_cpu/dut/cache_inst/tag_next
add wave -noupdate -expand -group CACHE -expand -group cache_signals /tb_cpu/dut/cache_inst/st_index_in
add wave -noupdate -expand -group CACHE -expand -group cache_signals /tb_cpu/dut/cache_inst/st_tag_in
add wave -noupdate -expand -group CACHE -expand -group data_signals /tb_cpu/dut/cache_inst/data_st_we_in
add wave -noupdate -expand -group CACHE -expand -group data_signals /tb_cpu/dut/cache_inst/data_st_rd_in
add wave -noupdate -expand -group CACHE -expand -group data_signals /tb_cpu/dut/cache_inst/data_st_data_in
add wave -noupdate -expand -group CACHE -expand -group data_signals /tb_cpu/dut/cache_inst/data_st_data_out
add wave -noupdate -expand -group CACHE -expand -group mgmt_signals -expand -group input /tb_cpu/dut/cache_inst/mgmt_st_wr_in
add wave -noupdate -expand -group CACHE -expand -group mgmt_signals -expand -group input /tb_cpu/dut/cache_inst/mgmt_st_rd_in
add wave -noupdate -expand -group CACHE -expand -group mgmt_signals -expand -group input /tb_cpu/dut/cache_inst/mgmt_st_valid_in
add wave -noupdate -expand -group CACHE -expand -group mgmt_signals -expand -group input /tb_cpu/dut/cache_inst/mgmt_st_dirty_in
add wave -noupdate -expand -group CACHE -expand -group mgmt_signals -expand -group output /tb_cpu/dut/cache_inst/mgmt_st_way_out
add wave -noupdate -expand -group CACHE -expand -group mgmt_signals -expand -group output /tb_cpu/dut/cache_inst/mgmt_st_dirty_out
add wave -noupdate -expand -group CACHE -expand -group mgmt_signals -expand -group output /tb_cpu/dut/cache_inst/mgmt_st_hit_out
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -divider inputs
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/clk
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/res_n
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/index
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/wr
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/rd
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/valid_in
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/dirty_in
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/tag_in
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -divider outputs
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/way_out
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/valid_out
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/dirty_out
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/tag_out
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/hit_out
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -divider internals
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/current_way
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/last_way
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/hit_way
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/index_integer
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/hit_internal
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/repl_mem
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/repl_mem_update
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/valid_mem
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/dirty_mem
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/mgmt_info_out_array
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group mgmt_st_instances -group mgmt_st_1w_gen(0) -divider inputs
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group mgmt_st_instances -group mgmt_st_1w_gen(0) /tb_cpu/dut/cache_inst/mgmt_st_inst/mgmt_st_1w_gen(0)/mgmt_st_1w/clk
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group mgmt_st_instances -group mgmt_st_1w_gen(0) /tb_cpu/dut/cache_inst/mgmt_st_inst/mgmt_st_1w_gen(0)/mgmt_st_1w/res_n
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group mgmt_st_instances -group mgmt_st_1w_gen(0) /tb_cpu/dut/cache_inst/mgmt_st_inst/mgmt_st_1w_gen(0)/mgmt_st_1w/index
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group mgmt_st_instances -group mgmt_st_1w_gen(0) /tb_cpu/dut/cache_inst/mgmt_st_inst/mgmt_st_1w_gen(0)/mgmt_st_1w/we
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group mgmt_st_instances -group mgmt_st_1w_gen(0) /tb_cpu/dut/cache_inst/mgmt_st_inst/mgmt_st_1w_gen(0)/mgmt_st_1w/we_repl
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group mgmt_st_instances -group mgmt_st_1w_gen(0) /tb_cpu/dut/cache_inst/mgmt_st_inst/mgmt_st_1w_gen(0)/mgmt_st_1w/mgmt_info_in
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group mgmt_st_instances -group mgmt_st_1w_gen(0) -divider outputs
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group mgmt_st_instances -group mgmt_st_1w_gen(0) /tb_cpu/dut/cache_inst/mgmt_st_inst/mgmt_st_1w_gen(0)/mgmt_st_1w/mgmt_info_out
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group mgmt_st_instances -group mgmt_st_1w_gen(0) -divider internals
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group mgmt_st_instances -group mgmt_st_1w_gen(0) /tb_cpu/dut/cache_inst/mgmt_st_inst/mgmt_st_1w_gen(0)/mgmt_st_1w/mgmt_mem
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group mgmt_st_instances -group mgmt_st_1w_gen(0) /tb_cpu/dut/cache_inst/mgmt_st_inst/mgmt_st_1w_gen(0)/mgmt_st_1w/current_set
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group mgmt_st_instances -group mgmt_st_1w_gen(1) -divider inputs
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group mgmt_st_instances -group mgmt_st_1w_gen(1) /tb_cpu/dut/cache_inst/mgmt_st_inst/mgmt_st_1w_gen(1)/mgmt_st_1w/clk
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group mgmt_st_instances -group mgmt_st_1w_gen(1) /tb_cpu/dut/cache_inst/mgmt_st_inst/mgmt_st_1w_gen(1)/mgmt_st_1w/res_n
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group mgmt_st_instances -group mgmt_st_1w_gen(1) /tb_cpu/dut/cache_inst/mgmt_st_inst/mgmt_st_1w_gen(1)/mgmt_st_1w/index
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group mgmt_st_instances -group mgmt_st_1w_gen(1) /tb_cpu/dut/cache_inst/mgmt_st_inst/mgmt_st_1w_gen(1)/mgmt_st_1w/we
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group mgmt_st_instances -group mgmt_st_1w_gen(1) /tb_cpu/dut/cache_inst/mgmt_st_inst/mgmt_st_1w_gen(1)/mgmt_st_1w/we_repl
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group mgmt_st_instances -group mgmt_st_1w_gen(1) /tb_cpu/dut/cache_inst/mgmt_st_inst/mgmt_st_1w_gen(1)/mgmt_st_1w/mgmt_info_in
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group mgmt_st_instances -group mgmt_st_1w_gen(1) -divider outputs
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group mgmt_st_instances -group mgmt_st_1w_gen(1) /tb_cpu/dut/cache_inst/mgmt_st_inst/mgmt_st_1w_gen(1)/mgmt_st_1w/mgmt_info_out
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group mgmt_st_instances -group mgmt_st_1w_gen(1) -divider internals
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group mgmt_st_instances -group mgmt_st_1w_gen(1) /tb_cpu/dut/cache_inst/mgmt_st_inst/mgmt_st_1w_gen(1)/mgmt_st_1w/mgmt_mem
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group mgmt_st_instances -group mgmt_st_1w_gen(1) /tb_cpu/dut/cache_inst/mgmt_st_inst/mgmt_st_1w_gen(1)/mgmt_st_1w/current_set
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group repl_instances -group repl_gen(0)_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/repl_gen(0)/repl_inst/valid_in
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group repl_instances -group repl_gen(0)_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/repl_gen(0)/repl_inst/dirty_in
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group repl_instances -group repl_gen(0)_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/repl_gen(0)/repl_inst/replace_in
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group repl_instances -group repl_gen(0)_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/repl_gen(0)/repl_inst/replace_out
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group repl_instances -group repl_gen(1)_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/repl_gen(1)/repl_inst/valid_in
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group repl_instances -group repl_gen(1)_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/repl_gen(1)/repl_inst/dirty_in
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group repl_instances -group repl_gen(1)_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/repl_gen(1)/repl_inst/replace_in
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group repl_instances -group repl_gen(1)_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/repl_gen(1)/repl_inst/replace_out
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group repl_instances -group repl_gen(2)_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/repl_gen(2)/repl_inst/valid_in
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group repl_instances -group repl_gen(2)_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/repl_gen(2)/repl_inst/dirty_in
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group repl_instances -group repl_gen(2)_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/repl_gen(2)/repl_inst/replace_in
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group repl_instances -group repl_gen(2)_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/repl_gen(2)/repl_inst/replace_out
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group repl_instances -group repl_gen(3)_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/repl_gen(3)/repl_inst/valid_in
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group repl_instances -group repl_gen(3)_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/repl_gen(3)/repl_inst/dirty_in
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group repl_instances -group repl_gen(3)_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/repl_gen(3)/repl_inst/replace_in
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group repl_instances -group repl_gen(3)_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/repl_gen(3)/repl_inst/replace_out
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group repl_instances -group repl_gen(4)_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/repl_gen(4)/repl_inst/valid_in
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group repl_instances -group repl_gen(4)_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/repl_gen(4)/repl_inst/dirty_in
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group repl_instances -group repl_gen(4)_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/repl_gen(4)/repl_inst/replace_in
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group repl_instances -group repl_gen(4)_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/repl_gen(4)/repl_inst/replace_out
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group repl_instances -group repl_gen(5)_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/repl_gen(5)/repl_inst/valid_in
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group repl_instances -group repl_gen(5)_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/repl_gen(5)/repl_inst/dirty_in
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group repl_instances -group repl_gen(5)_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/repl_gen(5)/repl_inst/replace_in
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group repl_instances -group repl_gen(5)_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/repl_gen(5)/repl_inst/replace_out
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group repl_instances -group repl_gen(6)_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/repl_gen(6)/repl_inst/valid_in
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group repl_instances -group repl_gen(6)_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/repl_gen(6)/repl_inst/dirty_in
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group repl_instances -group repl_gen(6)_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/repl_gen(6)/repl_inst/replace_in
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group repl_instances -group repl_gen(6)_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/repl_gen(6)/repl_inst/replace_out
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group repl_instances -expand -group repl_gen(7)_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/repl_gen(7)/repl_inst/valid_in
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group repl_instances -expand -group repl_gen(7)_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/repl_gen(7)/repl_inst/dirty_in
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group repl_instances -expand -group repl_gen(7)_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/repl_gen(7)/repl_inst/replace_in
add wave -noupdate -expand -group CACHE -expand -group mgmt_st_inst -group repl_instances -expand -group repl_gen(7)_inst /tb_cpu/dut/cache_inst/mgmt_st_inst/repl_gen(7)/repl_inst/replace_out
add wave -noupdate -expand -group CACHE -group data_st_inst -divider inputs
add wave -noupdate -expand -group CACHE -group data_st_inst /tb_cpu/dut/cache_inst/data_st_inst/clk
add wave -noupdate -expand -group CACHE -group data_st_inst /tb_cpu/dut/cache_inst/data_st_inst/we
add wave -noupdate -expand -group CACHE -group data_st_inst /tb_cpu/dut/cache_inst/data_st_inst/rd
add wave -noupdate -expand -group CACHE -group data_st_inst /tb_cpu/dut/cache_inst/data_st_inst/way
add wave -noupdate -expand -group CACHE -group data_st_inst /tb_cpu/dut/cache_inst/data_st_inst/index
add wave -noupdate -expand -group CACHE -group data_st_inst /tb_cpu/dut/cache_inst/data_st_inst/byteena
add wave -noupdate -expand -group CACHE -group data_st_inst /tb_cpu/dut/cache_inst/data_st_inst/data_in
add wave -noupdate -expand -group CACHE -group data_st_inst -divider outputs
add wave -noupdate -expand -group CACHE -group data_st_inst /tb_cpu/dut/cache_inst/data_st_inst/data_out
add wave -noupdate -expand -group CACHE -group data_st_inst -divider internals
add wave -noupdate -expand -group CACHE -group data_st_inst /tb_cpu/dut/cache_inst/data_st_inst/data_out_array
add wave -noupdate -expand -group CACHE -group data_st_inst /tb_cpu/dut/cache_inst/data_st_inst/current_way
add wave -noupdate -expand -group CACHE -group data_st_inst /tb_cpu/dut/cache_inst/data_st_inst/last_way
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 -divider inputs
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(0)/data_st_1w/clk
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(0)/data_st_1w/we
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(0)/data_st_1w/rd
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(0)/data_st_1w/index
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(0)/data_st_1w/byteena
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(0)/data_st_1w/data_in
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 -divider outputs
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(0)/data_st_1w/data_out
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 -divider internals
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(0)/correct_way
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 -group ram_byte0_inst -divider intputs
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 -group ram_byte0_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(0)/data_st_1w/RAM_BYTEi_INST(0)/ram_inst/clk
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 -group ram_byte0_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(0)/data_st_1w/RAM_BYTEi_INST(0)/ram_inst/data_in
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 -group ram_byte0_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(0)/data_st_1w/RAM_BYTEi_INST(0)/ram_inst/write_address
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 -group ram_byte0_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(0)/data_st_1w/RAM_BYTEi_INST(0)/ram_inst/read_address
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 -group ram_byte0_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(0)/data_st_1w/RAM_BYTEi_INST(0)/ram_inst/we
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 -group ram_byte0_inst -divider output
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 -group ram_byte0_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(0)/data_st_1w/RAM_BYTEi_INST(0)/ram_inst/data_out
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 -group ram_byte0_inst -divider internals
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 -group ram_byte0_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(0)/data_st_1w/RAM_BYTEi_INST(0)/ram_inst/ram
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 -group ram_byte0_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(0)/data_st_1w/RAM_BYTEi_INST(0)/ram_inst/read_address_reg
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 -group ram_byte1_inst -divider inputs
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 -group ram_byte1_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(0)/data_st_1w/RAM_BYTEi_INST(1)/ram_inst/clk
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 -group ram_byte1_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(0)/data_st_1w/RAM_BYTEi_INST(1)/ram_inst/data_in
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 -group ram_byte1_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(0)/data_st_1w/RAM_BYTEi_INST(1)/ram_inst/write_address
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 -group ram_byte1_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(0)/data_st_1w/RAM_BYTEi_INST(1)/ram_inst/read_address
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 -group ram_byte1_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(0)/data_st_1w/RAM_BYTEi_INST(1)/ram_inst/we
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 -group ram_byte1_inst -divider output
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 -group ram_byte1_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(0)/data_st_1w/RAM_BYTEi_INST(1)/ram_inst/data_out
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 -group ram_byte1_inst -divider internals
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 -group ram_byte1_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(0)/data_st_1w/RAM_BYTEi_INST(1)/ram_inst/ram
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 -group ram_byte1_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(0)/data_st_1w/RAM_BYTEi_INST(1)/ram_inst/read_address_reg
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 -group ram_byte2_inst -divider intputs
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 -group ram_byte2_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(0)/data_st_1w/RAM_BYTEi_INST(2)/ram_inst/clk
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 -group ram_byte2_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(0)/data_st_1w/RAM_BYTEi_INST(2)/ram_inst/data_in
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 -group ram_byte2_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(0)/data_st_1w/RAM_BYTEi_INST(2)/ram_inst/write_address
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 -group ram_byte2_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(0)/data_st_1w/RAM_BYTEi_INST(2)/ram_inst/read_address
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 -group ram_byte2_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(0)/data_st_1w/RAM_BYTEi_INST(2)/ram_inst/we
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 -group ram_byte2_inst -divider output
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 -group ram_byte2_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(0)/data_st_1w/RAM_BYTEi_INST(2)/ram_inst/data_out
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 -group ram_byte2_inst -divider internals
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 -group ram_byte2_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(0)/data_st_1w/RAM_BYTEi_INST(2)/ram_inst/ram
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 -group ram_byte2_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(0)/data_st_1w/RAM_BYTEi_INST(2)/ram_inst/read_address_reg
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 -group ram_byte3_inst -divider inputs
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 -group ram_byte3_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(0)/data_st_1w/RAM_BYTEi_INST(3)/ram_inst/clk
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 -group ram_byte3_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(0)/data_st_1w/RAM_BYTEi_INST(3)/ram_inst/data_in
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 -group ram_byte3_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(0)/data_st_1w/RAM_BYTEi_INST(3)/ram_inst/write_address
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 -group ram_byte3_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(0)/data_st_1w/RAM_BYTEi_INST(3)/ram_inst/read_address
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 -group ram_byte3_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(0)/data_st_1w/RAM_BYTEi_INST(3)/ram_inst/we
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 -group ram_byte3_inst -divider output
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 -group ram_byte3_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(0)/data_st_1w/RAM_BYTEi_INST(3)/ram_inst/data_out
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 -group ram_byte3_inst -divider internals
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 -group ram_byte3_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(0)/data_st_1w/RAM_BYTEi_INST(3)/ram_inst/ram
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen0 -group ram_byte3_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(0)/data_st_1w/RAM_BYTEi_INST(3)/ram_inst/read_address_reg
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 -divider inputs
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(1)/data_st_1w/clk
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(1)/data_st_1w/we
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(1)/data_st_1w/rd
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(1)/data_st_1w/index
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(1)/data_st_1w/byteena
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(1)/data_st_1w/data_in
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 -divider outputs
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(1)/data_st_1w/data_out
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 -divider internals
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(1)/correct_way
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 -group ram_byte0_inst -divider intputs
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 -group ram_byte0_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(1)/data_st_1w/RAM_BYTEi_INST(0)/ram_inst/clk
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 -group ram_byte0_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(1)/data_st_1w/RAM_BYTEi_INST(0)/ram_inst/data_in
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 -group ram_byte0_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(1)/data_st_1w/RAM_BYTEi_INST(0)/ram_inst/write_address
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 -group ram_byte0_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(1)/data_st_1w/RAM_BYTEi_INST(0)/ram_inst/read_address
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 -group ram_byte0_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(1)/data_st_1w/RAM_BYTEi_INST(0)/ram_inst/we
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 -group ram_byte0_inst -divider output
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 -group ram_byte0_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(1)/data_st_1w/RAM_BYTEi_INST(0)/ram_inst/data_out
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 -group ram_byte0_inst -divider internals
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 -group ram_byte0_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(1)/data_st_1w/RAM_BYTEi_INST(0)/ram_inst/ram
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 -group ram_byte0_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(1)/data_st_1w/RAM_BYTEi_INST(0)/ram_inst/read_address_reg
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 -group ram_byte1_inst -divider inputs
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 -group ram_byte1_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(1)/data_st_1w/RAM_BYTEi_INST(1)/ram_inst/clk
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 -group ram_byte1_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(1)/data_st_1w/RAM_BYTEi_INST(1)/ram_inst/data_in
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 -group ram_byte1_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(1)/data_st_1w/RAM_BYTEi_INST(1)/ram_inst/write_address
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 -group ram_byte1_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(1)/data_st_1w/RAM_BYTEi_INST(1)/ram_inst/read_address
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 -group ram_byte1_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(1)/data_st_1w/RAM_BYTEi_INST(1)/ram_inst/we
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 -group ram_byte1_inst -divider output
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 -group ram_byte1_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(1)/data_st_1w/RAM_BYTEi_INST(1)/ram_inst/data_out
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 -group ram_byte1_inst -divider internals
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 -group ram_byte1_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(1)/data_st_1w/RAM_BYTEi_INST(1)/ram_inst/ram
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 -group ram_byte1_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(1)/data_st_1w/RAM_BYTEi_INST(1)/ram_inst/read_address_reg
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 -group ram_byte2_inst -divider intputs
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 -group ram_byte2_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(1)/data_st_1w/RAM_BYTEi_INST(2)/ram_inst/clk
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 -group ram_byte2_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(1)/data_st_1w/RAM_BYTEi_INST(2)/ram_inst/data_in
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 -group ram_byte2_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(1)/data_st_1w/RAM_BYTEi_INST(2)/ram_inst/write_address
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 -group ram_byte2_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(1)/data_st_1w/RAM_BYTEi_INST(2)/ram_inst/read_address
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 -group ram_byte2_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(1)/data_st_1w/RAM_BYTEi_INST(2)/ram_inst/we
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 -group ram_byte2_inst -divider output
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 -group ram_byte2_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(1)/data_st_1w/RAM_BYTEi_INST(2)/ram_inst/data_out
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 -group ram_byte2_inst -divider internals
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 -group ram_byte2_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(1)/data_st_1w/RAM_BYTEi_INST(2)/ram_inst/ram
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 -group ram_byte2_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(1)/data_st_1w/RAM_BYTEi_INST(2)/ram_inst/read_address_reg
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 -group ram_byte3_inst -divider inputs
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 -group ram_byte3_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(1)/data_st_1w/RAM_BYTEi_INST(3)/ram_inst/clk
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 -group ram_byte3_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(1)/data_st_1w/RAM_BYTEi_INST(3)/ram_inst/data_in
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 -group ram_byte3_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(1)/data_st_1w/RAM_BYTEi_INST(3)/ram_inst/write_address
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 -group ram_byte3_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(1)/data_st_1w/RAM_BYTEi_INST(3)/ram_inst/read_address
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 -group ram_byte3_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(1)/data_st_1w/RAM_BYTEi_INST(3)/ram_inst/we
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 -group ram_byte3_inst -divider output
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 -group ram_byte3_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(1)/data_st_1w/RAM_BYTEi_INST(3)/ram_inst/data_out
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 -group ram_byte3_inst -divider internals
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 -group ram_byte3_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(1)/data_st_1w/RAM_BYTEi_INST(3)/ram_inst/ram
add wave -noupdate -expand -group CACHE -group data_st_inst -group data_st_1w_gen1 -group ram_byte3_inst /tb_cpu/dut/cache_inst/data_st_inst/data_st_1w_gen(1)/data_st_1w/RAM_BYTEi_INST(3)/ram_inst/read_address_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {write_miss {85000 ps} 1} {Cursor {214824 ps} 0} {read_miss {135000 ps} 1} {read_hit {215000 ps} 1} {write_hit {275000 ps} 1} {dirty_read_miss {315000 ps} 1}
quietly wave cursor active 2
configure wave -namecolwidth 212
configure wave -valuecolwidth 483
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {131248 ps} {248783 ps}
