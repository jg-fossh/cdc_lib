/*
 
Copyright (c) 2023, Jose R. Garcia (jg-fossh@protonmail.com)
All rights reserved.

The following hardware description source code is subject to the terms of the
                 Open Hardware Description License, v. 1.0
If a copy of the afromentioned license was not distributed with this file you
can obtain one at http://juliusbaxter.net/ohdl/ohdl.txt

--------------------------------------------------------------------------------
File name    : dual_clock_fifo.v
Author       : Jose R Garcia (jg-fossh@protonmail.com)
Project Name : Clock Domain Crossing Library
Module Name  : dual_clock_fifo
Description  : Generic Dual Clock FIFO

Additional Comments:
   
*/
module dual_clock_fifo #(
  // FIFO Params
  parameter integer P_DATA_MSB = 7,      // FIFO Width-1
  parameter integer P_DEPTH    = 128,    // FIFO $clog2(Depth)-1
  // Write Synchronizers Params
  parameter integer P_WR_SYNC_DEPTH = 2, //
  // Read Synchronizers Params
  parameter integer P_RD_SYNC_DEPTH = 2  //
)(
  //
  input                 i_wr_clk,   //
  input                 i_wr_rst,   //
  input                 i_wr_inc,   //
  input  [P_DATA_MSB:0] i_wr_data,  // 
  output                o_wr_full,  //
  //
  input                 i_rd_clk,   //
  input                 i_rd_rst,   //
  input                 i_rd_inc,   //
  output [P_DATA_MSB:0] o_rd_data,  //
  output                o_rd_empty  //
);

  ///////////////////////////////////////////////////////////////////////////////
  // Internal Parameter Declarations
  ///////////////////////////////////////////////////////////////////////////////
  // General
  localparam integer L_PTR_MSB = $clog2(P_DEPTH)-1;

  ///////////////////////////////////////////////////////////////////////////////
  // Internal Signals Declarations
  ///////////////////////////////////////////////////////////////////////////////
  // Chip Enable
  wire w_ce = !i_wr_rst & !i_rd_rst;
  // Pointers
  wire [L_PTR_MSB:0] w_wr_ptr;
  wire [L_PTR_MSB:0] w_rd_ptr;
  // domain transitioning pointers
  wire [L_PTR_MSB:0] w_wr2rd_ptr;
  wire [L_PTR_MSB:0] w_rd2wr_ptr;

  ///////////////////////////////////////////////////////////////////////////////
  //            ********      Architecture Declaration      ********           //
  ///////////////////////////////////////////////////////////////////////////////

  ///////////////////////////////////////////////////////////////////////////////
  // Instance    : Write Controller
  // Description : handling the write requests
  ///////////////////////////////////////////////////////////////////////////////
  wr_ctrl #(
    .P_PTR_MSB (L_PTR_MSB)
  ) wr_ctrl_inst (
    .i_clk        (i_wr_clk),
    .i_rst        (i_wr_rst),
    .i_inc        (i_wr_inc),
    .i_rd_ptr     (w_rd2wr_ptr),
    .o_wr_ptr     (w_wr_ptr),
    .o_full       (o_wr_full)
  );

 ///////////////////////////////////////////////////////////////////////////////
  // Instance    : Flip-flop Synchronizer
  // Description : Synchronizing the write pointer from write to read domain
  ///////////////////////////////////////////////////////////////////////////////
  synchronizer #(
    .P_DATA_MSB(L_PTR_MSB),
    .P_DEPTH   (P_WR_SYNC_DEPTH)
  ) wr2rd_ptr_sync_inst (
    //
    .i_clk(i_rd_clk),   
    .i_rst(i_rd_rst), 
    //
    .i_d(w_wr_ptr),   
    .o_q(w_wr2rd_ptr)
  );

  ///////////////////////////////////////////////////////////////////////////////
  // Instance    : Flip-flop Synchronizer
  // Description : Synchronizing the read pointer from read to write domain
  ///////////////////////////////////////////////////////////////////////////////
  synchronizer #(
    .P_DATA_MSB(L_PTR_MSB),
    .P_DEPTH   (P_RD_SYNC_DEPTH)
  ) rd2wr_ptr_sync_inst (
    //
    .i_clk(i_wr_clk),   
    .i_rst(i_wr_rst), 
    //
    .i_d(w_rd_ptr),   
    .o_q(w_rd2wr_ptr)
  );

  ///////////////////////////////////////////////////////////////////////////////
  // Instance    : Read Controller
  // Description : handling the read requests
  ///////////////////////////////////////////////////////////////////////////////
  rd_ctrl #(
    .P_PTR_MSB (L_PTR_MSB)
  ) rd_ctrl_inst (
    .i_clk         (i_rd_clk),
    .i_rst         (i_rd_rst),
    .i_inc         (i_rd_inc),
    .i_wr_ptr      (w_wr2rd_ptr),
    .o_rd_ptr      (w_rd_ptr),
    .o_empty       (o_rd_empty)
  );

  ///////////////////////////////////////////////////////////////////////////////
  // Instance    : Dual Clock BRAM
  // Description : Inferrable Simple Dual Clock Block RAM.
  ///////////////////////////////////////////////////////////////////////////////
  generic_sbram #(
    // Compile time configurable parameters
    .P_SBRAM_DATA_MSB (P_DATA_MSB),
    .P_SBRAM_ADDR_MSB (L_PTR_MSB),
    .P_SBRAM_MASK_MSB (0),
    .P_SBRAM_HAS_FILE (0),
    .P_SBRAM_INIT_FILE(0)
  ) fifo_mem_inst (
    .i_ce   (w_ce     ),
    .i_wclk (i_wr_clk ),
    .i_rclk (i_rd_clk ),
    .i_waddr(w_wr_ptr ),
    .i_raddr(w_rd_ptr ),
    .i_we   (i_wr_inc ),
    .i_mask (0        ), // 0=writes, 1=masks
    .i_wdata(i_wr_data),
    .o_rdata(o_rd_data)
  );

endmodule // dual_clock_fifo
