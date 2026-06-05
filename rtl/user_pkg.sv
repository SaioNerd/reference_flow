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
  //Added by Giulio following ex03 solution
  localparam int unsigned NumUserDomainSubordinates = 1;

  localparam bit [31:0] UserRomAddrOffset   = croc_pkg::UserBaseAddr; // 32'h2000_0000;
  localparam bit [31:0] UserRomAddrRange    = 32'h0000_1000;          // every subordinate has at least 4KB

  localparam int unsigned NumDemuxSbrRules  = NumUserDomainSubordinates; // number of address rules in the decoder
  localparam int unsigned NumDemuxSbr       = NumDemuxSbrRules + 1; // additional OBI error, used for signal arrays


  /// Enum with user domain demultiplexer subordinate idxs 
  typedef enum bit [4:0]  {
    UserError  = 0,
    UserRom = 1 // Added by Giulio
  } user_demux_outputs_e;

  /// Address rules given to user domain demultiplexer (see croc_pkg.sv for examples)
  // localparam croc_pkg::addr_map_rule_t [0:0] UserAddrMap = '{
  //   '{
  //     idx:        UserDesign,
  //     start_addr: croc_pkg::UserBaseAddr,
  //     end_addr:   croc_pkg::UserBaseAddr + 32'h1000_0000
  //   }
  // };

  // Added by Giulio to integrate ROM
  localparam croc_pkg::addr_map_rule_t [NumDemuxSbrRules-1:0] UserAddrMap = '{
    '{ 
      idx:          UserRom, 
      start_addr:   UserRomAddrOffset,
      end_addr:     UserRomAddrOffset + UserRomAddrRange
    }
  };
  // All addresses outside the defined address rules go to the error subordinate

  // +1 for additional OBI error
  
  // Comment by Giulio 
  //localparam int unsigned NumDemuxSbr = $size(UserAddrMap) + 1;

endpackage

