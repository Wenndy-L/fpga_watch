`timescale 1ns / 1ps

// Stopwatch top-level.
// button[0] starts/stops.
// button[1] is lap while running and reset while stopped.
module user_top_stopwatch_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input  logic       clk,
    /* verilator lint_off UNUSEDSIGNAL */
    input  logic [3:0] button,
    /* verilator lint_on UNUSEDSIGNAL */
    input  logic [9:0] sw,
    output logic [9:0] led,
    output logic [6:0] hours_disp,
    output logic [6:0] minutes_disp,
    output logic [6:0] seconds_disp,
    output logic       blank_hours,
    output logic       blank_minutes,
    output logic       blank_seconds
);

  logic rise_start_stop;
  logic rise_lap;

  logic counter_rst;
  logic counter_enable;
  logic lap_hold;

  logic [6:0] live_minutes;
  logic [5:0] live_seconds;
  logic [6:0] live_centiseconds;

  logic [6:0] shown_minutes;
  logic [5:0] shown_seconds;
  logic [6:0] shown_centiseconds;

  rising_edge_detector u_start_stop_edge (
      .clk(clk),
      .sig_in(button[0]),
      .rise(rise_start_stop)
  );

  rising_edge_detector u_lap_edge (
      .clk(clk),
      .sig_in(button[1]),
      .rise(rise_lap)
  );

  stopwatch_control u_control (
      .clk(clk),
      .rise_start_stop(rise_start_stop),
      .rise_lap(rise_lap),
      .counter_rst(counter_rst),
      .counter_enable(counter_enable),
      .lap_hold(lap_hold)
  );

  stopwatch_counter #(
      .CYCLES_PER_SECOND(CYCLES_PER_SECOND)
  ) u_counter (
      .clk(clk),
      .rst(counter_rst),
      .enable(counter_enable),
      .minutes(live_minutes),
      .seconds(live_seconds),
      .centiseconds(live_centiseconds)
  );

  snapshot_mux #(
      .WIDTH(7)
  ) u_minutes_snapshot (
      .clk(clk),
      .hold(lap_hold),
      .d(live_minutes),
      .q(shown_minutes)
  );

  snapshot_mux #(
      .WIDTH(6)
  ) u_seconds_snapshot (
      .clk(clk),
      .hold(lap_hold),
      .d(live_seconds),
      .q(shown_seconds)
  );

  snapshot_mux #(
      .WIDTH(7)
  ) u_centiseconds_snapshot (
      .clk(clk),
      .hold(lap_hold),
      .d(live_centiseconds),
      .q(shown_centiseconds)
  );

  assign hours_disp = shown_minutes;
  assign minutes_disp = {1'b0, shown_seconds};
  assign seconds_disp = shown_centiseconds;

  assign blank_hours = 1'b0;
  assign blank_minutes = 1'b0;
  assign blank_seconds = 1'b0;

  assign led = sw;

endmodule
