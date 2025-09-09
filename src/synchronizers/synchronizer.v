/*
 
Copyright (c) 2023, Jose R. Garcia (jg-fossh@protonmail.com)
All rights reserved.

The following hardware description source code is subject to the terms of the
                 Open Hardware Description License, v. 1.0
If a copy of the afromentioned license was not distributed with this file you
can obtain one at http://juliusbaxter.net/ohdl/ohdl.txt

--------------------------------------------------------------------------------
File name    : synchronizer.v
Author       : Jose R Garcia (jg-fossh@protonmail.com)
Project Name : Clock Domain Crossing Library
Module Name  : synchronizer
Description  : Vector synchronizer

Additional Comments:
   Flip-flop synchronizers
*/
module synchronizer #(
  parameter integer P_DATA_MSB = 0,
  parameter integer P_DEPTH    = 2 
)(
  // 
  input i_clk, 
  input i_rst,
  //
  input  [P_DATA_MSB:0] i_d, 
  output [P_DATA_MSB:0] o_q  
);

/*verilator coverage_off*/
  ///////////////////////////////////////////////////////////////////////////////
  // Parameters Check
  //     This is Verilog code and assertions were introduced in SystemVerilog,
  //     therefore we are using an initial statement to catch mis-configurations.
  //     Also Yosys and Verilator can't handle $error() nor $fatal() hence 
  //     defaulted to $display() to provide feedback to the integrator. The 
  //     messsages are in xml to promote automation tools that can parse the log
  //     and create reports.
  ///////////////////////////////////////////////////////////////////////////////
  initial begin
    if (P_DEPTH < 2) begin
      $display("[COMPILE-ERROR]");
      $display("  source: synchronizer");
      $display("  type: Parameter Out of Range");
      $display("  parameters:");
      $display("    P_DEPTH: %0d", P_DEPTH);
      $display("  description: P_DEPTH is too small. Needs to be >= 2.");
    end
  end
/*verilator coverage_on*/

  ///////////////////////////////////////////////////////////////////////////////
  // Internal Signals Declarations
  ///////////////////////////////////////////////////////////////////////////////
  //
  reg [P_DATA_MSB:0] q_sync [P_DEPTH-1:0];
  //
  genvar iter;

  ///////////////////////////////////////////////////////////////////////////////
  //            ********      Architecture Declaration      ********           //
  ///////////////////////////////////////////////////////////////////////////////

  /////////////////////////////////////////////////////////////////////////////
  // Process     : First Synchronizer
  // Description : 
  /////////////////////////////////////////////////////////////////////////////
  always @(posedge i_clk) begin : sync_0_proc
    if (i_rst) begin
      q_sync[0] <= 0;
    end
    else begin
      q_sync[0] <= i_d;
    end
  end // sync_0_proc

  generate
  for (iter = 1; iter <= P_DEPTH-1; iter = iter+1) begin : sync_chain_gen
    
  /////////////////////////////////////////////////////////////////////////////
  // Process     : Subsequent Synchs
  // Description : 
  /////////////////////////////////////////////////////////////////////////////
  always @(posedge i_clk) begin
    if (i_rst) begin
      q_sync[iter] <= 0;
    end
    else begin
      q_sync[iter] <= q_sync[iter-1];
    end
  end

  end // sync_chain_gen
  endgenerate
  //
  assign o_q = q_sync[P_DEPTH-1];
endmodule // synchronizer
