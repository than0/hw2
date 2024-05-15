module my_dut_assertions(clk,a,b,rnd,status,z);
input wire clk;
input wire[31:0] a,b,z;
input logic[2:0] rnd;
input logic[0:7] status;
int counter = 0;
//we initate a counter that lets us check our assertions once every 4 cycles
`ifdef immediate_assertions
//In this case we check if any two signals that shouldn't fire simultaniously have fired
//For our module to be correct, this code has to never print anything on the screen
property pr1;
	@(posedge clk) status[0] && status[1] && counter == 3;
endproperty
property1: assert property (pr1) $display("zero-inf"); else;

property pr2;
	@(posedge clk) status[0] && status[2] && counter == 3;
endproperty
property2: assert property (pr2) $display("zero-nan"); else;

property pr3;
	@(posedge clk) status[0] && status[3] && counter == 3;
endproperty
property3: assert property (pr3) $display("zero-tiny"); else;

property pr4;
	@(posedge clk) status[0] && status[4] && counter == 3;
endproperty
property4: assert property (pr4) $display("zero-huge"); else;

property pr5;
	@(posedge clk) status[1] && status[3] && counter == 3;
endproperty
property5: assert property (pr5) $display("inf-tiny"); else;

property pr6;
	@(posedge clk) status[2] && status[3] && counter == 3;
endproperty
property6: assert property (pr6) $display("nan-tiny"); else;

property pr7;
	@(posedge clk) status[2] && status[4] && counter == 3;
endproperty
property7: assert property (pr7) $display("nan-huge"); else;

property pr8;
	@(posedge clk) status[2] && status[5] && counter == 3;
endproperty
property8: assert property (pr8) $display("nan-inexact"); else;

property pr9;
	@(posedge clk) status[2] && status[6] && counter == 3;
endproperty
property9: assert property (pr9) $display("nan-overflow"); else;

property pr10;
	@(posedge clk) status[2] && status[7] && counter == 3;
endproperty
property10: assert property (pr10) $display("nan-underflow"); else;

property pr11;
	@(posedge clk) status[3] && status[4] && counter == 3;
endproperty
property11: assert property (pr11) $display("tiny-huge"); else;

property pr12;
	@(posedge clk) status[3] && status[6] && counter == 3;
endproperty
property12: assert property (pr12) $display("tiny-overflow"); else;

property pr13;
	@(posedge clk) status[4] && status[7] && counter == 3;
endproperty
property13: assert property (pr13) $display("huge-underflow"); else;

property pr14;
	@(posedge clk) status[6] && status[7] && counter == 3;
endproperty
property14: assert property (pr14) $display("overflow-underflow"); else;


`elsif concurrent_assertions
//We check the concurrent assertions described in the project's pdf
property pr1;
	@(posedge clk) status[0] && (z[30:23] == 8'b0) && counter == 3;		
endproperty
property1: assert property (pr1) $display("zero asserted"); else;

property pr2;
	@(posedge clk) status[1] && (z[30:23] == {8{1'b1}}) && counter == 3;
endproperty
property2: assert property (pr2) $display("inf asserted"); else;

property pr3;
	@(posedge clk) (((a[30:23] == 8'b0 && b[30:23] == {8{1'b1}}) || (b[30:23] == 8'b0 && a[30:23] == {8{1'b1}})) ##2 (status[2] && counter == 3)) ;
endproperty
property3: assert property (pr3) $display("nan asserted"); else;

property pr4;
	@(posedge clk) status[4] && ( z[30:23] == {8{1'b1}} || z[30:0] == {{7{1'b1}},1'b0,{23{1'b1}}} ) && counter == 3;
endproperty
property4: assert property (pr4) $display("huge asserted"); else;

property pr5;
	@(posedge clk) status[3] && ( z[30:23] == 8'b0 || z[30:0] == {8'b1,23'b0} ) && counter == 3;
endproperty
property5: assert property (pr5) $display("tiny asserted"); else;
`endif
//Code for our counter
always @(posedge clk)
begin
    if (counter == 3) // Reset the counter when it reaches 3
        counter <= 0;
    else
        counter <= counter + 1;
end

endmodule
