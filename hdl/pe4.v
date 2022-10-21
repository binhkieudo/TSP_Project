`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/07/2022 03:33:08 PM
// Design Name: 
// Module Name: pe4
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


module pe4(
        clk,
        reset,
        firstmatch,
        is_firstgap,
        ctrl,
        overlap,
        is_gap,
        is_mask,
        r0_lin,
        r1_lin,
        r2_lin,
        key,
        text,
        win_out,
        r0_out,
        r1_out,
        r2_out
    );
    
    input clk;
    input reset;
    
    input firstmatch;
    input is_firstgap;
    input [3:0]ctrl;
    input [3:0]overlap;
    input is_gap;
    input is_mask;
    input r0_lin;
    input r1_lin;
    input r2_lin;
    input [9:0]key;
    input [31:0]text;
    
    output [3:0]win_out;
    output r0_out;
    output r1_out;
    output r2_out;
    
    wire [3:0]r0_wout;
    wire [3:0]r1_wout;
    wire [3:0]r2_wout;
    
    wire [3:0]r0_win;
    wire [3:0]r1_win;
    wire [3:0]r2_win;
    
    wire [7:0]text_0;
    wire [7:0]text_1;
    wire [7:0]text_2;
    wire [7:0]text_3;
    
    assign r0_win[0] = r0_lin;
    assign r0_win[1] = r0_wout[0];
    assign r0_win[2] = r0_wout[1];
    assign r0_win[3] = r0_wout[2];
    
    assign r1_win[0]= r1_lin;
    assign r1_win[1]= r1_wout[0];
    assign r1_win[2]= r1_wout[1];
    assign r1_win[3]= r1_wout[2];
    
    assign r2_win[0]= r2_lin;
    assign r2_win[1]= r2_wout[0];
    assign r2_win[2]= r2_wout[1];
    assign r2_win[3]= r2_wout[2];
    
    assign text_0 = text[7:0];
    assign text_1 = text[15:8];
    assign text_2 = text[23:16];
    assign text_3 = text[31:24];
     
    pe inst0(
        .clk(clk),
        .reset(reset),
        .firstmatch(firstmatch),
        .is_firstgap(is_firstgap),
        .ctrl(ctrl[0]),
        .overlap(overlap[0]),
        .is_gap(is_gap),
        .is_mask(is_mask),
        .r0_lin(r0_win[0]),
        .r1_lin(r1_win[0]),
        .r2_lin(r2_win[0]),
        .key(key),
        .text(text_0),
        .r0_out(r0_wout[0]),
        .r1_out(r1_wout[0]),
        .r2_out(r2_wout[0])
    );
    
    pe inst1(
        .clk(clk),
        .reset(reset),
        .firstmatch(firstmatch),
        .is_firstgap(is_firstgap),
        .ctrl(ctrl[1]),
        .overlap(overlap[1]),
        .is_gap(is_gap),
        .is_mask(is_mask),
        .r0_lin(r0_win[1]),
        .r1_lin(r1_win[1]),
        .r2_lin(r2_win[1]),
        .key(key),
        .text(text_1),
        .r0_out(r0_wout[1]),
        .r1_out(r1_wout[1]),
        .r2_out(r2_wout[1])
    );
    
    pe inst2(
        .clk(clk),
        .reset(reset),
        .firstmatch(firstmatch),
        .is_firstgap(is_firstgap),
        .ctrl(ctrl[2]),
        .overlap(overlap[2]),
        .is_gap(is_gap),
        .is_mask(is_mask),
        .r0_lin(r0_win[2]),
        .r1_lin(r1_win[2]),
        .r2_lin(r2_win[2]),
        .key(key),
        .text(text_2),
        .r0_out(r0_wout[2]),
        .r1_out(r1_wout[2]),
        .r2_out(r2_wout[2])
    );
    
    pe inst3(
        .clk(clk),
        .reset(reset),
        .firstmatch(firstmatch),
        .is_firstgap(is_firstgap),
        .ctrl(ctrl[3]),
        .overlap(overlap[3]),
        .is_gap(is_gap),
        .is_mask(is_mask),
        .r0_lin(r0_win[3]),
        .r1_lin(r1_win[3]),
        .r2_lin(r2_win[3]),
        .key(key),
        .text(text_3),
        .r0_out(r0_wout[3]),
        .r1_out(r1_wout[3]),
        .r2_out(r2_wout[3])
    );
    
    assign win_out = r0_wout;
    assign r0_out = r0_wout[3];
    assign r1_out = r1_wout[3];
    assign r2_out = r2_wout[3];
    
endmodule

