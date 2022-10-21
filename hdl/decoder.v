module decoder (
	clk,
	reset,
	bit_position,
	start,
	idle,
	valid,
	position
);

	input clk;
	input reset;
	
	input [63:0]bit_position;
	input start;
	
	output idle;
	output valid;
	output [5:0]position;
	
	wire [7:0]idx;
	
	assign idx[0] = |bit_position[7:0];
	assign idx[1] = |bit_position[15:8];
	assign idx[2] = |bit_position[23:16];
	assign idx[3] = |bit_position[31:24];
	assign idx[4] = |bit_position[39:32];
	assign idx[5] = |bit_position[47:40];
	assign idx[6] = |bit_position[55:48];
	assign idx[7] = |bit_position[63:56];
	
	reg [2:0]idx_ptr;
	reg [2:0]bit_ptr;
	
	reg [1:0]state, next;
	
	wire [7:0]wbit_position[7:0];
	wire [7:0]sel_bitposition;
	
	assign wbit_position[0] = bit_position[7:0];
	assign wbit_position[1] = bit_position[15:8];
	assign wbit_position[2] = bit_position[23:16];
	assign wbit_position[3] = bit_position[31:24];
	assign wbit_position[4] = bit_position[39:32];
	assign wbit_position[5] = bit_position[47:40];
	assign wbit_position[6] = bit_position[55:48];
	assign wbit_position[7] = bit_position[63:56];
	assign sel_bitposition = wbit_position[idx_ptr];
	
	parameter S_IDLE = 2'b00,
						S_IDXCK = 2'b01,
						S_BITCK = 2'b10,
						S_FIN = 2'b11;
					
	wire sidle = state == S_IDLE;
	wire sidxck = state == S_IDXCK;
	wire sbitck = state == S_BITCK;
	
	always @(posedge clk) begin
			if (reset) state <= S_IDLE;
			else state <= next;
	end
	
	always @(*) begin
		case (state)
			S_IDLE: next = start? S_IDXCK: S_IDLE;
			S_IDXCK: next = idx[idx_ptr]? S_BITCK: (&idx_ptr? S_FIN: S_IDXCK);
			S_BITCK: next = &bit_ptr? (&idx_ptr? S_FIN: S_IDXCK): S_BITCK;
			S_FIN: next = S_IDLE;
			default: next = S_IDLE;
		endcase
	end
	
	always @(posedge clk) 
		if (sidle) idx_ptr <= 3'd0;
		else if (sidxck) idx_ptr <= idx[idx_ptr]? (&bit_ptr?idx_ptr + 1'b1: idx_ptr): idx_ptr + 1'b1;
		else if (sbitck) idx_ptr <= &bit_ptr? idx_ptr + 1'b1: idx_ptr;
		else idx_ptr <= idx_ptr;
	
	always @(posedge clk)
		if (sidle) bit_ptr <= 3'd0;
		else if (sbitck) bit_ptr <= bit_ptr + 1'b1;
		else bit_ptr <= bit_ptr;
	
	assign idle = sidle;
	assign valid = sel_bitposition[bit_ptr] & sbitck;
	assign position = {idx_ptr,bit_ptr};
	
endmodule
