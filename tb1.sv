`include "multiplication.sv"
`include "assertions.sv"
module main_module_tb1;
    // Inputs
    logic [31:0] sys_a;
    logic [31:0] sys_b;
    logic [2:0] sys_rnd;
    logic sys_clk;
    // Outputs
    logic [0:7] sys_status;
    logic [31:0] sys_z;
    string rounding_mode[6] = {"IEEE_near","IEEE_zero","IEEE_pinf","IEEE_ninf","near_up","away_zero"};
    
    // Instantiate the DUT
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
        // Initialize inputs
	for(int i = 0; i < 150; i++) begin
		sys_a = $urandom;
		//$display("a = \t [bin] %b",a);
		sys_b = $urandom;
		for(int j = 0; j < 6; j++) begin
			
			//$display("b = \t [bin] %b",b);

			//test for every signle rounding mode
		        sys_rnd = j;

			// Wait for some time to observe the outputs (4 clk periods)
		        #64ns;

			//$display("i = %d, j = %d",i,j);
		        //$display("z = %b", z);
			//$display("r = %b",multiplication(rounding_mode[j],a,b));

			//If output differs from expected, print everything in order to debug
			if(multiplication(rounding_mode[j],sys_a,sys_b) != sys_z) begin
				$display("found mistake");
				$display("a = %b",sys_a);
				$display("b = %b",sys_b);
				$display("mode = %s",rounding_mode[j]);
				$display("z = %b",sys_z);
				$display("r = %b",multiplication(rounding_mode[j],sys_a,sys_b));
			end
		end
	end
    end
    
endmodule

