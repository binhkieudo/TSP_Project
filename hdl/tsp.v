`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/21/2022 03:55:27 PM
// Design Name: 
// Module Name: mytsp
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


module tsp(
    clk,
    reset,
    reset_text,
    byte_mode,
    start,
    overlap,
    begin_gap,
    end_gap,
    last_byte,
    mask,
    key,
    key_length,
    // 32 channels 64-bits (update text)
    text_wdata,
    text_we,
    // Extend ports
    r0_lin,
    r1_lin,
    r2_lin,
    r0_out,
    r1_out,
    r2_out,
    // Read result port
    bash_offset,
    read_enable,
    odata,
    odatavalid,
    tsp_full,
    tsp_empty,
    match_count,
    match_count_valid,
    // Read bit stream
    bitstream_rden,
    bitstream_rdata
);

    parameter N_PACKS = 4096;
    parameter N_PE = 32768;
    parameter LOG2_NPE = 15;
    parameter BLOCK64 = N_PE / 64;
    parameter N_PE24 = 1365;
    parameter N_PE8  = 1;
    parameter N_BITS = N_PE * 8;

    parameter HBM_PC  = 32;
    parameter HBM_PCWIDTH = 64;

    parameter PACKS_PER_CHANNEL = N_PACKS /  HBM_PC;
    parameter PE_PER_CHANNEL =  1024; // 1024
    parameter BLOCK64_PER_CHANNEL = PE_PER_CHANNEL / 8;

    parameter MODE_1B = 2'b00,
    MODE_2B = 2'b01,
    MODE_3B = 2'b10,
    MODE_4B = 2'b11;

    input clk;
    input reset;
    input reset_text;

    input [1:0]byte_mode;
    input start;
    input overlap;
    input begin_gap;
    input end_gap;
    input last_byte;
    input mask;
    input [7:0]key;
    input [8:0]key_length;

    // 32 channels 64-bits (update text)
    input [2047:0]text_wdata;
    input [HBM_PC - 1:0]text_we;

    // Extend ports
    input r0_lin;
    input r1_lin;
    input r2_lin;
    output r0_out;
    output r1_out;
    output r2_out;

    // Read result port
    output [31:0]bash_offset;
    input read_enable;
    output [15:0]odata;
    output odatavalid;
    output tsp_full;
    output tsp_empty;

    output [LOG2_NPE - 1 : 0]match_count;
    output match_count_valid;

    input bitstream_rden;
    output [63:0]bitstream_rdata;

    wire [15:0]wodata;
    wire wodatavalid;
    wire wfull;
    wire wempty;

    reg rrun;
    reg rstart;
    reg rbegin_gap;
    reg rend_gap;
    reg rlast_key;
    reg rgap;
    reg rmask;
    reg [1:0]rbyte_mode;
    reg [9:0]rkey;
    reg [5:0]rkey_length;
    reg rupdate;
    wire [11:0]ctrl_enable = 12'hfff;
    reg [31:0]rbash_offset;

    reg [PE_PER_CHANNEL*8 - 1:0]rtext0 = 8192'd0;
    reg [PE_PER_CHANNEL*8 - 1:0]rtext1 = 8192'd0;
    reg [PE_PER_CHANNEL*8 - 1:0]rtext2 = 8192'd0;
    reg [PE_PER_CHANNEL*8 - 1:0]rtext3 = 8192'd0;
    reg [PE_PER_CHANNEL*8 - 1:0]rtext4 = 8192'd0;
    reg [PE_PER_CHANNEL*8 - 1:0]rtext5 = 8192'd0;
    reg [PE_PER_CHANNEL*8 - 1:0]rtext6 = 8192'd0;
    reg [PE_PER_CHANNEL*8 - 1:0]rtext7 = 8192'd0;
    reg [PE_PER_CHANNEL*8 - 1:0]rtext8 = 8192'd0;
    reg [PE_PER_CHANNEL*8 - 1:0]rtext9 = 8192'd0;
    reg [PE_PER_CHANNEL*8 - 1:0]rtext10 = 8192'd0;
    reg [PE_PER_CHANNEL*8 - 1:0]rtext11 = 8192'd0;
    reg [PE_PER_CHANNEL*8 - 1:0]rtext12 = 8192'd0;
    reg [PE_PER_CHANNEL*8 - 1:0]rtext13 = 8192'd0;
    reg [PE_PER_CHANNEL*8 - 1:0]rtext14 = 8192'd0;
    reg [PE_PER_CHANNEL*8 - 1:0]rtext15 = 8192'd0;
    reg [PE_PER_CHANNEL*8 - 1:0]rtext16 = 8192'd0;
    reg [PE_PER_CHANNEL*8 - 1:0]rtext17 = 8192'd0;
    reg [PE_PER_CHANNEL*8 - 1:0]rtext18 = 8192'd0;
    reg [PE_PER_CHANNEL*8 - 1:0]rtext19 = 8192'd0;
    reg [PE_PER_CHANNEL*8 - 1:0]rtext20 = 8192'd0;
    reg [PE_PER_CHANNEL*8 - 1:0]rtext21 = 8192'd0;
    reg [PE_PER_CHANNEL*8 - 1:0]rtext22 = 8192'd0;
    reg [PE_PER_CHANNEL*8 - 1:0]rtext23 = 8192'd0;
    reg [PE_PER_CHANNEL*8 - 1:0]rtext24 = 8192'd0;
    reg [PE_PER_CHANNEL*8 - 1:0]rtext25 = 8192'd0;
    reg [PE_PER_CHANNEL*8 - 1:0]rtext26 = 8192'd0;
    reg [PE_PER_CHANNEL*8 - 1:0]rtext27 = 8192'd0;
    reg [PE_PER_CHANNEL*8 - 1:0]rtext28 = 8192'd0;
    reg [PE_PER_CHANNEL*8 - 1:0]rtext29 = 8192'd0;
    reg [PE_PER_CHANNEL*8 - 1:0]rtext30 = 8192'd0;
    reg [PE_PER_CHANNEL*8 - 1:0]rtext31 = 8192'd0;
    wire [N_BITS-1:0]wtextin = {rtext31, rtext30,
    rtext29, rtext28, rtext27, rtext26, rtext25, rtext24, rtext23, rtext22, rtext21, rtext20,
    rtext19, rtext18, rtext17, rtext16, rtext15, rtext14, rtext13, rtext12, rtext11, rtext10,
    rtext9, rtext8, rtext7, rtext6, rtext5, rtext4, rtext3, rtext2, rtext1, rtext0};
    reg [N_PACKS*8-1:0]rwin;
    reg [N_PACKS*8-1:0]rwin2;
    reg start_decoder;

    reg [23:0]byte_offset;

    wire [N_PACKS*8-1:0]win_wout;

    wire [N_PE24 + N_PE8 - 1:0]r0_wout;
    wire [N_PE24 + N_PE8 - 1:0]r1_wout;
    wire [N_PE24 + N_PE8 - 1:0]r2_wout;

    wire [N_PE24 + N_PE8 - 1:0]r0_wlin;
    wire [N_PE24 + N_PE8 - 1:0]r1_wlin;
    wire [N_PE24 + N_PE8 - 1:0]r2_wlin;


    wire [15:0]waddr[0:BLOCK64-1];
    wire [BLOCK64-1:0]wdecode_fin;
    wire [BLOCK64-1:0]waddress_valid;

    wire tsp_idle;
    wire [N_PE-1:0]woverlap;

    assign r0_wlin[N_PE24 - 1:0] = {r0_wout[N_PE24-2:0] ,r0_lin};
    assign r1_wlin[N_PE24 - 1:0] = {r1_wout[N_PE24-2:0] ,r1_lin};
    assign r2_wlin[N_PE24 - 1:0] = {r2_wout[N_PE24-2:0] ,r2_lin};

    assign r0_wlin[N_PE24] = r0_wout[N_PE24-1];
    assign r1_wlin[N_PE24] = r1_wout[N_PE24-1];
    assign r2_wlin[N_PE24] = r2_wout[N_PE24-1];

    assign woverlap = {{1024{overlap}}, {31744{1'b0}}};

    always @(posedge clk) begin
        if (reset) begin
            rstart <= 1'b0;
            rbegin_gap <= 1'b0;
            rend_gap <= 1'b0;
            rlast_key <= 1'b0;
            rgap <= 1'b0;
            rmask = 1'b0;
            //ctrl_enable <= 12'h000;
            rbyte_mode <= 2'b00;
            rrun <= 1'b0;
        end
        else begin
            rstart <= start;
            rbegin_gap <= begin_gap;
            rend_gap <= end_gap;
            rlast_key <= last_byte;
            rgap <= begin_gap? 1'b1: rend_gap? 1'b0: rgap;
            rmask <= mask;
            
        end

        if (start) begin
            if (byte_mode == 2'b00) begin
                rkey <= {2'b11, key};
                rbyte_mode <= 2'b00;
            end
            else begin
                rkey <= {2'b01, key};
                rbyte_mode <= byte_mode - 2'd1;
            end
            rrun <= 1'b1;
        end
        else if (last_byte) begin
            if (byte_mode == 2'b00) rkey <= {2'b11, key};
            else rkey <= {2'b10, key};
            rrun <= 1'b0;
        end
        else if (rrun) begin
            if (byte_mode == 2'b00) begin
                rkey <= {2'b11, key};
                rbyte_mode <= 2'b00;
            end
            else begin
                if (rbyte_mode == 2'b00) rbyte_mode <= byte_mode;
                else rbyte_mode <= rbyte_mode - 2'd1;
                rkey <= { rbyte_mode == 2'b00, rbyte_mode == byte_mode, key};
            end
        end

        rupdate <= rlast_key;
    end

    integer index = 0;
    always @(posedge clk) begin
        if (text_we[0]) rtext0 <= {text_wdata[63:0], rtext0[8191:64]};

        if (text_we[1]) rtext1 <= {text_wdata[127:64], rtext1[8191:64]};

        if (text_we[2]) rtext2 <= {text_wdata[191:128], rtext2[8191:64]};

        //if (reset | reset_text) rtext3 <= 8192'd0;
        if (text_we[3]) rtext3 <= {text_wdata[255:192], rtext3[8191:64]};

        //if (reset | reset_text) rtext4 <= 8192'd0;
        if (text_we[4]) rtext4 <= {text_wdata[319:256], rtext4[8191:64]};

        //if (reset | reset_text) rtext5 <= 8192'd0;
        if (text_we[5]) rtext5 <= {text_wdata[383:320], rtext5[8191:64]};

        //if (reset | reset_text) rtext6 <= 8192'd0;
        if (text_we[6]) rtext6 <= {text_wdata[447:384], rtext6[8191:64]};

        //if (reset | reset_text) rtext7 <= 8192'd0;
        if (text_we[7]) rtext7 <= {text_wdata[511:448], rtext7[8191:64]};

        //if (reset | reset_text) rtext8 <= 8192'd0;
        if (text_we[8]) rtext8 <= {text_wdata[575:512], rtext8[8191:64]};

        //if (reset | reset_text) rtext9 <= 8192'd0;
        if (text_we[9]) rtext9 <= {text_wdata[639:576], rtext9[8191:64]};

        //if (reset | reset_text) rtext10 <= 8192'd0;
        if (text_we[10]) rtext10 <= {text_wdata[703:640], rtext10[8191:64]};

        //if (reset | reset_text) rtext11 <= 8192'd0;
        if (text_we[11]) rtext11 <= {text_wdata[767:704], rtext11[8191:64]};

        //if (reset | reset_text) rtext12 <= 8192'd0;
        if (text_we[12]) rtext12 <= {text_wdata[831:768], rtext12[8191:64]};

        //if (reset | reset_text) rtext13 <= 8192'd0;
        if (text_we[13]) rtext13 <= {text_wdata[895:832], rtext13[8191:64]};

        //if (reset | reset_text) rtext14 <= 8192'd0;
        if (text_we[14]) rtext14 <= {text_wdata[959:896], rtext14[8191:64]};

        //if (reset | reset_text) rtext15 <= 8192'd0;
        if (text_we[15]) rtext15 <= {text_wdata[1023:960], rtext15[8191:64]};

        //if (reset | reset_text) rtext16 <= 8192'd0;
        if (text_we[16]) rtext16 <= {text_wdata[1087:1024], rtext16[8191:64]};

        //if (reset | reset_text) rtext17 <= 8192'd0;
        if (text_we[17]) rtext17 <= {text_wdata[1151:1088], rtext17[8191:64]};

        //if (reset | reset_text) rtext18 <= 8192'd0;
        if (text_we[18]) rtext18 <= {text_wdata[1215:1152], rtext18[8191:64]};

        //if (reset | reset_text) rtext19 <= 8192'd0;
        if (text_we[19]) rtext19 <= {text_wdata[1279:1216], rtext19[8191:64]};

        //if (reset | reset_text) rtext20 <= 8192'd0;
        if (text_we[20]) rtext20 <= {text_wdata[1343:1280], rtext20[8191:64]};

        //if (reset | reset_text) rtext21 <= 8192'd0;
        if (text_we[21]) rtext21 <= {text_wdata[1407:1344], rtext21[8191:64]};

        //if (reset | reset_text) rtext22 <= 8192'd0;
        if (text_we[22]) rtext22 <= {text_wdata[1471:1408], rtext22[8191:64]};

        //if (reset | reset_text) rtext23 <= 8192'd0;
        if (text_we[23]) rtext23 <= {text_wdata[1535:1472], rtext23[8191:64]};

        //if (reset | reset_text) rtext24 <= 8192'd0;
        if (text_we[24]) rtext24 <= {text_wdata[1599:1536], rtext24[8191:64]};

        //if (reset | reset_text) rtext25 <= 8192'd0;
        if (text_we[25]) rtext25 <= {text_wdata[1663:1600], rtext25[8191:64]};

        //if (reset | reset_text) rtext26 <= 8192'd0;
        if (text_we[26]) rtext26 <= {text_wdata[1727:1664], rtext26[8191:64]};

        //if (reset | reset_text) rtext27 <= 8192'd0;
        if (text_we[27]) rtext27 <= {text_wdata[1791:1728], rtext27[8191:64]};

        //if (reset | reset_text) rtext28 <= 8192'd0;
        if (text_we[28]) rtext28 <= {text_wdata[1855:1792], rtext28[8191:64]};

        //if (reset | reset_text) rtext29 <= 8192'd0;
        if (text_we[29]) rtext29 <= {text_wdata[1919:1856], rtext29[8191:64]};

        //if (reset | reset_text) rtext30 <= 8192'd0;
        if (text_we[30]) rtext30 <= {text_wdata[1983:1920], rtext30[8191:64]};

        //if (reset | reset_text) rtext31 <= 8192'd0;
        if (text_we[31]) rtext31 <= {text_wdata[2047:1984], rtext31[8191:64]};
    end

    genvar i;
    generate
        for (i = 0; i < N_PE24; i = i + 1) begin: gen_pe
            pe24 inst(
                .clk(clk),
                .reset(reset | start),
                .firstmatch(rstart),
                .is_firstgap(rbegin_gap),
                .ctrl({ctrl_enable, ctrl_enable}),
                .overlap(woverlap[(i+1)*24 - 1 -: 24]),
                .is_gap(rgap),
                .is_mask(rmask),
                .r0_lin(r0_wlin[i]),
                .r1_lin(r1_wlin[i]),
                .r2_lin(r2_wlin[i]),
                .key(rkey),
                .text(wtextin[(i+1)*192 - 1 -: 192]),
                .win_out(win_wout[(i+1)*24 - 1 -: 24]),
                .r0_out(r0_wout[i]),
                .r1_out(r1_wout[i]),
                .r2_out(r2_wout[i])
            );
        end
    endgenerate

    pe8 pe8_inst0(
        .clk(clk),
        .reset(reset | start),
        .firstmatch(rstart),
        .is_firstgap(rbegin_gap),
        .ctrl(ctrl_enable[7:0]),
        .overlap(woverlap[N_PE-1 -: 8]),
        .is_gap(rgap),
        .is_mask(rmask),
        .r0_lin(r0_wlin[N_PE24]),
        .r1_lin(r1_wlin[N_PE24]),
        .r2_lin(r2_wlin[N_PE24]),
        .key(rkey),
        .text(wtextin[262143 -: 64]),
        .win_out(win_wout[32767 -: 8]),
        .r0_out(r0_wout[N_PE24]),
        .r1_out(r1_wout[N_PE24]),
        .r2_out(r2_wout[N_PE24])
    );

    //integer x;
    always @(posedge clk) begin
        if (rupdate) rwin <= win_wout;
        else rwin <= rwin;

        if (rupdate) rwin2 <= win_wout;
        else if (bitstream_rden) rwin2 <= rwin2 >> 64;
        else rwin2 <= rwin2;
    end

    always @(posedge clk) start_decoder <= rupdate;

    always @(posedge clk)
    if (reset) rkey_length <= 6'd0;
    else if (rstart) rkey_length <= key_length - 6'd1;

    always @(posedge clk) begin
        if (reset) byte_offset <= 24'h0000_0000;
        else if (rstart) byte_offset <= byte_offset + 1'b1;

        if (reset) rbash_offset <= 32'd0;
        else if (~rstart & start) rbash_offset <= rbash_offset + 1'b1;
    end

    tsp_decoder decoder(
        .clk(clk),
        .reset(reset | start),
        .key_length(key_length),
        .ibit(rwin),
        .istart(start_decoder),
        .bash_offset(byte_offset),
        .oaddress(wodata),
        .rden(read_enable),
        .ovalid(wodatavalid),
        .oidle(tsp_idle),
        .full(wfull),
        .empty(wempty),
        .match_count(match_count),
        .match_count_valid(match_count_valid)
    );

    assign bash_offset = rbash_offset;

    assign r0_out = r0_wout[N_PE24];
    assign r1_out = r1_wout[N_PE24];
    assign r2_out = r2_wout[N_PE24];

    assign odata = wodata;
    assign odatavalid = wodatavalid;
    assign tsp_full = wfull;
    assign tsp_empty = wempty;

    assign bitstream_rdata = rwin2[63:0];

endmodule
