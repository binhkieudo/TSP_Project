`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/22/2022 02:58:45 PM
// Design Name: 
// Module Name: top
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


module tsp_top(
    input           ICLK,
    input           IRESET,
    input           ICONTINUE,
    input           IRESETTEXT,
    input           IOVERLAP,
    // 32 channels 64-bits (update text)
    input [63:0]    ITEXT0_DATA,
    input [63:0]    ITEXT1_DATA,
    input [63:0]    ITEXT2_DATA,
    input [63:0]    ITEXT3_DATA,
    input [63:0]    ITEXT4_DATA,
    input [63:0]    ITEXT5_DATA,
    input [63:0]    ITEXT6_DATA,
    input [63:0]    ITEXT7_DATA,
    input [63:0]    ITEXT8_DATA,
    input [63:0]    ITEXT9_DATA,
    input [63:0]    ITEXT10_DATA,
    input [63:0]    ITEXT11_DATA,
    input [63:0]    ITEXT12_DATA,
    input [63:0]    ITEXT13_DATA,
    input [63:0]    ITEXT14_DATA,
    input [63:0]    ITEXT15_DATA,
    input [63:0]    ITEXT16_DATA,
    input [63:0]    ITEXT17_DATA,
    input [63:0]    ITEXT18_DATA,
    input [63:0]    ITEXT19_DATA,
    input [63:0]    ITEXT20_DATA,
    input [63:0]    ITEXT21_DATA,
    input [63:0]    ITEXT22_DATA,
    input [63:0]    ITEXT23_DATA,
    input [63:0]    ITEXT24_DATA,
    input [63:0]    ITEXT25_DATA,
    input [63:0]    ITEXT26_DATA,
    input [63:0]    ITEXT27_DATA,
    input [63:0]    ITEXT28_DATA,
    input [63:0]    ITEXT29_DATA,
    input [63:0]    ITEXT30_DATA,
    input [63:0]    ITEXT31_DATA,
    input [31:0]    ITEXT_WE,
    input           BITSTREAM_RDEN,
    // Read result port
    input           IRDEN,
    output [15:0]   ODATA,
    output          ODATAVALID,
    output          OFULL,
    output          OEMPTY,
    output [31:0]   MATCH_COUNT,
    output          MATCH_COUNT_VALID,
    output [63:0]   BITSTREAM,
    output [31:0]   BASH_CODE,
    // Buffer control signals
    input           BUFFER_START,
    input  [1:0]    BUFFER_BYTEMODE,
    input  [13:0]   BUFFER_IKEY,
    input           BUFFER_WREN,
    output          KEY_LAST
);

    parameter HBM_PC  = 32;
    parameter HBM_PCWIDTH = 64;
    parameter PE = 32768;
    parameter LOG2_PE = 15;
    parameter ZERO_FILL = 32 - LOG2_PE;
    
    wire [8:0]key_length;
    
    wire [HBM_PC*HBM_PCWIDTH-1:0] write_text = {ITEXT31_DATA, ITEXT30_DATA,
    ITEXT29_DATA, ITEXT28_DATA, ITEXT27_DATA, ITEXT26_DATA, ITEXT25_DATA, ITEXT24_DATA, ITEXT23_DATA, ITEXT22_DATA, ITEXT21_DATA, ITEXT20_DATA,
    ITEXT19_DATA, ITEXT18_DATA, ITEXT17_DATA, ITEXT16_DATA, ITEXT15_DATA, ITEXT14_DATA, ITEXT13_DATA, ITEXT12_DATA, ITEXT11_DATA, ITEXT10_DATA,
    ITEXT9_DATA, ITEXT8_DATA, ITEXT7_DATA, ITEXT6_DATA, ITEXT5_DATA, ITEXT4_DATA, ITEXT3_DATA, ITEXT2_DATA, ITEXT1_DATA, ITEXT0_DATA };

    wire [14 : 0]match_count;
    
    wire        key_first;
    wire        key_last;
    wire        key_begingap;
    wire        key_endgap;
    wire        key_mask;
    wire [1:0]  key_bytemode;
    wire [7:0]  key_data;
    
    
    tsp tsp_core(
        .clk        ( ICLK          ) ,
        .reset      ( IRESET        ) ,
        .reset_text ( IRESETTEXT    ) ,
        .byte_mode  ( key_bytemode  ) ,
        .start      ( key_first     ) ,
        .overlap    ( IOVERLAP      ) ,
        .begin_gap  ( key_begingap  ) ,
        .end_gap    ( key_endgap    ) ,
        .last_byte  ( key_last      ) ,
        .mask       ( key_mask      ) ,
        .key        ( key_data      ) ,
        .key_length ( key_length    ) ,
        // 32 channels 64-bits (update text)
        .text_wdata ( write_text ) ,
        .text_we    ( ITEXT_WE   ) ,
        // Extend ports
        .r0_lin     ( 1'b0       ) ,
        .r1_lin     ( 1'b0       ) ,
        .r2_lin     ( 1'b0       ) ,
        .r0_out     (            ) ,
        .r1_out     (            ) ,
        .r2_out     (            ) ,
        // Read result port
        .bash_offset( BASH_CODE  ) ,
        .read_enable( IRDEN      ) ,
        .odata      ( ODATA      ) ,
        .odatavalid ( ODATAVALID ) ,
        .tsp_full   ( OFULL      ) ,
        .tsp_empty  ( OEMPTY     ) ,
        .match_count( match_count) ,
        .match_count_valid  ( MATCH_COUNT_VALID ) ,
        .bitstream_rden     ( BITSTREAM_RDEN    ) ,
        .bitstream_rdata    ( BITSTREAM         )
    );

    key_buffer key_buffer_inst(
        .clk                    ( ICLK              ) ,
        .reset                  ( IRESET | ICONTINUE) ,
        .start                  ( BUFFER_START      ) ,    
        .byte_mode              ( BUFFER_BYTEMODE   ) ,  
        .write_key              ( BUFFER_IKEY       ) ,  
        .wren                   ( BUFFER_WREN       ) ,   
        .key_first              ( key_first         ) ,   
        .key_last               ( key_last          ) , 
        .key_begingap           ( key_begingap      ) , 
        .key_endgap             ( key_endgap        ) ,
        .key_mask               ( key_mask          ) ,
        .key_bytemode           ( key_bytemode      ) ,
        .key_length             ( key_length        ) ,
        .key                    ( key_data          ) ,
        .buffer_full            (                   ) ,
        .buffer_almost_full     (                   ) ,
        .buffer_empty           (                   ) ,
        .buffer_almost_empty    (                   )
    );

    assign MATCH_COUNT = {17'd0, match_count};
    assign KEY_LAST = key_last;
    
endmodule
