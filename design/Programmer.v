`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/23/2026 05:43:03 PM
// Design Name: 
// Module Name: Programmer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


//1MHz CCLK 
//slave serial M0:1 M1:1
// 8 bit width 360606 depth coe file
// send data when neg edge of the clock and sprtan 6 sample at posed


module Programmer(input clk,input rst_n,input init_b,output reg program_b,output reg Dout);

//counters for streaming
reg [18:0] byte_counter;//tied upo to the address of bram and changed at clk_divider_counter[0] bit of the counter
reg [7:0] bit_counter;// tied to clk_divider_counter[3] bit of the counter


// clock divider counters
reg clk_divider_counter;
reg cl_divider_counter_wire;

//Bram interface
reg [18:0] addra_Bram;
reg [7:0] douta_Bram;

   blk_mem_gen_0 spartan6 (
  .clka(clk),    // input wire clka
  .ena(1'b1),      // input wire ena
  .addra(addra),  // input wire [18 : 0] addra
  .douta(douta)  // output wire [7 : 0] douta
);
endmodule
