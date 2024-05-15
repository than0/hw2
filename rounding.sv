`include "globals.sv"
import global_types::*;

module rounding(input wire clk, input wire[22:0] normalized_mantissa, input wire Guard, input wire Sticky, input wire Sign, input rounding_mode rnd, input logic signed[9:0] exponent,
output logic[24:0] result_mantissa, output logic [9:0] post_round_exponent, output logic inexact );

wire[23:0] Mantissa;

assign Mantissa = {1'b1,normalized_mantissa[22:0]};

always @(posedge clk) begin

	//we have to make the result 0 and set it again from the start
	result_mantissa = 25'b0;
	post_round_exponent = 10'b0;
	post_round_exponent = exponent;
	//if we have an exact value
	if(Guard == 1'b0 && Sticky == 1'b0) begin
		result_mantissa = {1'b0,Mantissa[23:0]};
		inexact = 1'b0;
	end
	//if we don't have an exact value
	else begin

		inexact = 1'b1;
		//find out what kind of rounding we will do
		case (rnd)	
		default:	case ({Guard,Sticky})
				2'b10:	if(Mantissa[0])	//If the significant is odd 
						result_mantissa = Mantissa + 1;
					else
						result_mantissa = {1'b0,Mantissa[23:0]};
				2'b01:	result_mantissa = {1'b0,Mantissa[23:0]}; //if closer to 0, turncate
				2'b11:	result_mantissa = Mantissa + 1;		//if closer to 1, add 1
				endcase
		IEEE_zero:	result_mantissa = {1'b0,Mantissa[23:0]};

		IEEE_pinf:	if(Sign)
					result_mantissa = Mantissa;
				else
					result_mantissa = Mantissa + 1;		
		IEEE_ninf:	if(Sign)
					result_mantissa = Mantissa + 1;
				else
					result_mantissa = Mantissa;
		near_up:	case ({Guard,Sticky})
				2'b10:	if(Sign)	//If negative turncate, if positive add 1
						result_mantissa = Mantissa;
					else
						result_mantissa = Mantissa + 1;
				2'b01:	result_mantissa = {1'b0,Mantissa[23:0]}; //if closer to 0, turncate
				2'b11:	result_mantissa = Mantissa + 1;		//if closer to 1, add 1
				endcase	

		away_zero:	result_mantissa = Mantissa + 1;	//round away from zero
		endcase
	end

	if(result_mantissa[24]) begin
		result_mantissa = result_mantissa >> 1; //shift the result to the right by one
		post_round_exponent = exponent + 1;
	end
end


endmodule
