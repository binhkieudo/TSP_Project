module tsp_decoder (
	clk,
	reset,
	key_length,
	ibit,
	istart,
	bash_offset,
	oaddress,
	rden,
	ovalid,
	oidle,
	full,
	empty,
	match_count,
	match_count_valid
);

parameter BLOCK64 = 512;
parameter COUNT_WIDTH = $clog2(BLOCK64*64);

input clk;
input reset;

input [8:0]key_length;
input [BLOCK64*64 - 1:0]ibit;
input istart;
input [23:0]bash_offset;

output [15:0]oaddress;
input rden;
output ovalid;
output oidle;

output full;
output empty;
output [COUNT_WIDTH-1:0]match_count;
output match_count_valid;

wire [BLOCK64-1:0]decode_finish;
wire [BLOCK64-1:0]decode_valid;
wire [5:0]decode_data[BLOCK64-1:0];

wire [15:0]       stage1_rdata[0:BLOCK64-1];
wire [BLOCK64-1:0]stage1_read;
wire [BLOCK64-1:0]stage1_valid;
wire [BLOCK64-1:0]stage1_full;
wire [BLOCK64-1:0]stage1_almost_full;
wire [BLOCK64-1:0]stage1_empty;
wire [BLOCK64-1:0]stage1_almost_empty;

// Counter loop
parameter COUNT_S1 = BLOCK64; // 512
parameter COUNT_S2 = COUNT_S1 / 4; // 128
parameter COUNT_S3 = COUNT_S2 / 4; // 32
parameter COUNT_S4 = COUNT_S3 / 4; // 8
parameter COUNT_S5 = COUNT_S4 / 4; // 2
parameter COUNT_S6 = 1;

reg count_s1_fin;
reg count_s2_fin;
reg count_s3_fin;
reg count_s4_fin;
reg count_s5_fin;
reg count_s6_fin;

reg [BLOCK64*6 - 1:0]counter_s1;
wire [ 7:0]counter_s2[COUNT_S2-1:0];
wire [ 9:0]counter_s3[COUNT_S3-1:0];
wire [11:0]counter_s4[COUNT_S4-1:0];
wire [13:0]counter_s5[COUNT_S5-1:0];
reg [14:0]counter_s6;

always @(posedge clk) begin
    count_s1_fin <= &decode_finish;
    count_s2_fin <= count_s1_fin;
    count_s3_fin <= count_s2_fin;
    count_s4_fin <= count_s3_fin;
    count_s5_fin <= count_s4_fin;
    count_s6_fin <= count_s5_fin;
end

genvar ic2, ic3, ic4, ic5;
generate
    for (ic2 = 0; ic2 < COUNT_S2; ic2 = ic2 + 1) begin: gen_counts2
        wire [5:0]term0 = counter_s1[ic2*24 +  5 -:6];
        wire [5:0]term1 = counter_s1[ic2*24 + 11 -:6];
        wire [5:0]term2 = counter_s1[ic2*24 + 17 -:6];
        wire [5:0]term3 = counter_s1[ic2*24 + 23 -:6];
        
        reg [7:0]tmp_counts2;
        
        always @(posedge clk) 
            if (reset) tmp_counts2 <= 8'd0;
            else tmp_counts2 <= term0 + term1 + term2 + term3;
            
        assign counter_s2[ic2] = tmp_counts2;
    end
endgenerate

generate
    for (ic3 = 0; ic3 < COUNT_S3; ic3 = ic3 + 1) begin: gen_counts3
        wire [7:0]term0 = counter_s2[ic3*4];
        wire [7:0]term1 = counter_s2[ic3*4 + 1];
        wire [7:0]term2 = counter_s2[ic3*4 + 2];
        wire [7:0]term3 = counter_s2[ic3*4 + 3];
        
        reg [9:0]tmp_counts3;
        
        always @(posedge clk) 
            if (reset) tmp_counts3 <= 10'd0;
            else tmp_counts3 <= term0 + term1 + term2 + term3;
            
        assign counter_s3[ic3] = tmp_counts3;
    end
endgenerate

generate
    for (ic4 = 0; ic4 < COUNT_S4; ic4 = ic4 + 1) begin: gen_counts4
        wire [9:0]term0 = counter_s3[ic4*4];
        wire [9:0]term1 = counter_s3[ic4*4 + 1];
        wire [9:0]term2 = counter_s3[ic4*4 + 2];
        wire [9:0]term3 = counter_s3[ic4*4 + 3];
        
        reg [11:0]tmp_counts4;
        
        always @(posedge clk) 
            if (reset) tmp_counts4 <= 12'd0;
            else tmp_counts4 <= term0 + term1 + term2 + term3;
            
        assign counter_s4[ic4] = tmp_counts4;
    end
endgenerate

generate
    for (ic5 = 0; ic5 < COUNT_S5; ic5 = ic5 + 1) begin: gen_counts5
        wire [11:0]term0 = counter_s4[ic5*4];
        wire [11:0]term1 = counter_s4[ic5*4 + 1];
        wire [11:0]term2 = counter_s4[ic5*4 + 2];
        wire [11:0]term3 = counter_s4[ic5*4 + 3];
        
        reg [13:0]tmp_counts5;
        
        always @(posedge clk) 
            if (reset) tmp_counts5 <= 14'd0;
            else tmp_counts5 <= term0 + term1 + term2 + term3;
            
        assign counter_s5[ic5] = tmp_counts5;
    end
endgenerate

always @(posedge clk) begin
    if (reset) counter_s6 <= 14'd0;
    else counter_s6 <= counter_s5[0] + counter_s5[1];
end

assign match_count = counter_s6;
assign match_count_valid = count_s6_fin;

// Stage 1 (512 Blocks)
genvar is1;
generate
	for (is1 = 0; is1 < BLOCK64; is1 = is1 + 1) begin: stage1_gen
		wire [63:0]bit_position = ibit[(is1+1)*64 - 1 -: 64];
		wire [5:0]decoded_address;
		wire [9:0]s1_index = is1[9:0];
		
		decoder decoder_inst(
			.clk(clk),
			.reset(reset),
			.bit_position(bit_position),
			.start(istart),
			.idle(decode_finish[is1]),
			.valid(decode_valid[is1]),
			.position(decoded_address)
		);

        fifo fifo_s1(
            .clk(clk),
            .reset(reset),
            .wrdata(decoded_address),
            .wren(decode_valid[is1]),
            .rddata(decode_data[is1]),
            .rddata_vld(stage1_valid[is1]),
            .rden(stage1_read[is1]),
            .full(stage1_full[is1]),
            .almost_full(stage1_almost_full[is1]),
            .empty(stage1_empty[is1]),
            .almost_empty(stage1_almost_empty[is1])
        );
        defparam fifo_s1.FIFO_DEPTH = 32;
        defparam fifo_s1.FIFO_WIDTH = 6;
        
        assign stage1_rdata[is1] = {s1_index ,decode_data[is1]};
        
        always @(posedge clk) 
            if (reset) counter_s1[(is1+1)*6 - 1 -: 6] <= 6'd0;
            else if (decode_valid[is1] == 1'b1)
                counter_s1[(is1+1)*6 - 1 -: 6] <= counter_s1[(is1+1)*6 - 1 -: 6] + 1'b1;
	end
endgenerate

// Stage 2 (64 Blocks)
parameter STAGE2_BLOCKS = BLOCK64 / 8;

wire [15:0]stage2_rdata[0:STAGE2_BLOCKS-1];
wire [STAGE2_BLOCKS-1:0]stage2_rden;
wire [STAGE2_BLOCKS-1:0]stage2_rvalid;
wire [STAGE2_BLOCKS-1:0]stage2_empty;
reg [STAGE2_BLOCKS-1:0]stage2_finish;

genvar is2;
generate
	for (is2 = 0; is2 < STAGE2_BLOCKS; is2 = is2 + 1) begin: stage2_gen
		reg s2fifo_wen;
		wire s2fifo_full;
		wire s2fifo_almostfull;
		wire s2fifo_empty;
		wire s2fifo_almostempty;
		wire [7:0]stage2_selectindex = stage1_valid[(is2+1)*8 - 1 -: 8] & {8{~s2fifo_full}};
		
		wire [15:0]stage2_channel0 = stage1_rdata[is2*8];
		wire [15:0]stage2_channel1 = stage1_rdata[is2*8 + 1];
		wire [15:0]stage2_channel2 = stage1_rdata[is2*8 + 2];
		wire [15:0]stage2_channel3 = stage1_rdata[is2*8 + 3];
		wire [15:0]stage2_channel4 = stage1_rdata[is2*8 + 4];
		wire [15:0]stage2_channel5 = stage1_rdata[is2*8 + 5];
		wire [15:0]stage2_channel6 = stage1_rdata[is2*8 + 6];
		wire [15:0]stage2_channel7 = stage1_rdata[is2*8 + 7];
		
		wire [15:0]stage2_selecteddata 	= stage2_selectindex[0]? stage2_channel0:
										  stage2_selectindex[1]? stage2_channel1:
										  stage2_selectindex[2]? stage2_channel2:
										  stage2_selectindex[3]? stage2_channel3:
										  stage2_selectindex[4]? stage2_channel4:
										  stage2_selectindex[5]? stage2_channel5:
										  stage2_selectindex[6]? stage2_channel6: 
										  stage2_selectindex[7]? stage2_channel7:
										  16'd0;
											  
		wire stage2_datavalid = |stage2_selectindex;
		
		wire [7:0]stage1_nempty = ~stage1_empty[(is2+1)*8 - 1 -: 8];
		wire [7:0]stage1_readindex = stage1_nempty & {8{~s2fifo_full}};
		wire [7:0]stage1_readback = stage1_readindex[0]?  8'd1:
									stage1_readindex[1]?  8'd2:
									stage1_readindex[2]?  8'd4:
									stage1_readindex[3]?  8'd8:
									stage1_readindex[4]?  8'd16:
									stage1_readindex[5]?  8'd32:
									stage1_readindex[6]?  8'd64:
									stage1_readindex[7]?  8'd128: 
									8'd0;
									
		assign stage1_read[(is2+1)*8 - 1 -: 8] = stage1_readback & {8{!s2fifo_full & !s2fifo_almostfull}};
		always @(posedge clk) stage2_finish[is2] <= &decode_finish[(is2+1)*8 - 1 -: 8] & (&stage1_empty[(is2+1)*8 - 1 -: 8]) &stage2_empty[is2];
		
		always @(posedge clk) s2fifo_wen <= (|stage1_readback) & !s2fifo_full & !s2fifo_almostfull;
		
		fifo fifo_s2(
            .clk        (clk),
            .reset      (reset),
            .wrdata     (stage2_selecteddata),
            .wren       (s2fifo_wen),
            .rddata     (stage2_rdata[is2]),
            .rddata_vld (stage2_rvalid[is2]),
            .rden       (stage2_rden[is2]),
            .full       (s2fifo_full),
            .almost_full(s2fifo_almostfull),
            .empty      (stage2_empty[is2]),
            .almost_empty(s2fifo_almostempty)
        );
        defparam fifo_s2.FIFO_DEPTH = 8;
        defparam fifo_s2.FIFO_WIDTH = 16;
	end
endgenerate

// stage 3 (8 Blocks)
parameter STAGE3_BLOCKS = STAGE2_BLOCKS / 8;

wire [15:0]stage3_rdata[0:STAGE3_BLOCKS-1];
wire [STAGE3_BLOCKS-1:0]stage3_rden;
wire [STAGE3_BLOCKS-1:0]stage3_rvalid;
wire [STAGE3_BLOCKS-1:0]stage3_empty;
reg [STAGE3_BLOCKS-1:0]stage3_finish;

genvar is3;
generate
	for (is3 = 0; is3 < STAGE3_BLOCKS; is3 = is3 + 1) begin: stage3_gen
		reg s3fifo_wen;
		wire s3fifo_full;
		wire s3fifo_almostfull;
		wire s3fifo_empty;
		wire s3fifo_almostempty;
		wire [7:0]stage3_selectindex = stage2_rvalid[(is3+1)*8 - 1 -: 8] & {8{~s3fifo_full}};
		
		wire [15:0]stage3_channel0 = stage2_rdata[is3*8];
		wire [15:0]stage3_channel1 = stage2_rdata[is3*8 + 1];
		wire [15:0]stage3_channel2 = stage2_rdata[is3*8 + 2];
		wire [15:0]stage3_channel3 = stage2_rdata[is3*8 + 3];
		wire [15:0]stage3_channel4 = stage2_rdata[is3*8 + 4];
		wire [15:0]stage3_channel5 = stage2_rdata[is3*8 + 5];
		wire [15:0]stage3_channel6 = stage2_rdata[is3*8 + 6];
		wire [15:0]stage3_channel7 = stage2_rdata[is3*8 + 7];
		
		wire [15:0]stage3_selecteddata 	= stage3_selectindex[0]? stage3_channel0:
										  stage3_selectindex[1]? stage3_channel1:
										  stage3_selectindex[2]? stage3_channel2:
										  stage3_selectindex[3]? stage3_channel3:
										  stage3_selectindex[4]? stage3_channel4:
										  stage3_selectindex[5]? stage3_channel5:
										  stage3_selectindex[6]? stage3_channel6: 
										  stage3_selectindex[7]? stage3_channel7:
										  16'd0;
											  
		wire stage3_datavalid = |stage3_selectindex;
		
		wire [7:0]stage2_nempty = ~stage2_empty[(is3+1)*8 - 1 -: 8];
		wire [7:0]stage2_readindex = stage2_nempty & {8{~s3fifo_full}};
		wire [7:0]stage2_readback = stage2_readindex[0]?  8'd1:
									stage2_readindex[1]?  8'd2:
									stage2_readindex[2]?  8'd4:
									stage2_readindex[3]?  8'd8:
									stage2_readindex[4]?  8'd16:
									stage2_readindex[5]?  8'd32:
									stage2_readindex[6]?  8'd64:
									stage2_readindex[7]?  8'd128: 
									8'd0;
									
		assign stage2_rden[(is3+1)*8 - 1 -: 8] = stage2_readback & {8{!s3fifo_full & !s3fifo_almostfull}};
		always @(posedge clk) stage3_finish[is3] <= &stage2_finish[(is3+1)*8 - 1 -: 8] & (&stage2_empty[(is3+1)*8 - 1 -: 8]) & stage3_empty[is3];
		
		always @(posedge clk) s3fifo_wen <= (|stage2_readback) & !s3fifo_full & !s3fifo_almostfull;
		
		fifo fifo_s3(
            .clk        (clk),
            .reset      (reset),
            .wrdata     (stage3_selecteddata),
            .wren       (s3fifo_wen),
            .rddata     (stage3_rdata[is3]),
            .rddata_vld (stage3_rvalid[is3]),
            .rden       (stage3_rden[is3]),
            .full       (s3fifo_full),
            .almost_full(s3fifo_almostfull),
            .empty      (stage3_empty[is3]),
            .almost_empty(s3fifo_almostempty)
        );
        defparam fifo_s3.FIFO_DEPTH = 8;
        defparam fifo_s3.FIFO_WIDTH = 16;
	end
endgenerate


// stage 4 (1 blocks)
reg s4fifo_wen;
wire [15:0]s4_wdata;
wire [15:0]s4_rdata;
wire stage4_rvalid;
wire stage4_rden;
wire s4fifo_full;
wire s4fifo_almostfull;
wire s4fifo_empty;
wire s4fifo_almostempty;
wire [7:0]stage4_selectindex = stage3_rvalid & {8{~s4fifo_full}};

wire [15:0]stage4_channel0 = stage3_rdata[0];
wire [15:0]stage4_channel1 = stage3_rdata[1];
wire [15:0]stage4_channel2 = stage3_rdata[2];
wire [15:0]stage4_channel3 = stage3_rdata[3];
wire [15:0]stage4_channel4 = stage3_rdata[4];
wire [15:0]stage4_channel5 = stage3_rdata[5];
wire [15:0]stage4_channel6 = stage3_rdata[6];
wire [15:0]stage4_channel7 = stage3_rdata[7];
							  
wire stage4_datavalid = |stage4_selectindex;

wire [7:0]stage3_nempty = ~stage3_empty;
wire [7:0]stage3_readindex = stage3_nempty  & {8{~s4fifo_full}};
wire [7:0]stage3_readback = stage3_readindex[0]?  8'd1:
							stage3_readindex[1]?  8'd2:
							stage3_readindex[2]?  8'd4:
							stage3_readindex[3]?  8'd8:
							stage3_readindex[4]?  8'd16:
							stage3_readindex[5]?  8'd32:
							stage3_readindex[6]?  8'd64:
							stage3_readindex[7]?  8'd128: 
							8'd0;

wire [15:0]stage4_selecteddata 	= stage4_selectindex[0]? stage4_channel0:
								  stage4_selectindex[1]? stage4_channel1:
								  stage4_selectindex[2]? stage4_channel2:
								  stage4_selectindex[3]? stage4_channel3:
								  stage4_selectindex[4]? stage4_channel4:
								  stage4_selectindex[5]? stage4_channel5:
								  stage4_selectindex[6]? stage4_channel6:
								  stage4_selectindex[7]? stage4_channel7:
								  16'd0;
								  		  
reg stage4_finish;// = &stage3_finish;
always @(posedge clk) stage4_finish <= &stage3_finish;					
								
assign stage3_rden = stage3_readback & {STAGE3_BLOCKS{!s4fifo_full & !s4fifo_almostfull}};

// Send end code
parameter SF_IDLE = 3'd0,
						SF_WAIT = 3'd1,
						SF_ENDCODE = 3'd2,
						SF_BASHCODE0 = 3'd3,
						SF_BASHCODE1 = 3'd4,
						SF_FINISH = 3'd5;
						
reg [2:0]final_state, final_nextstate;

wire sfidle = final_state == SF_IDLE;
wire sfwait = final_state == SF_WAIT;
wire sfendcode = final_state == SF_ENDCODE;
wire sfbashcode0 = final_state == SF_BASHCODE0;
wire sfbashcode1 = final_state == SF_BASHCODE1;
wire sffinish = final_state == SF_FINISH;

always @(posedge clk) begin
	if (reset) final_state <= SF_IDLE;
	else final_state <= final_nextstate;
end

always @(*) begin
	case (final_state)
		SF_IDLE: final_nextstate <= ~stage4_finish? SF_WAIT: SF_IDLE;
		SF_WAIT: final_nextstate <= (stage4_finish & empty & (&stage3_empty))? SF_ENDCODE: SF_WAIT;
		SF_ENDCODE: final_nextstate <= SF_FINISH;
		SF_BASHCODE0: final_nextstate <= SF_BASHCODE1;
		SF_BASHCODE1:final_nextstate <= SF_FINISH;
		SF_FINISH: final_nextstate <= SF_IDLE;
		default: final_nextstate <= SF_IDLE;
	endcase
end

always @(posedge clk) s4fifo_wen <= |stage3_readback & !s4fifo_full & !s4fifo_almostfull;

assign s4_wdata = (sfidle | sfwait)? stage4_selecteddata - key_length:
					sfendcode? 16'hffff:
					sfbashcode0? bash_offset[15:0]:
					sfbashcode1? {8'd0, bash_offset[23:16]}: 16'hffff;
assign stage4_rden = rden;

fifo fifo_s4(
   .clk        (clk),
   .reset      (reset),
   .wrdata     (s4_wdata),
   .wren       (s4fifo_wen | sfendcode | sfbashcode0 | sfbashcode1),
   .rddata     (s4_rdata),
   .rddata_vld (stage4_rvalid),
   .rden       (stage4_rden),
   .full       (s4fifo_full),
   .almost_full(s4fifo_almostfull),
   .empty      (s4fifo_empty),
   .almost_empty(s4fifo_almostempty)
);
defparam fifo_s4.FIFO_DEPTH = 8;
defparam fifo_s4.FIFO_WIDTH = 16;

assign oaddress = s4_rdata;
assign ovalid = stage4_rvalid;
assign oidle = sfidle;
assign full = s4fifo_full;
assign empty = s4fifo_empty;

endmodule
