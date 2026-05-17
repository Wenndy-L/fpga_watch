`timescale 1ns / 1ps

// Snapshot mux.
// When hold is low, q follows d.
// When hold is high, q keeps the saved value.
module snapshot_mux #(
    parameter int WIDTH = 1
) (
    input  logic             clk,
    input  logic             hold,
    input  logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);

  logic [WIDTH-1:0] saved;

  // saved value starts at zero
  initial saved = '0;

  // while not holding, keep saving the live input
  always_ff @(posedge clk) begin
    if (!hold) begin
      saved <= d;
    end
  end

  // output live value or saved value
  always_comb begin
    if (hold) begin
      q = saved;
    end else begin
      q = d;
    end
  end

endmodule
