`timescale 1ns / 1ps
/*A parametrised synchronous up-down counter with enable.*/
module up_down_counter #(
    parameter int MAX   = 2,
    parameter int WIDTH = 2
) (
    input logic clk,
    input logic enable,
    input logic up,
    output logic [WIDTH-1:0] count
);
  /* Internal signal stores the calculated next count value */
  logic [WIDTH - 1:0] next_count;

  /* Local constants with the same width as count
    to avoid width warnings */
  localparam logic [WIDTH-1:0] Max = WIDTH'(MAX);
  localparam logic [WIDTH-1:0] One = WIDTH'(1);

  /* Initialise count to zero */
  initial count = '0;

  /*Combinational logic computes the next state value*/
  always_comb begin
    if (up) begin
      if (count < Max) begin
        next_count = count + One;
      end else begin
        next_count = '0;
      end
    end else begin
      if (count > '0) begin
        next_count = count - One;
      end else begin
        next_count = Max;
      end
    end
  end

  /*Sequential logic updates the state physically on
    the rising clock edge.*/
  always_ff @(posedge clk) begin
    if (enable) begin
      count <= next_count;
    end
  end

endmodule
