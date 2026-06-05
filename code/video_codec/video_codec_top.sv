`timescale 1ns/1ps

module video_codec_top (
    input  logic        clk,
    input  logic        rst_n,
    
    // AXI4-Lite Slave Interface
    input  logic        s_awvalid,
    output logic        s_awready,
    input  logic [31:0] s_awaddr,
    
    input  logic        s_wvalid,
    output logic        s_wready,
    input  logic [31:0] s_wdata,
    
    output logic        s_bvalid,
    input  logic        s_bready,
    
    input  logic        s_arvalid,
    output logic        s_arready,
    input  logic [31:0] s_araddr,
    
    output logic        s_rvalid,
    input  logic        s_rready,
    output logic [31:0] s_rdata
);

    // --- INTERNAL SIGNALS ---
    logic [63:0] u_av1_cdef_filter_0_filter_start;
    logic [63:0] u_av1_cdef_filter_0_cdef_strength;
    logic [63:0] u_av1_cdef_filter_0_mem_req;
    logic [63:0] u_av1_cdef_filter_0_mem_addr;
    logic [63:0] u_av1_cdef_filter_0_mem_we;
    logic [63:0] u_av1_cdef_filter_0_mem_wdata;
    logic [63:0] u_av1_cdef_filter_0_mem_rdata;
    logic [63:0] u_av1_cdef_filter_0_mem_ack;
    logic [63:0] u_av1_cdef_filter_0_filter_done;
    logic [63:0] u_av1_decoder_top_2_m_awvalid;
    logic [63:0] u_av1_decoder_top_2_m_awready;
    logic [63:0] u_av1_decoder_top_2_m_awaddr;
    logic [63:0] u_av1_decoder_top_2_m_awlen;
    logic [63:0] u_av1_decoder_top_2_m_wvalid;
    logic [63:0] u_av1_decoder_top_2_m_wready;
    logic [63:0] u_av1_decoder_top_2_m_wdata;
    logic [63:0] u_av1_decoder_top_2_m_wlast;
    logic [63:0] u_av1_decoder_top_2_m_bvalid;
    logic [63:0] u_av1_decoder_top_2_m_bready;
    logic [63:0] u_av1_decoder_top_2_m_arvalid;
    logic [63:0] u_av1_decoder_top_2_m_arready;
    logic [63:0] u_av1_decoder_top_2_m_araddr;
    logic [63:0] u_av1_decoder_top_2_m_arlen;
    logic [63:0] u_av1_decoder_top_2_m_rvalid;
    logic [63:0] u_av1_decoder_top_2_m_rready;
    logic [63:0] u_av1_decoder_top_2_m_rdata;
    logic [63:0] u_av1_decoder_top_2_m_rlast;
    logic [63:0] u_av1_entropy_decoder_3_bs_valid;
    logic [63:0] u_av1_entropy_decoder_3_bs_data;
    logic [63:0] u_av1_entropy_decoder_3_bs_ready;
    logic [63:0] u_av1_entropy_decoder_3_sym_valid;
    logic [63:0] u_av1_entropy_decoder_3_sym_coeff;
    logic [63:0] u_av1_entropy_decoder_3_sym_run;
    logic [63:0] u_av1_entropy_decoder_3_sym_type;
    logic [63:0] u_av1_entropy_decoder_3_sym_ready;
    logic [63:0] u_av1_idct_2d_4_coeff_valid;
    logic [63:0] u_av1_idct_2d_4_coeff_data;
    logic [63:0] u_av1_idct_2d_4_coeff_start;
    logic [63:0] u_av1_idct_2d_4_coeff_ready;
    logic [63:0] u_av1_idct_2d_4_res_valid;
    logic [63:0] u_av1_idct_2d_4_res_data;
    logic [63:0] u_av1_idct_2d_4_res_start;
    logic [63:0] u_av1_idct_2d_4_res_ready;
    logic [63:0] u_av1_intra_predictor_5_pred_start;
    logic [63:0] u_av1_intra_predictor_5_pred_mode;
    logic [63:0] u_av1_intra_predictor_5_block_size;
    logic [63:0] u_av1_intra_predictor_5_top_pixels;
    logic [63:0] u_av1_intra_predictor_5_left_pixels;
    logic [63:0] u_av1_intra_predictor_5_top_left_pixel;
    logic [63:0] u_av1_intra_predictor_5_pred_valid;
    logic [63:0] u_av1_intra_predictor_5_pred_pixel;
    logic [63:0] u_av1_intra_predictor_5_pred_done;
    logic [63:0] u_av1_intra_predictor_5_pred_ready;
    logic [63:0] u_av1_loop_filter_6_filter_start;
    logic [63:0] u_av1_loop_filter_6_filter_level;
    logic [63:0] u_av1_loop_filter_6_edge_dir;
    logic [63:0] u_av1_loop_filter_6_mem_req;
    logic [63:0] u_av1_loop_filter_6_mem_addr;
    logic [63:0] u_av1_loop_filter_6_mem_we;
    logic [63:0] u_av1_loop_filter_6_mem_wdata;
    logic [63:0] u_av1_loop_filter_6_mem_rdata;
    logic [63:0] u_av1_loop_filter_6_mem_ack;
    logic [63:0] u_av1_loop_filter_6_filter_done;
    logic [63:0] u_av1_motion_compensator_7_mc_start;
    logic [63:0] u_av1_motion_compensator_7_mv_x;
    logic [63:0] u_av1_motion_compensator_7_mv_y;
    logic [63:0] u_av1_motion_compensator_7_block_size;
    logic [63:0] u_av1_motion_compensator_7_m_arvalid;
    logic [63:0] u_av1_motion_compensator_7_m_arready;
    logic [63:0] u_av1_motion_compensator_7_m_araddr;
    logic [63:0] u_av1_motion_compensator_7_m_arlen;
    logic [63:0] u_av1_motion_compensator_7_m_rvalid;
    logic [63:0] u_av1_motion_compensator_7_m_rready;
    logic [63:0] u_av1_motion_compensator_7_m_rdata;
    logic [63:0] u_av1_motion_compensator_7_m_rlast;
    logic [63:0] u_av1_motion_compensator_7_pred_valid;
    logic [63:0] u_av1_motion_compensator_7_pred_pixel;
    logic [63:0] u_av1_motion_compensator_7_pred_done;
    logic [63:0] u_av1_motion_compensator_7_pred_ready;
    logic [63:0] u_color_format_converter_8_color_in;
    logic [63:0] u_color_format_converter_8_format_in;
    logic [63:0] u_color_format_converter_8_format_out;
    logic [63:0] u_color_format_converter_8_color_out;
    logic [63:0] u_color_space_converter_9_in_valid;
    logic [63:0] u_color_space_converter_9_in_data;
    logic [63:0] u_color_space_converter_9_in_ready;
    logic [63:0] u_color_space_converter_9_out_valid;
    logic [63:0] u_color_space_converter_9_out_data;
    logic [63:0] u_color_space_converter_9_out_ready;
    logic [63:0] u_deblocking_filter_10_valid_in;
    logic [63:0] u_deblocking_filter_10_pixels_in;
    logic [63:0] u_deblocking_filter_10_alpha;
    logic [63:0] u_deblocking_filter_10_beta;
    logic [63:0] u_deblocking_filter_10_tc;
    logic [63:0] u_deblocking_filter_10_valid_out;
    logic [63:0] u_deblocking_filter_10_pixels_out;
    logic [63:0] u_display_controller_top_11_pixel_clk;
    logic [63:0] u_display_controller_top_11_m_arvalid;
    logic [63:0] u_display_controller_top_11_m_arready;
    logic [63:0] u_display_controller_top_11_m_araddr;
    logic [63:0] u_display_controller_top_11_m_arlen;
    logic [63:0] u_display_controller_top_11_m_rvalid;
    logic [63:0] u_display_controller_top_11_m_rready;
    logic [63:0] u_display_controller_top_11_m_rdata;
    logic [63:0] u_display_controller_top_11_m_rlast;
    logic [63:0] u_display_controller_top_11_hdmi_clk_p;
    logic [63:0] u_display_controller_top_11_hdmi_clk_n;
    logic [63:0] u_display_controller_top_11_hdmi_tx_p;
    logic [63:0] u_display_controller_top_11_hdmi_tx_n;
    logic [63:0] u_inverse_transform_unit_15_valid_in;
    logic [63:0] u_inverse_transform_unit_15_coeffs;
    logic [63:0] u_inverse_transform_unit_15_valid_out;
    logic [63:0] u_inverse_transform_unit_15_residuals;
    logic [63:0] u_motion_estimation_engine_16_valid_in;
    logic [63:0] u_motion_estimation_engine_16_curr_mb;
    logic [63:0] u_motion_estimation_engine_16_ref_window;
    logic [63:0] u_motion_estimation_engine_16_valid_out;
    logic [63:0] u_motion_estimation_engine_16_best_mv_x;
    logic [63:0] u_motion_estimation_engine_16_best_mv_y;
    logic [63:0] u_motion_estimation_engine_16_best_sad;

    // --- INSTANTIATIONS ---
    av1_cdef_filter u_av1_cdef_filter_0 (
        .clk(clk),
        .rst_n(rst_n),
        .filter_start(u_av1_cdef_filter_0_filter_start),
        .cdef_strength(u_av1_cdef_filter_0_cdef_strength),
        .mem_req(u_av1_cdef_filter_0_mem_req),
        .mem_addr(u_av1_cdef_filter_0_mem_addr),
        .mem_we(u_av1_cdef_filter_0_mem_we),
        .mem_wdata(u_av1_cdef_filter_0_mem_wdata),
        .mem_rdata(u_av1_cdef_filter_0_mem_rdata),
        .mem_ack(u_av1_cdef_filter_0_mem_ack),
        .filter_done(u_av1_cdef_filter_0_filter_done)
    );

    av1_decoder_core u_av1_decoder_core_1 (
        .clk(clk),
        .rst_n(rst_n),
        .s_awvalid('0),
        .s_awready(),
        .s_awaddr('0),
        .s_wvalid('0),
        .s_wready(),
        .s_wdata('0),
        .s_bvalid('0),
        .s_bready(),
        .s_arvalid('0),
        .s_arready(),
        .s_araddr('0),
        .s_rvalid('0),
        .s_rready(),
        .s_rdata('0)
    );

    av1_decoder_top u_av1_decoder_top_2 (
        .clk(clk),
        .rst_n(rst_n),
        .s_awvalid('0),
        .s_awready(),
        .s_awaddr('0),
        .s_wvalid('0),
        .s_wready(),
        .s_wdata('0),
        .s_bvalid('0),
        .s_bready(),
        .s_arvalid('0),
        .s_arready(),
        .s_araddr('0),
        .s_rvalid('0),
        .s_rready(),
        .s_rdata('0),
        .m_awvalid('0),
        .m_awready(),
        .m_awaddr('0),
        .m_awlen('0),
        .m_wvalid('0),
        .m_wready(),
        .m_wdata('0),
        .m_wlast('0),
        .m_bvalid('0),
        .m_bready(),
        .m_arvalid('0),
        .m_arready(),
        .m_araddr('0),
        .m_arlen('0),
        .m_rvalid('0),
        .m_rready(),
        .m_rdata('0),
        .m_rlast('0)
    );

    av1_entropy_decoder u_av1_entropy_decoder_3 (
        .clk(clk),
        .rst_n(rst_n),
        .bs_valid(u_av1_entropy_decoder_3_bs_valid),
        .bs_data(u_av1_entropy_decoder_3_bs_data),
        .bs_ready(u_av1_entropy_decoder_3_bs_ready),
        .sym_valid(u_av1_entropy_decoder_3_sym_valid),
        .sym_coeff(u_av1_entropy_decoder_3_sym_coeff),
        .sym_run(u_av1_entropy_decoder_3_sym_run),
        .sym_type(u_av1_entropy_decoder_3_sym_type),
        .sym_ready(u_av1_entropy_decoder_3_sym_ready)
    );

    av1_idct_2d u_av1_idct_2d_4 (
        .clk(clk),
        .rst_n(rst_n),
        .coeff_valid(u_av1_idct_2d_4_coeff_valid),
        .coeff_data(u_av1_idct_2d_4_coeff_data),
        .coeff_start(u_av1_idct_2d_4_coeff_start),
        .coeff_ready(u_av1_idct_2d_4_coeff_ready),
        .res_valid(u_av1_idct_2d_4_res_valid),
        .res_data(u_av1_idct_2d_4_res_data),
        .res_start(u_av1_idct_2d_4_res_start),
        .res_ready(u_av1_idct_2d_4_res_ready)
    );

    av1_intra_predictor u_av1_intra_predictor_5 (
        .clk(clk),
        .rst_n(rst_n),
        .pred_start(u_av1_intra_predictor_5_pred_start),
        .pred_mode(u_av1_intra_predictor_5_pred_mode),
        .block_size(u_av1_intra_predictor_5_block_size),
        .top_pixels(u_av1_intra_predictor_5_top_pixels),
        .left_pixels(u_av1_intra_predictor_5_left_pixels),
        .top_left_pixel(u_av1_intra_predictor_5_top_left_pixel),
        .pred_valid(u_av1_intra_predictor_5_pred_valid),
        .pred_pixel(u_av1_intra_predictor_5_pred_pixel),
        .pred_done(u_av1_intra_predictor_5_pred_done),
        .pred_ready(u_av1_intra_predictor_5_pred_ready)
    );

    av1_loop_filter u_av1_loop_filter_6 (
        .clk(clk),
        .rst_n(rst_n),
        .filter_start(u_av1_loop_filter_6_filter_start),
        .filter_level(u_av1_loop_filter_6_filter_level),
        .edge_dir(u_av1_loop_filter_6_edge_dir),
        .mem_req(u_av1_loop_filter_6_mem_req),
        .mem_addr(u_av1_loop_filter_6_mem_addr),
        .mem_we(u_av1_loop_filter_6_mem_we),
        .mem_wdata(u_av1_loop_filter_6_mem_wdata),
        .mem_rdata(u_av1_loop_filter_6_mem_rdata),
        .mem_ack(u_av1_loop_filter_6_mem_ack),
        .filter_done(u_av1_loop_filter_6_filter_done)
    );

    av1_motion_compensator u_av1_motion_compensator_7 (
        .clk(clk),
        .rst_n(rst_n),
        .mc_start(u_av1_motion_compensator_7_mc_start),
        .mv_x(u_av1_motion_compensator_7_mv_x),
        .mv_y(u_av1_motion_compensator_7_mv_y),
        .block_size(u_av1_motion_compensator_7_block_size),
        .m_arvalid('0),
        .m_arready(),
        .m_araddr('0),
        .m_arlen('0),
        .m_rvalid('0),
        .m_rready(),
        .m_rdata('0),
        .m_rlast('0),
        .pred_valid(u_av1_motion_compensator_7_pred_valid),
        .pred_pixel(u_av1_motion_compensator_7_pred_pixel),
        .pred_done(u_av1_motion_compensator_7_pred_done),
        .pred_ready(u_av1_motion_compensator_7_pred_ready)
    );

    color_format_converter u_color_format_converter_8 (
        .color_in(u_color_format_converter_8_color_in),
        .format_in(u_color_format_converter_8_format_in),
        .format_out(u_color_format_converter_8_format_out),
        .color_out(u_color_format_converter_8_color_out)
    );

    color_space_converter u_color_space_converter_9 (
        .clk(clk),
        .rst_n(rst_n),
        .in_valid(u_color_space_converter_9_in_valid),
        .in_data(u_color_space_converter_9_in_data),
        .in_ready(u_color_space_converter_9_in_ready),
        .out_valid(u_color_space_converter_9_out_valid),
        .out_data(u_color_space_converter_9_out_data),
        .out_ready(u_color_space_converter_9_out_ready)
    );

    deblocking_filter u_deblocking_filter_10 (
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(u_deblocking_filter_10_valid_in),
        .pixels_in(u_deblocking_filter_10_pixels_in),
        .alpha(u_deblocking_filter_10_alpha),
        .beta(u_deblocking_filter_10_beta),
        .tc(u_deblocking_filter_10_tc),
        .valid_out(u_deblocking_filter_10_valid_out),
        .pixels_out(u_deblocking_filter_10_pixels_out)
    );

    display_controller_top u_display_controller_top_11 (
        .clk(clk),
        .rst_n(rst_n),
        .pixel_clk(u_display_controller_top_11_pixel_clk),
        .s_awvalid('0),
        .s_awready(),
        .s_awaddr('0),
        .s_wvalid('0),
        .s_wready(),
        .s_wdata('0),
        .s_bvalid('0),
        .s_bready(),
        .s_arvalid('0),
        .s_arready(),
        .s_araddr('0),
        .s_rvalid('0),
        .s_rready(),
        .s_rdata('0),
        .m_arvalid('0),
        .m_arready(),
        .m_araddr('0),
        .m_arlen('0),
        .m_rvalid('0),
        .m_rready(),
        .m_rdata('0),
        .m_rlast('0),
        .hdmi_clk_p(u_display_controller_top_11_hdmi_clk_p),
        .hdmi_clk_n(u_display_controller_top_11_hdmi_clk_n),
        .hdmi_tx_p(u_display_controller_top_11_hdmi_tx_p),
        .hdmi_tx_n(u_display_controller_top_11_hdmi_tx_n)
    );

    display_processor_2d u_display_processor_2d_12 (
        .clk(clk),
        .rst_n(rst_n),
        .s_awvalid('0),
        .s_awready(),
        .s_awaddr('0),
        .s_wvalid('0),
        .s_wready(),
        .s_wdata('0),
        .s_bvalid('0),
        .s_bready(),
        .s_arvalid('0),
        .s_arready(),
        .s_araddr('0),
        .s_rvalid('0),
        .s_rready(),
        .s_rdata('0)
    );

    entropy_decoder_cabac u_entropy_decoder_cabac_13 (
        .clk(clk),
        .rst_n(rst_n),
        .s_awvalid('0),
        .s_awready(),
        .s_awaddr('0),
        .s_wvalid('0),
        .s_wready(),
        .s_wdata('0),
        .s_bvalid('0),
        .s_bready(),
        .s_arvalid('0),
        .s_arready(),
        .s_araddr('0),
        .s_rvalid('0),
        .s_rready(),
        .s_rdata('0)
    );

    hevc_h265_encoder u_hevc_h265_encoder_14 (
        .clk(clk),
        .rst_n(rst_n),
        .s_awvalid('0),
        .s_awready(),
        .s_awaddr('0),
        .s_wvalid('0),
        .s_wready(),
        .s_wdata('0),
        .s_bvalid('0),
        .s_bready(),
        .s_arvalid('0),
        .s_arready(),
        .s_araddr('0),
        .s_rvalid('0),
        .s_rready(),
        .s_rdata('0)
    );

    inverse_transform_unit u_inverse_transform_unit_15 (
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(u_inverse_transform_unit_15_valid_in),
        .coeffs(u_inverse_transform_unit_15_coeffs),
        .valid_out(u_inverse_transform_unit_15_valid_out),
        .residuals(u_inverse_transform_unit_15_residuals)
    );

    motion_estimation_engine u_motion_estimation_engine_16 (
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(u_motion_estimation_engine_16_valid_in),
        .curr_mb(u_motion_estimation_engine_16_curr_mb),
        .ref_window(u_motion_estimation_engine_16_ref_window),
        .valid_out(u_motion_estimation_engine_16_valid_out),
        .best_mv_x(u_motion_estimation_engine_16_best_mv_x),
        .best_mv_y(u_motion_estimation_engine_16_best_mv_y),
        .best_sad(u_motion_estimation_engine_16_best_sad)
    );

endmodule
