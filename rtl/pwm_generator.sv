`timescale 1ns / 1ps

// Fixed-period, fixed-duty PWM generator.
// pwm_out is high for DUTY_CYCLES clocks in each period.
module pwm_generator #(
    // Number of clock cycles in one PWM period
    parameter int PERIOD_CYCLES = 50_000_000,

    // Number of clock cycles output is high
    parameter int DUTY_CYCLES = 25_000_000
) (
    input  logic clk,
    input  logic rst,
    output logic pwm_out
);

  localparam int CountWidth = $clog2(PERIOD_CYCLES);
  localparam int CompareWidth = CountWidth + 1;

  logic [  CountWidth-1:0] count;
  logic [CompareWidth-1:0] count_compare;

  localparam logic [CompareWidth-1:0] DutyCycles = CompareWidth'(DUTY_CYCLES);

  mod_n_counter #(
      .N(PERIOD_CYCLES),
      .WIDTH(CountWidth)
  ) u_count (
      .clk(clk),
      .rst(rst),
      .enable(1'b1),
      .count(count)
  );

  // Extend count by one bit, so DUTY_CYCLES can equal PERIOD_CYCLES
  assign count_compare = {1'b0, count};

  // high at the start of each PWM period
  assign pwm_out = count_compare < DutyCycles;

endmodule
