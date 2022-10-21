module krnl_rtl_read_axi #( 
  parameter integer C_ADDR_WIDTH       = 64,
  parameter integer C_DATA_WIDTH       = 64,
  parameter integer C_LENGTH_WIDTH     = 32,  
  parameter integer C_BURST_LEN        = 256, // Max AXI burst length for read commands
  parameter integer C_LOG_BURST_LEN    = 8,
  parameter integer C_MAX_OUTSTANDING  = 3 
)
(
  // System signals
  input                       aclk,
  input                       areset,
    // Control signals 
  input                       dev_start,
  input                       load_done,
  input                       ctrl_start, 
  output                      ctrl_done,
  input  [C_ADDR_WIDTH-1:0]   ctrl_offset,
  input  [C_LENGTH_WIDTH-1:0] ctrl_length,
  // AXI4 master interface                             
  output                      arvalid,
  input                       arready,
  output [C_ADDR_WIDTH-1:0]   araddr,
  output                      arid,
  output [7:0]                arlen,
  output [2:0]                arsize,
  input                       rvalid,
  output                      rready,
  input  [C_DATA_WIDTH - 1:0] rdata,
  input                       rlast,
  input                       rid,
  input  [1:0]                rresp,
  // FIFO read signals
  output                      idle,
  output                      odone,
  input                       rd_en,
  output [C_DATA_WIDTH - 1:0] rd_data,
  output                      rd_tvalid_n,
  output [7:0]               ocount,
  output [2:0]               ostate
);

///////////////////////////////////////////////////////////////////////////////
// Local Parameters
///////////////////////////////////////////////////////////////////////////////
localparam integer LP_MAX_OUTSTANDING_CNTR_WIDTH = $clog2(C_MAX_OUTSTANDING+1); 
localparam integer LP_TRANSACTION_CNTR_WIDTH = C_LENGTH_WIDTH-C_LOG_BURST_LEN;
localparam integer LP_DW_BYTES           = C_DATA_WIDTH/8;
localparam integer LP_AXI_BURST_LEN      = 4096/LP_DW_BYTES < 256 ? 4096/LP_DW_BYTES : 256;
localparam integer LP_RD_FIFO_DEPTH      = LP_AXI_BURST_LEN*(C_MAX_OUTSTANDING + 1);

///////////////////////////////////////////////////////////////////////////////
// Variables
///////////////////////////////////////////////////////////////////////////////
wire                      rd_tready_n;

wire                      m_tvalid;
wire                      m_tready = ~rd_tready_n;
wire [C_DATA_WIDTH-1:0]   m_tdata;

wire                      ctrl_prog_full;
  
// Control logic
reg                                  done = 1'b0;
wire [LP_TRANSACTION_CNTR_WIDTH-1:0] num_full_bursts;
wire                                 num_partial_bursts;
reg                                  start    = 1'b0;
reg [LP_TRANSACTION_CNTR_WIDTH-1:0]  num_transactions;
reg                                  has_partial_burst;
reg [C_LOG_BURST_LEN-1:0]            final_burst_len;
wire                                 single_transaction;
reg                                  ar_idle = 1'b1;
wire                                 ar_done;
// AXI Read Address Channel
wire                                     fifo_stall;
wire                                     arxfer;
reg                                      arvalid_r = 1'b0; 
reg [C_ADDR_WIDTH-1:0]                   addr;
wire [LP_TRANSACTION_CNTR_WIDTH-1:0]     ar_transactions_to_go;
wire                                     ar_final_transaction;
wire                                     incr_ar_to_r_cnt;
wire                                     decr_ar_to_r_cnt;
wire                                     stall_ar;
wire [LP_MAX_OUTSTANDING_CNTR_WIDTH-1:0] outstanding_vacancy_count;
// AXI Data Channel
wire                                 tvalid;
wire [C_DATA_WIDTH-1:0]              tdata;
wire                                 rxfer;
wire                                 decr_r_transaction_cntr;
wire [LP_TRANSACTION_CNTR_WIDTH-1:0] r_transactions_to_go;
wire                                 r_final_transaction;

reg [C_DATA_WIDTH - 1:0] r_rd_data;
reg                      r_rd_tvalid_n;
wire [C_DATA_WIDTH - 1:0] w_rd_data;
wire                      w_rd_tvalid_n;
///////////////////////////////////////////////////////////////////////////////
// Control Logic 
///////////////////////////////////////////////////////////////////////////////

always @(posedge aclk) begin
    done <= rxfer & rlast & r_final_transaction ? 1'b1 : 
          ctrl_done ? 1'b0 : done; 
end

assign ctrl_done = done;

// Determine how many full burst to issue and if there are any partial bursts.
assign num_full_bursts = ctrl_length[C_LOG_BURST_LEN+:C_LENGTH_WIDTH-C_LOG_BURST_LEN];
assign num_partial_bursts = ctrl_length[0+:C_LOG_BURST_LEN] ? 1'b1 : 1'b0; 

always @(posedge aclk) begin 
  start <= ctrl_start;
  num_transactions <= (num_partial_bursts == 1'b0) ? num_full_bursts - 1'b1 : num_full_bursts;
  has_partial_burst <= num_partial_bursts;
  final_burst_len <=  ctrl_length[0+:C_LOG_BURST_LEN] - 1'b1;
end

// Special case if there is only 1 AXI transaction. 
assign single_transaction = (num_transactions == {LP_TRANSACTION_CNTR_WIDTH{1'b0}}) ? 1'b1 : 1'b0;

///////////////////////////////////////////////////////////////////////////////
// AXI Read Address Channel
///////////////////////////////////////////////////////////////////////////////
assign arvalid = arvalid_r;
assign araddr = addr;
assign arlen  = ar_final_transaction || (start & single_transaction) ? final_burst_len : C_BURST_LEN - 1;
assign arsize = $clog2((C_DATA_WIDTH/8));
assign arid   = 1'b0;

assign arxfer = arvalid & arready;
assign fifo_stall = ctrl_prog_full;

always @(posedge aclk) begin 
  if (areset) begin 
    arvalid_r <= 1'b0;
  end
  else begin
    arvalid_r <= ~ar_idle & ~stall_ar & ~arvalid_r & ~fifo_stall ? 1'b1 : 
                 arready ? 1'b0 : arvalid_r;
  end
end

// When ar_idle, there are no transactions to issue.
always @(posedge aclk) begin 
  if (areset) begin 
    ar_idle <= 1'b1; 
  end
  else begin 
    ar_idle <= start   ? 1'b0 :
               ar_done ? 1'b1 : 
                         ar_idle;
  end
end

// Increment to next address after each transaction is issued.
always @(posedge aclk) begin 
    addr <= ctrl_start   ? ctrl_offset :
               arxfer       ? addr + C_BURST_LEN*C_DATA_WIDTH/8 : 
                              addr;
end

// Counts down the number of transactions to send.
krnl_rtl_axi_counter #(
  .C_WIDTH ( LP_TRANSACTION_CNTR_WIDTH         ) ,
  .C_INIT  ( {LP_TRANSACTION_CNTR_WIDTH{1'b0}} ) 
)
inst_ar_transaction_cntr ( 
  .clk        ( aclk                   ) ,
  .clken      ( 1'b1                   ) ,
  .rst        ( areset                 ) ,
  .load       ( start                  ) ,
  .incr       ( 1'b0                   ) ,
  .decr       ( arxfer                 ) ,
  .load_value ( num_transactions       ) ,
  .count      ( ar_transactions_to_go  ) ,
  .is_zero    ( ar_final_transaction   ) 
);

assign ar_done = ar_final_transaction && arxfer;

assign incr_ar_to_r_cnt = rxfer & rlast;
assign decr_ar_to_r_cnt = arxfer & (arid == 1'b0);

// Keeps track of the number of outstanding transactions. Stalls 
// when the value is reached so that the FIFO won't overflow.
krnl_rtl_axi_counter #(
  .C_WIDTH ( LP_MAX_OUTSTANDING_CNTR_WIDTH                       ) ,
  .C_INIT  ( C_MAX_OUTSTANDING[0+:LP_MAX_OUTSTANDING_CNTR_WIDTH] ) 
)
inst_ar_to_r_transaction_cntr ( 
  .clk        ( aclk                           ) ,
  .clken      ( 1'b1                           ) ,
  .rst        ( areset                         ) ,
  .load       ( 1'b0                           ) ,
  .incr       ( incr_ar_to_r_cnt               ) ,
  .decr       ( decr_ar_to_r_cnt               ) ,
  .load_value ( {LP_MAX_OUTSTANDING_CNTR_WIDTH{1'b0}} ) ,
  .count      ( outstanding_vacancy_count      ) ,
  .is_zero    ( stall_ar                       ) 
);

///////////////////////////////////////////////////////////////////////////////
// AXI Read Channel
///////////////////////////////////////////////////////////////////////////////
assign m_tvalid = tvalid;
assign m_tdata = tdata;

assign tvalid = rvalid && (rid == 1'b0); 
assign tdata  = rdata;

// rready can remain high for optimal timing because ar transactions are not issued
// unless there is enough space in the FIFO.
assign rready = 1'b1;
assign rxfer = rready & rvalid;

assign decr_r_transaction_cntr = rxfer & rlast & (rid == 1'b0);

krnl_rtl_axi_counter #(
  .C_WIDTH ( LP_TRANSACTION_CNTR_WIDTH         ) ,
  .C_INIT  ( {LP_TRANSACTION_CNTR_WIDTH{1'b0}} ) 
)
inst_r_transaction_cntr ( 
  .clk        ( aclk                          ) ,
  .clken      ( 1'b1                          ) ,
  .rst        ( areset                        ) ,
  .load       ( start                         ) ,
  .incr       ( 1'b0                          ) ,
  .decr       ( decr_r_transaction_cntr       ) ,
  .load_value ( num_transactions              ) ,
  .count      ( r_transactions_to_go          ) ,
  .is_zero    ( r_final_transaction           ) 
);

// Read FIFO
// xpm_fifo_sync: Synchronous FIFO
// Xilinx Parameterized Macro, Version 2016.4
xpm_fifo_sync # (
  .FIFO_MEMORY_TYPE          ("auto"),           //string; "auto", "block", "distributed", or "ultra";
  .ECC_MODE                  ("no_ecc"),         //string; "no_ecc" or "en_ecc";
  .FIFO_WRITE_DEPTH          (LP_RD_FIFO_DEPTH),   //positive integer
  .WRITE_DATA_WIDTH          (C_DATA_WIDTH),        //positive integer
  .WR_DATA_COUNT_WIDTH       ($clog2(LP_RD_FIFO_DEPTH)+1),       //positive integer, Not used
  .PROG_FULL_THRESH          (LP_AXI_BURST_LEN-2),               //positive integer
  .FULL_RESET_VALUE          (1),                //positive integer; 0 or 1
  .READ_MODE                 ("fwft"),            //string; "std" or "fwft";
  .FIFO_READ_LATENCY         (1),                //positive integer;
  .READ_DATA_WIDTH           (C_DATA_WIDTH),               //positive integer
  .RD_DATA_COUNT_WIDTH       ($clog2(LP_RD_FIFO_DEPTH)+1),               //positive integer, not used
  .PROG_EMPTY_THRESH         (10),               //positive integer, not used 
  .DOUT_RESET_VALUE          ("0"),              //string, don't care
  .WAKEUP_TIME               (0)                 //positive integer; 0 or 2;

) inst_rd_xpm_fifo_sync (
  .sleep         ( 1'b0             ) ,
  .rst           ( areset           ) ,
  .wr_clk        ( aclk             ) ,
  .wr_en         ( m_tvalid         ) ,
  .din           ( m_tdata          ) ,
  .full          ( rd_tready_n      ) ,
  .prog_full     ( ctrl_prog_full   ) ,
  .wr_data_count (                  ) ,
  .overflow      (                  ) ,
  .wr_rst_busy   (                  ) ,
  .rd_en         ( rd_en            ) ,
  .dout          ( w_rd_data        ) ,
  .empty         ( w_rd_tvalid_n    ) ,
  .prog_empty    (                  ) ,
  .rd_data_count (                  ) ,
  .underflow     (                  ) ,
  .rd_rst_busy   (                  ) ,
  .injectsbiterr ( 1'b0             ) ,
  .injectdbiterr ( 1'b0             ) ,
  .sbiterr       (                  ) ,
  .dbiterr       (                  ) 

);

reg rodone = 1'b0;
reg [7:0]data_count = 8'd0;

reg [2:0]count_state, count_nstate;

parameter S_IDLE = 3'd0,
        S_INIT = 3'd1,
        S_WAIT = 3'd2,
        S_FILL = 3'd3,
        S_DONE = 3'd4;
        
wire sidle = count_state == S_IDLE;
wire sinit = count_state == S_INIT;
wire swait = count_state == S_WAIT;
wire sfill = count_state == S_FILL;
wire sdone = count_state == S_DONE;

always @(posedge aclk) begin
    if (areset) count_state <= S_IDLE;
    else count_state <= count_nstate;
end

always @(*) begin
    case (count_state)
        S_IDLE: count_nstate = S_WAIT;
        S_WAIT: count_nstate = load_done? (data_count[7]? S_DONE: S_FILL): S_WAIT;
        //S_WAIT: count_nstate = load_done? S_DONE: S_WAIT;
        S_FILL: count_nstate = (data_count == 8'd127)? S_DONE: S_FILL;
        S_DONE: count_nstate = S_DONE;
        default: count_nstate = S_IDLE;
    endcase
end

always @(posedge aclk) begin
    if (sdone | areset) data_count <= 8'd0;
    //else if (sidle) data_count <= 8'd16;
    //else if (swait) data_count <= 8'd32;
    else if ((~w_rd_tvalid_n) | (~r_rd_tvalid_n)) data_count <= data_count + 1'b1;
    else data_count <= data_count;
end

always @(*) begin
    if (sfill) r_rd_data = 0;
    else r_rd_data = w_rd_data;
end

always @(*) begin
    if (sfill) r_rd_tvalid_n = 1'b0;
    else r_rd_tvalid_n = w_rd_tvalid_n;
end

always @(posedge aclk) begin
    if (sidle) rodone <= 1'b0;
    else if (sfill && count_nstate == S_DONE) rodone <= 1'b1;
    else rodone <= 1'b0;
end

assign odone = rodone;
assign rd_data = r_rd_data;
assign rd_tvalid_n = r_rd_tvalid_n;
assign idle = sidle || sdone;
assign ocount = {24'd0, data_count};
assign ostate = {29'd0, count_state};

endmodule
