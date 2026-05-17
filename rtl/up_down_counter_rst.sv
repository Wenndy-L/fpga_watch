`timescale 1ns / 1ps

// Up-down counter with enable and synchronous reset.
module up_down_counter_rst #(
    parameter int MAX   = 2,
    parameter int WIDTH = 2
) (
    input logic clk,
    input logic rst,
    input logic enable,
    input logic up,
    output logic [WIDTH-1:0] count
);

  // calculated next value
  logic [WIDTH-1:0] next_count;

  // constants with fixed width
  localparam logic [WIDTH-1:0] Max = WIDTH'(MAX);
  localparam logic [WIDTH-1:0] One = WIDTH'(1);

  // start from zero in simulation
  initial count = '0;

  // decide what the next count should be
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

  // rst has priority over enable
  always_ff @(posedge clk) begin
    if (rst) begin
      count <= '0;
    end else if (enable) begin
      count <= next_count;
    end
  end

endmodule
