`timescale 1ns / 1ps

// Editable counter.
// In normal mode it counts up on tick.
// In edit mode inc counts up and dec counts down.
module editable_counter #(
    parameter int N     = 60,
    parameter int WIDTH = 6
) (
    input  logic             clk,
    input  logic             tick,       // Count increments on tick when edit_mode is low
    input  logic             edit_mode,
    input  logic             inc,        // Count increments by one when edit_mode is high
    input  logic             dec,        // Count decrements by one when edit_mode is high
    output logic [WIDTH-1:0] count
);

  logic enable;
  logic up;

  up_down_counter #(
      .MAX  (N - 1),
      .WIDTH(WIDTH)
  ) u_counter (
      .clk(clk),
      .enable(enable),
      .up(up),
      .count(count)
  );

  wire inc_event = edit_mode && inc && !dec;
  wire dec_event = edit_mode && dec && !inc;
  wire tick_event = !edit_mode && tick;

  // Count direction: normal tick and inc both count up; dec counts down
  assign up = tick_event || inc_event;

  // Counter only changes when exactly one valid event happens
  assign enable = tick_event || inc_event || dec_event;

endmodule
