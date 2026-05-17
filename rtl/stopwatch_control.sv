`timescale 1ns / 1ps

// Control logic for the stopwatch.
// start_stop toggles running.
// lap toggles display hold while running, or resets when stopped.
module stopwatch_control (
    input  logic clk,
    input  logic rise_start_stop,
    input  logic rise_lap,
    output logic counter_rst,
    output logic counter_enable,
    output logic lap_hold
);

  // start from stopped, not reset, no lap hold
  initial begin
    counter_rst    = 1'b0;
    counter_enable = 1'b0;
    lap_hold       = 1'b0;
  end

  always_ff @(posedge clk) begin
    // reset is only a one-cycle pulse
    counter_rst <= 1'b0;

    // ignore if both buttons are pressed in the same cycle
    if (rise_start_stop && rise_lap) begin
      counter_enable <= counter_enable;
      lap_hold       <= lap_hold;
    end else if (rise_start_stop) begin
      // start/stop only toggles running
      counter_enable <= !counter_enable;
      lap_hold       <= lap_hold;
    end else if (rise_lap) begin
      if (counter_enable) begin
        // while running, lap freezes/unfreezes display
        lap_hold <= !lap_hold;
      end else if (!lap_hold) begin
        // while stopped and not holding a lap, lap resets the counter
        counter_rst <= 1'b1;
      end
    end
  end

endmodule
