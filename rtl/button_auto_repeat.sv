`timescale 1ns / 1ps

// Button auto repeat.
// A short press gives one pulse; holding gives repeated pulses.
module button_auto_repeat #(
    parameter int HOLD_CYCLES = 50_000_000,

    // REPEAT_CYCLES must be smaller than HOLD_CYCLES
    parameter int REPEAT_CYCLES = 5_000_000
) (
    input  logic clk,
    input  logic button,
    output logic pulse
);

  // Start hold detection before the required first repeat.
  // The +1 fixes the clock-edge alignment with the repeat generator.
  localparam int HoldBeforeRepeatCycles = HOLD_CYCLES - REPEAT_CYCLES + 1;

  logic rise;
  logic held;
  logic pulse_train;

  rising_edge_detector u_edge (
      .clk(clk),
      .sig_in(button),
      .rise(rise)
  );

  button_hold_detect #(
      .HOLD_CYCLES(HoldBeforeRepeatCycles)
  ) u_hold_detect (
      .clk(clk),
      .button(button),
      .held(held)
  );

  restartable_rate_generator #(
      .CYCLE_COUNT(REPEAT_CYCLES)
  ) u_repeat_rate (
      .clk (clk),
      .run (held),
      .tick(pulse_train)
  );

  // Immediate pulse on press, then repeat pulses while the button is still held
  assign pulse = rise | (button & pulse_train);

endmodule
