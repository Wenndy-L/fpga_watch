`timescale 1ns / 1ps

// Button hold pulse.
// pulse goes high for one clock cycle when the hold threshold is reached.
module button_hold_pulse #(
    parameter int HOLD_CYCLES = 50_000_000
) (
    input  logic clk,
    input  logic button,
    output logic pulse
);

  logic held;

  button_hold_detect #(
      .HOLD_CYCLES(HOLD_CYCLES)
  ) u_detect (
      .clk(clk),
      .button(button),
      .held(held)
  );

  rising_edge_detector u_detector (
      .clk(clk),
      .sig_in(held),
      .rise(pulse)
  );

endmodule
