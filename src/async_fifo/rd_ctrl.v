/*
 
Copyright (c) 2023, Jose R. Garcia (jg-fossh@protonmail.com)
All rights reserved.

The following hardware description source code is subject to the terms of the
                 Open Hardware Description License, v. 1.0
If a copy of the afromentioned license was not distributed with this file you
can obtain one at http://juliusbaxter.net/ohdl/ohdl.txt

--------------------------------------------------------------------------------
File name    : rd_ctrl.v
Author       : Jose R Garcia (jg-fossh@protonmail.com)
Project Name : Clock Domain Crossing Library
Module Name  : rd_ctrl
Description  : Read controller for a generic dual clock FIFO

Additional Comments:
   
*/
module rd_ctrl #(
  parameter integer P_PTR_MSB = 4
)(
  input                 i_clk,
  input                 i_rst,
  input                 i_inc,
  input  [P_PTR_MSB:0]  i_wr_ptr,
  //
  output [P_PTR_MSB:0]  o_rd_ptr,
  output                o_empty //
);

  ///////////////////////////////////////////////////////////////////////////////
  // Internal Parameter Declarations
  ///////////////////////////////////////////////////////////////////////////////
  localparam integer L_PTR_PAD = P_PTR_MSB-1;

  ///////////////////////////////////////////////////////////////////////////////
  // Internal Signals Declarations
  ///////////////////////////////////////////////////////////////////////////////
  // 
  reg [P_PTR_MSB:0] r_rd_ptr;
  reg               r_empty;
  
  // Read Controls Asynch Logic
  wire w_empty = ($unsigned(r_rd_ptr) == $unsigned(i_wr_ptr)) ? 1'b1 : 1'b0;
  
  ///////////////////////////////////////////////////////////////////////////////
  //            ********      Architecture Declaration      ********           //
  ///////////////////////////////////////////////////////////////////////////////

  ///////////////////////////////////////////////////////////////////////////////
  // Process     : Read Pointer
  // Description : Creates an incrementing read pointer and the empty flag. 
  ///////////////////////////////////////////////////////////////////////////////
  always @(posedge i_clk) begin : read_pointer_proc
    if (i_rst == 1'b1) begin
      r_empty  <= 1'b1;
      r_rd_ptr <= 0;
    end
    else begin
      r_rd_ptr <= r_rd_ptr + {{L_PTR_PAD{1'b0}}, {(i_inc & ~w_empty)}}; //
      r_empty  <= w_empty;
    end
  end // read_pointer_proc
  //
  assign o_empty  = r_empty;
  assign o_rd_ptr = r_rd_ptr;

endmodule // rd_ctrl
