/*
 
Copyright (c) 2023, Jose R. Garcia (jg-fossh@protonmail.com)
All rights reserved.

The following hardware description source code is subject to the terms of the
                 Open Hardware Description License, v. 1.0
If a copy of the afromentioned license was not distributed with this file you
can obtain one at http://juliusbaxter.net/ohdl/ohdl.txt

--------------------------------------------------------------------------------
File name    : wr_ctrl.v
Author       : Jose R Garcia (jg-fossh@protonmail.com)
Project Name : Clock Domain Crossing Library
Module Name  : wr_ctrl
Description  : Write controller for a dual clock fifo

Additional Comments:
   No grey codes
*/
module wr_ctrl #(
  parameter integer P_PTR_MSB = 4
)(
  input                i_clk,
  input                i_rst,
  input                i_inc,
  input  [P_PTR_MSB:0] i_rd_ptr,
  //
  output [P_PTR_MSB:0] o_wr_ptr,
  output               o_full 
);

  ///////////////////////////////////////////////////////////////////////////////
  // Internal Parameter Declarations
  ///////////////////////////////////////////////////////////////////////////////
  localparam integer L_PTR_PAD = P_PTR_MSB-1;

  ///////////////////////////////////////////////////////////////////////////////
  // Internal Signals Declarations
  ///////////////////////////////////////////////////////////////////////////////
  // 
  reg [P_PTR_MSB:0] r_wr_ptr;
  reg               r_full;

  // Write Controls Asynch Logic
  //wire w_full = ($signed(r_wr_ptr) == $signed(i_rd_ptr)-1) ? 1'b1 : 1'b0;
  wire w_full = ($signed(r_wr_ptr)+1 == $signed(i_rd_ptr)) ? 1'b1 : 1'b0;


  ///////////////////////////////////////////////////////////////////////////////
  //            ********      Architecture Declaration      ********           //
  ///////////////////////////////////////////////////////////////////////////////

  ///////////////////////////////////////////////////////////////////////////////
  // Process     : Write Controls
  // Description : Creates the write pointer and full flag.
  ///////////////////////////////////////////////////////////////////////////////
  always @(posedge i_clk) begin : wr_ctrls_proc
    if (i_rst == 1'b1) begin
      r_wr_ptr <= 0;
      r_full   <= 1'b0;
    end
    else begin
      r_wr_ptr <= r_wr_ptr + {{L_PTR_PAD{1'b0}}, {(i_inc & !w_full)}}; //
      r_full   <= w_full;
    end
  end // wr_ctrls_proc
  //
  assign o_full   = r_full;
  assign o_wr_ptr = r_wr_ptr;

endmodule
