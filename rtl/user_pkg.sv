// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Authors:
// - Philippe Sauter <phsauter@iis.ee.ethz.ch>

`include "obi/typedef.svh"

package user_pkg;

  //////////////////
  // User Manager //
  //////////////////

  // None


  ///////////////////////
  // User Subordinates //
  ///////////////////////

  // The base address of the user domain can be retrived from `croc_pkg::UserBaseAddr`
  // Recommended: place subordinates at 4KB boundaries (32'hXXXX_X000)

  /// Enum with user domain demultiplexer subordinate idxs
  typedef enum bit [4:0]  {
    UserError   = 0,
    UserBank0   = 1,
    UserRom     = 3,
    UserDesign  = 4
  } user_demux_outputs_e;

  /// Address rules given to user domain demultiplexer (see croc_pkg.sv for examples)
  localparam croc_pkg::addr_map_rule_t [3:0] UserAddrMap = '{
    '{
      idx:        UserBank0,
      start_addr: croc_pkg::UserBaseAddr,                // 32'h1000_0000
      end_addr:   croc_pkg::UserBaseAddr + 32'h1000
    },
    '{
      idx:        UserBank0+1,
      start_addr: croc_pkg::UserBaseAddr + 32'h1000,    //MODIFIED FOR SW TB
      end_addr:   croc_pkg::UserBaseAddr + 32'h2000
    },
    '{
      idx:        UserRom,
      start_addr: croc_pkg::UserBaseAddr + 32'h1000_0000, // = 32'h2000_0000
      end_addr:   croc_pkg::UserBaseAddr + 32'h1000_1000
    },
    '{
      idx:        UserDesign,
      start_addr: croc_pkg::UserBaseAddr + 32'h1000_1000,
      end_addr:   croc_pkg::UserBaseAddr + 32'h1000_2000
    }
  };
  // All addresses outside the defined address rules go to the error subordinate

  // SECDED Feature Toggle
  // 1'b1 = Use standard 32-bit SRAM (No Encryption/ECC)
  // 1'b0 = Use 64-bit SRAM with Byte-wise SECDED
  localparam bit SECDEDBypass = 1'b0;
  
  // +1 for additional OBI error
  localparam int unsigned NumDemuxSbr = $size(UserAddrMap) + 1;

endpackage
