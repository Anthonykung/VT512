/**
* Copyright (c) 2023 Anthony Kung (anth.dev)
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     https://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*
* @file   vt_top.sv
* @author Anthony Kung <hi@anth.dev> (anth.dev)
* @date   Created on 05/31/2023 23:14:09 PM
*/


module vt512_top #(
  parameter DATA_WIDTH = 32,
  parameter MAX_IMAGE_SIZE = 512
) (
`ifdef USE_POWER_PINS
  inout vccd1,	// User area 1 1.8V supply
  inout vssd1,	// User area 1 digital ground
`endif

  // Wishbone Slave ports (WB MI A)
  input wb_clk_i,
  input wb_rst_i,
  input wbs_stb_i,
  input wbs_cyc_i,
  input wbs_we_i,
  input [3:0] wbs_sel_i,
  input [31:0] wbs_dat_i,
  input [31:0] wbs_adr_i,
  output wbs_ack_o,
  output [31:0] wbs_dat_o,

  // Logic Analyzer Signals
  input  [127:0] la_data_in,
  output [127:0] la_data_out,
  input  [127:0] la_oenb,

  // IOs
  input  [15:0] io_in,
  output [15:0] io_out,
  output [15:0] io_oeb,

  // IRQ
  output [2:0] irq
);

  reg [DATA_WIDTH-1:0] image_data_out;
  reg [MAX_IMAGE_SIZE_LOG2:0] image_size;
  reg size_detection_done;

  always @(posedge wb_clk_i) begin
    if (wb_rst_i) begin
      // Reset values
      wbs_ack_o <= 1'b0;
      wbs_dat_o <= 32'h0;
    end
    else if (wbs_cyc_i && wbs_stb_i && wbs_we_i) begin
      // Acknowledge the write
      wbs_ack_o <= 1'b1;

      // Check the address to determine the write destination
      case (wbs_adr_i)
        // If wbs_adr_i is 0x414E_0000, then it is a write to the control register
        32'h414E_0000: begin
          // Control register
        end
        // If wbs_adr_i is 0x414E_5700, then it is a write to the weight memory cells
        32'h414E_5700: begin
          // Weight memory cells
        end
        // If wbs_adr_i is 0x414E_4200, then it is a write to the bias memory cells
        32'h414E_4200: begin
          // Bias memory cells
        end
        // If wbs_adr_i is 0x414E_4900, then it is image data
        32'h414E_4900: begin
          // Image data
          image_capture image_capture_inst #(
            .DATA_WIDTH(DATA_WIDTH),
            .MAX_IMAGE_SIZE(IMG_WIDTH),
            .MAX_IMAGE_SIZE_LOG2(9),
          ) (
            .wb_clk_i(wb_clk_i),
            .wb_rst_i(wb_rst_i),
            .wbs_stb_i(wbs_stb_i),
            .wbs_cyc_i(wbs_cyc_i),
            .wbs_we_i(wbs_we_i),
            .wbs_dat_i(wbs_dat_i),
            .wbs_ack_o(wbs_ack_o),
            .wbs_dat_o(wbs_dat_o),
            .image_data_out(image_data_out),
            .image_size(image_size),
            .size_detection_done(size_detection_done),
          )
        end
        default: begin
          // Unknown address
        end
      endcase
    end
    else begin
      // No write
      wbs_ack_o <= 1'b0;
      wbs_dat_o <= 32'h0;
    end
  end

endmodule
