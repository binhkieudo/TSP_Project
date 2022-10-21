module key_buffer(
        clk,
        reset,
        start,
        byte_mode,
        write_key,
        wren,
        key_first,
        key_last,
        key_begingap,
        key_endgap,
        key_mask,
        key_bytemode,
        key_length,
        key,
        buffer_full,
        buffer_almost_full,
        buffer_empty,
        buffer_almost_empty
    );
    
    input clk;
    input reset;
    input start;
    
    input [1:0]byte_mode;
    input [13:0]write_key;
    input wren;
    
    output key_first;
    output key_last;
    output key_begingap;
    output key_endgap;
    output key_mask;
    output [1:0]key_bytemode;
    output [8:0]key_length;
    output [7:0]key;
    
    output buffer_full;
    output buffer_almost_full;
    output buffer_empty;
    output buffer_almost_empty;
    
    wire [15:0]wrdata;
    wire [15:0]rddata;
    wire [15:0]wrddata;
    wire rddata_vld;
    wire rden;
    wire reload;
    wire output_vld;
    
    reg [1:0]rbytemode;
    
    reg r_first;
    reg r_begingap;
    reg r_endgap;
    reg r_last;
    reg r_mask;
    reg [1:0]r_keybytemode;
    reg [8:0]r_keylength;
    reg [7:0]r_key;
    reg r_lastkey;
    
// FSM
    reg [2:0]state, next;
    
    parameter S_IDLE   = 3'd0,
              S_INIT   = 3'd1,
              S_LOAD   = 3'd2,
              S_LOAD2  = 3'd3,
              S_RELOAD = 3'd4,
              S_WAIT   = 3'd5;   
              
    wire sidle   = state == S_IDLE;
    wire sinit   = state == S_INIT;
    wire sload   = state == S_LOAD;
    wire sload2  = state == S_LOAD2;
    wire sreload = state == S_RELOAD;
    wire swait   = state == S_WAIT;
    
    wire wdata_lastkey  = rddata[13];
    wire wdata_lastbyte = rddata[11];
    
    always @(posedge clk) begin
        if (reset) state <= S_IDLE;
        else state <= next;
    end
    
    always @(*) begin
        case (state)
            S_IDLE:     next = start? S_INIT: S_IDLE;
            S_INIT:     next = S_LOAD2;
            S_LOAD2:     next = S_LOAD;
            S_LOAD:     next = wdata_lastbyte? (wdata_lastkey? S_RELOAD: S_WAIT): S_LOAD;
            S_RELOAD:   next = S_IDLE;
            S_WAIT:     next = start? S_INIT: S_WAIT;
            default:    next = S_IDLE;
        endcase
    end
    
    always @(posedge clk) begin
        rbytemode <= byte_mode;
    end
    
    always @(posedge clk) begin
        if (sinit) r_keylength <= 9'd0;
        else if (sload && ~wdata_lastbyte) r_keylength <= r_keylength + 1'b1;
    end
    
    always @(posedge clk) begin
        r_keybytemode   <= rddata[15:14] & {2{output_vld}};
        r_lastkey       <= rddata[13]    & output_vld & sload;
        r_first         <= rddata[12]    & output_vld & sload;
        r_last          <= rddata[11]    & output_vld & sload;
        r_begingap      <= rddata[10]    & output_vld & sload;
        r_endgap        <= rddata[9]     & output_vld & sload;
        r_mask          <= rddata[8]     & output_vld & sload;
        r_key           <= rddata[7:0]   & {8{output_vld}};
    end
    
    assign wrdata       = {rbytemode, write_key};
    assign output_vld   = sload | sload2;
    assign rden         = (sload | sload2) & ~wdata_lastbyte;
    assign reload       = sreload;
    
    assign rddata = wrddata & {16{sload}};
    
    reload_fifo reload_fifo_inst(
        .clk            ( clk                ) ,
        .rd_reset       ( reset | reload     ) ,
        .wr_reset       ( reset              ) ,  
        .wrdata         ( wrdata             ) ,
        .wren           ( wren               ) ,
        .rddata         ( wrddata            ) ,
        .rddata_vld     ( rddata_vld         ) ,
        .rden           ( rden               ) ,
        .full           ( buffer_full        ) ,
        .almost_full    ( buffer_almost_full ) ,
        .empty          ( buffer_empty       ) ,
        .almost_empty   ( buffer_almost_empty)
    );
    defparam reload_fifo_inst.FIFO_DEPTH = 4096;
    defparam reload_fifo_inst.FIFO_WIDTH = 16;
    
    assign key_first    = r_first;
    assign key_last     = r_last;
    assign key_begingap = r_begingap;
    assign key_endgap   = r_endgap;
    assign key_mask     = r_mask;
    assign key_bytemode = r_keybytemode;
    assign key_length   = r_keylength;
    assign key          = r_key; 
    
endmodule
