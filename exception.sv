`include "globals.sv"
import global_types::*;

module EHM(input wire[31:0] a, input wire[31:0] b, input wire[31:0] z_calc, input wire overflow, input wire underflow, input wire inexact, input rounding_mode rnd,
output logic[31:0] z, output logic zero_f, output logic inf_f, output logic nan_f, output logic tiny_f, output logic huge_f, output logic inexact_f);

typedef enum logic[2:0] {ZERO, INF, NORM, MIN_NORM, MAX_NORM} interp_t;
interp_t A_interp, B_interp;

//Implementation of the function num_interp as requested
function interp_t num_interp(logic[31:0] vec);
	if(vec[30:23] == 8'b0)
		return ZERO;
	else if(vec[30:23] ==8'b11111111)
		return INF;
	else	return NORM;
endfunction

//Implementation of the function z_num as requested
function logic[30:0] z_num(interp_t val);
	case(val)
	ZERO: 		return 31'b0;
	INF:		return {{8{1'b1}},{23{1'b0}}};
	MIN_NORM:	return {8'b1,23'b0};
	MAX_NORM:	return {{7{1'b1}},1'b0,{23{1'b1}}};
	endcase
endfunction

always_comb begin
	//$display("inside exception");

	//start by setting all the status signals to 0
	zero_f = 0;
	inf_f = 0;
	nan_f = 0;
	tiny_f = 0;
	huge_f = 0;
	inexact_f = 0;

	A_interp = num_interp(a);
	B_interp = num_interp(b);
	//The code below seperates each case for a and b and returns the correct result z and status, based also on the rounding mode
	casex({A_interp,B_interp})
	{ZERO,ZERO},{ZERO,NORM},{NORM,ZERO}:	begin				
						z = {z_calc[31],z_num(ZERO)};
						zero_f = 1'b1;
						end
	{ZERO,INF},{INF,ZERO}:			begin
						z = {1'b0,z_num(INF)};
						nan_f = 1'b1;
						end
	{INF,INF},{INF,NORM},{NORM,INF}:	begin
						z = {z_calc[31],z_num(INF)};
						inf_f = 1'b1;
						huge_f = 1'b1;
						end
	{NORM,NORM}:				if(overflow)
							case(rnd)
							IEEE_zero:			begin
											z = {z_calc[31],z_num(MAX_NORM)}; 
											huge_f = 1'b1;
											inexact_f = 1'b1;
											end
							near_up,IEEE_near,away_zero: 	begin
											z = {z_calc[31],z_num(INF)};
											huge_f = 1'b1;
											inf_f = 1'b1;
											inexact_f = 1'b1;
											end
							IEEE_pinf: 			if(z_calc[31]) begin
												z = {z_calc[31],z_num(MAX_NORM)};
												huge_f = 1'b1;
												inexact_f = 1'b1;
											end
											else begin
												z = {z_calc[31],z_num(INF)};
												huge_f = 1'b1;
												inf_f = 1'b1;
												inexact_f = 1'b1;
											end
							IEEE_ninf: 			if(z_calc[31]) begin
												z = {z_calc[31],z_num(INF)};
												huge_f = 1'b1;
												inf_f = 1'b1;
												inexact_f = 1'b1;
											end
											else begin
												z = {z_calc[31],z_num(MAX_NORM)};
												huge_f = 1'b1;
												inexact_f = 1'b1;
											end
							default:			begin
											z = {z_calc[31],z_num(MAX_NORM)}; 
											huge_f = 1'b1;
											inexact_f = 1'b1;
											end
							endcase
						else if(underflow)
							case(rnd)
							away_zero: 			begin
											z = {z_calc[31],z_num(MIN_NORM)};
											tiny_f = 1'b1;
											inexact_f = 1'b1;
											end
							near_up,IEEE_near,IEEE_zero: 	begin
											z = {z_calc[31], z_num(ZERO)};
											inexact_f = 1'b1;
											end
							IEEE_pinf: 			if(z_calc[31]) begin
											z = {z_calc[31],z_num(ZERO)};
											inexact_f = 1'b1;
											end
											else begin
											z = {z_calc[31],z_num(MIN_NORM)};
											tiny_f = 1'b1;
											inexact_f = 1'b1;
											end
							IEEE_ninf: 			if(z_calc[31]) begin
											z = {z_calc[31],z_num(MIN_NORM)};
											tiny_f = 1'b1;
											inexact_f = 1'b1;
											end
											else begin
											z = {z_calc[31],z_num(ZERO)};
											inexact_f = 1'b1;
											end
							default: 			begin
											z = {z_calc[31],z_num(MIN_NORM)};
											inexact_f = 1'b1;
											end
							endcase
						else 	begin		//in this case we don't have an exception
							z = z_calc;
							inexact_f = inexact;
							end
	endcase
end
endmodule 
