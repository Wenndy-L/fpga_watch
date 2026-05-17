`timescale 1ns / 1ps

// Rising-edge detector.
// rise is high for one clock cycle when sig_in changes from 0 to 1.
module rising_edge_detector (
    input  logic clk,
    input  logic sig_in,
    output logic rise
);

  logic sig_in_prev;

  // Start by assuming the previous input was low
  initial sig_in_prev = 1'b0;

  // Store the previous sampled input
  always_ff @(posedge clk) begin
    sig_in_prev <= sig_in;
  end

  // A rising edge means current input is high and previous input was low
  assign rise = sig_in && !sig_in_prev;

endmodule
