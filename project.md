# Project Specification: 282-Module Advanced SoC Architecture (TSMC 90nm)

## Module Hierarchy & Build Order

### Block 1: Foundational Primitives & CDC (Modules 1–32)
1. `sv_standard_cell_ram.sv`
2. `sv_standard_cell_rom.sv`
3. `sync_fifo.sv`
4. `async_fifo.sv`
5. `skid_buffer.sv`
6. `level_synchronizer.sv`
7. `pulse_synchronizer.sv`
8. `handshake_synchronizer.sv`
9. `gray_to_binary.sv`
10. `binary_to_gray.sv`
11. `clock_gating_cell.sv`
12. `mux_tree_32b.sv`
13. `mux_tree_64b.sv`
14. `priority_encoder_32.sv`
15. `priority_encoder_64.sv`
16. `decoder_5to32.sv`
17. `decoder_6to64.sv`
18. `carry_lookahead_adder_32.sv`
19. `carry_lookahead_adder_64.sv`
20. `wallace_tree_mult_32.sv`
21. `wallace_tree_mult_64.sv`
22. `radix4_booth_encoder.sv`
23. `barrel_shifter_64.sv`
24. `int4_multiplier.sv`
25. `int8_multiplier.sv`
26. `bf16_multiplier.sv`
27. `bf16_adder.sv`
28. `fp32_fused_mac.sv`
29. `fp64_fused_mac.sv`
30. `prng_lfsr.sv`
31. `pll_clock_generator.sv`
32. `dll_phase_shifter.sv`

### Block 2: Quad-Core RV64GC Out-of-Order Core Subsystem (Modules 33–79)
33. `rv64_quad_core_cluster.sv`
34. `rv64_core_top.sv`
35. `pc_gen_unit.sv`
36. `fetch_buffer.sv`
37. `instr_prefetcher.sv`
38. `branch_target_buffer.sv`
39. `branch_history_table.sv`
40. `tournament_predictor.sv`
41. `return_address_stack.sv`
42. `pre_decode_unit.sv`
43. `instr_decoder.sv`
44. `compressed_decoder_rvc.sv`
45. `micro_op_sequencer.sv`
46. `register_alias_table.sv`
47. `freelist_manager.sv`
48. `register_rename_unit.sv`
49. `dispatch_unit_4way.sv`
50. `issue_queue_manager.sv`
51. `reservation_station_alu_0.sv`
52. `reservation_station_alu_1.sv`
53. `reservation_station_mem.sv`
54. `reservation_station_branch.sv`
55. `reorder_buffer_ctrl.sv`
56. `rob_memory_array.sv`
57. `commit_unit.sv`
58. `exception_handler.sv`
59. `trap_vector_ctrl.sv`
60. `csr_register_file.sv`
61. `csr_control_unit.sv`
62. `alu_execution_unit_0.sv`
63. `alu_execution_unit_1.sv`
64. `alu_execution_unit_2.sv`
65. `alu_execution_unit_3.sv`
66. `branch_execution_unit.sv`
67. `address_gen_unit.sv`
68. `mul_div_execution_unit.sv`
69. `forwarding_network_ctrl.sv`
70. `load_queue.sv`
71. `store_queue.sv`
72. `store_buffer.sv`
73. `memory_disambiguation_unit.sv`
74. `wakeup_select_logic.sv`
75. `architectural_regfile.sv`
76. `physical_regfile.sv`
77. `core_performance_counters.sv`
78. `core_debug_module.sv`
79. `trusted_execution_enclave.sv`

### Block 3: RVV Vector Subsystem (Modules 80–99)
80. `vector_core_top.sv`
81. `vector_dispatch_queue.sv`
82. `vector_regfile_512b.sv`
83. `vector_mask_regfile.sv`
84. `vector_lane_0.sv`
85. `vector_lane_1.sv`
86. `vector_lane_2.sv`
87. `vector_lane_3.sv`
88. `vector_alu_int.sv`
89. `vector_alu_fp.sv`
90. `vector_mac_array.sv`
91. `vector_reduction_unit.sv`
92. `vector_gather_scatter_unit.sv`
93. `vector_load_store_unit.sv`
94. `vector_slide_unit.sv`
95. `vector_permutation_network.sv`
96. `vector_mask_logic.sv`
97. `vector_csr_unit.sv`
98. `vector_forwarding_unit.sv`
99. `vector_commit_buffer.sv`

### Block 4: FPU Subsystem (Modules 100–116)
100. `fpu_top.sv`
101. `fpu_issue_queue.sv`
102. `fpu_regfile.sv`
103. `fpu_decoder.sv`
104. `fpu_adder_stage1.sv`
105. `fpu_adder_stage2.sv`
106. `fpu_adder_stage3.sv`
107. `fpu_multiplier_stage1.sv`
108. `fpu_multiplier_stage2.sv`
109. `fpu_multiplier_stage3.sv`
110. `fpu_divider_srt_radix4.sv`
111. `fpu_sqrt_unit.sv`
112. `fpu_rounding_unit.sv`
113. `fpu_exception_flags.sv`
114. `fpu_mac_pipeline.sv`
115. `fpu_forwarding_unit.sv`
116. `fpu_commit_unit.sv`

### Block 5: Advanced Memory Hierarchy & Coherency (Modules 117–146)
117. `mmu_top.sv`
118. `itlb_array.sv`
119. `dtlb_array.sv`
120. `jtlb_core.sv`
121. `hardware_page_walker.sv`
122. `pma_checker.sv`
123. `pmp_checker.sv`
124. `iommu_core.sv`
125. `iommu_translation_cache.sv`
126. `l1_icache_tags.sv`
127. `l1_icache_data.sv`
128. `l1_icache_ctrl.sv`
129. `l1_dcache_tags.sv`
130. `l1_dcache_data.sv`
131. `l1_dcache_ctrl.sv`
132. `stride_prefetcher.sv`
133. `stream_prefetcher.sv`
134. `l2_cache_tags.sv`
135. `l2_cache_data_banks.sv`
136. `l2_cache_ctrl_multicore.sv`
137. `l3_cache_tags.sv`
138. `l3_cache_data_banks.sv`
139. `l3_cache_ctrl_unified.sv`
140. `mesi_coherency_directory.sv`
141. `snoop_filter_unit.sv`
142. `coherency_bus_interface.sv`
143. `cache_eviction_manager.sv`
144. `memory_arbiter_core.sv`
145. `hardware_memory_scrubber.sv`
146. `memory_encryption_engine.sv`

### Block 6: NPU Subsystem (Modules 147–186)
147. `npu_top.sv`
148. `npu_host_interface.sv`
149. `npu_instruction_decoder.sv`
150. `npu_issue_queue.sv`
151. `mac_cell_int4_int8.sv`
152. `mac_cell_bf16_fp32.sv`
153. `npu_systolic_array_128x128.sv`
154. `sparsity_decoder_unit.sv`
155. `zero_skipping_logic.sv`
156. `weight_compression_decoder.sv`
157. `vector_processing_unit.sv`
158. `relu_activation_unit.sv`
159. `sigmoid_activation_unit.sv`
160. `tanh_activation_unit.sv`
161. `gelu_activation_unit.sv`
162. `softmax_exp_unit.sv`
163. `layer_norm_engine.sv`
164. `batch_norm_engine.sv`
165. `max_pool_engine.sv`
166. `avg_pool_engine.sv`
167. `tensor_reshape_unit.sv`
168. `tensor_transpose_unit.sv`
169. `weight_scratchpad_bank_0.sv`
170. `weight_scratchpad_bank_1.sv`
171. `weight_scratchpad_ctrl.sv`
172. `activation_scratchpad_bank_0.sv`
173. `activation_scratchpad_bank_1.sv`
174. `activation_scratchpad_ctrl.sv`
175. `psum_accumulation_buffer.sv`
176. `psum_scratchpad_ctrl.sv`
177. `npu_dma_read_channel_0.sv`
178. `npu_dma_read_channel_1.sv`
179. `npu_dma_write_channel.sv`
180. `npu_dma_arbiter.sv`
181. `npu_axi_burst_controller.sv`
182. `npu_power_management.sv`
183. `npu_performance_monitor.sv`
184. `npu_interrupt_ctrl.sv`
185. `npu_debug_trace_unit.sv`
186. `npu_clock_gating_ctrl.sv`

### Block 7: GPU Subsystem (Modules 187–228)
187. `gpu_top.sv`
188. `gpu_host_bridge.sv`
189. `gpu_command_streamer.sv`
190. `geometry_dispatch_unit.sv`
191. `hull_shader_engine.sv`
192. `tessellation_primitive_gen.sv`
193. `domain_shader_engine.sv`
194. `geometry_shader_engine.sv`
195. `hierarchical_z_cull_unit.sv`
196. `edge_equation_evaluator.sv`
197. `tile_traversal_unit.sv`
198. `gpu_rasterizer_core.sv`
199. `shader_dispatch_controller.sv`
200. `gpu_unified_shader_core_0.sv`
201. `gpu_unified_shader_core_1.sv`
202. `gpu_unified_shader_core_2.sv`
203. `gpu_unified_shader_core_3.sv`
204. `shader_vector_alu.sv`
205. `shader_scalar_alu.sv`
206. `shader_register_file.sv`
207. `compute_shader_manager.sv`
208. `texture_address_generator.sv`
209. `texture_l1_cache.sv`
210. `texture_l2_cache.sv`
211. `texture_decompression_unit.sv`
212. `bilinear_filter_unit.sv`
213. `trilinear_filter_unit.sv`
214. `anisotropic_filter_unit.sv`
215. `depth_stencil_test_unit.sv`
216. `alpha_blend_unit.sv`
217. `color_format_converter.sv`
218. `gpu_rop_pipeline.sv`
219. `framebuffer_cache_ctrl.sv`
220. `vga_timing_generator.sv`
221. `hdmi_output_formatter.sv`
222. `gpu_dma_read_engine.sv`
223. `gpu_dma_write_engine.sv`
224. `gpu_axi_burst_ctrl.sv`
225. `gpu_mmu_translation.sv`
226. `gpu_context_switch_mgr.sv`
227. `gpu_interrupt_handler.sv`
228. `gpu_power_gating_ctrl.sv`

### Block 8: Hardware Video/Media Codec Subsystem (Modules 229–237)
229. `video_codec_top.sv`
230. `av1_decoder_core.sv`
231. `hevc_h265_encoder.sv`
232. `motion_estimation_engine.sv`
233. `entropy_decoder_cabac.sv`
234. `inverse_transform_unit.sv`
235. `deblocking_filter.sv`
236. `video_dma_engine.sv`
237. `display_processor_2d.sv`

### Block 9: Network-on-Chip (NoC) & Interconnect (Modules 238–251)
238. `noc_mesh_router_core.sv`
239. `noc_network_interface_cpu.sv`
240. `noc_network_interface_npu.sv`
241. `noc_network_interface_gpu.sv`
242. `noc_network_interface_mem.sv`
243. `virtual_channel_allocator.sv`
244. `switch_allocator_arbiter.sv`
245. `noc_credit_manager.sv`
246. `axi4_to_noc_bridge.sv`
247. `noc_to_axi4_bridge.sv`
248. `axi4_crossbar_lite.sv`
249. `axi4_master_bfm.sv`
250. `axi4_slave_bfm.sv`
251. `axi2apb_bridge_core.sv`

### Block 10: SoC, I/O, & Advanced Peripherals (Modules 252–282)
252. `pcie_gen4_root_complex.sv`
253. `pcie_axi_bridge.sv`
254. `ddr4_phy_interface.sv`
255. `ddr4_memory_controller.sv`
256. `scatter_gather_dma_engine.sv`
257. `dma_descriptor_fetcher.sv`
258. `hardware_crypto_aes.sv`
259. `hardware_crypto_sha256.sv`
260. `plic_core_interrupt_ctrl.sv`
261. `clint_core_timer.sv`
262. `apb_uart_fifo.sv`
263. `apb_qspi_flash_ctrl.sv`
264. `apb_i2c_master.sv`
265. `apb_timer_watchdog.sv`
266. `apb_gpio_port.sv`
267. `rtc_module_core.sv`
268. `dvfs_power_controller.sv`
269. `thermal_sensor_adc.sv`
270. `clock_reset_manager.sv`
271. `jtag_debug_transport.sv`
272. `soc_reset_controller.sv`
273. `boot_rom_controller.sv`
274. `axi4_lite_interconnect.sv`
275. `pinmux_controller.sv`
276. `i2s_audio_interface.sv`
277. `ethernet_mac_10g.sv`
278. `usb_3_0_controller.sv`
279. `usb_phy_wrapper.sv`
280. `mipi_dsi_controller.sv`
281. `mipi_csi_controller.sv`
282. `soc_top.sv`

---

## Port Specifications

### Block 1 (Batch 1)

**`sv_standard_cell_ram.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `we` | input | 1 | Write Enable (Active High) |
| `addr` | input | `$clog2(DEPTH)` | Memory Address |
| `wdata` | input | `DATA_WIDTH` | Write Data |
| `rdata` | output | `DATA_WIDTH` | Read Data |

---
**`sv_standard_cell_rom.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `re` | input | 1 | Read Enable (Active High) |
| `addr` | input | `$clog2(DEPTH)` | ROM Address |
| `rdata` | output | `DATA_WIDTH` | Read Data |

---
**`sync_fifo.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rst_n` | input | 1 | Synchronous reset (Active Low) |
| `push` | input | 1 | Push/Write Enable |
| `pop` | input | 1 | Pop/Read Enable |
| `data_in` | input | `DATA_WIDTH` | Data to be written |
| `data_out` | output | `DATA_WIDTH` | Data to be read |
| `full` | output | 1 | FIFO is full flag |
| `empty` | output | 1 | FIFO is empty flag |


### Block 1 (Batch 2)

**`async_fifo.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `wclk` | input | 1 | Write Clock |
| `wrst_n` | input | 1 | Write Domain Reset (Active Low) |
| `wpush` | input | 1 | Write Enable |
| `wdata` | input | `DATA_WIDTH` | Write Data |
| `wfull` | output | 1 | Write Full Flag |
| `rclk` | input | 1 | Read Clock |
| `rrst_n` | input | 1 | Read Domain Reset (Active Low) |
| `rpop` | input | 1 | Read Enable |
| `rdata` | output | `DATA_WIDTH` | Read Data |
| `rempty` | output | 1 | Read Empty Flag |

---
**`skid_buffer.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rst_n` | input | 1 | Reset (Active Low) |
| `s_valid` | input | 1 | Slave valid |
| `s_ready` | output | 1 | Slave ready |
| `s_data` | input | `DATA_WIDTH` | Slave data |
| `m_valid` | output | 1 | Master valid |
| `m_ready` | input | 1 | Master ready |
| `m_data` | output | `DATA_WIDTH` | Master data |

---
**`level_synchronizer.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk_dest` | input | 1 | Destination Clock |
| `rst_dest_n` | input | 1 | Destination Reset (Active Low) |
| `sig_in` | input | 1 | Asynchronous input signal |
| `sig_out` | output | 1 | Synchronized output signal |

### Block 1 (Batch 3)

**`pulse_synchronizer.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk_src` | input | 1 | Source Clock |
| `rst_src_n` | input | 1 | Source Reset (Active Low) |
| `pulse_in` | input | 1 | Source domain pulse |
| `clk_dest` | input | 1 | Destination Clock |
| `rst_dest_n` | input | 1 | Destination Reset (Active Low) |
| `pulse_out` | output | 1 | Destination domain pulse |

---
**`handshake_synchronizer.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk_src` | input | 1 | Source Clock |
| `rst_src_n` | input | 1 | Source Reset |
| `req_in` | input | 1 | Request from source |
| `ack_out` | output | 1 | Acknowledge back to source |
| `data_in` | input | `DATA_WIDTH` | Data from source |
| `clk_dest` | input | 1 | Destination Clock |
| `rst_dest_n` | input | 1 | Destination Reset |
| `req_out` | output | 1 | Request to destination |
| `ack_in` | input | 1 | Acknowledge from destination |
| `data_out` | output | `DATA_WIDTH` | Data to destination |

---
**`gray_to_binary.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `gray_in` | input | `WIDTH` | Gray code input |
| `bin_out` | output | `WIDTH` | Binary output |

### Block 1 (Batch 4)

**`binary_to_gray.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `bin_in` | input | `WIDTH` | Binary input |
| `gray_out` | output | `WIDTH` | Gray code output |

---
**`clock_gating_cell.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk_in` | input | 1 | Input Clock |
| `en` | input | 1 | Enable signal |
| `test_en` | input | 1 | Test Enable (DFT) |
| `clk_out` | output | 1 | Gated Clock |

---
**`mux_tree_32b.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `data_in` | input | `32 * DATA_WIDTH` | Flat input data array |
| `sel` | input | 5 | Select line |
| `data_out` | output | `DATA_WIDTH` | Selected data |

### Block 1 (Batch 5)

**`mux_tree_64b.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `data_in` | input | `64 * DATA_WIDTH` | Flat input data array |
| `sel` | input | 6 | Select line |
| `data_out` | output | `DATA_WIDTH` | Selected data |

---
**`priority_encoder_32.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `req` | input | 32 | Request vector |
| `valid` | output | 1 | Any request valid |
| `grant` | output | 5 | Index of highest priority request |

---
**`priority_encoder_64.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `req` | input | 64 | Request vector |
| `valid` | output | 1 | Any request valid |
| `grant` | output | 6 | Index of highest priority request |

### Block 1 (Batch 6)

**`decoder_5to32.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `en` | input | 1 | Enable |
| `sel` | input | 5 | Input select |
| `dec_out` | output | 32 | Decoded one-hot output |

---
**`decoder_6to64.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `en` | input | 1 | Enable |
| `sel` | input | 6 | Input select |
| `dec_out` | output | 64 | Decoded one-hot output |

---
**`carry_lookahead_adder_32.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `a` | input | 32 | Operand A |
| `b` | input | 32 | Operand B |
| `c_in` | input | 1 | Carry in |
| `sum` | output | 32 | Sum result |
| `c_out` | output | 1 | Carry out |

### Block 1 (Batch 7)

**`carry_lookahead_adder_64.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `a` | input | 64 | Operand A |
| `b` | input | 64 | Operand B |
| `c_in` | input | 1 | Carry in |
| `sum` | output | 64 | Sum result |
| `c_out` | output | 1 | Carry out |

---
**`wallace_tree_mult_32.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `a` | input | 32 | Multiplicand |
| `b` | input | 32 | Multiplier |
| `prod` | output | 64 | Product |

---
**`wallace_tree_mult_64.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `a` | input | 64 | Multiplicand |
| `b` | input | 64 | Multiplier |
| `prod` | output | 128 | Product |

### Block 1 (Batch 8)

**`radix4_booth_encoder.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `mult` | input | 3 | 3-bit multiplier window |
| `neg` | output | 1 | Negative flag |
| `zero` | output | 1 | Zero flag |
| `two` | output | 1 | Multiply by 2 flag |
| `one` | output | 1 | Multiply by 1 flag |

---
**`barrel_shifter_64.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `data_in` | input | 64 | Data to shift |
| `shift_amt` | input | 6 | Shift amount |
| `dir` | input | 1 | Direction (0: Left, 1: Right) |
| `arith` | input | 1 | Arithmetic shift flag |
| `data_out` | output | 64 | Shifted data |

---
**`int4_multiplier.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `a` | input | 4 | Operand A |
| `b` | input | 4 | Operand B |
| `prod` | output | 8 | Product |

### Block 1 (Batch 9)

**`int8_multiplier.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `a` | input | 8 | Operand A |
| `b` | input | 8 | Operand B |
| `prod` | output | 16 | Product |

---
**`bf16_multiplier.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `a` | input | 16 | Bfloat16 Operand A |
| `b` | input | 16 | Bfloat16 Operand B |
| `prod` | output | 16 | Bfloat16 Product |

---
**`bf16_adder.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `a` | input | 16 | Bfloat16 Operand A |
| `b` | input | 16 | Bfloat16 Operand B |
| `sum` | output | 16 | Bfloat16 Sum |

### Block 1 (Batch 10)

**`fp32_fused_mac.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rst_n` | input | 1 | Reset |
| `a` | input | 32 | FP32 Operand A |
| `b` | input | 32 | FP32 Operand B |
| `c` | input | 32 | FP32 Addend C |
| `out` | output | 32 | FP32 MAC Result |

---
**`fp64_fused_mac.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rst_n` | input | 1 | Reset |
| `a` | input | 64 | FP64 Operand A |
| `b` | input | 64 | FP64 Operand B |
| `c` | input | 64 | FP64 Addend C |
| `out` | output | 64 | FP64 MAC Result |

---
**`prng_lfsr.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rst_n` | input | 1 | Reset |
| `seed` | input | 32 | LFSR Seed |
| `load` | input | 1 | Load seed enable |
| `en` | input | 1 | Enable generator |
| `rand_out`| output | 32 | Pseudo-random output |

### Block 1 (Batch 11)

**`pll_clock_generator.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk_ref` | input | 1 | Reference Clock |
| `rst_n` | input | 1 | Reset |
| `mult` | input | 8 | PLL Multiplier |
| `div` | input | 8 | PLL Divider |
| `clk_out` | output | 1 | Generated Clock |
| `locked` | output | 1 | PLL Locked Flag |

---
**`dll_phase_shifter.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk_in` | input | 1 | Input Clock |
| `rst_n` | input | 1 | Reset |
| `phase_sel`| input | 4 | Phase Shift Select |
| `clk_out` | output | 1 | Phase-shifted Clock |
| `locked` | output | 1 | DLL Locked Flag |


### Block 2 (Batch 12)

**`rv64_quad_core_cluster.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rst_n` | input | 1 | Reset (Active Low) |
| `axi_m_if` | interface | AXI4 | AXI4 Master Interface to NoC/L3 |
| `ext_int` | input | 4 | External Interrupts (1 per core) |

---
**`rv64_core_top.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Core Clock |
| `rst_n` | input | 1 | Core Reset |
| `core_id` | input | 2 | Core Identification (0-3) |
| `icache_if` | inout | INTF | L1 Instruction Cache Interface |
| `dcache_if` | inout | INTF | L1 Data Cache Interface |
| `irq` | input | 1 | Interrupt Request |

---
**`pc_gen_unit.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rst_n` | input | 1 | Reset |
| `stall` | input | 1 | Pipeline Stall |
| `redirect` | input | 1 | Branch Redirect Enable |
| `target_pc` | input | 64 | Redirect Target PC |
| `next_pc` | output | 64 | Next Program Counter |

### Block 2 (Batch 13)

**`fetch_buffer.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rst_n` | input | 1 | Reset |
| `push` | input | 1 | Push Enable (from I-Cache) |
| `pop_cnt` | input | 2 | Pop Count (0 to 2 instructions) |
| `instr_in` | input | 256 | 256-bit Fetch Block |
| `instr_out`| output | 64 | Up to 2 Instructions |
| `empty` | output | 1 | Buffer Empty |

---
**`instr_prefetcher.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rst_n` | input | 1 | Reset |
| `pc_in` | input | 64 | Current PC |
| `prefetch_req` | output | 1 | Request I-Cache Prefetch |
| `prefetch_addr` | output | 64 | Address to Prefetch |

---
**`branch_target_buffer.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rst_n` | input | 1 | Reset |
| `pc` | input | 64 | Current Fetch PC |
| `btb_hit` | output | 1 | BTB Hit |
| `btb_target` | output | 64 | Predicted Target PC |
| `update_en` | input | 1 | Update Enable |
| `update_pc` | input | 64 | Update PC |

### Block 2 (Batch 14)

**`branch_history_table.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rst_n` | input | 1 | Reset |
| `pc` | input | 64 | Instruction PC |
| `predict_taken` | output | 1 | Branch Prediction |
| `update_en` | input | 1 | Update Enable |
| `actual_taken` | input | 1 | Actual Branch Outcome |

---
**`tournament_predictor.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rst_n` | input | 1 | Reset |
| `pred_a` | input | 1 | Prediction from local BHT |
| `pred_b` | input | 1 | Prediction from global BHT |
| `final_pred` | output | 1 | Selected Prediction |
| `update_en` | input | 1 | Update Enable |

---
**`return_address_stack.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rst_n` | input | 1 | Reset |
| `push` | input | 1 | Push on CALL |
| `pop` | input | 1 | Pop on RET |
| `ret_addr_in` | input | 64 | Return Address |
| `ret_addr_out`| output | 64 | Predicted Return Address |

### Block 2 (Batch 15)

**`pre_decode_unit.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `instr_in` | input | 64 | Raw Instruction |
| `is_branch` | output | 1 | Branch identifier |
| `is_compressed` | output | 1 | RVC identifier |
| `instr_len` | output | 2 | Instruction length in bytes |

---
**`instr_decoder.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `instr` | input | 32 | 32-bit Instruction |
| `opcode` | output | 7 | Opcode |
| `rs1`, `rs2`, `rd` | output | 5 | Register indices |
| `imm` | output | 64 | Sign-extended immediate |
| `alu_op` | output | 4 | ALU Operation |

---
**`compressed_decoder_rvc.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `instr_rvc` | input | 16 | 16-bit Compressed Instr |
| `instr_rv32` | output | 32 | Expanded 32-bit Instr |
| `illegal_instr` | output | 1 | Illegal Instruction Flag |

### Block 2 (Batch 16)

**`micro_op_sequencer.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rst_n` | input | 1 | Reset |
| `complex_instr` | input | 32 | Complex Instruction |
| `uop_out` | output | 64 | Micro-op output |
| `uop_valid` | output | 1 | Micro-op valid |

---
**`register_alias_table.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rst_n` | input | 1 | Reset |
| `arch_reg` | input | 5 | Architectural Register (0-31) |
| `phys_reg` | output | 7 | Physical Register (0-127) |
| `update_en` | input | 1 | Update Map |
| `recover_en` | input | 1 | Rollback Map |

---
**`freelist_manager.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rst_n` | input | 1 | Reset |
| `pop` | input | 1 | Allocate register |
| `phys_reg_out` | output | 7 | Allocated Physical Register |
| `push` | input | 1 | Free register |
| `phys_reg_in` | input | 7 | Freed Physical Register |

### Block 2 (Batch 17)

**`register_rename_unit.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rs1`, `rs2`, `rd` | input | 5 | Arch Registers |
| `prs1`, `prs2`, `prd` | output | 7 | Physical Registers |
| `stall` | output | 1 | Stall if freelist empty |

---
**`dispatch_unit_4way.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `uop_in` | input | `4 * UOP_WIDTH` | 4 incoming micro-ops |
| `alu_rs_out` | output | `UOP_WIDTH` | To ALU Reservation Station |
| `mem_rs_out` | output | `UOP_WIDTH` | To MEM Reservation Station |
| `rob_alloc` | output | 4 | To ROB |

---
**`issue_queue_manager.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `wakeup_bus` | input | `4 * 7` | Broadcast tags |
| `issue_req` | output | 4 | Issue up to 4 instructions |
| `issue_grant` | input | 4 | Issue grants |

### Block 2 (Batch 18)

**`reservation_station_alu_0.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `alloc_en` | input | 1 | Allocate Entry |
| `uop_in` | input | `UOP_WIDTH` | Micro-op data |
| `wakeup_tags` | input | `4 * 7` | Tags of completing instructions |
| `issue_out` | output | `UOP_WIDTH` | Ready micro-op to ALU 0 |

---
**`reservation_station_alu_1.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `alloc_en` | input | 1 | Allocate Entry |
| `uop_in` | input | `UOP_WIDTH` | Micro-op data |
| `wakeup_tags` | input | `4 * 7` | Tags of completing instructions |
| `issue_out` | output | `UOP_WIDTH` | Ready micro-op to ALU 1 |

---
**`reservation_station_mem.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `alloc_en` | input | 1 | Allocate Entry |
| `uop_in` | input | `UOP_WIDTH` | Load/Store micro-op |
| `issue_out` | output | `UOP_WIDTH` | Ready micro-op to AGU |

### Block 2 (Batch 19)

**`reservation_station_branch.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `alloc_en` | input | 1 | Allocate Entry |
| `uop_in` | input | `UOP_WIDTH` | Branch micro-op |
| `issue_out` | output | `UOP_WIDTH` | Ready micro-op to Branch Unit |

---
**`reorder_buffer_ctrl.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rst_n` | input | 1 | Reset |
| `alloc_req` | input | 4 | Allocate 1 to 4 entries |
| `commit_req` | output | 4 | Commit up to 4 instructions |
| `rob_full` | output | 1 | ROB full flag |

---
**`rob_memory_array.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `wr_en` | input | 4 | 4 Write ports |
| `wr_addr` | input | `4 * $clog2(ROB_SIZE)` | Write addresses |
| `rd_en` | input | 4 | 4 Read ports |
| `rd_addr` | input | `4 * $clog2(ROB_SIZE)` | Read addresses |

### Block 2 (Batch 20)

**`commit_unit.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rob_head_info`| input | `4 * INFO_WIDTH`| Info of oldest instructions |
| `commit_en` | output | 4 | Commit enables |
| `arch_rf_we` | output | 4 | Architectural RF Write Enables |
| `freelist_push_en`| output | 4 | Push stale registers to Freelist |
| `stale_phys_reg` | output | `4 * 7` | Stale Physical Register IDs |

---
**`exception_handler.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `exception_req`| input | 1 | Exception request from ROB |
| `cause` | input | 6 | Exception cause code |
| `flush_pipeline`| output| 1 | Flush signal |
| `trap_pc` | output | 64 | PC to jump to |

---
**`trap_vector_ctrl.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `mtvec` | input | 64 | MTVEC CSR value |
| `cause` | input | 6 | Exception cause code |
| `vector_pc` | output | 64 | Computed Trap Vector PC |

### Block 2 (Batch 21)

**`csr_register_file.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rst_n` | input | 1 | Reset |
| `rd_addr` | input | 12 | CSR Read Address |
| `rd_data` | output | 64 | CSR Read Data |
| `wr_addr` | input | 12 | CSR Write Address |
| `wr_data` | input | 64 | CSR Write Data |
| `wr_en` | input | 1 | CSR Write Enable |

---
**`csr_control_unit.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `uop_csr` | input | `UOP_WIDTH` | CSR Micro-op |
| `csr_rf_we` | output | 1 | Write enable to CSR RF |
| `illegal_access`| output| 1 | Exception on illegal access |

---
**`alu_execution_unit_0.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rs1_data` | input | 64 | Operand 1 |
| `rs2_data` | input | 64 | Operand 2 |
| `opcode` | input | 4 | ALU Operation |
| `result` | output | 64 | ALU Result |
| `valid` | output | 1 | Result Valid |
| `dest_tag` | output | 7 | Destination Physical Reg ID / Tag |

### Block 2 (Batch 22)

**`alu_execution_unit_1.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rs1_data` | input | 64 | Operand 1 |
| `rs2_data` | input | 64 | Operand 2 |
| `opcode` | input | 4 | ALU Operation |
| `result` | output | 64 | ALU Result |
| `valid` | output | 1 | Result Valid |
| `dest_tag` | output | 7 | Destination Physical Reg ID / Tag |

---
**`alu_execution_unit_2.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rs1_data` | input | 64 | Operand 1 |
| `rs2_data` | input | 64 | Operand 2 |
| `opcode` | input | 4 | ALU Operation |
| `result` | output | 64 | ALU Result |
| `valid` | output | 1 | Result Valid |
| `dest_tag` | output | 7 | Destination Physical Reg ID / Tag |

---
**`alu_execution_unit_3.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rs1_data` | input | 64 | Operand 1 |
| `rs2_data` | input | 64 | Operand 2 |
| `opcode` | input | 4 | ALU Operation |
| `result` | output | 64 | ALU Result |
| `valid` | output | 1 | Result Valid |
| `dest_tag` | output | 7 | Destination Physical Reg ID / Tag |

### Block 2 (Batch 23)

**`branch_execution_unit.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rs1_data` | input | 64 | Operand 1 |
| `rs2_data` | input | 64 | Operand 2 |
| `pc` | input | 64 | Current PC |
| `branch_taken`| output | 1 | Actual Outcome |
| `target_pc` | output | 64 | Computed Target PC |
| `dest_tag` | output | 7 | Destination Physical Reg ID / Tag |

---
**`address_gen_unit.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `base_addr` | input | 64 | Base Address Register |
| `offset` | input | 64 | Immediate Offset |
| `eff_addr` | output | 64 | Effective Address (Virtual) |

---
**`mul_div_execution_unit.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rs1_data` | input | 64 | Operand 1 |
| `rs2_data` | input | 64 | Operand 2 |
| `is_div` | input | 1 | 1 for DIV, 0 for MUL |
| `result` | output | 64 | Result |
| `valid` | output | 1 | Valid (Takes multiple cycles) |

### Block 2 (Batch 24)

**`forwarding_network_ctrl.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `alu_results` | input | `4 * 64` | Results from ALUs |
| `mem_result` | input | 64 | Result from Load |
| `fw_rs1_data` | output | `4 * 64` | Forwarded data for RS1 |
| `fw_rs2_data` | output | `4 * 64` | Forwarded data for RS2 |

---
**`load_queue.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `alloc_en` | input | 1 | Allocate Load |
| `address` | input | 64 | Load Address |
| `data_out` | output | 64 | Data returned from Cache |
| `hit_store` | output | 1 | Store-to-Load Forwarding Hit |

---
**`store_queue.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `alloc_en` | input | 1 | Allocate Store |
| `address` | input | 64 | Store Address |
| `data_in` | input | 64 | Store Data |
| `commit_en` | input | 1 | Send to Store Buffer |

### Block 2 (Batch 25)

**`store_buffer.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `push` | input | 1 | Push committed store |
| `address` | input | 64 | Physical Address |
| `data` | input | 64 | Data |
| `dcache_req` | output | 1 | Request to L1 D-Cache |

---
**`memory_disambiguation_unit.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `ld_addr` | input | 64 | Load Address |
| `st_addrs` | input | `SQ_DEPTH * 64`| Addresses in Store Queue |
| `conflict` | output | 1 | Address conflict detected |
| `fwd_data` | output | 64 | Data forwarded from store |

---
**`wakeup_select_logic.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `reqs` | input | 64 | Ready bits in Issue Queue |
| `grants` | output | 4 | Select up to 4 instructions |

### Block 2 (Batch 26)

**`architectural_regfile.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rd_addr` | input | `4 * 5` | 4 Read Ports (Debug/Trap) |
| `rd_data` | output | `4 * 64` | Read Data |
| `wr_addr` | input | `4 * 5` | 4 Write Ports (Commit) |
| `wr_data` | input | `4 * 64` | Write Data |
| `wr_en` | input | 4 | Write Enables |

---
**`physical_regfile.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rd_addr` | input | `8 * 7` | 8 Read Ports (Issue) |
| `rd_data` | output | `8 * 64` | Read Data |
| `wr_addr` | input | `4 * 7` | 4 Write Ports (Execution) |
| `wr_data` | input | `4 * 64` | Write Data |
| `wr_en` | input | 4 | Write Enables |

---
**`core_performance_counters.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `event_instr` | input | 1 | Instruction Committed |
| `event_branch`| input | 1 | Branch executed |
| `event_miss` | input | 1 | Branch mispredict |
| `event_cache` | input | 1 | Cache Miss |
| `read_data` | output | 64 | Counter Value |

### Block 2 (Batch 27)

**`core_debug_module.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `jtag_tck` | input | 1 | JTAG Clock |
| `halt_req` | input | 1 | Halt core execution |
| `resume_req` | input | 1 | Resume execution |
| `core_state` | output | 2 | Current debug state |

---
**`trusted_execution_enclave.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rst_n` | input | 1 | Reset |
| `enclave_mode`| output | 1 | Enclave execution active |
| `mem_addr` | input | 64 | Memory Access Address |
| `access_deny` | output | 1 | Access violation flag |



### Block 3: RVV Vector Subsystem (Batch 28)

**`vector_core_top.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rst_n` | input | 1 | Reset (Active Low) |
| `issue_req` | input | `UOP_WIDTH` | Vector micro-op from Dispatch |
| `issue_valid` | input | 1 | Issue Valid |
| `issue_ready` | output | 1 | Vector Core Ready |
| `mem_req_if` | interface | MEM | Interface to L1 D-Cache/L2 |
| `commit_if` | interface | COMMIT | Interface to ROB Commit Unit |

---
**`vector_dispatch_queue.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rst_n` | input | 1 | Reset |
| `uop_in` | input | `UOP_WIDTH` | Incoming Vector uOp |
| `push` | input | 1 | Push uOp |
| `full` | output | 1 | Queue Full |
| `uop_out` | output | `UOP_WIDTH` | Outgoing Vector uOp |
| `pop` | input | 1 | Pop uOp |
| `empty` | output | 1 | Queue Empty |

---
**`vector_regfile_512b.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rd_addr_1`, `rd_addr_2`, `rd_addr_3`| input | 5 | Read Addresses (3 ports for FMA/Vector) |
| `rd_data_1`, `rd_data_2`, `rd_data_3`| output| 512 | Read Data (512-bit vectors) |
| `wr_addr` | input | 5 | Write Address |
| `wr_data` | input | 512 | Write Data |
| `wr_en` | input | 1 | Write Enable |
| `wr_mask` | input | 64 | Byte-level Write Mask |

### Block 3: RVV Vector Subsystem (Batch 29)

**`vector_mask_regfile.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rd_addr` | input | 5 | Mask Register Address |
| `rd_mask` | output | 64 | 64-bit Mask (1 bit per 8-bit element) |
| `wr_addr` | input | 5 | Write Address |
| `wr_mask` | input | 64 | Write Mask Data |
| `wr_en` | input | 1 | Write Enable |

---
**`vector_lane_0.sv` — Port Specification** (Same for Lanes 1, 2, 3)

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rst_n` | input | 1 | Reset |
| `lane_cmd` | input | 32 | Lane Command/Opcode |
| `src1_128b`, `src2_128b`, `src3_128b`| input | 128 | 128-bit slice of vector operands |
| `mask_16b` | input | 16 | 16-bit slice of mask |
| `result_128b` | output | 128 | 128-bit slice result |
| `valid` | output | 1 | Result Valid |
| `dest_tag` | output | 7 | Destination PRF / ROB Tag |

---
**`vector_alu_int.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `opcode` | input | 8 | Integer Vector ALU Opcode |
| `src1`, `src2`| input | 128 | 128-bit operands |
| `mask` | input | 16 | Execution mask |
| `vsew` | input | 3 | Standard Element Width (8/16/32/64) |
| `result` | output | 128 | Vector result |
| `valid` | output | 1 | Result Valid |
| `dest_tag` | output | 7 | Destination PRF Tag |

### Block 3: RVV Vector Subsystem (Batch 30)

**`vector_alu_fp.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `opcode` | input | 8 | FP Vector Opcode |
| `src1`, `src2`| input | 128 | 128-bit operands |
| `mask` | input | 16 | Execution mask |
| `vsew` | input | 3 | FP Element Width (16/32/64) |
| `result` | output | 128 | FP Vector result |
| `fflags` | output | 5 | Floating point exception flags |
| `valid` | output | 1 | Result Valid |
| `dest_tag` | output | 7 | Destination PRF Tag |

---
**`vector_mac_array.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `src1`, `src2`, `src3`| input | 128 | Operands for FMA/MAC |
| `mask` | input | 16 | Execution mask |
| `vsew` | input | 3 | Element Width |
| `result` | output | 128 | MAC Result |
| `valid` | output | 1 | Result Valid |
| `dest_tag` | output | 7 | Destination PRF Tag |

---
**`vector_reduction_unit.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `src_vector` | input | 512 | Full 512-bit vector for reduction |
| `scalar_in` | input | 64 | Initial scalar value |
| `opcode` | input | 8 | Reduction Opcode (Sum, Max, Min, etc) |
| `scalar_out` | output | 64 | Reduced scalar result |
| `valid` | output | 1 | Valid out |
| `dest_tag` | output | 7 | Destination Tag |

### Block 3: RVV Vector Subsystem (Batch 31)

**`vector_gather_scatter_unit.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `base_addr` | input | 64 | Base memory address |
| `index_vec` | input | 512 | Vector of indices/offsets |
| `data_vec_in` | input | 512 | Vector of data (for Scatter) |
| `mask` | input | 64 | Active element mask |
| `data_vec_out`| output | 512 | Vector of data (for Gather) |
| `mem_req_if` | interface | MEM | AXI/Memory Interface for individual requests |

---
**`vector_load_store_unit.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `base_addr` | input | 64 | Base Address |
| `stride` | input | 64 | Byte stride |
| `vlen` | input | 16 | Vector Length (active elements) |
| `data_vec_in` | input | 512 | Store Data |
| `data_vec_out`| output | 512 | Load Data |
| `mem_req_if` | interface | MEM | Wide cache-line interface (e.g., 256/512b) |
| `dest_tag` | output | 7 | Destination Tag |

---
**`vector_slide_unit.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `src_vector` | input | 512 | Source Vector |
| `slide_amt` | input | 16 | Slide amount (elements) |
| `slide_dir` | input | 1 | Direction (0: up, 1: down) |
| `result` | output | 512 | Slided Vector |
| `valid` | output | 1 | Result Valid |
| `dest_tag` | output | 7 | Destination PRF Tag |

### Block 3: RVV Vector Subsystem (Batch 32)

**`vector_permutation_network.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `src_vector` | input | 512 | Source Vector |
| `index_vector`| input | 512 | Indices for arbitrary permutation |
| `vsew` | input | 3 | Element Width |
| `result` | output | 512 | Permuted Vector |
| `valid` | output | 1 | Result Valid |
| `dest_tag` | output | 7 | Destination PRF Tag |

---
**`vector_mask_logic.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `mask1`, `mask2`| input | 64 | Mask Operands |
| `opcode` | input | 4 | Logic Opcode (AND, OR, XOR, etc) |
| `mask_out` | output | 64 | Mask Result |
| `valid` | output | 1 | Result Valid |
| `dest_tag` | output | 7 | Destination PRF Tag |

---
**`vector_csr_unit.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `vtype` | output | 64 | Vector Type Register |
| `vl` | output | 16 | Vector Length Register |
| `vcsr` | output | 64 | Vector Control & Status Register |
| `csr_we` | input | 1 | Write Enable from Core |
| `csr_wdata` | input | 64 | Write Data from Core |

### Block 3: RVV Vector Subsystem (Batch 33)

**`vector_forwarding_unit.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `lane_results`| input | `4 * 128` | Results from 4 lanes |
| `lane_tags` | input | `4 * 7` | Dest tags from 4 lanes |
| `req_tags` | input | `3 * 7` | Requested Source Tags |
| `fwd_data` | output | `3 * 512` | Forwarded Vector Data (muxed) |

---
**`vector_commit_buffer.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rob_commit` | input | 4 | Commit signals from ROB |
| `commit_tags` | input | `4 * 7` | Tags to commit |
| `vreg_we` | output | 1 | Write Enable to Architectural V-Reg |
| `vreg_wdata` | output | 512 | Data to commit |

---
### Block 4: FPU Subsystem (Batch 34)

**`fpu_top.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rst_n` | input | 1 | Reset |
| `issue_req` | input | `UOP_WIDTH` | FPU Micro-op |
| `issue_valid` | input | 1 | Issue Valid |
| `issue_ready` | output | 1 | FPU Ready to accept |
| `fpu_result` | output | 64 | FP Result |
| `fpu_valid` | output | 1 | Result Valid |
| `dest_tag` | output | 7 | Destination Tag |
| `fflags` | output | 5 | FP Exception Flags |

### Block 4: FPU Subsystem (Batch 35)

**`fpu_issue_queue.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `uop_in` | input | `UOP_WIDTH` | Incoming FPU uOp |
| `push` | input | 1 | Push Enable |
| `wakeup_tags` | input | `4 * 7` | Wakeup Tags from CBD |
| `issue_out` | output | `UOP_WIDTH` | Issued uOp to FPU pipelines |
| `issue_valid` | output | 1 | Issue Valid |

---
**`fpu_regfile.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rd_addr` | input | `3 * 7` | 3 Read Ports (rs1, rs2, rs3 for FMA) |
| `rd_data` | output | `3 * 64` | 3 Read Datas (FP64) |
| `wr_addr` | input | `2 * 7` | 2 Write Ports |
| `wr_data` | input | `2 * 64` | 2 Write Datas |
| `wr_en` | input | 2 | 2 Write Enables |

---
**`fpu_decoder.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `uop_in` | input | `UOP_WIDTH` | Raw FPU uOp |
| `fp_fmt` | output | 2 | Format (S:32, D:64, H:16, Q:128) |
| `rm` | output | 3 | Rounding Mode |
| `is_addsub` | output | 1 | Route to Adder |
| `is_mul` | output | 1 | Route to Multiplier |
| `is_divsqrt` | output | 1 | Route to Div/Sqrt |

### Block 4: FPU Subsystem (Batch 36)

**`fpu_adder_stage1.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `a`, `b` | input | 64 | FP Operands |
| `align_shift` | output | 8 | Mantissa alignment shift |
| `exp_diff` | output | 12 | Exponent difference |
| `larger_exp` | output | 12 | Larger Exponent |

---
**`fpu_adder_stage2.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `mant_a`, `mant_b`| input | 53 | Aligned Mantissas |
| `add_sub` | input | 1 | Operation (0: Add, 1: Sub) |
| `mant_sum` | output | 54 | Mantissa Sum |
| `lzc` | output | 6 | Leading Zero Count |

---
**`fpu_adder_stage3.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `mant_sum` | input | 54 | Mantissa Sum |
| `lzc` | input | 6 | Leading Zero Count |
| `larger_exp` | input | 12 | Original Larger Exponent |
| `result` | output | 64 | Normalized FP64 Result |
| `valid` | output | 1 | Result Valid |
| `dest_tag` | output | 7 | Destination Tag |

### Block 4: FPU Subsystem (Batch 37)

**`fpu_multiplier_stage1.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `a`, `b` | input | 64 | FP Operands |
| `exp_sum` | output | 13 | Exponent Sum |
| `sign_res` | output | 1 | Result Sign |
| `mant_a`, `mant_b`| output | 53 | Extracted Mantissas |

---
**`fpu_multiplier_stage2.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `mant_a`, `mant_b`| input | 53 | Extracted Mantissas |
| `partial_prod`| output | 106 | Wallace Tree partial products |

---
**`fpu_multiplier_stage3.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `partial_prod`| input | 106 | Mantissa Product |
| `exp_sum` | input | 13 | Exponent Sum |
| `result` | output | 64 | Normalized FP64 Result |
| `valid` | output | 1 | Result Valid |
| `dest_tag` | output | 7 | Destination Tag |

### Block 4: FPU Subsystem (Batch 38)

**`fpu_divider_srt_radix4.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `start` | input | 1 | Start Division |
| `a`, `b` | input | 64 | Dividend, Divisor |
| `quotient` | output | 64 | FP64 Quotient |
| `valid` | output | 1 | Valid (Iterative, Multi-cycle) |
| `dest_tag` | output | 7 | Destination Tag |

---
**`fpu_sqrt_unit.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `start` | input | 1 | Start SQRT |
| `a` | input | 64 | Operand |
| `root` | output | 64 | FP64 Square Root |
| `valid` | output | 1 | Valid (Multi-cycle) |
| `dest_tag` | output | 7 | Destination Tag |

---
**`fpu_rounding_unit.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `norm_mant` | input | 55 | Normalized Mantissa with Guard/Round/Sticky |
| `rm` | input | 3 | Rounding Mode |
| `sign` | input | 1 | Result Sign |
| `rounded_mant`| output | 52 | Final Rounded Mantissa |
| `inexact` | output | 1 | Inexact Exception Flag |

### Block 4: FPU Subsystem (Batch 39)

**`fpu_exception_flags.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `nv`, `dz`, `of`, `uf`, `nx` | input | 1 | Invalid, DivZero, Overflow, Underflow, Inexact triggers |
| `fflags_out` | output | 5 | Accumulated FFLAGS |

---
**`fpu_mac_pipeline.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `a`, `b`, `c` | input | 64 | Operands (A * B + C) |
| `result` | output | 64 | FP64 MAC Result |
| `valid` | output | 1 | Valid |
| `dest_tag` | output | 7 | Destination Tag |

---
**`fpu_forwarding_unit.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `fpu_results` | input | `4 * 64` | Results from FPU pipelines |
| `fpu_tags` | input | `4 * 7` | Destination tags from pipelines |
| `req_tags` | input | `3 * 7` | Requested tags by Issue Queue |
| `fwd_data` | output | `3 * 64` | Forwarded FP data |

### Block 4: FPU Subsystem (Batch 40)

**`fpu_commit_unit.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rob_commit_en`| input | 4 | Commit enables from ROB |
| `rob_dest_tags`| input | `4 * 7` | Tags of committing FP instrs |
| `fpu_rf_we` | output | 4 | Write Enables to Arch FP RF |
| `fflags_we` | output | 4 | Write Enables to CSR FFLAGS |
| `fflags_data` | output | `4 * 5` | FFLAGS to commit |
| `freelist_push_en`| output | 4 | Push stale registers to Freelist |
| `stale_phys_reg` | output | `4 * 7` | Stale Physical Register IDs |



### Block 5: Advanced Memory Hierarchy & Coherency (Batch 41)

**`mmu_top.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rst_n` | input | 1 | Reset |
| `vaddr` | input | 64 | Virtual Address |
| `req_type` | input | 2 | Request Type (R/W/X) |
| `paddr` | output | 56 | Physical Address |
| `page_fault` | output | 1 | Page Fault Exception |
| `tlb_hit` | output | 1 | TLB Hit Flag |
| `ptw_req_if` | interface | PTW | Page Table Walker Interface |

---
**`itlb_array.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `vaddr` | input | 64 | Instruction Virtual Address |
| `paddr` | output | 56 | Physical Address |
| `hit` | output | 1 | ITLB Hit |
| `update_en` | input | 1 | Update from JTLB/PTW |
| `update_vaddr`| input | 64 | Update Virtual Address |
| `update_paddr`| input | 56 | Update Physical Address |

---
**`dtlb_array.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `vaddr` | input | 64 | Data Virtual Address |
| `paddr` | output | 56 | Physical Address |
| `hit` | output | 1 | DTLB Hit |
| `update_en` | input | 1 | Update from JTLB/PTW |
| `update_vaddr`| input | 64 | Update Virtual Address |
| `update_paddr`| input | 56 | Update Physical Address |

### Block 5: Advanced Memory Hierarchy & Coherency (Batch 42)

**`jtlb_core.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `vaddr` | input | 64 | Virtual Address (from I/DTLB miss) |
| `paddr` | output | 56 | Physical Address |
| `hit` | output | 1 | Joint TLB Hit |
| `ptw_req` | output | 1 | Request Page Table Walk |
| `update_en` | input | 1 | Update from PTW |

---
**`hardware_page_walker.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `ptw_req` | input | 1 | Walk Request |
| `vaddr` | input | 64 | Virtual Address |
| `satp` | input | 64 | SATP CSR (Base of Page Table) |
| `mem_req_if` | interface | AXI | Memory Interface for PTE fetch |
| `paddr_out` | output | 56 | Translated Physical Address |
| `page_fault` | output | 1 | Page Fault Detected |

---
**`pma_checker.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `paddr` | input | 56 | Physical Address |
| `req_type` | input | 2 | Request Type (Read/Write/Fetch) |
| `is_cacheable`| output | 1 | PMA: Cacheable Region |
| `is_amo_allowed`| output| 1 | PMA: AMO Allowed |
| `access_fault`| output | 1 | PMA: Access Fault |

### Block 5: Advanced Memory Hierarchy & Coherency (Batch 43)

**`pmp_checker.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `paddr` | input | 56 | Physical Address |
| `req_type` | input | 2 | Request Type |
| `priv_mode` | input | 2 | Current Privilege Mode (M/S/U) |
| `pmp_cfg_regs`| input | `16 * 8` | PMP Configuration Registers |
| `pmp_addr_regs`| input| `16 * 64`| PMP Address Registers |
| `access_fault`| output | 1 | PMP Access Violation |

---
**`iommu_core.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `device_id` | input | 16 | PCIe/Device Requester ID |
| `dma_vaddr` | input | 64 | DMA Virtual Address |
| `dma_paddr` | output | 56 | Translated DMA Physical Address |
| `fault` | output | 1 | IOMMU Translation Fault |
| `ptw_req_if` | interface | PTW | Page Table Walker Interface |

---
**`iommu_translation_cache.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `device_id` | input | 16 | Device ID |
| `vaddr` | input | 64 | Virtual Address |
| `paddr` | output | 56 | Physical Address |
| `hit` | output | 1 | ITC Hit |
| `update_en` | input | 1 | Update from IOMMU PTW |

### Block 5: Advanced Memory Hierarchy & Coherency (Batch 44)

**`l1_icache_tags.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `index` | input | 8 | Cache Set Index |
| `tag_in` | input | 42 | Tag to write |
| `tag_out` | output | `4 * 42` | Tags for 4 ways |
| `valid_bits` | output | 4 | Valid bits |
| `wr_en` | input | 4 | Way Write Enables |

---
**`l1_icache_data.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `index` | input | 8 | Cache Set Index |
| `offset` | input | 4 | Cache Line Offset |
| `wr_data` | input | 512 | Cache Line Write Data (from L2) |
| `rd_data` | output | `4 * 512` | Read Data for 4 ways |
| `wr_en` | input | 4 | Way Write Enables |

---
**`l1_icache_ctrl.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `cpu_req_if` | interface | CPU | Interface to Fetch Unit |
| `tag_hit` | input | 4 | Tag comparison hits |
| `l2_req_if` | interface | AXI | Interface to L2 Cache |
| `miss_stall` | output | 1 | Stall Fetch Unit |

### Block 5: Advanced Memory Hierarchy & Coherency (Batch 45)

**`l1_dcache_tags.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `index` | input | 8 | Cache Set Index |
| `tag_out` | output | `8 * 42` | Tags for 8 ways |
| `valid_bits` | output | 8 | Valid bits |
| `dirty_bits` | output | 8 | Dirty bits |
| `snoop_index` | input | 8 | Snoop Index from Coherency |
| `snoop_hit` | output | 1 | Snoop Tag Hit |

---
**`l1_dcache_data.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `index` | input | 8 | Cache Set Index |
| `wr_data` | input | 512 | Line Write Data |
| `byte_mask` | input | 64 | Byte Write Mask for partial stores |
| `rd_data` | output | `8 * 512` | Read Data for 8 ways |
| `wr_en` | input | 8 | Way Write Enables |

---
**`l1_dcache_ctrl.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `cpu_req_if` | interface | CPU | Interface to LSU |
| `l2_req_if` | interface | AXI | Interface to L2 Cache |
| `snoop_if` | interface | SNOOP| Coherency Snoop Interface |
| `amo_alu` | interface | AMO | Atomic Memory Operation ALU |

### Block 5: Advanced Memory Hierarchy & Coherency (Batch 46)

**`stride_prefetcher.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `pc` | input | 64 | PC of Load instruction |
| `addr_miss` | input | 56 | Physical Address of Miss |
| `prefetch_req`| output | 1 | Request Prefetch to L2 |
| `prefetch_addr`| output| 56 | Computed Prefetch Address |

---
**`stream_prefetcher.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `addr_miss` | input | 56 | Address of Miss |
| `stream_hit` | output | 1 | Hit in stream buffers |
| `prefetch_req`| output | 1 | Issue stream prefetch to L2 |
| `prefetch_addr`| output| 56 | Stream Address |

---
**`l2_cache_tags.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `index` | input | 12 | L2 Set Index |
| `tag_out` | output | `16 * 40`| Tags for 16 ways |
| `mesi_state` | output | `16 * 2` | MESI Coherency State |
| `wr_en` | input | 16 | Way Write Enables |

### Block 5: Advanced Memory Hierarchy & Coherency (Batch 47)

**`l2_cache_data_banks.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `bank_sel` | input | 2 | Bank Select |
| `index` | input | 12 | Set Index |
| `wr_data` | input | 512 | Line Data |
| `rd_data` | output | `16 * 512`| Read Data |

---
**`l2_cache_ctrl_multicore.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `l1_req_if` | interface | AXI | Requests from Core L1s (Array) |
| `l3_req_if` | interface | AXI | Requests to L3 Cache |
| `coherency_if`| interface | MESI | Multi-core coherency bus |
| `evict_req` | output | 1 | Evict line to L3 |

---
**`l3_cache_tags.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `index` | input | 14 | L3 Set Index |
| `tag_out` | output | `16 * 38`| Tags for 16 ways |
| `mesi_state` | output | `16 * 2` | Coherency State |

### Block 5: Advanced Memory Hierarchy & Coherency (Batch 48)

**`l3_cache_data_banks.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `slice_sel` | input | 4 | 16 Distributed Slices |
| `wr_data` | input | 512 | Line Data |
| `rd_data` | output | 512 | Read Data from selected slice |

---
**`l3_cache_ctrl_unified.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `l2_req_if` | interface | AXI | Requests from L2 Caches |
| `ddr_req_if` | interface | AXI | Requests to DDR Memory Controller |
| `snoop_filter`| interface | SNOOP| Interface to Directory/Snoop Filter |

---
**`mesi_coherency_directory.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `paddr` | input | 56 | Physical Address |
| `dir_vector` | output | 4 | Presence vector (which cores have it) |
| `dir_state` | output | 2 | MESI state at directory level |
| `update_en` | input | 1 | Update Directory Entry |

### Block 5: Advanced Memory Hierarchy & Coherency (Batch 49)

**`snoop_filter_unit.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `l2_miss_addr`| input | 56 | Miss Address from L2 |
| `snoop_req` | output | 4 | Broadcast snoop to specific L2s |
| `snoop_resp` | input | `4 * 2` | Responses from L2s (Hit/Miss/Dirty) |

---
**`coherency_bus_interface.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `req_in` | input | `NUM_MASTERS * REQ`| Requests from multiple masters |
| `grant_out` | output | `NUM_MASTERS` | Arbitration grants |
| `snoop_bus` | output | SNOOP | Broadcast Snoops |

---
**`cache_eviction_manager.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `evict_paddr` | input | 56 | Address to evict |
| `evict_data` | input | 512 | Data to evict (writeback) |
| `mem_wr_req` | output | 1 | Request memory write |

### Block 5: Advanced Memory Hierarchy & Coherency (Batch 50)

**`memory_arbiter_core.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `l3_req` | input | 1 | Request from L3 Cache |
| `dma_req` | input | 1 | Request from PCIe/DMA |
| `npu_req` | input | 1 | Request from NPU |
| `gpu_req` | input | 1 | Request from GPU |
| `mem_grant` | output | 4 | Grants to Requesters |

---
**`hardware_memory_scrubber.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `en` | input | 1 | Enable Background Scrubbing |
| `scrub_addr` | output | 56 | Generated Scrub Address |
| `ecc_err` | input | 1 | ECC Error Detected (from Memory) |
| `correct_req` | output | 1 | Issue Writeback Correction |

---
**`memory_encryption_engine.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `paddr` | input | 56 | Physical Address (used as Tweak) |
| `plaintext` | input | 512 | Plaintext from Cache |
| `ciphertext` | output | 512 | Ciphertext to DDR |
| `aes_key` | input | 256 | AES-XTS Encryption Key |



### Block 6: NPU Subsystem (Batch 51)

**`npu_top.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | NPU Clock |
| `rst_n` | input | 1 | NPU Reset |
| `axi_host_if` | interface | AXI-Lite | Host CPU configuration interface |
| `axi_mem_if` | interface | AXI4 | High bandwidth DMA interface to NoC/Memory |
| `irq` | output | 1 | Interrupt to Host CPU |

---
**`npu_host_interface.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `axi_lite_if` | interface | AXI-Lite | AXI4-Lite Slave from CPU |
| `cmd_reg` | output | 32 | NPU Command Register |
| `status_reg` | input | 32 | NPU Status Register |
| `irq` | output | 1 | Interrupt trigger |

---
**`npu_instruction_decoder.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `instr_in` | input | 128 | 128-bit NPU VLIW Instruction |
| `sys_op` | output | 4 | Systolic Array Opcode |
| `vpu_op` | output | 4 | Vector Processing Unit Opcode |
| `dma_op` | output | 4 | DMA Opcode |

### Block 6: NPU Subsystem (Batch 52)

**`npu_issue_queue.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `push` | input | 1 | Push Decoded Instruction |
| `sys_op_in`, `vpu_op_in`| input | 4 | Opcodes |
| `sys_ready`, `vpu_ready`| input | 1 | Engine ready signals |
| `sys_op_out`, `vpu_op_out`| output| 4 | Issued Opcodes |

---
**`mac_cell_int4_int8.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `act_in` | input | 8 | Activation (INT8/INT4) |
| `wgt_in` | input | 8 | Weight (INT8/INT4) |
| `psum_in` | input | 32 | Partial Sum In |
| `act_out` | output | 8 | Activation Out (Systolic forwarding) |
| `psum_out` | output | 32 | Partial Sum Out |

---
**`mac_cell_bf16_fp32.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `act_in` | input | 16 | Activation (BF16) |
| `wgt_in` | input | 16 | Weight (BF16) |
| `psum_in` | input | 32 | Partial Sum In (FP32) |
| `act_out` | output | 16 | Activation Out |
| `psum_out` | output | 32 | Partial Sum Out (FP32) |

### Block 6: NPU Subsystem (Batch 53)

**`npu_systolic_array_128x128.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `en` | input | 1 | Enable Computation |
| `act_in_bus` | input | `128 * 8`| 128 Activations (INT8) per cycle |
| `wgt_in_bus` | input | `128 * 8`| 128 Weights (INT8) per cycle |
| `psum_in_bus` | input | `128 * 32`| 128 Partial Sums |
| `psum_out_bus`| output | `128 * 32`| 128 Resulting Partial Sums |

---
**`sparsity_decoder_unit.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `sparse_data` | input | 512 | Compressed Sparse Row (CSR) format |
| `bitmap` | input | 64 | Non-zero bitmap |
| `dense_data` | output | 512 | Decompressed dense vector |

---
**`zero_skipping_logic.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `act_vector` | input | 512 | Activation Vector |
| `is_zero` | output | 64 | Flag per 8-bit element |
| `skip_cycles` | output | 4 | Cycles saved by skipping rows |

### Block 6: NPU Subsystem (Batch 54)

**`weight_compression_decoder.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `encoded_wgt` | input | 256 | Huffman/RLE encoded weights |
| `decoded_wgt` | output | 512 | Expanded weights |
| `valid` | output | 1 | Valid output |

---
**`vector_processing_unit.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `opcode` | input | 4 | VPU Operation |
| `vec_in_a`, `b` | input | 512 | Vector operands |
| `vec_out` | output | 512 | Vector result |

---
**`relu_activation_unit.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `vec_in` | input | 512 | INT32 / FP32 Vector |
| `vec_out` | output | 512 | ReLU (max(0, x)) applied |

### Block 6: NPU Subsystem (Batch 55)

**`sigmoid_activation_unit.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `vec_in` | input | 512 | Input Vector |
| `vec_out` | output | 512 | Sigmoid (LUT/Taylor-based) output |

---
**`tanh_activation_unit.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `vec_in` | input | 512 | Input Vector |
| `vec_out` | output | 512 | Tanh output |

---
**`gelu_activation_unit.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `vec_in` | input | 512 | Input Vector |
| `vec_out` | output | 512 | GELU output |

### Block 6: NPU Subsystem (Batch 56)

**`softmax_exp_unit.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `vec_in` | input | 512 | Input Vector |
| `max_val` | input | 32 | Max value for numerical stability |
| `exp_out` | output | 512 | Exponentiated Vector |

---
**`layer_norm_engine.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `vec_in` | input | 512 | Input Vector |
| `mean` | output | 32 | Calculated Mean |
| `variance` | output | 32 | Calculated Variance |
| `vec_out` | output | 512 | Normalized Vector |

---
**`batch_norm_engine.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `vec_in` | input | 512 | Input Vector |
| `running_mean`| input | 32 | Learned Mean |
| `running_var` | input | 32 | Learned Variance |
| `vec_out` | output | 512 | Normalized Vector |

### Block 6: NPU Subsystem (Batch 57)

**`max_pool_engine.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `window_in` | input | `WINDOW_SZ * 32` | Pooling Window Data |
| `max_val` | output | 32 | Maximum Value |

---
**`avg_pool_engine.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `window_in` | input | `WINDOW_SZ * 32` | Pooling Window Data |
| `avg_val` | output | 32 | Average Value |

---
**`tensor_reshape_unit.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `tensor_in` | input | 512 | Input Data |
| `shape_cfg` | input | 32 | Shape configuration (e.g., NCHW to NHWC) |
| `tensor_out` | output | 512 | Reshaped Data |

### Block 6: NPU Subsystem (Batch 58)

**`tensor_transpose_unit.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `matrix_in` | input | `16 * 16 * 8`| 16x16 INT8 Matrix |
| `matrix_out` | output | `16 * 16 * 8`| Transposed Matrix |

---
**`weight_scratchpad_bank_0.sv` / `bank_1.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `addr` | input | 16 | SRAM Address |
| `wdata` | input | 512 | DMA Write Data |
| `we` | input | 1 | DMA Write Enable |
| `rdata` | output | 512 | NPU Read Data |

---
**`weight_scratchpad_ctrl.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `dma_req` | input | 1 | DMA Write Request |
| `sys_req` | input | 1 | Systolic Array Read Request |
| `bank_sel` | output | 1 | Ping-pong bank select |

### Block 6: NPU Subsystem (Batch 59)

**`activation_scratchpad_bank_0.sv` / `bank_1.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `addr` | input | 16 | SRAM Address |
| `wdata` | input | 512 | DMA / VPU Write Data |
| `rdata` | output | 512 | Systolic Array Read Data |

---
**`activation_scratchpad_ctrl.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `dma_req` | input | 1 | DMA Write Request |
| `sys_req` | input | 1 | Systolic Array Read Request |
| `bank_sel` | output | 1 | Double buffering control |

---
**`psum_accumulation_buffer.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `addr` | input | 14 | Buffer Address |
| `psum_in` | input | `128 * 32` | Systolic Array Output |
| `accum_en` | input | 1 | Enable accumulation (read-modify-write) |
| `psum_out` | output | `128 * 32` | Accumulated Result |

### Block 6: NPU Subsystem (Batch 60)

**`psum_scratchpad_ctrl.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `sys_done` | input | 1 | Systolic Array chunk finished |
| `dma_read_req`| input | 1 | DMA requesting writeback |

---
**`npu_dma_read_channel_0.sv` / `channel_1.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `src_addr` | input | 64 | Memory Address |
| `xfer_size` | input | 32 | Transfer Size |
| `axi_ar_if` | interface | AXI AR | AXI Read Address Channel |
| `axi_r_if` | interface | AXI R | AXI Read Data Channel |
| `sram_wdata` | output | 512 | Data to Scratchpad |

---
**`npu_dma_write_channel.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `dst_addr` | input | 64 | Memory Address |
| `sram_rdata` | input | 512 | Data from Psum Buffer/VPU |
| `axi_aw_if` | interface | AXI AW | AXI Write Address Channel |
| `axi_w_if` | interface | AXI W | AXI Write Data Channel |

### Block 6: NPU Subsystem (Batch 61)

**`npu_dma_arbiter.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rd0_req`, `rd1_req`, `wr_req` | input | 1 | DMA Channel Requests |
| `axi_m_if` | interface | AXI4 | Single multiplexed AXI master interface |

---
**`npu_axi_burst_controller.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `xfer_len` | input | 32 | Total bytes |
| `burst_len` | output | 8 | AXI AWLEN/ARLEN |
| `next_burst` | output | 1 | Trigger next 4KB boundary burst |

---
**`npu_power_management.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `idle_time` | input | 32 | Clock cycles NPU has been idle |
| `power_gate` | output | 1 | Power gate Systolic Array |
| `clock_gate` | output | 1 | Clock gate VPU |

### Block 6: NPU Subsystem (Batch 62)

**`npu_performance_monitor.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `mac_ops` | input | 1 | MAC operation active |
| `dma_stall` | input | 1 | DMA waiting for memory |
| `perf_cnt` | output | 64 | Software-readable performance counter |

---
**`npu_interrupt_ctrl.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `dma_done` | input | 1 | DMA Transfer Complete |
| `sys_done` | input | 1 | Task Complete |
| `error_flag` | input | 1 | Page Fault / AXI Error |
| `irq_out` | output | 1 | Interrupt to Host CPU PLIC |

---
**`npu_debug_trace_unit.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `state_vector`| input | 128 | Internal State Machines |
| `trace_out` | output | 64 | JTAG Trace Output |

### Block 6: NPU Subsystem (Batch 63)

**`npu_clock_gating_ctrl.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk_in` | input | 1 | Free-running clock |
| `sys_active` | input | 1 | Systolic array active flag |
| `vpu_active` | input | 1 | VPU active flag |
| `sys_clk` | output | 1 | Gated clock for Systolic |
| `vpu_clk` | output | 1 | Gated clock for VPU |



### Block 7: GPU Subsystem (Batch 64)

**`gpu_top.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | GPU Core Clock |
| `rst_n` | input | 1 | GPU Reset |
| `axi_lite_if` | interface | AXI-Lite | Host configuration / command interface |
| `axi_mem_if` | interface | AXI4 | GPU to GDDR/System Memory |
| `hdmi_tx_p/n` | output | 4 | HDMI TDMS lanes |
| `irq` | output | 1 | Interrupt to CPU |

---
**`gpu_host_bridge.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `axi_lite_if` | interface | AXI-Lite | Interface from CPU |
| `cmd_fifo_wr` | output | 1 | Write to Command Streamer |
| `cmd_data` | output | 256 | Command Packet |
| `gpu_status` | input | 32 | Status to read |

---
**`gpu_command_streamer.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `cmd_in` | input | 256 | Command from Host Bridge |
| `push` | input | 1 | Command push |
| `geom_cmd` | output | 128 | Geometry Pipeline command |
| `comp_cmd` | output | 128 | Compute Pipeline command |

### Block 7: GPU Subsystem (Batch 65)

**`geometry_dispatch_unit.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `vertex_stream` | input | 512 | Vertex Data from Memory |
| `hull_req` | output | 1 | Dispatch to Hull Shader |
| `domain_req` | output | 1 | Dispatch to Domain Shader |
| `geom_req` | output | 1 | Dispatch to Geometry Shader |

---
**`hull_shader_engine.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `patch_in` | input | 512 | Control Points |
| `tess_factors`| output | 128 | Tessellation factors |
| `patch_out` | output | 512 | Processed Control Points |

---
**`tessellation_primitive_gen.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `tess_factors`| input | 128 | From Hull Shader |
| `topology` | input | 2 | Quad, Tri, Line |
| `uvw_coords` | output | 96 | Generated Barycentric coords |
| `prim_valid` | output | 1 | Primitive Valid |

### Block 7: GPU Subsystem (Batch 66)

**`domain_shader_engine.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `patch_in` | input | 512 | Control Points |
| `uvw_coords` | input | 96 | Barycentric Coords |
| `vertex_out` | output | 256 | Evaluated Vertex Data |

---
**`geometry_shader_engine.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `prim_in` | input | 768 | Input Primitive (e.g., 3 Vertices) |
| `prim_out` | output | 768 | Output Primitive (Vertex stream) |
| `emit_vertex` | output | 1 | Vertex Emit Flag |

---
**`hierarchical_z_cull_unit.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `bounding_box`| input | 128 | Tile bounding box |
| `z_max` | input | 32 | Tile Z-Max |
| `hz_cache_rd` | output | 32 | Depth from HZ Cache |
| `cull_tile` | output | 1 | 1 if tile is fully occluded |

### Block 7: GPU Subsystem (Batch 67)

**`edge_equation_evaluator.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `v0, v1, v2` | input | 96 | Screen space X,Y coordinates |
| `a, b, c` | output | `3 * 32` | Edge Equation Coefficients |
| `valid` | output | 1 | Coefficients Valid |

---
**`tile_traversal_unit.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `bounding_box`| input | 128 | Primitive bounding box |
| `tile_x, y` | output | 32 | Current evaluating tile (8x8 pixels) |
| `valid` | output | 1 | Tile valid |

---
**`gpu_rasterizer_core.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `tile_coords` | input | 32 | Tile X, Y |
| `edge_coeffs` | input | 96 | A, B, C |
| `pixel_mask` | output | 64 | 8x8 Pixel Coverage Mask |
| `barycentrics`| output | `64 * 64`| Barycentric coordinates for covered pixels |

### Block 7: GPU Subsystem (Batch 68)

**`shader_dispatch_controller.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `pixel_mask` | input | 64 | Covered Pixels |
| `core_busy` | input | 4 | Busy status of 4 shader cores |
| `assign_core` | output | 2 | Selected Core (0-3) |
| `dispatch_en` | output | 4 | Dispatch enable for cores |

---
**`gpu_unified_shader_core_0.sv` (to 3) — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `thread_id` | input | 10 | Warp/Wavefront ID |
| `instr_cache` | interface | AXI | Instruction Fetch Interface |
| `tex_req` | output | 1 | Texture Fetch Request |
| `alu_req` | output | 1 | Issue to Vector/Scalar ALU |
| `color_out` | output | 128 | Final pixel color (RGBA32) |

---
**`shader_vector_alu.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `opcode` | input | 8 | Vector Opcode (FMAD, DP4) |
| `src1, src2` | input | 128 | 4x FP32 |
| `result` | output | 128 | 4x FP32 |
| `valid` | output | 1 | Result Valid |

### Block 7: GPU Subsystem (Batch 69)

**`shader_scalar_alu.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `opcode` | input | 8 | Scalar Opcode |
| `src1, src2` | input | 32 | FP32 |
| `result` | output | 32 | FP32 |

---
**`shader_register_file.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `warp_id` | input | 6 | Warp Context ID |
| `rd_addr` | input | `3 * 8` | 3 Read Ports |
| `rd_data` | output | `3 * 128` | 128-bit Vector Registers |
| `wr_addr` | input | `2 * 8` | 2 Write Ports |
| `wr_data` | input | `2 * 128` | Write Data |
| `wr_en` | input | 2 | Write Enable |

---
**`compute_shader_manager.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `workgroup_sz`| input | 32 | Dimensions of thread group |
| `barrier_req` | input | 64 | Barrier synchronization per thread |
| `barrier_done`| output | 1 | All threads reached barrier |

### Block 7: GPU Subsystem (Batch 70)

**`texture_address_generator.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `u, v` | input | 32 | Normalized Texture Coords (FP32) |
| `tex_width` | input | 16 | Texture Width |
| `tex_height` | input | 16 | Texture Height |
| `texel_addr` | output | `4 * 32` | Addresses of 4 nearest texels |

---
**`texture_l1_cache.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `req_addr` | input | `4 * 32` | 4 Texel Addresses |
| `texel_data` | output | `4 * 32` | 4 Texel Colors (RGBA8) |
| `hit` | output | 4 | Cache Hits |
| `l2_req_if` | interface | AXI | Interface to Texture L2 |

---
**`texture_l2_cache.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `l1_req_if` | interface | AXI | Interface from L1s |
| `mem_req_if` | interface | AXI | Interface to VRAM/System Memory |
| `evict_req` | output | 1 | Read-only cache, just drops line |

### Block 7: GPU Subsystem (Batch 71)

**`texture_decompression_unit.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `block_in` | input | 64 | BC1/DXT1 Compressed Block |
| `texel_out` | output | `16 * 32` | 16 Decompressed Texels (RGBA8) |

---
**`bilinear_filter_unit.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `texels_in` | input | `4 * 32` | 4 Nearest Texels |
| `frac_u, v` | input | 8 | Fractional coordinates |
| `filtered_out`| output | 32 | Bilinear Filtered Color |

---
**`trilinear_filter_unit.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `mipmap1_in` | input | 32 | Bilinear sample from LOD n |
| `mipmap2_in` | input | 32 | Bilinear sample from LOD n+1 |
| `frac_lod` | input | 8 | Fractional LOD |
| `filtered_out`| output | 32 | Trilinear Filtered Color |

### Block 7: GPU Subsystem (Batch 72)

**`anisotropic_filter_unit.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `samples_in` | input | `16 * 32` | Multi-tap samples along line of anisotropy |
| `weights` | input | `16 * 8` | Filter weights |
| `filtered_out`| output | 32 | Anisotropic Filtered Color |

---
**`depth_stencil_test_unit.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `frag_z` | input | 32 | Fragment Z (Depth) |
| `fb_z` | input | 32 | Framebuffer Z |
| `z_func` | input | 3 | Depth Test Function (Less, Equal, etc) |
| `test_pass` | output | 1 | 1 if Fragment passes depth test |

---
**`alpha_blend_unit.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `src_color` | input | 32 | Fragment Shader Color (RGBA8) |
| `dst_color` | input | 32 | Framebuffer Color (RGBA8) |
| `blend_eq` | input | 4 | Blend Equation |
| `final_color` | output | 32 | Blended Color |

### Block 7: GPU Subsystem (Batch 73)

**`color_format_converter.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `color_in` | input | 128 | Internal FP32 format |
| `format` | input | 4 | RGB565, RGBA8, FP16 |
| `color_out` | output | 32 | Converted format |

---
**`gpu_rop_pipeline.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `frag_color` | input | 32 | Color from Shader |
| `frag_z` | input | 32 | Depth |
| `fb_cache_if` | interface | AXI | Read/Write to Framebuffer Cache |
| `pixel_done` | output | 1 | ROP operation complete |

---
**`framebuffer_cache_ctrl.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rop_req_if` | interface | AXI | From ROP |
| `disp_req_if` | interface | AXI | From Display Controller |
| `mem_if` | interface | AXI | To VRAM |
| `flush_req` | input | 1 | Flush on swapchain present |

### Block 7: GPU Subsystem (Batch 74)

**`vga_timing_generator.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `pixel_clk` | input | 1 | Pixel Clock |
| `hsync` | output | 1 | Horizontal Sync |
| `vsync` | output | 1 | Vertical Sync |
| `de` | output | 1 | Data Enable (Active Pixels) |
| `x_coord` | output | 16 | X Coordinate |
| `y_coord` | output | 16 | Y Coordinate |

---
**`hdmi_output_formatter.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `pixel_clk` | input | 1 | Pixel Clock |
| `tmds_clk_5x` | input | 1 | 5x Pixel Clock for Serializer |
| `rgb_in` | input | 24 | RGB888 Pixel Data |
| `hsync, vsync`| input | 1 | Sync signals |
| `hdmi_tx_p/n` | output | 4 | TMDS diff pairs (Clock, D0, D1, D2) |

---
**`gpu_dma_read_engine.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `src_addr` | input | 64 | Host Memory Address |
| `axi_ar_if` | interface | AXI AR | Read Address |
| `axi_r_if` | interface | AXI R | Read Data |
| `fifo_wdata` | output | 256 | Data to GPU FIFO |

### Block 7: GPU Subsystem (Batch 75)

**`gpu_dma_write_engine.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `dst_addr` | input | 64 | Host Memory Address |
| `fifo_rdata` | input | 256 | Data from GPU FIFO |
| `axi_aw_if` | interface | AXI AW | Write Address |
| `axi_w_if` | interface | AXI W | Write Data |

---
**`gpu_axi_burst_ctrl.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `xfer_size` | input | 32 | Transfer Size |
| `burst_len` | output | 8 | AXI Burst Length |
| `align_addr` | output | 64 | 4KB Aligned boundary address |

---
**`gpu_mmu_translation.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `gpu_vaddr` | input | 64 | GPU Virtual Address (from shaders/dma) |
| `gpu_paddr` | output | 56 | Physical Address (VRAM or System) |
| `ptw_req_if` | interface | PTW | Page Table Walk Request to IOMMU |
| `page_fault` | output | 1 | Fault flag |

### Block 7: GPU Subsystem (Batch 76)

**`gpu_context_switch_mgr.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `preempt_req` | input | 1 | Preemption request from Host |
| `save_state` | output | 1 | Trigger save of shader RFs to Memory |
| `restore_state`| output| 1 | Trigger restore from Memory |
| `done` | output | 1 | Context Switch Complete |

---
**`gpu_interrupt_handler.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `cmd_done` | input | 1 | Command Buffer empty |
| `page_fault` | input | 1 | GPU MMU Page Fault |
| `vsync_event` | input | 1 | VSync occurred |
| `irq_out` | output | 1 | Interrupt to Host PLIC |

---
**`gpu_power_gating_ctrl.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `shader_idle` | input | 4 | Idle signals from 4 Shader Cores |
| `pg_enable` | output | 4 | Power Gate signals for Shader Cores |
| `cg_enable` | output | 1 | Clock Gate for Texture Caches |

### Block 8: Hardware Video/Media Codec Subsystem (Batch 77)

**`video_codec_top.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Video Clock |
| `rst_n` | input | 1 | Reset |
| `axi_lite_if` | interface | AXI-Lite | CPU Config Interface |
| `axi_mem_if` | interface | AXI4 | High bandwidth Memory Interface |
| `irq` | output | 1 | Interrupt |

---
**`av1_decoder_core.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `bitstream_in`| input | 128 | AV1 Bitstream FIFO |
| `pixel_out` | output | 32 | Decoded Pixels (YUV420) |
| `frame_done` | output | 1 | Frame Decode Complete |

---
**`hevc_h265_encoder.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `pixel_in` | input | 32 | Raw Pixels (YUV420) |
| `bitstream_out`| output| 128 | HEVC Bitstream FIFO |
| `frame_done` | output | 1 | Frame Encode Complete |

### Block 8: Hardware Video/Media Codec Subsystem (Batch 78)

**`motion_estimation_engine.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `curr_block` | input | `16*16*8`| Current Macroblock |
| `ref_window` | input | `32*32*8`| Reference Frame Window |
| `mv_x, mv_y` | output | 8 | Motion Vector |
| `sad_val` | output | 16 | Sum of Absolute Differences |

---
**`entropy_decoder_cabac.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `stream_in` | input | 32 | Bitstream chunk |
| `ctx_state` | input | 16 | CABAC Context State |
| `sym_out` | output | 16 | Decoded Symbol |
| `ctx_update` | output | 16 | Updated Context State |

---
**`inverse_transform_unit.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `coeffs_in` | input | `16*16` | Quantized DCT coefficients |
| `pixels_out` | output | `16*8` | Residual Pixels |

### Block 8: Hardware Video/Media Codec Subsystem (Batch 79)

**`deblocking_filter.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `edge_pixels` | input | 64 | Pixels across macroblock edge |
| `filter_str` | input | 4 | Boundary strength |
| `filtered_px` | output | 64 | Smoothed pixels |

---
**`video_dma_engine.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `y_addr, u_addr, v_addr` | input | 64 | YUV Plane Addresses |
| `stride` | input | 16 | Frame stride |
| `axi_mem_if` | interface | AXI4 | Memory Interface |

---
**`display_processor_2d.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `yuv_in` | input | 24 | YUV420 from Decoder |
| `rgb_out` | output | 24 | RGB888 to HDMI/GPU |
| `scaler_cfg` | input | 16 | Up/Down scaler ratio |



### Block 9: Network-on-Chip (NoC) & Interconnect (Batch 80)

**`noc_mesh_router_core.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rst_n` | input | 1 | Reset |
| `flit_in` | input | `5 * 128` | Incoming Flits from 5 ports (N,S,E,W,Local) |
| `credit_out` | output | `5 * 4` | Credits to 5 ports |
| `flit_out` | output | `5 * 128` | Outgoing Flits to 5 ports |
| `credit_in` | input | `5 * 4` | Credits from 5 ports |

---
**`noc_network_interface_cpu.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `axi_req_if` | interface | AXI4 | AXI Request from CPU |
| `flit_out` | output | 128 | Converted Request Flit to Router |
| `flit_in` | input | 128 | Response Flit from Router |
| `axi_resp_if` | interface | AXI4 | AXI Response to CPU |

---
**`noc_network_interface_npu.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `axi_req_if` | interface | AXI4 | AXI Request from NPU |
| `flit_out` | output | 128 | Flit to Router |
| `flit_in` | input | 128 | Flit from Router |
| `axi_resp_if` | interface | AXI4 | AXI Response to NPU |

### Block 9: Network-on-Chip (NoC) & Interconnect (Batch 81)

**`noc_network_interface_gpu.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `axi_req_if` | interface | AXI4 | AXI Request from GPU |
| `flit_out` | output | 128 | Flit to Router |
| `flit_in` | input | 128 | Flit from Router |
| `axi_resp_if` | interface | AXI4 | AXI Response to GPU |

---
**`noc_network_interface_mem.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `flit_in` | input | 128 | Flit from Router |
| `axi_req_if` | interface | AXI4 | AXI Request to Memory Controller |
| `axi_resp_if` | interface | AXI4 | AXI Response from Memory Controller |
| `flit_out` | output | 128 | Flit to Router |

---
**`virtual_channel_allocator.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `req_in` | input | `5 * 4` | Requests from 5 ports * 4 VCs |
| `dest_port` | input | `5 * 4 * 3`| Destination port for each request |
| `grant_out` | output | `5 * 4` | Grants to input VCs |

### Block 9: Network-on-Chip (NoC) & Interconnect (Batch 82)

**`switch_allocator_arbiter.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `vc_grant` | input | `5 * 4` | Virtual Channel Grants |
| `switch_req` | input | `5 * 4` | Requests for switch traversal |
| `switch_grant`| output | `5 * 4` | Grants for crossbar traversal |

---
**`noc_credit_manager.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `flit_depart` | input | 1 | Flit leaves router |
| `vc_idx` | input | 2 | VC index of departing flit |
| `credit_in` | input | 1 | Credit received from downstream |
| `credit_cnt` | output | 4 | Current credit count for VC |

---
**`axi4_to_noc_bridge.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `axi_if` | interface | AXI4 | AXI Master/Slave |
| `noc_tx` | output | 128 | Flit TX |
| `noc_rx` | input | 128 | Flit RX |

### Block 9: Network-on-Chip (NoC) & Interconnect (Batch 83)

**`noc_to_axi4_bridge.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `noc_rx` | input | 128 | Flit RX |
| `axi_if` | interface | AXI4 | AXI Master/Slave |
| `noc_tx` | output | 128 | Flit TX |

---
**`axi4_crossbar_lite.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `s_axi_if` | interface | `S_COUNT * AXI` | M AXI-Lite Slave Interfaces |
| `m_axi_if` | interface | `M_COUNT * AXI` | S AXI-Lite Master Interfaces |
| `addr_map` | input | `S * 64`| Address decode map |

---
**`axi4_master_bfm.sv` / `axi4_slave_bfm.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `axi_if` | interface | AXI4 | Simulation Interface |
| `sim_cmd` | input | 32 | Verification Command from TB |

---
**`axi2apb_bridge_core.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `axi_if` | interface | AXI-Lite | AXI Slave |
| `apb_if` | interface | APB | APB Master |

### Block 10: SoC, I/O, & Advanced Peripherals (Batch 84)

**`pcie_gen4_root_complex.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `pcie_tx_p/n` | output | 16 | 16-lane PCIe Gen4 TX |
| `pcie_rx_p/n` | input | 16 | 16-lane PCIe Gen4 RX |
| `axi_if` | interface | AXI4 | AXI Interface to SoC |

---
**`pcie_axi_bridge.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `pcie_tlp_rx` | input | 256 | TLP from PCIe |
| `pcie_tlp_tx` | output | 256 | TLP to PCIe |
| `axi_if` | interface | AXI4 | AXI Interface |

---
**`ddr4_phy_interface.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | PHY Clock |
| `dfi_if` | interface | DFI | Interface to DDR4 Controller |
| `ddr4_dq` | inout | 64 | Data pins |
| `ddr4_dqs` | inout | 8 | Data Strobe |
| `ddr4_ck` | output | 1 | Diff Clock |

### Block 10: SoC, I/O, & Advanced Peripherals (Batch 85)

**`ddr4_memory_controller.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Controller Clock |
| `axi_if` | interface | AXI4 | AXI from L3 / Interconnect |
| `dfi_if` | interface | DFI | DFI to PHY |

---
**`scatter_gather_dma_engine.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `axi_if` | interface | AXI4 | DMA Memory Access |
| `desc_addr` | input | 64 | Start of Descriptor Chain |
| `irq` | output | 1 | DMA Complete / Error |

---
**`dma_descriptor_fetcher.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `axi_ar_if` | interface | AXI AR | Address Fetch |
| `axi_r_if` | interface | AXI R | Descriptor Data Fetch |
| `next_desc` | output | 64 | Pointer to next descriptor |

### Block 10: SoC, I/O, & Advanced Peripherals (Batch 86)

**`hardware_crypto_aes.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `key` | input | 256 | AES-256 Key |
| `data_in` | input | 128 | Plaintext/Ciphertext block |
| `mode` | input | 2 | Encrypt/Decrypt, ECB/CBC |
| `data_out` | output | 128 | Result block |

---
**`hardware_crypto_sha256.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `msg_in` | input | 512 | Message Block |
| `hash_out` | output | 256 | Current Hash State |
| `valid` | output | 1 | Valid Hash |

---
**`plic_core_interrupt_ctrl.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `global_irqs` | input | 256 | Interrupt Sources from SoC |
| `ext_irq_cpu` | output | 4 | MEIP to 4 CPU Cores |
| `axi_lite_if` | interface | AXI-Lite | MMIO for config |

### Block 10: SoC, I/O, & Advanced Peripherals (Batch 87)

**`clint_core_timer.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rtc_tick` | input | 1 | 32.768 kHz RTC tick |
| `timer_irq` | output | 4 | MTIP to 4 CPU Cores |
| `soft_irq` | output | 4 | MSIP to 4 CPU Cores |
| `axi_lite_if` | interface | AXI-Lite | MMIO |

---
**`apb_uart_fifo.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `pclk` | input | 1 | APB Clock |
| `apb_if` | interface | APB | APB Slave Interface |
| `tx` | output | 1 | UART Transmit |
| `rx` | input | 1 | UART Receive |

---
**`apb_qspi_flash_ctrl.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `pclk` | input | 1 | APB Clock |
| `apb_if` | interface | APB | APB Slave |
| `qspi_sck` | output | 1 | SPI Clock |
| `qspi_cs_n` | output | 1 | Chip Select |
| `qspi_io` | inout | 4 | Quad SPI Data |

### Block 10: SoC, I/O, & Advanced Peripherals (Batch 88)

**`apb_i2c_master.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `pclk` | input | 1 | APB Clock |
| `apb_if` | interface | APB | APB Slave |
| `scl` | inout | 1 | I2C Clock |
| `sda` | inout | 1 | I2C Data |

---
**`apb_timer_watchdog.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `pclk` | input | 1 | APB Clock |
| `apb_if` | interface | APB | APB Slave |
| `wdog_rst` | output | 1 | Watchdog Reset trigger |

---
**`apb_gpio_port.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `pclk` | input | 1 | APB Clock |
| `apb_if` | interface | APB | APB Slave |
| `gpio_pins` | inout | 32 | GPIO Pads |
| `gpio_irq` | output | 1 | GPIO Interrupt |

### Block 10: SoC, I/O, & Advanced Peripherals (Batch 89)

**`rtc_module_core.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `rtc_clk` | input | 1 | 32.768 kHz Osc |
| `apb_if` | interface | APB | APB Interface |
| `time_out` | output | 64 | Current RTC Time |
| `alarm_irq` | output | 1 | RTC Alarm Interrupt |

---
**`dvfs_power_controller.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `axi_lite_if` | interface | AXI-Lite | Config |
| `vsel_out` | output | 8 | Voltage Select to external PMIC |
| `fsel_out` | output | 8 | Frequency Select to PLLs |

---
**`thermal_sensor_adc.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `analog_temp` | input | - | Analog diode voltage |
| `digital_temp`| output | 12 | ADC Output (Temperature) |
| `overtemp_irq`| output | 1 | Over-temperature alarm |

### Block 10: SoC, I/O, & Advanced Peripherals (Batch 90)

**`clock_reset_manager.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `ref_clk` | input | 1 | Base Crystal Clock |
| `por_rst_n` | input | 1 | Power-On Reset |
| `pll_configs` | input | 64 | Configurations from DVFS |
| `clk_out` | output | 8 | 8 Clocks for different domains |
| `rst_out_n` | output | 8 | Synchronized resets |

---
**`jtag_debug_transport.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `tck, tms, tdi`| input | 1 | JTAG inputs |
| `tdo` | output | 1 | JTAG output |
| `dmi_req` | output | 41 | DMI Request to Core |
| `dmi_resp` | input | 34 | DMI Response from Core |

---
**`soc_reset_controller.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `wdog_rst` | input | 1 | Watchdog Reset |
| `soft_rst` | input | 1 | Software Reset via APB |
| `system_rst_n`| output | 1 | Global System Reset |

### Block 10: SoC, I/O, & Advanced Peripherals (Batch 91)

**`boot_rom_controller.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `axi_lite_if` | interface | AXI-Lite | Read-only AXI interface |
| `rom_data` | output | 32 | Fetched boot code |

---
**`axi4_lite_interconnect.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `s_axi_if` | interface | AXI-Lite | From CPU / PCIe |
| `m_axi_if` | interface | `N * AXI-L`| To Peripherals |

---
**`pinmux_controller.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `apb_if` | interface | APB | APB Slave |
| `periph_sigs` | input | `SIG_COUNT` | Signals from internal peripherals |
| `pad_sigs` | inout | `PAD_COUNT` | Actual SoC IO Pads |

### Block 10: SoC, I/O, & Advanced Peripherals (Batch 92)

**`i2s_audio_interface.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `apb_if` | interface | APB | APB Slave |
| `i2s_sck` | output | 1 | I2S Clock |
| `i2s_ws` | output | 1 | Word Select |
| `i2s_sd` | inout | 1 | Serial Data |

---
**`ethernet_mac_10g.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `axi_if` | interface | AXI4 | DMA to Memory |
| `xgmii_txd` | output | 64 | XGMII Transmit Data |
| `xgmii_rxd` | input | 64 | XGMII Receive Data |

---
**`usb_3_0_controller.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `axi_if` | interface | AXI4 | DMA to Memory |
| `pipe_if` | interface | PIPE | PIPE Interface to USB PHY |

### Block 10: SoC, I/O, & Advanced Peripherals (Batch 93)

**`usb_phy_wrapper.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `pipe_if` | interface | PIPE | From Controller |
| `usb_tx_p/n` | output | 1 | USB SS TX |
| `usb_rx_p/n` | input | 1 | USB SS RX |

---
**`mipi_dsi_controller.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rgb_in` | input | 24 | RGB from Display Processor |
| `dsi_tx_p/n` | output | 4 | MIPI D-PHY lanes |

---
**`mipi_csi_controller.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `csi_rx_p/n` | input | 4 | MIPI D-PHY lanes from Camera |
| `axi_if` | interface | AXI4 | DMA to Memory |

---
**`soc_top.sv` — Port Specification**

| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `sys_clk` | input | 1 | External System Clock |
| `sys_rst_n` | input | 1 | External System Reset |
| `ddr4_pins` | inout | ~100| DDR4 interface pins |
| `pcie_pins` | inout | 32 | PCIe TX/RX pins |
| `gpio_pads` | inout | 32 | GPIO pins |
| `hdmi_pads` | output | 4 | HDMI pins |
| `uart,i2c,spi`| inout | 10 | Low speed serial pins |
| `jtag_pads` | input | 4 | Debug pins |

