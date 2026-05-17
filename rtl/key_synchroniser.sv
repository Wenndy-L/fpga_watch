`timescale 1ns / 1ps

// Key synchroniser.
// Converts active-low asynchronous KEY inputs into active-high synchronised buttons.
module key_synchroniser (
    input  logic       clk,
    input  logic [3:0] key_n,    // active-low, asynchronous
    output logic [3:0] key_sync  // active-high, synchronised
);

  logic [3:0] key_active_high;
  logic [3:0] sync_stage1;
  logic [3:0] sync_stage2;

  // Start with no buttons pressed
  initial sync_stage1 = '0;
  initial sync_stage2 = '0;

  // KEY is active-low, so invert it first
  assign key_active_high = ~key_n;

  // Two flip-flop synchroniser
  always_ff @(posedge clk) begin
    sync_stage1 <= key_active_high;
    sync_stage2 <= sync_stage1;
  end

  assign key_sync = sync_stage2;

endmodule
