`timescale 1ns / 1ps

// Restartable rate generator.
// When run is high, it makes a one-cycle tick every CYCLE_COUNT clocks.
module restartable_rate_generator #(
    parameter int CYCLE_COUNT = 2
) (
    input  logic clk,
    input  logic run,
    output logic tick
);

  logic running;
  logic tick_qualifier;

  initial running = 1'b0;

  // Store run as state, so tick does not depend on run combinationally.
  always_ff @(posedge clk) begin
    running <= run;
  end

  assign tick = running && tick_qualifier;

  generate
    if (CYCLE_COUNT == 1) begin : g_special

      // No counter is needed. Once run has been sampled high,
      // tick is high on clocked state only.
      assign tick_qualifier = 1'b1;

    end else begin : g_general

      localparam int CountWidth = $clog2(CYCLE_COUNT);
      localparam logic [CountWidth-1:0] TickCount = CountWidth'(CYCLE_COUNT - 1);

      logic rst_count;
      logic enable_count;
      logic [CountWidth-1:0] count;

      mod_n_counter #(
          .N(CYCLE_COUNT),
          .WIDTH(CountWidth)
      ) u_count (
          .clk(clk),
          .rst(rst_count),
          .enable(enable_count),
          .count(count)
      );

      // Counter runs only when run is high.
      // If run is low, restart from zero.
      assign rst_count = !run;
      assign enable_count = run;

      // This depends only on the counter state.
      assign tick_qualifier = count == TickCount;

    end
  endgenerate

endmodule
