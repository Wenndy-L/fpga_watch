`timescale 1ns / 1ps

// Timer top-level.
// button[0] starts/stops, or decrements in set mode.
// button[1] increments in set mode.
// button[3] long press enters set mode, short press moves edit field.
module user_top_timer_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
`ifdef FORMAL
    output logic       probe_running,
    output logic [2:0] probe_mode_enable,
`endif
    input  logic       clk,
    /* verilator lint_off UNUSEDSIGNAL */
    input  logic [3:0] button,
    input  logic [9:0] sw,
    /* verilator lint_on UNUSEDSIGNAL */
    output logic [9:0] led,
    output logic [6:0] hours_disp,
    output logic [6:0] minutes_disp,
    output logic [6:0] seconds_disp,
    output logic       blank_hours,
    output logic       blank_minutes,
    output logic       blank_seconds
);

  logic [4:0] hours;
  logic [5:0] minutes;
  logic [5:0] seconds;

  logic [2:0] mode_enable;
  logic edit_mode;
  logic timer_zero;

  logic running_state;
  logic running;
  logic start_stop_press;
  logic start_stop_event;

  logic one_second_tick;
  logic timer_tick;

  logic inc_pulse;
  logic dec_pulse;

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

  logic seconds_borrow;
  logic minutes_borrow;

  /* verilator lint_off UNUSEDSIGNAL */
  logic unused_hours_borrow;
  /* verilator lint_on UNUSEDSIGNAL */

  logic flash_on;

  assign edit_mode = mode_enable != 3'b000;
  assign timer_zero = (hours == '0) && (minutes == '0) && (seconds == '0);

  // Effective running output.
  // It is forced low whenever edit mode is active.
  assign running = running_state && !edit_mode;

  rising_edge_detector u_start_stop_edge (
      .clk(clk),
      .sig_in(button[0]),
      .rise(start_stop_press)
  );

  assign start_stop_event = start_stop_press && !edit_mode;

  // running/stopped state
  initial running_state = 1'b0;

  always_ff @(posedge clk) begin
    if (timer_zero || edit_mode) begin
      running_state <= 1'b0;
    end else if (start_stop_event) begin
      running_state <= !running_state;
    end
  end

  // Edit mode is entered only while not running
  edit_mode_selector #(
      .HOLD_CYCLES(CYCLES_PER_SECOND)
  ) u_mode_selector (
      .clk(clk),
      .button(button[3] && !running_state),
      .mode_enable(mode_enable)
  );

  button_auto_repeat #(
      .HOLD_CYCLES  (CYCLES_PER_SECOND / 2),
      .REPEAT_CYCLES(CYCLES_PER_SECOND / 10)
  ) u_inc_repeat (
      .clk(clk),
      .button(button[1]),
      .pulse(inc_pulse)
  );

  button_auto_repeat #(
      .HOLD_CYCLES  (CYCLES_PER_SECOND / 2),
      .REPEAT_CYCLES(CYCLES_PER_SECOND / 10)
  ) u_dec_repeat (
      .clk(clk),
      .button(button[0]),
      .pulse(dec_pulse)
  );

  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) u_one_second_tick (
      .clk (clk),
      .run (running),
      .tick(one_second_tick)
  );

  assign timer_tick = running && !timer_zero && one_second_tick;

  assign seconds_tick = timer_tick;
  assign minutes_tick = seconds_borrow;
  assign hours_tick = minutes_borrow;

  assign seconds_edit = mode_enable[0];
  assign minutes_edit = mode_enable[1];
  assign hours_edit = mode_enable[2];

  assign seconds_inc = inc_pulse && seconds_edit;
  assign minutes_inc = inc_pulse && minutes_edit;
  assign hours_inc = inc_pulse && hours_edit;

  assign seconds_dec = dec_pulse && seconds_edit;
  assign minutes_dec = dec_pulse && minutes_edit;
  assign hours_dec = dec_pulse && hours_edit;

  editable_countdown #(
      .MAX  (59),
      .WIDTH(6)
  ) u_seconds (
      .clk(clk),
      .clr(1'b0),
      .tick(seconds_tick),
      .edit_mode(seconds_edit),
      .inc(seconds_inc),
      .dec(seconds_dec),
      .count(seconds),
      .borrow_out(seconds_borrow)
  );

  editable_countdown #(
      .MAX  (59),
      .WIDTH(6)
  ) u_minutes (
      .clk(clk),
      .clr(1'b0),
      .tick(minutes_tick),
      .edit_mode(minutes_edit),
      .inc(minutes_inc),
      .dec(minutes_dec),
      .count(minutes),
      .borrow_out(minutes_borrow)
  );

  editable_countdown #(
      .MAX  (23),
      .WIDTH(5)
  ) u_hours (
      .clk(clk),
      .clr(1'b0),
      .tick(hours_tick),
      .edit_mode(hours_edit),
      .inc(hours_inc),
      .dec(hours_dec),
      .count(hours),
      .borrow_out(unused_hours_borrow)
  );

  pwm_generator #(
      .PERIOD_CYCLES(CYCLES_PER_SECOND / 2),
      .DUTY_CYCLES  ((CYCLES_PER_SECOND / 2) * 4 / 5)
  ) u_flash_pwm (
      .clk(clk),
      .rst(1'b0),
      .pwm_out(flash_on)
  );

  assign hours_disp = {2'b00, hours};
  assign minutes_disp = {1'b0, minutes};
  assign seconds_disp = {1'b0, seconds};

  assign blank_hours = hours_edit && !flash_on;
  assign blank_minutes = minutes_edit && !flash_on;
  assign blank_seconds = seconds_edit && !flash_on;

  assign led = sw;

`ifdef FORMAL
  assign probe_running = running;
  assign probe_mode_enable = mode_enable;
`endif

endmodule
