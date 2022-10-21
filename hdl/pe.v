`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/07/2022 02:36:43 PM
// Design Name: 
// Module Name: pe
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


module pe(
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
        r0_out,
        r1_out,
        r2_out
    );
    
    input clk;
    input reset;
    
    input firstmatch;
    input is_firstgap;
    input ctrl;
    input overlap;
    input is_gap;
    input is_mask;
    
    input r0_lin;
    input r1_lin;
    input r2_lin;
    
    input [9:0]key;
    input [7:0]text;
    
    output r0_out;
    output r1_out;
    output r2_out;
    
    reg r0;
    reg r1;
    reg r2;
    
    wire [7:0]wkey = key[7:0];
    wire r0_next;
    wire r1_next;
    wire r2_next;
    
    wire is_match = wkey == text;
    wire last_byte = key[9];
    wire first_byte = key[8];
    
    wire r0_gap = first_byte? (is_match | (last_byte & r2_next)): (last_byte? r2_next: r0_lin & is_match);
    
    //assign r0_next = firstmatch? (is_match & ctrl & !overlap):
    assign r0_next = firstmatch? (is_match & !overlap):
                     is_mask? r0_lin:
                     is_gap? r0_gap & ( r1_lin | is_firstgap):
                     r0_lin & is_match;
    
    assign r1_next = is_firstgap? r0_lin: r1_lin;
    
    assign r2_next = is_firstgap? (last_byte? is_match: 1'b0):
                     (last_byte? (is_match & (r0_lin | (last_byte & first_byte))) | r2_lin: r2_lin);
    
    always @(posedge clk) r0 <= reset? 1'b0: r0_next;
    
    always @(posedge clk) r1 <= reset? 1'b0: r1_next;
    
    always @(posedge clk) r2 <= reset? 1'b0: r2_next;
    
    assign r0_out = r0;
    assign r1_out = r1;
    assign r2_out = r2;
            
endmodule
