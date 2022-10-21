`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/14/2022 07:14:45 PM
// Design Name: 
// Module Name: pe8
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


module pe24(
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
    input [23:0]ctrl;
    input [23:0]overlap;
    input is_gap;
    input is_mask;
    input r0_lin;
    input r1_lin;
    input r2_lin;
    input [9:0]key;
    input [191:0]text;
    output [23:0]win_out;
    output r0_out;
    output r1_out;
    output r2_out;
    
    wire r0_win;
    wire r1_win;
    wire r2_win;
    
    wire [63:0]text0 = text[63:0];
    wire [63:0]text1 = text[127:64];
    wire [63:0]text2 = text[191:128];
    
    wire [2:0]r0_wout;
    wire [2:0]r1_wout;
    wire [2:0]r2_wout;
    
    pe8 inst0(
        .clk(clk),
        .reset(reset),
        .firstmatch(firstmatch),
        .is_firstgap(is_firstgap),
        .ctrl(ctrl[7:0]),
        .overlap(overlap[7:0]),
        .is_gap(is_gap),
        .is_mask(is_mask),
        .r0_lin(r0_lin),
        .r1_lin(r1_lin),
        .r2_lin(r2_lin),
        .key(key),
        .text(text0),
        .win_out(win_out[7:0]),
        .r0_out(r0_wout[0]),
        .r1_out(r1_wout[0]),
        .r2_out(r2_wout[0])
    );

    pe8 inst1(
        .clk(clk),
        .reset(reset),
        .firstmatch(firstmatch),
        .is_firstgap(is_firstgap),
        .ctrl(ctrl[15:8]),
        .overlap(overlap[15:8]),
        .is_gap(is_gap),
        .is_mask(is_mask),
        .r0_lin(r0_wout[0]),
        .r1_lin(r1_wout[0]),
        .r2_lin(r2_wout[0]),
        .key(key),
        .text(text1),
        .win_out(win_out[15:8]),
        .r0_out(r0_wout[1]),
        .r1_out(r1_wout[1]),
        .r2_out(r2_wout[1])
    );
    
    pe8 inst2(
        .clk(clk),
        .reset(reset),
        .firstmatch(firstmatch),
        .is_firstgap(is_firstgap),
        .ctrl(ctrl[23:16]),
        .overlap(overlap[23:16]),
        .is_gap(is_gap),
        .is_mask(is_mask),
        .r0_lin(r0_wout[1]),
        .r1_lin(r1_wout[1]),
        .r2_lin(r2_wout[1]),
        .key(key),
        .text(text2),
        .win_out(win_out[23:16]),
        .r0_out(r0_wout[2]),
        .r1_out(r1_wout[2]),
        .r2_out(r2_wout[2])
    );
        
    assign r0_out = r0_wout[2];
    assign r1_out = r1_wout[2];
    assign r2_out = r2_wout[2];
    
endmodule
