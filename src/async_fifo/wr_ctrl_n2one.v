/*
 
Copyright (c) 2023, Jose R. Garcia (jg-fossh@protonmail.com)
All rights reserved.

The following hardware description source code is subject to the terms of the
                 Open Hardware Description License, v. 1.0
If a copy of the afromentioned license was not distributed with this file you
can obtain one at http://juliusbaxter.net/ohdl/ohdl.txt

--------------------------------------------------------------------------------
File name    : wr_ctrl_n2one.v
Author       : Jose R Garcia (jg-fossh@protonmail.com)
Project Name : Clock Domain Crossing Library
Module Name  : wr_ctrl_n2one
Description  : Many-to-One data units write controller

Additional Comments:
   no grey codes
*/
module wr_ctrl_n2one #(
  parameter integer P_PTR_MSB  = 4,
  //
  parameter integer P_MASK_MSB        = 3,
  parameter integer P_MASK_SHIFT_UNIT = 1
)(
  //
  input                 i_clk,
  input                 i_rst,
  //
  input                 i_inc,
  input  [P_PTR_MSB:0]  i_rd_ptr,
  //
  output                o_full,
  output [P_PTR_MSB:0]  o_wr_ptr,
  output [P_MASK_MSB:0] o_wr_mask
);

  ///////////////////////////////////////////////////////////////////////////////
  // Internal Parameter Declarations
  ///////////////////////////////////////////////////////////////////////////////
  localparam integer        L_PTR_PAD      = P_PTR_MSB-1;
  localparam integer        L_MASK_PAD     = (P_MASK_MSB+1)-P_MASK_SHIFT_UNIT;
  localparam [P_MASK_MSB:0] L_MASK_INITIAL = {{L_MASK_PAD{1'b1}}, {P_MASK_SHIFT_UNIT{1'b0}}};

  ///////////////////////////////////////////////////////////////////////////////
  // Internal Signals Declarations
  ///////////////////////////////////////////////////////////////////////////////
  // 
  reg [P_PTR_MSB:0] r_wr_ptr;
  reg               r_full;
  // Data Input Wire
  reg [P_MASK_MSB:0] r_wr_mask;
  // Write Controls Asynch Logic
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
      r_wr_ptr  <= 0;
      r_full    <= 1'b0;
      r_wr_mask <= L_MASK_INITIAL;
    end
    else begin
      r_full <= w_full;

      if (i_inc == 1'b1) begin
        if (r_wr_mask[P_MASK_MSB] == 1'b0) begin
          r_wr_mask <= L_MASK_INITIAL;
          r_wr_ptr  <= r_wr_ptr + {{L_PTR_PAD{1'b0}}, {~w_full}}; //
        end
        else begin
          r_wr_mask <= r_wr_mask << P_MASK_SHIFT_UNIT;
        end
      end
    end
  end // wr_ctrls_proc

  //
  assign o_full        = r_full;
  assign o_wr_ptr      = r_wr_ptr;
  assign o_wr_mask     = r_wr_mask;

endmodule // wr_ctrl_n2one
