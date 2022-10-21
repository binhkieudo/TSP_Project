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


module pe8(
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
    input [7:0]ctrl;
    input [7:0]overlap;
    input is_gap;
    input is_mask;
    input r0_lin;
    input r1_lin;
    input r2_lin;
    input [9:0]key;
    input [63:0]text;
    
    output [7:0]win_out;
    output r0_out;
    output r1_out;
    output r2_out;
    
    wire r0_win;
    wire r1_win;
    wire r2_win;
    
    pe4 pe4_inst0(
        .clk(clk),
        .reset(reset),
        .firstmatch(firstmatch),
        .is_firstgap(is_firstgap),
        .ctrl(ctrl[3:0]),
        .overlap(overlap[3:0]),
        .is_gap(is_gap),
        .is_mask(is_mask),
        .r0_lin(r0_lin),
        .r1_lin(r1_lin),
        .r2_lin(r2_lin),
        .key(key),
        .text(text[31:0]),
        .win_out(win_out[3:0]),
        .r0_out(r0_win),
        .r1_out(r1_win),
        .r2_out(r2_win)
    );
    
    pe4 pe4_inst1(
        .clk(clk),
        .reset(reset),
        .firstmatch(firstmatch),
        .is_firstgap(is_firstgap),
        .ctrl(ctrl[7:4]),
        .overlap(overlap[7:4]),
        .is_gap(is_gap),
        .is_mask(is_mask),
        .r0_lin(r0_win),
        .r1_lin(r1_win),
        .r2_lin(r2_win),
        .key(key),
        .text(text[63:32]),
        .win_out(win_out[7:4]),
        .r0_out(r0_out),
        .r1_out(r1_out),
        .r2_out(r2_out)
    );
    
endmodule
