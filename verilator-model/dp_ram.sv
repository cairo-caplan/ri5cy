// Copyright 2015 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the “License”); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

module dp_ram
  #(
    parameter ADDR_WIDTH = 8
  )(
    // Clock and Reset
    input  logic clk,

    input  logic                   en_a_i,
    input  logic [ADDR_WIDTH-1:0]  addr_a_i,
    input  logic [31:0]            wdata_a_i,
    output logic [127:0]           rdata_a_o,
    input  logic                   we_a_i,
    input  logic [3:0]             be_a_i,

    input  logic                   en_b_i,
    input  logic [ADDR_WIDTH-1:0]  addr_b_i,
    input  logic [31:0]            wdata_b_i,
    output logic [31:0]            rdata_b_o,
    input  logic                   we_b_i,
    input  logic [3:0]             be_b_i
  );

  localparam bytes = 2**ADDR_WIDTH;

  logic [7:0] mem[bytes];

  always @(posedge clk)
  begin

    rdata_a_o[  0+: 8] <= mem[addr_a_i +  0];
    rdata_a_o[  8+: 8] <= mem[addr_a_i +  1];
    rdata_a_o[ 16+: 8] <= mem[addr_a_i +  2];
    rdata_a_o[ 24+: 8] <= mem[addr_a_i +  3];
    rdata_a_o[ 32+: 8] <= mem[addr_a_i +  4];
    rdata_a_o[ 40+: 8] <= mem[addr_a_i +  5];
    rdata_a_o[ 48+: 8] <= mem[addr_a_i +  6];
    rdata_a_o[ 56+: 8] <= mem[addr_a_i +  7];
    rdata_a_o[ 64+: 8] <= mem[addr_a_i +  8];
    rdata_a_o[ 72+: 8] <= mem[addr_a_i +  9];
    rdata_a_o[ 80+: 8] <= mem[addr_a_i + 10];
    rdata_a_o[ 88+: 8] <= mem[addr_a_i + 11];
    rdata_a_o[ 96+: 8] <= mem[addr_a_i + 12];
    rdata_a_o[104+: 8] <= mem[addr_a_i + 13];
    rdata_a_o[112+: 8] <= mem[addr_a_i + 14];
    rdata_a_o[120+: 8] <= mem[addr_a_i + 15];

    /* addr_b_i is the actual memory address referenced */

    if (en_b_i)
    begin
      /* handle writes */
      if (we_b_i)
      begin
        case (be_b_i[3:0])
          /* full word store */
          4'b1111:
          begin
            mem[addr_b_i    ] <= wdata_b_i[ 7: 0];
            mem[addr_b_i + 1] <= wdata_b_i[15: 8];
            mem[addr_b_i + 2] <= wdata_b_i[23:16];
            mem[addr_b_i + 3] <= wdata_b_i[31:24];
          end
          /* single byte stores */
          4'b0001: mem[addr_b_i] <= wdata_b_i[ 7: 0];
          4'b0010: mem[addr_b_i] <= wdata_b_i[15: 8];
          4'b0100: mem[addr_b_i] <= wdata_b_i[23:16];
          4'b1000: mem[addr_b_i] <= wdata_b_i[31:24];
          /* half-word stores */
          4'b0011:
          begin
            mem[addr_b_i    ] <= wdata_b_i[ 7: 0];
            mem[addr_b_i + 1] <= wdata_b_i[15: 8];
          end
          4'b1100:
          begin
            mem[addr_b_i    ] <= wdata_b_i[23:16];
            mem[addr_b_i + 1] <= wdata_b_i[31:24];
          end
        endcase
      end
      /* handle reads */
      else
      begin
        case (be_b_i[3:0])
          /* full word load */
          4'b1111:
          begin
            rdata_b_o[ 7: 0] <= mem[addr_b_i    ];
            rdata_b_o[15: 8] <= mem[addr_b_i + 1];
            rdata_b_o[23:16] <= mem[addr_b_i + 2];
            rdata_b_o[31:24] <= mem[addr_b_i + 3];
          end
          /* single byte loads */
          4'b0001: rdata_b_o[ 7: 0] <= mem[addr_b_i];
          4'b0010: rdata_b_o[15: 8] <= mem[addr_b_i];
          4'b0100: rdata_b_o[23:16] <= mem[addr_b_i];
          4'b1000: rdata_b_o[31:24] <= mem[addr_b_i];
          /* half-word loads */
          4'b0011:
          begin
            rdata_b_o[ 7: 0] <= mem[addr_b_i    ];
            rdata_b_o[15: 8] <= mem[addr_b_i + 1];
          end
          4'b1100:
          begin
            rdata_b_o[23:16] <= mem[addr_b_i    ];
            rdata_b_o[31:24] <= mem[addr_b_i + 1];
          end
        endcase
      end
    end
  end

  function [7:0] readByte;
    /* verilator public */
    input integer byte_addr;
    readByte = mem[byte_addr];
  endfunction

  task writeByte;
    /* verilator public */
    input integer byte_addr;
    input [7:0] val;
    mem[byte_addr] = val;
  endtask

endmodule
