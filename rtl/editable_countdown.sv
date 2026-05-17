`timescale 1ns / 1ps

// Editable countdown digit.
// In edit mode, inc/dec changes the value.
// Outside edit mode, tick counts down.
module editable_countdown #(
    parameter int MAX   = 59,
    parameter int WIDTH = 6
) (
    input logic clk,
    input logic clr,
    input logic tick,
    input logic edit_mode,
    input logic inc,
    input logic dec,
    output logic [WIDTH-1:0] count,
    output logic borrow_out
);

  logic count_enable;
  logic count_up;

  // edit mode allows manual increment or decrement
  logic inc_event;
  logic dec_event;

  // normal mode counts down on tick
  logic tick_event;

  assign inc_event = edit_mode && inc && !dec && !clr;
  assign dec_event = edit_mode && dec && !inc && !clr;
  assign tick_event = !edit_mode && tick && !clr;

  assign count_enable = inc_event || dec_event || tick_event;

  // inc counts up, dec and tick count down
  assign count_up = inc_event;

  // borrow is combinational, based on current count
  assign borrow_out = tick_event && (count == '0);

  up_down_counter_rst #(
      .MAX  (MAX),
      .WIDTH(WIDTH)
  ) u_count (
      .clk   (clk),
      .rst   (clr),
      .enable(count_enable),
      .up    (count_up),
      .count (count)
  );

endmodule
