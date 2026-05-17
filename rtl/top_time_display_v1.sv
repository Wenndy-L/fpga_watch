`timescale 1ns / 1ps

// Variable-speed time display.
// SW[1:0] selects how fast the clock runs.
module top_time_display_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input  logic       CLOCK_50,
    input  logic [1:0] SW,
    output logic [6:0] HEX5,
    output logic [6:0] HEX4,
    output logic [6:0] HEX3,
    output logic [6:0] HEX2,
    output logic [6:0] HEX1,
    output logic [6:0] HEX0
);

  logic tick_1hz;
  logic tick_25hz;
  logic tick_1khz;
  logic tick_50mhz;
  logic time_tick;

  logic [4:0] hours;
  logic [5:0] minutes;
  logic [5:0] seconds;

  logic [3:0] hours_tens;
  logic [3:0] hours_ones;
  logic [3:0] minutes_tens;
  logic [3:0] minutes_ones;
  logic [3:0] seconds_tens;
  logic [3:0] seconds_ones;

  // 1 Hz tick
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) u_rate_1hz (
      .clk (CLOCK_50),
      .run (SW == 2'b00),
      .tick(tick_1hz)
  );

  // 25 Hz tick
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 25)
  ) u_rate_25hz (
      .clk (CLOCK_50),
      .run (SW == 2'b01),
      .tick(tick_25hz)
  );

  // 1 kHz tick
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 1000)
  ) u_rate_1khz (
      .clk (CLOCK_50),
      .run (SW == 2'b10),
      .tick(tick_1khz)
  );

  // 50 MHz mode: tick every clock cycle
  assign tick_50mhz = SW == 2'b11;

  // Select one tick source using the switches
  always_comb begin
    unique case (SW)
      2'b00: time_tick = tick_1hz;
      2'b01: time_tick = tick_25hz;
      2'b10: time_tick = tick_1khz;
      2'b11: time_tick = tick_50mhz;
    endcase
  end

  hms_counter u_hms_counter (
      .clk(CLOCK_50),
      .enable(time_tick),
      .hours(hours),
      .minutes(minutes),
      .seconds(seconds)
  );

  binary_to_bcd u_hours_bcd (
      .bin ({2'b00, hours}),
      .tens(hours_tens),
      .ones(hours_ones)
  );

  binary_to_bcd u_minutes_bcd (
      .bin ({1'b0, minutes}),
      .tens(minutes_tens),
      .ones(minutes_ones)
  );

  binary_to_bcd u_seconds_bcd (
      .bin ({1'b0, seconds}),
      .tens(seconds_tens),
      .ones(seconds_ones)
  );

  seven_segment u_hex5 (
      .digit(hours_tens),
      .blank(1'b0),
      .segments(HEX5)
  );

  seven_segment u_hex4 (
      .digit(hours_ones),
      .blank(1'b0),
      .segments(HEX4)
  );

  seven_segment u_hex3 (
      .digit(minutes_tens),
      .blank(1'b0),
      .segments(HEX3)
  );

  seven_segment u_hex2 (
      .digit(minutes_ones),
      .blank(1'b0),
      .segments(HEX2)
  );

  seven_segment u_hex1 (
      .digit(seconds_tens),
      .blank(1'b0),
      .segments(HEX1)
  );

  seven_segment u_hex0 (
      .digit(seconds_ones),
      .blank(1'b0),
      .segments(HEX0)
  );

endmodule
