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


module VisionTransformer #(
  parameter DATA_WIDTH = 8,
  parameter IMG_WIDTH = 512,
  parameter IMG_HEIGHT = 512
) (
  // Caravel project wrapper ports
  input wire wb_clk_i,
  input wire wb_rst_i,
  input wire wbs_stb_i,
  input wire wbs_cyc_i,
  input wire wbs_we_i,
  input wire [3:0] wbs_sel_i,
  input wire [31:0] wbs_dat_i,
  input wire [31:0] wbs_adr_i,
  output wire wbs_ack_o,
  output wire [31:0] wbs_dat_o,

  // Communication with external host microcontroller
  input wire [DATA_WIDTH-1:0] i_image_data,
  input wire i_image_valid,
  output wire [DATA_WIDTH-1:0] o_prediction
);
  parameter NUM_PATCHES = (IMG_WIDTH/16) * (IMG_HEIGHT/16);
  parameter NUM_CHANNELS = 3;  // Assuming RGB input

  // Define internal signals and registers
  reg [DATA_WIDTH-1:0] patches[NUM_PATCHES][NUM_CHANNELS][16][16];
  reg [DATA_WIDTH-1:0] linearized[NUM_PATCHES][NUM_CHANNELS*256];
  reg [DATA_WIDTH-1:0] transformed[NUM_PATCHES][NUM_CHANNELS*256];

  // Define the modules and components of the Vision Transformer
  // ...

  // Implement the control and data path of the Vision Transformer
  always @(posedge wb_clk_i or negedge wb_rst_i) begin
    if (!wb_rst_i) begin
      // Reset logic
      // Initialize internal registers and signals

    end else begin
      // Clock cycle logic
      if (wbs_stb_i && wbs_cyc_i && wbs_we_i) begin
        // Handle write requests from the external host microcontroller
        // Update the necessary internal registers and signals based on the write requests
      end

      // Other control and data path logic

    end
  end
endmodule
