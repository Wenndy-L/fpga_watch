`timescale 1ns / 1ps

// Integrated timepiece.
// sw[1:0] selects watch, stopwatch, or timer.
module user_top_timepiece_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input  logic       clk,
    input  logic [3:0] button,
    input  logic [9:0] sw,
    output logic [9:0] led,
    output logic [6:0] hours_disp,
    output logic [6:0] minutes_disp,
    output logic [6:0] seconds_disp,
    output logic       blank_hours,
    output logic       blank_minutes,
    output logic       blank_seconds
);

  typedef struct packed {
    logic [3:0] button;
    logic [9:0] sw;
  } ui_in_t;

  typedef struct packed {
    logic [9:0] led;
    logic [6:0] hours_disp;
    logic [6:0] minutes_disp;
    logic [6:0] seconds_disp;
    logic blank_hours;
    logic blank_minutes;
    logic blank_seconds;
  } ui_out_t;

  ui_in_t watch_in;
  ui_in_t timer_in;
  ui_in_t stopwatch_in;

  ui_out_t watch_out;
  ui_out_t timer_out;
  ui_out_t stopwatch_out;
  ui_out_t selected_out;

  logic [1:0] mode_sel;

  assign mode_sel = sw[1:0];

  user_top_watch_v4 #(
      .CYCLES_PER_SECOND(CYCLES_PER_SECOND)
  ) u_watch (
      .clk(clk),
      .button(watch_in.button),
      .sw(watch_in.sw),
      .led(watch_out.led),
      .hours_disp(watch_out.hours_disp),
      .minutes_disp(watch_out.minutes_disp),
      .seconds_disp(watch_out.seconds_disp),
      .blank_hours(watch_out.blank_hours),
      .blank_minutes(watch_out.blank_minutes),
      .blank_seconds(watch_out.blank_seconds)
  );

  user_top_timer_v1 #(
      .CYCLES_PER_SECOND(CYCLES_PER_SECOND)
  ) u_timer (
      .clk(clk),
      .button(timer_in.button),
      .sw(timer_in.sw),
      .led(timer_out.led),
      .hours_disp(timer_out.hours_disp),
      .minutes_disp(timer_out.minutes_disp),
      .seconds_disp(timer_out.seconds_disp),
      .blank_hours(timer_out.blank_hours),
      .blank_minutes(timer_out.blank_minutes),
      .blank_seconds(timer_out.blank_seconds)
  );

  user_top_stopwatch_v1 #(
      .CYCLES_PER_SECOND(CYCLES_PER_SECOND)
  ) u_stopwatch (
      .clk(clk),
      .button(stopwatch_in.button),
      .sw(stopwatch_in.sw),
      .led(stopwatch_out.led),
      .hours_disp(stopwatch_out.hours_disp),
      .minutes_disp(stopwatch_out.minutes_disp),
      .seconds_disp(stopwatch_out.seconds_disp),
      .blank_hours(stopwatch_out.blank_hours),
      .blank_minutes(stopwatch_out.blank_minutes),
      .blank_seconds(stopwatch_out.blank_seconds)
  );

  // Buttons are sent only to the selected app.
  always_comb begin
    watch_in.sw = sw;
    timer_in.sw = sw;
    stopwatch_in.sw = sw;

    watch_in.button = 4'b0000;
    timer_in.button = 4'b0000;
    stopwatch_in.button = 4'b0000;

    selected_out = watch_out;

    unique case (mode_sel)
      2'b01: begin
        stopwatch_in.button = button;
        selected_out = stopwatch_out;
      end

      2'b11: begin
        timer_in.button = button;
        selected_out = timer_out;
      end

      default: begin
        watch_in.button = button;
        selected_out = watch_out;
      end
    endcase
  end

  assign led = selected_out.led;
  assign hours_disp = selected_out.hours_disp;
  assign minutes_disp = selected_out.minutes_disp;
  assign seconds_disp = selected_out.seconds_disp;
  assign blank_hours = selected_out.blank_hours;
  assign blank_minutes = selected_out.blank_minutes;
  assign blank_seconds = selected_out.blank_seconds;

endmodule
