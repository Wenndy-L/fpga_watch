`timescale 1ns / 1ps

// Restartable rate generator.
// When running, it makes a one-cycle tick every CYCLE_COUNT clocks.
module restartable_rate_generator #(
    parameter int CYCLE_COUNT = 2
) (
    input  logic clk,
    input  logic run,
    output logic tick
);

  logic tick_qualifier;
  logic running;

  // running stores the previous run value as part of the FSM state
  initial running = 1'b0;

  always_ff @(posedge clk) begin
    running <= run;
  end

  assign tick = running && tick_qualifier;

  generate
    if (CYCLE_COUNT > 1) begin : g_general

      localparam int CountWidth = $clog2(CYCLE_COUNT);

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

      // run low restarts the counter
      assign rst_count = !run;

      // counter only counts while run is high
      assign enable_count = run;

      // tick becomes possible at the last count value
      assign tick_qualifier = count == CountWidth'(CYCLE_COUNT - 1);

    end else begin : g_special

      // CYCLE_COUNT = 1 means every running cycle is a tick
      assign tick_qualifier = 1'b1;

    end
  endgenerate

endmodule
