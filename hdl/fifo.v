module fifo (
    clk,
    reset,
    wrdata,
    wren,
    rddata,
    rddata_vld,
    rden,
    full,
    almost_full,
    empty,
    almost_empty
);

    parameter FIFO_DEPTH = 32;
    parameter LOG2_FIFO_DEPTH = $clog2(FIFO_DEPTH);
    parameter FIFO_WIDTH = 32;

    input clk;
    input reset;

    input [FIFO_WIDTH-1:0]wrdata;
    input wren;

    output [FIFO_WIDTH-1:0]rddata;
    output rddata_vld;
    input rden;


    output full;
    output almost_full;
    output empty;
    output almost_empty;

    reg [FIFO_WIDTH-1:0]mem[0:FIFO_DEPTH-1];

    reg [LOG2_FIFO_DEPTH:0]wrptr;
    reg [LOG2_FIFO_DEPTH:0]rdptr;




    reg [LOG2_FIFO_DEPTH:0]wrptr_inc1;
    reg [LOG2_FIFO_DEPTH:0]rdptr_inc1;

    reg rempty;

    wire bit_cmp_f = wrptr[LOG2_FIFO_DEPTH] ^ rdptr[LOG2_FIFO_DEPTH];
    wire bit_cmp_e = ~bit_cmp_f;
    wire addr_eq = wrptr[LOG2_FIFO_DEPTH-1:0] == rdptr[LOG2_FIFO_DEPTH-1:0];

    wire bit_cmp_af = wrptr_inc1[LOG2_FIFO_DEPTH] ^ rdptr[LOG2_FIFO_DEPTH];
    wire addr_eq_af = wrptr_inc1[LOG2_FIFO_DEPTH-1:0] == rdptr[LOG2_FIFO_DEPTH-1:0];

    wire bit_cmp_ae = ~(wrptr[LOG2_FIFO_DEPTH] ^ rdptr_inc1[LOG2_FIFO_DEPTH]);
    wire addr_eq_ae = wrptr[LOG2_FIFO_DEPTH-1:0] == rdptr_inc1[LOG2_FIFO_DEPTH-1:0];



    wire fifo_full = bit_cmp_f && addr_eq;
    wire fifo_empty = bit_cmp_e && addr_eq;

    wire fifo_almost_full = bit_cmp_af && addr_eq_af;
    wire fifo_almost_empty = bit_cmp_ae && addr_eq_ae;

    reg [FIFO_WIDTH-1:0]rdata;

    always @(posedge clk) begin
        rempty <= fifo_empty;
    end

    always @(posedge clk)
    if (reset) begin
        wrptr <= 0;
        wrptr_inc1 <= 0;
    end
    else if (wren && !fifo_full) begin
        wrptr <= wrptr + 1'b1;
        wrptr_inc1 <= wrptr + 2;
    end

    always @(posedge clk)
    if (reset) begin
        rdptr <= 0;
        rdptr_inc1 <= 0;
    end
    else if (rden && !fifo_empty) begin
        rdptr <= rdptr + 1'b1;
        rdptr_inc1 <= rdptr + 2;
    end

    integer i;
    always @(posedge clk) begin
        //	   for (i = 0; i < FIFO_DEPTH; i = i + 1) 
        //	       if (reset) mem[i] <= 0;
        //	       else if (wren && !fifo_full && (i == wrptr)) mem[i] <= wrdata;
        if (wren && !fifo_full) mem[wrptr[LOG2_FIFO_DEPTH-1:0]] <= wrdata;

        rdata <= mem[rdptr[LOG2_FIFO_DEPTH-1:0]];
    end

    assign rddata = rdata;
    assign rddata_vld = !rempty;

    assign full = fifo_full;
    assign almost_full = fifo_almost_full;
    assign empty = fifo_empty;
    assign almost_empty = fifo_almost_empty;

endmodule