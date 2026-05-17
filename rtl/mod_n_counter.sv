`timescale 1ns / 1ps

// Modulo-N counter with synchronous reset.
// Counts from 0 to N-1, then wraps back to 0.
module mod_n_counter #(
    parameter int N     = 4,
    parameter int WIDTH = 2
) (
    input logic clk,
    input logic rst,
    input logic enable,
    output logic [WIDTH-1:0] count
);

  // Max count value is N-1, not N
  localparam logic [WIDTH-1:0] MaxCount = WIDTH'(N - 1);
  localparam logic [WIDTH-1:0] One = WIDTH'(1);

  logic [WIDTH-1:0] next_count;

  // Start from zero
  initial count = '0;

  // Work out what the next count should be
  always_comb begin
    if (count < MaxCount) begin
      next_count = count + One;
    end else begin
      next_count = '0;
    end
  end

  // rst has priority over enable
  always_ff @(posedge clk) begin
    if (rst) begin
      count <= '0;
    end else if (enable) begin
      count <= next_count;
    end
  end

endmodule
