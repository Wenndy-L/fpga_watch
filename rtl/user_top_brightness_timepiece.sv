`timescale 1ns / 1ps

// Brightness wrapper around the full timepiece.
// sw[9:8] controls display brightness using grey code.
module user_top_brightness_timepiece #(
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

  localparam int PwmPeriodCycles = CYCLES_PER_SECOND / 1000;
  localparam int PwmWidth = $clog2(PwmPeriodCycles);

  localparam logic [PwmWidth-1:0] DutyDim = PwmWidth'(PwmPeriodCycles / 8);
  localparam logic [PwmWidth-1:0] DutyLow = PwmWidth'(PwmPeriodCycles / 4);
  localparam logic [PwmWidth-1:0] DutyMedium = PwmWidth'(PwmPeriodCycles / 2);

  logic [PwmWidth-1:0] pwm_count;
  logic [1:0] brightness_sel;

  logic app_blank_hours;
  logic app_blank_minutes;
  logic app_blank_seconds;

  logic dim_on;
  logic low_on;
  logic medium_on;
  logic brightness_on;
  logic brightness_blank;

  assign brightness_sel = sw[9:8];

  user_top_timepiece_v1 #(
      .CYCLES_PER_SECOND(CYCLES_PER_SECOND)
  ) u_timepiece (
      .clk(clk),
      .button(button),
      .sw(sw),
      .led(led),
      .hours_disp(hours_disp),
      .minutes_disp(minutes_disp),
      .seconds_disp(seconds_disp),
      .blank_hours(app_blank_hours),
      .blank_minutes(app_blank_minutes),
      .blank_seconds(app_blank_seconds)
  );

  mod_n_counter #(
      .N(PwmPeriodCycles),
      .WIDTH(PwmWidth)
  ) u_pwm_counter (
      .clk(clk),
      .rst(1'b0),
      .enable(1'b1),
      .count(pwm_count)
  );

  assign dim_on = pwm_count < DutyDim;
  assign low_on = pwm_count < DutyLow;
  assign medium_on = pwm_count < DutyMedium;

  // Grey code brightness:
  // 00 dim, 01 low, 11 medium, 10 full
  assign brightness_on =
      (brightness_sel == 2'b00) ? dim_on :
      (brightness_sel == 2'b01) ? low_on :
      (brightness_sel == 2'b11) ? medium_on :
                                  1'b1;

  assign brightness_blank = !brightness_on;

  assign blank_hours = app_blank_hours || brightness_blank;
  assign blank_minutes = app_blank_minutes || brightness_blank;
  assign blank_seconds = app_blank_seconds || brightness_blank;

endmodule
