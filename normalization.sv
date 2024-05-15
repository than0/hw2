module normalization(input wire clk, input logic signed [9:0] exponent, input wire[47:0] P, output logic signed [9:0] normalized_exponent, output logic[22:0] normalized_mantissa,
output logic guard_bit, output logic sticky_bit);
	
	logic signed[9:0] exponent_plus_1;
	logic[21:0] sticky_vec1;
	logic[22:0] sticky_vec2;
	assign exponent_plus_1 = exponent + 1;

	//Implement the normalization module exactly as the diagram in the pdf shows
	always @(posedge clk) begin
		//$display("inside normalization");
		normalized_exponent = P[47] ? exponent_plus_1 : exponent;
		guard_bit = P[47] ? P[23] : P[22];
		sticky_bit = P[47] ? |P[22:0] : |P[21:0];
		normalized_mantissa = P[47] ? P[46:24] : P[45:23];
	end
	

endmodule
