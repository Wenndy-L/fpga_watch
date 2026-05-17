`timescale 1ns / 1ps

// Stopwatch counter.
// It counts centiseconds, seconds, and minutes.
module stopwatch_counter #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input  logic       clk,
    input  logic       rst,
    input  logic       enable,
    output logic [6:0] minutes,
    output logic [5:0] seconds,
    output logic [6:0] centiseconds
);

  // one centisecond is 1/100 second
  localparam int CyclesPerCentisecond = CYCLES_PER_SECOND / 100;

  logic centisecond_tick;
  logic counter_enable;
  logic timer_run;

  // reset should also restart the centisecond timing
  assign timer_run = enable && !rst;

  restartable_rate_generator #(
      .CYCLE_COUNT(CyclesPerCentisecond)
  ) u_centisecond_tick (
      .clk (clk),
      .run (timer_run),
      .tick(centisecond_tick)
  );

  assign counter_enable = timer_run && centisecond_tick;

  cascade_counter #(
      .N2(100),
      .N1(60),
      .N0(100),
      .W2(7),
      .W1(6),
      .W0(7)
  ) u_counter (
      .clk   (clk),
      .rst   (rst),
      .enable(counter_enable),
      .count2(minutes),
      .count1(seconds),
      .count0(centiseconds)
  );

endmodule
