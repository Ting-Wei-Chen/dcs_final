`timescale 1ns/1ps

`include "pattern.sv"
`ifdef RTL
	`include "MS.sv"
`elsif GATE
	`include "MS_SYN.v"
`endif

module TESTBENCH();

logic clk,rst_n,maze,in_valid;
logic out_valid,maze_not_valid;

logic  [3:0]out_x,out_y; 

initial begin
	`ifdef RTL
		$fsdbDumpfile("MS.fsdb");
		$fsdbDumpvars(0,"+mda");
	`elsif GATE
		$sdf_annotate("MS_SYN.sdf", I_MS);
		$fsdbDumpfile("MS_SYN.fsdb");
		$fsdbDumpvars();
	`endif
end

MS I_MS
(
  .clk(clk),
  .rst_n(rst_n),
  .in_valid(in_valid),
  .maze(maze),
  .maze_not_valid(maze_not_valid),
  .out_x(out_x),
  .out_y(out_y),
  .out_valid(out_valid)
);


PATTERN I_PATTERN
(   
  .clk(clk),
  .rst_n(rst_n),
  .in_valid(in_valid),
  .maze(maze),
  .maze_not_valid(maze_not_valid),
  .out_x(out_x),
  .out_y(out_y),
  .out_valid(out_valid)
);

endmodule
