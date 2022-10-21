`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/15/2022 10:49:18 PM
// Design Name: 
// Module Name: file_manager
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module file_manager(
    input clk,
    input reset,

    input istart,
    input iload,
    input iload_address,
    input [31:0]idone,
    input [63:0]start_address,
    input [63:0]file_size,
    output [31:0]ostart,
    output oreset,
    output ready,
    output odone,
    output [63:0]ofilesize,
    output [63:0]onext_addr,
    output [63:0]bash_offset,
    output [31:0]bash_count,
    output bash_update,
    output overlap,
    output [63:0]oc0_addr,
    output [63:0]oc1_addr,
    output [63:0]oc2_addr,
    output [63:0]oc3_addr,
    output [63:0]oc4_addr,
    output [63:0]oc5_addr,
    output [63:0]oc6_addr,
    output [63:0]oc7_addr,
    output [63:0]oc8_addr,
    output [63:0]oc9_addr,
    output [63:0]oc10_addr,
    output [63:0]oc11_addr,
    output [63:0]oc12_addr,
    output [63:0]oc13_addr,
    output [63:0]oc14_addr,
    output [63:0]oc15_addr,
    output [63:0]oc16_addr,
    output [63:0]oc17_addr,
    output [63:0]oc18_addr,
    output [63:0]oc19_addr,
    output [63:0]oc20_addr,
    output [63:0]oc21_addr,
    output [63:0]oc22_addr,
    output [63:0]oc23_addr,
    output [63:0]oc24_addr,
    output [63:0]oc25_addr,
    output [63:0]oc26_addr,
    output [63:0]oc27_addr,
    output [63:0]oc28_addr,
    output [63:0]oc29_addr,
    output [63:0]oc30_addr,
    output [63:0]oc31_addr,
    output [31:0]oc0_rdlen,
    output [31:0]oc1_rdlen,
    output [31:0]oc2_rdlen,
    output [31:0]oc3_rdlen,
    output [31:0]oc4_rdlen,
    output [31:0]oc5_rdlen,
    output [31:0]oc6_rdlen,
    output [31:0]oc7_rdlen,
    output [31:0]oc8_rdlen,
    output [31:0]oc9_rdlen,
    output [31:0]oc10_rdlen,
    output [31:0]oc11_rdlen,
    output [31:0]oc12_rdlen,
    output [31:0]oc13_rdlen,
    output [31:0]oc14_rdlen,
    output [31:0]oc15_rdlen,
    output [31:0]oc16_rdlen,
    output [31:0]oc17_rdlen,
    output [31:0]oc18_rdlen,
    output [31:0]oc19_rdlen,
    output [31:0]oc20_rdlen,
    output [31:0]oc21_rdlen,
    output [31:0]oc22_rdlen,
    output [31:0]oc23_rdlen,
    output [31:0]oc24_rdlen,
    output [31:0]oc25_rdlen,
    output [31:0]oc26_rdlen,
    output [31:0]oc27_rdlen,
    output [31:0]oc28_rdlen,
    output [31:0]oc29_rdlen,
    output [31:0]oc30_rdlen,
    output [31:0]oc31_rdlen    
);

    parameter BASE_0  = 64'h0,
    BASE_1  = 64'h10000000,
    BASE_2  = 64'h20000000,
    BASE_3  = 64'h30000000,
    BASE_4  = 64'h40000000,
    BASE_5  = 64'h50000000,
    BASE_6  = 64'h60000000,
    BASE_7  = 64'h70000000,
    BASE_8  = 64'h80000000,
    BASE_9  = 64'h90000000,
    BASE_10 = 64'ha0000000,
    BASE_11 = 64'hb0000000,
    BASE_12 = 64'hc0000000,
    BASE_13 = 64'hd0000000,
    BASE_14 = 64'he0000000,
    BASE_15 = 64'hf0000000,
    BASE_16 = 64'h100000000,
    BASE_17 = 64'h110000000,
    BASE_18 = 64'h120000000,
    BASE_19 = 64'h130000000,
    BASE_20 = 64'h140000000,
    BASE_21 = 64'h150000000,
    BASE_22 = 64'h160000000,
    BASE_23 = 64'h170000000,
    BASE_24 = 64'h180000000,
    BASE_25 = 64'h190000000,
    BASE_26 = 64'h1a0000000,
    BASE_27 = 64'h1b0000000,
    BASE_28 = 64'h1c0000000,
    BASE_29 = 64'h1d0000000,
    BASE_30 = 64'h1e0000000,
    BASE_31 = 64'h1f0000000,
    BASE_MASK   = 64'h1ffffffff;

    reg [63:0]r_start_address = 64'd0;
    reg [63:0]r_file_size = 64'd0;
    reg [63:0]r_size_next = 64'd0;

    reg [63:0]c0_addr = 64'd0;
    reg [63:0]c1_addr = 64'd0;
    reg [63:0]c2_addr = 64'd0;
    reg [63:0]c3_addr = 64'd0;
    reg [63:0]c4_addr = 64'd0;
    reg [63:0]c5_addr = 64'd0;
    reg [63:0]c6_addr = 64'd0;
    reg [63:0]c7_addr = 64'd0;
    reg [63:0]c8_addr = 64'd0;
    reg [63:0]c9_addr = 64'd0;
    reg [63:0]c10_addr = 64'd0;
    reg [63:0]c11_addr = 64'd0;
    reg [63:0]c12_addr = 64'd0;
    reg [63:0]c13_addr = 64'd0;
    reg [63:0]c14_addr = 64'd0;
    reg [63:0]c15_addr = 64'd0;
    reg [63:0]c16_addr = 64'd0;
    reg [63:0]c17_addr = 64'd0;
    reg [63:0]c18_addr = 64'd0;
    reg [63:0]c19_addr = 64'd0;
    reg [63:0]c20_addr = 64'd0;
    reg [63:0]c21_addr = 64'd0;
    reg [63:0]c22_addr = 64'd0;
    reg [63:0]c23_addr = 64'd0;
    reg [63:0]c24_addr = 64'd0;
    reg [63:0]c25_addr = 64'd0;
    reg [63:0]c26_addr = 64'd0;
    reg [63:0]c27_addr = 64'd0;
    reg [63:0]c28_addr = 64'd0;
    reg [63:0]c29_addr = 64'd0;
    reg [63:0]c30_addr = 64'd0;
    reg [63:0]c31_addr = 64'd0;

    reg [7:0]c0_rdlen = 8'd0;
    reg [7:0]c1_rdlen = 8'd0;
    reg [7:0]c2_rdlen = 8'd0;
    reg [7:0]c3_rdlen = 8'd0;
    reg [7:0]c4_rdlen = 8'd0;
    reg [7:0]c5_rdlen = 8'd0;
    reg [7:0]c6_rdlen = 8'd0;
    reg [7:0]c7_rdlen = 8'd0;
    reg [7:0]c8_rdlen = 8'd0;
    reg [7:0]c9_rdlen = 8'd0;
    reg [7:0]c10_rdlen = 8'd0;
    reg [7:0]c11_rdlen = 8'd0;
    reg [7:0]c12_rdlen = 8'd0;
    reg [7:0]c13_rdlen = 8'd0;
    reg [7:0]c14_rdlen = 8'd0;
    reg [7:0]c15_rdlen = 8'd0;
    reg [7:0]c16_rdlen = 8'd0;
    reg [7:0]c17_rdlen = 8'd0;
    reg [7:0]c18_rdlen = 8'd0;
    reg [7:0]c19_rdlen = 8'd0;
    reg [7:0]c20_rdlen = 8'd0;
    reg [7:0]c21_rdlen = 8'd0;
    reg [7:0]c22_rdlen = 8'd0;
    reg [7:0]c23_rdlen = 8'd0;
    reg [7:0]c24_rdlen = 8'd0;
    reg [7:0]c25_rdlen = 8'd0;
    reg [7:0]c26_rdlen = 8'd0;
    reg [7:0]c27_rdlen = 8'd0;
    reg [7:0]c28_rdlen = 8'd0;
    reg [7:0]c29_rdlen = 8'd0;
    reg [7:0]c30_rdlen = 8'd0;
    reg [7:0]c31_rdlen = 8'd0;

    reg roverlap;
    
    reg [5:0]nfull_channel = 6'd0;
    reg [9:0]nbytes_nfull_channel = 10'd0;
    reg [7:0]cnt_up = 8'd0;
    reg [7:0]cnt_down = 8'd0;
    reg [31:0]rostart = 32'd0;
    reg [31:0]rwait  = 32'd0;
    reg is_empty = 1'b0;
    
    reg [31:0]collect_done = 32'd0;
    
    reg [63:0]rbashoffset = 64'd0;
    reg [31:0]rbashcount = 32'd0;
    reg rbash_update = 1'b0;
    
    reg [1:0]rstart = 2'b00;
    
    parameter S_IDLE    = 4'd0,
    S_RESET0  = 4'd1,
    S_LOAD0   = 4'd2,
    S_CALC0   = 4'd3,
    S_START0  = 4'd4,
    S_WAIT0   = 4'd5,
    S_RESET1  = 4'd6,
    S_LOAD1   = 4'd7,
    S_CALC1   = 4'd8,
    S_START1  = 4'd9,
    S_WAIT1   = 4'd10,
    S_ADJUST  = 4'd11,
    S_DONE    = 4'd12;

    reg [3:0]state, next;

    wire sidle   = state == S_IDLE;
    wire sreset0 = state == S_RESET0;
    wire sload0  = state == S_LOAD0;
    wire scalc0  = state == S_CALC0;
    wire sstart0 = state == S_START0;
    wire swait0  = state == S_WAIT0;
    wire sreset1 = state == S_RESET1;
    wire sload1  = state == S_LOAD1;
    wire scalc1  = state == S_CALC1;
    wire sstart1 = state == S_START1;
    wire swait1  = state == S_WAIT1;
    wire sadjust = state == S_ADJUST;
    wire sdone   = state == S_DONE;
    
    
    wire [5:0] addr_inc [0:31];
    wire [27:0] start_address_inc [0:31];
    wire [27:0] addr_inc0 [0:31];
    wire [27:0] addr_inc1 [0:31];
    wire [31:0]wait_cond;
    
    reg [31:0]flippled_start;
    
    wire [31:0]first_flip;
    wire [31:0]last_channel;
    
    reg [7:0]rdlen_sel;
    reg [32:0]rdaddr_sel;
    
    reg [63:0]rnext_address = 64'd0;
    
    wire [7:0]rdlen_and[0:31];
    wire [32:0]rdaddr_and[0:31];
    
    wire [32:0]wnext_address;
    
    assign first_flip[0] = rostart[31];
    assign first_flip[1] = rostart[30];
    assign first_flip[2] = rostart[29];
    assign first_flip[3] = rostart[28];
    assign first_flip[4] = rostart[27];
    assign first_flip[5] = rostart[26];
    assign first_flip[6] = rostart[25];
    assign first_flip[7] = rostart[24];
    assign first_flip[8] = rostart[23];
    assign first_flip[9] = rostart[22];
    assign first_flip[10] = rostart[21];
    assign first_flip[11] = rostart[20];
    assign first_flip[12] = rostart[19];
    assign first_flip[13] = rostart[18];
    assign first_flip[14] = rostart[17];
    assign first_flip[15] = rostart[16];
    assign first_flip[16] = rostart[15];
    assign first_flip[17] = rostart[14];
    assign first_flip[18] = rostart[13];
    assign first_flip[19] = rostart[12];
    assign first_flip[20] = rostart[11];
    assign first_flip[21] = rostart[10];
    assign first_flip[22] = rostart[9];
    assign first_flip[23] = rostart[8];
    assign first_flip[24] = rostart[7];
    assign first_flip[25] = rostart[6];
    assign first_flip[26] = rostart[5];
    assign first_flip[27] = rostart[4];
    assign first_flip[28] = rostart[3];
    assign first_flip[29] = rostart[2];    
    assign first_flip[30] = rostart[1];
    assign first_flip[31] = rostart[0];
        
    assign last_channel[0] = flippled_start[31];
    assign last_channel[1] = flippled_start[30];
    assign last_channel[2] = flippled_start[29];
    assign last_channel[3] = flippled_start[28];
    assign last_channel[4] = flippled_start[27];
    assign last_channel[5] = flippled_start[26];
    assign last_channel[6] = flippled_start[25];
    assign last_channel[7] = flippled_start[24];
    assign last_channel[8] = flippled_start[23];
    assign last_channel[9] = flippled_start[22];
    assign last_channel[10] = flippled_start[21];
    assign last_channel[11] = flippled_start[20];
    assign last_channel[12] = flippled_start[19];
    assign last_channel[13] = flippled_start[18];
    assign last_channel[14] = flippled_start[17];
    assign last_channel[15] = flippled_start[16];
    assign last_channel[16] = flippled_start[15];
    assign last_channel[17] = flippled_start[14];
    assign last_channel[18] = flippled_start[13];
    assign last_channel[19] = flippled_start[12];
    assign last_channel[20] = flippled_start[11];
    assign last_channel[21] = flippled_start[10];
    assign last_channel[22] = flippled_start[9];
    assign last_channel[23] = flippled_start[8];
    assign last_channel[24] = flippled_start[7];
    assign last_channel[25] = flippled_start[6];
    assign last_channel[26] = flippled_start[5];
    assign last_channel[27] = flippled_start[4];
    assign last_channel[28] = flippled_start[3];
    assign last_channel[29] = flippled_start[2]; 
    assign last_channel[30] = flippled_start[1];
    assign last_channel[31] = flippled_start[0];
            
    assign addr_inc[0] = {1'b0, r_start_address[32:28]};
    assign addr_inc[1] = r_start_address[32:28] + 5'd1;
    assign addr_inc[2] = r_start_address[32:28] + 5'd2;
    assign addr_inc[3] = r_start_address[32:28] + 5'd3;
    assign addr_inc[4] = r_start_address[32:28] + 5'd4;
    assign addr_inc[5] = r_start_address[32:28] + 5'd5;
    assign addr_inc[6] = r_start_address[32:28] + 5'd6;
    assign addr_inc[7] = r_start_address[32:28] + 5'd7;
    assign addr_inc[8] = r_start_address[32:28] + 5'd8;
    assign addr_inc[9] = r_start_address[32:28] + 5'd9;
    assign addr_inc[10] = r_start_address[32:28] + 5'd10;
    assign addr_inc[11] = r_start_address[32:28] + 5'd11;
    assign addr_inc[12] = r_start_address[32:28] + 5'd12;
    assign addr_inc[13] = r_start_address[32:28] + 5'd13;
    assign addr_inc[14] = r_start_address[32:28] + 5'd14;
    assign addr_inc[15] = r_start_address[32:28] + 5'd15;
    assign addr_inc[16] = r_start_address[32:28] + 5'd16;
    assign addr_inc[17] = r_start_address[32:28] + 5'd17;
    assign addr_inc[18] = r_start_address[32:28] + 5'd18;
    assign addr_inc[19] = r_start_address[32:28] + 5'd19;
    assign addr_inc[20] = r_start_address[32:28] + 5'd20;
    assign addr_inc[21] = r_start_address[32:28] + 5'd21;
    assign addr_inc[22] = r_start_address[32:28] + 5'd22;
    assign addr_inc[23] = r_start_address[32:28] + 5'd23;
    assign addr_inc[24] = r_start_address[32:28] + 5'd24;
    assign addr_inc[25] = r_start_address[32:28] + 5'd25;
    assign addr_inc[26] = r_start_address[32:28] + 5'd26;
    assign addr_inc[27] = r_start_address[32:28] + 5'd27;
    assign addr_inc[28] = r_start_address[32:28] + 5'd28;
    assign addr_inc[29] = r_start_address[32:28] + 5'd29;
    assign addr_inc[30] = r_start_address[32:28] + 5'd30;
    assign addr_inc[31] = r_start_address[32:28] + 5'd31;

    assign start_address_inc[0] = addr_inc[0][5]? 28'd1024: 28'd0;
    assign start_address_inc[1] = addr_inc[1][5]? 28'd1024: 28'd0;
    assign start_address_inc[2] = addr_inc[2][5]? 28'd1024: 28'd0;
    assign start_address_inc[3] = addr_inc[3][5]? 28'd1024: 28'd0;
    assign start_address_inc[4] = addr_inc[4][5]? 28'd1024: 28'd0;
    assign start_address_inc[5] = addr_inc[5][5]? 28'd1024: 28'd0;
    assign start_address_inc[6] = addr_inc[6][5]? 28'd1024: 28'd0;
    assign start_address_inc[7] = addr_inc[7][5]? 28'd1024: 28'd0;
    assign start_address_inc[8] = addr_inc[8][5]? 28'd1024: 28'd0;
    assign start_address_inc[9] = addr_inc[9][5]? 28'd1024: 28'd0;
    assign start_address_inc[10] = addr_inc[10][5]? 28'd1024: 28'd0;
    assign start_address_inc[11] = addr_inc[11][5]? 28'd1024: 28'd0;
    assign start_address_inc[12] = addr_inc[12][5]? 28'd1024: 28'd0;
    assign start_address_inc[13] = addr_inc[13][5]? 28'd1024: 28'd0;
    assign start_address_inc[14] = addr_inc[14][5]? 28'd1024: 28'd0;
    assign start_address_inc[15] = addr_inc[15][5]? 28'd1024: 28'd0;
    assign start_address_inc[16] = addr_inc[16][5]? 28'd1024: 28'd0;
    assign start_address_inc[17] = addr_inc[17][5]? 28'd1024: 28'd0;
    assign start_address_inc[18] = addr_inc[18][5]? 28'd1024: 28'd0;
    assign start_address_inc[19] = addr_inc[19][5]? 28'd1024: 28'd0;
    assign start_address_inc[20] = addr_inc[20][5]? 28'd1024: 28'd0;
    assign start_address_inc[21] = addr_inc[21][5]? 28'd1024: 28'd0;
    assign start_address_inc[22] = addr_inc[22][5]? 28'd1024: 28'd0;
    assign start_address_inc[23] = addr_inc[23][5]? 28'd1024: 28'd0;
    assign start_address_inc[24] = addr_inc[24][5]? 28'd1024: 28'd0;
    assign start_address_inc[25] = addr_inc[25][5]? 28'd1024: 28'd0;
    assign start_address_inc[26] = addr_inc[26][5]? 28'd1024: 28'd0;
    assign start_address_inc[27] = addr_inc[27][5]? 28'd1024: 28'd0;
    assign start_address_inc[28] = addr_inc[28][5]? 28'd1024: 28'd0;
    assign start_address_inc[29] = addr_inc[29][5]? 28'd1024: 28'd0;
    assign start_address_inc[30] = addr_inc[30][5]? 28'd1024: 28'd0;
    assign start_address_inc[31] = addr_inc[31][5]? 28'd1024: 28'd0;

    assign addr_inc0[0] = r_start_address[27:0] + start_address_inc[0];
    assign addr_inc0[1] = r_start_address[27:0] + start_address_inc[1];
    assign addr_inc0[2] = r_start_address[27:0] + start_address_inc[2];
    assign addr_inc0[3] = r_start_address[27:0] + start_address_inc[3];
    assign addr_inc0[4] = r_start_address[27:0] + start_address_inc[4];
    assign addr_inc0[5] = r_start_address[27:0] + start_address_inc[5];
    assign addr_inc0[6] = r_start_address[27:0] + start_address_inc[6];
    assign addr_inc0[7] = r_start_address[27:0] + start_address_inc[7];
    assign addr_inc0[8] = r_start_address[27:0] + start_address_inc[8];
    assign addr_inc0[9] = r_start_address[27:0] + start_address_inc[9];
    assign addr_inc0[10] = r_start_address[27:0] + start_address_inc[10];
    assign addr_inc0[11] = r_start_address[27:0] + start_address_inc[11];
    assign addr_inc0[12] = r_start_address[27:0] + start_address_inc[12];
    assign addr_inc0[13] = r_start_address[27:0] + start_address_inc[13];
    assign addr_inc0[14] = r_start_address[27:0] + start_address_inc[14];
    assign addr_inc0[15] = r_start_address[27:0] + start_address_inc[15];
    assign addr_inc0[16] = r_start_address[27:0] + start_address_inc[16];
    assign addr_inc0[17] = r_start_address[27:0] + start_address_inc[17];
    assign addr_inc0[18] = r_start_address[27:0] + start_address_inc[18];
    assign addr_inc0[19] = r_start_address[27:0] + start_address_inc[19];
    assign addr_inc0[20] = r_start_address[27:0] + start_address_inc[20];
    assign addr_inc0[21] = r_start_address[27:0] + start_address_inc[21];
    assign addr_inc0[22] = r_start_address[27:0] + start_address_inc[22];
    assign addr_inc0[23] = r_start_address[27:0] + start_address_inc[23];
    assign addr_inc0[24] = r_start_address[27:0] + start_address_inc[24];
    assign addr_inc0[25] = r_start_address[27:0] + start_address_inc[25];
    assign addr_inc0[26] = r_start_address[27:0] + start_address_inc[26];
    assign addr_inc0[27] = r_start_address[27:0] + start_address_inc[27];
    assign addr_inc0[28] = r_start_address[27:0] + start_address_inc[28];
    assign addr_inc0[29] = r_start_address[27:0] + start_address_inc[29];
    assign addr_inc0[30] = r_start_address[27:0] + start_address_inc[30];
    assign addr_inc0[31] = r_start_address[27:0] + start_address_inc[31];

    assign addr_inc1[0] = {r_start_address[27:10], 10'd0} + 1024;
    assign addr_inc1[1] = {r_start_address[27:10], 10'd0} + start_address_inc[1];
    assign addr_inc1[2] = {r_start_address[27:10], 10'd0} + start_address_inc[2];
    assign addr_inc1[3] = {r_start_address[27:10], 10'd0} + start_address_inc[3];
    assign addr_inc1[4] = {r_start_address[27:10], 10'd0} + start_address_inc[4];
    assign addr_inc1[5] = {r_start_address[27:10], 10'd0} + start_address_inc[5];
    assign addr_inc1[6] = {r_start_address[27:10], 10'd0} + start_address_inc[6];
    assign addr_inc1[7] = {r_start_address[27:10], 10'd0} + start_address_inc[7];
    assign addr_inc1[8] = {r_start_address[27:10], 10'd0} + start_address_inc[8];
    assign addr_inc1[9] = {r_start_address[27:10], 10'd0} + start_address_inc[9];
    assign addr_inc1[10] = {r_start_address[27:10], 10'd0} + start_address_inc[10];
    assign addr_inc1[11] = {r_start_address[27:10], 10'd0} + start_address_inc[11];
    assign addr_inc1[12] = {r_start_address[27:10], 10'd0} + start_address_inc[12];
    assign addr_inc1[13] = {r_start_address[27:10], 10'd0} + start_address_inc[13];
    assign addr_inc1[14] = {r_start_address[27:10], 10'd0} + start_address_inc[14];
    assign addr_inc1[15] = {r_start_address[27:10], 10'd0} + start_address_inc[15];
    assign addr_inc1[16] = {r_start_address[27:10], 10'd0} + start_address_inc[16];
    assign addr_inc1[17] = {r_start_address[27:10], 10'd0} + start_address_inc[17];
    assign addr_inc1[18] = {r_start_address[27:10], 10'd0} + start_address_inc[18];
    assign addr_inc1[19] = {r_start_address[27:10], 10'd0} + start_address_inc[19];
    assign addr_inc1[20] = {r_start_address[27:10], 10'd0} + start_address_inc[20];
    assign addr_inc1[21] = {r_start_address[27:10], 10'd0} + start_address_inc[21];
    assign addr_inc1[22] = {r_start_address[27:10], 10'd0} + start_address_inc[22];
    assign addr_inc1[23] = {r_start_address[27:10], 10'd0} + start_address_inc[23];
    assign addr_inc1[24] = {r_start_address[27:10], 10'd0} + start_address_inc[24];
    assign addr_inc1[25] = {r_start_address[27:10], 10'd0} + start_address_inc[25];
    assign addr_inc1[26] = {r_start_address[27:10], 10'd0} + start_address_inc[26];
    assign addr_inc1[27] = {r_start_address[27:10], 10'd0} + start_address_inc[27];
    assign addr_inc1[28] = {r_start_address[27:10], 10'd0} + start_address_inc[28];
    assign addr_inc1[29] = {r_start_address[27:10], 10'd0} + start_address_inc[29];    
    assign addr_inc1[30] = {r_start_address[27:10], 10'd0} + start_address_inc[30];
    assign addr_inc1[31] = {r_start_address[27:10], 10'd0} + start_address_inc[31];
    
    assign rdlen_and[0] = {8{last_channel[0]}} & c0_rdlen;
    assign rdlen_and[1] = {8{last_channel[1]}} & c1_rdlen;
    assign rdlen_and[2] = {8{last_channel[2]}} & c2_rdlen;
    assign rdlen_and[3] = {8{last_channel[3]}} & c3_rdlen;
    assign rdlen_and[4] = {8{last_channel[4]}} & c4_rdlen;
    assign rdlen_and[5] = {8{last_channel[5]}} & c5_rdlen;
    assign rdlen_and[6] = {8{last_channel[6]}} & c6_rdlen;
    assign rdlen_and[7] = {8{last_channel[7]}} & c7_rdlen;
    assign rdlen_and[8] = {8{last_channel[8]}} & c8_rdlen;
    assign rdlen_and[9] = {8{last_channel[9]}} & c9_rdlen;
    assign rdlen_and[10] = {8{last_channel[10]}} & c10_rdlen;
    assign rdlen_and[11] = {8{last_channel[11]}} & c11_rdlen;
    assign rdlen_and[12] = {8{last_channel[12]}} & c12_rdlen;
    assign rdlen_and[13] = {8{last_channel[13]}} & c13_rdlen;
    assign rdlen_and[14] = {8{last_channel[14]}} & c14_rdlen;
    assign rdlen_and[15] = {8{last_channel[15]}} & c15_rdlen;
    assign rdlen_and[16] = {8{last_channel[16]}} & c16_rdlen;
    assign rdlen_and[17] = {8{last_channel[17]}} & c17_rdlen;
    assign rdlen_and[18] = {8{last_channel[18]}} & c18_rdlen;
    assign rdlen_and[19] = {8{last_channel[19]}} & c19_rdlen;
    assign rdlen_and[20] = {8{last_channel[20]}} & c20_rdlen;
    assign rdlen_and[21] = {8{last_channel[21]}} & c21_rdlen;
    assign rdlen_and[22] = {8{last_channel[22]}} & c22_rdlen;
    assign rdlen_and[23] = {8{last_channel[23]}} & c23_rdlen;
    assign rdlen_and[24] = {8{last_channel[24]}} & c24_rdlen;
    assign rdlen_and[25] = {8{last_channel[25]}} & c25_rdlen;
    assign rdlen_and[26] = {8{last_channel[26]}} & c26_rdlen;
    assign rdlen_and[27] = {8{last_channel[27]}} & c27_rdlen;
    assign rdlen_and[28] = {8{last_channel[28]}} & c28_rdlen;
    assign rdlen_and[29] = {8{last_channel[29]}} & c29_rdlen;
    assign rdlen_and[30] = {8{last_channel[30]}} & c30_rdlen;
    assign rdlen_and[31] = {8{last_channel[31]}} & c31_rdlen;
    
    assign rdaddr_and[0] = {33{last_channel[0]}} & c0_addr[32:0];
    assign rdaddr_and[1] = {33{last_channel[1]}} & c1_addr[32:0];
    assign rdaddr_and[2] = {33{last_channel[2]}} & c2_addr[32:0];
    assign rdaddr_and[3] = {33{last_channel[3]}} & c3_addr[32:0];
    assign rdaddr_and[4] = {33{last_channel[4]}} & c4_addr[32:0];
    assign rdaddr_and[5] = {33{last_channel[5]}} & c5_addr[32:0];
    assign rdaddr_and[6] = {33{last_channel[6]}} & c6_addr[32:0];
    assign rdaddr_and[7] = {33{last_channel[7]}} & c7_addr[32:0];
    assign rdaddr_and[8] = {33{last_channel[8]}} & c8_addr[32:0];
    assign rdaddr_and[9] = {33{last_channel[9]}} & c9_addr[32:0];
    assign rdaddr_and[10] = {33{last_channel[10]}} & c10_addr[32:0];
    assign rdaddr_and[11] = {33{last_channel[11]}} & c11_addr[32:0];
    assign rdaddr_and[12] = {33{last_channel[12]}} & c12_addr[32:0];
    assign rdaddr_and[13] = {33{last_channel[13]}} & c13_addr[32:0];
    assign rdaddr_and[14] = {33{last_channel[14]}} & c14_addr[32:0];
    assign rdaddr_and[15] = {33{last_channel[15]}} & c15_addr[32:0];
    assign rdaddr_and[16] = {33{last_channel[16]}} & c16_addr[32:0];
    assign rdaddr_and[17] = {33{last_channel[17]}} & c17_addr[32:0];
    assign rdaddr_and[18] = {33{last_channel[18]}} & c18_addr[32:0];
    assign rdaddr_and[19] = {33{last_channel[19]}} & c19_addr[32:0];
    assign rdaddr_and[20] = {33{last_channel[20]}} & c20_addr[32:0];
    assign rdaddr_and[21] = {33{last_channel[21]}} & c21_addr[32:0];
    assign rdaddr_and[22] = {33{last_channel[22]}} & c22_addr[32:0];
    assign rdaddr_and[23] = {33{last_channel[23]}} & c23_addr[32:0];
    assign rdaddr_and[24] = {33{last_channel[24]}} & c24_addr[32:0];
    assign rdaddr_and[25] = {33{last_channel[25]}} & c25_addr[32:0];
    assign rdaddr_and[26] = {33{last_channel[26]}} & c26_addr[32:0];
    assign rdaddr_and[27] = {33{last_channel[27]}} & c27_addr[32:0];
    assign rdaddr_and[28] = {33{last_channel[28]}} & c28_addr[32:0];
    assign rdaddr_and[29] = {33{last_channel[29]}} & c29_addr[32:0];
    assign rdaddr_and[30] = {33{last_channel[30]}} & c30_addr[32:0];
    assign rdaddr_and[31] = {33{last_channel[31]}} & c31_addr[32:0];    
    
    assign wait_cond = collect_done | rwait;
    
    always @(posedge clk) begin
        if (reset) state <= S_IDLE;
        else state <= next;
    end

    always @(*) begin
        case (state)
            S_IDLE  : next = (istart & ~is_empty)? S_RESET0: S_IDLE;
            S_RESET0: next = S_LOAD0;
            S_LOAD0 : next = S_CALC0;
            S_CALC0 : next = S_START0;
            S_START0: next = S_WAIT0;
            //S_WAIT0 : next = &wait_cond? S_LOAD1: S_WAIT0;
            //S_WAIT0 : next = wait_cond[0]? S_RESET1: S_WAIT0;
            S_WAIT0 : next = &wait_cond? S_LOAD1: S_WAIT0;
            //S_WAIT0: next = S_LOAD1;
            S_RESET1: next = S_LOAD1;
            S_LOAD1 : next = S_CALC1;
            S_CALC1 : next = S_START1;
            S_START1: next = S_WAIT1;
            //S_WAIT1 : next = wait_cond[0]? S_DONE: S_WAIT1;
            S_WAIT1 : next = &wait_cond? S_ADJUST: S_WAIT1;
            S_ADJUST: next = S_DONE;
            S_DONE  : next = S_IDLE;
            default : next = S_IDLE;
        endcase
    end

    always @(posedge clk) begin
        if (reset) r_size_next <= 64'd0;
        else if (iload) r_size_next <= file_size;
        else if (sreset0) begin
            if ((r_size_next[32:16] != 0) | (r_size_next[15] && (r_size_next[14:0] != 0))) begin
                r_size_next[63:34] <= 30'd0;
                r_size_next[33:0] <= r_size_next[33:0] - 34'd31744;
            end
            else r_size_next <= 64'd0;
        end
        
        if (reset) r_file_size <= 64'd0;
        else if (sidle | sdone)
            if (r_size_next[32:15] != 0) r_file_size <= 64'd32768;
            else  r_file_size <= r_size_next;
        
        if (reset) is_empty <= 1'b0;
        else is_empty <= r_size_next[32:0] == 33'd0;
    end
    
    always @(posedge clk) begin
        if (reset) r_start_address <= 64'd0;
        else if (sidle & istart) r_start_address <= rnext_address;
        
        if (sidle) begin
            if (istart) begin
                //r_start_address <= start_address;
                nfull_channel   <= r_file_size[15:10];
                nbytes_nfull_channel <= r_file_size[9:3];
                cnt_up   <= 8'd128 - {1'b0, rnext_address[9:3]};
                cnt_down <= {1'b0, rnext_address[9:3]};
            end
            else begin
                //r_start_address      <= 64'd0;
                nfull_channel        <= 6'd0;
                nbytes_nfull_channel <= 10'd0;
                cnt_up               <= 8'd0;
                cnt_down             <= 8'd0;
            end
        end
    end
    
    always @(posedge clk) begin
        if (swait0 | swait1) collect_done <= collect_done | idone;
        else collect_done <= 32'd0;
    end
    
    always @(posedge clk) begin
        if (scalc0 | scalc1) begin
            rostart[0] <= c0_rdlen != 8'd0;
            rostart[1] <= c1_rdlen != 8'd0;
            rostart[2] <= c2_rdlen != 8'd0;
            rostart[3] <= c3_rdlen != 8'd0;
            rostart[4] <= c4_rdlen != 8'd0;
            rostart[5] <= c5_rdlen != 8'd0;
            rostart[6] <= c6_rdlen != 8'd0;
            rostart[7] <= c7_rdlen != 8'd0;
            rostart[8] <= c8_rdlen != 8'd0;
            rostart[9] <= c9_rdlen != 8'd0;
            rostart[10] <= c10_rdlen != 8'd0;
            rostart[11] <= c11_rdlen != 8'd0;
            rostart[12] <= c12_rdlen != 8'd0;
            rostart[13] <= c13_rdlen != 8'd0;
            rostart[14] <= c14_rdlen != 8'd0;
            rostart[15] <= c15_rdlen != 8'd0;
            rostart[16] <= c16_rdlen != 8'd0;
            rostart[17] <= c17_rdlen != 8'd0;
            rostart[18] <= c18_rdlen != 8'd0;
            rostart[19] <= c19_rdlen != 8'd0;
            rostart[20] <= c20_rdlen != 8'd0;
            rostart[21] <= c21_rdlen != 8'd0;
            rostart[22] <= c22_rdlen != 8'd0;
            rostart[23] <= c23_rdlen != 8'd0;
            rostart[24] <= c24_rdlen != 8'd0;
            rostart[25] <= c25_rdlen != 8'd0;
            rostart[26] <= c26_rdlen != 8'd0;
            rostart[27] <= c27_rdlen != 8'd0;
            rostart[28] <= c28_rdlen != 8'd0;
            rostart[29] <= c29_rdlen != 8'd0;
            rostart[30] <= c30_rdlen != 8'd0;
            rostart[31] <= c31_rdlen != 8'd0;                        
        end
        else rostart <= 32'd0;
    end    
    
    always @(posedge clk) begin
        if (sidle) rwait <= 32'd0;
        else if (sstart0 | sstart1) begin
            rwait <= ~rostart;
        end
    end
    
    always @(posedge clk) begin
        if (sidle) flippled_start <= 32'd0;
        else if (sstart0 | sstart1)
            flippled_start <= ~first_flip + 32'd1;
    end
    
    always @(posedge clk) begin
        if (sload0) begin
            c0_addr <= r_start_address;
            if (nfull_channel == 6'd0)
                c0_rdlen <= (nbytes_nfull_channel > cnt_up)? cnt_up: nbytes_nfull_channel;
            else if (nfull_channel > 6'd0)
                c0_rdlen <= cnt_up;

            c1_addr[32:0] <= {addr_inc[1][4:0], addr_inc0[1]};
            if (nfull_channel == 6'd1)
                c1_rdlen <= (nbytes_nfull_channel > cnt_up)? cnt_up: nbytes_nfull_channel;
            else if (nfull_channel > 6'd1) c1_rdlen <= cnt_up;
            else c1_rdlen <= 8'd0;

            c2_addr[32:0] <= {addr_inc[2][4:0], addr_inc0[2]};
            if (nfull_channel == 6'd2)
                c2_rdlen <= (nbytes_nfull_channel > cnt_up)? cnt_up: nbytes_nfull_channel;
            else if (nfull_channel > 6'd2) c2_rdlen <= cnt_up;
            else c2_rdlen <= 8'd0;

            c3_addr[32:0] <= {addr_inc[3][4:0], addr_inc0[3]};
            if (nfull_channel == 6'd3)
                c3_rdlen <= (nbytes_nfull_channel > cnt_up)? cnt_up: nbytes_nfull_channel;
            else if (nfull_channel > 6'd3) c3_rdlen <= cnt_up;
            else c3_rdlen <= 8'd0;

            c4_addr[32:0] <= {addr_inc[4][4:0], addr_inc0[4]};
            if (nfull_channel == 6'd4)
                c4_rdlen <= (nbytes_nfull_channel > cnt_up)? cnt_up: nbytes_nfull_channel;
            else if (nfull_channel > 6'd4) c4_rdlen <= cnt_up;
            else c4_rdlen <= 8'd0;

            c5_addr[32:0] <= {addr_inc[5][4:0], addr_inc0[5]};
            if (nfull_channel == 6'd5)
                c5_rdlen <= (nbytes_nfull_channel > cnt_up)? cnt_up: nbytes_nfull_channel;
            else if (nfull_channel > 6'd5) c5_rdlen <= cnt_up;
            else c5_rdlen <= 8'd0;

            c6_addr[32:0] <= {addr_inc[6][4:0], addr_inc0[6]};
            if (nfull_channel == 6'd6)
                c6_rdlen <= (nbytes_nfull_channel > cnt_up)? cnt_up: nbytes_nfull_channel;
            else if (nfull_channel > 6'd6) c6_rdlen <= cnt_up;
            else c6_rdlen <= 8'd0;

            c7_addr[32:0] <= {addr_inc[7][4:0], addr_inc0[7]};
            if (nfull_channel == 6'd7)
                c7_rdlen <= (nbytes_nfull_channel > cnt_up)? cnt_up: nbytes_nfull_channel;
            else if (nfull_channel > 6'd7) c7_rdlen <= cnt_up;
            else c7_rdlen <= 8'd0;

            c8_addr[32:0] <= {addr_inc[8][4:0], addr_inc0[8]};
            if (nfull_channel == 6'd8)
                c8_rdlen <= (nbytes_nfull_channel > cnt_up)? cnt_up: nbytes_nfull_channel;
            else if (nfull_channel > 6'd8) c8_rdlen <= cnt_up;
            else c8_rdlen <= 8'd0;

            c9_addr[32:0] <= {addr_inc[9][4:0], addr_inc0[9]};
            if (nfull_channel == 6'd9)
                c9_rdlen <= (nbytes_nfull_channel > cnt_up)? cnt_up: nbytes_nfull_channel;
            else if (nfull_channel > 6'd9) c9_rdlen <= cnt_up;
            else c9_rdlen <= 8'd0;

            c10_addr[32:0] <= {addr_inc[10][4:0], addr_inc0[10]};
            if (nfull_channel == 6'd10)
                c10_rdlen <= (nbytes_nfull_channel > cnt_up)? cnt_up: nbytes_nfull_channel;
            else if (nfull_channel > 6'd10) c10_rdlen <= cnt_up;
            else c10_rdlen <= 8'd0;

            c11_addr[32:0] <= {addr_inc[11][4:0], addr_inc0[11]};
            if (nfull_channel == 6'd11)
                c11_rdlen <= (nbytes_nfull_channel > cnt_up)? cnt_up: nbytes_nfull_channel;
            else if (nfull_channel > 6'd11) c11_rdlen <= cnt_up;
            else c11_rdlen <= 8'd0;

            c12_addr[32:0] <= {addr_inc[12][4:0], addr_inc0[12]};
            if (nfull_channel == 6'd12)
                c12_rdlen <= (nbytes_nfull_channel > cnt_up)? cnt_up: nbytes_nfull_channel;
            else if (nfull_channel > 6'd12) c12_rdlen <= cnt_up;
            else c12_rdlen <= 8'd0;

            c13_addr[32:0] <= {addr_inc[13][4:0], addr_inc0[13]};
            if (nfull_channel == 6'd13)
                c13_rdlen <= (nbytes_nfull_channel > cnt_up)? cnt_up: nbytes_nfull_channel;
            else if (nfull_channel > 6'd13) c13_rdlen <= cnt_up;
            else c13_rdlen <= 8'd0;

            c14_addr[32:0] <= {addr_inc[14][4:0], addr_inc0[14]};
            if (nfull_channel == 6'd14)
                c14_rdlen <= (nbytes_nfull_channel > cnt_up)? cnt_up: nbytes_nfull_channel;
            else if (nfull_channel > 6'd14) c14_rdlen <= cnt_up;
            else c14_rdlen <= 8'd0;

            c15_addr[32:0] <= {addr_inc[15][4:0], addr_inc0[15]};
            if (nfull_channel == 6'd15)
                c15_rdlen <= (nbytes_nfull_channel > cnt_up)? cnt_up: nbytes_nfull_channel;
            else if (nfull_channel > 6'd15) c15_rdlen <= cnt_up;
            else c15_rdlen <= 8'd0;

            c16_addr[32:0] <= {addr_inc[16][4:0], addr_inc0[16]};
            if (nfull_channel == 6'd16)
                c16_rdlen <= (nbytes_nfull_channel > cnt_up)? cnt_up: nbytes_nfull_channel;
            else if (nfull_channel > 6'd16) c16_rdlen <= cnt_up;
            else c16_rdlen <= 8'd0;

            c17_addr[32:0] <= {addr_inc[17][4:0], addr_inc0[17]};
            if (nfull_channel == 6'd17)
                c17_rdlen <= (nbytes_nfull_channel > cnt_up)? cnt_up: nbytes_nfull_channel;
            else if (nfull_channel > 6'd17) c17_rdlen <= cnt_up;
            else c17_rdlen <= 8'd0;

            c18_addr[32:0] <= {addr_inc[18][4:0], addr_inc0[18]};
            if (nfull_channel == 6'd18)
                c18_rdlen <= (nbytes_nfull_channel > cnt_up)? cnt_up: nbytes_nfull_channel;
            else if (nfull_channel > 6'd18) c18_rdlen <= cnt_up;
            else c18_rdlen <= 8'd0;

            c19_addr[32:0] <= {addr_inc[19][4:0], addr_inc0[19]};
            if (nfull_channel == 6'd19)
                c19_rdlen <= (nbytes_nfull_channel > cnt_up)? cnt_up: nbytes_nfull_channel;
            else if (nfull_channel > 6'd19) c19_rdlen <= cnt_up;
            else c19_rdlen <= 8'd0;

            c20_addr[32:0] <= {addr_inc[20][4:0], addr_inc0[20]};
            if (nfull_channel == 6'd20)
                c20_rdlen <= (nbytes_nfull_channel > cnt_up)? cnt_up: nbytes_nfull_channel;
            else if (nfull_channel > 6'd20) c20_rdlen <= cnt_up;
            else c20_rdlen <= 8'd0;

            c21_addr[32:0] <= {addr_inc[21][4:0], addr_inc0[21]};
            if (nfull_channel == 6'd21)
                c21_rdlen <= (nbytes_nfull_channel > cnt_up)? cnt_up: nbytes_nfull_channel;
            else if (nfull_channel > 6'd21) c21_rdlen <= cnt_up;
            else c21_rdlen <= 8'd0;

            c22_addr[32:0] <= {addr_inc[22][4:0], addr_inc0[22]};
            if (nfull_channel == 6'd22)
                c22_rdlen <= (nbytes_nfull_channel > cnt_up)? cnt_up: nbytes_nfull_channel;
            else if (nfull_channel > 6'd22) c22_rdlen <= cnt_up;
            else c22_rdlen <= 8'd0;

            c23_addr[32:0] <= {addr_inc[23][4:0], addr_inc0[23]};
            if (nfull_channel == 6'd23)
                c23_rdlen <= (nbytes_nfull_channel > cnt_up)? cnt_up: nbytes_nfull_channel;
            else if (nfull_channel > 6'd23) c23_rdlen <= cnt_up;
            else c23_rdlen <= 8'd0;

            c24_addr[32:0] <= {addr_inc[24][4:0], addr_inc0[24]};
            if (nfull_channel == 6'd24)
                c24_rdlen <= (nbytes_nfull_channel > cnt_up)? cnt_up: nbytes_nfull_channel;
            else if (nfull_channel > 6'd24) c24_rdlen <= cnt_up;
            else c24_rdlen <= 8'd0;

            c25_addr[32:0] <= {addr_inc[25][4:0], addr_inc0[25]};
            if (nfull_channel == 6'd25)
                c25_rdlen <= (nbytes_nfull_channel > cnt_up)? cnt_up: nbytes_nfull_channel;
            else if (nfull_channel > 6'd25) c25_rdlen <= cnt_up;
            else c25_rdlen <= 8'd0;

            c26_addr[32:0] <= {addr_inc[26][4:0], addr_inc0[26]};
            if (nfull_channel == 6'd26)
                c26_rdlen <= (nbytes_nfull_channel > cnt_up)? cnt_up: nbytes_nfull_channel;
            else if (nfull_channel > 6'd26) c26_rdlen <= cnt_up;
            else c26_rdlen <= 8'd0;

            c27_addr[32:0] <= {addr_inc[27][4:0], addr_inc0[27]};
            if (nfull_channel == 6'd27)
                c27_rdlen <= (nbytes_nfull_channel > cnt_up)? cnt_up: nbytes_nfull_channel;
            else if (nfull_channel > 6'd27) c27_rdlen <= cnt_up;
            else c27_rdlen <= 8'd0;

            c28_addr[32:0] <= {addr_inc[28][4:0], addr_inc0[28]};
            if (nfull_channel == 6'd28)
                c28_rdlen <= (nbytes_nfull_channel > cnt_up)? cnt_up: nbytes_nfull_channel;
            else if (nfull_channel > 6'd28) c28_rdlen <= cnt_up;
            else c28_rdlen <= 8'd0;

            c29_addr[32:0] <= {addr_inc[29][4:0], addr_inc0[29]};
            if (nfull_channel == 6'd29)
                c29_rdlen <= (nbytes_nfull_channel > cnt_up)? cnt_up: nbytes_nfull_channel;
            else if (nfull_channel > 6'd29) c29_rdlen <= cnt_up;
            else c29_rdlen <= 8'd0;

            c30_addr[32:0] <= {addr_inc[30][4:0], addr_inc0[30]};
            if (nfull_channel == 6'd30)
                c30_rdlen <= (nbytes_nfull_channel > cnt_up)? cnt_up: nbytes_nfull_channel;
            else if (nfull_channel > 6'd30) c30_rdlen <= cnt_up;
            else c30_rdlen <= 8'd0;

            c31_addr[32:0] <= {addr_inc[31][4:0], addr_inc0[31]};
            if (nfull_channel == 6'd31)
                c31_rdlen <= (nbytes_nfull_channel > cnt_up)? cnt_up: nbytes_nfull_channel;
            else if (nfull_channel > 6'd31) c31_rdlen <= cnt_up;
            else c31_rdlen <= 8'd0;
        end
        else if (sload1) begin
            c0_addr[32:0] <= {addr_inc[1][4:0], addr_inc1[1] };
            if (nfull_channel == 6'd0)
                c0_rdlen <= (nbytes_nfull_channel > cnt_up)? nbytes_nfull_channel - cnt_up: 8'd0;
            else if (nfull_channel > 6'd0) c0_rdlen <= cnt_down;
            else c0_rdlen <= 8'd0;

            c1_addr[32:0] <= {addr_inc[2][4:0], addr_inc1[2] };
            if (nfull_channel == 6'd1)
                c1_rdlen <= (nbytes_nfull_channel > cnt_up)? nbytes_nfull_channel - cnt_up: 8'd0;
            else if (nfull_channel > 6'd1) c1_rdlen <= cnt_down;
            else c1_rdlen <= 8'd0;

            c2_addr[32:0] <= {addr_inc[3][4:0], addr_inc1[3] };
            if (nfull_channel == 6'd2)
                c2_rdlen <= (nbytes_nfull_channel > cnt_up)? nbytes_nfull_channel - cnt_up: 8'd0;
            else if (nfull_channel > 6'd2) c2_rdlen <= cnt_down;
            else c2_rdlen <= 8'd0;

            c3_addr[32:0] <= {addr_inc[4][4:0], addr_inc1[4] };
            if (nfull_channel == 6'd3)
                c3_rdlen <= (nbytes_nfull_channel > cnt_up)? nbytes_nfull_channel - cnt_up: 8'd0;
            else if (nfull_channel > 6'd3) c3_rdlen <= cnt_down;
            else c3_rdlen <= 8'd0;

            c4_addr[32:0] <= {addr_inc[5][4:0], addr_inc1[5] };
            if (nfull_channel == 6'd4)
                c4_rdlen <= (nbytes_nfull_channel > cnt_up)? nbytes_nfull_channel - cnt_up: 8'd0;
            else if (nfull_channel > 6'd4) c4_rdlen <= cnt_down;
            else c4_rdlen <= 8'd0;

            c5_addr[32:0] <= {addr_inc[6][4:0], addr_inc1[6] };
            if (nfull_channel == 6'd5)
                c5_rdlen <= (nbytes_nfull_channel > cnt_up)? nbytes_nfull_channel - cnt_up: 8'd0;
            else if (nfull_channel > 6'd5) c5_rdlen <= cnt_down;
            else c5_rdlen <= 8'd0;

            c6_addr[32:0] <= {addr_inc[7][4:0], addr_inc1[7] };
            if (nfull_channel == 6'd6)
                c6_rdlen <= (nbytes_nfull_channel > cnt_up)? nbytes_nfull_channel - cnt_up: 8'd0;
            else if (nfull_channel > 6'd6) c6_rdlen <= cnt_down;
            else c6_rdlen <= 8'd0;

            c7_addr[32:0] <= {addr_inc[8][4:0], addr_inc1[8] };
            if (nfull_channel == 6'd7)
                c7_rdlen <= (nbytes_nfull_channel > cnt_up)? nbytes_nfull_channel - cnt_up: 8'd0;
            else if (nfull_channel > 6'd7) c7_rdlen <= cnt_down;
            else c7_rdlen <= 8'd0;

            c8_addr[32:0] <= {addr_inc[9][4:0], addr_inc1[9] };
            if (nfull_channel == 6'd8)
                c8_rdlen <= (nbytes_nfull_channel > cnt_up)? nbytes_nfull_channel - cnt_up: 8'd0;
            else if (nfull_channel > 6'd8) c8_rdlen <= cnt_down;
            else c8_rdlen <= 8'd0;

            c9_addr[32:0] <= {addr_inc[10][4:0], addr_inc1[10] };
            if (nfull_channel == 6'd9)
                c9_rdlen <= (nbytes_nfull_channel > cnt_up)? nbytes_nfull_channel - cnt_up: 8'd0;
            else if (nfull_channel > 6'd9) c9_rdlen <= cnt_down;
            else c9_rdlen <= 8'd0;

            c10_addr[32:0] <= {addr_inc[11][4:0], addr_inc1[11] };
            if (nfull_channel == 6'd10)
                c10_rdlen <= (nbytes_nfull_channel > cnt_up)? nbytes_nfull_channel - cnt_up: 8'd0;
            else if (nfull_channel > 6'd10) c10_rdlen <= cnt_down;
            else c10_rdlen <= 8'd0;

            c11_addr[32:0] <= {addr_inc[12][4:0], addr_inc1[12] };
            if (nfull_channel == 6'd11)
                c11_rdlen <= (nbytes_nfull_channel > cnt_up)? nbytes_nfull_channel - cnt_up: 8'd0;
            else if (nfull_channel > 6'd11) c11_rdlen <= cnt_down;
            else c11_rdlen <= 8'd0;

            c12_addr[32:0] <= {addr_inc[13][4:0], addr_inc1[13] };
            if (nfull_channel == 6'd12)
                c12_rdlen <= (nbytes_nfull_channel > cnt_up)? nbytes_nfull_channel - cnt_up: 8'd0;
            else if (nfull_channel > 6'd12) c12_rdlen <= cnt_down;
            else c12_rdlen <= 8'd0;

            c13_addr[32:0] <= {addr_inc[14][4:0], addr_inc1[14] };
            if (nfull_channel == 6'd13)
                c13_rdlen <= (nbytes_nfull_channel > cnt_up)? nbytes_nfull_channel - cnt_up: 8'd0;
            else if (nfull_channel > 6'd13) c13_rdlen <= cnt_down;
            else c13_rdlen <= 8'd0;

            c14_addr[32:0] <= {addr_inc[15][4:0], addr_inc1[15] };
            if (nfull_channel == 6'd14)
                c14_rdlen <= (nbytes_nfull_channel > cnt_up)? nbytes_nfull_channel - cnt_up: 8'd0;
            else if (nfull_channel > 6'd14) c14_rdlen <= cnt_down;
            else c14_rdlen <= 8'd0;

            c15_addr[32:0] <= {addr_inc[16][4:0], addr_inc1[16] };
            if (nfull_channel == 6'd15)
                c15_rdlen <= (nbytes_nfull_channel > cnt_up)? nbytes_nfull_channel - cnt_up: 8'd0;
            else if (nfull_channel > 6'd15) c15_rdlen <= cnt_down;
            else c15_rdlen <= 8'd0;

            c16_addr[32:0] <= {addr_inc[17][4:0], addr_inc1[17] };
            if (nfull_channel == 6'd16)
                c16_rdlen <= (nbytes_nfull_channel > cnt_up)? nbytes_nfull_channel - cnt_up: 8'd0;
            else if (nfull_channel > 6'd16) c16_rdlen <= cnt_down;
            else c16_rdlen <= 8'd0;

            c17_addr[32:0] <= {addr_inc[18][4:0], addr_inc1[18] };
            if (nfull_channel == 6'd17)
                c17_rdlen <= (nbytes_nfull_channel > cnt_up)? nbytes_nfull_channel - cnt_up: 8'd0;
            else if (nfull_channel > 6'd17) c17_rdlen <= cnt_down;
            else c17_rdlen <= 8'd0;

            c18_addr[32:0] <= {addr_inc[19][4:0], addr_inc1[19] };
            if (nfull_channel == 6'd18)
                c18_rdlen <= (nbytes_nfull_channel > cnt_up)? nbytes_nfull_channel - cnt_up: 8'd0;
            else if (nfull_channel > 6'd18) c18_rdlen <= cnt_down;
            else c18_rdlen <= 8'd0;

            c19_addr[32:0] <= {addr_inc[20][4:0], addr_inc1[20] };
            if (nfull_channel == 6'd19)
                c19_rdlen <= (nbytes_nfull_channel > cnt_up)? nbytes_nfull_channel - cnt_up: 8'd0;
            else if (nfull_channel > 6'd19) c19_rdlen <= cnt_down;
            else c19_rdlen <= 8'd0;

            c20_addr[32:0] <= {addr_inc[21][4:0], addr_inc1[21] };
            if (nfull_channel == 6'd20)
                c20_rdlen <= (nbytes_nfull_channel > cnt_up)? nbytes_nfull_channel - cnt_up: 8'd0;
            else if (nfull_channel > 6'd20) c20_rdlen <= cnt_down;
            else c20_rdlen <= 8'd0;

            c21_addr[32:0] <= {addr_inc[22][4:0], addr_inc1[22] };
            if (nfull_channel == 6'd21)
                c21_rdlen <= (nbytes_nfull_channel > cnt_up)? nbytes_nfull_channel - cnt_up: 8'd0;
            else if (nfull_channel > 6'd21) c21_rdlen <= cnt_down;
            else c21_rdlen <= 8'd0;

            c22_addr[32:0] <= {addr_inc[23][4:0], addr_inc1[23] };
            if (nfull_channel == 6'd22)
                c22_rdlen <= (nbytes_nfull_channel > cnt_up)? nbytes_nfull_channel - cnt_up: 8'd0;
            else if (nfull_channel > 6'd22) c22_rdlen <= cnt_down;
            else c22_rdlen <= 8'd0;

            c23_addr[32:0] <= {addr_inc[24][4:0], addr_inc1[24] };
            if (nfull_channel == 6'd23)
                c23_rdlen <= (nbytes_nfull_channel > cnt_up)? nbytes_nfull_channel - cnt_up: 8'd0;
            else if (nfull_channel > 6'd23) c23_rdlen <= cnt_down;
            else c23_rdlen <= 8'd0;

            c24_addr[32:0] <= {addr_inc[25][4:0], addr_inc1[25] };
            if (nfull_channel == 6'd24)
                c24_rdlen <= (nbytes_nfull_channel > cnt_up)? nbytes_nfull_channel - cnt_up: 8'd0;
            else if (nfull_channel > 6'd24) c24_rdlen <= cnt_down;
            else c24_rdlen <= 8'd0;

            c25_addr[32:0] <= {addr_inc[26][4:0], addr_inc1[26] };
            if (nfull_channel == 6'd25)
                c25_rdlen <= (nbytes_nfull_channel > cnt_up)? nbytes_nfull_channel - cnt_up: 8'd0;
            else if (nfull_channel > 6'd25) c25_rdlen <= cnt_down;
            else c25_rdlen <= 8'd0;

            c26_addr[32:0] <= {addr_inc[27][4:0], addr_inc1[27] };
            if (nfull_channel == 6'd26)
                c26_rdlen <= (nbytes_nfull_channel > cnt_up)? nbytes_nfull_channel - cnt_up: 8'd0;
            else if (nfull_channel > 6'd26) c26_rdlen <= cnt_down;
            else c26_rdlen <= 8'd0;

            c27_addr[32:0] <= {addr_inc[28][4:0], addr_inc1[28] };
            if (nfull_channel == 6'd27)
                c27_rdlen <= (nbytes_nfull_channel > cnt_up)? nbytes_nfull_channel - cnt_up: 8'd0;
            else if (nfull_channel > 6'd27) c27_rdlen <= cnt_down;
            else c27_rdlen <= 8'd0;

            c28_addr[32:0] <= {addr_inc[29][4:0], addr_inc1[29] };
            if (nfull_channel == 6'd28)
                c28_rdlen <= (nbytes_nfull_channel > cnt_up)? nbytes_nfull_channel - cnt_up: 8'd0;
            else if (nfull_channel > 6'd28) c28_rdlen <= cnt_down;
            else c28_rdlen <= 8'd0;

            c29_addr[32:0] <= {addr_inc[30][4:0], addr_inc1[30] };
            if (nfull_channel == 6'd29)
                c29_rdlen <= (nbytes_nfull_channel > cnt_up)? nbytes_nfull_channel - cnt_up: 8'd0;
            else if (nfull_channel > 6'd29) c29_rdlen <= cnt_down;
            else c29_rdlen <= 8'd0;

            c30_addr[32:0] <= {addr_inc[31][4:0], addr_inc1[31] };
            if (nfull_channel == 6'd30)
                c30_rdlen <= (nbytes_nfull_channel > cnt_up)? nbytes_nfull_channel - cnt_up: 8'd0;
            else if (nfull_channel > 6'd30) c30_rdlen <= cnt_down;
            else c30_rdlen <= 8'd0;

            c31_addr[32:0] <= {addr_inc[0][4:0], addr_inc1[0] };
            if (nfull_channel == 6'd31)
                c31_rdlen <= (nbytes_nfull_channel > cnt_up)? nbytes_nfull_channel - cnt_up: 8'd0;
            else if (nfull_channel > 6'd31) c31_rdlen <= cnt_down;
            else c31_rdlen <= 8'd0;

        end
    end

    always @(posedge clk) begin
        if (sidle) rdlen_sel <= 8'd0;
        else if (swait0 | scalc1)
            rdlen_sel <= rdlen_and[0] | rdlen_and[1] | rdlen_and[2] | rdlen_and[3] |
                        rdlen_and[4] | rdlen_and[5] | rdlen_and[6] | rdlen_and[7] |
                        rdlen_and[8] | rdlen_and[9] | rdlen_and[10] | rdlen_and[11] |
                        rdlen_and[12] | rdlen_and[13] | rdlen_and[14] | rdlen_and[15] |
                        rdlen_and[16] | rdlen_and[17] | rdlen_and[18] | rdlen_and[19] |
                        rdlen_and[20] | rdlen_and[21] | rdlen_and[22] | rdlen_and[23] |
                        rdlen_and[24] | rdlen_and[25] | rdlen_and[26] | rdlen_and[27] |
                        rdlen_and[28] | rdlen_and[29] | rdlen_and[30] | rdlen_and[31];               
    end
    
    always @(posedge clk) begin
        if (sidle) rdaddr_sel <= 33'd0;
        else if (swait0 | scalc1)
            rdaddr_sel <= rdaddr_and[0] | rdaddr_and[1] | rdaddr_and[2] | rdaddr_and[3] |
                        rdaddr_and[4] | rdaddr_and[5] | rdaddr_and[6] | rdaddr_and[7] |
                        rdaddr_and[8] | rdaddr_and[9] | rdaddr_and[10] | rdaddr_and[11] |
                        rdaddr_and[12] | rdaddr_and[13] | rdaddr_and[14] | rdaddr_and[15] |
                        rdaddr_and[16] | rdaddr_and[17] | rdaddr_and[18] | rdaddr_and[19] |
                        rdaddr_and[20] | rdaddr_and[21] | rdaddr_and[22] | rdaddr_and[23] |
                        rdaddr_and[24] | rdaddr_and[25] | rdaddr_and[26] | rdaddr_and[27] |
                        rdaddr_and[28] | rdaddr_and[29] | rdaddr_and[30] | rdaddr_and[31];               
    end
    
    assign wnext_address = rdaddr_sel + {rdlen_sel, 3'd0};
    
    always @(posedge clk) begin
        if (reset) rnext_address <= 64'd0;
        else if (iload_address) rnext_address <= start_address;
        else if (sload1 | sadjust) begin
            if (rdlen_sel != 8'd0) begin
                if (wnext_address[27:10] == rdaddr_sel[27:10]) rnext_address <= wnext_address;
                else begin
                    rnext_address[32:28] <= wnext_address[32:28] + 1'b1;
                    rnext_address[27:10] <= (wnext_address[32:28] == 5'h1f)? wnext_address[27:10]: rdaddr_sel[27:10];
                    rnext_address[9:0]   <= 10'd0;
                end
            end
        end
        else if (sdone && r_file_size[15] && (r_size_next != 0)) begin
             rnext_address[32:28] <= (rnext_address[32:28] == 5'h00)? 5'hff: rnext_address[32:28] - 5'd1;
             rnext_address[27:0] <= (rnext_address[32:28] == 5'h00)? rnext_address[27:0] - 28'h400: rnext_address[27:0];
             //rnext_address[9:0] <= rnext_address[9:0];
        end
    end
    
    always @(posedge clk) begin
        if ((sidle & istart) | reset) roverlap <= 1'b0;
        else if (last_channel[31] && r_file_size[15] && (r_size_next != 0)) roverlap <= 1'b1;
    end
    
    always @(posedge clk) begin
        if (reset | iload) rbashcount <= 32'd0;
        else if (sdone) rbashcount <= rbashcount + 1'b1;
        
        if (reset | iload) rbashoffset <= 64'd0;
        else if (sdone) rbashoffset <= rbashoffset + 64'd31744;
    end
    
    always @(posedge clk) begin
        if (sadjust) rbash_update <= 1'b1;
        else rbash_update <= 1'b0;
    end
    
    always @(posedge clk) 
        if (reset) rstart <= 2'b00;
        else rstart <= {rstart[0], istart};
    
    assign overlap = roverlap;
    assign ostart = rostart;
    assign ready = sidle;
    assign odone  = sdone | (sidle && rstart[1] && is_empty);
    
    assign oc0_addr = c0_addr;
    assign oc1_addr = c1_addr;
    assign oc2_addr = c2_addr;
    assign oc3_addr = c3_addr;
    assign oc4_addr = c4_addr;
    assign oc5_addr = c5_addr;
    assign oc6_addr = c6_addr;
    assign oc7_addr = c7_addr;
    assign oc8_addr = c8_addr;
    assign oc9_addr = c9_addr;
    assign oc10_addr = c10_addr;
    assign oc11_addr = c11_addr;
    assign oc12_addr = c12_addr;
    assign oc13_addr = c13_addr;
    assign oc14_addr = c14_addr;
    assign oc15_addr = c15_addr;
    assign oc16_addr = c16_addr;
    assign oc17_addr = c17_addr;
    assign oc18_addr = c18_addr;
    assign oc19_addr = c19_addr;
    assign oc20_addr = c20_addr;
    assign oc21_addr = c21_addr;
    assign oc22_addr = c22_addr;
    assign oc23_addr = c23_addr;
    assign oc24_addr = c24_addr;
    assign oc25_addr = c25_addr;
    assign oc26_addr = c26_addr;
    assign oc27_addr = c27_addr;
    assign oc28_addr = c28_addr;
    assign oc29_addr = c29_addr;
    assign oc30_addr = c30_addr;
    assign oc31_addr = c31_addr;
    
    assign oc0_rdlen = {24'd0, c0_rdlen};
    assign oc1_rdlen = {24'd0, c1_rdlen};
    assign oc2_rdlen = {24'd0, c2_rdlen};
    assign oc3_rdlen = {24'd0, c3_rdlen};
    assign oc4_rdlen = {24'd0, c4_rdlen};
    assign oc5_rdlen = {24'd0, c5_rdlen};
    assign oc6_rdlen = {24'd0, c6_rdlen};
    assign oc7_rdlen = {24'd0, c7_rdlen};
    assign oc8_rdlen = {24'd0, c8_rdlen};
    assign oc9_rdlen = {24'd0, c9_rdlen};
    assign oc10_rdlen = {24'd0, c10_rdlen};
    assign oc11_rdlen = {24'd0, c11_rdlen};
    assign oc12_rdlen = {24'd0, c12_rdlen};
    assign oc13_rdlen = {24'd0, c13_rdlen};
    assign oc14_rdlen = {24'd0, c14_rdlen};
    assign oc15_rdlen = {24'd0, c15_rdlen};
    assign oc16_rdlen = {24'd0, c16_rdlen};
    assign oc17_rdlen = {24'd0, c17_rdlen};
    assign oc18_rdlen = {24'd0, c18_rdlen};
    assign oc19_rdlen = {24'd0, c19_rdlen};
    assign oc20_rdlen = {24'd0, c20_rdlen};
    assign oc21_rdlen = {24'd0, c21_rdlen};
    assign oc22_rdlen = {24'd0, c22_rdlen};
    assign oc23_rdlen = {24'd0, c23_rdlen};
    assign oc24_rdlen = {24'd0, c24_rdlen};
    assign oc25_rdlen = {24'd0, c25_rdlen};
    assign oc26_rdlen = {24'd0, c26_rdlen};
    assign oc27_rdlen = {24'd0, c27_rdlen};
    assign oc28_rdlen = {24'd0, c28_rdlen};
    assign oc29_rdlen = {24'd0, c29_rdlen};
    assign oc30_rdlen = {24'd0, c30_rdlen};
    assign oc31_rdlen = {24'd0, c31_rdlen};   
    
    assign oreset = sreset0 | sreset1;
    assign ofilesize = r_size_next;
    assign onext_addr = rnext_address;
    
    assign bash_offset = rbashoffset;
    assign bash_count = rbashcount;
    assign bash_update = rbash_update;
    
endmodule
