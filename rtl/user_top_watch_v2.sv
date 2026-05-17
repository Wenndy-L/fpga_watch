`timescale 1ns / 1ps

// Watch V2.
// Basic timekeeping plus edit mode selection flashing.
module user_top_watch_v2 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic clk,
    /* verilator lint_off UNUSED */
    input logic [3:0] button,
    input logic [9:0] sw,
    /* verilator lint_on UNUSED */
    output logic [9:0] led,
    output logic [6:0] hours_disp,
    output logic [6:0] minutes_disp,
    output logic [6:0] seconds_disp,
    output logic blank_hours,
    output logic blank_minutes,
    output logic blank_seconds
);

  // ------------------
  // Core Functionality
  // ------------------

  logic [5:0] seconds;
  logic [5:0] minutes;
  logic [4:0] hours;

  logic seconds_tick;
  logic minutes_tick;
  logic hours_tick;

  logic seconds_edit;
  logic minutes_edit;
  logic hours_edit;

  logic seconds_inc;
  logic minutes_inc;
  logic hours_inc;

  logic seconds_dec;
  logic minutes_dec;
  logic hours_dec;

  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) u_divider_1hz (
      .clk (clk),
      .run (1'b1),
      .tick(seconds_tick)
  );

  editable_counter #(
      .N(60),
      .WIDTH(6)
  ) u_seconds (
      .clk(clk),
      .tick(seconds_tick),
      .edit_mode(seconds_edit),
      .inc(seconds_inc),
      .dec(seconds_dec),
      .count(seconds)
  );

  editable_counter #(
      .N(60),
      .WIDTH(6)
  ) u_minutes (
      .clk(clk),
      .tick(minutes_tick),
      .edit_mode(minutes_edit),
      .inc(minutes_inc),
      .dec(minutes_dec),
      .count(minutes)
  );

  editable_counter #(
      .N(24),
      .WIDTH(5)
  ) u_hours (
      .clk(clk),
      .tick(hours_tick),
      .edit_mode(hours_edit),
      .inc(hours_inc),
      .dec(hours_dec),
      .count(hours)
  );

  assign minutes_tick = seconds_tick && (seconds == 6'd59);
  assign hours_tick = minutes_tick && (minutes == 6'd59);

  // V2 only selects the edit field. It does not edit the time yet.
  assign seconds_edit = 1'b0;
  assign minutes_edit = 1'b0;
  assign hours_edit = 1'b0;

  assign seconds_inc = 1'b0;
  assign minutes_inc = 1'b0;
  assign hours_inc = 1'b0;

  assign seconds_dec = 1'b0;
  assign minutes_dec = 1'b0;
  assign hours_dec = 1'b0;

  assign hours_disp = {2'b00, hours};
  assign minutes_disp = {1'b0, minutes};
  assign seconds_disp = {1'b0, seconds};

  assign led = 10'b0;

  // --------------
  // Mode Selection
  // --------------

  logic [2:0] mode_enable;
  logic pwm_out;

  edit_mode_selector #(
      .HOLD_CYCLES(CYCLES_PER_SECOND)
  ) u_mode_selector (
      .clk(clk),
      .button(button[3]),
      .mode_enable(mode_enable)
  );

  pwm_generator #(
      .PERIOD_CYCLES(CYCLES_PER_SECOND / 2),
      .DUTY_CYCLES  (CYCLES_PER_SECOND / 10)
  ) u_flash_pwm (
      .clk(clk),
      .rst(1'b0),
      .pwm_out(pwm_out)
  );

  assign blank_seconds = mode_enable[0] && pwm_out;
  assign blank_minutes = mode_enable[1] && pwm_out;
  assign blank_hours   = mode_enable[2] && pwm_out;

endmodule
