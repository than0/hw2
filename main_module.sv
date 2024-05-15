`include "globals.sv"
import global_types::*;
module main_module(input wire clk, input wire[31:0] a, input wire[31:0] b, input logic[2:0] rnd, output logic[0:7] status, output logic[31:0] z);
	rounding_mode rndm;
	wire sign_xor,zero_f,inf_f,nan_f,tiny_f,huge_f,inexact_f, guard_bit,sticky_bit,inexact;
	logic signed [9:0] added_exp, post_round_exponent;
	wire[47:0] mult_mantissa;
	logic[7:0] exp1, exp2, corrected_exponent;
	logic signed [9:0] normalized_exponent;
 	wire[22:0] normalized_mantissa;
	wire[24:0] post_round_mantissa;
	logic overflow, underflow;
	logic[31:0] z_calc;
	
	assign sign_xor = a[31] ^ b[31];		//make the XOR gate for the sign
	assign exp1 = a[30:23];
	assign exp2 = b[30:23];
	assign added_exp = exp1 + exp2 - 127;		//add the exponents
	assign mult_mantissa = {1'b1,a[22:0]} * {1'b1,b[22:0]};		//multiply the mantissas

	//Instantiate the normalization,rounding and exception modules and connect them with the respective wires
	normalization norm(.clk(clk),.exponent(added_exp),.P(mult_mantissa),.normalized_exponent(normalized_exponent),.normalized_mantissa(normalized_mantissa),.guard_bit(guard_bit),.sticky_bit(sticky_bit));
	rounding round(clk,normalized_mantissa,guard_bit,sticky_bit,sign_xor,rndm,normalized_exponent,post_round_mantissa,post_round_exponent, inexact);
	EHM exception(a,b,z_calc,overflow,underflow,inexact,rndm,z,zero_f,inf_f,nan_f,tiny_f,huge_f,inexact_f);

//This code is to simply cast the 3 bit rounding mode input to our rounding enum
always @rnd
	$cast(rndm,rnd);

//Implement the overflow and underflow detection system
always @(posedge clk) begin
	//$display("inside main");
	//$display("added_exponent: %b", added_exp);
	//$display("exp1 + exp2 = %b",exp1+exp2);
	//$display("post round exponent: %b",post_round_exponent);
	if(post_round_exponent > 254)
		begin
		overflow = 1'b1;
		underflow = 1'b0;
		//corrected_exponent = {1'b0,{7{1'b1}}};
		//$display("detected overflow");
		end
	else if(post_round_exponent < 1)
		begin
		overflow = 1'b0;
		underflow = 1'b1;
		//$display("detected underflow");
		//corrected_exponent = {1'b1,{6{1'b0}},2'b10};	
		end
	else
		begin
		overflow = 1'b0;
		underflow = 1'b0;
		//corrected_exponent = post_round_exponent[7:0];
		end
	//The main module also generates the z_calc and status signals
	z_calc = {sign_xor, post_round_exponent[7:0], post_round_mantissa[22:0]};
	status = {zero_f,inf_f,nan_f,tiny_f,huge_f,inexact_f,overflow,underflow};
end
endmodule
