`include "multiplication.sv"
`include "globals.sv"
`include "main_module.sv"
import global_types::*;
module main_module_tb2;
    // Inputs
    logic [31:0] sys_a;
    logic [31:0] sys_b;
    logic [2:0] sys_rnd;
    logic sys_clk;
    // Outputs
    logic [0:7] sys_status;
    logic [31:0] sys_z;
    string rounding_mode[6] = {"IEEE_near","IEEE_zero","IEEE_pinf","IEEE_ninf","near_up","away_zero"};
    boundary_cond conditions[12] = {pos_qnan,neg_qnan,pos_snan,neg_snan,pos_inf,neg_inf,pos_zero,neg_zero,pos_denorm,neg_denorm,pos_norm,neg_norm};
  // Instantiate main_module (DUT)
  main_module dut (
    .clk(sys_clk),
    .a(sys_a),
    .b(sys_b),
    .rnd(sys_rnd),
    .status(sys_status),
    .z(sys_z)

  );

  // Bind additional functionality or assertions to main_module
  bind main_module my_dut_assertions dutbound (clk,a,b,rnd,status,z);

//Give our clock the desired period and run it forever
initial begin
	sys_clk = 0;
	forever #7500ps sys_clk = ~sys_clk;
end


    initial begin
        // Initialize input
        sys_rnd = 3'b000;
	for(int i = 0; i < 12; i++) begin
		sys_a = conditions[i];
		//$display("a = \t [bin] %b",a);
		for(int j = 0; j < 12; j++) begin
			sys_b = conditions[j];

			//$display("i = %d, j = %d",i,j);
			//$display("b = \t [bin] %b",b);

			// Wait for some time to observe the outputs
		        #64ns;

		        // Print the outputs
		        //$display("z = %b", z);
			//$display("r = %b",multiplication(rounding_mode[j],a,b));
			//$display("z = %b",z);
			
			//If output differs from expected, print everything in order to debug
			if(multiplication(rounding_mode[0],sys_a,sys_b) != sys_z) begin
				$display("found mistake");
				$display("a = %b",sys_a);
				$display("b = %b",sys_b);
				$display("mode = %s",rounding_mode[0]);
				$display("z = %b",sys_z);
				$display("r = %b",multiplication(rounding_mode[0],sys_a,sys_b));			
			end
		end
	end
    end
    
endmodule
