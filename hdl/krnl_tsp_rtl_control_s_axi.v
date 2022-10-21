module krnl_tsp_rtl_control_s_axi
#(parameter
    C_S_AXI_ADDR_WIDTH = 10,
    C_S_AXI_DATA_WIDTH = 32
)(
    // axi4 lite slave signals
    input  wire                          ACLK,
    input  wire                          ARESET,
    input  wire                          ACLK_EN,
    input  wire [C_S_AXI_ADDR_WIDTH-1:0] AWADDR,
    input  wire                          AWVALID,
    output wire                          AWREADY,
    input  wire [C_S_AXI_DATA_WIDTH-1:0] WDATA,
    input  wire [C_S_AXI_DATA_WIDTH/8-1:0] WSTRB,
    input  wire                          WVALID,
    output wire                          WREADY,
    output wire [1:0]                    BRESP,
    output wire                          BVALID,
    input  wire                          BREADY,
    input  wire [C_S_AXI_ADDR_WIDTH-1:0] ARADDR,
    input  wire                          ARVALID,
    output wire                          ARREADY,
    output wire [C_S_AXI_DATA_WIDTH-1:0] RDATA,
    output wire [1:0]                    RRESP,
    output wire                          RVALID,
    input  wire                          RREADY,
    output wire                          interrupt,
    output wire                          ap_start,
    input  wire                          ap_done,
    input  wire                          ap_ready,
    input  wire                          ap_idle,
    // user signals
    output wire [63:0]                   file_size,
    output wire                          load_filesize,
    output wire [63:0]                   start_address,
    output wire                          load_address,
    input  wire [63:0]                   next_filesize,
    input  wire [63:0]                   next_address,
    input  wire                          overlap,
    input  wire                          load_done,
    output wire                          dev_reset,
    output wire                          dev_continue,
    output wire [1:0]                    dev_bytemode,
    input  wire                          dev_done,
    output wire                          dev_start,
    output wire                          dev_load_text,
    output wire [31:0]                   key,
    output wire                          key_we,
    output wire                          rden,
    output wire [5:0]                    keylen,
    input  wire [16:0]                   result,
    output wire                          bitstream_rden,
    input  wire [63:0]                   bitsream,
    input  wire [31:0]                   matchcount,
    input  wire                          matchcount_vld,
    input  wire [63:0]                   bash_offset,
    input  wire [31:0]                   bash_code,
    input  wire                          bash_update,
    input  wire [63:0]                   read_addr_0,
    input  wire [63:0]                   read_addr_1,
    input  wire [63:0]                   read_addr_2,
    input  wire [63:0]                   read_addr_3,
    input  wire [63:0]                   read_addr_4,
    input  wire [63:0]                   read_addr_5,
    input  wire [63:0]                   read_addr_6,
    input  wire [63:0]                   read_addr_7,
    input  wire [63:0]                   read_addr_8,
    input  wire [63:0]                   read_addr_9,
    input  wire [63:0]                   read_addr_10,
    input  wire [63:0]                   read_addr_11,
    input  wire [63:0]                   read_addr_12,
    input  wire [63:0]                   read_addr_13,
    input  wire [63:0]                   read_addr_14,
    input  wire [63:0]                   read_addr_15,
    input  wire [63:0]                   read_addr_16,
    input  wire [63:0]                   read_addr_17,
    input  wire [63:0]                   read_addr_18,
    input  wire [63:0]                   read_addr_19,
    input  wire [63:0]                   read_addr_20,
    input  wire [63:0]                   read_addr_21,
    input  wire [63:0]                   read_addr_22,
    input  wire [63:0]                   read_addr_23,
    input  wire [63:0]                   read_addr_24,
    input  wire [63:0]                   read_addr_25,
    input  wire [63:0]                   read_addr_26,
    input  wire [63:0]                   read_addr_27,
    input  wire [63:0]                   read_addr_28,
    input  wire [63:0]                   read_addr_29,
    input  wire [63:0]                   read_addr_30,
    input  wire [63:0]                   read_addr_31
);

    //------------------------Parameter----------------------
    localparam
    ADDR_AP_CTRL           = 10'h000,
    ADDR_GIE               = 10'h004,
    ADDR_IER               = 10'h008,
    ADDR_ISR               = 10'h00c,
    ADDR_C0_DATA_0         = 10'h010, // Channel 0
    ADDR_C0_DATA_1         = 10'h014,
    ADDR_C1_DATA_0         = 10'h018, // Channel 1
    ADDR_C1_DATA_1         = 10'h01c,
    ADDR_C2_DATA_0         = 10'h020, // Channel 2
    ADDR_C2_DATA_1         = 10'h024,
    ADDR_C3_DATA_0         = 10'h028, // Channel 3
    ADDR_C3_DATA_1         = 10'h02c,
    ADDR_C4_DATA_0         = 10'h030, // Channel 4
    ADDR_C4_DATA_1         = 10'h034,
    ADDR_C5_DATA_0         = 10'h038, // Channel 5
    ADDR_C5_DATA_1         = 10'h03c,
    ADDR_C6_DATA_0         = 10'h040, // Channel 6
    ADDR_C6_DATA_1         = 10'h044,
    ADDR_C7_DATA_0         = 10'h048, // Channel 7
    ADDR_C7_DATA_1         = 10'h04c,
    ADDR_C8_DATA_0         = 10'h050, // Channel 8
    ADDR_C8_DATA_1         = 10'h054,
    ADDR_C9_DATA_0         = 10'h058, // Channel 9
    ADDR_C9_DATA_1         = 10'h05c,
    ADDR_C10_DATA_0        = 10'h060, // Channel 10
    ADDR_C10_DATA_1        = 10'h064,
    ADDR_C11_DATA_0        = 10'h068, // Channel 11
    ADDR_C11_DATA_1        = 10'h06c,
    ADDR_C12_DATA_0        = 10'h070, // Channel 12
    ADDR_C12_DATA_1        = 10'h074,
    ADDR_C13_DATA_0        = 10'h078, // Channel 13
    ADDR_C13_DATA_1        = 10'h07c,
    ADDR_C14_DATA_0        = 10'h080, // Channel 14
    ADDR_C14_DATA_1        = 10'h084,
    ADDR_C15_DATA_0        = 10'h088, // Channel 15
    ADDR_C15_DATA_1        = 10'h08c,
    ADDR_C16_DATA_0        = 10'h090, // Channel 16
    ADDR_C16_DATA_1        = 10'h094,
    ADDR_C17_DATA_0        = 10'h098, // Channel 17
    ADDR_C17_DATA_1        = 10'h09c,
    ADDR_C18_DATA_0        = 10'h0a0, // Channel 18
    ADDR_C18_DATA_1        = 10'h0a4,
    ADDR_C19_DATA_0        = 10'h0a8, // Channel 19
    ADDR_C19_DATA_1        = 10'h0ac,
    ADDR_C20_DATA_0        = 10'h0b0, // Channel 20
    ADDR_C20_DATA_1        = 10'h0b4,
    ADDR_C21_DATA_0        = 10'h0b8, // Channel 21
    ADDR_C21_DATA_1        = 10'h0bc,
    ADDR_C22_DATA_0        = 10'h0c0, // Channel 22
    ADDR_C22_DATA_1        = 10'h0c4,
    ADDR_C23_DATA_0        = 10'h0c8, // Channel 23
    ADDR_C23_DATA_1        = 10'h0cc,
    ADDR_C24_DATA_0        = 10'h0d0, // Channel 24
    ADDR_C24_DATA_1        = 10'h0d4,
    ADDR_C25_DATA_0        = 10'h0d8, // Channel 25
    ADDR_C25_DATA_1        = 10'h0dc,
    ADDR_C26_DATA_0        = 10'h0e0, // Channel 26
    ADDR_C26_DATA_1        = 10'h0e4,
    ADDR_C27_DATA_0        = 10'h0e8, // Channel 27
    ADDR_C27_DATA_1        = 10'h0ec,
    ADDR_C28_DATA_0        = 10'h0f0, // Channel 28
    ADDR_C28_DATA_1        = 10'h0f4,
    ADDR_C29_DATA_0        = 10'h0f8, // Channel 29
    ADDR_C29_DATA_1        = 10'h0fc,
    ADDR_C30_DATA_0        = 10'h100, // Channel 30
    ADDR_C30_DATA_1        = 10'h104,
    ADDR_C31_DATA_0        = 10'h108, // Channel 31
    ADDR_C31_DATA_1        = 10'h10c,
    ADDR_STARTADDR_0       = 10'h110,
    ADDR_STARTADDR_1       = 10'h114,
    ADDR_LENGTH_0          = 10'h118,
    ADDR_LENGTH_1          = 10'h11c,
    ADDR_RESULT            = 10'h120,
    ADDR_COUNT             = 10'h124,
    ADDR_BITSTREAM_0       = 10'h128,
    ADDR_BITSTREAM_1       = 10'h12c,
    ADDR_BASHCODE          = 10'h130,
    ADDR_NEXTADDRESS_0     = 10'h134,
    ADDR_NEXTADDRESS_1     = 10'h138,
    ADDR_NEXTFILESIZE_0    = 10'h13c,
    ADDR_NEXTFILESIZE_1    = 10'h140,
    ADDR_BASH_OFFSET_0     = 10'h144,
    ADDR_BASH_OFFSET_1     = 10'h148,
    ADDR_DEVCTRL           = 10'h14c,
    ADDR_KEYLEN            = 10'h150,
    ADDR_KEY               = 10'h154,
    WRIDLE                 = 2'd0,
    WRDATA                 = 2'd1,
    WRRESP                 = 2'd2,
    RDIDLE                 = 2'd0,
    RDDATA                 = 2'd1,

    ADDR_BITS         = 10;

    //------------------------Local signal-------------------
    reg  [1:0]                    wstate = WRIDLE;
    reg  [1:0]                    wnext;
    reg  [ADDR_BITS-1:0]          waddr;
    wire [31:0]                   wmask;
    wire                          aw_hs;
    wire                          w_hs;
    reg  [1:0]                    rstate = RDIDLE;
    reg  [1:0]                    rnext;
    reg  [31:0]                   rdata;

    wire                          ar_hs;
    wire [ADDR_BITS-1:0]          raddr;
    // internal registers
    wire                          int_ap_idle;
    wire                          int_ap_ready;
    reg                           int_ap_done = 1'b0;
    reg                           int_ap_start = 1'b0;
    reg                           int_auto_restart = 1'b0;
    reg                           int_gie = 2'b0;
    reg  [1:0]                    int_ier = 2'b0;
    reg  [1:0]                    int_isr = 2'b0;

    // User regisers
    reg [63:0]                    int_file_size     = 64'd0;
    reg                           int_load_filesize = 1'b0;
    reg [63:0]                    int_start_address = 64'd0;
    reg                           int_load_address  = 1'b0;
    reg [63:0]                    int_next_filesize = 64'd0;
    reg [63:0]                    int_next_address  = 64'd0;
    reg                           int_overlap       = 1'b0;
    reg                           int_load_done     = 1'b0;
    reg                           int_dev_reset     = 1'b0;
    reg                           int_dev_continue  = 1'b0;
    reg  [1:0]                    int_dev_bytemode  = 2'b00;
    reg                           int_dev_done      = 1'b0;
    reg                           int_dev_start     = 1'b0;
    reg                           int_dev_load_text = 1'b0;
    reg  [31:0]                   int_key           = 32'd0;
    reg                           int_keywe         = 1'b0;
    reg                           int_readresult    = 1'b0;
    reg  [31:0]                   int_keylen        = 32'd0;
    reg  [31:0]                   int_result        = 32'd0;
    reg                           int_bitstreamrden = 1'b0;
    reg  [63:0]                   int_bitstream     = 64'd0;
    reg  [31:0]                   int_matchcount    = 32'd0;
    reg                           int_matchcountvld = 1'b0;
    reg  [63:0]                   int_bash_offset   = 64'd0;
    reg  [31:0]                   int_bash_code     = 32'd0;

    reg [63:0]                    int_read_addr_0 = 64'd0;
    reg [63:0]                    int_read_addr_1 = 64'd0;
    reg [63:0]                    int_read_addr_2 = 64'd0;
    reg [63:0]                    int_read_addr_3 = 64'd0;
    reg [63:0]                    int_read_addr_4 = 64'd0;
    reg [63:0]                    int_read_addr_5 = 64'd0;
    reg [63:0]                    int_read_addr_6 = 64'd0;
    reg [63:0]                    int_read_addr_7 = 64'd0;
    reg [63:0]                    int_read_addr_8 = 64'd0;
    reg [63:0]                    int_read_addr_9 = 64'd0;
    reg [63:0]                    int_read_addr_10 = 64'd0;
    reg [63:0]                    int_read_addr_11 = 64'd0;
    reg [63:0]                    int_read_addr_12 = 64'd0;
    reg [63:0]                    int_read_addr_13 = 64'd0;
    reg [63:0]                    int_read_addr_14 = 64'd0;
    reg [63:0]                    int_read_addr_15 = 64'd0;
    reg [63:0]                    int_read_addr_16 = 64'd0;
    reg [63:0]                    int_read_addr_17 = 64'd0;
    reg [63:0]                    int_read_addr_18 = 64'd0;
    reg [63:0]                    int_read_addr_19 = 64'd0;
    reg [63:0]                    int_read_addr_20 = 64'd0;
    reg [63:0]                    int_read_addr_21 = 64'd0;
    reg [63:0]                    int_read_addr_22 = 64'd0;
    reg [63:0]                    int_read_addr_23 = 64'd0;
    reg [63:0]                    int_read_addr_24 = 64'd0;
    reg [63:0]                    int_read_addr_25 = 64'd0;
    reg [63:0]                    int_read_addr_26 = 64'd0;
    reg [63:0]                    int_read_addr_27 = 64'd0;
    reg [63:0]                    int_read_addr_28 = 64'd0;
    reg [63:0]                    int_read_addr_29 = 64'd0;
    reg [63:0]                    int_read_addr_30 = 64'd0;
    reg [63:0]                    int_read_addr_31 = 64'd0;

    //------------------------Instantiation------------------

    //------------------------AXI write fsm------------------
    assign AWREADY = (~ARESET) & (wstate == WRIDLE);
    assign WREADY  = (wstate == WRDATA);
    assign BRESP   = 2'b00; // OKAY
    assign BVALID  = (wstate == WRRESP);
    assign wmask   = { {8{WSTRB[3]}}, {8{WSTRB[2]}}, {8{WSTRB[1]}}, {8{WSTRB[0]}} };
    assign aw_hs   = AWVALID & AWREADY;
    assign w_hs    = WVALID & WREADY;

    // wstate
    always @(posedge ACLK) begin
        if (ARESET)
            wstate <= WRIDLE;
        else if (ACLK_EN)
            wstate <= wnext;
    end

    // wnext
    always @(*) begin
        case (wstate)
            WRIDLE:
            if (AWVALID)
                wnext = WRDATA;
            else
                wnext = WRIDLE;
            WRDATA:
            if (WVALID)
                wnext = WRRESP;
            else
                wnext = WRDATA;
            WRRESP:
            if (BREADY)
                wnext = WRIDLE;
            else
                wnext = WRRESP;
            default:
            wnext = WRIDLE;
        endcase
    end

    // waddr
    always @(posedge ACLK) begin
        if (ACLK_EN) begin
            if (aw_hs)
                waddr <= AWADDR[ADDR_BITS-1:0];
        end
    end

    //------------------------AXI read fsm-------------------
    assign ARREADY = (~ARESET) && (rstate == RDIDLE);
    assign RDATA   = rdata;
    assign RRESP   = 2'b00; // OKAY
    assign RVALID  = (rstate == RDDATA);
    assign ar_hs   = ARVALID & ARREADY;
    assign raddr   = ARADDR[ADDR_BITS-1:0];

    // rstate
    always @(posedge ACLK) begin
        if (ARESET)
            rstate <= RDIDLE;
        else if (ACLK_EN)
            rstate <= rnext;
    end

    // rnext
    always @(*) begin
        case (rstate)
            RDIDLE:
            if (ARVALID)
                rnext = RDDATA;
            else
                rnext = RDIDLE;
            RDDATA:
            if (RREADY & RVALID)
                rnext = RDIDLE;
            else
                rnext = RDDATA;
            default:
            rnext = RDIDLE;
        endcase
    end

    // rdata
    always @(posedge ACLK) begin
        if (ACLK_EN) begin
            if (ar_hs) begin
                rdata <= 1'b0;
                case (raddr)
                    ADDR_AP_CTRL: begin
                        rdata[0] <= int_ap_start;
                        rdata[1] <= int_ap_done;
                        rdata[2] <= int_ap_idle;
                        rdata[3] <= int_ap_ready;
                        rdata[4] <= int_overlap;
                        rdata[5] <= int_load_done;
                        rdata[6] <= int_dev_done;
                        rdata[7] <= int_auto_restart;
                    end
                    ADDR_GIE: begin
                        rdata <= int_gie;
                    end
                    ADDR_IER: begin
                        rdata <= int_ier;
                    end
                    ADDR_ISR: begin
                        rdata <= int_isr;
                    end
                    ADDR_DEVCTRL: begin
                        rdata[0]   <= int_dev_reset;
                        rdata[1]   <= int_dev_continue;
                        rdata[3:2] <= int_dev_bytemode;
                        rdata[4]   <= int_dev_load_text;
                        rdata[5]   <= int_dev_start;
                    end
                    ADDR_KEYLEN:        rdata <= int_keylen;
                    ADDR_KEY:           rdata <= int_key;
                    ADDR_STARTADDR_0:   rdata <= int_start_address[31:0];
                    ADDR_STARTADDR_1:   rdata <= int_start_address[63:32];
                    ADDR_LENGTH_0:      rdata <= int_file_size[31:0];
                    ADDR_LENGTH_1:      rdata <= int_file_size[63:32];
                    ADDR_RESULT:        rdata <= int_result;
                    ADDR_COUNT:         rdata <= int_matchcount;
                    ADDR_BITSTREAM_0:   rdata <= int_bitstream[31:0];
                    ADDR_BITSTREAM_1:   rdata <= int_bitstream[63:32];
                    ADDR_BASHCODE:      rdata <= int_bash_code;
                    ADDR_NEXTADDRESS_0: rdata <= int_next_address[31:0];
                    ADDR_NEXTADDRESS_1: rdata <= int_next_address[63:32];
                    ADDR_NEXTFILESIZE_0:rdata <= int_next_filesize[31:0];
                    ADDR_NEXTFILESIZE_1:rdata <= int_next_filesize[63:32];
                    ADDR_BASH_OFFSET_0: rdata <= int_bash_offset[31:0];
                    ADDR_BASH_OFFSET_1: rdata <= int_bash_offset[63:32];
                    ADDR_C0_DATA_0:      rdata <= int_read_addr_0[31:0];
                    ADDR_C0_DATA_1:      rdata <= int_read_addr_0[63:32];
                    ADDR_C1_DATA_0:      rdata <= int_read_addr_1[31:0];
                    ADDR_C1_DATA_1:      rdata <= int_read_addr_1[63:32];
                    ADDR_C2_DATA_0:      rdata <= int_read_addr_2[31:0];
                    ADDR_C2_DATA_1:      rdata <= int_read_addr_2[63:32];
                    ADDR_C3_DATA_0:      rdata <= int_read_addr_3[31:0];
                    ADDR_C3_DATA_1:      rdata <= int_read_addr_3[63:32];
                    ADDR_C4_DATA_0:      rdata <= int_read_addr_4[31:0];
                    ADDR_C4_DATA_1:      rdata <= int_read_addr_4[63:32];
                    ADDR_C5_DATA_0:      rdata <= int_read_addr_5[31:0];
                    ADDR_C5_DATA_1:      rdata <= int_read_addr_5[63:32];
                    ADDR_C6_DATA_0:      rdata <= int_read_addr_6[31:0];
                    ADDR_C6_DATA_1:      rdata <= int_read_addr_6[63:32];
                    ADDR_C7_DATA_0:      rdata <= int_read_addr_7[31:0];
                    ADDR_C7_DATA_1:      rdata <= int_read_addr_7[63:32];
                    ADDR_C8_DATA_0:      rdata <= int_read_addr_8[31:0];
                    ADDR_C8_DATA_1:      rdata <= int_read_addr_8[63:32];
                    ADDR_C9_DATA_0:      rdata <= int_read_addr_9[31:0];
                    ADDR_C9_DATA_1:      rdata <= int_read_addr_9[63:32];
                    ADDR_C10_DATA_0:      rdata <= int_read_addr_10[31:0];
                    ADDR_C10_DATA_1:      rdata <= int_read_addr_10[63:32];
                    ADDR_C11_DATA_0:      rdata <= int_read_addr_11[31:0];
                    ADDR_C11_DATA_1:      rdata <= int_read_addr_11[63:32];
                    ADDR_C12_DATA_0:      rdata <= int_read_addr_12[31:0];
                    ADDR_C12_DATA_1:      rdata <= int_read_addr_12[63:32];
                    ADDR_C13_DATA_0:      rdata <= int_read_addr_13[31:0];
                    ADDR_C13_DATA_1:      rdata <= int_read_addr_13[63:32];
                    ADDR_C14_DATA_0:      rdata <= int_read_addr_14[31:0];
                    ADDR_C14_DATA_1:      rdata <= int_read_addr_14[63:32];
                    ADDR_C15_DATA_0:      rdata <= int_read_addr_15[31:0];
                    ADDR_C15_DATA_1:      rdata <= int_read_addr_15[63:32];
                    ADDR_C16_DATA_0:      rdata <= int_read_addr_16[31:0];
                    ADDR_C16_DATA_1:      rdata <= int_read_addr_16[63:32];
                    ADDR_C17_DATA_0:      rdata <= int_read_addr_17[31:0];
                    ADDR_C17_DATA_1:      rdata <= int_read_addr_17[63:32];
                    ADDR_C18_DATA_0:      rdata <= int_read_addr_18[31:0];
                    ADDR_C18_DATA_1:      rdata <= int_read_addr_18[63:32];
                    ADDR_C19_DATA_0:      rdata <= int_read_addr_19[31:0];
                    ADDR_C19_DATA_1:      rdata <= int_read_addr_19[63:32];
                    ADDR_C20_DATA_0:      rdata <= int_read_addr_20[31:0];
                    ADDR_C20_DATA_1:      rdata <= int_read_addr_20[63:32];
                    ADDR_C21_DATA_0:      rdata <= int_read_addr_21[31:0];
                    ADDR_C21_DATA_1:      rdata <= int_read_addr_21[63:32];
                    ADDR_C22_DATA_0:      rdata <= int_read_addr_22[31:0];
                    ADDR_C22_DATA_1:      rdata <= int_read_addr_22[63:32];
                    ADDR_C23_DATA_0:      rdata <= int_read_addr_23[31:0];
                    ADDR_C23_DATA_1:      rdata <= int_read_addr_23[63:32];
                    ADDR_C24_DATA_0:      rdata <= int_read_addr_24[31:0];
                    ADDR_C24_DATA_1:      rdata <= int_read_addr_24[63:32];
                    ADDR_C25_DATA_0:      rdata <= int_read_addr_25[31:0];
                    ADDR_C25_DATA_1:      rdata <= int_read_addr_25[63:32];
                    ADDR_C26_DATA_0:      rdata <= int_read_addr_26[31:0];
                    ADDR_C26_DATA_1:      rdata <= int_read_addr_26[63:32];
                    ADDR_C27_DATA_0:      rdata <= int_read_addr_27[31:0];
                    ADDR_C27_DATA_1:      rdata <= int_read_addr_27[63:32];
                    ADDR_C28_DATA_0:      rdata <= int_read_addr_28[31:0];
                    ADDR_C28_DATA_1:      rdata <= int_read_addr_28[63:32];
                    ADDR_C29_DATA_0:      rdata <= int_read_addr_29[31:0];
                    ADDR_C29_DATA_1:      rdata <= int_read_addr_29[63:32];
                    ADDR_C30_DATA_0:      rdata <= int_read_addr_30[31:0];
                    ADDR_C30_DATA_1:      rdata <= int_read_addr_30[63:32];
                    ADDR_C31_DATA_0:      rdata <= int_read_addr_31[31:0];
                    ADDR_C31_DATA_1:      rdata <= int_read_addr_31[63:32];
                endcase
            end
        end
    end


    //------------------------Register logic-----------------
    assign interrupt    = int_gie & (|int_isr);
    assign ap_start     = int_ap_start;
    assign int_ap_idle  = ap_idle;
    assign int_ap_ready = ap_ready;

    assign file_size = int_file_size;
    assign load_filesize = int_load_filesize;
    assign start_address = int_start_address;
    assign load_address = int_load_address;
    assign dev_reset = int_dev_reset;
    assign dev_continue = int_dev_continue;
    assign dev_bytemode = int_dev_bytemode;
    assign dev_start    = int_dev_start;
    assign dev_load_text = int_dev_load_text;
    assign key = int_key;
    assign key_we = int_keywe;
    assign rden = int_readresult;
    assign keylen = int_keylen;
    assign bitstream_rden = int_bitstreamrden;

    // int_ap_start
    always @(posedge ACLK) begin
        if (ARESET)
            int_ap_start <= 1'b0;
        else if (ACLK_EN) begin
            if (w_hs && waddr == ADDR_AP_CTRL && WSTRB[0] && WDATA[0])
                int_ap_start <= 1'b1;
            else if (int_ap_ready)
                int_ap_start <= int_auto_restart; // clear on handshake/auto restart
        end
    end

    // int_ap_done
    always @(posedge ACLK) begin
        if (ARESET)
            int_ap_done <= 1'b0;
        else if (ACLK_EN) begin
            if (ap_done)
                int_ap_done <= 1'b1;
            else if (ar_hs && raddr == ADDR_AP_CTRL)
                int_ap_done <= 1'b0; // clear on read
        end
    end

    // int_auto_restart
    always @(posedge ACLK) begin
        if (ARESET)
            int_auto_restart <= 1'b0;
        else if (ACLK_EN) begin
            if (w_hs && waddr == ADDR_AP_CTRL && WSTRB[0])
                int_auto_restart <=  WDATA[7];
        end
    end

    //int_gie
    always @(posedge ACLK) begin
        if (ARESET)
            int_gie <= 1'b0;
        else if (ACLK_EN) begin
            if (w_hs && waddr == ADDR_GIE && WSTRB[0])
                int_gie <= WDATA[0];
        end
    end

    // int_ier
    always @(posedge ACLK) begin
        if (ARESET)
            int_ier <= 1'b0;
        else if (ACLK_EN) begin
            if (w_hs && waddr == ADDR_IER && WSTRB[0])
                int_ier <= WDATA[1:0];
        end
    end

    // int_isr[0]
    always @(posedge ACLK) begin
        if (ARESET)
            int_isr[0] <= 1'b0;
        else if (ACLK_EN) begin
            if (int_ier[0] & ap_done)
                int_isr[0] <= 1'b1;
            else if (w_hs && waddr == ADDR_ISR && WSTRB[0])
                int_isr[0] <= int_isr[0] ^ WDATA[0]; // toggle on write
        end
    end

    // int_isr[1]
    always @(posedge ACLK) begin
        if (ARESET)
            int_isr[1] <= 1'b0;
        else if (ACLK_EN) begin
            if (int_ier[1] & ap_ready)
                int_isr[1] <= 1'b1;
            else if (w_hs && waddr == ADDR_ISR && WSTRB[0])
                int_isr[1] <= int_isr[1] ^ WDATA[1]; // toggle on write
        end
    end

    // int_auto_restart
    always @(posedge ACLK) begin
        if (ARESET)
            int_auto_restart <= 1'b0;
        else if (ACLK_EN) begin
            if (w_hs && waddr == ADDR_AP_CTRL && WSTRB[0])
                int_auto_restart <=  WDATA[7];
        end
    end

    //int_file_size + int_load_filesize
    always @(posedge ACLK) begin
        if (ARESET)
            int_file_size[31:0] <= 0;
        else if (ACLK_EN) begin
            if (w_hs && waddr == ADDR_LENGTH_0)
                int_file_size[31:0] <= (WDATA[31:0] & wmask) | (int_file_size[31:0] & ~wmask);
        end

        if (ARESET)
            int_file_size[63:32] <= 0;
        else if (ACLK_EN) begin
            if (w_hs && waddr == ADDR_LENGTH_1)
                int_file_size[63:32] <= (WDATA[31:0] & wmask) | (int_file_size[63:32] & ~wmask);
        end

        if (ARESET)
            int_load_filesize <= 1'b0;
        else if (ACLK_EN) begin
            if (w_hs && waddr == ADDR_LENGTH_0)
                int_load_filesize <= 1'b1;
            else
                int_load_filesize <= 1'b0;
        end
    end

    //int_start_address + int_load_address
    always @(posedge ACLK) begin
        if (ARESET)
            int_start_address[31:0] <= 0;
        else if (ACLK_EN) begin
            if (w_hs && waddr == ADDR_STARTADDR_0)
                int_start_address[31:0] <= (WDATA[31:0] & wmask) | (int_start_address[31:0] & ~wmask);
        end

        if (ARESET)
            int_start_address[63:32] <= 0;
        else if (ACLK_EN) begin
            if (w_hs && waddr == ADDR_STARTADDR_1)
                int_start_address[63:32] <= (WDATA[31:0] & wmask) | (int_start_address[63:32] & ~wmask);
        end

        if (ARESET)
            int_load_address <= 1'b0;
        else if (ACLK_EN) begin
            if (w_hs && waddr == ADDR_STARTADDR_0)
                int_load_address <= 1'b1;
            else
                int_load_address <= 1'b0;
        end
    end

    //int_next_filesize
    always @(posedge ACLK) begin
        if (ARESET)
            int_next_filesize <= 64'd0;
        else if (ACLK_EN) begin
            int_next_filesize <= next_filesize;
        end
    end

    //int_next_address
    always @(posedge ACLK) begin
        if (ARESET)
            int_next_address <= 64'd0;
        else if (ACLK_EN) begin
            int_next_address <= next_address;
        end
    end

    //int_overlap
    always @(posedge ACLK) begin
        if (ARESET)
            int_overlap <= 1'b0;
        else if (ACLK_EN) begin
            int_overlap <= overlap;
        end
    end

    //int_dev_load_text
    //int_load_done;

    reg int_loaddone_wait = 1'b0;

    always @(posedge ACLK) begin
        if (ARESET)
            int_loaddone_wait <= 1'b0;
        else if (ACLK_EN) begin
            if (int_dev_load_text) int_loaddone_wait <= 1'b1;
            else if (int_load_done) int_loaddone_wait <= 1'b0;
        end

        if (ARESET)
            int_load_done <= 1'b0;
        else if (ACLK_EN) begin
            if (load_done && int_loaddone_wait) int_load_done <= 1'b1;
            else if (ar_hs && raddr == ADDR_AP_CTRL) int_load_done <= 1'b0;
        end
    end

    //int_dev_reset
    always @(posedge ACLK) begin
        if (ARESET)
            int_dev_reset <= 1'b0;
        else if (ACLK_EN) begin
            if (w_hs && waddr == ADDR_DEVCTRL && WSTRB[0] && WDATA[0])
                int_dev_reset <= 1'b1; // Clear after set
            else
                int_dev_reset <= 1'b0;
        end
    end

    //int_dev_continue
    always @(posedge ACLK) begin
        if (ARESET)
            int_dev_continue <= 1'b0;
        else if (ACLK_EN) begin
            if (w_hs && waddr == ADDR_DEVCTRL && WSTRB[0] && WDATA[1])
                int_dev_continue <= 1'b1; // Clear after set
            else
                int_dev_continue <= 1'b0;
        end
    end

    // int_dev_bytemode
    always @(posedge ACLK) begin
        if (ARESET)
            int_dev_bytemode <= 2'b00;
        else if (ACLK_EN) begin
            if (w_hs && waddr == ADDR_DEVCTRL)
                int_dev_bytemode <= WDATA[3:2];
        end
    end

    // int_dev_done
    always @(posedge ACLK) begin
        if (ARESET)
            int_dev_done <= 1'b0;
        else if (ACLK_EN) begin
            if (dev_done)
                int_dev_done <= 1'b1;
            else if (ar_hs && raddr == ADDR_AP_CTRL)
                int_dev_done <= 1'b0; // clear on read
        end
    end

    // int_dev_load_text
    always @(posedge ACLK) begin
        if (ARESET)
            int_dev_load_text <= 1'b0;
        else if (ACLK_EN) begin
            if (w_hs && waddr == ADDR_DEVCTRL && WDATA[4])
                int_dev_load_text <= 1'b1; // Clear after set
            else
                int_dev_load_text <= 1'b0;
        end
    end

    //int_dev_start
    always @(posedge ACLK) begin
        if (ARESET)
            int_dev_start <= 1'b0;
        else if (ACLK_EN) begin
            if (w_hs && waddr == ADDR_DEVCTRL && WDATA[5])
                int_dev_start <= 1'b1; // Clear after set
            else
                int_dev_start <= 1'b0;
        end
    end

    // int_key[31:0]
    always @(posedge ACLK) begin
        if (ARESET)
            int_key <= 0;
        else if (ACLK_EN) begin
            if (w_hs && waddr == ADDR_KEY)
                int_key <= WDATA[31:0];
        end
    end

    // int_keywe
    always @(posedge ACLK) begin
        if (ARESET)
            int_keywe <= 1'b0;
        else if (ACLK_EN) begin
            if (w_hs && waddr == ADDR_KEY)
                int_keywe <= 1'b1;
            else
                int_keywe <= 1'b0;
        end
    end

    //int_keylen[5:0]
    always @(posedge ACLK) begin
        if (ARESET)
            int_keylen <= 32'd0;
        else if (ACLK_EN) begin
            if (w_hs && waddr == ADDR_KEYLEN)
                int_keylen <= WDATA[31:0]; // Clear after set
        end
    end

    //int_readresult
    always @(posedge ACLK) begin
        if (ARESET)
            int_readresult <= 1'b0;
        else if (ACLK_EN) begin
            if (ar_hs && raddr == ADDR_RESULT)
                int_readresult <= 1'b1;
            else
                int_readresult <= 1'b0;
        end
    end

    // int_result[31:0]
    always @(posedge ACLK) begin
        if (ARESET)
            int_result[31:0] <= {16'd1, 16'd0};
        else if (ACLK_EN) begin
            int_result[31:0] <= {15'd0, result};
        end
    end

    // int_bitstreamrden
    always @(posedge ACLK) begin
        if (ARESET)
            int_bitstreamrden <= 1'b0;
        else if (ACLK_EN) begin
            if (ar_hs && raddr == ADDR_BITSTREAM_0)
                int_bitstreamrden <= 1'b1;
            else
                int_bitstreamrden <= 1'b0;
        end
    end

    // int_bitstream[63:0]
    always @(posedge ACLK) begin
        if (ARESET)
            int_bitstream <= 64'd0;
        else if (ACLK_EN) begin
            int_bitstream <= bitsream;
        end
    end

    // int_matchcount[63:0] 
    always @(posedge ACLK) begin
        if (ARESET)
            int_matchcount <= 32'd0;
        else if (ACLK_EN) begin
            int_matchcount <= matchcount;
        end
    end

    // int_matchcountvld
    always @(posedge ACLK) begin
        if (ARESET)
            int_matchcountvld <= 1'b0;
        else if (ACLK_EN) begin
            if (int_dev_start) int_matchcountvld <= 1'b0;
            else if (~int_matchcountvld & matchcount_vld) int_matchcountvld <= 1'b1;
            else int_matchcountvld <= int_matchcountvld;
        end
    end

    // int_bash_code[31:0]
    always @(posedge ACLK) begin
        if (ARESET) begin
            int_bash_code <= 32'd0;
            int_bash_offset <= 64'd0;
        end
        else if (ACLK_EN) begin
            if (bash_update) begin
                int_bash_code <= bash_code;
                int_bash_offset <= bash_offset;
            end
        end
    end

    always @(posedge ACLK) begin
        if (ARESET)
            int_read_addr_0[63:0] <= 64'd0;
        else if (ACLK_EN) begin
            int_read_addr_0 <= read_addr_0;
        end
    end

    always @(posedge ACLK) begin
        if (ARESET)
            int_read_addr_1[63:0] <= 64'd0;
        else if (ACLK_EN) begin
            int_read_addr_1 <= read_addr_1;
        end
    end

    always @(posedge ACLK) begin
        if (ARESET)
            int_read_addr_2[63:0] <= 64'd0;
        else if (ACLK_EN) begin
            int_read_addr_2 <= read_addr_2;
        end
    end

    always @(posedge ACLK) begin
        if (ARESET)
            int_read_addr_3[63:0] <= 64'd0;
        else if (ACLK_EN) begin
            int_read_addr_3 <= read_addr_3;
        end
    end

    always @(posedge ACLK) begin
        if (ARESET)
            int_read_addr_4[63:0] <= 64'd0;
        else if (ACLK_EN) begin
            int_read_addr_4 <= read_addr_4;
        end
    end

    always @(posedge ACLK) begin
        if (ARESET)
            int_read_addr_5[63:0] <= 64'd0;
        else if (ACLK_EN) begin
            int_read_addr_5 <= read_addr_5;
        end
    end

    always @(posedge ACLK) begin
        if (ARESET)
            int_read_addr_6[63:0] <= 64'd0;
        else if (ACLK_EN) begin
            int_read_addr_6 <= read_addr_6;
        end
    end

    always @(posedge ACLK) begin
        if (ARESET)
            int_read_addr_7[63:0] <= 64'd0;
        else if (ACLK_EN) begin
            int_read_addr_7 <= read_addr_7;
        end
    end

    always @(posedge ACLK) begin
        if (ARESET)
            int_read_addr_8[63:0] <= 64'd0;
        else if (ACLK_EN) begin
            int_read_addr_8 <= read_addr_8;
        end
    end

    always @(posedge ACLK) begin
        if (ARESET)
            int_read_addr_9[63:0] <= 64'd0;
        else if (ACLK_EN) begin
            int_read_addr_9 <= read_addr_9;
        end
    end

    always @(posedge ACLK) begin
        if (ARESET)
            int_read_addr_10[63:0] <= 64'd0;
        else if (ACLK_EN) begin
            int_read_addr_10 <= read_addr_10;
        end
    end

    always @(posedge ACLK) begin
        if (ARESET)
            int_read_addr_11[63:0] <= 64'd0;
        else if (ACLK_EN) begin
            int_read_addr_11 <= read_addr_11;
        end
    end

    always @(posedge ACLK) begin
        if (ARESET)
            int_read_addr_12[63:0] <= 64'd0;
        else if (ACLK_EN) begin
            int_read_addr_12 <= read_addr_12;
        end
    end

    always @(posedge ACLK) begin
        if (ARESET)
            int_read_addr_13[63:0] <= 64'd0;
        else if (ACLK_EN) begin
            int_read_addr_13 <= read_addr_13;
        end
    end

    always @(posedge ACLK) begin
        if (ARESET)
            int_read_addr_14[63:0] <= 64'd0;
        else if (ACLK_EN) begin
            int_read_addr_14 <= read_addr_14;
        end
    end

    always @(posedge ACLK) begin
        if (ARESET)
            int_read_addr_15[63:0] <= 64'd0;
        else if (ACLK_EN) begin
            int_read_addr_15 <= read_addr_15;
        end
    end

    always @(posedge ACLK) begin
        if (ARESET)
            int_read_addr_16[63:0] <= 64'd0;
        else if (ACLK_EN) begin
            int_read_addr_16 <= read_addr_16;
        end
    end

    always @(posedge ACLK) begin
        if (ARESET)
            int_read_addr_17[63:0] <= 64'd0;
        else if (ACLK_EN) begin
            int_read_addr_17 <= read_addr_17;
        end
    end

    always @(posedge ACLK) begin
        if (ARESET)
            int_read_addr_18[63:0] <= 64'd0;
        else if (ACLK_EN) begin
            int_read_addr_18 <= read_addr_18;
        end
    end

    always @(posedge ACLK) begin
        if (ARESET)
            int_read_addr_19[63:0] <= 64'd0;
        else if (ACLK_EN) begin
            int_read_addr_19 <= read_addr_19;
        end
    end

    always @(posedge ACLK) begin
        if (ARESET)
            int_read_addr_20[63:0] <= 64'd0;
        else if (ACLK_EN) begin
            int_read_addr_20 <= read_addr_20;
        end
    end

    always @(posedge ACLK) begin
        if (ARESET)
            int_read_addr_21[63:0] <= 64'd0;
        else if (ACLK_EN) begin
            int_read_addr_21 <= read_addr_21;
        end
    end

    always @(posedge ACLK) begin
        if (ARESET)
            int_read_addr_22[63:0] <= 64'd0;
        else if (ACLK_EN) begin
            int_read_addr_22 <= read_addr_22;
        end
    end

    always @(posedge ACLK) begin
        if (ARESET)
            int_read_addr_23[63:0] <= 64'd0;
        else if (ACLK_EN) begin
            int_read_addr_23 <= read_addr_23;
        end
    end

    always @(posedge ACLK) begin
        if (ARESET)
            int_read_addr_24[63:0] <= 64'd0;
        else if (ACLK_EN) begin
            int_read_addr_24 <= read_addr_24;
        end
    end

    always @(posedge ACLK) begin
        if (ARESET)
            int_read_addr_25[63:0] <= 64'd0;
        else if (ACLK_EN) begin
            int_read_addr_25 <= read_addr_25;
        end
    end

    always @(posedge ACLK) begin
        if (ARESET)
            int_read_addr_26[63:0] <= 64'd0;
        else if (ACLK_EN) begin
            int_read_addr_26 <= read_addr_26;
        end
    end

    always @(posedge ACLK) begin
        if (ARESET)
            int_read_addr_27[63:0] <= 64'd0;
        else if (ACLK_EN) begin
            int_read_addr_27 <= read_addr_27;
        end
    end

    always @(posedge ACLK) begin
        if (ARESET)
            int_read_addr_28[63:0] <= 64'd0;
        else if (ACLK_EN) begin
            int_read_addr_28 <= read_addr_28;
        end
    end

    always @(posedge ACLK) begin
        if (ARESET)
            int_read_addr_29[63:0] <= 64'd0;
        else if (ACLK_EN) begin
            int_read_addr_29 <= read_addr_29;
        end
    end

    always @(posedge ACLK) begin
        if (ARESET)
            int_read_addr_30[63:0] <= 64'd0;
        else if (ACLK_EN) begin
            int_read_addr_30 <= read_addr_30;
        end
    end

    always @(posedge ACLK) begin
        if (ARESET)
            int_read_addr_31[63:0] <= 64'd0;
        else if (ACLK_EN) begin
            int_read_addr_31 <= read_addr_31;
        end
    end


    //------------------------Memory logic-------------------

endmodule