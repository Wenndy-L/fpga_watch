`timescale 1ns / 1ps

// Button hold detector.
// held goes high after button is high for HOLD_CYCLES clock edges.
module button_hold_detect #(
    parameter int HOLD_CYCLES = 50_000_000
) (
    input  logic clk,
    input  logic button,
    output logic held
);

  // CountMax is the value reached after HOLD_CYCLES high samples
  localparam int CountMax = HOLD_CYCLES;
  localparam int CountWidth = $clog2(CountMax + 1);

  logic count_rst;
  logic count_enable;
  logic [CountWidth-1:0] count;

  mod_n_counter #(
      .N(CountMax + 1),
      .WIDTH(CountWidth)
  ) u_counter (
      .clk(clk),
      .rst(count_rst),
      .enable(count_enable),
      .count(count)
  );

  // Moore output: held depends only on the counter state
  assign held = count == CountWidth'(CountMax);

  // button low clears the counter on the next clock edge
  assign count_rst = !button;

  // count while button is high, then stop at held
  assign count_enable = button && !held;

endmodule
